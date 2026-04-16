module SymGroups

include("symgroup.jl")
export SymGroup, CombSymGroup
export _make_hashset

include("predefined_funcs/general.jl")
export AbstractSymSpec
export Translational, SpatialReflection, Rotational
export check_Nₛ, check_perm, check_flip
export apply_Nₛ, apply_perm, apply_flip
export sym

include("predefined_funcs/spin.jl")
export TotalMagnetization, SpinMultipole, SpinInversion
export check_multipole
export apply_multipole

include("predefined_funcs/boson.jl")
export ParticleNumberConservation, TotalBosonicNumber

end
