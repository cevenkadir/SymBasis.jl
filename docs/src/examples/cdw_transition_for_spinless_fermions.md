```md
# Finite-size precursor of the CDW transition in the 1D spinless-fermion \(t\)-\(V\) chain at half filling

The one-dimensional spinless-fermion \(t\)-\(V\) model is a standard interacting lattice-fermion system with Hamiltonian
```math
\hat{H}
=
-J \sum_{i=1}^{N}
\left(
\hat{c}_{i}^{\dagger}\hat{c}_{i+1}
+
\hat{c}_{i+1}^{\dagger}\hat{c}_{i}
\right)
-\mu \sum_{i=1}^{N} \hat{n}_i
+U \sum_{i=1}^{N} \hat{n}_i \hat{n}_{i+1},
```
with periodic boundary conditions, \(\hat{c}_{N+1}\equiv \hat{c}_1\), and \(\hat{n}_i=\hat{c}_i^\dagger \hat{c}_i\).

At half filling, this model is exactly related to the spin-\(\tfrac12\) XXZ chain by the Jordan–Wigner transformation and exhibits a transition between a gapless metallic phase and a charge-density-wave (CDW) phase at \(U/J=2\) in the thermodynamic limit. On a finite ring, the transition is rounded, but its precursor can already be seen in the low-energy spectrum, the excitation gap, and the CDW structure factor.

In this example, we resolve:
- total particle number,
- translational symmetry,
- spatial reflection symmetry.

Because translation and reflection commute only in special momentum sectors on a ring, we focus on \(k=0\) and \(k=\pi\) for even system size.

## Defining the spinless-fermion DoF-object

We work with spinless fermions on a periodic chain of length \(N=8\) at half filling, i.e. with \(N_f=4\) particles.

```@example tv_chain
using SymBasis.DigitBase
using SymBasis.DoFObjects
using SymBasis.SymGroups

N = 8
n_particles = 4

J = 0.5
μ = 0.4

dofo = dof_object(SpinlessFermion())
```

## Constructing the symmetry groups

We now define symmetry groups for:
- total spinless-fermion number conservation,
- lattice translation,
- spatial reflection.

```@example tv_chain
pn_sg = sym(TotalSpinlessFermionicNumber(n_particles, N), dofo)
T_sg = sym(Translational(0, mod1.((1:N) .+ 1, N)), dofo) # one-site translation
P_sg = sym(SpatialReflection(+1, mod1.(N .- (1:N) .+ 1, N)), dofo) # site reflection
```

These can be composed into a combined symmetry group:
```@example tv_chain
csg = pn_sg ∘ T_sg ∘ P_sg
```

The translational and reflection symmetry groups act on the fermionic basis with the appropriate fermionic phase factors determined by the DoF-object.

## Constructing the basis

```@example tv_chain
using SymBasis.Bases

ba = basis(dofo, N, csg)
hilbert_dim = length(ba.states)
hilbert_dim
```

This basis contains only states in the fixed particle-number sector with
- \(N_f=4\),
- momentum \(k=0\),
- reflection parity \(p=+1\).

## Building the Hamiltonian in a symmetry-resolved basis

We now assemble the Hamiltonian matrix in the symmetry-resolved basis. The diagonal terms come from the chemical potential and nearest-neighbor interaction, while the off-diagonal terms come from fermionic hopping.

```@example tv_chain
using LinearAlgebra
using SparseArrays

