# Operator construction

SymBasis.jl does not ship an `Operator` or `Hamiltonian` type of its own. Instead, it gives you a symmetry-reduced [`Basis`](@ref SymBasis.Bases.Basis) (see [Basis construction](@ref "Basis construction")) together with the low-level tools needed to act with an operator on a basis state and map the result back onto a representative (see [State operations](@ref "State operations") and [Determining representative states](@ref "Determining representative states")). Building a Hamiltonian, or any other operator, is then just a matter of assembling its matrix elements yourself.

This page covers two ways to do that:
- **From scratch**, using only SymBasis.jl's digit primitives and [`representative`](@ref SymBasis.Bases.representative). This works for any degree of freedom, including fermions, and requires no additional dependency.
- **With [OperatorAlgebra.jl](https://github.com/h-mnzlr/OperatorAlgebra.jl)**, an optional external package that lets you express an operator as a sum of products of single-site matrices and have SymBasis.jl project it onto the symmetry-reduced basis for you. This is more convenient, but currently only supports bosonic and spin degrees of freedom, not fermions.

```@contents
Pages = ["operator_construction.md"]
Depth = 2
```

## Building operators from scratch

The general recipe is the same for every model:
1. Walk the basis states with `for (n, sₙ) in enumerate(ba.states)`; `n` is the column index of `sₙ` and `ba.norms[n]` its normalization constant.
2. Apply the local pieces of the operator (using `read`, `eachdigit`, `flip`, `dec`, `inc`, or `write` from [State operations](@ref "State operations")) to obtain a candidate state.
3. Map the candidate state back to its representative with `rep_s, rep_fac = representative(candidate, ba)`, and look up its row index with [`state_index(ba, rep_s)`](@ref SymBasis.Bases.state_index), which returns `nothing` if `rep_s` is not in the basis (see [Looking up states](@ref "Looking up states")).
4. Accumulate the matrix element, weighted by `rep_fac` and the normalization ratio `sqrt(Nₘ/Nₙ)` (see [Determining representative states](@ref "Determining representative states") for where this factor comes from), into a sparse matrix.

As a concrete example, consider the transverse-field Ising chain with periodic boundary conditions,
```math
H = J\sum_{i} Z_i Z_{i+1} + h\sum_i X_i~,
```
resolved in the momentum-$k=0$ sector of a translationally-invariant spin-1/2 chain:
```@example ising
using SymBasis

N = 6 # number of sites
J = 1.0 # Ising coupling
h = 0.5 # transverse field

dofo = dof_object(Spin(1 // 2))

# resolve translational symmetry at momentum k=0
T_sg = sym(Translational(0, mod1.((1:N) .+ 1, N)), dofo)
ba = basis(dofo, N, T_sg)
```

The diagonal $ZZ$ term is read off directly from each state's digits (digit `0`/`1` corresponds to eigenvalue $+1$/$-1$ of $Z$), and the off-diagonal $X$ term flips one site at a time and maps the result back to its representative:
```@example ising
using SparseArrays

hilbert_dim = length(ba.states)

I_vec = Int64[]
J_vec = Int64[]
V_vec = ComplexF64[]

for (n, sₙ) in enumerate(ba.states)
    Nₙ = ba.norms[n]

    # diagonal ZZ term
    diag_val = 0.0
    for i in 1:N
        j = mod1(i + 1, N)
        zᵢ = 1 - 2 * Int(read(sₙ, i)) # digit 0/1 -> eigenvalue +1/-1
        zⱼ = 1 - 2 * Int(read(sₙ, j))
        diag_val += J * zᵢ * zⱼ
    end
    push!(I_vec, n)
    push!(J_vec, n)
    push!(V_vec, diag_val)

    # off-diagonal X term
    for i in 1:N
        temp_s = flip(sₙ, i)
        rep_s, rep_fac = representative(temp_s, ba)

        m = state_index(ba, rep_s)
        if m !== nothing
            Nₘ = ba.norms[m]

            all_fac = h * sqrt(Nₘ / Nₙ) * rep_fac

            push!(I_vec, m)
            push!(J_vec, n)
            push!(V_vec, all_fac)
        end
    end
end

# construct the sparse Hamiltonian matrix
h_manual = sparse(I_vec, J_vec, V_vec, hilbert_dim, hilbert_dim)
```

!!! tip
    [`state_index`](@ref SymBasis.Bases.state_index) binary-searches the (always sorted) state vector, so each lookup costs $\mathcal{O}(\log n)$ and needs no auxiliary storage. In a matrix-element loop this is dwarfed by [`representative`](@ref SymBasis.Bases.representative), but if you ever write a loop that is dominated by lookups rather than by symmetry operations, a precomputed `Dict(ba.states .=> eachindex(ba.states))` gives $\mathcal{O}(1)$ lookups in exchange for $\mathcal{O}(n)$ extra memory.

!!! note
    Just as in the [Bose-Hubbard chain example](@ref "Phase diagram of the Bose-Hubbard chain"), `h_manual` is Hermitian only up to floating-point round-off, since the normalization ratio `sqrt(Nₘ/Nₙ)` is not computed exactly symmetrically for the two directions of a matrix element. Symmetrize it explicitly before using it, e.g. `h_manual = (h_manual + h_manual') / 2`.

### A note on fermionic operators

Fermionic creation/annihilation operators anticommute across sites, so acting with them requires an extra Jordan-Wigner sign that is not needed for spins or bosons. This sign has to be computed by hand as part of the same recipe above, by counting the occupied sites between the two sites involved in a hopping term, e.g.:
```julia
temp_s = dec(sₙ, j) # annihilate at site j
anticomm_sign = cispi(count(temp_s, 1:(j-1), 1))  # occupied sites below j
anticomm_sign *= cispi(-count(temp_s, 1:(i-1), 1)) # occupied sites below i
temp_s = inc(temp_s, i) # create at site i

rep_s, rep_fac = representative(temp_s, ba)
# ... accumulate matrix_element * anticomm_sign * sqrt(Nₘ/Nₙ) * rep_fac as before
```
Counting over a contiguous range walks the digits once, so it is cheaper than
`sum(read(temp_s, x) for x in 1:(j-1))`, which recomputes the place value at every position
(see [State operations](@ref "State operations")).
For the complete derivation and a worked example, see the [Spinless-fermion t-V chain vs. the exact Bethe-Hulthén solution](@ref "Spinless-fermion t-V chain vs. the exact Bethe-Hulthén solution") and [Fermi-Hubbard chain vs. the exact Lieb-Wu solution](@ref "Fermi-Hubbard chain vs. the exact Lieb-Wu solution") examples.

## Building operators with OperatorAlgebra.jl

[OperatorAlgebra.jl](https://github.com/h-mnzlr/OperatorAlgebra.jl) is an optional package, not a dependency of SymBasis.jl, that lets you assemble operators more declaratively out of single-site matrices. Install it alongside SymBasis.jl:
```julia
julia> import Pkg; Pkg.add("OperatorAlgebra")
```
Once both packages are loaded with `using SymBasis, OperatorAlgebra`, OperatorAlgebra.jl's package extension for SymBasis.jl activates automatically — no further setup is required.

An `Op(mat, site)` represents a single-site operator; multiplying `Op`s on different sites builds an `OpChain`, and adding `Op`s or `OpChain`s builds an `OpSum`. OperatorAlgebra.jl ships spin-1/2 constants such as `PAULI_X`/`PAULI_Y`/`PAULI_Z`, `RAISE`/`LOWER`, and `OCC_PART`/`OCC_HOLE`. The same transverse-field Ising Hamiltonian built from scratch above can then be written as:
```@example ising
using OperatorAlgebra

H = sum(J * Op(PAULI_Z, i) * Op(PAULI_Z, mod1(i + 1, N)) for i in 1:N) +
    sum(h * Op(PAULI_X, i) for i in 1:N)

h_opalg = sparse(H, ba)
```

`sparse(H, ba)` uses the same `representative`-based projection shown in the from-scratch section internally, so it reproduces `h_manual` up to floating-point round-off:
```@example ising
using LinearAlgebra
norm(collect(h_manual) - collect(h_opalg))
```

Instead of forming the full sparse matrix, `apply!(H, v, ba)` applies the operator directly to a state vector `v` (expressed in the symmetry-reduced basis `ba`), overwriting `v` in place with the result — useful when you only need matrix-vector products, e.g. for iterative diagonalization or time evolution.

!!! note
    OperatorAlgebra.jl's predefined constants are spin-1/2 only. For bosons, build the local ladder-operator matrices yourself (e.g. `diagm(1 => sqrt.(1:n_max))` for annihilation on a truncated Fock space) and wrap them in `Op(mat, site)` — see the [Bose-Hubbard chain example](@ref "Phase diagram of the Bose-Hubbard chain") for the full construction.

!!! warning
    OperatorAlgebra.jl's SymBasis.jl extension does not yet support fermionic degrees of freedom (`SpinlessFermion`, `SpinfulFermion`). Internally, each `Op` is applied as a purely local matrix action (`read`/`write` at one site) with no Jordan-Wigner string, which is correct for bosons and spins but omits the anticommutation sign fermionic operators require (see [above](@ref "A note on fermionic operators")). Building fermionic operators with `Op`/`OpSum` will silently produce incorrect matrix elements rather than an error — use the from-scratch approach for fermionic systems.
