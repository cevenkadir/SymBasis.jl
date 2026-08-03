
using SymBasis.DigitBase: BaseInt, BaseIntRange, base_number_to_string
using SymBasis.SymGroups: SymGroup, CombSymGroup, _apply_all, _apply_phase_all,
    _candidate_states, apply_Nₛ
using SymBasis.DoFObjects: DoFObject

"""
    Basis{T,T_n<:Number}
    Basis(
        states::AbstractVector{T},
        norms::AbstractVector{T_n},
        sg::Union{SymGroup,CombSymGroup,Nothing}=nothing
    ) where {T,T_n<:Number}

A basis struct consisting of a collection of basis states and their corresponding norms. The
basis states are represented using [`SymBasis.DigitBase.BaseInt`](@ref), which allows for
efficient representation and manipulation of states in different bases.

# Fields
- `states::AbstractVector{T}`: A vector of basis states, where `T` is the type of the basis
    states.
- `norms::AbstractVector{T_n}`: A vector of norms corresponding to each basis state, where
    `T_n` is the data type for the norms.
- `sg::Union{SymGroup,CombSymGroup,Nothing}`: An optional symmetry group associated with the
    basis. It can be either a [`SymBasis.SymGroups.SymGroup`](@ref) or a
    [`SymBasis.SymGroups.CombSymGroup`](@ref), or `nothing` if no symmetry group is
    associated.
- `sorted::Bool`: Whether `states` is in ascending order, determined once at construction.
    Bases built by [`basis`](@ref) always are; [`state_index`](@ref) uses this to pick a
    binary search over a linear scan.

# Constructor Arguments
- `states::AbstractVector{T}`: A vector of basis states, where `T` is the type of the basis
    states.
- `norms::AbstractVector{T_n}`: A vector of norms corresponding to each basis state.
- `sg::Union{SymGroup,CombSymGroup,Nothing}`: An optional symmetry group associated with the
    basis.

# Returns
- [`SymBasis.Bases.Basis`](@ref)`{T,T_n}`: A new [`SymBasis.Bases.Basis`](@ref) instance
    containing the provided states, norms and optional symmetry group.

The constructor checks that the length of states matches the length of norms to ensure
consistency.
"""
struct Basis{
    T,T_n<:Number,
    T_states<:AbstractVector{T},
    T_norms<:AbstractVector{T_n},
    T_sg<:Union{SymGroup,CombSymGroup,Nothing}
}
    states::T_states
    norms::T_norms
    sg::T_sg
    sorted::Bool
    function Basis(
        states::AbstractVector{T},
        norms::AbstractVector{T_n},
        sg::Union{SymGroup,CombSymGroup,Nothing}=nothing
    ) where {T,T_n<:Number}
        @assert length(states) == length(norms) "Length of states and norms must be equal"
        return new{T,T_n,typeof(states),typeof(norms),typeof(sg)}(
            states, norms, sg, issorted(states)
        )
    end
end

function Base.isequal(b1::Basis{T,T_n}, b2::Basis{T,T_n}) where {T,T_n}
    return b1.states == b2.states && b1.norms == b2.norms && b1.sg == b2.sg
end

function Base.:(==)(b1::Basis{T,T_n}, b2::Basis{T,T_n}) where {T,T_n}
    return b1.states == b2.states && b1.norms == b2.norms && b1.sg == b2.sg
end

function Base.hash(b::Basis, h::UInt)
    return hash(b.states, hash(b.norms, hash(b.sg, hash(:BaseNumber, h))))
end

Base.iterate(b::Basis) = (b.states, Val(:norms))
Base.iterate(b::Basis, ::Val{:norms}) = (b.norms, Val(:sg))
Base.iterate(b::Basis, ::Val{:sg}) = (b.sg, Val(:done))
Base.iterate(b::Basis, ::Val{:done}) = nothing

"""
    state_index(b::SymBasis.Bases.Basis{T}, state::T) where {T}

Return the index of `state` in `b.states`, or `nothing` if it is not a basis state.

Bases produced by [`basis`](@ref) are sorted, in which case the lookup is a binary search
(`O(log n)`); otherwise it falls back to a linear scan. This is the efficient way to map a
representative state back to its basis index when assembling operators — it avoids both
the `O(n)` cost of `findfirst`/`∈` on `b.states` and the memory of a separate index
`Dict`.

# Arguments
- `b::`[`SymBasis.Bases.Basis`](@ref)`{T}`: The basis to look the state up in.
- `state::T`: The state to look up.

# Returns
- `Union{Int,Nothing}`: The index of `state` in `b.states`, or `nothing` if absent.
"""
function state_index(b::Basis{T}, state::T) where {T}
    if b.sorted
        i = searchsortedfirst(b.states, state)
        (i <= length(b.states) && b.states[i] == state) && return i
        return nothing
    end
    return findfirst(isequal(state), b.states)
