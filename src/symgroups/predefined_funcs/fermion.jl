using SymBasis.Miscs: combos_dof_sum_weighted

# For spinless fermions
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
    if haskey(p, :parity)
        return _phase_perm_fermionic(inv_perm, p.parity, state)
    end
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
    _phase_perm_fermionic(
        inv_perm::AbstractVector{<:Integer},
        parity::NTuple{B,Bool},
        state::SymBasis.DigitBase.BaseInt{T,Ti,B}
    ) where {T,Ti,B}

Parity of the permutation restricted to *occupied* digits, generalized to a multi-particle
local Hilbert space (e.g. `SpinfulFermion`, where a single digit can encode `0`, `1`, or more
fermions). A digit counts as "occupied" for sign purposes iff `parity[digit+1]` is `true`,
i.e. the digit's own fermion number is odd — a digit holding an even number of fermions (a
doubly-occupied site, say) behaves like a boson under exchange and never contributes a sign,
consistent with the ascending-spin-projection intra-site operator ordering used to build the
`SpinfulFermion` DoF-object's local Hilbert space.
"""
function _phase_perm_fermionic(
    inv_perm::AbstractVector{<:Integer},
    parity::NTuple{B,Bool},
    state::BaseInt{T,Ti,B}
) where {T,Ti,B}
    BB = T(B)
    v = state.value
    seen = zero(T)
    n_inversions = 0
    site = 1
    while !iszero(v)
        digit = Int(v % BB)
        v ÷= BB
        if parity[digit+1]
            mapped_site = inv_perm[site]
            n_inversions += count_ones(seen >>> mapped_site)
            seen |= one(T) << (mapped_site - 1)
        end
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

# For spinful fermions
"""
    TotalSpinfulFermionicNumber{T_b<:Integer,T_N<:Integer}
        <: SymBasis.SymGroups.AbstractSymSpec

A concrete subtype of [`SymBasis.SymGroups.AbstractSymSpec`](@ref) representing a
spin-resolved fermionic number symmetry specification for a spin-1/2 `SpinfulFermion`
DoF-object (exactly 2 distinct spin projections). Selects the subspace with fixed
spin-up count `n_up` and spin-down count `n_down` separately.

# Fields
- `n_up::T_b`: The target number of spin-up fermions.
- `n_down::T_b`: The target number of spin-down fermions.
- `N::T_N`: The total number of DoF-objects (sites) in the system.
"""
struct TotalSpinfulFermionicNumber{T_b<:Integer,T_N<:Integer} <: AbstractSymSpec
    n_up::T_b
    n_down::T_b
    N::T_N

    function TotalSpinfulFermionicNumber(
        n_up::T_b, n_down::T_b, N::T_N
    ) where {T_b,T_N}
        @assert n_up >= 0 "Number of spin-up particles must be non-negative."
        @assert n_down >= 0 "Number of spin-down particles must be non-negative."
        @assert n_up + n_down <= N "Total number of particles cannot exceed the total number of DoF-objects."

        return new{T_b,T_N}(n_up, n_down, N)
    end
end

"""
    sym(
        ss::SymBasis.SymGroups.TotalSpinfulFermionicNumber{T_b,T_N},
        dofo::SymBasis.DoFObjects.DoFObject{B,T_ldof,T,Ti}
    ) where {B,T_ldof,T,Ti,T_b,T_N}

Create a spin-resolved fermionic number symmetry group for the given spin-1/2 spinful
fermionic DoF-object `dofo`, fixing `N_up = ss.n_up` and `N_down = ss.n_down`
independently.
"""
function sym(
    ss::TotalSpinfulFermionicNumber{T_b,T_N},
    dofo::DoFObject{B,T_ldof,T,Ti}
) where {B,T_ldof,T,Ti,T_b,T_N}
    @assert dofo.type == :SpinfulFermion

    all_ms = sort(unique(vcat(collect.(dofo.ldof)...)))
    @assert length(all_ms) == 2 (
        "TotalSpinfulFermionicNumber requires a spin-1/2 SpinfulFermion DoF-object " *
        "(exactly 2 distinct spin projections), got $(length(all_ms))."
    )
    m_down, m_up = all_ms

    up_weights = [count(==(m_up), l) for l in dofo.ldof]
    down_weights = [count(==(m_down), l) for l in dofo.ldof]

    cyclesₛ = combos_dof_sum_weighted(
        (up_weights, down_weights), (ss.n_up, ss.n_down), ss.N
    )

    Nud_sym = SymGroup(
        dofo,
        cyclesₛ,
        check_Nₛ,
        apply_Nₛ,
        phase_unity,
        ones(length(cyclesₛ)),
        ss.N
    )

    return Nud_sym
end

"""
    apply_spinful_fermion_relabel(
        p::NamedTuple,
        state::SymBasis.DigitBase.BaseInt{T,Ti,B}
    ) where {T,Ti,B}

