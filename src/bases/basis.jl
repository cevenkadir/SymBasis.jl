
using SymBasis.DigitBase: BaseInt, BaseIntRange, base_number_to_string
using SymBasis.SymGroups: SymGroup, CombSymGroup
using SymBasis.DoFObjects: DoFObject

"""
    Basis{T,T_n<:Number}
    Basis(
        states::AbstractVector{T},
        norms::AbstractVector{T_n},
        sg::Union{SymGroup,CombSymGroup,Nothing}=nothing
    ) where {T,T_n<:Number}

A basis struct consisting of a collection of basis states and their corresponding norms. The
basis states are represented using [`SymBasis.DigitBase.BaseInt`](@ref), which allows for
efficient representation and manipulation of states in different bases.

# Fields
- `states::AbstractVector{T}`: A vector of basis states, where `T` is the type of the basis
    states.
- `norms::AbstractVector{T_n}`: A vector of norms corresponding to each basis state, where
    `T_n` is the data type for the norms.
- `sg::Union{SymGroup,CombSymGroup,Nothing}`: An optional symmetry group associated with the
    basis. It can be either a [`SymBasis.SymGroups.SymGroup`](@ref) or a
    [`SymBasis.SymGroups.CombSymGroup`](@ref), or `nothing` if no symmetry group is
    associated.

# Constructor Arguments
- `states::AbstractVector{T}`: A vector of basis states, where `T` is the type of the basis
    states.
- `norms::AbstractVector{T_n}`: A vector of norms corresponding to each basis state.
- `sg::Union{SymGroup,CombSymGroup,Nothing}`: An optional symmetry group associated with the
    basis.

# Returns
- [`SymBasis.Bases.Basis`](@ref)`{T,T_n}`: A new [`SymBasis.Bases.Basis`](@ref) instance
    containing the provided states, norms and optional symmetry group.

The constructor checks that the length of states matches the length of norms to ensure
consistency.
"""
struct Basis{T,T_n<:Number}
    states::AbstractVector{T}
    norms::AbstractVector{T_n}
    sg::Union{SymGroup,CombSymGroup,Nothing}
    function Basis(
        states::AbstractVector{T},
        norms::AbstractVector{T_n},
        sg::Union{SymGroup,CombSymGroup,Nothing}=nothing
    ) where {T,T_n<:Number}
        @assert length(states) == length(norms) "Length of states and norms must be equal"
        return new{T,T_n}(states, norms, sg)
    end
end

function Base.isequal(b1::Basis{T,T_n}, b2::Basis{T,T_n}) where {T,T_n}
    return b1.states == b2.states && b1.norms == b2.norms && b1.sg == b2.sg
end

function Base.:(==)(b1::Basis{T,T_n}, b2::Basis{T,T_n}) where {T,T_n}
    return b1.states == b2.states && b1.norms == b2.norms && b1.sg == b2.sg
end

function Base.hash(b::Basis, h::UInt)
    return hash(b.states, hash(b.norms, hash(b.sg, hash(:BaseNumber, h))))
end

Base.iterate(b::Basis) = (b.states, Val(:norms))
Base.iterate(b::Basis, ::Val{:norms}) = (b.norms, Val(:sg))
Base.iterate(b::Basis, ::Val{:sg}) = (b.sg, Val(:done))
Base.iterate(b::Basis, ::Val{:done}) = nothing

function Base.summary(io::IO, b::Basis{T,T_n}) where {T,T_n}
    print(io, "Basis{$T,$T_n} with ", length(b.states), " states")
end

function Base.show(io::IO, b::Basis{T,T_n}) where {T,T_n}
    compact = get(io, :compact, false)
    print(io, "Basis{$T,$T_n}(")
    if compact
        print(io, "states=", length(b.states), ", norms=", length(b.norms))
    else
        print(io, "\n\tstates = ")
        show(io, b.states)
        print(io, ",\n\tnorms  = ")
        show(io, b.norms)
        print(io, "\n")
    end
    print(io, ")")
end

