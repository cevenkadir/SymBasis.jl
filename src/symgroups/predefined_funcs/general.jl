using SymBasis.Miscs: perm_k, perm_wrapper, invperm
using BitPermutations: bitpermute, PermutationBackend, BitPermutation
using SymBasis.DoFObjects: DoFObject
using SymBasis.DigitBase: BaseInt, permute, count, flip, read

# START -- check and apply functions for predefined symmetries
"""
    check_perm(
        p::NamedTuple,
        state::SymBasis.DigitBase.BaseInt{T,Ti,B},
        prev_bool::Bool
    ) where {T,Ti,B}

Check if the given state is invariant under the permutation `p.perm`. Since permutations are
symmetries, this function always returns `prev_bool` unchanged.

`p` accepts any `NamedTuple` containing at least a `perm` field: besides plain
`(; perm=...)` cycles, this includes the extended cycles built by
[`SymBasis.SymGroups.sym`](@ref) for `Translational`/`SpatialReflection`/`Rotational`
symmetries, which additionally carry a precomputed `invperm` (and, for bases `B > 2`, a
digit power table `pows`) used by [`apply_perm`](@ref) and
[`SymBasis.SymGroups.phase_perm_fermionic`](@ref).

# Arguments
- `p::NamedTuple`: A named tuple containing at least a `perm` field.
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state to be checked.
- `prev_bool::Bool`: The previous boolean value to be combined with the check result.

# Returns
- `Bool`: The combined result of the previous boolean and the check (always `prev_bool`).
"""
function check_perm(
    p::NamedTuple,
    state::BaseInt{T,Ti,B},
    prev_bool::Bool
) where {T,Ti,B}
    return prev_bool
end

"""
    _perm_cycle(perm::AbstractVector{Ti}, dofo::DoFObject{B,T_s,T,Ti}) where {B,T_s,T,Ti}

Build the cycle named tuple for a permutation symmetry element. Besides the (possibly
bit-wrapped) permutation itself, the tuple carries data precomputed once per cycle so the
hot loop stays allocation-free: the inverse permutation (needed for fermionic phases), and,
for bases `B > 2`, the digit power table `pows[k] = B^(k-1)` used to permute digits in a
single pass. For a `:SpinfulFermion` DoF-object, the cycle additionally carries a per-digit
occupation-parity lookup `parity[d+1] = isodd(length(dofo.ldof[d+1]))`, used by
[`phase_perm_fermionic`](@ref) to compute the Jordan-Wigner sign (a digit holding an even
number of fermions, e.g. a doubly-occupied site, never contributes a sign under a site
permutation).
"""
function _perm_cycle(
    perm::AbstractVector{Ti},
    dofo::DoFObject{B,T_s,T,Ti}
) where {B,T_s,T,Ti}
    ip = Base.invperm(perm)
    wrapped = perm_wrapper(perm, B)
    if dofo.type == :SpinfulFermion
        parity = ntuple(d -> isodd(length(dofo.ldof[d])), B)
        if B == 2
            return (; perm=wrapped, invperm=ip, parity=parity)
        else
            pows = T[T(B)^(k - 1) for k in eachindex(perm)]
            return (; perm=wrapped, invperm=ip, pows=pows, parity=parity)
        end
    elseif B == 2
        return (; perm=wrapped, invperm=ip)
    else
        pows = T[T(B)^(k - 1) for k in eachindex(perm)]
        return (; perm=wrapped, invperm=ip, pows=pows)
    end
end

"""
    apply_perm(
        p::NamedTuple,
        state::SymBasis.DigitBase.BaseInt{T,Ti,B}
    ) where {T,Ti,B}

Apply the permutation `p.perm` to the given state.

`p` accepts any `NamedTuple` containing at least a `perm` field. When `p` also carries the
precomputed `invperm` and (for bases `B > 2`) `pows` fields produced by
[`_perm_cycle`](@ref) — as is the case for cycles built by
[`SymBasis.SymGroups.sym`](@ref) for `Translational`/`SpatialReflection`/`Rotational`
symmetries — the permutation is applied via a single allocation-free digit pass instead of
going through [`SymBasis.DigitBase.permute`](@ref). (`haskey` on a `NamedTuple` is resolved
at compile time, so this dispatch adds no runtime branching cost.) Otherwise it falls back
to `permute(state, p.perm)` for a plain vector `perm`, or to a specialized bit-permutation
path (via `BitPermutations.bitpermute`) when `p.perm` is a `BitPermutation` (base 2 only).

# Arguments
- `p::NamedTuple`: A named tuple containing at least a `perm` field.
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state to which the
    permutation will be applied.

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state after applying the permutation.
"""
function apply_perm(
    p::NamedTuple,
    state::BaseInt{T,Ti,B}
) where {T,Ti,B}
    # Cycles built by `sym(...)` for B > 2 carry the inverse permutation and a digit power
    # table, allowing a single-pass, allocation-free permutation. (`haskey` on a NamedTuple
    # is resolved at compile time.)
    if haskey(p, :invperm) && haskey(p, :pows)
        return _permute_invpow(state, p.invperm, p.pows)
    end
    return _apply_perm(p.perm, state)