Apply a per-digit relabeling to every site of `state`. `p` must carry a `sites` field (the
site positions to visit) and a `relabel` field (`relabel[d+1]` gives the new digit for old
digit `d`). Used by [`FermionicSpinInversion`](@ref) to implement the simultaneous
spin-up/spin-down exchange at every site (a relabeling of each site's own local digit, as
opposed to [`apply_perm`](@ref)/[`apply_perm_fermionic`](@ref), which permute *sites*).

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state after relabeling every digit.
"""
function apply_spinful_fermion_relabel(
    p::NamedTuple,
    state::BaseInt{T,Ti,B}
) where {T,Ti,B}
    new_state = state
    for x in p.sites
        d = read(new_state, x)
        new_state = write(new_state, x, p.relabel[d+1])
    end
    return new_state
end

"""
    phase_spinful_fermion_relabel(
        p::NamedTuple,
        state::SymBasis.DigitBase.BaseInt{T,Ti,B}
    ) where {T,Ti,B}

Compute the fermionic sign of relabeling every site of `state` per `p.relabel` (see
[`apply_spinful_fermion_relabel`](@ref)). `p` must carry a `sites` field and a `sign_lut`
field (`sign_lut[d+1]` gives the sign contributed by a site whose digit is `d`). Unlike
[`phase_perm_fermionic`](@ref) (a Jordan-Wigner string that flags *odd*-occupied sites under
a *site permutation*), this relabels each site's own operators in place — no fermion ever
moves between sites, so the total sign is simply the product of independent per-site signs.

# Returns
- `Int`: The product of `p.sign_lut[read(state,x)+1]` over every site `x` in `p.sites`.
"""
function phase_spinful_fermion_relabel(
    p::NamedTuple,
    state::BaseInt{T,Ti,B}
) where {T,Ti,B}
    sign = 1
    for x in p.sites
        sign *= p.sign_lut[read(state, x)+1]
    end
    return sign
end

"""
    FermionicSpinInversion{T_z<:Integer,T_N<:Integer} <: SymBasis.SymGroups.AbstractSymSpec

A concrete subtype of [`SymBasis.SymGroups.AbstractSymSpec`](@ref) representing the
simultaneous exchange of spin-up and spin-down fermions at every site of a spin-1/2
`SpinfulFermion` DoF-object (QuSpin's `sblock`). With the fixed ascending-spin-projection
intra-site operator ordering used throughout this package (`|m_1<m_2⟩ = c†_{m_1}c†_{m_2}|0⟩`),
a doubly-occupied site picks up a `-1` sign under this exchange (reversing the order of its 2
creation operators); empty and singly-occupied sites are sign-free.

Note this symmetry maps a state with `(N_up, N_down)` to one with `(N_down, N_up)`: composed
with [`TotalSpinfulFermionicNumber`](@ref), it is a meaningful (non-degenerate) symmetry only
when `n_up == n_down`.

# Fields
- `z::T_z`: The spin-inversion parity quantum number (either `-1` or `1`).
- `N::T_N`: The total number of DoF-objects (sites) in the system.
"""
struct FermionicSpinInversion{T_z<:Integer,T_N<:Integer} <: AbstractSymSpec
    z::T_z
    N::T_N

    function FermionicSpinInversion(z::T_z, N::T_N) where {T_z,T_N}
        @assert z == T_z(-1) || z == T_z(1)

        return new{T_z,T_N}(z, N)
    end
end

"""
    sym(
        ss::SymBasis.SymGroups.FermionicSpinInversion{T_z,T_N},
        dofo::SymBasis.DoFObjects.DoFObject{B,T_ldof,T,Ti}
    ) where {B,T_ldof,T,Ti,T_z,T_N}

Create a fermionic spin-inversion symmetry group for the given spin-1/2 spinful fermionic
DoF-object `dofo`, exchanging spin-up and spin-down at every site.
"""
function sym(
    ss::FermionicSpinInversion{T_z,T_N},
    dofo::DoFObject{B,T_ldof,T,Ti}
) where {B,T_ldof,T,Ti,T_z,T_N}
    @assert dofo.type == :SpinfulFermion

    occ_of = Dict(dofo.ldof[d+1] => d for d in 0:(B-1))
    relabel = ntuple(i -> occ_of[sort(-dofo.ldof[i])], B)
    sign_lut = ntuple(i -> iseven(binomial(length(dofo.ldof[i]), 2)) ? 1 : -1, B)

    identity_relabel = ntuple(i -> i - 1, B)
    trivial_sign_lut = ntuple(_ -> 1, B)

    sites = 1:ss.N |> collect
    rₛ = 0:1

    Z_sym = SymGroup(
        dofo,
        [
            r == 0 ?
            (; relabel=identity_relabel, sign_lut=trivial_sign_lut, sites=sites) :
            (; relabel=relabel, sign_lut=sign_lut, sites=sites)
            for r in rₛ
        ],
        check_perm,
        apply_spinful_fermion_relabel,
        phase_spinful_fermion_relabel,
        [ss.z^r for r in rₛ],
        ss.N
    )

    return Z_sym
end
