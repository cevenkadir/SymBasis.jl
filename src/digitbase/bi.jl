# START -- General digit-base integer type and associated functions
"""
    BaseInt{T<:Integer,Ti<:Integer,B}
    BaseInt(
        value::T;
        base::Integer=2,
        Ti=Int
    ) where T<:Integer
    BaseInt{T,Ti,B}(value::Integer) where {T<:Integer,Ti<:Integer,B}

A type representing an integer in base `B`, where `T` is the underlying integer type used to
store the value, and `Ti` is the integer type used for indexing digits.

# Fields
- `value::T`: The integer value representing the number in base `B`.

# Constructor Arguments
- `value::T`: The integer value to be represented in base `B`.

# Constructor Keyword Arguments
- `base::Integer=2`: The base in which to represent the integer. Default is `2`.
- `Ti=Int`: The integer type used for indexing digits. Default is `Int`.

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: A new `BaseInt` instance.

The constructor checks that the base is at least 2.

There is also a fully static constructor, `BaseInt{T,Ti,B}(value::Integer)`, used
internally on hot paths throughout this module. With `B` already fixed in the type domain,
it skips the runtime `base` check and keyword handling that the general constructor
performs, and simply converts `value` to `T`.
"""
struct BaseInt{T<:Integer,Ti<:Integer,B}
    value::T

    function BaseInt(value::T; base::Integer=2, Ti=Int) where T<:Integer
        @assert base >= 2 "Base must be at least 2, got $base"
        return new{T,Ti,base}(value)
    end

    # Fully static constructor for hot paths: with `B` in the type domain, no keyword
    # handling or runtime base checks are needed.
    function BaseInt{T,Ti,B}(value::Integer) where {T<:Integer,Ti<:Integer,B}
        return new{T,Ti,B}(T(value))
    end
end

"""
    Base.copy(b::SymBasis.DigitBase.BaseInt{T,Ti,B}) where {T,Ti,B}

Create a copy of the [`SymBasis.DigitBase.BaseInt`](@ref) instance `b`.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The
    [`SymBasis.DigitBase.BaseInt`](@ref) instance to copy.

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: A new [`SymBasis.DigitBase.BaseInt`](@ref)
    instance with the same value as `b`.
"""
function Base.copy(b::BaseInt{T,Ti,B}) where {T,Ti,B}
    return BaseInt{T,Ti,B}(b.value |> copy)
end

"""
    bi"..."B

Create a [`SymBasis.DigitBase.BaseInt`](@ref) instance from a string representation of a
number in the specified base `B`.

# Arguments
- `str::String`: The string representation of the number.
- `B::Integer`: The base in which the number is represented.

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{UInt,Int,B}`: The
    [`SymBasis.DigitBase.BaseInt`](@ref) instance representing the number.
"""
macro bi_str(str::String, base::Integer)
    digit_values = [parse(Int, string(c)) for c in str]
    @assert all(x -> 0 <= x < base, digit_values) """entered numbers do not
    follow given base"""
    return BaseInt(evalpoly(base, reverse(digit_values)) |> UInt, base=base)
end


function Base.:(==)(b1::TB, b2::TB) where {TB<:BaseInt}
    return b1.value == b2.value
end

function Base.isequal(b1::TB, b2::TB) where {TB<:BaseInt}
    return isequal(b1.value, b2.value)
end

function Base.hash(b::BaseInt{T,Ti,B}, h::UInt) where {T,Ti,B}
    return hash(B, hash(b.value, hash(:BaseNumber, h)))
end

function Base.length(::BaseInt)
    return 1
end

function Base.iterate(b::BaseInt)
    return (b, nothing)
end

function Base.iterate(::BaseInt, state)
    return nothing
end

function Base.isless(b1::TB, b2::TB) where {TB<:BaseInt}
    return b1.value < b2.value
end

subscript(i::Integer) = join(Char(0x2080 + d) for d in reverse!(digits(i)))

