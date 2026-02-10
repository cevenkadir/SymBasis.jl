"""
    dof_object(sym::Symbol, args...; kwargs...)

Create an object with degrees of freedom based on the specified symbol `sym` and additional
arguments.

# Arguments
- `sym::Symbol`: The symbol representing the type of object to create.
- `args...`: Additional positional arguments required for the object constructor.

# Keyword Arguments
- `kwargs...`: Additional keyword arguments required for the object constructor.

# Returns
- [`SymBasis.DoFObjects.DoFObject`](@ref): The created degree of freedom object.
"""
function dof_object(sym::Symbol, args...; kwargs...)
    return dof_object(Val(sym), args...; kwargs...)
end

"""
    dof_object(type::Val{:Spin}, s::Rational; T::Type=UInt, Ti::Type=Int)

Create a quantum mechanical spin object with spin `s`.

# Arguments
- `type::Val{:Spin}`: The type of the object, fixed to `:Spin`.
- `s::Rational`: The spin value.
- `T::Type=UInt`: The underlying integer type for storage (default is `UInt`).
- `Ti::Type=Int`: The integer type used for indexing (default is `Int`).

# Returns
- [`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_ldof,T,Ti}`: The object representing the
    spin.
"""
function dof_object(type::Val{:Spin}, s::Rational; T::Type=UInt, Ti::Type=Int)
    @assert numerator(s) > 0
    @assert denominator(s) == 1 || denominator(s) == 2

    ldof = -s:s |> Tuple

    return DoFObject(:Spin, ldof; T=T, Ti=Ti)
end