function Base.show(
    io::IO, ::MIME"text/plain", b::Basis{T,Tn}
) where {T,Tn}
    n = length(b.states)
    println(io, "Basis{$T,$Tn} with $n state$(n == 1 ? "" : "s")")

    # shorter indent (2 spaces)
    ind = "  "
    ind2 = "    "

    println(io, ind, "states: ", typeof(b.states))
    println(io, ind, "norms : ", typeof(b.norms))
    println(io, ind, "symmetry group: ", typeof(b.sg))

    n == 0 && return

    m = min(n, get(io, :limit, true) ? 10 : n)
    println(io, ind, "first $(m) state$(m == 1 ? "" : "s")/norm$(m == 1 ? "" : "s"):")

    st_strs = [sprint(show, b.states[i]) for i in 1:m]
    wmax = maximum(textwidth.(st_strs))
    gap = 2

    for i in 1:m
        s = st_strs[i]
        print(io, ind2, s)
        print(io, ' '^max(gap, wmax - textwidth(s) + gap))
        print(io, "(norm=")
        show(io, b.norms[i])
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
    ) where {B,T_s,T,Ti}

Generates the full basis for a DoF-object without symmetry considerations.

# Arguments
- `dofo::`[`SymBasis.DoFObjects.DoFObject`](@ref)`{B,T_s,T,Ti}`: The DoF-object for which
    the basis is to be generated.
- `N::Integer`: The number of sites or particles.

# Keyword Arguments
- `norm_type::DataType=Float64`: The data type for the norms of the basis states. Default is
    `Float64`.
- `is_sorted::Bool=false`: Whether to sort the basis states in ascending order. Default is
    `false`.

# Returns
- [`SymBasis.Bases.Basis`](@ref): The generated basis.
"""
function basis(
    dofo::DoFObject{B,T_s,T,Ti},
    N::Integer;
    norm_type::DataType=Float64,
    is_sorted::Bool=false
) where {B,T_s,T,Ti}
    states = collect(BaseInt(T(0); base=B, Ti=Ti):BaseInt(T(B^N - 1); base=B, Ti=Ti))
    norms = ones(norm_type, length(states))
    if is_sorted
        sorted_indices = sortperm(states)
        return Basis(states[sorted_indices], norms[sorted_indices])
    else
        return Basis(states, norms)
    end
end

function _basis_impl(
    all_bints::BaseIntRange{T,Ti,B},
    n_cycles::Int,
    sg::Union{SymGroup{B,T_s,T,Ti,Ts},CombSymGroup{B,T_s,T,Ti,Ts}},
    F₀::Complex{T_n},
    eps_norm_type::T_n,
    get_temp_state,
    is_sorted::Bool
) where {T,Ti,B,T_n<:Real,T_s,Ts}
    nthreads = Threads.nthreads()

    tasks = map(Iterators.partition(all_bints, length(all_bints) ÷ nthreads + 1)) do chunk
        Threads.@spawn begin
            local_norms = T_n[]
            local_states = BaseInt{T,Ti,B}[]
            local_F = F₀
            local_hashbuf = Vector{UInt}(undef, n_cycles)
            local_count = 0

            for state₀ in chunk
                local_F = F₀
                h_state₀ = hash(state₀)
                local_count = 0

                @inbounds for idx in 1:n_cycles
                    is_valid_state, temp_state, temp_phase = get_temp_state(idx, state₀)

                    if is_valid_state
                        h_temp_state = hash(temp_state)

                        is_new = true
                        @inbounds for k in 1:local_count
                            if local_hashbuf[k] == h_temp_state
                                is_new = false
                                break
                            end
                        end
                        if is_new
                            local_count += 1
                            @inbounds local_hashbuf[local_count] = h_temp_state
                        end

                        if h_temp_state < h_state₀
                            local_F = F₀
                            break
                        elseif h_temp_state == h_state₀
                            local_F += sg.factors[idx] * temp_phase
                        end
                    end
                end

                norm₀ = local_count * abs2(local_F)
                if norm₀ > eps_norm_type
                    push!(local_norms, norm₀)
                    push!(local_states, state₀)
                end
            end

            (local_states, local_norms)
        end
    end

    results = fetch.(tasks)
    states = vcat((r[1] for r in results)...)
    norms = vcat((r[2] for r in results)...)

    if is_sorted
        sorted_indices = sortperm(states)
        return Basis(states[sorted_indices], norms[sorted_indices], sg)
    else
        return Basis(states, norms, sg)
    end
end

"""
    basis(
        dofo::DoFObject{B,T_s,T,Ti},
        N::Integer,
        sg::SymGroup{B,T_s,T,Ti,Ts};
        norm_type=Float64
    ) where {T,Ti,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}

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
- `is_sorted::Bool=false`: Whether to sort the basis states in ascending order. Default is
    `false`.