end

"""
    Base.in(state::T, b::SymBasis.Bases.Basis{T}) where {T}

Check whether `state` is one of the basis states of `b`, using the same fast lookup as
[`state_index`](@ref).

# Arguments
- `state::T`: The state to test.
- `b::`[`SymBasis.Bases.Basis`](@ref)`{T}`: The basis to test against.

# Returns
- `Bool`: `true` if `state` is a basis state of `b`, `false` otherwise.
"""
Base.in(state::T, b::Basis{T}) where {T} = state_index(b, state) !== nothing

function Base.summary(io::IO, b::Basis{T,T_n}) where {T,T_n}
    print(io, "Basis{$T,$T_n} with ", length(b.states), " states")
end

function Base.show(io::IO, b::Basis{T,T_n}) where {T,T_n}
    compact = get(io, :compact, false)
    print(io, "Basis{$T,$T_n}(")
    if compact
        print(io, "states=", length(b.states), ", norms=", length(b.norms))
    else
        print(io, "\n\tstates = ")
        show(io, b.states)
        print(io, ",\n\tnorms  = ")
        show(io, b.norms)
        print(io, "\n")
    end
    print(io, ")")
end

function Base.show(
    io::IO, ::MIME"text/plain", b::Basis{T,Tn}
) where {T,Tn}
    n = length(b.states)
    println(io, "Basis{$T,$Tn} with $n state$(n == 1 ? "" : "s")")

    # shorter indent (2 spaces)
    ind = "  "
    ind2 = "    "

    println(io, ind, "states: ", typeof(b.states))
    println(io, ind, "norms : ", typeof(b.norms))
    println(io, ind, "symmetry group: ", typeof(b.sg))

    n == 0 && return

    m = min(n, get(io, :limit, true) ? 10 : n)
    println(io, ind, "first $(m) state$(m == 1 ? "" : "s")/norm$(m == 1 ? "" : "s"):")

    st_strs = [sprint(show, b.states[i]) for i in 1:m]
    wmax = maximum(textwidth.(st_strs))
    gap = 2

    for i in 1:m
        s = st_strs[i]
        print(io, ind2, s)
        print(io, ' '^max(gap, wmax - textwidth(s) + gap))
        print(io, "(norm=")
        show(io, b.norms[i])
        println(io, ")")
    end

    if m < n
        println(io, ind2, "⋮")
    end
end

"""
    basis(
        dofo::DoFObject{B,T_s,T,Ti},
        N::Integer;
        norm_type=Float64
    ) where {B,T_s,T,Ti}

Generates the full basis for a DoF-object without symmetry considerations.

# Arguments
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object for which
    the basis is to be generated.
- `N::Integer`: The number of sites or particles.

# Keyword Arguments
- `norm_type::DataType=Float64`: The data type for the norms of the basis states. Default is
    `Float64`.
- `is_sorted::Bool=false`: Retained for backwards compatibility and has no effect: the
    states are enumerated in ascending order, so the returned basis is always sorted.

# Returns
- [`SymBasis.Bases.Basis`](@ref): The generated basis.
"""
function basis(
    dofo::DoFObject{B,T_s,T,Ti},
    N::Integer;
    norm_type::DataType=Float64,
    is_sorted::Bool=false
) where {B,T_s,T,Ti}
    states = collect(BaseInt(T(0); base=B, Ti=Ti):BaseInt(T(B^N-1); base=B, Ti=Ti))
    norms = ones(norm_type, length(states))
    # The scan is over an ascending range, so the output is sorted by construction and
    # `is_sorted` needs no extra work.
    return Basis(states, norms)
end

