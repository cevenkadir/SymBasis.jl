# Compare SymBasis vs XDiag.jl: soft-core boson chain (max_occupancy=2, d=3 local states),
# symmetry-resolved basis construction and representative-state lookup.
#
# Run with: julia --project=benchmark benchmark/boson_basis.jl
# Sweep size selectable via: BENCH_SWEEP=quick|large (default quick)

include(joinpath(@__DIR__, "common.jl"))
include(joinpath(@__DIR__, "xdiag_common.jl"))

using .BenchCommon
using .XDiagCommon

using SymBasis
using XDiag

const MAX_OCCUPANCY = 2
const D = MAX_OCCUPANCY + 1 # local dimension, matches XDiag's `d`
const CONFIGS = (:u1, :u1_t, :u1_t_p)
const CONFIG_LABELS = Dict(:u1 => "U1", :u1_t => "U1+T(k=0)", :u1_t_p => "U1+T(k=0)+P(p=1)")

function symbasis_group(N::Integer, config::Symbol, n_particles::Integer)
    dofo = dof_object(SymBasis.Boson(MAX_OCCUPANCY))
    sg_U1 = sym(TotalBosonicNumber(n_particles, N), dofo)
    config == :u1 && return dofo, sg_U1

    sg_T = sym(Translational(0, mod1.((1:N) .+ 1, N)), dofo)
    config == :u1_t && return dofo, sg_U1 ∘ sg_T

    sg_P = sym(SpatialReflection(1, reverse(1:N)), dofo)
    return dofo, sg_U1 ∘ sg_T ∘ sg_P
end

function xdiag_block(N::Integer, config::Symbol, n_particles::Integer)
    config == :u1 && return XDiag.Boson(N, D, n_particles)

    if config == :u1_t
        irrep = cyclic_group_irrep(N, 0)
    else
        group = build_translation_reflection_group(N)
        irrep = Representation(group, ones(ComplexF64, length(group)))
    end
    return XDiag.Boson(N, D, n_particles, irrep)
end

function run()
    Ns = sweep_sizes(:boson)
    rows = []

    local last_ba, last_N
    for N in Ns, config in CONFIGS
        n_particles = N # average filling of 1 boson/site (out of max 2/site)
        dofo, csg = symbasis_group(N, config, n_particles)
        (ba, sym_mean, sym_std) = benchmark_stats(() -> SymBasis.basis(dofo, N, csg))
        dim_sym = length(ba.states)

        (block, xdiag_mean, xdiag_std) = benchmark_stats(() -> xdiag_block(N, config, n_particles))
        dim_xdiag = dim(block)

        @assert dim_sym == dim_xdiag "dimension mismatch at N=$N, $(config): SymBasis=$dim_sym, XDiag=$dim_xdiag"

        println("boson N=$N $(CONFIG_LABELS[config]): dim=$dim_sym  SymBasis=$(sym_mean)±$(sym_std)s  XDiag=$(xdiag_mean)±$(xdiag_std)s")
        push!(rows, (N, CONFIG_LABELS[config], dim_sym, sym_mean, sym_std, xdiag_mean, xdiag_std))

        if config == :u1_t_p
            last_ba, last_N = ba, N
        end
    end

    write_csv(
        joinpath(results_dir(), "boson_construction.csv"),
        [
            "N", "config", "dim",
            "symbasis_mean_seconds", "symbasis_std_seconds",
            "xdiag_mean_seconds", "xdiag_std_seconds",
        ],
        rows,
    )

    N = last_N
    S = eltype(last_ba.states)
    nsamples = 10_000
    samples = [S(rand(0:(D^N - 1))) for _ in 1:nsamples]
    csg = last_ba.sg

    (_, batch_mean, batch_std) = benchmark_stats() do
        for s in samples
            SymBasis.representative(s, csg)
        end
    end
    mean_per_call = batch_mean / nsamples
    std_per_call = batch_std / nsamples

    println("boson representative lookup (N=$N, U1+T+P, $nsamples samples): SymBasis=$(mean_per_call)±$(std_per_call)s/call, XDiag=N/A (no decoupled API)")
    write_csv(
        joinpath(results_dir(), "boson_representative.csv"),
        [
            "N", "config", "nsamples",
            "symbasis_mean_seconds_per_call", "symbasis_std_seconds_per_call",
            "xdiag_mean_seconds_per_call", "xdiag_std_seconds_per_call",
        ],
        [(N, CONFIG_LABELS[:u1_t_p], nsamples, mean_per_call, std_per_call, "NA", "NA")],
    )
end

run()
