
using SymBasis.DigitBase: BaseInt, BaseIntRange, base_number_to_string
using SymBasis.SymGroups: _make_hashset
using SymBasis.SymGroups: SymGroup, CombSymGroup
using SymBasis.DoFObjects: DoFObject

"""
    Basis{T<:Integer,Ti<:Integer,B,T_n<:Number}
    Basis(
        states::AbstractVector{BaseInt{T,Ti,B}},
        norms::AbstractVector{T_n}
    ) where {T<:Integer,Ti<:Integer,B,T_n<:Number}

A basis struct consisting of a collection of basis states and their corresponding norms. The
basis states are represented using [`SymBasis.DigitBase.BaseInt`](@ref), which allows for
efficient representation and manipulation of states in different bases.

# Fields
- `states::AbstractVector{`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}}`: A vector of
    basis states represented as [`SymBasis.DigitBase.BaseInt`](@ref) DoF-objects, where `B`
    is the base corresponding to the number of local degrees of freedom of the DoF-object.
- `norms::AbstractVector{T_n}`: A vector of norms corresponding to each basis state, where
    `T_n` is the data type for the norms.

# Constructor Arguments
- `states::AbstractVector{`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}}`: A vector of
    basis states represented as [`SymBasis.DigitBase.BaseInt`](@ref) DoF-objects.
- `norms::AbstractVector{T_n}`: A vector of norms corresponding to each basis state.

# Returns
- [`SymBasis.Bases.Basis`](@ref)`{T,Ti,B,T_n}`: A new [`SymBasis.Bases.Basis`](@ref)
    instance containing the provided states and norms.

The constructor checks that the length of states matches the length of norms to ensure
consistency.
"""
struct Basis{T<:Integer,Ti<:Integer,B,T_n<:Number}
    states::AbstractVector{BaseInt{T,Ti,B}}
    norms::AbstractVector{T_n}
    function Basis(
        states::AbstractVector{BaseInt{T,Ti,B}},
        norms::AbstractVector{T_n}
    ) where {T<:Integer,Ti<:Integer,B,T_n<:Number}
        @assert length(states) == length(norms) "Length of states and norms must be equal"
        return new{T,Ti,B,T_n}(states, norms)
    end
end
Base.iterate(B::Basis) = (B.states, Val(:norms))
Base.iterate(B::Basis, ::Val{:norms}) = (B.norms, Val(:done))
Base.iterate(B::Basis, ::Val{:done}) = nothing

function Base.summary(io::IO, B::Basis{T,Ti,BaseVal,Tn}) where {T,Ti,BaseVal,Tn}
    print(io, "Basis{$T,$Ti,$BaseVal,$Tn} with ", length(B.states), " states")
end

function Base.show(io::IO, B::Basis{T,Ti,BaseVal,Tn}) where {T,Ti,BaseVal,Tn}
    compact = get(io, :compact, false)
    print(io, "Basis{$T,$Ti,$BaseVal,$Tn}(")
    if compact
        print(io, "states=", length(B.states), ", norms=", length(B.norms))
    else
        print(io, "\n\tstates = ")
        show(io, B.states)
        print(io, ",\n\tnorms  = ")
        show(io, B.norms)
        print(io, "\n")
    end
    print(io, ")")
end

function Base.show(
    io::IO, ::MIME"text/plain", B::Basis{T,Ti,BaseVal,Tn}
) where {T,Ti,BaseVal,Tn}
    n = length(B.states)
    println(io, "Basis{$T,$Ti,$BaseVal,$Tn} with $n state$(n == 1 ? "" : "s")")

    # shorter indent (2 spaces)
    ind = "  "
    ind2 = "    "

    println(io, ind, "states: ", typeof(B.states))
    println(io, ind, "norms : ", typeof(B.norms))

    n == 0 && return

    m = min(n, get(io, :limit, true) ? 10 : n)
    println(io, ind, "first $(m) state$(m == 1 ? "" : "s")/norm$(m == 1 ? "" : "s"):")

    st_strs = [sprint(show, B.states[i]) for i in 1:m]
    wmax = maximum(textwidth.(st_strs))
    gap = 2

    for i in 1:m
        s = st_strs[i]
        print(io, ind2, s)
        print(io, ' '^max(gap, wmax - textwidth(s) + gap))
        print(io, "(norm=")
        show(io, B.norms[i])
        println(io, ")")
    end

    if m < n
        println(io, ind2, "⋮")
    end
