using BitPermutations: BitPermutation, PermutationBackend

"""
    combos_dof_sum(
        ldof::AbstractVector,
        target,
        n::T_n
    ) where {T_n<:Int}

Generate all combinations of local degree-of-freedom (DoF) values for `n` sites that sum
to the specified `target` value. This is the generic form that works for any discrete DoF,
including both spin systems (rational-valued local DoF) and bosonic systems (integer-valued
occupation numbers).

# Arguments
- `ldof::AbstractVector`: A vector of the possible local DoF values (e.g., `[-1//2, 1//2]`
    for spin-1/2, or `[0, 1, 2, 3]` for bosons with max occupancy 3).
- `target`: The target sum of the local DoF values across all `n` sites. Must be
    comparable to elements of `ldof` under arithmetic (e.g., `Int` or `Rational`).
- `n::T_n`: The number of sites.

# Returns
- `Vector`: A vector of named tuples, each representing a valid combination of DoF
    occupation counts that sum to the target. Each named tuple contains a count `Nj` for
    each local DoF value (indexed `j = 0, 1, …`) and the total number of sites `N`.
"""
function combos_dof_sum(
    ldof::AbstractVector,
    target,
    n::T_n
) where {T_n<:Int}
    n_ldof = length(ldof)

    # Represent everything as Rational for uniform arithmetic.
    ldofR = Rational{Int}.(ldof)
    targetR = Rational{Int}(target)

    # Find a common denominator and scale to integers for the recursion.
    denom = lcm(denominator.(ldofR)..., denominator(targetR))
    S = Int.(ldofR .* denom)
    targetI = Int(targetR * denom)

    configs = Vector{Vector{eltype(ldofR)}}()
    counts = zeros(T_n, n_ldof)

    function rec(i::Int, remaining::Int, sumval::Int)
        if i == n_ldof
            c = remaining
            if sumval + S[i] * c == targetI
                counts[i] = c
                push!(configs, vcat([fill(ldofR[j], counts[j]) for j in 1:n_ldof]...))
            end
            return
        end

        for c in 0:remaining
            counts[i] = c
            rec(i + 1, remaining - c, sumval + S[i] * c)
        end
    end

    rec(1, n, 0)
    return _configs_to_namedtuples(ldofR, n, configs)
end

"""
    combos_spin_sum(
        s::T_s,
        target::Union{T_s,Int},
        n::T_n
    ) where {T_s<:Rational,T_n<:Int}

Generate all combinations of spin projections for `n` spins of size `s` that sum to the
specified `target` value.

# Arguments
- `s::T_s`: The spin size (e.g., `1//2`, `1//1`, `3//2`, etc.).
- `target::Union{T_s,Int}`: The target sum of spin projections.
- `n::T_n`: The number of spins.

# Returns
- `Vector`: A vector of named tuples, each representing a valid combination of spin
    projections that sum to the target. Each named tuple contains counts of each spin
    projection and the total number of spins `N`.
"""
function combos_spin_sum(
    s::T_s,
    target::Union{T_s,Int},
    n::T_n
) where {T_s<:Rational,T_n<:Int}
    n_ldof = numerator(2s + 1)
    ldof = ((0:(n_ldof-1)) .- s) |> collect

    # Integer-scaled projections:
    S = ldof .|> numerator

    # Scale target to the same units (works for odd/even n and any rational s):
    targetR = target isa Int ? target // 1 : target
    targetI = Int(numerator(targetR * denominator(s)))  # scale by denom(s)

    configs = Vector{Vector{Rational{Int}}}()
    counts = zeros(T_n, length(S))

    function rec(i::Int, remaining::Int, sumval::Int)
        if i == length(S)
            c = remaining
            if sumval + S[i] * c == targetI
                counts[i] = c
                # Build a representative config: each projection repeated counts[j] times.
                push!(configs, vcat([fill(ldof[j], counts[j]) for j in 1:n_ldof]...))
            end
            return
        end

        for c in 0:remaining
            counts[i] = c
            rec(i + 1, remaining - c, sumval + S[i] * c)
        end
    end

    rec(1, n, 0)
    return _configs_to_namedtuples(ldof, n, configs)
end

"""
    combos_boson_sum(
        max_occupancy::Integer,
        target::Integer,
        n::T_n
    ) where {T_n<:Int}

Generate all combinations of boson occupation numbers for `n` sites with a maximum
occupancy of `max_occupancy` that sum to the specified `target` total particle number.

# Arguments
- `max_occupancy::Integer`: The maximum number of bosons allowed on a single site
    (e.g., `3` for occupation numbers `0, 1, 2, 3`).
- `target::Integer`: The target total particle number (sum of all site occupancies).
- `n::T_n`: The number of sites.

# Returns
- `Vector`: A vector of named tuples, each representing a valid combination of site
    occupation counts that sum to the target. Each named tuple contains a count `Nj` for
    each occupation level `j = 0, 1, …, max_occupancy` and the total number of sites `N`.
"""
function combos_boson_sum(
    max_occupancy::Integer,
    target::Integer,
    n::T_n
) where {T_n<:Int}
    ldof = collect(0:max_occupancy)
    return combos_dof_sum(ldof, target, n)
