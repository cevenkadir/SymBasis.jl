using SymBasis.DoFObjects: DoFObject

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

# Fields
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object on which the
    symmetry group acts.
- `cycles::AbstractVector{<:NamedTuple}`: A vector of named tuples representing the symmetry
    cycles.
- `check::Function`: A function to check the validity of symmetry operations.
- `apply::Function`: A function to apply the symmetry operations.
- `phase::Function`: A function to compute the phase of symmetry operations.
- `factors::AbstractVector{T_f}`: A vector of factors associated with each symmetry cycle.
- `N::Int`: The total number of the DoF-objects in the system. This is used to check
    the validity of the symmetry operations.

# Constructor Arguments
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object on which the
    symmetry group acts.
- `cycles::AbstractVector{<:NamedTuple}`: A vector of named tuples representing the symmetry
    cycles.
- `check::Function`: A function to check the validity of symmetry operations.
- `apply::Function`: A function to apply the symmetry operations.
- `phase::Function`: A function to compute the phase of symmetry operations.
- `factors::AbstractVector{T_f}`: A vector of factors associated with each symmetry cycle.
- `N::Integer`: The total number of the DoF-objects in the system. This is used to check the
    validity of the symmetry operations.

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
    T_fs<:AbstractVector{T_f}
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
        N::Integer
    ) where {B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
        @assert length(cycles) == length(factors)
        return new{
            B,T_s,T,Ti,T_f,
            typeof(cycles),typeof(check),typeof(apply),typeof(phase),typeof(factors)
        }(dofo, cycles, check, apply, phase, factors, Int(N))
    end
end

function SymGroup(
    dofo::DoFObject{B,T_s,T,Ti},
    cycles::AbstractVector{<:NamedTuple},
    check::Function,
    apply::Function,
    factors::AbstractVector{T_f},
    N::Integer
) where {B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
    return SymGroup(dofo, cycles, check, apply, phase_unity, factors, N)
end

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

# Fields
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
- `N::Int`: The total number of the DoF-objects in the system. This is used to check
    the validity of the symmetry operations.

# Constructor Arguments
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
- `N::Integer`: The total number of the DoF-objects in the system. This is used to check the
    validity of the symmetry operations.

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
    T_fs<:AbstractArray{T_f}
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
        N::Integer
    ) where {B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
        @assert size(cycles) == size(factors)
        @assert ndims(cycles) == length(check)
        @assert ndims(cycles) == length(apply)
        @assert ndims(cycles) == length(phase)
        return new{
            B,T_s,T,Ti,T_f,
            typeof(cycles),typeof(check),typeof(apply),typeof(phase),typeof(factors)
        }(dofo, cycles, check, apply, phase, factors, Int(N))
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
    N::Integer
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
    N::Integer
) where {B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
    return CombSymGroup(dofo, cycles, (check...,), (apply...,), (phase...,), factors, N)
end

function CombSymGroup(
    dofo::DoFObject{B,T_s,T,Ti},
    cycles::AbstractArray{<:Union{AbstractVector{<:NamedTuple},Tuple{Vararg{NamedTuple}}}},
    check::Union{AbstractVector{<:Function},Tuple{Vararg{Function}}},
    apply::Union{AbstractVector{<:Function},Tuple{Vararg{Function}}},
    factors::AbstractArray{T_f},
    N::Integer
) where {B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
    return CombSymGroup(
        dofo,
        cycles,
        check,
        apply,
        ntuple(_ -> phase_unity, length(apply)),
        factors,
        N
    )
end

# Recursive traversal of the per-dimension function tuples of a CombSymGroup, so each
# call site is resolved at compile time (a runtime index into a heterogeneous tuple would
# be type-unstable in the hot loop).
@inline _check_all(checks::Tuple{}, cycle::Tuple{}, state, ok::Bool) = ok
@inline function _check_all(checks::Tuple, cycle::Tuple, state, ok::Bool)
    ok || return false
    return _check_all(
        Base.tail(checks),
        Base.tail(cycle),
        state,
        first(checks)(first(cycle), state, ok)
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
        ph * phᵢ
    )
end

_cycles_preview(cycles; maxitems::Int=4) = begin
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
end

Base.summary(g::SymGroup{B,T_s,T,Ti,T_f}) where {B,T_s,T,Ti,T_f} =
    "SymGroup{$(B),$(T_s),$(T),$(Ti),$(T_f)} with $(length(g.cycles)) cycle(s)"

function Base.show(io::IO, g::SymGroup)
    # compact (used e.g. in arrays)
    if get(io, :compact, false)
        print(io, summary(g))
        return
    end

    println(io, summary(g))
    _print_kv(io, "N:", g.N)
    _print_kv(io, "DoF-object:", summary(g.dofo))
    _print_kv(io, "cycles:", _cycles_preview(g.cycles))
    _print_kv(
        io,
        "factors:",
        "$(length(g.factors)) element(s), eltype=$(eltype(g.factors))"
    )
    _print_kv(io, "check:", string(nameof(g.check)))
    _print_kv(io, "apply:", string(nameof(g.apply)))
    _print_kv(io, "phase:", string(nameof(g.phase)))
end

function Base.show(io::IO, ::MIME"text/plain", g::SymGroup)
    show(io, g)
end

Base.summary(g::CombSymGroup{B,T_s,T,Ti,T_f}) where {B,T_s,T,Ti,T_f} =
    "CombSymGroup{$(B),$(T_s),$(T),$(Ti),$(T_f)} " *
    "with size of cycles = $(size(g.cycles))"

function Base.show(io::IO, g::CombSymGroup)
    if get(io, :compact, false)
        print(io, summary(g))
        return
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
end

function Base.show(io::IO, ::MIME"text/plain", g::CombSymGroup)
    show(io, g)
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
    sg2::SymGroup{B,T_s,T,Ti,<:T_f}
) where {B,T_s,T,Ti,T_f<:Number}
    @assert sg1.dofo == sg2.dofo
    @assert sg1.N == sg2.N
    return CombSymGroup(
        sg1.dofo,
        collect(Base.product(sg1.cycles, sg2.cycles)),
        (sg1.check, sg2.check),
        (sg1.apply, sg2.apply),
        (sg1.phase, sg2.phase),
        map(x -> *(x...), Base.product(sg1.factors, sg2.factors)),
        sg1.N
    )
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
    sg::SymGroup{B,T_s,T,Ti,<:T_f}
) where {B,T_s,T,Ti,T_f<:Number}
    @assert csg.dofo == sg.dofo
    @assert csg.N == sg.N
    return CombSymGroup(
        csg.dofo,
        map(x -> (x[1]..., x[2]), Base.product(csg.cycles, sg.cycles)),
        (csg.check..., sg.check),
        (csg.apply..., sg.apply),
        (csg.phase..., sg.phase),
        map(x -> *(x...), Base.product(csg.factors, sg.factors)),
        csg.N
    )
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
    csg::CombSymGroup{B,T_s,T,Ti,<:T_f}
) where {B,T_s,T,Ti,T_f<:Number}
    @assert csg.dofo == sg.dofo
    @assert csg.N == sg.N
    return CombSymGroup(
        csg.dofo,
        map(x -> (x[1], x[2]...), Base.product(sg.cycles, csg.cycles)),
        (sg.check, csg.check...),
        (sg.apply, csg.apply...),
        (sg.phase, csg.phase...),
        map(x -> *(x...), Base.product(sg.factors, csg.factors)),
        csg.N
    )
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
    csg2::CombSymGroup{B,T_s,T,Ti,<:T_f}
) where {B,T_s,T,Ti,T_f<:Number}
    @assert csg1.dofo == csg2.dofo
    @assert csg1.N == csg2.N
    return CombSymGroup(
        csg1.dofo,
        map(x -> (x[1]..., x[2]...), Base.product(csg1.cycles, csg2.cycles)),
        (csg1.check..., csg2.check...),
        (csg1.apply..., csg2.apply...),
        (csg1.phase..., csg2.phase...),
        map(x -> *(x...), Base.product(csg1.factors, csg2.factors)),
        csg1.N
    )
end
