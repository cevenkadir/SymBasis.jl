using SymBasis.Miscs: combos_spin_sum, perm_k, perm_wrapper
using BitPermutations: bitpermute, BenesNetwork, BitPermutation
using SymBasis.DoFObjects: DoFObject
using SymBasis.DigitBase: BaseInt, permute, count

# START -- check and apply functions for predefined symmetries
"""
    check_perm(
        p::@NamedTuple{perm::Tperm},
        state::SymBasis.DigitBase.BaseInt{T,Ti,B},
        prev_bool::Bool
    ) where {
        T<:Integer,
        Ti<:Integer,
        B,
        Tperm<:Union{
            AbstractVector{<:Ti},
            BitPermutations.BitPermutation{T,BitPermutations.BenesNetwork{T}}
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
    T<:Integer,
    Ti<:Integer,
    B,
    Tperm<:Union{AbstractVector{<:Ti},BitPermutation{T,BenesNetwork{T}}}
}
    bool = prev_bool |> copy
    return bool
end

"""
    apply_perm(
        p::@NamedTuple{perm::Tperm},
        state::SymBasis.DigitBase.BaseInt{T,Ti,B}
    ) where {T<:Integer,Ti<:Integer,B,Tperm<:AbstractVector{<:Ti}}

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
) where {T<:Integer,Ti<:Integer,B,Tperm<:AbstractVector{<:Ti}}
    return permute(state, p.perm)
end

"""
    apply_perm(
        p::@NamedTuple{perm::Tperm},
        state::SymBasis.DigitBase.BaseInt{T,Ti,2}
    ) where {
        T<:Integer,
        Ti<:Integer,
        Tperm<:BitPermutations.BitPermutation{T,BitPermutations.BenesNetwork{T}}
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
) where {T<:Integer,Ti<:Integer,Tperm<:BitPermutation{T,BenesNetwork{T}}}
    return BaseInt(bitpermute(state.value, p.perm); base=2, Ti=Ti)
end

"""
    check_Nₛ(
        p::NamedTuple{names,NT},
        state::SymBasis.DigitBase.BaseInt{T,Ti,B},
        prev_bool::Bool,
    ) where {names,NT<:Tuple{Vararg{<:Integer}},T<:Integer,Ti<:Integer,B}

Check if the given state has the specified digit counts as defined in the named tuple `p`.
Since this is a symmetry check, the result is combined with `prev_bool`.

# Arguments
- `p::NamedTuple{names,NT}`: A named tuple containing the digit counts.
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state to be checked.
- `prev_bool::Bool`: The previous boolean value to be combined with the check result.

# Returns
- `Bool`: The combined result of the previous boolean and the digit count check.
"""
function check_Nₛ(
    p::NamedTuple{names,NT},
    state::BaseInt{T,Ti,B},
    prev_bool::Bool
) where {names,NT<:Tuple{Vararg{<:Integer}},T<:Integer,Ti<:Integer,B}
    return prev_bool * _check_Nₛ(state, p)
end

"""
    _check_Nₛ(
        state::SymBasis.DigitBase.BaseInt{T,Ti,B},
        p::NamedTuple{names,NT}
    ) where {T<:Integer,Ti<:Integer,B,names,NT<:Tuple{Vararg{<:Integer}}}

Internal function to check if the given state has the specified digit counts as defined in
the named tuple `p`.

# Arguments
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state to be checked.
- `p::NamedTuple{names,NT}`: A named tuple containing the digit counts.

# Returns
- `Bool`: `true` if the state has the specified digit counts, `false` otherwise.
"""
function _check_Nₛ(
    state::BaseInt{T,Ti,B},
    p::NamedTuple{names,NT}
) where {T<:Integer,Ti<:Integer,B,names,NT<:Tuple{Vararg{<:Integer}}}
    sites = 1:p.N |> collect

    return all((j, p[Symbol("N$j")]) for j in 0:(B-1)) do (digit, Nᵢ)
        Nᵢ == count(state, sites, digit)
    end
end

"""
    _check_Nₛ(
        state::SymBasis.DigitBase.BaseInt{T,Ti,2},
        p::NamedTuple{N0::TN, N1::TN, N::TN}
    ) where {T<:Integer,Ti<:Integer,TN<:Integer}

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
) where {T<:Integer,Ti<:Integer,TN<:Integer}
    _N1 = count_ones(state.value)
    _N0 = p.N - _N1

    return (p.N0 == _N0) && (p.N1 == _N1)
end

"""
    apply_Nₛ(
        p::NamedTuple{names,NT},
        state::SymBasis.DigitBase.BaseInt{T,Ti,B}
    ) where {names,NT<:Tuple{Vararg{<:Integer}},T<:Integer,Ti<:Integer,B}

Apply the symmetry operation defined by the digit counts in `p` to the given state. Since
this is a symmetry where the state remains unchanged, the function simply returns the input
state.

# Arguments
- `p::NamedTuple{names,NT}`: A named tuple containing the digit counts.
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state to which the symmetry
    operation will be applied.

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The unchanged state.
"""
function apply_Nₛ(
    p::NamedTuple{names,NT},
    state::BaseInt{T,Ti,B}
) where {names,NT<:Tuple{Vararg{<:Integer}},T<:Integer,Ti<:Integer,B}
    return state
