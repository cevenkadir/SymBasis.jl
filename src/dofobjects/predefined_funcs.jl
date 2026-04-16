"""
    AbstractDoFSpec{T,Ti}

An abstract type representing a specification for degrees of freedom (DoF) objects. This
type serves as a base for concrete DoF specifications, such as
[`SymBasis.DoFObjects.Spin`](@ref), which define predefined
specific types of DoF objects.
"""
abstract type AbstractDoFSpec{T,Ti} end

"""
    Spin{Ts<:Rational,T,Ti} <: SymBasis.DoFObjects.AbstractDoFSpec{T,Ti}

A concrete type representing a quantum mechanical spin specification. The spin value `s` is
a rational number that can be either an integer or a half-integer, and it defines the local
degrees of freedom for the spin object.

# Fields
- `s::Ts`: The spin value, which must be a positive rational number with a denominator of 1
    or 2.

# Constructor Arguments
- `s::Ts`: The spin value, which must be a positive rational number with a denominator of 1
    or 2.

# Constructor Keyword Arguments
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

"""
    dof_object(type::Spin{Ts,T,Ti}) where {Ts,T,Ti}

Constructs a `DoFObject` based on the provided
[`SymBasis.DoFObjects.Spin`](@ref) specification. The local degrees
of freedom are determined by the spin value `s`, which defines a range from `-s` to `s`.

# Arguments
- `type::Spin{Ts,T,Ti}`: A [`SymBasis.DoFObjects.Spin`](@ref) specification that defines the
    spin value and associated types.

# Returns
- [`SymBasis.DoFObjects.DoFObject`](@ref): A DoF-object representing the degrees of freedom
    for the specified spin.
"""
function dof_object(type::Spin{Ts,T,Ti}) where {Ts,T,Ti}
    ldof = -type.s:type.s |> Tuple

    return DoFObject(:Spin, ldof; T=T, Ti=Ti)
end

"""
    Boson{Tb<:Unsigned,T,Ti} <: SymBasis.DoFObjects.AbstractDoFSpec{T,Ti}

A concrete type representing a bosonic degree of freedom specification. This type defines
the maximum occupancy for each particle.

# Fields
- `max_occupancy::Tb`: The maximum occupancy for each bosonic particle.

# Constructor Arguments
- `max_occupancy::Tb`: The maximum occupancy for each bosonic particle.

# Constructor Keyword Arguments
- `T::Type=UInt`: The underlying integer type for storage (default is `UInt`).
- `Ti::Type=Int`: The integer type used for indexing (default is `Int`).

# Returns
- `Boson{Tb,T,Ti}`: A new `Boson` instance representing the specified bosonic degree of
    freedom.
"""
struct Boson{Tb<:Unsigned,T,Ti} <: AbstractDoFSpec{T,Ti}
    max_occupancy::Tb

    function Boson(max_occupancy::Tb; T::Type=UInt, Ti::Type=Int) where {Tb}
        @assert max_occupancy > 0

        return new{Tb,T,Ti}(max_occupancy)
    end
end

"""
    Boson(max_occupancy::Signed; kwargs...)

A convenience constructor for creating a `Boson` instance with an optional maximum
occupancy. The constructor automatically determines the appropriate unsigned integer type
for storage based on the provided values.

# Arguments
- `max_occupancy::Signed`: The maximum occupancy for each bosonic particle.

# Keyword Arguments
- `kwargs...`: Additional keyword arguments to be passed to the `Boson` constructor.

# Returns
- `Boson`: A new `Boson` instance representing the specified bosonic degree of freedom.
"""
function Boson(max_occupancy::Signed; kwargs...)
    m = max_occupancy
    Tb = m ≤ typemax(UInt8) ? UInt8 :
         m ≤ typemax(UInt16) ? UInt16 :
         m ≤ typemax(UInt32) ? UInt32 :
         m ≤ typemax(UInt64) ? UInt64 : UInt128
    return Boson(Tb(max_occupancy); kwargs...)
end

"""
    dof_object(type::Boson{Tb,T,Ti}) where {Tb,T,Ti}

Constructs a `DoFObject` based on the provided [`SymBasis.DoFObjects.Boson`](@ref)
specification. The local degrees of freedom are determined by the maximum occupancy, which
defines a range from `0` to `max_occupancy`.

# Arguments
- `type::Boson{Tb,T,Ti}`: A [`SymBasis.DoFObjects.Boson`](@ref) specification that defines
    the maximum occupancy, and associated types.

# Returns
- [`SymBasis.DoFObjects.DoFObject`](@ref): A DoF-object representing the degrees of freedom
    for the specified bosonic system.
"""
function dof_object(type::Boson{Tb,T,Ti}) where {Tb,T,Ti}
    ldof = 0:type.max_occupancy |> Tuple

    return DoFObject(:Boson, ldof; T=T, Ti=Ti)
end

"""
    SpinlessFermion{T,Ti} <: SymBasis.DoFObjects.AbstractDoFSpec{T,Ti}

A concrete type representing a spinless fermionic degree of freedom specification. This type
defines a binary occupancy for each particle, where each site can be either occupied (1) or
unoccupied (0).

# Constructor Keyword Arguments
- `T::Type=UInt`: The underlying integer type for storage (default is `UInt`).
- `Ti::Type=Int`: The integer type used for indexing (default is `Int`).

# Returns
- `SpinlessFermion{T,Ti}`: A new `SpinlessFermion` instance representing the specified
    spinless fermionic degree of freedom.
"""
struct SpinlessFermion{T,Ti} <: AbstractDoFSpec{T,Ti}
    function SpinlessFermion(; T::Type=UInt, Ti::Type=Int)
        return new{T,Ti}()
    end
end

"""
    dof_object(::SpinlessFermion{T,Ti}) where {T,Ti}

Constructs a `DoFObject` based on the provided [`SymBasis.DoFObjects.SpinlessFermion`](@ref)
specification. The local degrees of freedom are binary, representing the occupation number of
each site, which can be either `0` (unoccupied) or `1` (occupied).

# Arguments
- `::SpinlessFermion{T,Ti}`: A [`SymBasis.DoFObjects.SpinlessFermion`](@ref) specification
    that defines the types for storage and indexing.

# Returns
- [`SymBasis.DoFObjects.DoFObject`](@ref): A DoF-object representing the degrees of freedom
    for the specified spinless fermionic system.
"""
function dof_object(::SpinlessFermion{T,Ti}) where {T,Ti}
    ldof = 0:1 |> Tuple

    return DoFObject(:SpinlessFermion, ldof; T=T, Ti=Ti)
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