function base_number_to_string(b::BaseInt{T,Ti,B}; pad::Integer=1) where {T,Ti,B}
    str = string(b.value, base=B, pad=pad)
    return "($str)$(subscript(B))"
end

function Base.show(io::IO, b::BaseInt)
    print(io, base_number_to_string(b))
end
# END -- General digit-base integer type and associated functions

# START -- Digit manipulation functions

# When the base is a power of two, a digit occupies a fixed bit field, so the place value
# `B^(pos-1)` is a shift and the digit itself is a shift plus a mask -- no runtime power and,
# more importantly, no hardware division. `B` is a type parameter, so `ispow2(B)` is folded at
# compile time and only one of the two branches survives in the generated code. For every
# other base the original `B^(pos-1)` / `÷` / `%` arithmetic is kept exactly as it was,
# including its integer-promotion behaviour for narrow `T`.
@inline _base_shift(::Val{B}) where {B} = trailing_zeros(B)

# Exactly `B^k`, same `Int` type and same value (including the wrapping of large `k`), so it
# is a drop-in for the place values that feed the mixed-type arithmetic and overflow checks
# below -- only cheaper to compute.
@inline function _base_pow(::Val{B}, k::Integer) where {B}
    ispow2(B) && return one(Int) << (_base_shift(Val(B)) * k)
    return B^k
end

# `value` is not necessarily the state's own `T`: integer promotion can widen it (e.g. a
# `UInt8`-backed state whose intermediate value became an `Int`), so dispatch on what is
# actually passed. The shift is only equivalent to the division for unsigned values -- `>>`
# on a negative signed integer is arithmetic, `÷` truncates -- hence the `V <: Unsigned`
# guard, which like `ispow2(B)` is resolved at compile time.
@inline function _digit_at(value::V, ::Val{B}, pos::Integer) where {V<:Integer,B}
    (ispow2(B) && V <: Unsigned) &&
        return (value >> (_base_shift(Val(B)) * (pos - 1))) & V(B - 1)
    return (value ÷ B^(pos - 1)) % B
end

# Discard the `k` least-significant digits, so that digit `k+1` becomes digit 1. Used to
# start an ordered walk part-way through a state without stepping over the digits below it.
@inline function _drop_low_digits(value::V, ::Val{B}, k::Integer) where {V<:Integer,B}
    (ispow2(B) && V <: Unsigned) && return value >> (_base_shift(Val(B)) * k)
    return value ÷ B^k
end

# An ordered walk of `n` digits starting at position `start`. Walking from position 1 -- by
# far the common case -- needs no repositioning at all, so it must not pay for one.
@inline function _walk_from(b::BaseInt{T,Ti,B}, start::Integer, n::Integer) where {T,Ti,B}
    start == 1 && return eachdigit(b, n)
    return eachdigit(
        BaseInt{T,Ti,B}(_drop_low_digits(b.value, Val(B), Int(start) - 1)), n
    )
end

"""
    flip(b::SymBasis.DigitBase.BaseInt{T,Ti,B}, pos::Ti) where {T,Ti,B}

Flip the digit at position `pos` in the base-`B` representation of the integer `b`.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base-`B` integer.
- `pos::Ti`: The position of the digit to flip (1-based indexing).

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: A new [`SymBasis.DigitBase.BaseInt`](@ref)
    instance with the specified digit flipped.
"""
function flip(b::BaseInt{T,Ti,B}, pos::Ti) where {T,Ti,B}
    pos > 0 || throw(ArgumentError("position must be positive, got $pos"))
    B >= 2 || throw(ArgumentError("base must be ≥ 2, got $B"))

    power = _base_pow(Val(B), pos - 1)
    digit = _digit_at(b.value, Val(B), pos)

    new_digit = (B - 1) - digit

    new_digit == digit && return b

    new_value = b.value + (new_digit - digit) * power

    return BaseInt{T,Ti,B}(new_value)
end

