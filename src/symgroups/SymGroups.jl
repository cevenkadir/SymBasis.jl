module SymGroups

include("symgroup.jl")
export SymGroup, CombSymGroup
export _make_hashset

include("predefined_funcs.jl")
export AbstractSymSpec
export TotalMagnetization, Translational, SpatialReflection
export check_Nₛ, check_perm
export apply_Nₛ, apply_perm
export sym

end