function sector_hamiltonian(dofo, N, n_particles, k, p, J, μ, U)
    pn_sg = sym(TotalSpinlessFermionicNumber(n_particles, N), dofo)
    T_sg = sym(Translational(k, mod1.((1:N) .+ 1, N)), dofo)
    P_sg = sym(SpatialReflection(p, mod1.(N .- (1:N) .+ 1, N)), dofo)

    csg = pn_sg ∘ T_sg ∘ P_sg
    ba = basis(dofo, N, csg)

    hilbert_dim = length(ba.states)
    b = Dict(ba.states .=> 1:hilbert_dim) # representative state -> basis index

    I_vec = Int64[]
    J_vec = Int64[]
    V_vec = ComplexF64[]

    for sₙ in ba.states
        n = b[sₙ]
        Nₙ = ba.norms[n] # orbit normalization factor of the ket state

        # diagonal chemical potential term
        for xᵢ in 1:N
            n_xᵢ = DigitBase.read(sₙ, xᵢ)

            push!(I_vec, n)
            push!(J_vec, n)
            push!(V_vec, -μ * n_xᵢ)
        end

        # diagonal interaction term
        for xᵢ in 1:N
            n_xᵢ = DigitBase.read(sₙ, xᵢ)
            xⱼ = mod1(xᵢ + 1, N) # nearest neighbor with periodic wrapping
            n_xⱼ = DigitBase.read(sₙ, xⱼ)

            push!(I_vec, n)
            push!(J_vec, n)
            push!(V_vec, U * n_xᵢ * n_xⱼ)
        end

        # off-diagonal hopping term
        for xᵢ in 1:N
            xᵢ₊₁ = mod1(xᵢ + 1, N)

            # annihilate at xᵢ₊₁, create at xᵢ
            if DigitBase.read(sₙ, xᵢ₊₁) == 1 && DigitBase.read(sₙ, xᵢ) == 0
                temp_s₁ = dec(sₙ, xᵢ₊₁)
                anticomm_sign = cispi(sum(DigitBase.read(temp_s₁, x) for x in 1:(xᵢ₊₁ - 1); init=0))
                anticomm_sign *= cispi(-sum(DigitBase.read(temp_s₁, x) for x in 1:(xᵢ - 1); init=0))
                temp_s₁ = inc(temp_s₁, xᵢ)

                rep_s₁, rep_fac₁ = representative(temp_s₁, ba) # map to sector representative

                if haskey(b, rep_s₁)
                    m = b[rep_s₁]
                    Nₘ = ba.norms[m]

                    all_fac = -J * sqrt(Nₘ / Nₙ) * rep_fac₁
                    all_fac *= anticomm_sign # Jordan–Wigner sign from fermion exchange

                    push!(I_vec, m)
                    push!(J_vec, n)
                    push!(V_vec, all_fac)
                end
            end

            # annihilate at xᵢ, create at xᵢ₊₁
            if DigitBase.read(sₙ, xᵢ) == 1 && DigitBase.read(sₙ, xᵢ₊₁) == 0
                temp_s₂ = dec(sₙ, xᵢ)
                anticomm_sign = cispi(sum(DigitBase.read(temp_s₂, x) for x in 1:(xᵢ - 1); init=0))
                anticomm_sign *= cispi(-sum(DigitBase.read(temp_s₂, x) for x in 1:(xᵢ₊₁ - 1); init=0))
                temp_s₂ = inc(temp_s₂, xᵢ₊₁)

                rep_s₂, rep_fac₂ = representative(temp_s₂, ba)

                if haskey(b, rep_s₂)
                    m = b[rep_s₂]
                    Nₘ = ba.norms[m]

                    all_fac = -J * sqrt(Nₘ / Nₙ) * rep_fac₂
                    all_fac *= anticomm_sign

                    push!(I_vec, m)
                    push!(J_vec, n)
                    push!(V_vec, all_fac)
                end
            end
        end
    end

    h = sparse(I_vec, J_vec, V_vec, hilbert_dim, hilbert_dim)
    h .+= h'
    h ./= 2 # enforce Hermiticity at the matrix level

    return ba, csg, Matrix(h)
end
```

As a first check, let us construct and diagonalize the Hamiltonian in the \((k,p)=(0,+1)\) sector for a single value of \(U\):

```@example tv_chain
U = 0.25

ba, csg, h = sector_hamiltonian(dofo, N, n_particles, 0, +1, J, μ, U)
eigvals(h) |> sort
```

## Comparing symmetry sectors as a function of \(U/J\)

To visualize the finite-size precursor of the CDW transition, we compute the lowest energy in the symmetry sectors
- \((k,p)=(0,+1)\),
- \((k,p)=(0,-1)\),
- \((k,p)=(\pi,+1)\),
- \((k,p)=(\pi,-1)\),

as a function of the interaction strength \(U\).

For even system size \(N\), we use the integer momentum labels \(k=0\) and \(k=N/2\), corresponding to momenta \(0\) and \(\pi\), respectively.

```@example tv_chain
U_vals = range(0.0, 2.0; length=41)
sector_labels = [(0, +1), (0, -1), (N ÷ 2, +1), (N ÷ 2, -1)]

sector_energies = Dict(label => Float64[] for label in sector_labels)

