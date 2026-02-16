# State operations

This guide covers the fundamental operations for working with states in SymBasis.jl. States are represented as [`BaseInt`](@ref SymBasis.DigitBase.BaseInt) objects—multi-digit numbers where each digit represents a local degree of freedom (such as spin orientation, particle occupation, etc.). 

The operations described here enable you to manipulate states and extract information from them, which is essential for defining operators (like Hamiltonians) and implementing custom symmetries.

```@contents
Pages = ["state_operations.md"]
Depth = 3
```

## Overview of operations

SymBasis.jl provides predefined operators organized into three categories:

1. **Modifying operators**: Change digit values (`dec`, `inc`, `flip`, `write`)
2. **Structural operators**: Rearrange digits (`permute`)
3. **Query operators**: Extract information (`read`, `count`)

All operations work with states in base-`B` notation, where `B` is the number of local degrees of freedom. For example, `(123)₄` represents a 3-site state in base-4, with digits 3, 2, and 1 at positions 1, 2, and 3 respectively.

## Modifying operators

### Decrementing digits

The `dec` function decreases the value of digit(s) by one, useful for implementing lowering operators (e.g., spin lowering $\hat{S}^-$ or boson annihilation $\hat{b}$).

**Single digit:**

Use [`dec(state, pos)`](@ref SymBasis.DigitBase.dec(::SymBasis.DigitBase.BaseInt{T,Ti,B}, ::Ti) where {T,Ti,B}) to decrement the digit at position `pos`.

```@example dec
using SymBasis.DigitBase
state = bi"11"2 # Binary state (11)₂
pos = 2 # Position to decrement
dec(state, pos) # Returns (1)₂
```

**Multiple digits:**

Use [`dec(state, positions)`](@ref SymBasis.DigitBase.dec(::SymBasis.DigitBase.BaseInt{T,Ti,B}, ::AbstractVector{Ti}) where {T,Ti,B}) to decrement several digits at once.

```@example dec
posₛ = [1, 2] # Decrement both positions
dec(state, posₛ) # Returns (0)₂
```

### Incrementing digits

The `inc` function increases the value of digit(s) by one, useful for implementing raising operators (e.g., spin raising $\hat{S}^+$ or boson creation $\hat{a}^\dagger$).

**Single digit:**

Use [`inc(state, pos)`](@ref SymBasis.DigitBase.inc(::SymBasis.DigitBase.BaseInt{T,Ti,B}, ::Ti) where {T,Ti,B}) to increment the digit at position `pos`.

```@example inc
using SymBasis.DigitBase
state = bi"10"2 # Binary state (10)₂
pos = 1 # Position to increment
inc(state, pos) # Returns (11)₂
```

**Multiple digits:**

Use [`inc(state, positions)`](@ref SymBasis.DigitBase.inc(::SymBasis.DigitBase.BaseInt{T,Ti,B}, ::AbstractVector{Ti}) where {T,Ti,B}) to increment several digits simultaneously.

```@example inc
posₛ = [1, 4] # Increment at positions 1 and 4
inc(state, posₛ) # Returns (1011)₂
```

### Flipping digits

The `flip` function toggles digit values within the allowed range, useful for spin flip operations (e.g., $\hat{S}^x$ operator).

**Single digit:**

Use [`flip(state, pos)`](@ref SymBasis.DigitBase.flip(::SymBasis.DigitBase.BaseInt{T,Ti,B}, ::Ti) where {T,Ti,B}) to flip the digit at position `pos`.

```@example flip
using SymBasis.DigitBase
state = bi"22"3 # Base-3 state (22)₃
pos = 1 # Position to flip
flip(state, pos) # Returns (20)₃ (flips 2→0)
```

**Multiple digits:**

Use [`flip(state, positions)`](@ref SymBasis.DigitBase.flip(::SymBasis.DigitBase.BaseInt{T,Ti,B}, ::AbstractVector{Ti}) where {T,Ti,B}) to flip several digits at once.

```@example flip
posₛ = [1, 3] # Flip positions 1 and 3
flip(state, posₛ) # Returns (220)₃
```

### Writing new digit values

