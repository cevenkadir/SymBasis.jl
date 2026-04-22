"""
    TotalSpinlessFermionicNumber{T_b<:Integer,T_N<:Integer}
        <: SymBasis.SymGroups.AbstractSymSpec

A concrete subtype of [`SymBasis.SymGroups.AbstractSymSpec`](@ref) representing a total
spinless fermionic number symmetry specification. The type parameter `T_b` represents the
target total number of fermions, while `T_N` represents the total number of DoF-objects in
the system.

This symmetry selects the subspace with fixed total fermion number, i.e. states whose
binary occupations sum to `n_particles`.

# Fields
- `n_particles::T_b`: The target total number of spinless fermions for the symmetry
    specification.
- `N::T_N`: The total number of DoF-objects in the system.

# Constructor Arguments
- `n_particles::T_b`: The target total number of spinless fermions for the symmetry
    specification.
- `N::T_N`: The total number of DoF-objects in the system.

# Returns
- `TotalSpinlessFermionicNumber{T_b,T_N}`: An instance of `TotalSpinlessFermionicNumber`
    representing the specified total spinless fermionic number symmetry.
"""
struct TotalSpinlessFermionicNumber{T_b<:Integer,T_N<:Integer} <: AbstractSymSpec
    n_particles::T_b
    N::T_N

    function TotalSpinlessFermionicNumber(
        n_particles::T_b, N::T_N
    ) where {T_b,T_N}
        @assert n_particles >= 0 "Number of particles must be non-negative."
        @assert n_particles <= N "Number of particles cannot exceed the total number of DoF-objects."

        return new{T_b,T_N}(n_particles, N)
    end
end

function phase_perm_fermionic(
    p::@NamedTuple{perm::Tperm},
    state::BaseInt{T,Ti,B}
) where {
    T,Ti,B,Tp,Tperm<:Union{AbstractVector{<:Ti},BitPermutation{Tp,<:PermutationBackend{Tp}}}
}
    inv_perm = invperm(p.perm)
    mapped_occupied_sites = Int[]
    is_odd_parity = false

    for site in eachindex(inv_perm)
        if read(state, Ti(site)) == 1
            mapped_site = inv_perm[site]
            for prev_site in mapped_occupied_sites
                is_odd_parity ⊻= (prev_site > mapped_site)
            end
            push!(mapped_occupied_sites, mapped_site)
        end
    end

    return is_odd_parity ? -1 : 1
end

"""
    sym(
        ss::SymBasis.SymGroups.TotalSpinlessFermionicNumber{T_b,T_N},
        dofo::SymBasis.DoFObjects.DoFObject{B,T_b,T,Ti}
    ) where {B,T_b,T,Ti,T_N}

Create a total spinless fermionic number symmetry group for the given spinless fermionic
DoF-object `dofo`, and target total spinless fermionic number specification `ss`. The
function generates all combinations of occupation numbers that sum to the target number of
particles.

# Arguments
- `ss::`[`SymBasis.SymGroups.TotalSpinlessFermionicNumber`](@ref)`{T_b,T_N}`: The total
    spinless fermionic number symmetry specification.
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_b,T,Ti}`: The DoF-object
    representing spinless fermions.

# Returns
- [`SymBasis.SymGroups.SymGroup`](@ref): The total spinless fermionic number symmetry
    group.
"""
function sym(
    ss::TotalSpinlessFermionicNumber{T_b,T_N},
    dofo::DoFObject{B,T_b,T,Ti}
) where {B,T_b,T,Ti,T_N}
    @assert dofo.type == :SpinlessFermion

    all_spinless_fermion_sumₛ = combos_boson_sum(dofo.ldof[end], ss.n_particles, ss.N)

    N_sym = SymGroup(
        dofo,
        all_spinless_fermion_sumₛ,
        check_Nₛ,
        apply_Nₛ,
        phase_unity,
        ones(length(all_spinless_fermion_sumₛ)),
        ss.N
    )

    return N_sym
end