end

function _apply_perm(
    perm::AbstractVector{<:Integer},
    state::BaseInt{T,Ti,B}
) where {T,Ti,B}
    return permute(state, perm)
end

function _permute_invpow(
    state::BaseInt{T,Ti,B},
    inv_perm::AbstractVector{<:Integer},
    pows::AbstractVector{T}
) where {T,Ti,B}
    BB = T(B)
    v = state.value
    out = zero(T)
    i = 1
    while !iszero(v)
        d = v % BB
        v ÷= BB
        iszero(d) || (out += d * pows[inv_perm[i]])
        i += 1
    end
    return BaseInt{T,Ti,B}(out)
end

"""
    _apply_perm(
        perm::BitPermutations.BitPermutation{T,<:BitPermutations.PermutationBackend{T}},
        state::SymBasis.DigitBase.BaseInt{T,Ti,2}
    ) where {T,Ti}

Internal helper backing [`apply_perm`](@ref): apply the bit permutation `perm` to the given
binary state in a more efficient way via `BitPermutations.bitpermute`. This method is
selected when the cycle's `perm` field is a `BitPermutation` (base 2 only); it is called as
`_apply_perm(p.perm, state)` from `apply_perm`, receiving the permutation directly rather
than the wrapping cycle `NamedTuple`.

# Arguments
- `perm::BitPermutations.BitPermutation{T,<:BitPermutations.PermutationBackend{T}}`: The bit
    permutation to apply.
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,2}`: The binary state to which the bit
    permutation will be applied.

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,2}`: The binary state after applying the bit
    permutation.
"""
function _apply_perm(
    perm::BitPermutation{T,<:PermutationBackend{T}},
    state::BaseInt{T,Ti,2}
) where {T,Ti}
    return BaseInt{T,Ti,2}(bitpermute(state.value, perm))
end

"""
    phase_unity(p, state)

Return a phase factor of `true` (implying a phase factor of `1`) for any given input. This
function is used as the default phase function for symmetries that do not involve any
nontrivial phase factors.

# Arguments
- `p`: A parameter containing the symmetry operation (not used in this function).
- `state`: The state to which the symmetry operation is applied (not used in this function).

# Returns
- `true`: A constant phase factor of `1`.
"""
function phase_unity(p, state)
    return true
end

"""
    apply_perm_fermionic(p, state)

Apply the permutation `p.perm` to the given binary state, and compute the fermionic phase
arising from the permutation of occupied sites. The function returns a tuple containing the
permuted state and the fermionic phase factor.

# Arguments
- `p`: A parameter containing the permutation (e.g. a named tuple with a `perm` field).
- `state`: The binary state to which the permutation will be applied.

# Returns
- A tuple containing the permuted state and the fermionic phase factor (`1` or `-1`).
"""
function apply_perm_fermionic(p, state)
    return apply_perm(p, state)
end

"""
    WeightedCounts{K,B}

Collapsed description of a conserved quantity that is a linear function of the digit counts
of a state. Instead of one group cycle per admissible digit-count signature — which makes
[`SymBasis.Bases.basis`](@ref) re-walk every state once per signature — a single cycle
carries `K` non-negative weight tables and their target values, so the sector membership
test is one pass over the digits regardless of how many signatures the sector admits.

# Fields
- `weights::NTuple{K,NTuple{B,Int}}`: `weights[k][d+1]` is the contribution of digit value
    `d` to the `k`-th conserved quantity. All entries must be non-negative (the membership
    test relies on the partial sums being monotone to bail out early).
- `targets::NTuple{K,Int}`: the target value of each conserved quantity.
- `sigs::Vector{NTuple{B,Int}}`: the admissible digit-count signatures `(N0, …, N(B-1))`,
    retained so that sector enumeration
    ([`SymBasis.SymGroups._candidate_states`](@ref)) can still avoid the full `Bᴺ` scan.
"""
struct WeightedCounts{K,B}
    weights::NTuple{K,NTuple{B,Int}}
    targets::NTuple{K,Int}
    sigs::Vector{NTuple{B,Int}}
end

function Base.:(==)(a::WeightedCounts, b::WeightedCounts)
    return a.weights == b.weights && a.targets == b.targets && a.sigs == b.sigs
end

Base.hash(w::WeightedCounts, h::UInt) = hash(w.sigs, hash(w.targets, hash(w.weights, h)))

