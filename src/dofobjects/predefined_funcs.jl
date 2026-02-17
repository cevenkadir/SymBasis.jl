"""
    AbstractDoFSpec{T,Ti}

An abstract type representing a specification for degrees of freedom (DoF) objects. This
type serves as a base for concrete DoF specifications, such as
[`SymBasis.DoFObjects.Spin`](@ref SymBasis.DoFObjects.Spin), which define predefined
specific types of DoF objects.
"""
abstract type AbstractDoFSpec{T,Ti} end

"""
    Spin{Ts<:Rational,T,Ti} <: AbstractDoFSpec{T,Ti}

A concrete type representing a quantum mechanical spin specification. The spin value `s` is
a rational number that can be either an integer or a half-integer, and it defines the local
degrees of freedom for the spin object.

# Fields
- `s::Ts`: The spin value, which must be a positive rational number with a denominator of 1
    or 2.

# Constructor Arguments
- `s::Ts`: The spin value, which must be a positive rational number with a denominator of 1
    or 2.
- `T::Type=UInt`: The underlying integer type for storage (default is `UInt`).
- `Ti::Type=Int`: The integer type used for indexing (default is `Int`).

# Returns
- `Spin{Ts,T,Ti}`: A new `Spin` instance representing the specified spin.
"""
struct Spin{Ts<:Rational,T,Ti} <: AbstractDoFSpec{T,Ti}
    s::Ts

    function Spin(s::Ts; T::Type=UInt, Ti::Type=Int) where {Ts}
        @assert numerator(s) > 0
        @assert denominator(s) == 1 || denominator(s) == 2

        return new{Ts,T,Ti}(s)
    end
end

function dof_object(type::Spin{Ts,T,Ti}) where {Ts,T,Ti}
    ldof = -type.s:type.s |> Tuple

    return DoFObject(:Spin, ldof; T=T, Ti=Ti)
end

@deprecate dof_object(
    sym::Symbol, args...;
    kwargs...
) dof_object(
    getfield(DoFObjects, sym)(args...;
        kwargs...)
)

@deprecate dof_object(
    sym::Val{:Spin}, args...;
    kwargs...
) dof_object(
    Spin(args...; kwargs...)
)
