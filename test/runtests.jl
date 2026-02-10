using Test

using SymBasis.DigitBase
using SymBasis.DoFObjects
using SymBasis.Miscs
using SymBasis.SymGroups
using SymBasis.Bases

@testset "SymBasis.jl Tests" begin
    @info "Testing BaseInt..."
    include("digitbase/bi.jl")
    @info "Testing BaseIntRange..."
    include("digitbase/bir.jl")

    @info "Testing DoFObject..."
    include("dofobjects/dofobject.jl")
    @info "Testing DoFObject's predefined functions..."
    include("dofobjects/predefined_funcs.jl")

    @info "Testing SmallHashSet..."
    include("miscs/small_hash_set.jl")
    @info "Testing auxiliary functions of Miscs..."
    include("miscs/auxiliary.jl")

    @info "Testing SymGroup..."
    include("symgroups/symgroup.jl")
    @info "Testing SymGroup's predefined functions..."
    include("symgroups/predefined_funcs.jl")

    @info "Testing Basis..."
    include("bases/basis.jl")
end
