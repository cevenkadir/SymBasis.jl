# Static analysis of SymBasis with JET.jl.
#
# JET is deliberately NOT part of the main `[targets].test` set: every JET release supports
# only specific Julia minor versions, so listing it there could break `Pkg.test()`
# resolution on some CI matrix entries (nightly/pre). It lives in its own environment.
#
# Run from the repository root:
#   julia --project=test/jet -e 'using Pkg; Pkg.develop(path="."); Pkg.instantiate()'
#   julia --project=test/jet test/jet/runjet.jl
# `test/runtests.jl` runs this file automatically when `ENV["SYMBASIS_JET"] == "1"`.
using JET
using SymBasis
using Test

# Known false positives. The predefined-symmetry `check_*`/`apply_*` functions dispatch on
# `NamedTuple`s whose payload types JET can only infer as `Union`s (e.g. `p.N::Union{Integer,
# WeightedCounts}`); JET then reports the union-split branches that the dispatch on the
# concrete tuple type never reaches. They are keyed by the reported function so that any
# other report still fails the test.
const KNOWN_FALSE_POSITIVES = (:check_Ns, :apply_flip)

@testset "JET" begin
    result = JET.report_package(SymBasis; target_modules=(SymBasis,))
    unexpected = filter(JET.get_reports(result)) do report
        return !(report.vst[1].linfo.def.name in KNOWN_FALSE_POSITIVES)
    end
    isempty(unexpected) || show(stdout, MIME"text/plain"(), unexpected)
    @test isempty(unexpected)
end
