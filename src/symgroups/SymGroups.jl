module SymGroups

include("symgroup.jl")
export SymGroup, CombSymGroup
export _make_hashset

include("predefined_funcs.jl")
export AbstractSymSpec
export TotalMagnetization, SpinInversion
export Translational, SpatialReflection, Rotational
export check_Nₛ, check_perm, check_flip
export apply_Nₛ, apply_perm, apply_flip
export sym

end