for U in U_vals
    for label in sector_labels
        k, p = label
        _, _, h = sector_hamiltonian(dofo, N, n_particles, k, p, J, μ, U)
        evals = eigvals(h) |> real |> sort
        push!(sector_energies[label], evals[1]) # store the lowest level in each sector
    end
end
```

## Plotting the lowest energies in different symmetry sectors

```@example tv_chain
using CairoMakie
CairoMakie.activate!(type = "svg") # hide

with_theme(theme_latexfonts()) do # hide
fig = Figure()
ax = Axis(
    fig[1, 1];
    xlabel=L"U/J",
    ylabel="Lowest energy in sector",
    title="Lowest energies in symmetry sectors"
)

lines!(ax, U_vals ./ J, sector_energies[(0, +1)], label="k = 0, p = +1")
lines!(ax, U_vals ./ J, sector_energies[(0, -1)], label="k = 0, p = -1")
lines!(ax, U_vals ./ J, sector_energies[(N ÷ 2, +1)], label="k = π, p = +1")
lines!(ax, U_vals ./ J, sector_energies[(N ÷ 2, -1)], label="k = π, p = -1")
axislegend(ax; position=:rb)
vlines!(ax, [2.0], color=:black, linestyle=:dash) # thermodynamic critical value
fig
end # hide
```

This plot shows how the competition between low-energy symmetry sectors changes as the interaction approaches the CDW regime.

## Building the Hamiltonian in the full fixed-particle-number sector

To compute the many-body gap and the CDW structure factor, it is convenient to work in the full fixed-particle-number sector without additionally resolving translation and reflection.

```@example tv_chain
function particle_number_hamiltonian(dofo, N, n_particles, J, μ, U)
    pn_sg = sym(TotalSpinlessFermionicNumber(n_particles, N), dofo)
    ba = basis(dofo, N, pn_sg)

    hilbert_dim = length(ba.states)
    b = Dict(ba.states .=> 1:hilbert_dim)

    I_vec = Int64[]
    J_vec = Int64[]
    V_vec = ComplexF64[]

    for sₙ in ba.states
        n = b[sₙ]

        # diagonal chemical potential term
        for xᵢ in 1:N
            n_xᵢ = DigitBase.read(sₙ, xᵢ)

            push!(I_vec, n)
            push!(J_vec, n)
            push!(V_vec, -μ * n_xᵢ)
        end

        # diagonal interaction term
        for xᵢ in 1:N
            n_xᵢ = DigitBase.read(sₙ, xᵢ)
            xⱼ = mod1(xᵢ + 1, N)
            n_xⱼ = DigitBase.read(sₙ, xⱼ)

            push!(I_vec, n)
            push!(J_vec, n)
            push!(V_vec, U * n_xᵢ * n_xⱼ)
        end

        # off-diagonal hopping term
        for xᵢ in 1:N
            xᵢ₊₁ = mod1(xᵢ + 1, N)

            # annihilate at xᵢ₊₁, create at xᵢ
            if DigitBase.read(sₙ, xᵢ₊₁) == 1 && DigitBase.read(sₙ, xᵢ) == 0
                temp_s₁ = dec(sₙ, xᵢ₊₁)
                anticomm_sign = cispi(sum(DigitBase.read(temp_s₁, x) for x in 1:(xᵢ₊₁ - 1); init=0))
                anticomm_sign *= cispi(-sum(DigitBase.read(temp_s₁, x) for x in 1:(xᵢ - 1); init=0))
                temp_s₁ = inc(temp_s₁, xᵢ)

                if haskey(b, temp_s₁)
                    m = b[temp_s₁]
                    all_fac = -J * anticomm_sign

                    push!(I_vec, m)
                    push!(J_vec, n)
                    push!(V_vec, all_fac)
                end
            end

            # annihilate at xᵢ, create at xᵢ₊₁
            if DigitBase.read(sₙ, xᵢ) == 1 && DigitBase.read(sₙ, xᵢ₊₁) == 0
                temp_s₂ = dec(sₙ, xᵢ)
                anticomm_sign = cispi(sum(DigitBase.read(temp_s₂, x) for x in 1:(xᵢ - 1); init=0))
                anticomm_sign *= cispi(-sum(DigitBase.read(temp_s₂, x) for x in 1:(xᵢ₊₁ - 1); init=0))
                temp_s₂ = inc(temp_s₂, xᵢ₊₁)

                if haskey(b, temp_s₂)
                    m = b[temp_s₂]
                    all_fac = -J * anticomm_sign

                    push!(I_vec, m)
                    push!(J_vec, n)
                    push!(V_vec, all_fac)
                end
            end
        end
    end

    h = sparse(I_vec, J_vec, V_vec, hilbert_dim, hilbert_dim)
    h .+= h'
    h ./= 2

    return ba, Matrix(h)
