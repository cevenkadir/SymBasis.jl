# SymBasis.jl

*A generator of basis with symmetries for Julia*

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
- Spatial reflection symmetry
- Translational symmetry

In the upcoming versions, we plan to add more predefined symmetries such as spin inversion, particle number conservation (for fermions and bosons), etc.

## Quick installation
**Requirements**: Julia 1.11 or later.

You can install SymBasis.jl using Julia's package manager. Open the Julia REPL and run:
```julia
julia> import Pkg; Pkg.add("https://github.com/cevenkadir/SymBasis.jl")
```

## Quick example
You can determine the basis with zero total magnetization for a spin-1/2 system with 4 sites as follows:
```@example
using SymBasis.DoFObjects
using SymBasis.SymGroups
using SymBasis.Bases

N = 4 # number of sites
Sz = 0//1 # total magnetization

# define an object for spin-1/2
dofo = dof_object(:Spin, 1 // 2)

# define the symmetry group for total magnetization
sg = sym(:TotalMagnetization, dofo, Sz, N)

# generate the basis
basis(dofo, N, sg)
```

## Supporting and citing
This package was developed for academic purposes. If you find SymBasis.jl useful and use it in your research, please consider citing it as follows:
```bibtex
@misc{symbasis,
  title={{SymBasis.jl}: {A generator of basis with symmetries for {Julia}}},
  author={Kadir Çeven},
  year={2026},
  url={https://github.com/cevenkadir/SymBasis.jl}
  version={v0.1.0}
}
```