@inline _any_exceeds(::Tuple{}, ::Tuple{}) = false
@inline function _any_exceeds(sums::Tuple, targets::Tuple)
    return first(sums) > first(targets) ||
           _any_exceeds(Base.tail(sums), Base.tail(targets))
end

@inline function _add_weights(
    sums::NTuple{K,Int}, weights::NTuple{K,NTuple{B,Int}}, d::Int
) where {K,B}
    return ntuple(k -> sums[k] + @inbounds(weights[k][d]), Val(K))
end

"""
    _check_wc(
        state::SymBasis.DigitBase.BaseInt{T,Ti,B},
        wc::SymBasis.SymGroups.WeightedCounts{K,B},
        N::Integer
    ) where {T,Ti,B,K}

Internal single-pass membership test for a [`SymBasis.SymGroups.WeightedCounts`](@ref)
sector: accumulate the `K` weighted digit sums over the `N` digits of `state` and compare
them against the targets. Because the weights are non-negative the partial sums are
monotone, so the walk bails out as soon as one of them overshoots its target.
"""
@inline function _check_wc(
    state::BaseInt{T,Ti,B}, wc::WeightedCounts{K,B}, N::Integer
) where {T,Ti,B,K}
    BB = T(B)
    weights = wc.weights
    targets = wc.targets
    sums = ntuple(_ -> 0, Val(K))
    v = state.value
    for _ in 1:N
        d = Int(v % BB) + 1
        sums = _add_weights(sums, weights, d)
        _any_exceeds(sums, targets) && return false
        v ÷= BB
    end
    return sums == targets
end

"""
    _weighted_count_cycle(
        cycles,
        weight_lists::NTuple{K,<:AbstractVector{<:Integer}},
        ::Val{B},
        N::Integer
    ) where {K,B}

Collapse a list of per-signature digit-count cycles into a single cycle
`(; wc::`[`SymBasis.SymGroups.WeightedCounts`](@ref)`, N)` carrying the same sector.

Returns `nothing` — signalling the caller to keep the original per-signature cycles — when
the collapse would not be an exact rewrite or would not pay off:

- fewer than two signatures (nothing to collapse; in particular every base-2 sector, whose
  [`SymBasis.SymGroups.check_Nₛ`](@ref) has a dedicated `count_ones` fast path),
- a negative weight (the early-exit in [`_check_wc`](@ref) assumes monotone partial sums),
- signatures that do not all encode the same target value.
"""
function _weighted_count_cycle(
    cycles,
    weight_lists::NTuple{K,<:AbstractVector{<:Integer}},
    ::Val{B},
    N::Integer
) where {K,B}
    length(cycles) > 1 || return nothing
    all(wl -> length(wl) == B && all(>=(0), wl), weight_lists) || return nothing

    sigs = [_digit_targets(p, Val(B)) for p in cycles]
    weights = ntuple(k -> ntuple(j -> Int(weight_lists[k][j]), Val(B)), Val(K))
    targets = ntuple(k -> _weighted_sum(sigs[1], weights[k]), Val(K))
    for sig in sigs
        ntuple(k -> _weighted_sum(sig, weights[k]), Val(K)) == targets || return nothing
    end

    return (; wc=WeightedCounts(weights, targets, sigs), N=Int(N))
end

@inline _weighted_sum(sig::NTuple{B,Int}, w::NTuple{B,Int}) where {B} = sum(map(*, sig, w))

"""
    check_Nₛ(
        p::NamedTuple{names,NT},
        state::SymBasis.DigitBase.BaseInt,
        prev_bool::Bool,
    ) where {names,NT<:Tuple{Vararg{Integer}}}

Check if the given state has the specified digit counts as defined in the named tuple `p`.
Since this is a symmetry check, the result is combined with `prev_bool`.

# Arguments
- `p::NamedTuple{names,NT}`: A named tuple containing the digit counts.
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref): The state to be checked.
- `prev_bool::Bool`: The previous boolean value to be combined with the check result.

# Returns
- `Bool`: The combined result of the previous boolean and the digit count check.
"""
function check_Nₛ(
    p::NamedTuple{names,NT},
    state::BaseInt,
    prev_bool::Bool
) where {names,NT<:Tuple{Vararg{Integer}}}
    return prev_bool * _check_Nₛ(state, p)
end

