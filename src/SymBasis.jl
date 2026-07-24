module SymBasis

# DigitBase submodule
include("digitbase/DigitBase.jl")

using .DigitBase: BaseInt
export BaseInt

using .DigitBase: @bi_str
export @bi_str

using .DigitBase: flip, inc, dec, permute
export flip, inc, dec, permute

using .DigitBase: num_digits_in_base
export num_digits_in_base

using .DigitBase: BaseIntRange
export BaseIntRange

# DoFObjects submodule
include("dofobjects/DoFObjects.jl")
using .DoFObjects: DoFObject
export DoFObject

using .DoFObjects: bint
export bint

using .DoFObjects: AbstractDoFSpec
export AbstractDoFSpec

using .DoFObjects: Spin, Boson, SpinlessFermion, SpinfulFermion
export Spin, Boson, SpinlessFermion, SpinfulFermion

using .DoFObjects: dof_object
export dof_object

include("miscs/Miscs.jl")

# SymGroups submodule
include("symgroups/SymGroups.jl")
using .SymGroups: SymGroup, CombSymGroup
export SymGroup, CombSymGroup

using .SymGroups: AbstractSymSpec
export AbstractSymSpec

using .SymGroups: Translational, SpatialReflection, Rotational
export Translational, SpatialReflection, Rotational

using .SymGroups: check_Nₛ, check_perm, check_flip
export check_Nₛ, check_perm, check_flip

using .SymGroups: apply_Nₛ, apply_perm, apply_flip
export apply_Nₛ, apply_perm, apply_flip

using .SymGroups: phase_unity
export phase_unity

using .SymGroups: sym
export sym

using .SymGroups: TotalMagnetization, SpinMultipole, SpinInversion
export TotalMagnetization, SpinMultipole, SpinInversion

using .SymGroups: check_multipole
export check_multipole

using .SymGroups: apply_multipole
export apply_multipole

using .SymGroups: ParticleNumberConservation, TotalBosonicNumber
export ParticleNumberConservation, TotalBosonicNumber

using .SymGroups: TotalSpinlessFermionicNumber
export TotalSpinlessFermionicNumber

using .SymGroups: TotalSpinfulFermionicNumber, FermionicSpinInversion
export TotalSpinfulFermionicNumber, FermionicSpinInversion

using .SymGroups: phase_perm_fermionic
export phase_perm_fermionic

# Bases submodule
include("bases/Bases.jl")
using .Bases: Basis
export Basis

using .Bases: basis
export basis

using .Bases: is_commutative, representative
export is_commutative, representative

end
