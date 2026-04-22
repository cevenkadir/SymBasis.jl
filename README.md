<p align="center">
    <img width="200px" src="docs/src/assets/logo.svg#gh-light-mode-only"/>
    <img width="200px" src="docs/src/assets/logo-dark.svg#gh-dark-mode-only"/>
</p>
<div align="center">

# SymBasis.jl

*A generator of basis with symmetries for Julia*

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://cevenkadir.github.io/SymBasis.jl/stable/) [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://cevenkadir.github.io/SymBasis.jl/dev/) [![Build Status](https://github.com/cevenkadir/SymBasis.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/cevenkadir/SymBasis.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Coverage](https://codecov.io/gh/cevenkadir/SymBasis.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/cevenkadir/SymBasis.jl) [![Downloads](https://img.shields.io/badge/dynamic/json?url=http%3A%2F%2Fjuliapkgstats.com%2Fapi%2Fv1%2Fmonthly_downloads%2FSymBasis&query=total_requests&suffix=%2Fmonth&label=Downloads)](https://juliapkgstats.com/pkg/SymBasis)
</div>

SymBasis.jl is a Julia package for determining the bases conserving the symmetries of a system with a discrete number of degrees of freedom, which is useful for quantum many-body problems. This package offers an easy-to-use interface to generate any basis with one symmetry or multiple symmetries, without the need for users to understand the underlying algorithms. Compared to other similar packages, in SymBasis.jl, you can easily define your custom symmetries (or use predefined ones) and generate the corresponding basis, which is mostly unsupported by other packages.

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
- Spin-multipole conservation (for quantum mechanical spins)
- Particle number conservation (for bosons and spinless fermions)
- Spatial reflection symmetry
- Translational symmetry
- Rotational symmetry of space

In the upcoming versions, we plan to add more predefined symmetries for spinful fermions.

## Installation
**Requirements**: Julia 1.11 or later.

To install the latest stable version of SymBasis.jl, you can use the Julia package manager. Either use the Julia REPL package mode (by pressing `]`):
```julia
pkg> add SymBasis
```
or open the Julia REPL and run the following command:
```julia
julia> import Pkg; Pkg.add("SymBasis")
```

## Documentation
For detailed information on using this package, check out the [stable documentation](https://cevenkadir.github.io/SymBasis.jl/stable/).

## Important notice
This project is still under active development. While it includes an extensive test suite and is developed with high scientific rigor, you should always benchmark your own code. Please report any issues you encounter via the [GitHub issue tracker](https://github.com/cevenkadir/SymBasis.jl/issues/new).

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
  phase:         phase_unity

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

## Citation
If you use this package in your work, 
we would appreciate the following reference as in [CITATION.bib](https://github.com/cevenkadir/SymBasis.jl/blob/main/CITATION.bib).
