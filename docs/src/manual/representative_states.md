# Determining representative states
In SymBasis.jl, each symmetry-related orbit of basis states is represented by a single *representative* state. Starting from a state $\lvert a'(q)\rangle$, you generate all symmetry images under the symmetry operator $\hat{S}$ and choose the one with the smallest hash value as the representative:
```math
\lvert a(q)\rangle = \hat{S}^{\ell_{\mathrm{rep}}}\lvert a'(q)\rangle,
\qquad
\ell_{\mathrm{rep}}=\arg\min_{\ell}\Big\{\mathrm{hash}\!\big[\hat{S}^\ell\lvert a'(q)\rangle\big]\Big\}~.
```
Here, $q$ labels the symmetry sector, and $\ell_{\mathrm{rep}}$ is the shift needed to map $\lvert a'(q)\rangle$ onto its representative $\lvert a(q)\rangle$. This is handled automatically when you construct a basis via [`basis`](@ref SymBasis.Bases.basis) from [`SymBasis.Bases`](@ref bases-api), ensuring that each symmetry sector contains only one representative per orbit.

## Operator action and mapping back to representatives
Consider an operator decomposed into local contributions,
```math
\hat{F} \coloneqq \sum_{j=0}^{N_F}\hat{F}_j~,
```
with $\hat{F}_0$ the diagonal part and $\hat{F}_{j>0}$ off-diagonal parts. Acting with one term on a representative basis state generally produces a (symmetry-related) state that is *not* itself in representative form:
```math
\hat{F}_j\lvert a(q)\rangle = f_j[a(q)]\,\lvert b'_j(q)\rangle~.
```
To express the result in the representative basis, map $\lvert b'_j(q)\rangle$ to its representative $\lvert b_j(q)\rangle$ using the symmetry operation:
```math
\lvert b_j(q)\rangle = \hat{S}^{\ell_j}\lvert b'_j(q)\rangle~,
```
where $\ell_j$ is the number of applications needed to reach the representative. Equivalently,
```math
\hat{F}_j\lvert a(q)\rangle = f_j[a(q)]\,\hat{S}^{-\ell_j}\lvert b_j(q)\rangle~.
```
Including the symmetry phase and normalization factors, this becomes
```math
\hat{F}_j\lvert a(q)\rangle = f_j[a(q)]\,\eta(q,\ell_j)\,\sqrt{\frac{N_{b_j(q)}}{N_{a(q)}}}\,\lvert b_j(q)\rangle~,
```
where $\eta(q,\ell_j)$ is the phase accrued when relating $\lvert b'_j(q)\rangle$ to $\lvert b_j(q)\rangle$, and $N_{a(q)}$, $N_{b_j(q)}$ are the state normalization factors.

## Matrix elements

- **Diagonal term**:
```math
\langle a(q)\lvert \hat{F}_0\rvert a(q)\rangle = f_0[a(q)]~.
```

- **Off-diagonal term** (after mapping to representatives):
```math
\langle b_j(q)\lvert \hat{F}_{j>0}\rvert a(q)\rangle
= f_{j>0}[a(q)]\,\eta(q,\ell_j)\,\sqrt{\frac{N_{b_j(q)}}{N_{a(q)}}}~.
```

## Implementation in SymBasis.jl
To obtain the representative for an arbitrary state (and associated normalization information), use [`representative`](@ref SymBasis.Bases.representative) from [`SymBasis.Bases`](@ref bases-api). It takes a state and a symmetry group and returns the corresponding representative data used to build symmetry-resolved matrix elements.

For example, if you have a state $\vert \downarrow \downarrow \uparrow \uparrow \rangle$ in a spin-1/2 chain with total magnetization symmetry ($S^z=0$ sector) and translational symmetry ($k=0$ sector), you can find its representative state and normalization factor as follows:
```@example
using SymBasis.DigitBase
using SymBasis.DoFObjects
using SymBasis.SymGroups
using SymBasis.Bases

N = 4 # number of sites
dofo = dof_object(:Spin, 1 // 2) # define a DoF-object for spin-1/2

Sz = 0 // 1 # total magnetization quantum number
# define the symmetry group for total magnetization symmetry
sg_Sz = sym(:TotalMagnetization, dofo, Sz, N)

perm = mod1.((1:N) .+ 1, N) # permutation for translational symmetry
k = 0 # momentum quantum number
# define the symmetry group for translational symmetry
sg_translational = sym(:Translational, dofo, k, perm)

# combine the total magnetization symmetry and the translational symmetry
csg = sg_Sz ∘ sg_translational

state = bi"0011"2 # state |↓↓↑↑⟩ in binary representation

# get the representative state and normalization
rep_state, norm_factor = representative(state, csg)
```
This will return the representative state corresponding to $\vert \uparrow \uparrow \downarrow \downarrow \rangle$ in the specified symmetry sector, along with its normalization factor, which can be used to compute matrix elements of operators in the basis.

!!! warning
    The `representative` function assumes that the input state is valid within the specified symmetry sector. If the state does not belong to the symmetry sector defined by the symmetry group, the function still returns a representative state and normalization factor, but they may not correspond to a valid state in the symmetry sector. It is the user's responsibility to ensure that the input state is consistent with the defined symmetries when using the `representative` function. You can use the [`is_commutative`](@ref SymBasis.Bases.is_commutative) function from the [`SymBasis.Bases`](@ref bases-api) submodule to check if the symmetries commute and thus ensure that the representative states are valid within the symmetry sector.