end



"""
    basis(
        dofo::DoFObject{B,T_s,T,Ti},
        N::Integer;
        norm_type=Float64
    ) where {B,T_s,T<:Integer,Ti<:Integer}

Generates the full basis for a DoF-object without symmetry considerations.

# Arguments
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object for which
    the basis is to be generated.
- `N::Integer`: The number of sites or particles.

# Keyword Arguments
- `norm_type::DataType=Float64`: The data type for the norms of the basis states. Default is
    `Float64`.

# Returns
- [`SymBasis.Bases.Basis`](@ref)`{T,Ti,B,T_n}`: The generated basis, where `B` is the number
    of local degrees of freedom of the DoF-object and `T_n` is the specified norm type.
"""
function basis(
    dofo::DoFObject{B,T_s,T,Ti},
    N::Integer;
    norm_type=Float64
) where {B,T_s,T<:Integer,Ti<:Integer}
    states = collect(BaseInt(T(0); base=B, Ti=Ti):BaseInt(T(B^N - 1); base=B, Ti=Ti))
    norms = ones(norm_type, length(states))

    return Basis(states, norms)
end

"""
    basis(
        dofo::DoFObject{B,T_s,T,Ti},
        N::Integer,
        sg::SymGroup{B,T_s,T,Ti,Ts};
        norm_type=Float64
    ) where {T<:Integer,Ti<:Integer,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}

Generates the symmetry-resolved basis for a DoF-object under the action of a symmetry group.

# Arguments
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object for which
    the basis is to be generated.
- `N::Integer`: The number of sites or particles.
- `sg::`[`SymBasis.SymGroups.SymGroup`](@ref)`{B,T_s,T,Ti,Ts}`: The symmetry group to be
    resolved.

# Keyword Arguments
- `norm_type::DataType=Float64`: The data type for the norms of the basis states. Default is
    `Float64`.

# Returns
- [`SymBasis.Bases.Basis`](@ref)`{T,Ti,B,T_n}`: The generated symmetry-resolved basis, where
    `B` is the number of local degrees of freedom of the DoF-object and `T_n` is the
    specified norm type.
"""
function basis(
    dofo::DoFObject{B,T_s,T,Ti},
    N::Integer,
    sg::SymGroup{B,T_s,T,Ti,Ts};
    norm_type=Float64
) where {T<:Integer,Ti<:Integer,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}
    nthreads = Threads.nthreads()

    norms = [norm_type[] for _ in 1:nthreads]
    states = [BaseInt{T,Ti,B}[] for _ in 1:nthreads]

    F₀ = zero(Complex{norm_type})
    F = [F₀ |> deepcopy for _ in 1:nthreads]

    eps_norm_type = eps(norm_type)

    n_cycles = sg.cycles |> length

    Dₛₛ = [_make_hashset(sg) for _ in 1:nthreads]

    c = true

    all_bints = BaseInt(T(0); base=B, Ti=Ti):BaseInt(T(B^N - 1); base=B, Ti=Ti)

    Threads.@threads for state₀ in all_bints
        threadid = Threads.threadid()

        F[threadid] = F₀

        h_state₀ = hash(state₀)

        empty!(Dₛₛ[threadid])

        @inbounds for idx in 1:n_cycles
            cycleᵢ = sg.cycles[idx]

            temp_state₀ = sg.apply(cycleᵢ, state₀)
            is_valid_state = sg.check(cycleᵢ, temp_state₀, c)

            if is_valid_state
                h_temp_state = hash(temp_state₀)
                push!(Dₛₛ[threadid], h_temp_state)

                if h_temp_state < h_state₀
                    F[threadid] *= zero(norm_type)
                    break
                elseif h_temp_state == h_state₀
                    F[threadid] += sg.factors[idx]
                end
            end
        end

        norm₀ = length(Dₛₛ[threadid]) * abs2(F[threadid])
        if norm₀ > eps_norm_type
            push!(norms[threadid], norm₀)
            push!(states[threadid], state₀)
        end
    end

    return Basis(vcat(states...), vcat(norms...))