"""
    flip(b::SymBasis.DigitBase.BaseInt{T,Ti,B}, pos::AbstractVector{Ti}) where {T,Ti,B}

Flip the digits at the specified positions in the base-`B` representation of the integer
`b`.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base-`B` integer.
- `pos::AbstractVector{Ti}`: The positions of the digits to flip (1-based indexing).

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: A new [`SymBasis.DigitBase.BaseInt`](@ref)
    instance with the specified digits flipped.
"""
function flip(b::BaseInt{T,Ti,B}, pos::AbstractVector{Ti}) where {T,Ti,B}
    new_b = b |> copy

    for posᵢ in pos
        new_b = flip(new_b, posᵢ)
    end

    return new_b
end

"""
    flip(b::SymBasis.DigitBase.BaseInt{T,Ti,2}, pos::Ti) where {T,Ti}

Flip the bit at position `pos` in the base-2 representation of the integer `b`. This is an
optimized specialization for base-2, using bitwise XOR.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,2}`: The base-2 integer.
- `pos::Ti`: The position of the bit to flip (1-based indexing).

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,2}`: A new [`SymBasis.DigitBase.BaseInt`](@ref)
    instance with the specified bit flipped.
"""
function flip(b::BaseInt{T,Ti,2}, pos::Ti) where {T,Ti}
    pos > 0 || throw(ArgumentError("position must be positive, got $pos"))
    mask = one(T) << (pos - 1)
    return BaseInt{T,Ti,2}(b.value ⊻ mask)
end

"""
    flip(b::SymBasis.DigitBase.BaseInt{T,Ti,2}, pos::AbstractVector{Ti}) where {T,Ti}

Flip the bits at the specified positions in the base-2 representation of the integer `b`.
This is an optimized specialization for base-2, using bitwise XOR.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,2}`: The base-2 integer.
- `pos::AbstractVector{Ti}`: The positions of the bits to flip (1-based indexing).

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,2}`: A new [`SymBasis.DigitBase.BaseInt`](@ref)
    instance with the specified bits flipped.
"""
function flip(b::BaseInt{T,Ti,2}, pos::AbstractVector{Ti}) where {T,Ti}
    isempty(pos) && return b
    @inbounds for p in pos
        p > 0 || throw(ArgumentError("position must be positive, got $p"))
    end
    mask = reduce((m, p) -> m | (one(T) << (p - 1)), pos; init=zero(T))
    return BaseInt{T,Ti,2}(b.value ⊻ mask)
end

"""
    inc(b::SymBasis.DigitBase.BaseInt{T,Ti,B}, pos::Ti) where {T,Ti,B}

Increment the digit at position `pos` in the base-`B` representation of the integer `b`.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base-`B` integer.
- `pos::Ti`: The position of the digit to increment (1-based indexing).

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: A new [`SymBasis.DigitBase.BaseInt`](@ref)
    instance with the specified digit incremented.
"""
function inc(b::BaseInt{T,Ti,B}, pos::Ti) where {T,Ti,B}
    pos <= 0 && throw(ArgumentError("digit position must be non-negative"))

    base_pow = _base_pow(Val(B), pos - 1)
    digit = _digit_at(b.value, Val(B), pos)

    new_digit = digit + 1
    carry = new_digit ÷ B
    new_digit = new_digit % B

    new_val = b.value - digit * base_pow + new_digit * base_pow

    pos_next = pos + 1
    while carry != 0
        base_pow_next = _base_pow(Val(B), pos_next - 1)
        current_digit = _digit_at(new_val, Val(B), pos_next)
        new_digit = current_digit + carry
        carry = new_digit ÷ B
        new_digit = new_digit % B

        new_val = new_val - current_digit * base_pow_next + new_digit * base_pow_next
        pos_next += 1
    end

    return BaseInt{T,Ti,B}(new_val)
end