end

"""
    combos_dof_sum_weighted(
        weight_lists::NTuple{K,<:AbstractVector{<:Integer}},
        targets::NTuple{K,<:Integer},
        n::T_n
    ) where {K,T_n<:Int}

Generate all per-digit occupation-count vectors `(N0, N1, …, N(n_ldof-1))` for `n` sites (one
count per local digit value `0, …, n_ldof-1`) such that `sum(Nj) == n` and, for every
`k = 1, …, K`, `sum(Nj * weight_lists[k][j+1] for j) == targets[k]`.

Unlike [`combos_dof_sum`](@ref), this enumerates directly over per-digit *positions* rather
than reconstructing counts from a flat list of values, so it stays correct when the weight
vector(s) contain repeated values — as happens, e.g., for `SpinfulFermion`, where distinct
digits can carry the same total particle count (or the same spin-up/spin-down count).

# Arguments
- `weight_lists::NTuple{K,<:AbstractVector{<:Integer}}`: `K` weight vectors, each of length
    `n_ldof` (the number of local digit values), giving the contribution of each digit value
    to the `k`-th conserved quantity.
- `targets::NTuple{K,<:Integer}`: The target value for each of the `K` conserved quantities.
- `n::T_n`: The number of sites.

# Returns
- `Vector`: A vector of named tuples, each with fields `N0, …, N(n_ldof-1), N` (matching the
    shape expected by [`SymBasis.SymGroups.check_Nₛ`](@ref)/[`SymBasis.SymGroups.apply_Nₛ`](@ref)).
"""
function combos_dof_sum_weighted(
    weight_lists::NTuple{K,<:AbstractVector{<:Integer}},
    targets::NTuple{K,<:Integer},
    n::T_n
) where {K,T_n<:Int}
    n_ldof = length(weight_lists[1])
    @assert all(==(n_ldof), length.(weight_lists))

    names = NTuple{n_ldof,Symbol}(Symbol("N$j") for j in 0:(n_ldof-1))
    NT = NamedTuple{names,NTuple{n_ldof,T_n}}
    names_last = (names..., Symbol("N"))
    NT_last = NamedTuple{names_last,NTuple{n_ldof + 1,T_n}}

    res = Vector{NT_last}()
    counts = zeros(T_n, n_ldof)
    targetsI = Int.(targets)

    function rec(i::Int, remaining::Int, sums::NTuple{K,Int})
        if i == n_ldof
            c = remaining
            new_sums = ntuple(k -> sums[k] + Int(weight_lists[k][i]) * c, K)
            if new_sums == targetsI
                counts[i] = c
                nt = merge(NT(ntuple(j -> counts[j], n_ldof)), (; N=n))
                push!(res, nt)
            end
            return
        end

        for c in 0:remaining
            counts[i] = c
            rec(i + 1, remaining - c, ntuple(k -> sums[k] + Int(weight_lists[k][i]) * c, K))
        end
    end

    rec(1, Int(n), ntuple(_ -> 0, K))
    return res
end

# Generic helper: builds named-tuple results from a raw list of per-site configs.
function _configs_to_namedtuples(
    ldof::AbstractVector,
    n::T_n,
    configs::Vector{<:AbstractVector}
) where {T_n<:Int}
    n_ldof = length(ldof)

    names = NTuple{n_ldof,Symbol}(Symbol("N$j") for j in 0:(n_ldof-1))
    NT = NamedTuple{names,NTuple{n_ldof,T_n}}
    names_last = (names..., Symbol("N"))
    NT_last = NamedTuple{names_last,NTuple{n_ldof + 1,T_n}}

    seen = Set{NT_last}()
    res = Vector{NT_last}()
    for config in configs
        counts = NT(ntuple(j -> T_n(count(==(ldof[j]), config)), n_ldof))
        nt = merge(counts, (; N=n))
        nt ∉ seen && (push!(seen, nt); push!(res, nt))
    end
    return res
end

"""
    all_permutations(t::NTuple{N,T}) where {N,T}

Generate all permutations of the elements in the input tuple `t`.

# Arguments
- `t::NTuple{N,T}`: An N-tuple containing elements of type `T`.

# Returns
- `Vector{NTuple{N,T}}`: A vector containing all permutations of the input tuple `t`.
"""
function all_permutations(t::NTuple{N,T}) where {N,T}
    N == 1 && return [t]
    result = NTuple{N,T}[]
    for i in 1:N
        rest = ntuple(j -> t[j < i ? j : j + 1], N - 1)
        for p in all_permutations(rest)
            push!(result, (t[i], p...))
        end
    end
    return result
