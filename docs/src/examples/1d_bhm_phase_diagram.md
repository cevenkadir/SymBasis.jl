# Phase diagram of the Bose-Hubbard chain

The Bose-Hubbard model is the paradigmatic lattice model for strongly-correlated bosons. On a one-dimensional chain with $N$ sites and periodic boundary conditions, it reads
```math
H = -t \sum_{i=1}^{N} \left( b_i^\dagger b_{i+1} + \mathrm{h.c.} \right) + \frac{U}{2} \sum_{i=1}^{N} \hat{n}_i(\hat{n}_i - 1) - \mu \sum_{i=1}^{N} \hat{n}_i\,,
```
where $b_i^\dagger$ ($b_i$) creates (annihilates) a boson on site $i$, $\hat{n}_i = b_i^\dagger b_i$ is the local number operator, $t$ is the hopping amplitude, $U$ is the on-site repulsion, and $\mu$ is the chemical potential. Competition between kinetic energy ($t$) and interaction energy ($U$) drives a quantum phase transition between a gapped **Mott insulator** at integer filling and a gapless **superfluid**. The phase boundary in the $(t/U, \mu/U)$ plane forms characteristic lobes, one for each integer occupation $n_0$.

In this example we map out the first Mott lobe ($n_0 = 1$) using two approaches: an analytic mean-field approximation and finite-size exact diagonalization (ED) using a particle-number-conserved basis built with SymBasis.jl.

## Boundaries from the third-order perturbation theory
Within the third-order strong-coupling expansion around the atomic limit ($t/U \to 0$)[^Freericks_1994], the upper and lower boundaries of the $n_0$-th Mott lobe are given by
```math
\mu_+/U = 1 - 2 (n_0 + 1) \tilde{t} + n_0^2 \tilde{t}^2 + n_0 (n_0 + 1) (n_0 + 2) \tilde{t}^3\,,
```
and
```math
\mu_-/U = 2 n_0 \tilde{t} - (n_0 + 1)^2 \tilde{t}^2 + n_0 (n_0 + 1) (n_0 - 1) \tilde{t}^3\,,
```
where $\tilde{t} = t/U$ is the dimensionless hopping strength. These expressions are obtained by computing the energy cost of adding or removing a particle from the Mott state, treating the hopping term as a perturbation.

```@example bhm
U = 1.0 # on-site interaction strength

function per_th_μₛ(n₀, t, U)
    tilde_t = t / U
    return begin
        1-2 * (n₀ + 1) * tilde_t + n₀^2 * tilde_t^2 + n₀ * (n₀ + 1) * (n₀ + 2) * tilde_t^3,
        2 * n₀ * tilde_t - (n₀ + 1)^2 * tilde_t^2 + n₀ * (n₀ + 1) * (n₀ - 1) * tilde_t^3
    end
end

pt_tₛ = range(0.0; stop=0.215, length=100)
pt_μₛ = per_th_μₛ.(1 |> Ref, pt_tₛ, U |> Ref)
pt_μ_plusₛ = pt_μₛ .|> first
pt_μ_minusₛ = pt_μₛ .|> last
```

## Boundaries from exact diagonalization

The ED estimate of the phase boundary is obtained from the finite-size excitation gap. The upper boundary of the $n_0 = 1$ Mott lobe is the energy cost of adding one particle to the $n_0 = 1$ ground state,
```math
\mu_+ = E_0(N, N+1) - E_0(N, N)\,,
```
and the lower boundary is the energy cost of removing one particle,
```math
\mu_- = E_0(N, N) - E_0(N, N-1)\,,
```
where $E_0(N, n)$ denotes the ground-state energy of the system with $N$ sites and $n$ particles. As the system approaches the superfluid phase these gaps close and the lobe shrinks. We compute these quantities for several system sizes to observe the finite-size convergence toward the thermodynamic limit.

```@example bhm
Nₛ = 4:6; # total number of sites for which to compute the phase diagram
tₛ = 0.0:0.1:0.3; # hopping strength range for which to compute the phase diagram
```

### Defining the DoF-object and particle-number-conserved basis

For bosons with a local Hilbert space of dimension $n_\mathrm{max} + 1$ (occupation numbers $0, 1, \ldots, n_\mathrm{max}$), SymBasis provides the predefined [`Boson`](@ref SymBasis.DoFObjects.Boson) DoF-object. We construct the basis by combining three symmetry groups: particle-number conservation [`TotalBosonicNumber`](@ref SymBasis.SymGroups.TotalBosonicNumber) to select states with a fixed particle number $n$, translational symmetry [`Translational`](@ref SymBasis.SymGroups.Translational) to reduce the Hilbert space by fixing the quantum momentum number $k$, and spatial reflection symmetry [`SpatialReflection`](@ref SymBasis.SymGroups.SpatialReflection) to include spatial parity sectors with the parity numbers $p = \pm 1$. These symmetries are composed to form the combined symmetry group, and we build the symmetry-resolved basis and assemble the Hamiltonian in each sector $(N, n, k, p)$ for $n \in \{N-1, N, N+1\}$, sweeping over both system sizes and hopping values.