"""
    inc(b::SymBasis.DigitBase.BaseInt{T,Ti,B}, pos::AbstractVector{Ti}) where {T,Ti,B}

Increment the digits at the specified positions in the base-`B` representation of the
integer `b`.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base-`B` integer.
- `pos::AbstractVector{Ti}`: The positions of the digits to increment (1-based indexing).

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: A new [`SymBasis.DigitBase.BaseInt`](@ref)
    instance with the specified digits incremented.
"""
function inc(b::BaseInt{T,Ti,B}, pos::AbstractVector{Ti}) where {T,Ti,B}
    new_b = b |> copy

    for posᵢ in pos
        new_b = inc(new_b, posᵢ)
    end

    return new_b
end

"""
    dec(b::SymBasis.DigitBase.BaseInt{T,Ti,B}, pos::Ti) where {T,Ti,B}

Decrement the digit at position `pos` in the base-`B` representation of the integer `b`.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base-`B` integer.
- `pos::Ti`: The position of the digit to decrement (1-based indexing).

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: A new [`SymBasis.DigitBase.BaseInt`](@ref)
    instance with the specified digit decremented.
"""
function dec(b::BaseInt{T,Ti,B}, pos::Ti) where {T,Ti,B}
    pos <= 0 && throw(ArgumentError("digit position must be non-negative"))

    base_pow = _base_pow(Val(B), pos - 1)
    digit = _digit_at(b.value, Val(B), pos)

    if digit > 0
        new_val = b.value - base_pow
        return BaseInt{T,Ti,B}(new_val)
    else
        pos_next = pos + 1
        while true
            base_pow_next = _base_pow(Val(B), pos_next - 1)
            if base_pow_next > b.value
                break
            end
            current_digit = _digit_at(b.value, Val(B), pos_next)
            if current_digit > 0
                new_val = b.value - base_pow_next
                # Set all positions from pos to pos_next-1 to (B-1)
                for p in pos:(pos_next-1)
                    base_pow_p = _base_pow(Val(B), p - 1)
                    current_digit_p = _digit_at(b.value, Val(B), p)
                    new_val += (B - 1 - current_digit_p) * base_pow_p
                end
                return BaseInt{T,Ti,B}(new_val)
            end
            pos_next += 1
        end

        new_val = b.value + (B - 1) * base_pow
        return BaseInt{T,Ti,B}(new_val)
    end
end

"""
    dec(b::SymBasis.DigitBase.BaseInt{T,Ti,B}, pos::AbstractVector{Ti}) where {T,Ti,B}

Decrement the digits at the specified positions in the base-`B` representation of the
integer `b`.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base-`B` integer.
- `pos::AbstractVector{Ti}`: The positions of the digits to decrement (1-based indexing).

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: A new [`SymBasis.DigitBase.BaseInt`](@ref)
    instance with the specified digits decremented.
"""
function dec(b::BaseInt{T,Ti,B}, pos::AbstractVector{Ti}) where {T,Ti,B}
    new_b = b |> copy

    for posᵢ in pos
        new_b = dec(new_b, posᵢ)
    end

    return new_b
end

"""
    num_digits_in_base(n::Integer, base::Int)

Return the number of digits required to represent the integer `n` in the specified base
`base`.

# Arguments
- `n::Integer`: The integer to evaluate.
- `base::Int`: The base for representation.

# Returns
- `Int`: The number of digits required to represent `n` in base `base`.
"""
function num_digits_in_base(n::Integer, base::Int)
    n == 0 && return 1
    cnt = 0
    while n > 0
        cnt += 1
        n ÷= base
    end
    cnt
end