end
```

## Computing the gap and the CDW structure factor

The CDW structure factor is defined as
```math
S(\pi)
=
\frac{1}{N}
\sum_{i,j}
(-1)^{i-j}
\left(
\langle n_i n_j \rangle
-
\langle n_i \rangle \langle n_j \rangle
\right).
```

```@example tv_chain
function cdw_structure_factor(ba, ψ, N)
    occ_exp = zeros(Float64, N)

    for (idx, s) in enumerate(ba.states)
        prob = abs2(ψ[idx]) # probability weight of basis state s
        for i in 1:N
            occ_exp[i] += prob * DigitBase.read(s, i)
        end
    end

    Sπ = 0.0
    for i in 1:N, j in 1:N
        nij_exp = 0.0
        for (idx, s) in enumerate(ba.states)
            prob = abs2(ψ[idx])
            nij_exp += prob * DigitBase.read(s, i) * DigitBase.read(s, j)
        end
        Sπ += (-1)^(i - j) * (nij_exp - occ_exp[i] * occ_exp[j])
    end

    return Sπ / N
end
```

We now sweep \(U\), diagonalize the Hamiltonian in the fixed-particle-number sector, and extract:
- the many-body gap \(E_1-E_0\),
- the CDW structure factor \(S(\pi)\) of the ground state.

```@example tv_chain
gaps = Float64[]
Sπ_vals = Float64[]

for U in U_vals
    ba_pn, h_pn = particle_number_hamiltonian(dofo, N, n_particles, J, μ, U)
    egn = eigen(Hermitian(h_pn))

    push!(gaps, egn.values[2] - egn.values[1]) # first excitation gap
    push!(Sπ_vals, cdw_structure_factor(ba_pn, egn.vectors[:, 1], N)) # ground-state S(π)
end
```

## Plotting the many-body gap

```@example tv_chain
with_theme(theme_latexfonts()) do # hide
fig = Figure()
ax = Axis(
    fig[1, 1];
    xlabel=L"U/J",
    ylabel=L"E_1 - E_0",
    title="Many-body gap at half filling"
)

lines!(ax, U_vals ./ J, gaps)
vlines!(ax, [2.0], color=:black, linestyle=:dash)
fig
end # hide
```

Although every finite system is gapped, the behavior of the lowest excitation gap changes as the system crosses over into the CDW regime.

## Plotting the CDW structure factor

```@example tv_chain
with_theme(theme_latexfonts()) do # hide
fig = Figure()
ax = Axis(
    fig[1, 1];
    xlabel=L"U/J",
    ylabel=L"S(\pi)",
    title="CDW structure factor at half filling"
)

lines!(ax, U_vals ./ J, Sπ_vals)
vlines!(ax, [2.0], color=:black, linestyle=:dash)
fig
end # hide
```

As \(U/J\) increases, the CDW structure factor grows, signaling the increasing importance of staggered density correlations. In the strong-coupling regime, the low-energy physics is increasingly dominated by the two CDW-like configurations
```math
\vert 10101010 \rangle
\quad\text{and}\quad
\vert 01010101 \rangle.
```

## Discussion

This example illustrates three useful finite-size diagnostics of the CDW transition:

- **Lowest energies in different symmetry sectors** show how the low-energy states reorganize as a function of interaction strength.
- **The many-body gap** tracks the evolution of the lowest excitation energy.
- **The CDW structure factor \(S(\pi)\)** directly probes staggered density correlations.

In the thermodynamic limit, the half-filled \(t\)-\(V\) chain undergoes a transition at
```math
\frac{U}{J}=2.
```
The exact diagonalization calculations above do not reproduce the singular thermodynamic transition directly, but they clearly show its finite-size precursor in a symmetry-resolved setting.

[^1]: For the exact solution and its relation to the XXZ chain, see for example M. Takahashi, *Thermodynamics of One-Dimensional Solvable Models* (Cambridge University Press, 1999).
```