<p align="center">
    <img width="200px" src="docs/src/assets/logo.svg#gh-light-mode-only"/>
    <img width="200px" src="docs/src/assets/logo-dark.svg#gh-dark-mode-only"/>
</p>
<div align="center">

# SymBasis.jl

*A generator of basis with symmetries for Julia*

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://cevenkadir.github.io/SymBasis.jl/stable/) [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://cevenkadir.github.io/SymBasis.jl/dev/) [![Build Status](https://github.com/cevenkadir/SymBasis.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/cevenkadir/SymBasis.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Coverage](https://codecov.io/gh/cevenkadir/SymBasis.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/cevenkadir/SymBasis.jl) [![Downloads](https://img.shields.io/badge/dynamic/json?url=http%3A%2F%2Fjuliapkgstats.com%2Fapi%2Fv1%2Fmonthly_downloads%2FSymBasis&query=total_requests&suffix=%2Fmonth&label=Downloads)](https://juliapkgstats.com/pkg/SymBasis)
</div>

SymBasis.jl is a Julia package for building the bases that conserve the symmetries of a system with a discrete number of degrees of freedom — useful for quantum many-body problems. You generate a basis with one symmetry or several without having to understand the enumeration algorithms underneath. Most similar packages only expose a fixed menu of symmetries; SymBasis.jl lets you define your own alongside the predefined ones.

## Key features
- **Easy-to-use interface**: generate bases with symmetries without needing to understand the underlying algorithms.
- **Custom base positional numbering**: specify the base positional numbering for the basis states, and alter those (integer) numbers directly.
- **Any discrete degrees of freedom**: define DoF-objects for spins, bosons, spinless and spinful fermions, or even custom objects like flag emojis of countries.
- **Multiple symmetries at once**: generate bases that conserve several symmetries simultaneously.
- **Custom symmetries**: define your own symmetries and generate the corresponding basis.

## Predefined symmetries
SymBasis.jl provides predefined symmetry groups for commonly used symmetries, including:
- Total magnetization (for quantum mechanical spins)
- Spin inversion (for quantum mechanical spins)
- Spin-multipole conservation (for quantum mechanical spins)
- Total particle number (for bosons)
- Total particle number (for spinless fermions)
- Spin-resolved particle number (for spinful fermions)
- Fermionic spin inversion (for spinful fermions)
- Spatial reflection symmetry
- Translational symmetry
- Rotational symmetry of space

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

SymBasis precompiles its common construction flows, so the first `basis` call in a session is
fast. That work is redone on every rebuild, which is noticeable when developing against a
`dev`ed checkout. To skip it, add to the `LocalPreferences.toml` of your environment:
```toml
[SymBasis]
precompile_workload = false
```

## Documentation
For detailed information on using this package, check out the [stable documentation](https://cevenkadir.github.io/SymBasis.jl/stable/).

## Manual
- [Getting started](https://cevenkadir.github.io/SymBasis.jl/stable/manual/getting_started/)
- [Defining DoF-object(s)](https://cevenkadir.github.io/SymBasis.jl/stable/manual/defining_dof_objects/)
- [Defining symmetry group(s)](https://cevenkadir.github.io/SymBasis.jl/stable/manual/defining_sym_groups/)
- [Basis construction](https://cevenkadir.github.io/SymBasis.jl/stable/manual/basis_construction/)
- [Determining representative states](https://cevenkadir.github.io/SymBasis.jl/stable/manual/representative_states/)
- [State operations](https://cevenkadir.github.io/SymBasis.jl/stable/manual/state_operations/)
- [Operator construction](https://cevenkadir.github.io/SymBasis.jl/stable/manual/operator_construction/)

Performance comparisons against other packages are collected on the [benchmarks page](https://cevenkadir.github.io/SymBasis.jl/stable/benchmarks/).

## Examples
- [Quantum mechanical spins](https://cevenkadir.github.io/SymBasis.jl/stable/examples/spins/)
- [Level statistics as a completeness test](https://cevenkadir.github.io/SymBasis.jl/stable/examples/level_statistics/)
- [Quantum many-body scars in the PXP chain](https://cevenkadir.github.io/SymBasis.jl/stable/examples/pxp/)
- [Phase diagram of the Bose-Hubbard chain](https://cevenkadir.github.io/SymBasis.jl/stable/examples/1d_bhm_phase_diagram/)
- [Fermi-Hubbard chain vs. the exact Lieb-Wu solution](https://cevenkadir.github.io/SymBasis.jl/stable/examples/fhm_lieb_wu/)
- [Spinless-fermion t-V chain vs. the exact Bethe-Hulthén solution](https://cevenkadir.github.io/SymBasis.jl/stable/examples/tv_chain_bethe_hulthen/)

## Quick example
You can determine the basis with zero total magnetization for a spin-1/2 system with 4 sites as follows:
```julia
julia> using SymBasis

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
Basis{BaseInt{UInt64, Int64, 2},Float64} with 6 states
  states: Vector{BaseInt{UInt64, Int64, 2}}
  norms : Vector{Float64}
  symmetry group: SymGroup{2, Rational{Int64}, UInt64, Int64, Float64, Vector{@NamedTuple{N0::Int64, N1::Int64, N::Int64}}, typeof(check_Nₛ), typeof(apply_Nₛ), typeof(phase_unity), Vector{Float64}}
  first 6 states/norms:
    (11)₂    (norm=1.0)
    (101)₂   (norm=1.0)
    (110)₂   (norm=1.0)
    (1001)₂  (norm=1.0)
    (1010)₂  (norm=1.0)
    (1100)₂  (norm=1.0)
```

## Important notice
This project is still under active development. It has an extensive test suite, but you should still benchmark your own code rather than take correctness for granted. Please report any issues you encounter via the [GitHub issue tracker](https://github.com/cevenkadir/SymBasis.jl/issues/new).

## Citation
If you use this package in your work, 
we would appreciate the following reference as in [CITATION.bib](https://github.com/cevenkadir/SymBasis.jl/blob/main/CITATION.bib).