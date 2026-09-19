using Test

using SymBasis

@testset "SymBasis.jl Tests" begin
    @info "Testing BaseInt..."
    include("digitbase/bi.jl")
    @info "Testing BaseIntRange..."
    include("digitbase/bir.jl")

    @info "Testing DoFObject..."
    include("dofobjects/dofobject.jl")
    @info "Testing DoFObject's predefined functions..."
    include("dofobjects/predefined_funcs.jl")

    @info "Testing auxiliary functions of Miscs..."
    include("miscs/auxiliary.jl")

    @info "Testing SymGroup..."
    include("symgroups/symgroup.jl")
    @info "Testing SymGroup's predefined functions..."
    include("symgroups/predefined_funcs.jl")

    @info "Testing Basis..."
    include("bases/basis.jl")

    @info "Testing package quality (Aqua)..."
    include("quality/aqua.jl")
end

# JET lives in its own environment (test/jet) because each JET release supports only some
# Julia versions; opt in with `SYMBASIS_JET=1` after setting that environment up, see
# test/jet/runjet.jl.
if get(ENV, "SYMBASIS_JET", "0") == "1"
    @info "Testing static analysis (JET)..."
    run(
        `$(Base.julia_cmd()) --project=$(joinpath(@__DIR__, "jet")) $(joinpath(@__DIR__, "jet", "runjet.jl"))`
    )
end
