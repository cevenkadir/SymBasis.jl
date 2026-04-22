# Defining a DoF-object
In SymBasis.jl, to generate a basis, you first need to define an object with degrees of freedom (DoF-object) that represents the system you are interested in.


```@contents
Pages = ["defining_dof_objects.md"]
Depth = 3
```

## Predefined DoF-objects
SymBasis.jl provides predefined DoF-objects for commonly used systems. 

### Quantum mechanical spins
Define a spin DoF-object using the [`dof_object`](@ref SymBasis.DoFObjects.dof_object) function and the [`Spin`](@ref SymBasis.DoFObjects.Spin) type from the [`SymBasis.DoFObjects`](@ref dofobjects-api) submodule as follows:
```@example
using SymBasis.DoFObjects
s = 1//2 # spin quantum number
dofo = dof_object(Spin(s))
```
This creates a spin-1/2 DoF-object for specifying symmetries and generating bases.

### Bosons
Define a boson DoF-object using the [`dof_object`](@ref SymBasis.DoFObjects.dof_object) function and the [`Boson`](@ref SymBasis.DoFObjects.Boson) type from the [`SymBasis.DoFObjects`](@ref dofobjects-api) submodule:
```@example
using SymBasis.DoFObjects
max_occupancy = 3
dofo = dof_object(Boson(max_occupancy))
```
This creates a local DoF-object with occupations `(0, 1, ..., max_occupancy)`, suitable for specifying symmetries and generating bosonic bases.

### Spinless fermions
Define a spinless fermion DoF-object using the [`dof_object`](@ref SymBasis.DoFObjects.dof_object) function and the [`SpinlessFermion`](@ref SymBasis.DoFObjects.SpinlessFermion) type from the [`SymBasis.DoFObjects`](@ref dofobjects-api) submodule:
```@example
using SymBasis.DoFObjects
dofo = dof_object(SpinlessFermion())
```
This creates a local two-state DoF-object with occupations `(0, 1)`, suitable for specifying symmetries and generating fermionic bases.

## Custom DoF-objects
In addition to the predefined DoF-objects, you can also define your own custom DoF-objects for other types of systems. For example, if you want to define a DoF-object for a system containing flag emojis of countries, you can do so by defining a tuple of the flag emojis and then using the [`DoFObject`](@ref SymBasis.DoFObjects.DoFObject) constructor from the [`SymBasis.DoFObjects`](@ref dofobjects-api) submodule as follows:
```@example
using SymBasis.DoFObjects
countries = ("🇹🇷", "🇩🇪", "🇺🇸", "🇬🇧", "🇫🇷")
dofo = DoFObject(:Country, countries)
```
