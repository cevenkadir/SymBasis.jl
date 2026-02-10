# Defining symmetry sector(s)
In SymBasis.jl, you can generate bases that have one or more symmetries by defining the corresponding symmetry groups(s).

```@contents
Pages = ["defining_sym_groups.md"]
Depth = 5
```

## Predefined symmetry groups
SymBasis.jl provides predefined symmetry groups for commonly used symmetries. You can construct these symmetry groups using the [`sym`](@ref SymBasis.SymGroups.sym) function from the [`SymBasis.SymGroups`](@ref symgroups-api) submodule.

### DoF-object-independent symmetry groups
Some symmetries are independent of the DoF-object, such as translational and reflection symmetries.

#### Translational symmetry
Translational symmetry is a symmetry where the system is invariant under translations. In a system with $N$ sites, the translation operator $T$ acts on a state $\vert a \rangle$ as follows:
```math
\vert a(k) \rangle = \frac{1}{\sqrt{N_a}} \sum_{r=0}^{N-1} e^{-i k r} \hat{T}^r \vert a \rangle
```
where $N_a$ is the normalization factor, $k$ is the momentum quantum number, and $\hat{T}^r$ is the translation operator applied $r$ times. The translation operator $\hat{T}$ acts on the state $\vert a(k) \rangle$ as follows:
```math
\hat{T} \vert a(k) \rangle =  e^{i k} \vert a(k) \rangle
```
You can define a translation symmetry group for a system with a certain number of sites using the [`sym`](@ref SymBasis.SymGroups.sym) function as follows:
```@example
using SymBasis.DoFObjects
using SymBasis.SymGroups

dofo = dof_object(:Spin, 1 // 2) # define, for example, a spin-1/2

N = 4 # number of sites
perm = mod1.((1:N) .+ 1, N) # permutation for translational symmetry
k = 0 # momentum quantum number

sg = sym(:Translational, dofo, k, perm)
```

#### Spatial-reflection symmetry
Spatial-reflection symmetry is a symmetry where the system is invariant under spatial reflection. In a system with $N$ sites, the reflection operator $R$ acts on a state $\vert a \rangle$ as follows:
```math
\vert a(p) \rangle = \frac{1}{\sqrt{N_a}} \sum_{r=0}^{1} p^r \hat{R}^r \vert a \rangle
```
where $N_a$ is the normalization factor, $p$ is the parity quantum number, and $\hat{R}^r$ is the reflection operator applied $r$ times. The reflection operator $\hat{R}$ acts on the state $\vert a(p) \rangle$ as follows:
```math
\hat{R} \vert a(p) \rangle =  p \vert a(p) \rangle
```
You can define a spatial reflection symmetry group for a system with a certain number of sites using the [`sym`](@ref SymBasis.SymGroups.sym) function as follows:
```@example
using SymBasis.DoFObjects
using SymBasis.SymGroups

dofo = DoFObject(:Pet, (:🐶, :🐱, :🦜)) # define, for example, a pet object
N = 4 # number of sites
perm = reverse(1:N) |> collect # permutation for reflection symmetry
p = -1 # parity number

sg = sym(:SpatialReflection, dofo, p, perm)
```

### DoF-object-dependent symmetry groups
Some symmetries depend on the DoF-object, such as total magnetization symmetry.

#### Quantum mechanical spins

##### Total magnetization symmetry
Total magnetization symmetry is a symmetry where the system is invariant under the total magnetization operator. In a system with $N$ sites, the total magnetization operator $\hat{S}^z$ acts on a state $\vert a(S^z) \rangle$ as follows:
```math
\hat{S}^z \vert a(S^z) \rangle = \sum_{i=1}^{N} S_i^z \vert a(S^z) \rangle = S^z \vert a(S^z) \rangle
```
where $S_i^z$ is the magnetization of the $i$-th site, and $S^z$ is the total magnetization quantum number.
You can define a total magnetization symmetry group for a system with a certain number of sites using the [`sym`](@ref SymBasis.SymGroups.sym) function as follows:
```@example
using SymBasis.DoFObjects
using SymBasis.SymGroups

dofo = dof_object(:Spin, 1 // 1) # define, for example, a spin-1
N = 5 # number of sites
Sz = 0//1 # total magnetization quantum number

sg = sym(:TotalMagnetization, dofo, Sz, N)
```

## Custom symmetry groups
In addition to the predefined symmetry groups, you can also define your own custom symmetry groups by specifying the appropriate parameters when constructing the symmetry group via the [`SymGroup`](@ref SymBasis.SymGroups.SymGroup) constructor from the [`SymBasis.SymGroups`](@ref symgroups-api) submodule.

