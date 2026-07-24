# Compare SymBasis vs XDiag.jl: spinful-fermion (1D) chain, symmetry-resolved basis
# construction and representative-state lookup. Reports mean +/- std timing over multiple
# samples.
#
# Run with: julia --project=benchmark benchmark/spinful_fermion_basis.jl
# Sweep size selectable via: BENCH_SWEEP=quick|large (default quick)

include(joinpath(@__DIR__, "common.jl"))
include(joinpath(@__DIR__, "xdiag_common.jl"))

using .BenchCommon
using .XDiagCommon

using SymBasis
using XDiag

const CONFIGS = (:u1, :u1_t, :u1_t_p)
const CONFIG_LABELS = Dict(:u1 => "U1", :u1_t => "U1+T(k=0)", :u1_t_p => "U1+T(k=0)+P(p=1)")

function symbasis_group(N::Integer, config::Symbol, n_up::Integer, n_down::Integer)
    dofo = dof_object(SpinfulFermion(1 // 2, 2))
    sg_U1 = sym(TotalSpinfulFermionicNumber(n_up, n_down, N), dofo)
    config == :u1 && return dofo, sg_U1

    sg_T = sym(Translational(0, mod1.((1:N) .+ 1, N)), dofo)
    config == :u1_t && return dofo, sg_U1 ∘ sg_T

    sg_P = sym(SpatialReflection(1, reverse(1:N)), dofo)
    return dofo, sg_U1 ∘ sg_T ∘ sg_P
end

function xdiag_block(N::Integer, config::Symbol, n_up::Integer, n_down::Integer)
    config == :u1 && return Electron(N, n_up, n_down)

    if config == :u1_t
        irrep = cyclic_group_irrep(N, 0)
    else
        group = build_translation_reflection_group(N)
        irrep = Representation(group, ones(ComplexF64, length(group)))
    end
    return Electron(N, n_up, n_down, irrep)
end

function run()
    Ns = sweep_sizes(:spinful_fermion)
    rows = []

    local last_ba, last_N
    for N in Ns, config in CONFIGS
        n = N ÷ 2
        dofo, csg = symbasis_group(N, config, n, n)
        (ba, sym_mean, sym_std) = benchmark_stats(() -> SymBasis.basis(dofo, N, csg))
        dim_sym = length(ba.states)

        (block, xdiag_mean, xdiag_std) = benchmark_stats(() -> xdiag_block(N, config, n, n))
        dim_xdiag = dim(block)

        @assert dim_sym == dim_xdiag "dimension mismatch at N=$N, $(config): SymBasis=$dim_sym, XDiag=$dim_xdiag"

        println("spinful fermion N=$N $(CONFIG_LABELS[config]): dim=$dim_sym  SymBasis=$(sym_mean)±$(sym_std)s  XDiag=$(xdiag_mean)±$(xdiag_std)s")
        push!(rows, (N, CONFIG_LABELS[config], dim_sym, sym_mean, sym_std, xdiag_mean, xdiag_std))

        if config == :u1_t_p
            last_ba, last_N = ba, N
        end
    end

    write_csv(
        joinpath(results_dir(), "spinful_fermion_construction.csv"),
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
    samples = [S(rand(0:(4^N - 1))) for _ in 1:nsamples]
    csg = last_ba.sg

    (_, batch_mean, batch_std) = benchmark_stats() do
        for s in samples
            SymBasis.representative(s, csg)
        end
    end
    mean_per_call = batch_mean / nsamples
    std_per_call = batch_std / nsamples

    println("spinful fermion representative lookup (N=$N, U1+T+P, $nsamples samples): SymBasis=$(mean_per_call)±$(std_per_call)s/call, XDiag=N/A (no decoupled API)")
    write_csv(
        joinpath(results_dir(), "spinful_fermion_representative.csv"),
        [
            "N", "config", "nsamples",
            "symbasis_mean_seconds_per_call", "symbasis_std_seconds_per_call",
            "xdiag_mean_seconds_per_call", "xdiag_std_seconds_per_call",
        ],
        [(N, CONFIG_LABELS[:u1_t_p], nsamples, mean_per_call, std_per_call, "NA", "NA")],
    )
end

run()
