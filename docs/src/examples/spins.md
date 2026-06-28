# Quantum mechanical spins

## Spin-1/2 objects on a chain without any symmetries
In this example, we will construct a basis for a system of spin-1/2 objects on a chain without any symmetries. We will first define the DoF-object for spin-1/2 and then generate the full basis for a system of 4 spin-1/2 objects.
```@example spin_half_chain_no_sym
using SymBasis

N = 4 # number of sites
dofo = dof_object(Spin(1 // 2)) # define a DoF-object for spin-1/2

b = basis(dofo, N) # generate the full basis without any symmetries
```
This will generate the full basis for a system of 4 spin-1/2 particles, which consists of $2^4 = 16$ basis states. Each basis state corresponds to a specific configuration of the spin-1/2 objects on the chain, where each object can be in either the spin-up or spin-down state. The basis states are represented as integers using the base positional numbering system, where the position of each spin-1/2 object contributes to the overall integer representation of the state. For example, the state where all spin-1/2 objects are in the spin-down state would be represented as `0`, while the state where all spin-1/2 objects are in the spin-up state would be represented as `15` (which is `2^4 - 1`).

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
This will generate a basis that consists of the basis states with total magnetization quantum number $S^z = 0$ for a system of 4 spin-1 objects.

## Spin-1/2 objects on a chain with total magnetization and translational symmetries
In this example, we will construct a basis for a system of spin-1/2 objects on a chain with both total magnetization and translational symmetries. We will first define the DoF-object for spin-1/2, then define the symmetry groups for total magnetization and translational symmetries, and finally combine the symmetry groups to generate the basis that resolves both symmetries for a system of 4 spin-1/2 objects.
```@example spin_half_chain_Sz_translational_syms
using SymBasis

N = 4 # number of sites
dofo = dof_object(Spin(1 // 2)) # define a DoF-object for spin-1/2

Sz = 0 # total magnetization quantum number
sg_Sz = sym(TotalMagnetization(Sz, N), dofo) # define the symmetry group for total magnetization

perm = mod1.((1:N) .+ 1, N) # permutation for translational symmetry
k = 0 # momentum quantum number
sg_translational = sym(Translational(k, perm), dofo) # define the symmetry group for translational symmetry

# Combine the total magnetization symmetry and the translational symmetry
csg = sg_Sz ∘ sg_translational

b = basis(dofo, N, csg) # generate the basis that resolves both symmetries
```
This will generate a basis that consists of the basis states with total magnetization quantum number $S^z = 0$ and momentum quantum number $k = 0$ for a system of 4 spin-1/2 objects. The basis states in this case will be linear combinations of the basis states from the previous example (without symmetries) that are invariant under both the total magnetization and translational symmetry operations. Each basis state in this combined symmetry sector will have a specific normalization factor that accounts for the number of states that are combined to form the invariant state under the symmetry operations.


## Spin-1/2 objects on a 2D square lattice with total magnetization, translational, and spatial reflection symmetries
In this example, we will construct a basis for a system of spin-1/2 objects on a 2D square lattice with total magnetization, translational, and spatial reflection symmetries. We will first define the DoF-object for spin-1/2, then define the symmetry groups for total magnetization, translational, and spatial reflection symmetries, and finally combine the symmetry groups to generate the basis that resolves all three symmetries for a system of 4 spin-1/2 objects on a 2D square lattice.
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
This will generate a basis that consists of the basis states with total magnetization quantum number $S^z = 0$, momentum quantum numbers $k_x = 0$ and $k_y = 0$, and parity quantum numbers $p_x = -1$ and $p_y = 1$ for a system of 14 spin-1/2 objects on a 2D square lattice. The basis states in this combined symmetry sector will be linear combinations of the basis states from the previous examples that are invariant under the total magnetization, translational, and spatial reflection symmetry operations. Each basis state in this combined symmetry sector will have a specific normalization factor that accounts for the number of states that are combined to form the invariant state under the symmetry operations.