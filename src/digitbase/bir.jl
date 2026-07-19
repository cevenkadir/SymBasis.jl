"""
    BaseIntRange{T<:Integer,Ti<:Integer,B}

A range of `SymBasis.DigitBase.BaseInt{T,Ti,B}` numbers with specified first, step, and last
elements.

# Fields
- `first::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The first element of the range.
- `step::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The step size between consecutive
    elements.
- `last::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The last element of the range.
"""
struct BaseIntRange{T<:Integer,Ti<:Integer,B}
    first::BaseInt{T,Ti,B}
    step::BaseInt{T,Ti,B}
    last::BaseInt{T,Ti,B}
end

function Base.show(io::IO, r::BaseIntRange)
    show(io, r.first)

    print(io, ':')

    show(io, r.step)

    print(io, ':')

    show(io, r.last)
    return nothing
end

function Base.:(:)(first::TB, last::TB) where {T,Ti,B,TB<:BaseInt{T,Ti,B}}
    BaseIntRange{T,Ti,B}(first, BaseInt{T,Ti,B}(T(1)), last)
end

function Base.:(:)(a::TB, s::TB, b::TB) where {T,Ti,B,TB<:BaseInt{T,Ti,B}}
    s.value <= 0 && throw(ArgumentError("step must be positive, got $(s.value)"))
    a.value > b.value && return BaseIntStepRange(a, s, a)
    return BaseIntRange{T,Ti,B}(a, s, b)
end

function Base.length(r::BaseIntRange)
    a = r.first.value
    s = r.step.value
    b = r.last.value
    a > b && return 0

    n = (b - a) ÷ s + 1
    return Int(n)
end

function Base.iterate(
    r::BaseIntRange{T,Ti,B},
    state::BaseInt{T,Ti,B}=r.first
) where {T,Ti,B}
    state.value > r.last.value && return nothing

    next_state = BaseInt{T,Ti,B}(state.value + r.step.value)
    return (state, next_state)
end

function Base.collect(r::BaseIntRange{T,Ti,B}) where {T,Ti,B}
    len = length(r)
    out = Vector{BaseInt{T,Ti,B}}(undef, len)

    cur = r.first.value
    step_val = r.step.value
    @inbounds for i = 1:len
        out[i] = BaseInt{T,Ti,B}(cur)
        cur += step_val
    end
    return out
end

function Base.eltype(::Type{<:BaseIntRange{T,Ti,B}}) where {T,Ti,B}
    return BaseInt{T,Ti,B}
end
Base.IteratorSize(::Type{<:BaseIntRange}) = Base.HasLength()
Base.IteratorEltype(::Type{<:BaseIntRange}) = Base.HasEltype()

Base.firstindex(::BaseIntRange) = 1
function Base.getindex(r::BaseIntRange{T,Ti,B}, x::Ti) where {T,Ti,B}
    new_val = r.first.value + (x - 1) * r.step.value
    new_val > r.last.value && throw(BoundsError(r, x))
    return BaseInt{T,Ti,B}(T(new_val))
end