"""
    _OrbitDedup{T}

Counts the distinct states visited in one symmetry orbit, reset between orbits and reused
for the whole chunk.

Small groups scan a linear buffer. Groups of 32 or more cycles (2D lattices, say) switch to
an open-addressing table, where each slot carries the `generation` it was last written in
rather than a validity flag — so resetting is an increment instead of a `fill!` over the
whole table.
"""
mutable struct _OrbitDedup{T}
    use_hash::Bool
    seen::Vector{T}       # linear mode: the states of the current orbit
    slots::Vector{T}      # hash mode: open-addressing table, `mask + 1` entries
    stamps::Vector{Int32} # hash mode: generation each slot was last written in
    generation::Int32
    mask::Int
    count::Int
end

function _OrbitDedup(::Type{T}, n_cycles::Int) where {T}
    n_cycles < 32 && return _OrbitDedup{T}(
        false, Vector{T}(undef, n_cycles), T[], Int32[], Int32(0), 0, 0
    )
    n_slots = max(8, nextpow(2, 2 * n_cycles))
    return _OrbitDedup{T}(
        true, T[], Vector{T}(undef, n_slots), zeros(Int32, n_slots), Int32(0), n_slots - 1, 0
    )
end

@inline function _dedup_reset!(d::_OrbitDedup)
    d.count = 0
    if d.use_hash
        if d.generation == typemax(Int32)
            fill!(d.stamps, Int32(0))
            d.generation = Int32(0)
        end
        d.generation += Int32(1)
    end
    return d
end

# murmur3 finalizer
@inline function _mix64(v)
    z = v % UInt64
    z ⊻= z >>> 33
    z *= 0xff51afd7ed558ccd
    z ⊻= z >>> 33
    return z
end

@inline function _dedup_insert!(d::_OrbitDedup{T}, v::T) where {T}
    if d.use_hash
        i = (Int(_mix64(v) & 0x7fffffffffffffff) & d.mask) + 1
        @inbounds while d.stamps[i] == d.generation
            d.slots[i] == v && return nothing
            i = (i & d.mask) + 1
        end
        @inbounds d.stamps[i] = d.generation
        @inbounds d.slots[i] = v
    else
        @inbounds for k in 1:d.count
            d.seen[k] == v && return nothing
        end
        @inbounds d.seen[d.count+1] = v
    end
    d.count += 1
    return nothing
end

"""
    _dim_elements(cycles::AbstractArray{TT,D}) where {TT<:Tuple,D}

Extract, for each dimension of a `CombSymGroup`'s cycle product, the vector of that
dimension's distinct symmetry elements. `cycles` is built from `Base.product`, so the
dim-`i` component of the cycle at CartesianIndex `I` depends only on `I[i]`.
"""
function _dim_elements(cycles::AbstractArray{TT,D}) where {TT<:Tuple,D}
    corner = first(CartesianIndices(cycles)).I
    return ntuple(Val(D)) do i
        [cycles[Base.setindex(corner, k, i)...][i] for k in axes(cycles, i)]
    end
end

# Evaluate each dimension's check once per distinct element of that dimension (instead of once
# per flattened cycle). Returns `false` as soon as some dimension has no valid element, in
# which case no cycle of the product can be valid for `state₀`. Dimension `S` (0 for none) is
# taken as already satisfied -- see `_candidates_satisfy_check`.
# Generated so the per-dimension loops are fully unrolled with no tuple juggling.
@generated function _fill_valid!(
    valid::NTuple{D,Any}, checks::NTuple{D,Any}, elems::NTuple{D,Any}, state₀, ::Val{S}
) where {D,S}
    body = Expr(:block)
    for i in 1:D
        if i == S
            push!(body.args, :(fill!(valid[$i], true)))
            continue
        end
        vs, es, chk, ok, anyok = gensym(:vs), gensym(:es), gensym(:chk),
        gensym(:ok), gensym(:anyok)
        push!(body.args, quote
            $vs = valid[$i]
            $es = elems[$i]
            $chk = checks[$i]
            $anyok = false
            @inbounds for k in eachindex($es)
                $ok = $chk($es[k], state₀, true)
                $vs[k] = $ok
                $anyok |= $ok
            end
            $anyok || return false
        end)
    end
    push!(body.args, :(return true))
    return body
end

"""
    _candidates_satisfy_check(apply, elems, candidates) -> Bool

Whether every candidate already passes the check of the dimension that produced it, making
that dimension's per-state re-test pure overhead. Requires the candidates to come from an
exact [`SymBasis.SymGroups._candidate_states`](@ref) enumeration (not the `Bᴺ` fallback) and
that dimension to hold a single element.

Also requires `apply_Nₛ`, which is easy to miss: the check is evaluated against the
*transformed* state, so the candidate set's provenance only carries over when the
transformation is the identity.
"""
@inline function _candidates_satisfy_check(apply, elems, candidates)
    return candidates !== nothing && length(elems) == 1 && apply === apply_Nₛ
