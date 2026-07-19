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

"""
    phase_perm_fermionic(
        p::NamedTuple,
        state::SymBasis.DigitBase.BaseInt{T,Ti,B}
    ) where {T,Ti,B}

Compute the fermionic sign (`1` or `-1`) that arises from applying the permutation `p.perm`
to the occupied sites of `state`, i.e. the parity of the permutation restricted to the
subset of sites where `state` has a nonzero digit.

`p` accepts any `NamedTuple` containing at least a `perm` field. When `p` also carries the
precomputed `invperm` field — as produced for cycles built by
[`SymBasis.SymGroups.sym`](@ref) for `Translational`/`SpatialReflection`/`Rotational`
symmetries applied to spinless fermions — that inverse permutation is used directly;
otherwise it is computed on the fly via [`SymBasis.Miscs.invperm`](@ref).

The sign itself is obtained by counting inversions of the occupied-site permutation with a
bitmask sweep over already-mapped positions (`count_ones` on a shifted mask), rather than
by materializing an intermediate list of mapped sites. Base 2 uses a dedicated fast path
that iterates set bits of `state.value` directly (`trailing_zeros`, clearing the lowest set
bit each step); other bases use a sequential digit-by-digit `divrem` pass.

# Arguments
- `p::NamedTuple`: A named tuple containing at least a `perm` field.
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state whose occupied sites
    define the permutation parity to compute.

# Returns
- `Int`: `1` for an even permutation of the occupied sites, `-1` for an odd one.
"""
function phase_perm_fermionic(
    p::NamedTuple,
    state::BaseInt{T,Ti,B}
) where {T,Ti,B}
    # Cycles built by `sym(...)` carry the precomputed inverse permutation; fall back to
    # computing it for user-built cycles. (`haskey` on a NamedTuple is compile-time.)
    inv_perm = haskey(p, :invperm) ? p.invperm : invperm(p.perm)
    return _phase_perm_fermionic(inv_perm, state)
end

# Parity of the permutation restricted to the occupied sites, counted as inversions via a
# bitmask of already-mapped positions — no intermediate vectors.
function _phase_perm_fermionic(
    inv_perm::AbstractVector{<:Integer},
    state::BaseInt{T,Ti,2}
) where {T,Ti}
    v = state.value
    seen = zero(T)
    n_inversions = 0
    while !iszero(v)
        site = trailing_zeros(v) + 1
        mapped_site = inv_perm[site]
        n_inversions += count_ones(seen >>> mapped_site)
        seen |= one(T) << (mapped_site - 1)
        v &= v - one(T)
    end

    return isodd(n_inversions) ? -1 : 1
end

function _phase_perm_fermionic(
    inv_perm::AbstractVector{<:Integer},
    state::BaseInt{T,Ti,B}
) where {T,Ti,B}
    BB = T(B)
    v = state.value
    seen = zero(T)
    n_inversions = 0
    site = 1
    while !iszero(v)
        if v % BB == one(T)
            mapped_site = inv_perm[site]
            n_inversions += count_ones(seen >>> mapped_site)
            seen |= one(T) << (mapped_site - 1)
        end
        v ÷= BB
        site += 1
    end

    return isodd(n_inversions) ? -1 : 1
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
