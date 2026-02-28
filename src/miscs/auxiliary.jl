using BitPermutations: BitPermutation

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
    return _configs_to_namedtuples(s, n, configs)
end

function _configs_to_namedtuples(
    s::T_s,
    n::T_n,
    configs::Vector{Vector{Rational{Int}}}
) where {T_s<:Rational,T_n<:Int}
    n_ldof = numerator(2s + 1)
    ldof = ((0:(n_ldof-1)) .- s) |> collect

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

Wrap the permutation `perm` in a `BitPermutations.BitPermutation` if the specified `base` is
2, otherwise return `perm` as is.

# Arguments
- `perm::AbstractVector{T_lsi}`: The permutation to be wrapped.
- `base::Integer`: The base to determine whether to wrap the permutation in a
    `BitPermutations.BitPermutation`.

# Returns
- `Union{BitPermutations.BitPermutation{unsigned(T_lsi)}, AbstractVector{T_lsi}}`: The
    wrapped permutation if `base` is 2, or the original permutation otherwise.
"""
function perm_wrapper(perm::AbstractVector{T_lsi}, base::Integer) where {T_lsi<:Integer}
    if base == 2
        return BitPermutation{unsigned(T_lsi)}(perm)
    else
        return perm
    end
end