end

# Nested scan over the valid part of the cycle product, reusing partial applications: the
# dim-1 transformation of `state₀` is computed once and shared by all combinations of the
# later dimensions. At the leaf the fully transformed state feeds the orbit dedup and, when it
# lands back on `state₀`, appends its element indices to `stab`; an early return unwinds the
# whole nest when a valid cycle maps `state₀` below itself. Generated so all `D` loops are
# emitted explicitly (a `Base.tail` recursion over tuples of vectors cannot be inlined and
# allocates per state).
#
# Phases are resolved from `stab` only after the nest completes, so candidates that abort
# never pay for one. That matters because the identity is the first leaf visited and fixes
# every state, making the phase otherwise unavoidable for all of them. `stab` is in leaf
# order, so `F` accumulates exactly as it would have inline and the result is bit-identical.
@generated function _scan_product(
    applys::NTuple{D,Any}, phases::NTuple{D,Any}, elems::NTuple{D,Any},
    valid::NTuple{D,Any}, factors, state₀, F₀, dedup::_OrbitDedup,
    stab::Vector{NTuple{D,Int}}
) where {D}
    ks = [Symbol(:k_, i) for i in 1:D]
    sts = [Symbol(:state_, i) for i in 0:D]
    els = [Symbol(:elem_, i) for i in 1:D]

    body = quote
        _dedup_insert!(dedup, $(sts[D+1]).value)
        if isless($(sts[D+1]), state₀)
            return (zero(F), true)
        elseif $(sts[D+1]) == state₀
            n_stab += 1
            @inbounds stab[n_stab] = ($(ks...),)
        end
    end

    for i in D:-1:1
        es, vs, a = gensym(:es), gensym(:vs), gensym(:a)
        body = quote
            $es = elems[$i]
            $vs = valid[$i]
            $a = applys[$i]
            @inbounds for $(ks[i]) in eachindex($es)
                $vs[$(ks[i])] || continue
                $(els[i]) = $es[$(ks[i])]
                $(sts[i+1]) = $a($(els[i]), $(sts[i]))
                $body
            end
        end
    end

    return quote
        $(sts[1]) = state₀
        F = F₀
        n_stab = 0
        $body
        @inbounds for t in 1:n_stab
            ksel = stab[t]
            # Splatted rather than `ntuple(i -> ...)`: a closure in a `@generated` function's
            # returned AST is rejected as impure.
            es = ($([:(elems[$i][ksel[$i]]) for i in 1:D]...),)
            F += factors[ksel...] * last(_apply_phase_all(applys, phases, es, state₀, 1))
        end
        return (F, false)
    end
end

const _WORK_PER_CHUNK = 256

# Split a scan range into chunks for `Threads.@spawn`. Oversubscribing to ~4 chunks per thread
# balances an uneven density of valid states across the range, but it only pays once there is
# enough work to amortize the extra spawns: a scan that finishes in microseconds loses more to
# task overhead than it gains. The relevant measure is total work, not the number of
# candidates -- each candidate is scanned against every cycle of the group -- so the chunk
# count is driven by `n * n_cycles` and floored at one chunk per thread.
function _chunk_length(n::Integer, n_cycles::Integer, nthreads::Integer)
    n_chunks = clamp(cld(n * n_cycles, _WORK_PER_CHUNK), nthreads, 4 * nthreads)
    return max(1, cld(n, n_chunks))
end