"""
    check_Nₛ(
        p::NamedTuple{names,<:Tuple{SymBasis.SymGroups.WeightedCounts,Integer}},
        state::SymBasis.DigitBase.BaseInt,
        prev_bool::Bool
    ) where {names}

Collapsed form of the digit-count check: instead of testing one fixed signature, test the
conserved quantity carried by `p.wc` in a single pass over the digits (see
[`SymBasis.SymGroups.WeightedCounts`](@ref)). This is the method selected for the
multi-signature sectors built by `sym` for `TotalBosonicNumber`, `TotalMagnetization` and
`TotalSpinfulFermionicNumber`.
"""
function check_Nₛ(
    p::NamedTuple{names,<:Tuple{WeightedCounts,Integer}},
    state::BaseInt,
    prev_bool::Bool
) where {names}
    return prev_bool && _check_wc(state, p.wc, p.N)
end

"""
    _check_Nₛ(
        state::SymBasis.DigitBase.BaseInt{T,Ti,B},
        p::NamedTuple{names}
    ) where {T,Ti,B,names}

Internal function to check if the given state has the specified digit counts as defined in
the named tuple `p`. Accepts any named tuple that contains the fields `N`, `N0`, `N1`, ...,
`N(B-1)` (e.g. from both `check_Nₛ` and `check_flip` parameter tuples).

# Arguments
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state to be checked.
- `p::NamedTuple{names}`: A named tuple containing at least the digit count fields.

# Returns
- `Bool`: `true` if the state has the specified digit counts, `false` otherwise.
"""
function _check_Nₛ(
    state::BaseInt{T,Ti,B},
    p::NamedTuple{names}
) where {T,Ti,B,names}
    BB = T(B)
    targets = _digit_targets(p, Val(B))
    counts = ntuple(_ -> 0, Val(B))
    v = state.value
    for _ in 1:p.N
        digit = Int(v % BB)
        c = counts[digit+1] + 1
        # Early exit: once any digit count exceeds its target the state cannot match.
        c > targets[digit+1] && return false
        counts = Base.setindex(counts, c, digit + 1)
        v ÷= BB
    end
    return counts == targets
end

# Fetch the target digit counts (`N0`, `N1`, …, `N(B-1)`) from `p` with the field lookups
# resolved at compile time (a runtime `Symbol("N$j")` would intern a new symbol per digit
# per call).
@generated function _digit_targets(p::NamedTuple, ::Val{B}) where {B}
    fields = [:(Int(getfield(p, $(QuoteNode(Symbol("N", j)))))) for j in 0:(B-1)]
    return :(($(fields...),))
end

"""
    _check_Nₛ(
        state::SymBasis.DigitBase.BaseInt{T,Ti,2},
        p::NamedTuple{N0::TN, N1::TN, N::TN}
    ) where {T,Ti,TN<:Integer}

Internal function to check if the given binary state has the specified counts of 0s and 1s
as defined in the named tuple `p`.

# Arguments
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,2}`: The binary state to be checked.
- `p::NamedTuple{N0::TN, N1::TN, N::TN}`: A named tuple containing the counts of 0s and 1s.

# Returns
- `Bool`: `true` if the state has the specified counts of 0s and 1s, `false` otherwise.
"""
function _check_Nₛ(
    state::BaseInt{T,Ti,2},
    p::@NamedTuple{N0::TN, N1::TN, N::TN}
) where {T,Ti,TN<:Integer}
    return count_ones(state.value) == p.N1
end

"""
    apply_Nₛ(
        p::NamedTuple{names,NT},
        state::SymBasis.DigitBase.BaseInt
    ) where {names,NT<:Tuple{Vararg{Integer}}}

Apply the symmetry operation defined by the digit counts in `p` to the given state. Since
this is a symmetry where the state remains unchanged, the function simply returns the input
state.

# Arguments
- `p::NamedTuple{names,NT}`: A named tuple containing the digit counts.
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref): The state to which the symmetry
    operation will be applied.

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref): The unchanged state.
"""
function apply_Nₛ(
    p::NamedTuple{names,NT},
    state::BaseInt
) where {names,NT<:Tuple{Vararg{Integer}}}
    return state
end

# Collapsed digit-count cycles (see `WeightedCounts`) act trivially too.
function apply_Nₛ(
    p::NamedTuple{names,<:Tuple{WeightedCounts,Integer}},
    state::BaseInt
) where {names}
    return state
end

"""
    check_flip(
        p::NamedTuple{names,<:Tuple{Bool,<:AbstractVector{Ti},Vararg{Integer}}},
        state::SymBasis.DigitBase.BaseInt{T,Ti,B},
        prev_bool::Bool
    ) where {names,T,Ti,B}

Check if the given state (for base `B > 2`) has the specified digit counts as defined in the
named tuple `p`. The function checks if the flipped state has the specified digit counts.
The result is combined with `prev_bool`.

# Arguments
- `p::NamedTuple{names,<:Tuple{Bool,<:AbstractVector{Ti},Vararg{Integer}}}`: A named tuple
    containing `is_flipped`, `sites`, and digit count fields `N0`, `N1`, ..., `N(B-1)`, `N`.
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state to be checked.
- `prev_bool::Bool`: The previous boolean value to be combined with the check result.

# Returns
- `Bool`: The combined result of the previous boolean and the digit count check.
"""
function check_flip(
    p::NamedTuple{names,<:Tuple{Bool,<:AbstractVector{Ti},Vararg{Integer}}},
    state::BaseInt{T,Ti,B},
    prev_bool::Bool
) where {names,T,Ti,B}
    return prev_bool && _check_Nₛ(state, p)
