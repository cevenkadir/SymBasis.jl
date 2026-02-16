using SymBasis.DoFObjects: DoFObject
using SymBasis.Miscs: SmallHashSet

"""
    SymGroup{B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
    SymGroup(
        dofo::DoFObject{B,T_s,T,Ti},
        cycles::AbstractVector{<:NamedTuple},
        check::Function,
        apply::Function,
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
- `factors::AbstractVector{T_f}`: A vector of factors associated with each symmetry cycle.
- `N::Integer`: The total number of the DoF-objects in the system. This is used to check
    the validity of the symmetry operations.

# Constructor Arguments
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object on which the
    symmetry group acts.
- `cycles::AbstractVector{<:NamedTuple}`: A vector of named tuples representing the symmetry
    cycles.
- `check::Function`: A function to check the validity of symmetry operations.
- `apply::Function`: A function to apply the symmetry operations.
- `factors::AbstractVector{T_f}`: A vector of factors associated with each symmetry cycle.
- `N::Integer`: The total number of the DoF-objects in the system. This is used to check the
    validity of the symmetry operations.

# Returns
- `SymGroup{B,T_s,T,Ti,T_f}`: A new `SymGroup` instance initialized with the provided
    parameters.

The constructor checks that the number of cycles matches the number of factors to ensure
consistency.
"""
struct SymGroup{B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
    dofo::DoFObject{B,T_s,T,Ti}
    cycles::AbstractVector{<:NamedTuple}
    check::Function
    apply::Function
    factors::AbstractVector{T_f}
    N::Integer

    function SymGroup(
        dofo::DoFObject{B,T_s,T,Ti},
        cycles::AbstractVector{<:NamedTuple},
        check::Function,
        apply::Function,
        factors::AbstractVector{T_f},
        N::Integer
    ) where {B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
        @assert length(cycles) == length(factors)
        return new{B,T_s,T,Ti,T_f}(dofo, cycles, check, apply, factors, N)
    end
end

"""
    CombSymGroup{B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
    CombSymGroup(
        dofo::DoFObject{B,T_s,T,Ti},
        cycles::AbstractArray{<:AbstractVector{<:NamedTuple}},
        check::AbstractVector{<:Function},
        apply::AbstractVector{<:Function},
        factors::AbstractArray{T_f},
        N::Integer
    ) where {B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}

A combined symmetry group formed by the composition of multiple symmetry groups acting on
the same DoF-object. This structure allows for the representation of more complex symmetry
operations by combining simpler ones.

# Fields
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object on which the
    combined symmetry group acts.
- `cycles::AbstractArray{<:AbstractVector{<:NamedTuple}}`: An array of vectors of named
    tuples representing the combined symmetry cycles.
- `check::AbstractVector{<:Function}`: A vector of functions to check the validity of each
    set of symmetry operations.
- `apply::AbstractVector{<:Function}`: A vector of functions to apply each set of symmetry
    operations.
- `factors::AbstractArray{T_f}`: An array of factors associated with each combined symmetry
    cycle.
- `N::Integer`: The total number of the DoF-objects in the system. This is used to check
    the validity of the symmetry operations.

# Constructor Arguments
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object on which the
    combined symmetry group acts.
- `cycles::AbstractArray{<:AbstractVector{<:NamedTuple}}`: An array of vectors of named
    tuples representing the combined symmetry cycles.
- `check::AbstractVector{<:Function}`: A vector of functions to check the validity of each
    set of symmetry operations.
- `apply::AbstractVector{<:Function}`: A vector of functions to apply each set of symmetry
    operations.
- `factors::AbstractArray{T_f}`: An array of factors associated with each combined symmetry
    cycle.
- `N::Integer`: The total number of the DoF-objects in the system. This is used to check the
    validity of the symmetry operations.

# Returns
- `CombSymGroup{B,T_s,T,Ti,T_f}`: A new `CombSymGroup` instance initialized with the
    provided parameters.

The constructor checks that the size of cycles matches the size of factors and that the
number of dimensions matches the number of check and apply functions to ensure consistency.
"""
struct CombSymGroup{B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
    dofo::DoFObject{B,T_s,T,Ti}
    cycles::AbstractArray{<:AbstractVector{<:NamedTuple}}
    check::AbstractVector{<:Function}
    apply::AbstractVector{<:Function}
    factors::AbstractArray{T_f}
    N::Integer
    function CombSymGroup(
        dofo::DoFObject{B,T_s,T,Ti},
        cycles::AbstractArray{<:AbstractVector{<:NamedTuple}},
        check::AbstractVector{<:Function},
        apply::AbstractVector{<:Function},
        factors::AbstractArray{T_f},
        N::Integer
    ) where {B,T_s,T<:Integer,Ti<:Integer,T_f<:Number}
        @assert size(cycles) == size(factors)
        @assert ndims(cycles) == length(check)
        @assert ndims(cycles) == length(apply)
        return new{B,T_s,T,Ti,T_f}(dofo, cycles, check, apply, factors, N)
    end
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
    _print_kv(io, "cycles:", "array of vectors; eltype=$(eltype(g.cycles))")
    _print_kv(io, "factors:", "size=$(size(g.factors)), eltype=$(eltype(g.factors))")
    _print_kv(io, "check:", "$(length(g.check)) function(s)")
    _print_kv(io, "apply:", "$(length(g.apply)) function(s)")

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
        map(collect, Base.product(sg1.cycles, sg2.cycles)),
        [sg1.check, sg2.check],
        [sg1.apply, sg2.apply],
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
        map(x -> vcat(x...), Base.product(csg.cycles, sg.cycles)),
        vcat(csg.check..., sg.check),
        vcat(csg.apply..., sg.apply),
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
        map(x -> vcat(x...), Base.product(sg.cycles, csg.cycles)),
        vcat(sg.check, csg.check...),
        vcat(sg.apply, csg.apply...),
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
        map(x -> vcat(x...), Base.product(csg1.cycles, csg2.cycles)),
        vcat(csg1.check..., csg2.check...),
        vcat(csg1.apply..., csg2.apply...),
        map(x -> *(x...), Base.product(csg1.factors, csg2.factors)),
        csg1.N
    )
end

"""
    _make_hashset(sg::SymBasis.SymGroups.SymGroup)

Create a [`SymBasis.Miscs.SmallHashSet`](@ref) instance suitable for storing symmetry sector
parameters based on the provided symmetry group `sg`.

# Arguments
- `sg::`[`SymBasis.SymGroups.SymGroup`](@ref): The symmetry group for which to create the
    hash set.

# Returns
- [`SymBasis.Miscs.SmallHashSet`](@ref): A new [`SymBasis.Miscs.SmallHashSet`](@ref)
    instance.
"""
function _make_hashset(sg::SymGroup)
    Ncycles = length(sg.cycles)
    return SmallHashSet{Ncycles,UInt}()
end

"""
    _make_hashset(csg::SymBasis.SymGroups.CombSymGroup)

Create a [`SymBasis.Miscs.SmallHashSet`](@ref) instance suitable for storing symmetry sector
parameters based on the provided combined symmetry group `csg`.

# Arguments
- `csg::`[`SymBasis.SymGroups.CombSymGroup`](@ref): The combined symmetry group for which to
    create the hash set.
"""
function _make_hashset(csg::CombSymGroup)
    Ncycles = length(csg.cycles)
    return SmallHashSet{Ncycles,UInt}()
end