function _basis_impl_csg(
    all_bints::Union{BaseIntRange{T,Ti,B},AbstractVector{BaseInt{T,Ti,B}}},
    csg::CombSymGroup{B,T_s,T,Ti,Ts},
    dim_elems::DE,
    F₀::Complex{T_n},
    eps_norm_type::T_n,
    skip_dim::Val{S}
) where {T,Ti,B,T_n<:Real,T_s,Ts,DE<:Tuple,S}
    n_cycles = length(csg.cycles)
    checks = csg.check
    applys = csg.apply
    phases = csg.phase
    factors = csg.factors
    D = length(dim_elems)

    nthreads = Threads.nthreads()
    chunk_len = _chunk_length(length(all_bints), n_cycles, nthreads)

    tasks = map(Iterators.partition(all_bints, chunk_len)) do chunk
        Threads.@spawn begin
            local_norms = T_n[]
            local_states = BaseInt{T,Ti,B}[]
            sizehint!(local_norms, length(chunk) ÷ n_cycles + 4)
            sizehint!(local_states, length(chunk) ÷ n_cycles + 4)
            valid = map(es -> Vector{Bool}(undef, length(es)), dim_elems)
            dedup = _OrbitDedup(T, n_cycles)
            # Reused across states; an orbit cannot fix `state₀` more often than it has
            # elements, so `n_cycles` is a hard bound on the stabilizer size.
            stab = Vector{NTuple{D,Int}}(undef, n_cycles)

            for state₀ in chunk
                _fill_valid!(valid, checks, dim_elems, state₀, skip_dim) || continue

                _dedup_reset!(dedup)
                local_F, aborted = _scan_product(
                    applys, phases, dim_elems, valid, factors, state₀, F₀, dedup, stab
                )
                aborted && continue

                norm₀ = dedup.count * abs2(local_F)
                if norm₀ > eps_norm_type
                    push!(local_norms, norm₀)
                    push!(local_states, state₀)
                end
            end

            (local_states, local_norms)
        end
    end

    results = fetch.(tasks)
    states = isempty(results) ? BaseInt{T,Ti,B}[] : vcat((r[1] for r in results)...)
    norms = isempty(results) ? T_n[] : vcat((r[2] for r in results)...)

    # Ascending by construction: ordered scan + order-preserving chunk concatenation.
    return Basis(states, norms, csg)
end

function _basis_impl(
    all_bints::Union{BaseIntRange{T,Ti,B},AbstractVector{BaseInt{T,Ti,B}}},
    n_cycles::Int,
    sg::Union{SymGroup{B,T_s,T,Ti,Ts},CombSymGroup{B,T_s,T,Ti,Ts}},
    F₀::Complex{T_n},
    eps_norm_type::T_n,
    get_temp_state::F,
    get_phase::G,
    is_sorted::Bool
) where {T,Ti,B,T_n<:Real,T_s,Ts,F,G}
    nthreads = Threads.nthreads()

    chunk_len = _chunk_length(length(all_bints), n_cycles, nthreads)

    tasks = map(Iterators.partition(all_bints, chunk_len)) do chunk
        Threads.@spawn begin
            local_norms = T_n[]
            local_states = BaseInt{T,Ti,B}[]
            sizehint!(local_norms, length(chunk) ÷ n_cycles + 4)
            sizehint!(local_states, length(chunk) ÷ n_cycles + 4)
            local_F = F₀
            dedup = _OrbitDedup(T, n_cycles)
            # Reused across states; the stabilizer cannot be larger than the group.
            stab = Vector{Int}(undef, n_cycles)

            for state₀ in chunk
                _dedup_reset!(dedup)
                n_stab = 0
                aborted = false

                @inbounds for idx in 1:n_cycles
                    is_valid_state, temp_state = get_temp_state(idx, state₀)

                    if is_valid_state
                        _dedup_insert!(dedup, temp_state.value)

                        if isless(temp_state, state₀)
                            aborted = true
                            break
                        elseif temp_state == state₀
                            # Record the stabilizer element; its phase is only worth
                            # computing if the scan gets past every abort below.
                            n_stab += 1
                            stab[n_stab] = idx
                        end
                    end
                end

                aborted && continue

                local_F = F₀
                @inbounds for t in 1:n_stab
                    idx = stab[t]
                    local_F += sg.factors[idx] * get_phase(idx, state₀)
                end

                norm₀ = dedup.count * abs2(local_F)
                if norm₀ > eps_norm_type
                    push!(local_norms, norm₀)
                    push!(local_states, state₀)
                end
            end

            (local_states, local_norms)
        end
    end

    results = fetch.(tasks)
    states = isempty(results) ? BaseInt{T,Ti,B}[] : vcat((r[1] for r in results)...)
    norms = isempty(results) ? T_n[] : vcat((r[2] for r in results)...)

    # `all_bints` is scanned in ascending order (a range, or a pre-sorted candidate
    # vector) and chunk concatenation preserves that order, so the output is already
    # sorted and `is_sorted` needs no extra work.
    return Basis(states, norms, sg)
end