end

"""
    check_flip(
        p::NamedTuple{
            names,<:Tuple{Bool,<:AbstractVector{<:Integer},
            SymBasis.SymGroups.WeightedCounts,Integer}
        },
        state::SymBasis.DigitBase.BaseInt,
        prev_bool::Bool
    ) where {names}

Collapsed form of [`check_flip`](@ref) for sectors whose admissible digit-count signatures
have been folded into a single [`SymBasis.SymGroups.WeightedCounts`](@ref) (see
`sym(::SpinInversion, …)`).
"""
function check_flip(
    p::NamedTuple{
        names,<:Tuple{Bool,<:AbstractVector{<:Integer},WeightedCounts,Integer}
    },
    state::BaseInt,
    prev_bool::Bool
) where {names}
    return prev_bool && _check_wc(state, p.wc, p.N)
end

"""
    apply_flip(
        p::NamedTuple{is_flipped::Bool, sites::T_site, N0::TN, N1::TN, N::TN},
        state::SymBasis.DigitBase.BaseInt{T,Ti,2}
    ) where {T,Ti,TN<:Integer,T_site<:AbstractVector{Ti}}

Apply the flip operation defined by `p` to the given binary state if `p.is_flipped` is
`true`. If the state is flipped, the function returns the flipped state; otherwise, it
returns the original state.

# Arguments
- `p::@NamedTuple{is_flipped::Bool, sites::T_site, N0::TN, N1::TN, N::TN}`: A named tuple
    containing the flip flag, sites to be flipped, and the expected counts of 0s and 1s.
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,2}`: The binary state to which the
    flip operation will be applied.

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,2}`: The state after applying the flip
    operation.
"""
function apply_flip(
    p::NamedTuple{names,<:Tuple{Bool,<:AbstractVector{Ti},Vararg{Integer}}},
    state::BaseInt{T,Ti,B}
) where {names,T,Ti,B}
    if p.is_flipped
        return flip(state, p.sites)
    else
        return state
    end
end

# Same flip, for the collapsed cycles carrying a `WeightedCounts` instead of one signature.
function apply_flip(
    p::NamedTuple{
        names,<:Tuple{Bool,<:AbstractVector{<:Integer},WeightedCounts,Integer}
    },
    state::BaseInt
) where {names}
    return p.is_flipped ? flip(state, p.sites) : state
end
# END -- check and apply functions for predefined symmetries


# START -- candidate-state enumeration for sector-restricted checks
"""
    _candidate_states(check, cycles, ::Type{BaseInt{T,Ti,B}}, N) where {T,Ti,B}

Return a sorted `Vector` of all states that can pass `check` for at least one cycle in
`cycles`, or `nothing` when the check does not admit direct enumeration. Used by
`SymBasis.Bases.basis` to skip the full `B^N` scan: any state outside the returned
superset fails `check` for every cycle and therefore never enters the basis, so replacing
the full range by this set leaves the result unchanged.
"""
_candidate_states(check, cycles, ::Type{BaseInt{T,Ti,B}}, N) where {T,Ti,B} = nothing

function _candidate_states(
    ::typeof(check_Nₛ), cycles, ::Type{BaseInt{T,Ti,B}}, N
) where {T,Ti,B}
    return _sector_states_from_counts(cycles, BaseInt{T,Ti,B}, Int(N))
end

function _candidate_states(
    ::typeof(check_flip), cycles, ::Type{BaseInt{T,Ti,B}}, N
) where {T,Ti,B}
    return _sector_states_from_counts(cycles, BaseInt{T,Ti,B}, Int(N))
end

function _sector_states_from_counts(
    cycles, ::Type{BaseInt{T,Ti,B}}, N::Int
) where {T,Ti,B}
    # Bit tricks below assume the digit string fits strictly inside T.
    N * ceil(Int, log2(B)) < 8 * sizeof(T) || return nothing

    # Unique digit-count signatures (N0, …, N(B-1)) among the cycles; distinct signatures
    # define disjoint sectors.
    sigs = Set{NTuple{B,Int}}()
    for p in cycles
        for sig in _cycle_sigs(p, Val(B))
            push!(sigs, sig)
        end
    end

    # Each signature block comes out in ascending order, so the blocks only need merging.
    blocks = Vector{BaseInt{T,Ti,B}}[]
    for sig in sigs
        sum(sig) == N || continue # no N-digit state can match such a signature
        block = BaseInt{T,Ti,B}[]
        if B == 2
            _append_fixed_popcount_states!(block, BaseInt{T,Ti,2}, N, sig[2])
        else
            _append_fixed_counts_states!(block, BaseInt{T,Ti,B}, N, sig)
        end
        isempty(block) || push!(blocks, block)
    end
    return _merge_sorted_blocks(blocks, BaseInt{T,Ti,B})
