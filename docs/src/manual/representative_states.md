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
In practice, [`representative`](@ref SymBasis.Bases.representative) returns a representative coefficient
```math
\xi_j \equiv \mathrm{rep\_factor}(b'_j(q))
```
that combines the symmetry-sector factor and the state-dependent phase required to map $\lvert b'_j(q)\rangle$ onto $\lvert b_j(q)\rangle$. Including this coefficient and the normalization factors, the mapped action is
```math
\hat{F}_j\lvert a(q)\rangle = f_j[a(q)]\,\xi_j\,\sqrt{\frac{N_{b_j(q)}}{N_{a(q)}}}\,\lvert b_j(q)\rangle~,
```
where $N_{a(q)}$ and $N_{b_j(q)}$ are the state normalization factors.

For a single symmetry group, this coefficient can be viewed schematically as
```math
\xi_j = \phi_{\hat{S}^{\ell_j}}\!\big(b'_j(q)\big)\,\chi_{\hat{S}^{\ell_j}},
```
with $\phi_{\hat{S}^{\ell_j}}\!\big(b'_j(q)\big)$ the phase from the symmetry action and $\chi_{\hat{S}^{\ell_j}}$ the symmetry-sector factor associated with the cycle that produces the representative (for translational symmetry this is analogous to notation such as $\phi_{\hat{T}^{r}}(a)$ in the symmetry-group documentation).

## Matrix elements

- **Diagonal term**:
```math
\langle a(q)\lvert \hat{F}_0\rvert a(q)\rangle = f_0[a(q)]~.
```

- **Off-diagonal term** (after mapping to representatives):
```math
\langle b_j(q)\lvert \hat{F}_{j>0}\rvert a(q)\rangle
= f_{j>0}[a(q)]\,\xi_j\,\sqrt{\frac{N_{b_j(q)}}{N_{a(q)}}}~,
```
where $\xi_j$ is obtained from `rep_state, rep_factor = representative(b'_j(q), \text{symmetry group})`.

## Implementation in SymBasis.jl
To obtain the representative for an arbitrary state (and the associated representative coefficient), use [`representative`](@ref SymBasis.Bases.representative) from [`SymBasis.Bases`](@ref bases-api). It takes a state and a symmetry group and returns the corresponding representative data used to build symmetry-resolved matrix elements.

For example, if you have a state $\lvert \downarrow \uparrow \uparrow \downarrow \rangle$ in a spin-1/2 chain with total magnetization symmetry ($S^z=0$ sector) and translational symmetry ($k=0$ sector), you can find its representative state and representative coefficient as follows:
```@example
using SymBasis.DigitBase
using SymBasis.DoFObjects
using SymBasis.SymGroups
using SymBasis.Bases

N = 4 # number of sites
dofo = dof_object(Spin(1 // 2)) # define a DoF-object for spin-1/2

Sz = 0 # total magnetization quantum number
# define the symmetry group for total magnetization symmetry
sg_Sz = sym(TotalMagnetization(Sz, N), dofo)

perm = mod1.((1:N) .+ 1, N) # permutation for translational symmetry
k = 0 # momentum quantum number
# define the symmetry group for translational symmetry
sg_translational = sym(Translational(k, perm), dofo)

# combine the total magnetization symmetry and the translational symmetry
csg = sg_Sz ∘ sg_translational

state = bi"0110"2 # state |↓↑↑↓⟩ in binary representation

# get the representative state and representative coefficient
rep_state, rep_factor = representative(state, csg)
```
This returns the representative state in the specified symmetry sector, together with the representative coefficient (including symmetry-eigenvalue factors and any state-dependent phase from the symmetry action). This coefficient is the quantity needed when mapping operator-generated states back to representatives.

!!! warning
    The [`representative`](@ref SymBasis.Bases.representative) function assumes that the input state is valid within the specified symmetry sector. If the state does not belong to the symmetry sector defined by the symmetry group, the function still returns a representative state and representative coefficient, but they may not correspond to a valid state in the symmetry sector. It is the user's responsibility to ensure that the input state is consistent with the defined symmetries when using the [`representative`](@ref SymBasis.Bases.representative) function. You can use the [`is_commutative`](@ref SymBasis.Bases.is_commutative) function from the [`SymBasis.Bases`](@ref bases-api) submodule to check if the symmetries commute and thus ensure that the representative states are valid within the symmetry sector.