"""
    basis(
        dofo::DoFObject{B,T_s,T,Ti},
        N::Integer,
        sg::SymGroup{B,T_s,T,Ti,Ts};
        norm_type=Float64
    ) where {T,Ti,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}

Generates the symmetry-resolved basis for a DoF-object under the action of a symmetry group.

# Arguments
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object for which
    the basis is to be generated.
- `N::Integer`: The number of sites or particles.
- `sg::`[`SymBasis.SymGroups.SymGroup`](@ref)`{B,T_s,T,Ti,Ts}`: The symmetry group to be
    resolved.

# Keyword Arguments
- `norm_type::DataType=Float64`: The data type for the norms of the basis states. Default is
    `Float64`.
- `is_sorted::Bool=false`: Retained for backwards compatibility and has no effect: the
    states are enumerated in ascending order, so the returned basis is always sorted.

# Returns
- [`SymBasis.Bases.Basis`](@ref): The generated symmetry-resolved basis.
"""
function basis(
    dofo::DoFObject{B,T_s,T,Ti},
    N::Integer,
    sg::SymGroup{B,T_s,T,Ti,Ts};
    norm_type::DataType=Float64,
    is_sorted::Bool=false
) where {T,Ti,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}
    F₀ = zero(Complex{norm_type})
    eps_norm_type = eps(norm_type)
    c = true
    candidates = _candidate_states(sg.check, sg.cycles, BaseInt{T,Ti,B}, N)
    all_bints = candidates === nothing ?
                (BaseInt(T(0); base=B, Ti=Ti):BaseInt(T(B^N - 1); base=B, Ti=Ti)) :
                candidates

    # Kept separate from `get_temp_state` so `_basis_impl` can call it only for the cycles
    # that actually fix `state₀`; `sg.phase` is a pure function of `(cycle, state)`, so the
    # deferred call sees exactly the arguments the eager one did.
    get_phase = (idx, state₀) -> sg.phase(sg.cycles[idx], state₀)

    # Branching, rather than picking a closure with `?:`, keeps each call type-stable.
    if _candidates_satisfy_check(sg.apply, sg.cycles, candidates)
        return _basis_impl(
            all_bints, length(sg.cycles), sg, F₀, eps_norm_type,
            (idx, state₀) -> (true, sg.apply(sg.cycles[idx], state₀)),
            get_phase, is_sorted
        )
    end

    get_temp_state = (idx, state₀) -> begin
        cycleᵢ = sg.cycles[idx]
        temp_state = sg.apply(cycleᵢ, state₀)
        (sg.check(cycleᵢ, temp_state, c), temp_state)
    end

    return _basis_impl(
        all_bints,
        length(sg.cycles),
        sg,
        F₀,
        eps_norm_type,
        get_temp_state,
        get_phase,
        is_sorted
    )
end

"""
    basis(
        dofo::DoFObject{B,T_s,T,Ti},
        N::Integer,
        csg::CombSymGroup{B,T_s,T,Ti,Ts};
        norm_type::DataType=Float64,
        is_sorted::Bool=false
    ) where {T,Ti,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}

Generates the symmetry-resolved basis for a DoF-object under the action of a combined
    symmetry group.

# Arguments
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object for which
    the basis is to be generated.
- `N::Integer`: The number of sites or particles.
- `csg::`[`SymBasis.SymGroups.CombSymGroup`](@ref)`{B,T_s,T,Ti,Ts}`: The combined symmetry
    group to be resolved.

# Keyword Arguments
- `norm_type::DataType=Float64`: The data type for the norms of the basis states. Default is
    `Float64`.
- `is_sorted::Bool=false`: Retained for backwards compatibility and has no effect: the
    states are enumerated in ascending order, so the returned basis is always sorted.

# Returns
- [`SymBasis.Bases.Basis`](@ref): The generated symmetry-resolved basis.
"""
function basis(
    dofo::DoFObject{B,T_s,T,Ti},
    N::Integer,
    csg::CombSymGroup{B,T_s,T,Ti,Ts};
    norm_type::DataType=Float64,
    is_sorted::Bool=false
) where {T,Ti,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}
    F₀ = zero(Complex{norm_type})
    eps_norm_type = eps(norm_type)

    # Per-dimension distinct symmetry elements, recovered once from the cycle product.
    dim_elems = _dim_elements(csg.cycles)

    # Use the smallest directly-enumerable sector among the dimensions (if any); the
    # remaining dimensions' checks still run on every candidate, so any superset of the
    # valid states gives an identical basis.
    candidates = nothing
    cand_dim = 0
    for i in 1:ndims(csg.cycles)
        candᵢ = _candidate_states(csg.check[i], dim_elems[i], BaseInt{T,Ti,B}, N)
        if candᵢ !== nothing && (candidates === nothing || length(candᵢ) < length(candidates))
            candidates = candᵢ
            cand_dim = i
        end
    end
    all_bints = candidates === nothing ?
                (BaseInt(T(0); base=B, Ti=Ti):BaseInt(T(B^N - 1); base=B, Ti=Ti)) :
                candidates

    # `Val` so `_fill_valid!` can drop the skipped dimension's loop at compile time.
    skip_dim = (cand_dim != 0 && _candidates_satisfy_check(
        csg.apply[cand_dim], dim_elems[cand_dim], candidates)) ? cand_dim : 0

    return _basis_impl_csg(
        all_bints, csg, dim_elems, F₀, eps_norm_type, Val(skip_dim)
    )
