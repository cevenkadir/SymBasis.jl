module DigitBase

include("bi.jl")
include("bir.jl")

export BaseInt
export @bi_str, bi_str

export flip, inc, dec, permute
export num_digits_in_base

export BaseIntRange

end
