# Basis construction
In SymBasis.jl, you construct a basis by first defining a DoF object and then calling the [`basis`](@ref SymBasis.Bases.basis) function from the [`SymBasis.Bases`](@ref bases-api) submodule. If you want to resolve symmetries, you additionally provide one symmetry group or a combined symmetry group; otherwise, you can omit them to build the full, unreduced basis. The `basis` function takes the DoF object, the system size, and optionally symmetry group(s), and returns a basis object containing the basis states and their normalization constants.

```@contents
Pages = ["basis_construction.md"]
Depth = 2
```

First, we define a DoF object for a system, for example, containing spin-1/2 particles:
```@example basis_construction
using SymBasis

N = 4 # number of sites
dofo = dof_object(Spin(1 // 2)) # define, for example, a spin-1/2
```

## Without any symmetries
To construct the full, unreduced basis without any symmetries, you can simply call the `basis` function with the DoF object and the system size as follows:
```@example basis_construction
b_wo_sym = basis(dofo, N)
```
This will generate the full basis for a system of 4 spin-1/2 particles, which consists of $2^4 = 16$ basis states.

## With symmetries
To construct a basis that resolves one or more symmetries, you can first define the corresponding symmetry group(s) and then pass them to the `basis` function. For example, if you want to construct a basis that resolves the total magnetization symmetry, you can define the symmetry group for total magnetization and then call the `basis` function as follows:
```@example basis_construction
Sz = 0 # total magnetization quantum number

# Define the symmetry group for total magnetization
sg_Sz = sym(TotalMagnetization(Sz, N), dofo)

# Construct the basis that resolves the total magnetization symmetry
b_with_Sz_sym = basis(dofo, N, sg_Sz)
```
This will generate a basis that consists of the basis states with total magnetization quantum number $S^z = 0$ for a system of 4 spin-1/2 objects. You can similarly define other symmetry groups and combine them to construct bases that resolve multiple symmetries simultaneously.

For instance, if you want to construct a basis that resolves both the total magnetization symmetry and the translational symmetry, you can define the symmetry group for translational symmetry and then combine it with the total magnetization symmetry group as follows:
```@example basis_construction
perm = mod1.((1:N) .+ 1, N) # permutation for translational symmetry
k = 0 # momentum quantum number

# Define the symmetry group for translational symmetry
sg_translational = sym(Translational(k, perm), dofo)

# Combine the total magnetization symmetry and the translational symmetry
csg = sg_Sz ∘ sg_translational

# Construct the basis that resolves both symmetries
b_with_both_syms = basis(dofo, N, csg)
```
This will generate a basis that consists of the basis states with total magnetization quantum number $S^z = 0$ and momentum quantum number $k = 0$ for a system of 4 spin-1/2 objects.

!!! warning
    If you are unsure about whether these symmetries commute with each other in the constructed basis, you can simply pass the combined symmetry group to the [`is_commutative`](@ref SymBasis.Bases.is_commutative) function from the [`SymBasis.SymGroups`](@ref symgroups-api) submodule to check if the symmetries commute:
    ```@example basis_construction
    is_commutative(b_with_both_syms)
    ```
    This will return `true` if the symmetries with commute and `false` otherwise. If the symmetries do not commute, you cannot combine them to construct a basis that resolves both symmetries simultaneously.