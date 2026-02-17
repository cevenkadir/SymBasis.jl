# Defining a DoF-object
In SymBasis.jl, to generate a basis, you first need to define an object with degrees of freedom (DoF-object) that represents the system you are interested in.


```@contents
Pages = ["defining_dof_objects.md"]
Depth = 3
```

## Predefined DoF-objects
SymBasis.jl provides predefined DoF-objects for commonly used systems. 

### Quantum mechanical spins
You can define a DoF-object for quantum mechanical spins using the [`dof_object`](@ref SymBasis.DoFObjects.dof_object) function from the [`SymBasis.DoFObjects`](@ref dofobjects-api) submodule as follows:
```@example
using SymBasis.DoFObjects
s = 1//2 # spin quantum number
dofo = dof_object(Spin(s))
```
This will create a DoF-object for spin-1/2, which can then be used to specify symmetries and generate bases for systems containing spin-1/2 particles.

## Custom DoF-objects
In addition to the predefined DoF-objects, you can also define your own custom DoF-objects for other types of systems. For example, if you want to define a DoF-object for a system containing flag emojis of countries, you can do so by defining a tuple of the flag emojis and then using the [`DoFObject`](@ref SymBasis.DoFObjects.DoFObject) constructor from the [`SymBasis.DoFObjects`](@ref dofobjects-api) submodule as follows:
```@example
using SymBasis.DoFObjects
countries = ("🇹🇷", "🇩🇪", "🇺🇸", "🇬🇧", "🇫🇷")
dofo = DoFObject(:Country, countries)
```