"""
    permute(b::SymBasis.DigitBase.BaseInt{T,Ti,B}, perm::AbstractVector{Ti}) where {T,Ti,B}

Permute the positions of the digits in the base-`B` representation of the integer `b`
according to the permutation vector `perm`.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base-`B` integer.
- `perm::AbstractVector{Ti}`: The permutation vector, where the `i`-th element
    indicates the new position for the digit originally at position `i`.

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: A new [`SymBasis.DigitBase.BaseInt`](@ref)
    instance with the digits permuted according to `perm`.
"""
function permute(b::BaseInt{T,Ti,B}, perm::AbstractVector{Ti}) where {T,Ti,B}
    B > 1 || throw(ArgumentError("Base must be ≥ 2"))

    n = length(perm)
    @assert all(p -> 1 <= p <= n, perm) "perm must index into 1:length(perm)"

    BB = T(B)

    # digits of b in LSD-first order
    digitsb = Vector{T}(undef, n)
    v = b.value
    @inbounds for i in 1:n
        digitsb[i] = v % BB
        v ÷= BB
    end

    out = zero(T)
    pBk = one(T) # B^(k-1)

    @inbounds for k in 1:n
        out += digitsb[perm[k]] * pBk # place digit perm[k] as k-th LSD digit
        pBk *= BB
    end

    return BaseInt{T,Ti,B}(out)
end

"""
    permute(
        b::SymBasis.DigitBase.BaseInt{T,Ti,B},
        pos::Ti,
        perm::AbstractVector{<:Integer}
    ) where {T,Ti,B}

Permute the digit at position `pos` in the base-`B` representation of the integer `b`
according to the permutation vector `perm`.

*Note*: This function permutes the value of the digit at the specified position, rather than
its position.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base-`B` integer.
- `pos::Ti`: The position of the digit to permute (1-based indexing).
- `perm::AbstractVector{<:Integer}`: The permutation vector, where the `i`-th element
    indicates the new value for the digit originally equal to `i-1`.

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: A new [`SymBasis.DigitBase.BaseInt`](@ref)
    instance with the specified digit permuted according to `perm`.
"""
function permute(
    b::BaseInt{T,Ti,B},
    pos::Ti,
    perm::AbstractVector{<:Integer}
) where {T,Ti,B}
    pos >= 1 || throw(ArgumentError("position must be ≥ 1 (1‑based indexing)"))
    length(perm) == B ||
        throw(ArgumentError("permutation vector must have length equal to the base $B"))
    @boundscheck any(p -> p < 0 || p >= B, perm) &&
                 throw(ArgumentError("permutation entries must be in 0:$(B-1)"))

    power = _base_pow(Val(B), pos - 1)
    old_digit = _digit_at(b.value, Val(B), pos)

    new_digit = perm[old_digit+1]

    new_digit == old_digit && return b

    delta = (new_digit - old_digit) * power

    new_val = b.value + delta

    # overflow check
    T_max = typemax(T)
    (delta > 0) && (new_val > T_max) &&
        throw(OverflowError("incrementing digit causes overflow"))

    return BaseInt{T,Ti,B}(new_val)
end

"""
    permute(
        b::SymBasis.DigitBase.BaseInt{T,Ti,B},
        pos::AbstractVector{Ti},
        perm::AbstractVector{<:Integer}
    ) where {T,Ti,B}

Permute the digits at the specified positions in the base-`B` representation of the integer
`b` according to the permutation vector `perm`.

*Note*: This function permutes the values of the digits at the specified positions, rather
than their positions.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base-`B` integer.
- `pos::AbstractVector{Ti}`: The positions of the digits to permute (1-based indexing).
- `perm::AbstractVector{<:Integer}`: The permutation vector, where the `i`-th element
    indicates the new value for the digit originally equal to `i-1`.

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: A new [`SymBasis.DigitBase.BaseInt`](@ref)
    instance with the specified digits permuted according to `perm`.
"""
function permute(
    b::BaseInt{T,Ti,B},
    pos::AbstractVector{Ti},
    perm::AbstractVector{<:Integer}
) where {T,Ti,B}
    new_b = b |> copy

    for posᵢ in pos
        new_b = permute(new_b, posᵢ, perm)
    end

    return new_b
end