```@example bhm
using SymBasis
using LinearAlgebra, SparseArrays, Arpack

# initialize array to store ground state energies for each (t, N, n_particles)
evalₛ = fill(Inf, length(tₛ), length(Nₛ), 3)

# parameters for DoF object
n_max = 3  # maximum occupation number per site

# loop over the parameter space and compute ground state energies
for (id_t, t) in enumerate(tₛ)
    for (id_N, N) in enumerate(Nₛ)
        for (id_n, n_particles) in enumerate((N-1):(N+1))
            
            # consider all translation and parity quantum numbers
            k_values = (N % 2 == 0) ? [0, Int(N // 2)] : [0]
            p_values = [-1, 1]
            
            for k in k_values, p in p_values
                # construct the symmetry-resolved basis
                dofo = dof_object(Boson(n_max))
                pn_sg = sym(TotalBosonicNumber(n_particles, N), dofo)
                T_sg = sym(Translational(k, mod1.((1:N) .+ 1, N)), dofo)
                P_sg = sym(SpatialReflection(p, mod1.(N .- (1:N) .+ 1, N)), dofo)
                csg = pn_sg ∘ T_sg ∘ P_sg
                ba = basis(dofo, N, csg)
                
                hilbert_dim = length(ba.states)
                
                # initialize vectors to store the row indices, column indices, and values
                I_vec = Int64[]
                J_vec = Int64[]
                V_vec = ComplexF64[]
                
                b = Dict(ba.states .=> 1:hilbert_dim)
                for sₙ in ba.states
                    n = b[sₙ]
                    Nₙ = ba.norms[n]
                    
                    # diagonal interaction term
                    for xᵢ in 1:N
                        n_xᵢ = read(sₙ, xᵢ)
                        if n_xᵢ > 0
                            push!(I_vec, n)
                            push!(J_vec, n)
                            push!(V_vec, 0.5 * U * n_xᵢ * (n_xᵢ - 1))
                        end
                    end
                    
                    # off-diagonal hopping terms
                    for xᵢ in 1:N
                        xᵢ₊₁ = mod1(xᵢ + 1, N)
                        
                        # annihilate at xᵢ₊₁, create at xᵢ
                        if read(sₙ, xᵢ₊₁) > 0
                            temp_s₁ = dec(sₙ, xᵢ₊₁)
                            temp_s₁ = inc(temp_s₁, xᵢ)
                            rep_s₁, rep_fac₁ = representative(temp_s₁, ba)
                            
                            if haskey(b, rep_s₁)
                                m = b[rep_s₁]
                                Nₘ = ba.norms[m]
                                all_fac = -t * sqrt(Nₘ / Nₙ) * rep_fac₁
                                push!(I_vec, m)
                                push!(J_vec, n)
                                push!(V_vec, all_fac)
                            end
                        end
                        
                        # annihilate at xᵢ, create at xᵢ₊₁
                        if read(sₙ, xᵢ) > 0
                            temp_s₂ = dec(sₙ, xᵢ)
                            temp_s₂ = inc(temp_s₂, xᵢ₊₁)
                            rep_s₂, rep_fac₂ = representative(temp_s₂, ba)
                            
                            if haskey(b, rep_s₂)
                                m = b[rep_s₂]
                                Nₘ = ba.norms[m]
                                all_fac = -t * sqrt(Nₘ / Nₙ) * rep_fac₂
                                push!(I_vec, m)
                                push!(J_vec, n)
                                push!(V_vec, all_fac)
                            end
                        end
                    end
                end
                
                # construct and symmetrize the sparse Hamiltonian matrix
                h = sparse(I_vec, J_vec, V_vec, hilbert_dim, hilbert_dim)
                h .+= h'
                h ./= 2
                
                # compute ground state energy
                gs_energy = begin
                    try
                        eigs(h, nev=1, which=:SR) |> first |> first |> real
                    catch
                        eigvals(h |> collect) |> first |> real
                    end
                end
                
                # store the minimum ground state energy across all symmetry sectors
                if gs_energy < evalₛ[id_t, id_N, id_n]
                    evalₛ[id_t, id_N, id_n] = gs_energy
                end
            end
        end
    end
end
```


### Extracting the phase boundaries

The upper and lower chemical-potential boundaries of the first Mott lobe are obtained from the ground-state energies in the three sectors $n \in \{N-1, N, N+1\}$:
```@example bhm
ed_μ_plusₛ = (evalₛ[:, :, 3] .- evalₛ[:, :, 2]) ./ U
ed_μ_minusₛ = (evalₛ[:, :, 2] .- evalₛ[:, :, 1]) ./ U
```

## Plotting the phase diagram
```@example bhm
using CairoMakie

CairoMakie.activate!(type="svg") # hide
with_theme(theme_latexfonts()) do # hide
fig = Figure()
ax = Axis(fig[1, 1]; xlabel=L"t/U", ylabel=L"\mu/U")
for (id_N, N) in enumerate(Nₛ)
    scatterlines!(ax, tₛ ./ U, ed_μ_plusₛ[:, id_N]; color=Cycled(id_N), label=L"N=%$(N)")
    scatterlines!(ax, tₛ ./ U, ed_μ_minusₛ[:, id_N]; color=Cycled(id_N))
end

lines!(ax, pt_tₛ ./ U, pt_μ_plusₛ; color=:black, linestyle=:dash, label=L"\text{3rd order perturbation theory}")
lines!(ax, pt_tₛ ./ U, pt_μ_minusₛ; color=:black, linestyle=:dash)

axislegend(ax; position=:rt, merge=true)
fig
end # hide
```

[^Freericks_1994]: J. K. Freericks and H. Monien, *Phase diagram of the Bose-Hubbard Model*, [Europhys. Lett. **26**, 545 (1994)](https://doi.org/10.1209/0295-5075/26/7/012).