end

"""
    perm_k(perm::AbstractVector{T_lsi}, k) where {T_lsi<:Integer}

Apply the permutation `perm` repeatedly `k` times.

# Arguments
- `perm::AbstractVector{T_lsi}`: The permutation to be applied.
- `k::Integer`: The number of times to apply the permutation.

# Returns
- `Vector{T_lsi}`: The resulting permutation after applying `perm` `k` times.
"""
function perm_k(perm::AbstractVector{T_lsi}, k) where {T_lsi<:Integer}
    A = 1:length(perm) .|> T_lsi
    for _ in 1:k
        A .= A[perm]
    end

    return A
end

"""
    perm_wrapper(perm::AbstractVector{T_lsi}, base::Integer) where {T_lsi<:Integer}
    perm_wrapper(
        perm::AbstractVector{<:Integer}, base::Integer, ::Type{T}
    ) where {T<:Integer}

Wrap the permutation `perm` in a `BitPermutations.BitPermutation` if the specified `base` is
2, otherwise return `perm` as is.

`T` is the integer type the *states* being permuted are stored in, which is what the
resulting `BitPermutation` must be parameterized on: `SymBasis.SymGroups.apply_perm` applies
it to a [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,2}`, and that method only matches when the
two agree. It is a separate argument because the permutation vector's own element type is an
indexing type (`Ti`, typically `Int`) with no relation to the state storage type -- deriving
the wrapper type from the vector instead silently restricted every permutation symmetry to
DoF-objects left at the default `T = UInt`.

The two-argument form keeps the previous behaviour of deriving the type from the permutation
vector, for callers that permute `UInt`-backed states.

# Arguments
- `perm::AbstractVector{T_lsi}`: The permutation to be wrapped.
- `base::Integer`: The base to determine whether to wrap the permutation in a
    `BitPermutations.BitPermutation`.
- `::Type{T}`: The integer type the permuted states are stored in.

# Returns
- `Union{BitPermutations.BitPermutation{unsigned(T)}, AbstractVector{T_lsi}}`: The
    wrapped permutation if `base` is 2, or the original permutation otherwise.
"""
function perm_wrapper(perm::AbstractVector{T_lsi}, base::Integer) where {T_lsi<:Integer}
    return perm_wrapper(perm, base, T_lsi)
end

function perm_wrapper(
    perm::AbstractVector{<:Integer}, base::Integer, ::Type{T}
) where {T<:Integer}
    if base == 2
        return BitPermutation{unsigned(T)}(perm)
    else
        return perm
    end
end


"""
    rtoldefault(x::Union{T,Type{T}}, y::Union{S,Type{S}}, atol::Real) where {T<:Number,S<:Number}

Compute a default relative tolerance based on the types of `x` and `y` and the provided absolute tolerance.

# Arguments
- `x::Union{T,Type{T}}`: A value or type of the first operand.
- `y::Union{S,Type{S}}`: A value or type of the second operand.
- `atol::Real`: The absolute tolerance threshold.

# Returns
- `Real`: The default relative tolerance. If `atol > 0`, returns zero (absolute tolerance takes precedence).
    Otherwise, returns the maximum of the default relative tolerances for the real parts of types `T` and `S`.
"""
function rtoldefault(x::Union{T,Type{T}}, y::Union{S,Type{S}}, atol::Real) where {T<:Number,S<:Number}
    rtol = max(rtoldefault(real(T)), rtoldefault(real(S)))
    return atol > 0 ? zero(rtol) : rtol
end

"""
    rtoldefault(::Type{T}) where {T<:AbstractFloat}

Compute the default relative tolerance for a floating-point type as the square root of machine epsilon.

# Arguments
- `T::Type{<:AbstractFloat}`: A floating-point type.

# Returns
- `AbstractFloat`: The square root of the machine epsilon for type `T`.
"""
rtoldefault(::Type{T}) where {T<:AbstractFloat} = sqrt(eps(T))

"""
    rtoldefault(::Type{<:Real})

Compute the default relative tolerance for a non-floating-point real type.

# Returns
- `Int`: Returns zero, as non-floating-point real types have exact arithmetic.
"""
rtoldefault(::Type{<:Real}) = 0

"""
    invperm(perm::BitPermutation{T,<:PermutationBackend{T}}) where {T}

Compute the inverse of a bit permutation.

# Arguments
- `perm::BitPermutation{T,<:PermutationBackend{T}}`: The bit permutation for which to
    compute the inverse.

# Returns
- `Vector{T}`: The inverse of the input bit permutation, returned as a standard vector.
"""
function invperm(perm::BitPermutation{T,<:PermutationBackend{T}}) where {T}
    return Base.invperm(Vector(perm))
end

invperm(perm::AbstractVector{<:Integer}) = Base.invperm(perm)