"""
    Base.read(b::SymBasis.DigitBase.BaseInt{T,Ti,B}, pos::Ti) where {T,Ti,B}

Read the digit at position `pos` in the base-`B` representation of the integer `b`.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base-`B` integer.
- `pos::Ti`: The position of the digit to read (1-based indexing).

# Returns
- `T`: The digit at the specified position, as the same integer type used to store `b`'s
    value.
"""
function Base.read(b::BaseInt{T,Ti,B}, pos::Ti) where {T,Ti,B}
    pos >= 1 || throw(ArgumentError("position must be ≥ 1 (1‑based indexing)"))
    B >= 2 || throw(ArgumentError("base must be ≥ 2, got $B"))

    return _digit_at(b.value, Val(B), pos)

end

"""
    Base.read(b::SymBasis.DigitBase.BaseInt{T,Ti,2}, pos::Ti) where {T,Ti}

Read the bit at position `pos` in the base-2 representation of the integer `b`. This is an
optimized specialization for base-2, using bitwise shifts.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,2}`: The base-2 integer.
- `pos::Ti`: The position of the bit to read (1-based indexing).

# Returns
- `T`: The bit at the specified position, as the same integer type used to store `b`'s
    value.
"""
function Base.read(b::BaseInt{T,Ti,2}, pos::Ti) where {T,Ti}
    pos >= 1 || throw(ArgumentError("position must be ≥ 1 (1‑based indexing)"))

    return (b.value >> (pos - 1)) % 2
end

"""
    Base.read(b::SymBasis.DigitBase.BaseInt{T,Ti,B}, pos::AbstractVector{Ti}) where {T,Ti,B}

Read the digits at the specified positions in the base-`B` representation of the integer
`b`.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base-`B` integer.
- `pos::AbstractVector{Ti}`: The positions of the digits to read (1-based indexing).

# Returns
- `Vector{T}`: The digits at the specified positions, as the same integer type used to
    store `b`'s value.
"""
function Base.read(b::BaseInt{T,Ti,B}, pos::AbstractVector{Ti}) where {T,Ti,B}
    return map(pos) do posᵢ
        read(b, posᵢ)
    end
end

"""
    Base.read(b::SymBasis.DigitBase.BaseInt{T,Ti,B}, pos::AbstractUnitRange{Ti}) where {T,Ti,B}

Read the digits over a contiguous range of positions in the base-`B` representation of the
integer `b`.

Because the positions are consecutive, the digits are produced by a single ordered walk (as
in [`eachdigit`](@ref)) rather than one independent lookup per position. For a base that is
not a power of two this is several times faster than the general
[`read(b, pos::AbstractVector)`](@ref) method, which recomputes `B^(pos-1)` for every
position.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base-`B` integer.
- `pos::AbstractUnitRange{Ti}`: The contiguous positions to read (1-based indexing).

# Returns
- `Vector{T}`: The digits at the specified positions, in order.
"""
function Base.read(b::BaseInt{T,Ti,B}, pos::AbstractUnitRange{Ti}) where {T,Ti,B}
    # Match the element type of the per-position method exactly -- integer promotion in the
    # scalar `read` can widen the digit past `T` for a narrow `T`, and base 2 has its own
    # specialization. Asking the same dispatch is the only reliable source; the call itself
    # is elided, only its type survives.
    Td = typeof(read(b, oneunit(Ti)))

    isempty(pos) && return Td[]
    first(pos) >= 1 || throw(ArgumentError("position must be ≥ 1 (1‑based indexing)"))

    out = Vector{Td}(undef, length(pos))
    i = 0
    @inbounds for digit in _walk_from(b, first(pos), length(pos))
        out[i+=1] = digit
    end
    return out
end

"""
    DigitIterator{T,Ti,B}

Iterator over the low-order digits of a [`SymBasis.DigitBase.BaseInt`](@ref), returned by
[`eachdigit`](@ref).

# Fields
- `value::T`: The value whose digits are iterated.
- `n::Int`: The number of digits to produce (LSD-first, zero-padded).
"""
struct DigitIterator{T<:Integer,Ti<:Integer,B}
    value::T
    n::Int
end