To define a custom symmetry group, you need to specify the following parameters:
- `dofo`: The DoF-object that the symmetry group is associated with.
- `cycles`: A vector of `NamedTuple`s, where each `NamedTuple` represents a cycle in the symmetry group. Each `NamedTuple` has its own special fields that depend on the type of symmetry you want to define. For example, for a custom symmetry that is defined by a permutation, you would specify the `perm` field in the `NamedTuple` to represent the permutation.
- `check`: A function that checks whether a given state is invariant under the symmetry operation. This function should take a cycle, a state and the previous boolean result of checking the previous cycle as input and return a boolean value indicating whether the state is invariant under the symmetry operation and the previous cycles.
- `apply`: A function that applies the symmetry operation to a given state. This function should take a cycle, a state and return the state obtained by applying the symmetry operation to the input state.
- `factors`: A vector of factors that are used to calculate the normalization factor for the basis states. The factors should be defined in such a way that they can be used to calculate the normalization factor for the basis states that are invariant under the symmetry operation.
- `N`: The number of sites in the system.

As an example, let's define a custom symmetry group for a DoF-object that represents a system containing pet emojis (🐶, 🐱, 🦜, 🐢), where the symmetry is defined by preventing the 🐱 from being next to 🐶. We can define this custom symmetry group as follows:

Let's first import the necessary submodules and then define our DoF-object for the system containing pet emojis:
```@example custom_symmetry
using SymBasis.DigitBase
using SymBasis.DoFObjects
using SymBasis.SymGroups

dofo = DoFObject(:Pet, (:🐶, :🐱, :🦜, :🐢))
```
Next, we define the number of sites:
```@example custom_symmetry
N = 3
```
Then, we define the cycles for the custom symmetry. In this case, we want to prevent the 🐱 from being next to 🐶, so we can define a cycle that represents this constraint:
```@example custom_symmetry
cycles = [(; prevent=(UInt(0), UInt(1)), N=N)] # prevent the 🐱 from being next to 🐶
```
Next, we can define the check function for the custom symmetry. This function will check if a given state is invariant under the symmetry operation, which in this case means checking if the 🐱 and 🐶 are next to each other in the state:
```@example custom_symmetry
function check_cat_dog(
    p::Tp,
    state::BaseInt{T,Ti,B},
    prev_bool::Bool
) where {
    T<:Integer,
    Ti<:Integer,
    B,
    Tp<:NamedTuple{(:prevent, :N),<:Tuple{NTuple{2,T},<:Integer}}
}
    return prev_bool && !any(
        map(2:(p.N-1)) do i
            d_prev, d_curr, d_next = read(state, i - 1), read(state, i), read(state, i + 1)

            (d_curr == p.prevent[1] && d_next == p.prevent[2]) ||
                (d_curr == p.prevent[2] && d_next == p.prevent[1]) ||
                (d_curr == p.prevent[1] && d_prev == p.prevent[2]) ||
                (d_curr == p.prevent[2] && d_prev == p.prevent[1])
        end
    )
end
```
Then, we can define the apply function for the custom symmetry. This function will apply the symmetry operation to a given state. In this case, since the symmetry operation does not change the state, we can simply return the input state:
```@example custom_symmetry
function apply_cat_dog(
    p::Tp,
    state::BaseInt{T,Ti,B}
) where {
    T<:Integer,
    Ti<:Integer,
    B,
    Tp<:NamedTuple{(:prevent, :N),<:Tuple{NTuple{2,T},<:Integer}}
}
    return state
end
```
Next, we define the factors for the custom symmetry. In this case, we can simply use a factor of 1 since the normalization factor for the basis states that are invariant under the symmetry operation is 1:
```@example custom_symmetry
factors = [1,]
```
Finally, we can construct the custom symmetry group using the [`SymGroup`](@ref SymBasis.SymGroups.SymGroup) constructor:
```@example custom_symmetry
sg = SymGroup(
    dofo,
    cycles,
    check_cat_dog,
    apply_cat_dog,
    factors,
    N
)
```
## Combining symmetry groups
You can also combine multiple symmetry groups to generate bases that conserve multiple symmetries simultaneously. This can be done using the [`∘`](@ref Base.:(∘)) function from the [`SymBasis.SymGroups`](@ref symgroups-api) submodule, which eventually returns a [`CombSymGroup`](@ref SymBasis.SymGroups.CombSymGroup) type that represents the combined symmetries.

For example, if you want to combine the total magnetization symmetry and the translational symmetry, you can define the combined symmetry group as follows:
```@example
using SymBasis.DoFObjects
using SymBasis.SymGroups

dofo = dof_object(:Spin, 1 // 2) # define, for example, a spin-1/2

N = 4 # number of sites

Sz = 0//1 # total magnetization quantum number

perm = mod1.((1:N) .+ 1, N) # permutation for translational symmetry
k = 0 # momentum quantum number

sg_total_magnetization = sym(:TotalMagnetization, dofo, Sz, N)
sg_translational = sym(:Translational, dofo, k, perm)

csg = sg_total_magnetization ∘ sg_translational
```

!!! warning
    When combining multiple symmetry groups, it is important to ensure that the symmetries commute with each other in the basis. If the symmetries do not commute, the generated basis may not be correct. It is the user's responsibility to check for the commutation of symmetries after generating the basis using the [`is_commutative`](@ref SymBasis.Bases.is_commutative) function from the [`SymBasis.Bases`](@ref bases-api) submodule.