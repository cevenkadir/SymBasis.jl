# Getting started

## Installation
To install the latest stable version of SymBasis.jl, you can use the Julia package manager. Either use the Julia REPL package mode (by pressing `]`):
```julia
pkg> add SymBasis
```
or open the Julia REPL and run the following command:
```julia
julia> import Pkg; Pkg.add("https://github.com/cevenkadir/SymBasis.jl.git")
```

## Basic concepts
Before diving into the usage of SymBasis.jl, it is helpful to understand some basic concepts related to the package. SymBasis.jl is designed to generate bases with certain symmetries for systems with a discrete number of degrees of freedom, which is particularly useful for quantum many-body problems.

### Base positional numbering
In SymBasis.jl, the basis states are represented using a base positional numbering system with a corresponding base. This means that each state is assigned a unique integer based on its configuration, and the position of each degree of freedom contributes to the overall number. This allows for efficient storage and manipulation of basis states. This is handled internally by the [`SymBasis.DigitBase`](@ref digitbase-api) submodule, which is responsible for the base positional numbering system used in the package. Users typically do not need to interact directly with this submodule when using the package to generate bases, but it is an important aspect of how the package represents and manages basis states via the [`BaseInt`](@ref SymBasis.DigitBase.BaseInt) type from the [`SymBasis.DigitBase`](@ref digitbase-api) submodule.

### Objects with degrees of freedom a.k.a. DoF-objects
To generate a basis, you first need to define an object with degrees of freedom (DoF-object) that represents the physical system you are interested in. For example, if you are working with a spin-1/2 system, you can define a DoF-object for spin-1/2 using the [`dof_object`](@ref SymBasis.DoFObjects.dof_object) function from the [`SymBasis.DoFObjects`](@ref dofobjects-api) submodule. This object will then be used to specify the symmetries and generate the corresponding basis.

Additionally, you can define custom DoF-objects for other types of systems, such as a system containing flag emojis of countries, by specifying the appropriate parameters when creating the DoF-object via the [`DoFObject`](@ref SymBasis.DoFObjects.DoFObject) constructor from the [`SymBasis.DoFObjects`](@ref dofobjects-api) submodule. This flexibility allows you to use SymBasis.jl for a wide range of systems.

### Symmetry groups
Symmetry groups are a crucial Julia struct to generate bases with symmetries. In SymBasis.jl, you can contruct symmetry groups using the [`sym`](@ref SymBasis.SymGroups.sym) function from the [`SymBasis.SymGroups`](@ref symgroups-api) submodule. This function allows you to call various types of predefined symmetries, such as total magnetization, translation, reflection, and more. You can also combine multiple symmetries to generate bases that conserve multiple symmetries simultaneously.

Similar to DoF-objects, you can also define your own custom symmetries by specifying the appropriate parameters when constructing the symmetry group via the [`SymGroup`](@ref SymBasis.SymGroups.SymGroup) constructor from the [`SymBasis.SymGroups`](@ref symgroups-api) submodule. This feature provides great flexibility in generating bases that are tailored to the very specialized symmetries of your system. These symmetry groups can be also combined with each other to generate bases that conserve multiple symmetries simultaneously via the [`∘`](@ref Base.:(∘)) function from the [`SymBasis.SymGroups`](@ref symgroups-api) submodule, which eventually returns [`CombSymGroup`](@ref SymBasis.SymGroups.CombSymGroup) types that represent the combined symmetries.

### Generating bases
Once you have defined the DoF-object and the symmetry group(s), you can generate the basis using the [`basis`](@ref SymBasis.Bases.basis) function from the [`SymBasis.Bases`](@ref bases-api) submodule. This function takes the DoF-object, the number of sites, and the symmetry group(s) as input and returns a [`Basis`](@ref SymBasis.Bases.Basis) type that contains the basis states and their normalization factors to define operators like Hamiltonian in the basis. The generated basis will conserve the specified symmetries, allowing you to work with a reduced Hilbert space that is more manageable for quantum many-body problems.

!!! warning 
    The [`basis`](@ref SymBasis.Bases.basis) function will return the correct basis states and their normalization factors, as long as the specified symmetries commute with each other in that basis. If the symmetries do not commute, the function will not throw an error. That is, the function does not check for the commutation of symmetries, and it is the user's responsibility to ensure that the specified symmetries commute with each other in the basis. This can be done by using the [`is_commutative`](@ref SymBasis.Bases.is_commutative) function from the [`SymBasis.Bases`](@ref bases-api) submodule to check for the commutation of symmetries after generating the basis.