"""
    eachdigit(b::SymBasis.DigitBase.BaseInt{T,Ti,B}, n::Integer) where {T,Ti,B}

Iterate the first `n` digits of `b` in base `B`, least-significant digit first, padding
with zeros once the value is exhausted.

Each digit costs one division/remainder pair on a running value, so reading all `n` digits
of a state takes `O(n)` operations in total. Iteration allocates nothing.

When `B` is **not** a power of two, reading the same digits with [`Base.read`](@ref) instead
costs `O(n)` *per digit*, since every call recomputes `B^(pos-1)` — prefer `eachdigit`
whenever a check or operator needs to scan a whole state. When `B` is a power of two, a
digit is a bit field and `read` extracts it with a shift and a mask, so a plain `read` loop
is just as fast (marginally faster, in fact: the positions are independent, whereas the
running value here is a serial dependency). Use whichever reads more clearly there.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base-`B` integer.
- `n::Integer`: The number of digits to produce.

# Returns
- [`SymBasis.DigitBase.DigitIterator`](@ref)`{T,Ti,B}`: An iterator yielding `n` digits of
    type `T`, least-significant first.

# Examples
```jldoctest
julia> using SymBasis

julia> collect(eachdigit(BaseInt(UInt(0b1011); base=2), 5))
5-element Vector{UInt64}:
 0x0000000000000001
 0x0000000000000001
 0x0000000000000000
 0x0000000000000001
 0x0000000000000000
```
"""
function eachdigit(b::BaseInt{T,Ti,B}, n::Integer) where {T,Ti,B}
    n >= 0 || throw(ArgumentError("number of digits must be non-negative, got $n"))
    return DigitIterator{T,Ti,B}(b.value, Int(n))
end

Base.length(it::DigitIterator) = it.n
Base.eltype(::Type{<:DigitIterator{T}}) where {T} = T
Base.IteratorSize(::Type{<:DigitIterator}) = Base.HasLength()
Base.IteratorEltype(::Type{<:DigitIterator}) = Base.HasEltype()

function Base.iterate(it::DigitIterator{T,Ti,B}, state::Tuple{Int,T}=(1, it.value)) where {T,Ti,B}
    i, v = state
    i > it.n && return nothing
    return (v % T(B), (i + 1, v ÷ T(B)))
end

"""
    Base.write(b::SymBasis.DigitBase.BaseInt{T,Ti,B}, pos::Ti, d::Integer) where {T,Ti,B}

Write the digit `d` at position `pos` in the base-`B` representation of the integer `b`.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base-`B` integer.
- `pos::Ti`: The position of the digit to write (1-based indexing).
- `d::Integer`: The digit to write at the specified position.

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: A new [`SymBasis.DigitBase.BaseInt`](@ref)
    instance with the specified digit written.
"""
function Base.write(b::BaseInt{T,Ti,B}, pos::Ti, d::Integer) where {T,Ti,B}
    pos >= 1 || throw(ArgumentError("position must be ≥ 1 (1‑based indexing)"))
    B >= 2 || throw(ArgumentError("base must be ≥ 2, got $B"))
    0 ≤ d < B || throw(ArgumentError("digit must satisfy 0 ≤ d < $B, got $d"))

    power = _base_pow(Val(B), pos - 1)
    old = _digit_at(b.value, Val(B), pos)

    d == old && return b

    delta = (d - old) * power

    new_val = b.value + delta

    # overflow checks
    T_max = typemax(T)
    (delta > 0) && (new_val > T_max) &&
        throw(OverflowError("incrementing digit causes overflow"))

    return BaseInt{T,Ti,B}(new_val)
end