end
# END -- check and apply functions for predefined symmetries


# START -- predefined symmetry group wrappers for end users
"""
    sym(s::Symbol, args...; kwargs...)

Create a symmetry group based on the specified symbol `s` and additional arguments.

# Arguments
- `s::Symbol`: The symbol representing the type of symmetry group to create.
- `args...`: Additional positional arguments required for the specific symmetry group.

# Keyword Arguments
- `kwargs...`: Additional keyword arguments required for the specific symmetry group.

# Returns
- [`SymBasis.SymGroups.SymGroup`](@ref): The created symmetry group.
"""
sym(s::Symbol, args...; kwargs...) = sym(Val(s), args...; kwargs...)

"""
    sym(
        ::Val{:TotalMagnetization},
        dofo::SymBasis.DoFObjects.DoFObject{B,T_s,T,Ti},
        mag::T_s,
        N::Integer
    ) where {B,T_s<:Rational,T<:Integer,Ti<:Integer}

Create a total magnetization symmetry group for the given spin object `dofo`, target
magnetization `mag`, and number of sites `N`.

# Arguments
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object representing
    the quantum mechanical spin.
- `mag::T_s`: The target total magnetization.
- `N::Integer`: The total number of DoF-objects in the system.

# Returns
- [`SymBasis.SymGroups.SymGroup`](@ref): The total magnetization symmetry group.
"""
function sym(
    ::Val{:TotalMagnetization},
    dofo::DoFObject{B,T_s,T,Ti},
    mag::T_s,
    N::Integer
) where {B,T_s<:Rational,T<:Integer,Ti<:Integer}
    @assert dofo.type == :Spin
    s = T_s((length(dofo) - 1) // 2)

    all_spin_sumₛ = combos_spin_sum(s, mag, N)

    Sz_sym = SymGroup(
        dofo,
        all_spin_sumₛ,
        check_Nₛ,
        apply_Nₛ,
        ones(length(all_spin_sumₛ)),
        N
    )

    return Sz_sym
end

"""
    sym(
        ::Val{:Translational},
        dofo::SymBasis.DoFObjects.DoFObject{B,T_s,T,Ti},
        k::T_k,
        perm::AbstractVector{Ti}
    ) where {B,T_s,T<:Integer,Ti<:Integer,T_k<:Integer}

Create a translational symmetry group for the given DoF-object `dofo`, momentum `k`, and
permutation `perm`.

# Arguments
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object.
- `k::T_k`: The momentum number.
- `perm::AbstractVector{Ti}`: The permutation vector defining the translation.

# Returns
- [`SymBasis.SymGroups.SymGroup`](@ref): The translational symmetry group.
"""
function sym(
    ::Val{:Translational},
    dofo::DoFObject{B,T_s,T,Ti},
    k::T_k,
    perm::AbstractVector{Ti}
) where {B,T_s,T<:Integer,Ti<:Integer,T_k<:Integer}
    N = length(perm)
    @assert N == length(unique(perm))

    Id_vec = 1:N .|> Ti
    @assert perm != Id_vec

    R = 1
    for r in 1:(N-1)
        if Id_vec != perm_k(perm, r)
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
            (; perm=perm_wrapper(perm_k(perm, i), length(dofo)))
            for i in rₛ
        ],
        check_perm,
        apply_perm,
        [
            exp(-2im * π * r * k / R)
            for r in rₛ
        ],
        N
    )

    return T_sym
end

"""
    sym(
        ::Val{:SpatialReflection},
        dofo::SymBasis.DoFObjects.DoFObject{B,T_s,T,Ti},
        p::T_p,
        perm::AbstractVector{Ti}
    ) where {B,T_s,T<:Integer,Ti<:Integer,T_p<:Integer}

Create a spatial reflection symmetry group for the given DoF-object `dofo`, parity `p`, and
permutation `perm`.

# Arguments
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object.
- `p::T_p`: The parity number (either `-1` or `1`).
- `perm::AbstractVector{Ti}`: The permutation vector defining the spatial reflection.

# Returns
- [`SymBasis.SymGroups.SymGroup`](@ref): The spatial reflection symmetry group.
"""
function sym(
    ::Val{:SpatialReflection},
    dofo::DoFObject{B,T_s,T,Ti},
    p::T_p,
    perm::AbstractVector{Ti}
) where {B,T_s,T<:Integer,Ti<:Integer,T_p<:Integer}
    N = length(perm)
    @assert N == length(unique(perm))

    @assert p == T_p(-1) || p == T_p(1)

    Id_vec = 1:N .|> Ti
    @assert perm != Id_vec

    R = 1
    for r in 1:(N-1)
        if Id_vec != perm_k(perm, r)
            R += 1
        else
            break
        end
    end
    @assert R == 2

    rₛ = 0:(R-1)

    P_sym = SymGroup(
        dofo,
        [(; perm=perm_wrapper(perm_k(perm, i), length(dofo))) for i in rₛ],
        check_perm,
        apply_perm,
        [p^r for r in rₛ],
        N
    )

    return P_sym
end
# END -- predefined symmetry group wrappers for end users