end

# Digit-count signatures a cycle admits: a collapsed cycle carries the whole list, a plain
# one encodes exactly one in its `N0`, …, `N(B-1)` fields. (`haskey` on a `NamedTuple` is
# resolved at compile time.)
@inline function _cycle_sigs(p::NamedTuple, ::Val{B}) where {B}
    haskey(p, :wc) && return p.wc.sigs
    return (_digit_targets(p, Val(B)),)
end

# Merge already-ascending, pairwise-disjoint blocks into one ascending vector. Signature
# blocks are disjoint by construction, so a plain merge cannot produce duplicates. Merging
# pairwise (⌈log₂ k⌉ passes) rather than sorting the concatenation matters: at spinful
# N=12 the final `sort!` alone used to cost 16.9 ms of a 24.5 ms enumeration.
function _merge_sorted_blocks(
    blocks::Vector{Vector{V}}, ::Type{V}
) where {V}
    isempty(blocks) && return V[]
    while length(blocks) > 1
        merged = Vector{Vector{V}}()
        sizehint!(merged, cld(length(blocks), 2))
        for i in 1:2:length(blocks)
            if i == length(blocks)
                push!(merged, blocks[i])
            else
                push!(merged, _merge_two(blocks[i], blocks[i+1]))
            end
        end
        blocks = merged
    end
    return blocks[1]
end

function _merge_two(a::Vector{V}, b::Vector{V}) where {V}
    isempty(a) && return b
    isempty(b) && return a
    out = Vector{V}(undef, length(a) + length(b))
    i = 1
    j = 1
    @inbounds for k in eachindex(out)
        if j > length(b) || (i <= length(a) && isless(a[i], b[j]))
            out[k] = a[i]
            i += 1
        else
            out[k] = b[j]
            j += 1
        end
    end
    return out
end

# All N-bit values with exactly k ones, via Gosper's hack.
function _append_fixed_popcount_states!(
    out::Vector{BaseInt{T,Ti,2}}, ::Type{BaseInt{T,Ti,2}}, N::Int, k::Int
) where {T,Ti}
    if k == 0
        push!(out, BaseInt{T,Ti,2}(zero(T)))
        return out
    end
    (0 < k <= N) || return out

    sizehint!(out, length(out) + binomial(N, k))
    limit = one(T) << N
    v = (one(T) << k) - one(T)
    while v < limit
        push!(out, BaseInt{T,Ti,2}(v))
        c = v & (-v)
        r = v + c
        v = (((r ⊻ v) >> 2) ÷ c) | r
    end
    return out
end

# All N-digit base-B values whose digit multiset matches `counts` (multiset permutations).
function _append_fixed_counts_states!(
    out::Vector{BaseInt{T,Ti,B}}, ::Type{BaseInt{T,Ti,B}}, N::Int, counts::NTuple{B2,Int}
) where {T,Ti,B,B2}
    all(>=(0), counts) || return out

    # Multinomial coefficient N! / ∏ counts[j]!, estimated in Float64 to avoid overflow
    # and capped so the hint itself stays modest.
    est = 1.0
    r = N
    for c in counts
        est *= Float64(binomial(r, c))
        r -= c
    end
    sizehint!(out, length(out) + (est < 1e7 ? round(Int, est) : 10_000_000))

    pows = T[T(B)^(p - 1) for p in 1:N]
    remaining = collect(counts)
    _fixed_counts_rec!(out, remaining, pows, N, zero(T))
    return out
end

# Fill the digit positions from the most significant one downwards, trying digit values in
# ascending order. Since the value of a state is `Σ dₚ Bᵖ⁻¹`, that emission order is
# numerically ascending, which lets `_sector_states_from_counts` merge the per-signature
# blocks instead of sorting their concatenation.
function _fixed_counts_rec!(
    out::Vector{BaseInt{T,Ti,B}},
    remaining::Vector{Int},
    pows::Vector{T},
    pos::Int,
    val::T
) where {T,Ti,B}
    if pos < 1
        push!(out, BaseInt{T,Ti,B}(val))
        return nothing
    end
    @inbounds for d in 0:(B-1)
        if remaining[d+1] > 0
            remaining[d+1] -= 1
            _fixed_counts_rec!(out, remaining, pows, pos - 1, val + T(d) * pows[pos])
            remaining[d+1] += 1
        end
    end
    return nothing
