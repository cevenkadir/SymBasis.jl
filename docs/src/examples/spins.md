# Quantum mechanical spins

This page collects two spin bases that go beyond the one-dimensional spin-1/2 cases already covered in the [basis construction](@ref "Basis construction") manual page: a higher spin, and a two-dimensional lattice with several point-group symmetries resolved at once. For a worked application that combines four symmetries at once and then checks that the resulting sectors really are irreducible, see [level statistics as a completeness test](@ref "Level statistics as a completeness test for symmetry resolution").

## Spin-1 objects on a chain with total magnetization symmetry
In this example, we will construct a basis for a system of spin-1 objects on a chain with total magnetization symmetry. We will first define the DoF-object for spin-1 and then define the symmetry group for total magnetization. Finally, we will generate the basis that resolves the total magnetization symmetry for a system of 4 spin-1 objects.
```@example spin_one_chain_Sz_sym
using SymBasis

N = 4 # number of sites
dofo = dof_object(Spin(1 // 1)) # define a DoF-object for spin-1

Sz = 0 # total magnetization quantum number
sg_Sz = sym(TotalMagnetization(Sz, N), dofo) # define the symmetry group for total magnetization

b = basis(dofo, N, sg_Sz) # generate the basis that resolves the total magnetization symmetry
```
This will generate a basis that consists of the basis states with total magnetization quantum number $S^z = 0$ for a system of 4 spin-1 objects. Note that a spin-1 site has three local states, so the basis states are stored as base-3 integers rather than the base-2 ones used for spin-1/2.

## Spin-1/2 objects on a 2D square lattice with total magnetization, translational, and spatial reflection symmetries
In this example, we will construct a basis for a system of spin-1/2 objects on a 2D square lattice with total magnetization, translational, and spatial reflection symmetries. We will first define the DoF-object for spin-1/2, then define the symmetry groups for total magnetization, translational, and spatial reflection symmetries, and finally combine the symmetry groups to generate the basis that resolves all three symmetries for a system of 12 spin-1/2 objects on a 2D square lattice.
```@example spin_one_square_lattice_Sz_translational_reflection_syms
using SymBasis

Lₛ = (4, 3) # dimensions of the square lattice (x and y directions)
N = prod(Lₛ) # total number of sites
dofo = dof_object(Spin(1 // 2)) # define a DoF-object for spin-1/2

Sz = 0 # total magnetization quantum number
# define the symmetry group for total magnetization
sg_Sz = sym(TotalMagnetization(Sz, N), dofo)

Tx_perm = LinearIndices(Lₛ)[
    [CartesianIndex(mod1(r[1] + 1, Lₛ[1]), r[2]) for r in CartesianIndices(Lₛ)][:]
]
kx = 0 # momentum quantum number for x-direction
# define the symmetry group for translational symmetry in x-direction
sg_translational_x = sym(Translational(kx, Tx_perm), dofo)

Rx_perm = LinearIndices(Lₛ)[
    [CartesianIndex(Lₛ[1] - r[1] + 1, r[2]) for r in CartesianIndices(Lₛ)][:]
]
px = -1 # parity quantum number for reflection in x-direction
# define the symmetry group for spatial reflection symmetry in x-direction
sg_reflection_x = sym(SpatialReflection(px, Rx_perm), dofo)

Ty_perm = LinearIndices(Lₛ)[
    [CartesianIndex(r[1], mod1(r[2] + 1, Lₛ[2])) for r in CartesianIndices(Lₛ)][:]
]
ky = 0 # momentum quantum number for y-direction
# define the symmetry group for translational symmetry in y-direction
sg_translational_y = sym(Translational(ky, Ty_perm), dofo)

Ry_perm = LinearIndices(Lₛ)[
    [CartesianIndex(r[1], Lₛ[2] - r[2] + 1) for r in CartesianIndices(Lₛ)][:]
]
py = 1 # parity quantum number for reflection in y-direction
# define the symmetry group for spatial reflection symmetry in y-direction
sg_reflection_y = sym(SpatialReflection(py, Ry_perm), dofo)

# Combine all the symmetry groups
csg = sg_Sz ∘ sg_translational_x ∘ sg_reflection_x ∘ sg_translational_y ∘ sg_reflection_y

b = basis(dofo, N, csg) # generate the basis that resolves all three symmetries
```
This will generate a basis that consists of the basis states with total magnetization quantum number $S^z = 0$, momentum quantum numbers $k_x = 0$ and $k_y = 0$, and parity quantum numbers $p_x = -1$ and $p_y = 1$ for a system of 12 spin-1/2 objects on a 2D square lattice. The basis states in this combined symmetry sector will be linear combinations of the product states that are invariant under the total magnetization, translational, and spatial reflection symmetry operations. Each basis state in this combined symmetry sector will have a specific normalization factor that accounts for the number of states that are combined to form the invariant state under the symmetry operations.