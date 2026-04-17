using SymBasis.Miscs: perm_k, perm_wrapper, invperm
using BitPermutations: bitpermute, PermutationBackend, BitPermutation
using SymBasis.DoFObjects: DoFObject
using SymBasis.DigitBase: BaseInt, permute, count, flip, read

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
    phase_unity(p, state)

Return a phase factor of `true` (implying a phase factor of `1`) for any given input. This
function is used as the default phase function for symmetries that do not involve any
nontrivial phase factors.

# Arguments
- `p`: A parameter containing the symmetry operation (not used in this function).
- `state`: The state to which the symmetry operation is applied (not used in this function).

# Returns
- `true`: A constant phase factor of `1`.
"""
function phase_unity(p, state)
    return true
end

"""
    apply_perm_fermionic(p, state)

Apply the permutation `p.perm` to the given binary state, and compute the fermionic phase
arising from the permutation of occupied sites. The function returns a tuple containing the
permuted state and the fermionic phase factor.

# Arguments
- `p`: A parameter containing the permutation (e.g. a named tuple with a `perm` field).
- `state`: The binary state to which the permutation will be applied.

# Returns
- A tuple containing the permuted state and the fermionic phase factor (`1` or `-1`).
"""
function apply_perm_fermionic(p, state)
    return apply_perm(p, state)
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
    for pos in 1:p.N
        digit = read(state, Ti(pos))
        counts[digit+1] += 1
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

    is_spinless_fermion = dofo.type == :SpinlessFermion

    apply = is_spinless_fermion ? apply_perm_fermionic : apply_perm
    phase = is_spinless_fermion ? phase_perm_fermionic : phase_unity

    T_sym = SymGroup(
        dofo,
        [
            (; perm=perm_wrapper(perm_k(ss.perm, i), length(dofo)))
            for i in rₛ
        ],
        check_perm,
        apply,
        phase,
        [
            cispi(-2r * ss.k / R)
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

    is_spinless_fermion = dofo.type == :SpinlessFermion

    apply = is_spinless_fermion ? apply_perm_fermionic : apply_perm
    phase = is_spinless_fermion ? phase_perm_fermionic : phase_unity

    P_sym = SymGroup(
        dofo,
        [(; perm=perm_wrapper(perm_k(ss.perm, i), length(dofo))) for i in rₛ],
        check_perm,
        apply,
        phase,
        [ss.p^r for r in rₛ],
        N
    )

    return P_sym
end

"""
    Rotational{T_r<:Integer,Ti} <: SymBasis.SymGroups.AbstractSymSpec

A concrete subtype of [`SymBasis.SymGroups.AbstractSymSpec`](@ref) representing the
specification of rotational symmetry of space. The type parameter `T_r` represents the
spatial rotation number, while `Ti` represents the type of the permutation indices.

# Fields
- `r::T_r`: The spatial rotation number.
- `perm::AbstractVector{Ti}`: The permutation vector defining the rotation.

# Constructor Arguments
- `r::T_r`: The spatial rotation number.
- `perm::AbstractVector{Ti}`: The permutation vector defining the rotation.

# Returns
- `Rotational{T_r,Ti}`: An instance of `Rotational` representing the specified rotational
    symmetry of space.
"""
struct Rotational{T_r<:Integer,Ti} <: AbstractSymSpec
    r::T_r
    perm::AbstractVector{Ti}

    function Rotational(r::T_r, perm::AbstractVector{Ti}) where {T_r,Ti}
        N = length(perm)
        @assert N == length(unique(perm))

        Id_vec = 1:N .|> Ti
        @assert perm != Id_vec

        return new{T_r,Ti}(r, perm)
    end
end

"""
    sym(
        ss::SymBasis.SymGroups.Rotational{T_r,Ti},
        dofo::SymBasis.DoFObjects.DoFObject{B,T_s,T,Ti}
    ) where {B,T_s,T,Ti,T_r}

Create  a group of rotational symmetry of space for the given DoF-object `dofo`, and
rotational symmetry specification `ss`. The function generates the rotational symmetry group
by applying the permutation defined in `ss` repeatedly until it returns to the identity, and
constructs the rotational symmetry group using the `check_perm` and `apply_perm` functions.

# Arguments
- `ss::`[`SymBasis.SymGroups.Rotational`](@ref)`{T_r,Ti}`: The specification of rotational
    symmetry of space.
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object.

# Returns
- [`SymBasis.SymGroups.SymGroup`](@ref): The group of rotational symmetry of space.
"""
function sym(
    ss::Rotational{T_r,Ti},
    dofo::DoFObject{B,T_s,T,Ti}
) where {B,T_s,T,Ti,T_r}
    dofo.type == :SpinlessFermion && error(
        "Rotational symmetry is not supported for SpinlessFermion DoF-object."
    )

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
        phase_unity,
        [cispi(-2 * r * ss.r / R) for r in rₛ],
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