end

"""
    basis(
        dofo::DoFObject{B,T_s,T,Ti},
        N::Integer,
        csg::CombSymGroup{B,T_s,T,Ti,Ts};
        norm_type=Float64
    ) where {T<:Integer,Ti<:Integer,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}

Generates the symmetry-resolved basis for a DoF-object under the action of a combined
    symmetry group.

# Arguments
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object for which
    the basis is to be generated.
- `N::Integer`: The number of sites or particles.
- `csg::`[`SymBasis.SymGroups.CombSymGroup`](@ref)`{B,T_s,T,Ti,Ts}`: The combined symmetry
    group to be resolved.

# Keyword Arguments
- `norm_type::DataType=Float64`: The data type for the norms of the basis states. Default is
    `Float64`.

# Returns
- [`SymBasis.Bases.Basis`](@ref)`{T,Ti,B,T_n}`: The generated symmetry-resolved basis, where
    `B` is the number of local degrees of freedom of the DoF-object and `T_n` is the
    specified norm type.
"""
function basis(
    dofo::DoFObject{B,T_s,T,Ti},
    N::Integer,
    csg::CombSymGroup{B,T_s,T,Ti,Ts};
    norm_type=Float64
) where {T<:Integer,Ti<:Integer,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}
    nthreads = Threads.nthreads()

    norms = [norm_type[] for _ in 1:nthreads]
    states = [BaseInt{T,Ti,B}[] for _ in 1:nthreads]

    F₀ = zero(Complex{norm_type})
    F = [F₀ |> deepcopy for _ in 1:nthreads]

    eps_norm_type = eps(norm_type)

    n_cycles = csg.cycles |> length
    ndims_cycles = csg.cycles |> ndims

    Dₛₛ = [_make_hashset(csg) for _ in 1:nthreads]

    c = true

    all_bints = BaseInt(T(0); base=B, Ti=Ti):BaseInt(T(B^N - 1); base=B, Ti=Ti)

    Threads.@threads for state₀ in all_bints
        threadid = Threads.threadid()

        F[threadid] = F₀

        h_state₀ = hash(state₀)

        empty!(Dₛₛ[threadid])

        @inbounds for idx in 1:n_cycles
            is_valid_state = c
            temp_state = state₀
            cycle = csg.cycles[idx]

            for i in 1:ndims_cycles
                if is_valid_state
                    is_valid_state = csg.check[i](cycle[i], state₀, is_valid_state)
                end
            end

            if is_valid_state
                @inbounds for i in 1:ndims_cycles
                    temp_state = csg.apply[i](cycle[i], temp_state)
                end

                h_temp_state = hash(temp_state)

                push!(Dₛₛ[threadid], h_temp_state)

                if h_temp_state < h_state₀
                    F[threadid] *= zero(norm_type)
                    break
                elseif h_temp_state == h_state₀
                    F[threadid] += csg.factors[idx]#'
                end
            end
        end

        norm₀ = length(Dₛₛ[threadid]) * abs2(F[threadid])
        if norm₀ > eps_norm_type
            push!(norms[threadid], norm₀)
            push!(states[threadid], state₀)
        end

    end

    states = vcat(states...)
    norms = vcat(norms...)

    return Basis(states, norms)
end

