using SymBasis.DigitBase: BaseInt

abstract type AbstractDoFObject end

"""
    DoFObject{B,T_ldof,T<:Integer,Ti<:Integer} <: SymBasis.DoFObjects.AbstractDoFObject
    DoFObject(
        type::Symbol,
        ldof::NTuple{B,T_ldof};
        T::DataType=UInt, Ti::DataType=Int
    ) where {B,T_ldof}

An object having degrees of freedom. Each object is characterized by its type and a tuple of
local degrees of freedom (ldof) with length `B`. The type of the local degrees of freedom is
specified by the type parameter `T_ldof`, while the integer types used for indexing and
calculations are specified by the type parameters `T` and `Ti`.

# Fields
- `type::Symbol`: The type of the object (e.g., `:Spin`, `:Fermion`) as a symbol.
- `ldof::NTuple{B,T_ldof}`: A tuple representing the local degrees of freedom of the object.

# Constructor Arguments
- `type::Symbol`: The type of the object (e.g., `:Spin`, `:Fermion`) as a symbol.
- `ldof::NTuple{B,T_ldof}`: A tuple representing the local degrees of freedom of the object.

# Constructor Keyword Arguments
- `T::DataType=UInt`: The integer type used for indexing and calculations. Default is
    `UInt`.
- `Ti::DataType=Int`: The integer type used for indexing and calculations. Default is
    `Int`.

# Returns
- `DoFObject{B,T_ldof,T,Ti}`: A new `DoFObject` instance.
"""
struct DoFObject{B,T_ldof,T<:Integer,Ti<:Integer} <: AbstractDoFObject
    type::Symbol
    ldof::NTuple{B,T_ldof}
    function DoFObject(
        type::Symbol,
        ldof::NTuple{B,T_ldof};
        T::DataType=UInt, Ti::DataType=Int
    ) where {B,T_ldof}
        return new{B,T_ldof,T,Ti}(type, ldof)
    end
end

function Base.:(==)(dofo1::TDOFO, dofo2::TDOFO) where {TDOFO<:DoFObject}
    return (dofo1.ldof == dofo2.ldof) && (dofo1.type == dofo2.type)
end

function Base.isequal(dofo1::TDOFO, dofo2::TDOFO) where {TDOFO<:DoFObject}
    return isequal(dofo1.ldof, dofo2.ldof) && isequal(dofo1.type, dofo2.type)
end

function Base.hash(dofo::DoFObject, h::UInt)
    return hash(dofo.type, hash(dofo.ldof, hash(:BaseNumber, h)))
end

"""
    bint(dofo::SymBasis.DoFObjects.DoFObject{B,T_ldof,T,Ti}) where {B,T_ldof,T,Ti}

Returns [`SymBasis.DigitBase.BaseInt`](@ref) corresponding to the object.

# Arguments
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_ldof,T,Ti}`: The object for which to
create the base integer.

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base integer type corresponding
    to the object.
"""
function bint(dofo::DoFObject{B,T_ldof,T,Ti}) where {B,T_ldof,T,Ti}
    return BaseInt{T,Ti,B}
end

function Base.length(dofo::DoFObject{B,T_ldof,T,Ti}) where {B,T_ldof,T,Ti}
    return B
end

function Base.summary(io::IO, dofo::DoFObject{B,T_ldof,T,Ti}) where {B,T_ldof,T,Ti}
    print(io, "DoFObject(", dofo.type, ", B=", B, ")")
end

function Base.show(io::IO, dofo::DoFObject)
    print(io, String(dofo.type), "⟨")
    for (i, x) in pairs(dofo.ldof)
        i > 1 && print(io, ", ")
        show(io, x)
    end
    print(io, "⟩")
end

function Base.show(
    io::IO, ::MIME"text/plain", dofo::DoFObject{B,T_ldof,T,Ti}
) where {B,T_ldof,T,Ti}
    print(io, "DoFObject: ", String(dofo.type), " (B=", B, ")\n")
    print(io, "  ldof: ")
    show(io, dofo.ldof)
    print(io, "\n")
    print(io, "  index types: T=", T, ", Ti=", Ti)
end
