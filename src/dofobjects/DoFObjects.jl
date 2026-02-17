module DoFObjects

include("dofobject.jl")
export DoFObject
export bint

include("predefined_funcs.jl")
export AbstractDoFSpec
export Spin
export dof_object

end