end

"""
    is_commutative(b::Basis, csg::CombSymGroup)

Checks whether the given symmetries commute with each other in the given basis.

# Arguments
- `b::`[`SymBasis.Bases.Basis`](@ref): The basis to be checked.
- `csg::`[`SymBasis.SymGroups.CombSymGroup`](@ref): The combined symmetry group under which
    the basis states are expected to be consistent.

# Returns
- `Bool`: Returns `true` if the basis states are consistent under the action of the combined
    symmetry group, and `false` otherwise.
"""
function is_commutative(b::Basis, csg::CombSymGroup)
    if b.sg != csg
        @warn "The symmetry group of the basis does not match the provided combined symmetry group."
    end

    ndims_cycles = csg.cycles |> ndims
    nthreads = Threads.nthreads()

    # Distinct elements per dimension: the flattened cycle product repeats each
    # (element i, element j) pair many times, and only the pair matters here.
    dim_elems = _dim_elements(csg.cycles)
    state_indices = eachindex(b.states)
    chunk_len = _chunk_length(
        length(state_indices), ndims_cycles * (ndims_cycles - 1) ÷ 2, nthreads)

    tasks = map(Iterators.partition(state_indices, chunk_len)) do chunk
        Threads.@spawn begin
            ok = true
            for i in 1:ndims_cycles, j in (i+1):ndims_cycles
                # Function barrier: resolve the per-dimension functions and element
                # vectors once per dimension pair instead of on every inner iteration
                # (indexing a heterogeneous tuple with a runtime index is type-unstable).
                ok = _commutes_pair(
                    b.states, chunk, csg,
                    csg.apply[i], csg.phase[i], dim_elems[i],
                    csg.apply[j], csg.phase[j], dim_elems[j]
                )
                ok || break
            end
            ok
        end
    end

    # Fetch results from all tasks - all must be true
    results = fetch.(tasks)
    return all(results)
end

function _commutes_pair(
    states, chunk, csg,
    applyᵢ::Fa, phaseᵢ::Fp, elemsᵢ,
    applyⱼ::Ga, phaseⱼ::Gp, elemsⱼ
) where {Fa,Fp,Ga,Gp}
    @inbounds for s_idx in chunk
        test_state = states[s_idx]
        for eᵢ in elemsᵢ, eⱼ in elemsⱼ
            # Apply symmetry i then j
            phase_i = phaseᵢ(eᵢ, test_state)
            state_ij = applyᵢ(eᵢ, test_state)
            phase_j = phaseⱼ(eⱼ, state_ij)
            state_ij = applyⱼ(eⱼ, state_ij)
            state_ij, factor_ij = representative(state_ij, csg)
            factor_ij *= phase_i * phase_j

            # Apply symmetry j then i
            phase_j = phaseⱼ(eⱼ, test_state)
            state_ji = applyⱼ(eⱼ, test_state)
            phase_i = phaseᵢ(eᵢ, state_ji)
            state_ji = applyᵢ(eᵢ, state_ji)
            state_ji, factor_ji = representative(state_ji, csg)
            factor_ji *= phase_i * phase_j

            if state_ij != state_ji || !(factor_ij ≈ factor_ji)
                return false
            end
        end
    end
    return true
end

"""
    is_commutative(b::Basis)

Checks whether the symmetries in the basis commute with each other.

# Arguments
- `b::`[`SymBasis.Bases.Basis`](@ref): The basis to be checked.

# Returns
- `Bool`: Returns `true` if the symmetries in the basis commute with each other, and `false`
otherwise.
"""
function is_commutative(b::Basis)
    return is_commutative(b, b.sg)