The `write` function directly sets digit(s) to specified value(s), useful for projection operators or state preparation.

**Single digit:**

Use [`write(state, pos, value)`](@ref SymBasis.DigitBase.Base.write(::SymBasis.DigitBase.BaseInt{T,Ti,B}, ::Ti, ::Integer) where {T,Ti,B}) to set a specific value at position `pos`.

```@example write
using SymBasis.DigitBase
state = bi"1201"3 # Base-3 state (1201)₃
pos = 2 # Position to write to
value = 2 # New value
write(state, pos, value) # Returns (1221)₃
```

**Multiple digits:**

Use [`write(state, positions, values)`](@ref SymBasis.DigitBase.Base.write) to set multiple positions to specified values.

```@example write
posₛ = [1, 3] # Positions to modify
values = [2, 0] # Corresponding new values
write(state, posₛ, values) # Returns (1002)₃
```

## Structural operators

### Permuting digit positions

Use [`permute(state, perm_vector)`](@ref SymBasis.DigitBase.permute(::SymBasis.DigitBase.BaseInt{T,Ti,B}, ::AbstractVector{Ti}) where {T,Ti,B}) to rearrange the positions of digits, useful for translation or other spatial symmetry operations.

```@example permute1
using SymBasis.DigitBase
state = bi"123"4 # Base-4 state (123)₄
permute(state, [3, 1, 2]) # Returns (231)₄ - digit at pos 1 moves to pos 3, etc.
```

### Permuting local degrees of freedom

These operations permute the *values* of digits (not their positions), useful for local spin rotations or particle type exchanges.

**Single digit:**

Use [`permute(state, pos, perm_vector)`](@ref SymBasis.DigitBase.permute) to permute the local degree of freedom at position `pos`.

```@example permute2
using SymBasis.DigitBase
state = bi"123"4 # Base-4 state (123)₄
pos = 1 # Position to permute
# Permutation: 0→3, 1→0, 2→1, 3→2
permute(state, pos, [3, 0, 1, 2]) # Returns (122)₄
```

**Multiple digits:**

Use [`permute(state, positions, perm_vector)`](@ref SymBasis.DigitBase.permute) to apply the same permutation to multiple positions.

```@example permute2
posₛ = [1, 3] # Apply permutation to positions 1 and 3
permute(state, posₛ, [3, 0, 1, 2]) # Returns (22)₄
```

## Query operators

### Reading digit values

The `read` function extracts digit value(s) without modifying the state, useful for measuring local observables.

**Single digit:**

Use [`read(state, pos)`](@ref SymBasis.DigitBase.Base.read(::SymBasis.DigitBase.BaseInt{T,Ti,B}, ::Ti) where {T,Ti,B}) to get the value at position `pos`.

```@example read
using SymBasis.DigitBase
state = bi"1201"3 # Base-3 state (1201)₃
pos = 2 # Query position 2
read(state, pos) # Returns 0
```

**Multiple digits:**

Use [`read(state, positions)`](@ref SymBasis.DigitBase.Base.read(::SymBasis.DigitBase.BaseInt{T,Ti,B}, ::AbstractVector{Ti}) where {T,Ti,B}) to get values at multiple positions.

```@example read
posₛ = [1, 3] # Query positions 1 and 3
read(state, posₛ) # Returns [1, 2]
```

### Counting digit occurrences

The `count` function tallies how many times specific digit value(s) appear in given positions, useful for computing conserved quantities like total magnetization or particle number.

**Single digit value:**

Use [`count(state, positions, digit)`](@ref SymBasis.DigitBase.Base.count) to count occurrences of a specific digit.

```@example count
using SymBasis.DigitBase
state = bi"1201"3 # Base-3 state (1201)₃
posₛ = [1, 2, 3, 4] # Positions to check
digit = 1 # Value to count
count(state, posₛ, digit) # Returns 2 (two 1's in the state)
```

**Multiple digit values:**

Provide a vector of digits to count occurrences of any of them.

```@example count
digits = [0, 1] # Count both 0's and 1's
count(state, posₛ, digits) # Returns [1, 2] (one 0 and two 1's)
```