end
# END -- candidate-state enumeration for sector-restricted checks


# START -- predefined symmetry group wrappers for end users
"""
    AbstractSymSpec

An abstract type representing a symmetry specification. Concrete subtypes of
`AbstractSymSpec` define specific symmetry specifications that can be used to create
symmetry groups.
"""
abstract type AbstractSymSpec end

"""
    Translational{T_k<:Integer,Ti} <: SymBasis.SymGroups.AbstractSymSpec

A concrete subtype of [`SymBasis.SymGroups.AbstractSymSpec`](@ref) representing a
translational symmetry specification. The type parameter `T_k` represents the momentum
quantum number, while `Ti` represents the type of the permutation indices.

# Fields
- `k::T_k`: The momentum number.
- `perm::AbstractVector{Ti}`: The permutation vector defining the translation.

# Constructor Arguments
- `k::T_k`: The momentum number.
- `perm::AbstractVector{Ti}`: The permutation vector defining the translation.

# Returns
- `Translational{T_k,Ti}`: An instance of `Translational` representing the specified
translational symmetry.
"""
struct Translational{T_k<:Integer,Ti} <: AbstractSymSpec
    k::T_k
    perm::AbstractVector{Ti}

    function Translational(k::T_k, perm::AbstractVector{Ti}) where {T_k,Ti}
        N = length(perm)
        @assert N == length(unique(perm))

        Id_vec = 1:N .|> Ti
        @assert perm != Id_vec

        return new{T_k,Ti}(k, perm)
    end
end

"""
    sym(
        ss::SymBasis.SymGroups.Translational{T_k,Ti},
        dofo::SymBasis.DoFObjects.DoFObject{B,T_s,T,Ti}
    ) where {B,T_s,T,Ti,T_k}

Create a translational symmetry group for the given DoF-object `dofo`, and translational
symmetry specification `ss`.

# Arguments
- `ss::`[`SymBasis.SymGroups.Translational`](@ref)`{T_k,Ti}`: The translational symmetry
    specification.
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object.

# Returns
- [`SymBasis.SymGroups.SymGroup`](@ref): The translational symmetry group.
"""
function sym(
    ss::Translational{T_k,Ti},
    dofo::DoFObject{B,T_s,T,Ti}
) where {B,T_s,T,Ti,T_k}
    N = length(ss.perm)
    Id_vec = 1:N .|> Ti

    R = 1
    for r in 1:(N-1)
        if Id_vec != perm_k(ss.perm, r)
            R += 1
        else
            break
        end
    end
    @assert R <= N

    rₛ = 0:(R-1)

    is_fermionic = dofo.type == :SpinlessFermion || dofo.type == :SpinfulFermion

    apply = is_fermionic ? apply_perm_fermionic : apply_perm
    phase = is_fermionic ? phase_perm_fermionic : phase_unity

    T_sym = SymGroup(
        dofo,
        [_perm_cycle(perm_k(ss.perm, i), dofo) for i in rₛ],
        check_perm,
        apply,
        phase,
        [
            cispi(-2r * ss.k / R)
            for r in rₛ
        ],
        N
    )

    return T_sym
end

"""
    SpatialReflection{T_p<:Integer,Ti} <: SymBasis.SymGroups.AbstractSymSpec

A concrete subtype of [`SymBasis.SymGroups.AbstractSymSpec`](@ref) representing a spatial
reflection symmetry specification. The type parameter `T_p` represents the parity quantum
number, while `Ti` represents the type of the permutation indices.

# Fields
- `p::T_p`: The parity number (either `-1` or `1`).
- `perm::AbstractVector{Ti}`: The permutation vector defining the spatial reflection.

# Constructor Arguments
- `p::T_p`: The parity number (either `-1` or `1`).
- `perm::AbstractVector{Ti}`: The permutation vector defining the spatial reflection.

# Returns
- `SpatialReflection{T_p,Ti}`: An instance of `SpatialReflection` representing the specified
spatial reflection symmetry.
"""
struct SpatialReflection{T_p<:Integer,Ti} <: AbstractSymSpec
    p::T_p
    perm::AbstractVector{Ti}

    function SpatialReflection(p::T_p, perm::AbstractVector{Ti}) where {T_p,Ti}
        N = length(perm)
        @assert N == length(unique(perm))

        @assert p == T_p(-1) || p == T_p(1)

        Id_vec = 1:N .|> Ti
        @assert perm != Id_vec

        return new{T_p,Ti}(p, perm)
    end
end

