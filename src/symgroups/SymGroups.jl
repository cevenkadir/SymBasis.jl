module SymGroups

include("symgroup.jl")
export SymGroup, CombSymGroup
export _make_hashset

include("predefined_funcs.jl")
export AbstractSymSpec
export TotalMagnetization, Parity
export Translational, SpatialReflection
export check_Nₛ, check_perm, check_flip
export apply_Nₛ, apply_perm, apply_flip
export sym

end
