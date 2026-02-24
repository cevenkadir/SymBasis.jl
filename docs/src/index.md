# SymBasis.jl

*A generator of basis with symmetries for Julia*

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://cevenkadir.github.io/SymBasis.jl/stable/) [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://cevenkadir.github.io/SymBasis.jl/dev/) [![Build Status](https://github.com/cevenkadir/SymBasis.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/cevenkadir/SymBasis.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Coverage](https://codecov.io/gh/cevenkadir/SymBasis.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/cevenkadir/SymBasis.jl) [![Downloads](https://img.shields.io/badge/dynamic/json?url=http%3A%2F%2Fjuliapkgstats.com%2Fapi%2Fv1%2Fmonthly_downloads%2FSymBasis&query=total_requests&suffix=%2Fmonth&label=Downloads)](https://juliapkgstats.com/pkg/SymBasis)

The [SymBasis.jl](https://github.com/cevenkadir/SymBasis.jl) is a Julia package for determining the bases conserving the symmetries of a system with a discrete number of degrees of freedom, which is useful for quantum many-body problems. This package offers an easy-to-use interface to generate any basis with one symmetry or multiple symmetries, without the need for users to understand the underlying algorithms. Compared to other similar packages, in SymBasis.jl, you can easily define your custom symmetries (or use predefined ones) and generate the corresponding basis, which is mostly unsupported by other packages.

## Key features
- **Easy-to-use interface**: Users can generate bases with symmetries without needing to understand the underlying algorithms.
- **Custom base positional numbering**: Users can specify the base positional numbering for the basis states and alter these (integer) numbers.
- **Any discrete degrees of freedom**: Users can define DoF-objects for any discrete degrees of freedom, such as spins, fermions, bosons, or even custom objects like flag emojis of countries.
- **Support for multiple symmetries**: Users can generate bases that conserve multiple symmetries.
- **Custom symmetries**: Users can define their own symmetries and generate the corresponding basis.

## Predefined symmetries
SymBasis.jl provides predefined symmetry groups for commonly used symmetries, including:
- Total magnetization (for quantum mechanical spins)
- Spin inversion (for quantum mechanical spins)
- Spatial reflection symmetry
- Translational symmetry
- Rotational symmetry of space

In the upcoming versions, we plan to add more predefined symmetries such as multipole conservation for spins and particle number conservation for fermions and bosons, etc.

## Quick installation
**Requirements**: Julia 1.11 or later.

You can install SymBasis.jl using Julia's package manager. Open the Julia REPL and run:
```julia
julia> import Pkg; Pkg.add("SymBasis")
```
or in package mode (press `]` in the REPL):
```julia
pkg> add SymBasis
```

## Quick example
You can determine the basis with zero total magnetization for a spin-1/2 system with 4 sites as follows:
```julia
julia> using SymBasis.DoFObjects
julia> using SymBasis.SymGroups
julia> using SymBasis.Bases

julia> N = 4; # number of sites
julia> Sz = 0; # total magnetization

# define an object for spin-1/2
julia> dofo = dof_object(Spin(1 // 2))
DoFObject: Spin (B=2)
  ldof: (-1//2, 1//2)
  index types: T=UInt64, Ti=Int64

# define the symmetry group for total magnetization
julia> sg = sym(TotalMagnetization(Sz, N), dofo)
SymGroup{2,Rational{Int64},UInt64,Int64,Float64} with 1 cycle(s)
  N:             4
  DoF-object:    DoFObject(Spin, B=2)
  cycles:        (N0 = 2, N1 = 2, N = 4)
  factors:       1 element(s), eltype=Float64
  check:         check_Nₛ
  apply:         apply_Nₛ

# generate the basis
julia> basis(dofo, N, sg)
Basis{SymBasis.DigitBase.BaseInt{UInt64, Int64, 2},Float64} with 6 states
  states: Vector{SymBasis.DigitBase.BaseInt{UInt64, Int64, 2}}
  norms : Vector{Float64}
  first 6 states/norms:
    (11)₂    (norm=1.0)
    (101)₂   (norm=1.0)
    (110)₂   (norm=1.0)
    (1001)₂  (norm=1.0)
    (1010)₂  (norm=1.0)
    (1100)₂  (norm=1.0)
```

## Supporting and citing
This package was developed for academic purposes. If you find SymBasis.jl useful and use it in your research, please consider citing it as follows:
```bibtex
@misc{symbasis,
  title={{SymBasis}.jl: {A} generator of basis with symmetries for {Julia}},
  author={Kadir Çeven},
  year={2026},
  url={https://github.com/cevenkadir/SymBasis.jl}
  version={v0.1.3}
}
```