"""
    Base.write(
        b::SymBasis.DigitBase.BaseInt{T,Ti,B},
        pos::AbstractVector{Ti},
        d::AbstractVector{<:Integer}
    ) where {T,Ti,B}

Write the digits `d` at the specified positions in the base-`B` representation of the
integer `b`.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base-`B` integer.
- `pos::AbstractVector{Ti}`: The positions of the digits to write (1-based indexing).
- `d::AbstractVector{<:Integer}`: The digits to write at the specified positions.

# Returns
- [`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: A new [`SymBasis.DigitBase.BaseInt`](@ref)
    instance with the specified digits written.
"""
function Base.write(
    b::BaseInt{T,Ti,B},
    pos::AbstractVector{Ti},
    d::AbstractVector{<:Integer}
) where {T,Ti,B}
    new_b = b |> copy

    for i in eachindex(pos)
        new_b = write(new_b, pos[i], d[i])
    end

    return new_b
end

"""
    Base.count(
        b::SymBasis.DigitBase.BaseInt{T,Ti,B},
        pos::AbstractVector{Ti},
        d::Integer
    ) where {T,Ti,B}

Count the occurrences of the digit `d` at the specified positions in the base-`B`
representation of the integer `b`.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base-`B` integer.
- `pos::AbstractVector{Ti}`: The positions of the digits to check (1-based indexing).
- `d::Integer`: The digit to count.

# Returns
- `Int`: The count of occurrences of the digit `d` at the specified positions.
"""
function Base.count(b::BaseInt{T,Ti,B}, pos::AbstractVector{Ti}, d::Integer) where {T,Ti,B}
    0 ≤ d < B || throw(ArgumentError("digit must satisfy 0 ≤ d < B, got $d"))

    @boundscheck any(p -> p < 1, pos) &&
                 throw(ArgumentError("all positions must be ≥ 1 (1‑based indexing)"))

    cnt = 0
    @inbounds for p in pos
        cnt += (read(b, p) == d) ? 1 : 0
    end
    return cnt
end

"""
    Base.count(
        b::SymBasis.DigitBase.BaseInt{T,Ti,B},
        pos::AbstractUnitRange{Ti},
        d::Integer
    ) where {T,Ti,B}

Count the occurrences of the digit `d` over a contiguous range of positions in the base-`B`
representation of the integer `b`.

Like [`read(b, pos::AbstractUnitRange)`](@ref), this walks the digits once instead of
looking each position up independently, which is faster at every base and several times
faster when `B` is not a power of two.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base-`B` integer.
- `pos::AbstractUnitRange{Ti}`: The contiguous positions to check (1-based indexing).
- `d::Integer`: The digit to count.

# Returns
- `Int`: The count of occurrences of the digit `d` at the specified positions.
"""
function Base.count(
    b::BaseInt{T,Ti,B},
    pos::AbstractUnitRange{Ti},
    d::Integer
) where {T,Ti,B}
    0 ≤ d < B || throw(ArgumentError("digit must satisfy 0 ≤ d < B, got $d"))
    isempty(pos) && return 0

    @boundscheck first(pos) < 1 &&
                 throw(ArgumentError("all positions must be ≥ 1 (1‑based indexing)"))

    cnt = 0
    for digit in _walk_from(b, first(pos), length(pos))
        cnt += (digit == d) ? 1 : 0
    end
    return cnt
end

"""
    Base.count(
        b::SymBasis.DigitBase.BaseInt{T,Ti,B},
        pos::AbstractVector{Ti},
        d::AbstractVector{<:Integer}
    ) where {T,Ti,B}

Count the occurrences of each digit in `d` at the specified positions in the base-`B`
representation of the integer `b`.

# Arguments
- `b::`[`SymBasis.DigitBase.BaseInt`](@ref)`{T,Ti,B}`: The base-`B` integer.
- `pos::AbstractVector{Ti}`: The positions of the digits to check (1-based indexing).
- `d::AbstractVector{<:Integer}`: The digits to count.

# Returns
- `Vector{Int}`: A vector containing the counts of occurrences for each digit in `d`.
"""
function Base.count(
    b::BaseInt{T,Ti,B},
    pos::AbstractVector{Ti},
    d::AbstractVector{<:Integer}
) where {T,Ti,B}
    return map(d) do dᵢ
        count(b, pos, dᵢ)
    end
end
# END -- Digit manipulation functions
