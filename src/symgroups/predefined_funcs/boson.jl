using SymBasis.Miscs: combos_boson_sum

"""
    TotalBosonicNumber{T_b<:Integer,T_N<:Integer} <: SymBasis.SymGroups.AbstractSymSpec

A concrete subtype of [`SymBasis.SymGroups.AbstractSymSpec`](@ref) representing a bosonic
particle number conservation specification. The type parameter `T_b` represents the target
total particle number quantum number, while `T_N` represents the number of sites.

# Fields
- `n_particles::T_b`: The target total particle number quantum number.
- `N::T_N`: The number of sites.

# Constructor Arguments
- `n_particles::T_b`: The target total particle number quantum number.
- `N::T_N`: The number of sites.

# Returns
- [`SymBasis.SymGroups.TotalBosonicNumber`](@ref): An instance of
    `TotalBosonicNumber` with the number of particles converted to an
    integer.
"""
struct TotalBosonicNumber{T_b<:Integer,T_N<:Integer} <: AbstractSymSpec
    n_particles::T_b
    N::T_N

    function TotalBosonicNumber(
        n_particles::T_b, N::T_N
    ) where {T_b,T_N}
        @assert n_particles >= 0 "Number of particles must be non-negative."

        return new{T_b,T_N}(n_particles, N)
    end
end

"""
    sym(
        ss::TotalBosonicNumber{T_b,T_N},
        dofo::DoFObject{B,T_b,T,Ti}
    ) where {B,T_b,T,Ti,T_N}

Create a symmetry group for particle conservation for the given bosonic DoF-object `dofo`,
and target total particle number specification `ss`.

A given total particle number is usually reachable through several digit-count signatures
(e.g. `N_b = 3` on 5 sites with `n_max = 2` admits both `(N0, N1, N2) = (2, 3, 0)` and
`(3, 1, 1)`). Those are folded into a single cycle carrying a
[`SymBasis.SymGroups.WeightedCounts`](@ref), so `length(sg.cycles)` does not track the number
of signatures; with a single signature the plain `N0`, …, `N(B-1)` cycle is kept.

# Arguments
- `ss::TotalBosonicNumber{T_b,T_N}`: The particle number conservation specification,
    containing the target total particle number quantum number and the number of sites.
- `dofo::DoFObject{B,T_b,T,Ti}`: The bosonic DoF-object for which to create the symmetry
    group.

# Returns
- [`SymBasis.SymGroups.SymGroup`](@ref): The symmetry group for particle conservation.
"""
function sym(
    ss::TotalBosonicNumber{T_b,T_N},
    dofo::DoFObject{B,T_b,T,Ti}
) where {B,T_b,T,Ti,T_N}
    @assert dofo.type == :Boson

    all_boson_sumₛ = combos_boson_sum(dofo.ldof[end], ss.n_particles, ss.N)

    # Digit `d` carries `d` bosons, so the sector is one weighted digit-count constraint and
    # all its signatures collapse into a single cycle.
    cyclesₛ = _counts_cycles(all_boson_sumₛ, (collect(0:(B-1)),), Val(B), ss.N)

    N_sym = SymGroup(
        dofo,
        cyclesₛ,
        check_Nₛ,
        apply_Nₛ,
        phase_unity,
        ones(length(cyclesₛ)),
        ss.N
    )

    return N_sym
end

@deprecate ParticleNumberConservation TotalBosonicNumber