"""
    is_commutative(
        b::Basis{T,Ti,B,T_n},
        csg::CombSymGroup{B,T_s,T,Ti,Ts}
    ) where {T<:Integer,Ti<:Integer,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}

Checks whether the given symmetries commute with each other in the given basis.

# Arguments
- `b::`[`SymBasis.Bases.Basis`](@ref)`{T,Ti,B,T_n}`: The basis to be checked.
- `csg::`[`SymBasis.SymGroups.CombSymGroup`](@ref)`{T_s,T,Ti,Ts}`: The combined symmetry
    group under which the basis states are expected to be consistent.

# Returns
- `Bool`: Returns `true` if the basis states are consistent under the action of the combined
    symmetry group, and `false` otherwise.
"""
function is_commutative(
    b::Basis{T,Ti,B,T_n},
    csg::CombSymGroup{B,T_s,T,Ti,Ts}
) where {T<:Integer,Ti<:Integer,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}
    n_cycles = csg.cycles |> length
    ndims_cycles = csg.cycles |> ndims

    failed = Threads.Atomic{Bool}(false)

    Threads.@threads for s_idx in eachindex(b.states)
        if failed[]
            continue
        end

        test_state = b.states[s_idx]

        for i in 1:ndims_cycles
            for j in (i+1):ndims_cycles
                for cycle_idx in 1:n_cycles
                    if failed[]
                        break
                    end

                    cycle = csg.cycles[cycle_idx]

                    # Apply symmetry i then j
                    state_ij = csg.apply[i](cycle[i], test_state)
                    state_ij = csg.apply[j](cycle[j], state_ij)
                    state_ij, factor_ij = representative(state_ij, csg)

                    # Apply symmetry j then i
                    state_ji = csg.apply[j](cycle[j], test_state)
                    state_ji = csg.apply[i](cycle[i], state_ji)
                    state_ji, factor_ji = representative(state_ji, csg)

                    if state_ij != state_ji || !(factor_ij ≈ factor_ji)
                        failed[] = true
                        break
                    end
                end
                if failed[]
                    break
                end
            end
            if failed[]
                break
            end
        end
    end

    return !(failed[])
end

"""
    representative(
        state::SymBasis.DigitBase.BaseInt{T,Ti,B},
        sg::SymGroup{B,T_s,T,Ti,Ts}
    ) where {T<:Integer,Ti<:Integer,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}

Finds the representative state and corresponding factor for a given state under the action
of a symmetry group.

# Arguments
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state for which the
    representative is to be found.
- `sg::`[`SymBasis.SymGroups.SymGroup`](@ref)`{B,T_s,T,Ti,Ts}`: The symmetry group.

# Returns
- `rep_state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The representative state.
- `rep_fac::Ts`: The corresponding factor associated with the representative state.
"""
function representative(
    state::BaseInt{T,Ti,B},
    sg::SymGroup{B,T_s,T,Ti,Ts}
) where {T<:Integer,Ti<:Integer,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}
    n_cycles = length(sg.cycles)

    # Preallocate matrices for temp_stateₛ
    temp_stateₛ = Vector{BaseInt{T,Ti,B}}(undef, n_cycles)

    broadcast!(sg.apply, temp_stateₛ, sg.cycles, state |> Ref)

    id_rep_state = argmin(hash.(temp_stateₛ))

    rep_fac = sg.factors[id_rep_state]
    rep_state = temp_stateₛ[id_rep_state]

    return rep_state, rep_fac
end

"""
    representative(
        state::SymBasis.DigitBase.BaseInt{T,Ti,B},
        csg::CombSymGroup{B,T_s,T,Ti,Ts}
    ) where {T<:Integer,Ti<:Integer,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}

Finds the representative state and corresponding factor for a given state under the action
of a combined symmetry group.

# Arguments
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state for which the
    representative is to be found.
- `csg::`[`SymBasis.SymGroups.CombSymGroup`](@ref)`{B,T_s,T,Ti,Ts}`: The combined symmetry
    group.

# Returns
- `rep_state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The representative state.
- `rep_fac::Ts`: The corresponding factor associated with the representative state.
"""
function representative(
    state::BaseInt{T,Ti,B},
    csg::CombSymGroup{B,T_s,T,Ti,Ts}
) where {T<:Integer,Ti<:Integer,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}
    n_cycles = length(csg.cycles)
    ndims_cycles = ndims(csg.cycles)

    @inbounds out_cycles = [vec([v[dim] for v in csg.cycles]) for dim in 1:ndims_cycles]

    # Preallocate matrices for temp_stateₛ
    temp_stateₛ = Vector{BaseInt{T,Ti,B}}(undef, n_cycles)
    @views fill!(temp_stateₛ, state)

    @inbounds for dim in 1:ndims_cycles
        broadcast!(csg.apply[dim], temp_stateₛ, out_cycles[dim], temp_stateₛ)
    end

    id_rep_state = argmin(hash.(temp_stateₛ))

    rep_fac = csg.factors[id_rep_state]
    rep_state = temp_stateₛ[id_rep_state]

    return rep_state, rep_fac
end
