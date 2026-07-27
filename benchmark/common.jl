module BenchCommon

using BenchmarkTools
using Statistics: mean, std

export benchmark_stats, write_csv, results_dir, sweep_sizes

# CI writes the canonical, tracked results directly; local runs default to a gitignored
# scratch subdirectory so they never collide with the bot's commits to benchmark/results/*.csv
# on the next `git pull`.
const RESULTS_DIR = get(ENV, "CI", "false") == "true" ?
    joinpath(@__DIR__, "results") :
    joinpath(@__DIR__, "results", "local")

function results_dir()
    mkpath(RESULTS_DIR)
    return RESULTS_DIR
end

"""
    sweep_sizes(kind::Symbol)

Return the `N` values to sweep over for the current `BENCH_SWEEP` environment variable
(`"quick"` (default) or `"large"`). `kind` is `:spin_fermion`, `:boson`, or `:spinful_fermion`.
"""
function sweep_sizes(kind::Symbol)
    sweep = get(ENV, "BENCH_SWEEP", "quick")
    if kind == :spin_fermion
        return sweep == "large" ? (16, 18, 20, 22, 24) : (8, 10, 12, 14, 16)
    elseif kind == :boson
        return sweep == "large" ? (10, 12, 14) : (6, 8, 10, 12)
    elseif kind == :spinful_fermion
        # SpinfulFermion's local dimension is 4 (vs 2 for spin/spinless-fermion, 3 for boson),
        # so the Hilbert space grows much faster with N -- a smaller range than the other
        # kinds is needed to keep runtime comparable (N=14 alone already takes ~5s for a
        # single U1-sector construction).
        return sweep == "large" ? (10, 12, 14) : (4, 6, 8, 10, 12)
    else
        throw(ArgumentError("unknown sweep kind $kind"))
    end
end

"""
    benchmark_stats(f; evals=1, samples=10, seconds=30)

Call `f()` once to obtain `result` (also serves as an untimed warmup for JIT compilation),
then benchmark it with `BenchmarkTools.@benchmark` (`evals=1` so each sample is a single call
of `f`, matching the per-call semantics used on the Python/QuSpin side rather than letting
BenchmarkTools batch many evaluations per sample for fast operations).

Returns `(result, mean_seconds, std_seconds)`.
"""
function benchmark_stats(f::Function; evals::Int=1, samples::Int=10, seconds::Real=30)
    result = f()
    trial = @benchmark $f() evals = evals samples = samples seconds = seconds
    return result, mean(trial).time / 1e9, std(trial).time / 1e9
end

function write_csv(path::AbstractString, header::Vector{String}, rows::AbstractVector)
    open(path, "w") do io
        println(io, join(header, ","))
        for row in rows
            println(io, join(row, ","))
        end
    end
    return path
end

end