# Returns
- [`SymBasis.Bases.Basis`](@ref): The generated symmetry-resolved basis.
"""
function basis(
    dofo::DoFObject{B,T_s,T,Ti},
    N::Integer,
    sg::SymGroup{B,T_s,T,Ti,Ts};
    norm_type::DataType=Float64,
    is_sorted::Bool=false
) where {T,Ti,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}
    F₀ = zero(Complex{norm_type})
    eps_norm_type = eps(norm_type)
    c = true
    all_bints = BaseInt(T(0); base=B, Ti=Ti):BaseInt(T(B^N - 1); base=B, Ti=Ti)

    get_temp_state = (idx, state₀) -> begin
        cycleᵢ = sg.cycles[idx]
        temp_state = sg.apply(cycleᵢ, state₀)
        temp_phase = sg.phase(cycleᵢ, state₀)
        (sg.check(cycleᵢ, temp_state, c), temp_state, temp_phase)
    end

    return _basis_impl(
        all_bints,
        length(sg.cycles),
        sg,
        F₀,
        eps_norm_type,
        get_temp_state,
        is_sorted
    )
end

"""
    basis(
        dofo::DoFObject{B,T_s,T,Ti},
        N::Integer,
        csg::CombSymGroup{B,T_s,T,Ti,Ts};
        norm_type::DataType=Float64,
        is_sorted::Bool=false
    ) where {T,Ti,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}

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
- `is_sorted::Bool=false`: Whether to sort the basis states in ascending order. Default is
    `false`.

# Returns
- [`SymBasis.Bases.Basis`](@ref): The generated symmetry-resolved basis.
"""
function basis(
    dofo::DoFObject{B,T_s,T,Ti},
    N::Integer,
    csg::CombSymGroup{B,T_s,T,Ti,Ts};
    norm_type::DataType=Float64,
    is_sorted::Bool=false
) where {T,Ti,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}
    F₀ = zero(Complex{norm_type})
    eps_norm_type = eps(norm_type)
    c = true
    ndims_cycles = ndims(csg.cycles)
    all_bints = BaseInt(T(0); base=B, Ti=Ti):BaseInt(T(B^N - 1); base=B, Ti=Ti)

    get_temp_state = (idx, state₀) -> begin
        is_valid = c
        temp_state = state₀
        temp_phase = 1
        cycle = csg.cycles[idx]
        for i in 1:ndims_cycles
            is_valid || break
            is_valid = csg.check[i](cycle[i], state₀, is_valid)
        end
        if is_valid
            for i in 1:ndims_cycles
                phaseᵢ = csg.phase[i](cycle[i], temp_state)
                temp_state = csg.apply[i](cycle[i], temp_state)
                temp_phase *= phaseᵢ
            end
        end
        (is_valid, temp_state, temp_phase)
    end

    return _basis_impl(
        all_bints,
        length(csg.cycles),
        csg,
        F₀,
        eps_norm_type,
        get_temp_state,
        is_sorted
    )
end

"""
    is_commutative(b::Basis, csg::CombSymGroup)

Checks whether the given symmetries commute with each other in the given basis.

# Arguments
- `b::`[`SymBasis.Bases.Basis`](@ref): The basis to be checked.
- `csg::`[`SymBasis.SymGroups.CombSymGroup`](@ref): The combined symmetry group under which
    the basis states are expected to be consistent.

# Returns
- `Bool`: Returns `true` if the basis states are consistent under the action of the combined
    symmetry group, and `false` otherwise.
"""
function is_commutative(b::Basis, csg::CombSymGroup)
    if b.sg != csg
        @warn "The symmetry group of the basis does not match the provided combined symmetry group."
    end

    n_cycles = csg.cycles |> length
    ndims_cycles = csg.cycles |> ndims
    nthreads = Threads.nthreads()

    state_indices = eachindex(b.states)

    # Partition work and spawn tasks
    tasks = map(
        Iterators.partition(state_indices, length(state_indices) ÷ nthreads + 1)
    ) do chunk
        Threads.@spawn begin
            for s_idx in chunk
                test_state = b.states[s_idx]

                for i in 1:ndims_cycles
                    for j in (i+1):ndims_cycles
                        for cycle_idx in 1:n_cycles
                            cycle = csg.cycles[cycle_idx]

                            # Apply symmetry i then j
                            phase_i = csg.phase[i](cycle[i], test_state)
                            state_ij = csg.apply[i](cycle[i], test_state)
                            phase_j = csg.phase[j](cycle[j], state_ij)
                            state_ij = csg.apply[j](cycle[j], state_ij)
                            state_ij, factor_ij = representative(state_ij, csg)
                            factor_ij *= phase_i * phase_j

                            # Apply symmetry j then i
                            phase_j = csg.phase[j](cycle[j], test_state)
                            state_ji = csg.apply[j](cycle[j], test_state)
                            phase_i = csg.phase[i](cycle[i], state_ji)
                            state_ji = csg.apply[i](cycle[i], state_ji)
                            state_ji, factor_ji = representative(state_ji, csg)
                            factor_ji *= phase_i * phase_j

                            if state_ij != state_ji || !(factor_ij ≈ factor_ji)
                                return false
                            end
                        end
                    end
                end
            end
            return true
        end
    end

    # Fetch results from all tasks - all must be true
    results = fetch.(tasks)
    return all(results)
end

"""
    is_commutative(b::Basis)

