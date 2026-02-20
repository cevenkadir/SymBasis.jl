using SymBasis.Miscs: combos_spin_sum, perm_k, perm_wrapper
using BitPermutations: bitpermute, PermutationBackend, BitPermutation
using SymBasis.DoFObjects: DoFObject
using SymBasis.DigitBase: BaseInt, permute, count, flip

# START -- check and apply functions for predefined symmetries
"""
    check_perm(
        p::@NamedTuple{perm::Tperm},
        state::SymBasis.DigitBase.BaseInt{T,Ti,B},
        prev_bool::Bool
    ) where {
        T,
        Ti,
        B,
        Tperm<:Union{
            AbstractVector{<:Ti},
            BitPermutations.BitPermutation{T,<:BitPermutations.PermutationBackend{T}}
        }
    }

Check if the given state is invariant under the permutation `p.perm`. Since permutations are
symmetries, this function always returns `prev_bool` unchanged.

# Arguments
- `p::@NamedTuple{perm::Tperm}`: A named tuple containing the permutation.
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state to be checked.
- `prev_bool::Bool`: The previous boolean value to be combined with the check result.

# Returns
- `Bool`: The combined result of the previous boolean and the check (always `prev_bool`).
"""
function check_perm(
    p::@NamedTuple{perm::Tperm},
    state::BaseInt{T,Ti,B},
    prev_bool::Bool
) where {
    T,
    Ti,
    B,
    Tperm<:Union{AbstractVector{<:Ti},BitPermutation{T,<:PermutationBackend{T}}}
}
    bool = prev_bool |> copy
    return bool
end

"""
    apply_perm(
        p::@NamedTuple{perm::Tperm},
        state::SymBasis.DigitBase.BaseInt{T,Ti,B}
    ) where {T,Ti,B,Tperm<:AbstractVector{<:Ti}}

Apply the permutation `p.perm` to the given state.

# Arguments
- `p::@NamedTuple{perm::Tperm}`: A named tuple containing the permutation.
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state to which the
    permutation will be applied.

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state after applying the permutation.
"""
function apply_perm(
    p::@NamedTuple{perm::Tperm},
    state::BaseInt{T,Ti,B}
) where {T,Ti,B,Tperm<:AbstractVector{<:Ti}}
    return permute(state, p.perm)
end

"""
    apply_perm(
        p::@NamedTuple{perm::Tperm},
        state::SymBasis.DigitBase.BaseInt{T,Ti,2}
    ) where {
        T,
        Ti,
        Tperm<:BitPermutations.BitPermutation{T,<:BitPermutations.PermutationBackend{T}}
    }

Apply the bit permutation `p.perm` to the given binary state in a more efficient way.

# Arguments
- `p::@NamedTuple{perm::Tperm}`: A named tuple containing the bit permutation.
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,2}`: The binary state to which the bit
    permutation will be applied.

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,2}`: The binary state after applying the bit
    permutation.
"""
function apply_perm(
    p::@NamedTuple{perm::Tperm},
    state::BaseInt{T,Ti,2}
) where {T,Ti,Tperm<:BitPermutation{T,<:PermutationBackend{T}}}
    return BaseInt(bitpermute(state.value, p.perm); base=2, Ti=Ti)
end

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
    counts = zeros(Int, B)
    v = state.value
    BB = T(B)
    for _ in 1:p.N
        counts[(v%BB)+1] += 1
        v ÷= BB
    end
    return all(j -> counts[j+1] == p[Symbol("N$j")], 0:(B-1))
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
# END -- check and apply functions for predefined symmetries


# START -- predefined symmetry group wrappers for end users
"""
    AbstractSymSpec

An abstract type representing a symmetry specification. Concrete subtypes of
`AbstractSymSpec` define specific symmetry specifications that can be used to create
symmetry groups.
"""
abstract type AbstractSymSpec end

"""
    TotalMagnetization{T_s<:Rational,T_N<:Integer} <: SymBasis.SymGroups.AbstractSymSpec

A concrete subtype of [`SymBasis.SymGroups.AbstractSymSpec`](@ref) representing a total
magnetization symmetry specification. The type parameter `T_s` represents the target total
magnetization value, while `T_N` represents the total number of DoF-objects in the system.

# Constructor Arguments
- `mag::T_s`: The target total magnetization value for the symmetry specification.
- `N::T_N`: The total number of DoF-objects in the system.

# Returns
- `TotalMagnetization{T_s,T_N}`: An instance of `TotalMagnetization` representing the
    specified total magnetization symmetry.
"""
struct TotalMagnetization{T_s<:Rational,T_N<:Integer} <: AbstractSymSpec
    mag::T_s
    N::T_N

    function TotalMagnetization(mag::T_s, N::T_N) where {T_s,T_N}
        @assert denominator(mag) == 1 || denominator(mag) == 2

        return new{T_s,T_N}(mag, N)
    end