end

"""
    representative(
        state::SymBasis.DigitBase.BaseInt{T,Ti,B},
        sg::SymGroup{B,T_s,T,Ti,Ts}
    ) where {T,Ti,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}

Finds the representative state and corresponding factor for a given state under the action
of a symmetry group.

# Arguments
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state for which the
    representative is to be found.
- `sg::`[`SymBasis.SymGroups.SymGroup`](@ref)`{B,T_s,T,Ti,Ts}`: The symmetry group.

# Returns
- `rep_state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The representative state.
- `rep_fac::Ts`: The corresponding factor associated with the representative state.
"""
function representative(
    state::BaseInt{T,Ti,B},
    sg::SymGroup{B,T_s,T,Ti,Ts}
) where {T,Ti,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}
    n_cycles = length(sg.cycles)

    id_rep_state = first(eachindex(sg.cycles))
    rep_state = sg.apply(sg.cycles[id_rep_state], state)

    @inbounds for idx in 2:n_cycles
        temp_state = sg.apply(sg.cycles[idx], state)

        if isless(temp_state, rep_state)
            id_rep_state = idx
            rep_state = temp_state
        end
    end

    # Only the winning cycle's phase survives, so it is evaluated once here instead of once
    # per cycle above. `sg.phase` is a pure function of `(cycle, state)` and the comparison
    # stays strict, so the same cycle wins and the factor is unchanged.
    rep_phase = sg.phase(sg.cycles[id_rep_state], state)
    rep_fac = rep_phase * sg.factors[id_rep_state]

    return rep_state, rep_fac
end

"""
    representative(
        state::SymBasis.DigitBase.BaseInt{T,Ti,B},
        csg::CombSymGroup{B,T_s,T,Ti,Ts}
    ) where {T,Ti,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}

Finds the representative state and corresponding factor for a given state under the action
of a combined symmetry group.

# Arguments
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state for which the
    representative is to be found.
- `csg::`[`SymBasis.SymGroups.CombSymGroup`](@ref)`{B,T_s,T,Ti,Ts}`: The combined symmetry
    group.

# Returns
- `rep_state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The representative state.
- `rep_fac::Ts`: The corresponding factor associated with the representative state.
"""
function representative(
    state::BaseInt{T,Ti,B},
    csg::CombSymGroup{B,T_s,T,Ti,Ts}
) where {T,Ti,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}
    n_cycles = length(csg.cycles)

    # Flat scan over the cycle product: unlike `basis`, this is called once per state
    # (e.g. per Hamiltonian matrix element), so there is nothing to amortize the setup of
    # a per-dimension nested scan against.
    rep_state = _apply_all(csg.apply, csg.cycles[1], state)
    id_rep_state = 1

    @inbounds for idx in 2:n_cycles
        temp_state = _apply_all(csg.apply, csg.cycles[idx], state)

        if isless(temp_state, rep_state)
            id_rep_state = idx
            rep_state = temp_state
        end
    end

    # As in the `SymGroup` method: scan with `apply` alone, then pay for the phase chain
    # once, for the cycle that actually won.
    _, rep_phase = @inbounds _apply_phase_all(
        csg.apply, csg.phase, csg.cycles[id_rep_state], state, one(Ts)
    )
    rep_fac = rep_phase * csg.factors[id_rep_state]

    return rep_state, rep_fac
end

"""
    representative(
        state::BaseInt{T,Ti,B},
        basis::Basis{BaseInt{T,Ti,B},T_n}
    ) where {T,Ti,B,T_n}

Finds the representative state and corresponding factor for a given state under the action
of the symmetry group associated with the provided basis.

# Arguments
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state for which the
    representative is to be found.
- `basis::`[`SymBasis.Bases.Basis`](@ref)`{BaseInt{T,Ti,B},T_n}`: The basis containing the
    symmetry group.

# Returns
- `rep_state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The representative state.
- `rep_fac`: The corresponding factor associated with the representative state.
"""
function representative(
    state::BaseInt{T,Ti,B}, basis::Basis{BaseInt{T,Ti,B},T_n}
) where {T,Ti,B,T_n}
    if basis.sg isa Nothing
        return state
    else
        return representative(state, basis.sg)
    end
end