Checks whether the symmetries in the basis commute with each other.

# Arguments
- `b::`[`SymBasis.Bases.Basis`](@ref): The basis to be checked.

# Returns
- `Bool`: Returns `true` if the symmetries in the basis commute with each other, and `false`
otherwise.
"""
function is_commutative(b::Basis)
    return is_commutative(b, b.sg)
end

"""
    representative(
        state::SymBasis.DigitBase.BaseInt{T,Ti,B},
        sg::SymGroup{B,T_s,T,Ti,Ts}
    ) where {T,Ti,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}

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
) where {T,Ti,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}
    n_cycles = length(sg.cycles)

    id_rep_state = first(eachindex(sg.cycles))
    rep_phase = sg.phase(sg.cycles[id_rep_state], state)
    rep_state = sg.apply(sg.cycles[id_rep_state], state)
    h_rep_state = hash(rep_state)

    @inbounds for idx in 2:n_cycles
        temp_phase = sg.phase(sg.cycles[idx], state)
        temp_state = sg.apply(sg.cycles[idx], state)
        h_temp_state = hash(temp_state)

        if h_temp_state < h_rep_state
            id_rep_state = idx
            rep_state = temp_state
            rep_phase = temp_phase
            h_rep_state = h_temp_state
        end
    end

    rep_fac = rep_phase * sg.factors[id_rep_state]

    return rep_state, rep_fac
end

"""
    representative(
        state::SymBasis.DigitBase.BaseInt{T,Ti,B},
        csg::CombSymGroup{B,T_s,T,Ti,Ts}
    ) where {T,Ti,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}

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
) where {T,Ti,B,T_s,T_n<:Real,Ts<:Union{T_n,Complex{T_n}}}
    n_cycles = length(csg.cycles)
    ndims_cycles = ndims(csg.cycles)

    # Initialize with first cycle
    rep_state = state
    rep_phase = one(Ts)
    @inbounds for dim in 1:ndims_cycles
        phaseᵢ = csg.phase[dim](csg.cycles[1][dim], rep_state)
        rep_state = csg.apply[dim](csg.cycles[1][dim], rep_state)
        rep_phase *= phaseᵢ
    end
    h_rep_state = hash(rep_state)
    id_rep_state = 1

    @inbounds for idx in 2:n_cycles
        cycle = csg.cycles[idx]
        temp_state = state
        temp_phase = one(Ts)

        for dim in 1:ndims_cycles
            phaseᵢ = csg.phase[dim](cycle[dim], temp_state)
            temp_state = csg.apply[dim](cycle[dim], temp_state)
            temp_phase *= phaseᵢ
        end

        h_temp_state = hash(temp_state)

        if h_temp_state < h_rep_state
            id_rep_state = idx
            rep_state = temp_state
            rep_phase = temp_phase
            h_rep_state = h_temp_state
        end
    end

    rep_fac = rep_phase * csg.factors[id_rep_state]

    return rep_state, rep_fac
end

"""
    representative(
        state::BaseInt{T,Ti,B},
        basis::Basis{BaseInt{T,Ti,B},T_n}
    ) where {T,Ti,B,T_n}

Finds the representative state and corresponding factor for a given state under the action
of the symmetry group associated with the provided basis.

# Arguments
- `state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The state for which the
    representative is to be found.
- `basis::`[`SymBasis.Bases.Basis`](@ref)`{BaseInt{T,Ti,B},T_n}`: The basis containing the
    symmetry group.

# Returns
- `rep_state::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The representative state.
- `rep_fac`: The corresponding factor associated with the representative state.
"""
function representative(
    state::BaseInt{T,Ti,B}, basis::Basis{BaseInt{T,Ti,B},T_n}
) where {T,Ti,B,T_n}
    if basis.sg isa Nothing
        return state
    else
        return representative(state, basis.sg)
    end
end