end

"""
    TotalMagnetization(mag::Integer, N)

Convenience constructor for `TotalMagnetization` that accepts an integer magnetization value
and converts it to a rational number.

# Arguments
- `mag::Integer`: The target total magnetization value as an integer.
- `N`: The total number of DoF-objects in the system.

# Returns
- [`SymBasis.SymGroups.TotalMagnetization`](@ref): An instance of `TotalMagnetization` with
    the magnetization value converted to a rational number.
"""
TotalMagnetization(mag::Integer, N) = TotalMagnetization(rationalize(mag), N)

"""
    TotalMagnetization(mag::AbstractFloat, N)

Convenience constructor for `TotalMagnetization` that accepts a floating-point magnetization
value and converts it to a rational number.

# Arguments
- `mag::AbstractFloat`: The target total magnetization value as a floating-point number.
- `N`: The total number of DoF-objects in the system.

# Returns
- [`SymBasis.SymGroups.TotalMagnetization`](@ref): An instance of `TotalMagnetization` with
    the magnetization value converted to a rational number.
"""
TotalMagnetization(mag::AbstractFloat, N) = TotalMagnetization(rationalize(mag), N)

"""
    sym(
        ss::SymBasis.SymGroups.TotalMagnetization{T_s,T_N},
        dofo::SymBasis.DoFObjects.DoFObject{B,T_s,T,Ti}
    ) where {B,T_s,T,Ti,T_N}

Create a total magnetization symmetry group for the given spin DoF-object `dofo`, and target
total magnetization specification `ss`.

# Arguments
- `ss::`[`SymBasis.SymGroups.TotalMagnetization`](@ref)`{T_s,T_N}`: The total magnetization
    symmetry specification.
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object.

# Returns
- [`SymBasis.SymGroups.SymGroup`](@ref): The total magnetization symmetry group.
"""
function sym(
    ss::TotalMagnetization{T_s,T_N},
    dofo::DoFObject{B,T_s,T,Ti}
) where {B,T_s,T,Ti,T_N}
    @assert dofo.type == :Spin
    s = T_s((length(dofo) - 1) // 2)

    all_spin_sumₛ = combos_spin_sum(s, ss.mag, ss.N)

    Sz_sym = SymGroup(
        dofo,
        all_spin_sumₛ,
        check_Nₛ,
        apply_Nₛ,
        ones(length(all_spin_sumₛ)),
        ss.N
    )

    return Sz_sym
end

"""
    SpinInversion{T_z<:Integer,T_N<:Integer} <: SymBasis.SymGroups.AbstractSymSpec

A concrete subtype of [`SymBasis.SymGroups.AbstractSymSpec`](@ref) representing a spin
inversion symmetry specification. The type parameter `T_z` represents the spin inversion
quantum number, while `T_N` represents the total number of DoF-objects in the system.

# Fields
- `z::T_z`: The parity quantum number (either `-1` or `1`).
- `N::T_N`: The total number of DoF-objects in the system.

# Constructor Arguments
- `z::T_z`: The parity quantum number (either `-1` or `1`).
- `N::T_N`: The total number of DoF-objects in the system.

# Returns
- `SpinInversion{T_z,T_N}`: An instance of `SpinInversion` representing the specified spin
    inversion symmetry.
"""
struct SpinInversion{T_z<:Integer,T_N<:Integer} <: AbstractSymSpec
    z::T_z
    N::T_N

    function SpinInversion(z::T_z, N::T_N) where {T_z,T_N}
        @assert z == T_z(-1) || z == T_z(1)

        return new{T_z,T_N}(z, N)
    end
end

"""
    sym(
        ss::SymBasis.SymGroups.SpinInversion{T_z,T_N},
        dofo::SymBasis.DoFObjects.DoFObject{B,T_s,T,Ti}
    ) where {B,T_s,T,Ti,T_z,T_N}

Create a spin inversion symmetry group for the given DoF-object `dofo`, and spin inversion
symmetry specification `ss`. The function generates all combinations of spin projections
that sum to zero, and constructs the spin inversion symmetry group using the `check_flip`
and `apply_flip` functions.

# Arguments
- `ss::`[`SymBasis.SymGroups.SpinInversion`](@ref)`{T_z,T_N}`: The spin inversion symmetry
    specification.
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object.

# Returns
- [`SymBasis.SymGroups.SymGroup`](@ref): The spin inversion symmetry group.
"""
function sym(
    ss::SpinInversion{T_z,T_N},
    dofo::DoFObject{B,T_s,T,Ti}
) where {B,T_s,T,Ti,T_z,T_N}
    @assert dofo.type == :Spin
    s = T_s((length(dofo) - 1) // 2)

    sites = 1:ss.N |> collect

    all_spin_sumₛ = combos_spin_sum(s, 0 // 1, ss.N)

    rₛ = 0:1

    Z_sym = SymGroup(
        dofo,
        [
            merge((; is_flipped=Bool(r), sites=sites,), sumⱼ)
            for r in rₛ
            for sumⱼ in all_spin_sumₛ
        ],
        check_flip,
        apply_flip,
        [ss.z^r for r in rₛ for sumⱼ in all_spin_sumₛ],
        ss.N
    )

    return Z_sym
end

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

    T_sym = SymGroup(
        dofo,
        [
            (; perm=perm_wrapper(perm_k(ss.perm, i), length(dofo)))
            for i in rₛ
        ],
        check_perm,
        apply_perm,
        [
            cis(-2π * r * ss.k / R)
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

    P_sym = SymGroup(
        dofo,
        [(; perm=perm_wrapper(perm_k(ss.perm, i), length(dofo))) for i in rₛ],
        check_perm,
        apply_perm,
        [ss.p^r for r in rₛ],
        N
    )

    return P_sym
end

"""
    SpatialRotational{T_r<:Integer,Ti} <: SymBasis.SymGroups.AbstractSymSpec

A concrete subtype of [`SymBasis.SymGroups.AbstractSymSpec`](@ref) representing a spatial
rotational symmetry specification. The type parameter `T_r` represents the spatial rotation
number, while `Ti` represents the type of the permutation indices.

# Fields
- `r::T_r`: The spatial rotation number.
- `perm::AbstractVector{Ti}`: The permutation vector defining the rotation.

# Constructor Arguments
- `r::T_r`: The spatial rotation number.
- `perm::AbstractVector{Ti}`: The permutation vector defining the rotation.

# Returns
- `SpatialRotational{T_r,Ti}`: An instance of `SpatialRotational` representing the specified
spatial rotational symmetry.
"""
struct SpatialRotational{T_r<:Integer,Ti} <: AbstractSymSpec
    r::T_r
    perm::AbstractVector{Ti}

    function SpatialRotational(r::T_r, perm::AbstractVector{Ti}) where {T_r,Ti}
        N = length(perm)
        @assert N == length(unique(perm))

        Id_vec = 1:N .|> Ti
        @assert perm != Id_vec

        return new{T_r,Ti}(r, perm)
    end
end

"""
    sym(
        ss::SymBasis.SymGroups.SpatialRotational{T_r,Ti},
        dofo::SymBasis.DoFObjects.DoFObject{B,T_s,T,Ti}
    ) where {B,T_s,T,Ti,T_r}

Create a spatial rotational symmetry group for the given DoF-object `dofo`, and spatial
rotational symmetry specification `ss`. The function generates the rotation symmetry group
by applying the permutation defined in `ss` repeatedly until it returns to the identity, and
constructs the spatial rotational symmetry group using the `check_perm` and `apply_perm`
functions.

# Arguments
- `ss::`[`SymBasis.SymGroups.SpatialRotational`](@ref)`{T_r,Ti}`: The spatial rotational
    symmetry specification.
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object.

# Returns
- [`SymBasis.SymGroups.SymGroup`](@ref): The spatial rotational symmetry group.
"""
function sym(
    ss::SpatialRotational{T_r,Ti},
    dofo::DoFObject{B,T_s,T,Ti}
) where {B,T_s,T,Ti,T_r}
    N = length(ss.perm)
    Id_vec = 1:N .|> Ti

    R = 1

    while Id_vec != perm_k(ss.perm, R)
        R += 1
    end

    rₛ = 0:(R-1)

    R_sym = SymGroup(
        dofo,
        [(; perm=perm_wrapper(perm_k(ss.perm, i), length(dofo))) for i in rₛ],
        check_perm,
        apply_perm,
        [cis(-2π * r * ss.r / R) for r in rₛ],
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
