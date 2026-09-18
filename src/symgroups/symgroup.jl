using SymBasis.DoFObjects: DoFObject

# The parameters `B`, `T_s`, `T`, `Ti` and `T_f` are user-facing. `T_c`, `F_c`, `F_a`,
# `F_p` and `T_fs` are storage-only: they keep the field types concrete and are inferred.
"""
    SymGroup{B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
    SymGroup(
        dofo::DoFObject{B,T_s,T,Ti},
        cycles::AbstractVector{<:NamedTuple},
        check::Function,
        apply::Function,
        phase::Function,
        factors::AbstractVector{T_f},
        N::Integer
    ) where {B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}

A symmetry group acting on a DoF-object. The symmetry group is defined by its associated
DoF-object, a set of cycles representing the symmetry operations, functions to check and
apply these operations, and factors associated with each symmetry cycle.

# Type parameters
- `B`: The base (local Hilbert-space dimension) of the DoF-object.
- `T_s`: The type of the local degrees of freedom (spin-like quantum numbers) of the
    DoF-object.
- `T<:Integer`: The integer storage type of the encoded states.
- `Ti<:Integer`: The integer type used for site indices.
- `T_f<:Number`: The element type of `factors`.
- `T_c`, `F_c`, `F_a`, `F_p`, `T_fs`: The concrete types of the `cycles`, `check`, `apply`,
    `phase` and `factors` fields. They exist only to keep the field types concrete, so that
    field access is inferable and code using a `SymGroup` is specialized. They are inferred
    by the constructor and are not meant to be chosen by users.

# Constructor Arguments
Each argument is stored in the field of the same name. The fields `cycles`, `check`,
`apply`, `phase` and `factors` are stored with the concrete types `T_c`, `F_c`, `F_a`,
`F_p` and `T_fs` (see Type parameters), and `N` is stored as an `Int`.

- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object on which the
    symmetry group acts.
- `cycles::AbstractVector{<:NamedTuple}`: A vector of named tuples representing the symmetry
    cycles.
- `check::Function`: A function to check the validity of symmetry operations.
- `apply::Function`: A function to apply the symmetry operations.
- `phase::Function`: A function to compute the phase of symmetry operations.
- `factors::AbstractVector{T_f}`: A vector of factors associated with each symmetry cycle.
- `N::Integer`: The number of sites. Used to check the validity of the symmetry operations.

# Returns
- `SymGroup{B,T_s,T,Ti,T_f}`: A new `SymGroup` instance initialized with the provided
    parameters.

The constructor checks that the number of cycles matches the number of factors to ensure
consistency.
"""
struct SymGroup{
    B,T_s,T<:Integer,Ti<:Integer,T_f<:Number,
    T_c<:AbstractVector{<:NamedTuple},
    F_c<:Function,F_a<:Function,F_p<:Function,
    T_fs<:AbstractVector{T_f},
}
    dofo::DoFObject{B,T_s,T,Ti}
    cycles::T_c
    check::F_c
    apply::F_a
    phase::F_p
    factors::T_fs
    N::Int

    function SymGroup(
        dofo::DoFObject{B,T_s,T,Ti},
        cycles::AbstractVector{<:NamedTuple},
        check::Function,
        apply::Function,
        phase::Function,
        factors::AbstractVector{T_f},
        N::Integer,
    ) where {B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
        length(cycles) == length(factors) ||
            throw(
                ArgumentError(
                    "cycles and factors must have the same length, got $(length(cycles)) and $(length(factors))"
                ),
            )
        return new{
            B,T_s,T,Ti,T_f,
            typeof(cycles),typeof(check),typeof(apply),typeof(phase),typeof(factors),
        }(
            dofo, cycles, check, apply, phase, factors, Int(N)
        )
    end
end

function SymGroup(
    dofo::DoFObject{B,T_s,T,Ti},
    cycles::AbstractVector{<:NamedTuple},
    check::Function,
    apply::Function,
    factors::AbstractVector{T_f},
    N::Integer,
) where {B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
    return SymGroup(dofo, cycles, check, apply, phase_unity, factors, N)
end

# The parameters `B`, `T_s`, `T`, `Ti` and `T_f` are user-facing. `T_c`, `F_c`, `F_a`,
# `F_p` and `T_fs` are storage-only: they keep the field types concrete and are inferred.
"""
    CombSymGroup{B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
    CombSymGroup(
        dofo::DoFObject{B,T_s,T,Ti},
        cycles::AbstractArray{<:Tuple{Vararg{NamedTuple}}},
        check::Tuple{Vararg{Function}},
        apply::Tuple{Vararg{Function}},
        phase::Tuple{Vararg{Function}},
        factors::AbstractArray{T_f},
        N::Integer
    ) where {B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}

A combined symmetry group formed by the composition of multiple symmetry groups acting on
the same DoF-object. This structure allows for the representation of more complex symmetry
operations by combining simpler ones.

Internally the per-dimension data is stored as tuples (each cycle is a `Tuple` of named
tuples, and `check`/`apply`/`phase` are `Tuple`s of functions) so that the per-dimension
types stay known to the compiler in the hot loops. The constructor also accepts the legacy
layout (array of vectors of named tuples, and vectors of functions) and converts it.

# Type parameters
- `B`: The base (local Hilbert-space dimension) of the DoF-object.
- `T_s`: The type of the local degrees of freedom (spin-like quantum numbers) of the
    DoF-object.
- `T<:Integer`: The integer storage type of the encoded states.
- `Ti<:Integer`: The integer type used for site indices.
- `T_f<:Number`: The element type of `factors`.
- `T_c`, `F_c`, `F_a`, `F_p`, `T_fs`: The concrete types of the `cycles`, `check`, `apply`,
    `phase` and `factors` fields. They exist only to keep the field types concrete, so that
    field access is inferable and the per-dimension tuple types are known to the compiler.
    They are inferred by the constructor and are not meant to be chosen by users.

# Constructor Arguments
Each argument is stored in the field of the same name. The fields `cycles`, `check`,
`apply`, `phase` and `factors` are stored with the concrete types `T_c`, `F_c`, `F_a`,
`F_p` and `T_fs` (see Type parameters), and `N` is stored as an `Int`.

- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object on which the
    combined symmetry group acts.
- `cycles::AbstractArray{<:Tuple{Vararg{NamedTuple}}}`: An array of tuples of named
    tuples representing the combined symmetry cycles.
- `check::Tuple{Vararg{Function}}`: A tuple of functions to check the validity of each
    set of symmetry operations.
- `apply::Tuple{Vararg{Function}}`: A tuple of functions to apply each set of symmetry
    operations.
- `phase::Tuple{Vararg{Function}}`: A tuple of functions to compute phase factors for
    each set of symmetry operations.
- `factors::AbstractArray{T_f}`: An array of factors associated with each combined symmetry
    cycle.
- `N::Integer`: The number of sites. Used to check the validity of the symmetry operations.

A legacy outer constructor also accepts the array-of-vectors/vector-of-functions layout
(`cycles::AbstractArray{<:AbstractVector{<:NamedTuple}}`,
`check/apply/phase::AbstractVector{<:Function}`) and converts it to the tuple-based layout
above.

# Returns
- `CombSymGroup{B,T_s,T,Ti,T_f}`: A new `CombSymGroup` instance initialized with the
    provided parameters.

The constructor checks that the size of cycles matches the size of factors and that the
number of dimensions matches the number of check and apply functions to ensure consistency.
"""
struct CombSymGroup{
    B,T_s,T<:Integer,Ti<:Integer,T_f<:Number,
    T_c<:AbstractArray{<:Tuple{Vararg{NamedTuple}}},
    F_c<:Tuple{Vararg{Function}},
    F_a<:Tuple{Vararg{Function}},
    F_p<:Tuple{Vararg{Function}},
    T_fs<:AbstractArray{T_f},
}
    dofo::DoFObject{B,T_s,T,Ti}
    cycles::T_c
    check::F_c
    apply::F_a
    phase::F_p
    factors::T_fs
    N::Int
    function CombSymGroup(
        dofo::DoFObject{B,T_s,T,Ti},
        cycles::AbstractArray{<:Tuple{Vararg{NamedTuple}}},
        check::Tuple{Vararg{Function}},
        apply::Tuple{Vararg{Function}},
        phase::Tuple{Vararg{Function}},
        factors::AbstractArray{T_f},
        N::Integer,
    ) where {B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
        size(cycles) == size(factors) ||
            throw(
                ArgumentError(
                    "cycles and factors must have the same size, got $(size(cycles)) and $(size(factors))"
                ),
            )
        ndims(cycles) == length(check) ||
            throw(
                ArgumentError(
                    "length of check ($(length(check))) must equal ndims(cycles) ($(ndims(cycles)))"
                ),
            )
        ndims(cycles) == length(apply) ||
            throw(
                ArgumentError(
                    "length of apply ($(length(apply))) must equal ndims(cycles) ($(ndims(cycles)))"
                ),
            )
        ndims(cycles) == length(phase) ||
            throw(
                ArgumentError(
                    "length of phase ($(length(phase))) must equal ndims(cycles) ($(ndims(cycles)))"
                ),
            )
        return new{
            B,T_s,T,Ti,T_f,
            typeof(cycles),typeof(check),typeof(apply),typeof(phase),typeof(factors),
        }(
            dofo, cycles, check, apply, phase, factors, Int(N)
        )
    end
end

# Legacy layout: cycles as an array of vectors of NamedTuples, and check/apply/phase as
# vectors of functions. Converted to the tuple-based layout, which keeps the per-dimension
# types known to the compiler.
function CombSymGroup(
    dofo::DoFObject{B,T_s,T,Ti},
    cycles::AbstractArray{<:AbstractVector{<:NamedTuple}},
    check::Union{AbstractVector{<:Function},Tuple{Vararg{Function}}},
    apply::Union{AbstractVector{<:Function},Tuple{Vararg{Function}}},
    phase::Union{AbstractVector{<:Function},Tuple{Vararg{Function}}},
    factors::AbstractArray{T_f},
    N::Integer,
) where {B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
    return CombSymGroup(
        dofo, map(c -> (c...,), cycles), (check...,), (apply...,), (phase...,), factors, N
    )
end

function CombSymGroup(
    dofo::DoFObject{B,T_s,T,Ti},
    cycles::AbstractArray{<:Tuple{Vararg{NamedTuple}}},
    check::Union{AbstractVector{<:Function},Tuple{Vararg{Function}}},
    apply::Union{AbstractVector{<:Function},Tuple{Vararg{Function}}},
    phase::Union{AbstractVector{<:Function},Tuple{Vararg{Function}}},
    factors::AbstractArray{T_f},
    N::Integer,
) where {B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
    return CombSymGroup(dofo, cycles, (check...,), (apply...,), (phase...,), factors, N)
end

function CombSymGroup(
    dofo::DoFObject{B,T_s,T,Ti},
    cycles::AbstractArray{<:Union{AbstractVector{<:NamedTuple},Tuple{Vararg{NamedTuple}}}},
    check::Union{AbstractVector{<:Function},Tuple{Vararg{Function}}},
    apply::Union{AbstractVector{<:Function},Tuple{Vararg{Function}}},
    factors::AbstractArray{T_f},
    N::Integer,
) where {B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
    return CombSymGroup(
        dofo,
        cycles,
        check,
        apply,
        ntuple(_ -> phase_unity, length(apply)),
        factors,
        N,
    )
end

# Apply every dimension's element without computing any phase. Used by `representative`,
# which discards the phase of all but the winning cycle, so evaluating it during the scan
# is pure waste — for fermionic groups it was ~90% of the call.
@inline _apply_all(applys::Tuple{}, cycle::Tuple{}, state) = state
@inline function _apply_all(applys::Tuple, cycle::Tuple, state)
    return _apply_all(
        Base.tail(applys),
        Base.tail(cycle),
        first(applys)(first(cycle), state),
    )
end

@inline _apply_phase_all(applys::Tuple{}, phases::Tuple{}, cycle::Tuple{}, state, ph) =
    (state, ph)
@inline function _apply_phase_all(applys::Tuple, phases::Tuple, cycle::Tuple, state, ph)
    phᵢ = first(phases)(first(cycle), state)
    new_state = first(applys)(first(cycle), state)
    return _apply_phase_all(
        Base.tail(applys),
        Base.tail(phases),
        Base.tail(cycle),
        new_state,
        ph * phᵢ,
    )
end

function _cycles_preview(cycles; maxitems::Int=4)
    n = length(cycles)
    if n == 0
        return "∅"
    end
    parts = String[]
    for (k, c) in enumerate(cycles)
        k > maxitems && break
        # keep it robust: don't assume specific NamedTuple keys
        push!(parts, sprint(show, MIME"text/plain"(), c))
    end
    tail = n > maxitems ? ", …" : ""
    return join(parts, ", ") * tail
end

function _print_kv(io::IO, key::AbstractString, val; indent::Int=2)
    print(io, ' '^indent, rpad(key, 15), val, '\n')
    return nothing
end

function Base.summary(g::SymGroup{B,T_s,T,Ti,T_f}) where {B,T_s,T,Ti,T_f}
    "SymGroup{$(B),$(T_s),$(T),$(Ti),$(T_f)} with $(length(g.cycles)) cycle(s)"
end

function Base.show(io::IO, g::SymGroup)
    # compact (used e.g. in arrays)
    if get(io, :compact, false)
        print(io, summary(g))
        return nothing
    end

    println(io, summary(g))
    _print_kv(io, "N:", g.N)
    _print_kv(io, "DoF-object:", summary(g.dofo))
    _print_kv(io, "cycles:", _cycles_preview(g.cycles))
    _print_kv(
        io,
        "factors:",
        "$(length(g.factors)) element(s), eltype=$(eltype(g.factors))",
    )
    _print_kv(io, "check:", string(nameof(g.check)))
    _print_kv(io, "apply:", string(nameof(g.apply)))
    _print_kv(io, "phase:", string(nameof(g.phase)))

    return nothing
end

function Base.show(io::IO, ::MIME"text/plain", g::SymGroup)
    show(io, g)
    return nothing
end

function Base.summary(g::CombSymGroup{B,T_s,T,Ti,T_f}) where {B,T_s,T,Ti,T_f}
    "CombSymGroup{$(B),$(T_s),$(T),$(Ti),$(T_f)} " *
    "with size of cycles = $(size(g.cycles))"
end

function Base.show(io::IO, g::CombSymGroup)
    if get(io, :compact, false)
        print(io, summary(g))
        return nothing
    end

    println(io, summary(g))
    _print_kv(io, "N:", g.N)
    _print_kv(io, "DoF-object:", summary(g.dofo))
    _print_kv(io, "cycles:", "array of tuples; eltype=$(eltype(g.cycles))")
    _print_kv(io, "factors:", "size=$(size(g.factors)), eltype=$(eltype(g.factors))")
    _print_kv(io, "check:", "$(length(g.check)) function(s)")
    _print_kv(io, "apply:", "$(length(g.apply)) function(s)")
    _print_kv(io, "phase:", "$(length(g.phase)) function(s)")

    # Show a small preview of a representative entry if possible
    if length(g.cycles) > 0
        I = first(eachindex(g.cycles))
        cycI = g.cycles[I]
        facI = g.factors[I]
        _print_kv(io, "preview @[$(I)]:", "factor=$(facI)")
        _print_kv(io, "", "cycle=" * _cycles_preview(cycI))
    end

    return nothing
end

function Base.show(io::IO, ::MIME"text/plain", g::CombSymGroup)
    show(io, g)
    return nothing
end

# Per-dimension data of a `SymGroup`/`CombSymGroup`, normalized to the tuple-per-dimension
# shape `∘` composes: a `SymGroup`'s single cycle/check/apply/phase becomes a 1-tuple, so
# `_compose` below can concatenate either operand identically instead of each `∘` method
# hand-flattening its own combination of plain values and tuples.
function _normalize(sg::SymGroup)
    (map(c -> (c,), sg.cycles), (sg.check,), (sg.apply,), (sg.phase,), sg.factors)
end
_normalize(csg::CombSymGroup) = (csg.cycles, csg.check, csg.apply, csg.phase, csg.factors)

# Shared composition core for all four `∘` methods below: concatenate the normalized
# per-dimension tuples and take the outer product of cycles and factors.
function _compose(a::Union{SymGroup,CombSymGroup}, b::Union{SymGroup,CombSymGroup}, dofo, N)
    cyclesₐ, checkₐ, applyₐ, phaseₐ, factorsₐ = _normalize(a)
    cyclesᵦ, checkᵦ, applyᵦ, phaseᵦ, factorsᵦ = _normalize(b)
    return CombSymGroup(
        dofo,
        map(x -> (x[1]..., x[2]...), Base.product(cyclesₐ, cyclesᵦ)),
        (checkₐ..., checkᵦ...),
        (applyₐ..., applyᵦ...),
        (phaseₐ..., phaseᵦ...),
        map(x -> *(x...), Base.product(factorsₐ, factorsᵦ)),
        N,
    )
end

"""
    ∘(
        sg1::SymGroup{B,T_s,T,Ti,<:T_f},
        sg2::SymGroup{B,T_s,T,Ti,<:T_f}
    ) where {B,T_s,T,Ti,T_f<:Number}

Composition of two symmetry groups acting on the same DoF-object. The resulting symmetry
group combines the cycles, check functions, apply functions, and factors of the input
symmetry groups.

# Arguments
- `sg1::`[`SymBasis.SymGroups.SymGroup`](@ref)`{B,T_s,T,Ti,<:T_f}`: The first symmetry
    group.
- `sg2::`[`SymBasis.SymGroups.SymGroup`](@ref)`{B,T_s,T,Ti,<:T_f}`: The second symmetry
    group.

# Returns
- [`SymBasis.SymGroups.CombSymGroup`](@ref)`{B,T_s,T,Ti,T_f}`: The combined symmetry group.
"""
function Base.:(∘)(
    sg1::SymGroup{B,T_s,T,Ti,<:T_f},
    sg2::SymGroup{B,T_s,T,Ti,<:T_f},
) where {B,T_s,T,Ti,T_f<:Number}
    sg1.dofo == sg2.dofo || throw(
        ArgumentError("cannot compose symmetry groups acting on different DoF-objects")
    )
    sg1.N == sg2.N || throw(
        ArgumentError(
            "cannot compose symmetry groups with different N: $(sg1.N) vs $(sg2.N)"
        ),
    )
    return _compose(sg1, sg2, sg1.dofo, sg1.N)
end

"""
    ∘(
        csg::CombSymGroup{B,T_s,T,Ti,<:T_f},
        sg::SymGroup{B,T_s,T,Ti,<:T_f}
    ) where {B,T_s,T,Ti,T_f<:Number}

Composition of a combined symmetry group with a symmetry group acting on the same
DoF-object. The resulting symmetry group combines the cycles, check functions, apply
functions, and factors of the input symmetry groups.

# Arguments
- `csg::`[`SymBasis.SymGroups.CombSymGroup`](@ref)`{B,T_s,T,Ti,T_f}`: The combined symmetry
    group.
- `sg::`[`SymBasis.SymGroups.SymGroup`](@ref)`{B,T_s,T,Ti,T_f}`: The symmetry group.

# Returns
- [`SymBasis.SymGroups.CombSymGroup`](@ref)`{B,T_s,T,Ti,T_f}`: The combined symmetry group.
"""
function Base.:(∘)(
    csg::CombSymGroup{B,T_s,T,Ti,<:T_f},
    sg::SymGroup{B,T_s,T,Ti,<:T_f},
) where {B,T_s,T,Ti,T_f<:Number}
    csg.dofo == sg.dofo || throw(
        ArgumentError("cannot compose symmetry groups acting on different DoF-objects")
    )
    csg.N == sg.N || throw(
        ArgumentError(
            "cannot compose symmetry groups with different N: $(csg.N) vs $(sg.N)"
        ),
    )
    return _compose(csg, sg, csg.dofo, csg.N)
end

"""
    ∘(
        csg::SymGroup{B,T_s,T,Ti,<:T_f},
        sg::CombSymGroup{B,T_s,T,Ti,<:T_f}
    ) where {B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}

Composition of a combined symmetry group with a symmetry group acting on the same
DoF-object. The resulting symmetry group combines the cycles, check functions, apply
functions, and factors of the input symmetry groups.

# Arguments
- `csg::`[`SymBasis.SymGroups.SymGroup`](@ref)`{B,T_s,T,Ti,<:T_f}`: The symmetry group.
- `sg::`[`SymBasis.SymGroups.CombSymGroup`](@ref)`{B,T_s,T,Ti,<:T_f}`: The combined symmetry
    group.

# Returns
- [`SymBasis.SymGroups.CombSymGroup`](@ref)`{B,T_s,T,Ti,T_f}`: The combined symmetry group.
"""
function Base.:(∘)(
    sg::SymGroup{B,T_s,T,Ti,<:T_f},
    csg::CombSymGroup{B,T_s,T,Ti,<:T_f},
) where {B,T_s,T,Ti,T_f<:Number}
    csg.dofo == sg.dofo || throw(
        ArgumentError("cannot compose symmetry groups acting on different DoF-objects")
    )
    csg.N == sg.N || throw(
        ArgumentError(
            "cannot compose symmetry groups with different N: $(csg.N) vs $(sg.N)"
        ),
    )
    return _compose(sg, csg, csg.dofo, csg.N)
end

"""
    ∘(
        csg1::CombSymGroup{B,T_s,T,Ti,<:T_f},
        csg2::CombSymGroup{B,T_s,T,Ti,<:T_f}
    ) where {B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}

Composition of two combined symmetry groups acting on the same DoF-object. The resulting
symmetry group combines the cycles, check functions, apply functions, and factors of the
input symmetry groups.

# Arguments
- `csg1::`[`SymBasis.SymGroups.CombSymGroup`](@ref)`{B,T_s,T,Ti,<:T_f}`: The first combined
    symmetry group.
- `csg2::`[`SymBasis.SymGroups.CombSymGroup`](@ref)`{B,T_s,T,Ti,<:T_f}`: The second combined
    symmetry group.

# Returns
- [`SymBasis.SymGroups.CombSymGroup`](@ref)`{B,T_s,T,Ti,T_f}`: The combined symmetry group.
"""
function Base.:(∘)(
    csg1::CombSymGroup{B,T_s,T,Ti,<:T_f},
    csg2::CombSymGroup{B,T_s,T,Ti,<:T_f},
) where {B,T_s,T,Ti,T_f<:Number}
    csg1.dofo == csg2.dofo || throw(
        ArgumentError("cannot compose symmetry groups acting on different DoF-objects")
    )
    csg1.N == csg2.N || throw(
        ArgumentError(
            "cannot compose symmetry groups with different N: $(csg1.N) vs $(csg2.N)"
        ),
    )
    return _compose(csg1, csg2, csg1.dofo, csg1.N)
end
