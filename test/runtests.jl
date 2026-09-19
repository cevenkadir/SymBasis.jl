using Test

# Runs `file` in its own throwaway module so that definitions and `using`s do not leak
# between test files (the same isolation `SafeTestsets.@safetestset` provides). Every file
# therefore has to import what it needs, which also keeps it runnable on its own.
function run_isolated(file::AbstractString)
    mod = Module(gensym(:IsolatedTests))
    @testset "$file" begin
        Base.include(mod, joinpath(@__DIR__, file))
    end
end

@testset verbose = true "SymBasis.jl" begin
    run_isolated("digitbase/bi.jl")
    run_isolated("digitbase/bir.jl")
    run_isolated("dofobjects/dofobject.jl")
    run_isolated("dofobjects/predefined_funcs.jl")
    run_isolated("miscs/auxiliary.jl")
    run_isolated("symgroups/symgroup.jl")
    run_isolated("symgroups/predefined_funcs.jl")
    run_isolated("bases/basis.jl")
    run_isolated("quality/aqua.jl")
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
