# Aggregate the CSV outputs from spin_basis.jl / fermion_basis.jl / boson_basis.jl (SymBasis +
# XDiag.jl) and quspin_bench.py (QuSpin) into a single markdown comparison page for the docs.
# Plots are NOT pre-rendered here -- the page embeds `@example` code blocks (see
# benchmark/plotting.jl) that Documenter executes live during `docs/make.jl`, reading the same
# CSVs this script reads. No image file is ever generated or committed by this script.
#
# Run with: julia --project=benchmark benchmark/compare_results.jl

using Printf

const RESULTS = joinpath(@__DIR__, "results")
const DOCS_PAGE = joinpath(@__DIR__, "..", "docs", "src", "benchmarks.md")

function read_csv(path::AbstractString)
    isfile(path) || return nothing
    lines = filter(!isempty, readlines(path))
    header = String.(split(lines[1], ","))
    rows = [String.(split(l, ",")) for l in lines[2:end]]
    return header, rows
end

row_dict(header, row) = Dict(header[i] => row[i] for i in eachindex(header))

function fmt_stat(mean_s::AbstractString, std_s::AbstractString)
    (mean_s == "NA" || mean_s == "") && return "N/A"
    m = parse(Float64, mean_s)
    s = (std_s == "NA" || std_s == "") ? nothing : parse(Float64, std_s)
    return s === nothing ? (@sprintf "%.4g s" m) : (@sprintf "%.4g ± %.2g s" m s)
end

function speedup(base_mean::AbstractString, other_mean::AbstractString)
    (base_mean == "NA" || other_mean == "NA" || base_mean == "" || other_mean == "") && return "N/A"
    return @sprintf("%.2fx", parse(Float64, other_mean) / parse(Float64, base_mean))
end

function construction_table(io, name::AbstractString, label::AbstractString)
    sym = read_csv(joinpath(RESULTS, "$(name)_construction.csv"))
    sym === nothing && return
    sym_header, sym_rows = sym

    qs = read_csv(joinpath(RESULTS, "$(name)_construction_quspin.csv"))
    qs_by_key = Dict{Tuple{String,String},Dict{String,String}}()
    if qs !== nothing
        qs_header, qs_rows = qs
        for r in qs_rows
            d = row_dict(qs_header, r)
            qs_by_key[(d["N"], d["config"])] = d
        end
    end

    println(io, "### $label — basis construction")
    println(io)
    # Executed live by Documenter (see the shared setup block in `main`, which `include`s
    # benchmark/plotting.jl into this page's persistent `@example benchmarks` session).
    println(io, "```@example benchmarks")
    println(io, "plot_construction(\"$name\", \"$label\")")
    println(io, "```")
    println(io)
    println(io, "| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |")
    println(io, "|---|---|---|---|---|---|---|---|")
    for r in sym_rows
        d = row_dict(sym_header, r)
        qd = get(qs_by_key, (d["N"], d["config"]), nothing)
        qs_dim = qd === nothing ? "NA" : qd["dim"]
        qs_mean = qd === nothing ? "NA" : qd["quspin_mean_seconds"]
        qs_std = qd === nothing ? "NA" : qd["quspin_std_seconds"]
        note = (qs_dim != "NA" && qs_dim != d["dim"]) ? " **(dim mismatch!)**" : ""

        println(
            io,
            "| $(d["N"]) | $(d["config"]) | $(d["dim"])$note | ",
            "$(fmt_stat(d["symbasis_mean_seconds"], d["symbasis_std_seconds"])) | ",
            "$(fmt_stat(d["xdiag_mean_seconds"], d["xdiag_std_seconds"])) | ",
            "$(fmt_stat(qs_mean, qs_std)) | ",
            "$(speedup(d["symbasis_mean_seconds"], d["xdiag_mean_seconds"])) | ",
            "$(speedup(d["symbasis_mean_seconds"], qs_mean)) |",
        )
    end
    println(io)
end

function representative_table(io, name::AbstractString, label::AbstractString)
    sym = read_csv(joinpath(RESULTS, "$(name)_representative.csv"))
    sym === nothing && return
    sym_header, sym_rows = sym

    qs = read_csv(joinpath(RESULTS, "$(name)_representative_quspin.csv"))
    qs_by_N = Dict{String,Tuple{String,String}}()
    if qs !== nothing
        qs_header, qs_rows = qs
        for r in qs_rows
            d = row_dict(qs_header, r)
            qs_by_N[d["N"]] = (d["quspin_mean_seconds_per_call"], d["quspin_std_seconds_per_call"])
        end
    end

    println(io, "### $label — representative lookup (seconds/call, amortized over batch)")
    println(io)
    println(io, "| N | config | nsamples | SymBasis | XDiag | QuSpin |")
    println(io, "|---|---|---|---|---|---|")
    for r in sym_rows
        d = row_dict(sym_header, r)
        qs_mean, qs_std = get(qs_by_N, d["N"], ("NA", "NA"))
        println(
            io,
            "| $(d["N"]) | $(d["config"]) | $(d["nsamples"]) | ",
            "$(fmt_stat(d["symbasis_mean_seconds_per_call"], d["symbasis_std_seconds_per_call"])) | ",
            "N/A (no decoupled API) | $(fmt_stat(qs_mean, qs_std)) |",
        )
    end
    println(io)
end

function main()
    mkpath(dirname(DOCS_PAGE))
    open(DOCS_PAGE, "w") do io
        println(io, "# Benchmarks")
        println(io)
        println(
            io,
            "Symmetry-resolved basis construction and representative-state lookup speed, ",
            "compared against [XDiag.jl](https://github.com/awietek/XDiag.jl) and ",
            "[QuSpin](https://quspin.github.io/QuSpin/). SymBasis is benchmarked against its ",
            "own dev checkout; XDiag.jl and QuSpin are whatever their latest released ",
            "versions were at the time this page was generated. Regenerated automatically on ",
            "every SymBasis release.",
        )
        println(io)
        println(
            io,
            "Threads are left at each library's own defaults (`JULIA_NUM_THREADS=auto`, ",
            "`OMP_NUM_THREADS` unset) rather than pinned to 1 -- these numbers reflect ",
            "out-of-the-box performance, not a strictly single-threaded comparison.",
        )
        println(io)
        println(io, "Sweep: `BENCH_SWEEP=$(get(ENV, "BENCH_SWEEP", "quick"))`")
        println(io)
        # Shared setup for every `@example benchmarks` block below -- Documenter evaluates all
        # blocks sharing a session name in one persistent module, so this only needs to run
        # once per page build.
        println(io, "```@example benchmarks")
        println(io, "using CairoMakie # hide")
        println(io, "CairoMakie.activate!(type = \"svg\") # hide")
        println(io, "include(joinpath(@__DIR__, \"..\", \"..\", \"benchmark\", \"plotting.jl\")) # hide")
        println(io, "nothing # hide")
        println(io, "```")
        println(io)
        for (name, label) in
            (("spin", "Spin-1/2"), ("fermion", "Spinless fermion"), ("boson", "Boson (d=3)"))
            construction_table(io, name, label)
            representative_table(io, name, label)
        end
    end
    print(read(DOCS_PAGE, String))
    return DOCS_PAGE
end

main()