"""
    sym(
        ss::SymBasis.SymGroups.SpatialReflection{T_p,Ti},
        dofo::SymBasis.DoFObjects.DoFObject{B,T_s,T,Ti}
    ) where {B,T_s,T,Ti,T_p}

Create a spatial reflection symmetry group for the given DoF-object `dofo`, and spatial
reflection symmetry specification `ss`.

# Arguments
- `ss::`[`SymBasis.SymGroups.SpatialReflection`](@ref)`{T_p,Ti}`: The spatial reflection
    symmetry specification.
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object.

# Returns
- [`SymBasis.SymGroups.SymGroup`](@ref): The spatial reflection symmetry group.
"""
function sym(
    ss::SpatialReflection{T_p,Ti},
    dofo::DoFObject{B,T_s,T,Ti}
) where {B,T_s,T,Ti,T_p}
    N = length(ss.perm)
    Id_vec = 1:N .|> Ti

    R = 1
    for r in 1:(N-1)
        if Id_vec != perm_k(ss.perm, r)
            R += 1
        else
            break
        end
    end
    @assert R == 2

    rₛ = 0:(R-1)

    is_fermionic = dofo.type == :SpinlessFermion || dofo.type == :SpinfulFermion

    apply = is_fermionic ? apply_perm_fermionic : apply_perm
    phase = is_fermionic ? phase_perm_fermionic : phase_unity

    P_sym = SymGroup(
        dofo,
        [_perm_cycle(perm_k(ss.perm, i), dofo) for i in rₛ],
        check_perm,
        apply,
        phase,
        [ss.p^r for r in rₛ],
        N
    )

    return P_sym
end

"""
    Rotational{T_r<:Integer,Ti} <: SymBasis.SymGroups.AbstractSymSpec

A concrete subtype of [`SymBasis.SymGroups.AbstractSymSpec`](@ref) representing the
specification of rotational symmetry of space. The type parameter `T_r` represents the
spatial rotation number, while `Ti` represents the type of the permutation indices.

# Fields
- `r::T_r`: The spatial rotation number.
- `perm::AbstractVector{Ti}`: The permutation vector defining the rotation.

# Constructor Arguments
- `r::T_r`: The spatial rotation number.
- `perm::AbstractVector{Ti}`: The permutation vector defining the rotation.

# Returns
- `Rotational{T_r,Ti}`: An instance of `Rotational` representing the specified rotational
    symmetry of space.
"""
struct Rotational{T_r<:Integer,Ti} <: AbstractSymSpec
    r::T_r
    perm::AbstractVector{Ti}

    function Rotational(r::T_r, perm::AbstractVector{Ti}) where {T_r,Ti}
        N = length(perm)
        @assert N == length(unique(perm))

        Id_vec = 1:N .|> Ti
        @assert perm != Id_vec

        return new{T_r,Ti}(r, perm)
    end
end

"""
    sym(
        ss::SymBasis.SymGroups.Rotational{T_r,Ti},
        dofo::SymBasis.DoFObjects.DoFObject{B,T_s,T,Ti}
    ) where {B,T_s,T,Ti,T_r}

Create  a group of rotational symmetry of space for the given DoF-object `dofo`, and
rotational symmetry specification `ss`. The function generates the rotational symmetry group
by applying the permutation defined in `ss` repeatedly until it returns to the identity, and
constructs the rotational symmetry group using the `check_perm` and `apply_perm` functions.

# Arguments
- `ss::`[`SymBasis.SymGroups.Rotational`](@ref)`{T_r,Ti}`: The specification of rotational
    symmetry of space.
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object.

# Returns
- [`SymBasis.SymGroups.SymGroup`](@ref): The group of rotational symmetry of space.
"""
function sym(
    ss::Rotational{T_r,Ti},
    dofo::DoFObject{B,T_s,T,Ti}
) where {B,T_s,T,Ti,T_r}
    N = length(ss.perm)
    Id_vec = 1:N .|> Ti

    R = 1

    while Id_vec != perm_k(ss.perm, R)
        R += 1
    end

    rₛ = 0:(R-1)

    is_fermionic = dofo.type == :SpinlessFermion || dofo.type == :SpinfulFermion

    apply = is_fermionic ? apply_perm_fermionic : apply_perm
    phase = is_fermionic ? phase_perm_fermionic : phase_unity

    R_sym = SymGroup(
        dofo,
        [_perm_cycle(perm_k(ss.perm, i), dofo) for i in rₛ],
        check_perm,
        apply,
        phase,
        [cispi(-2 * r * ss.r / R) for r in rₛ],
        N
    )

    return R_sym
end

@deprecate sym(
    s::Symbol,
    dofo::DoFObject{B,T_s,T,Ti},
    args...; kwargs...
) where {B,T_s,T,Ti} sym(getfield(SymGroups, s)(args...), dofo; kwargs...)
# END -- predefined symmetry group wrappers for end users
