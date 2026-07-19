# Plot construction-time vs N (U1+T+P config, the richest symmetry sector) for each basis
# type, one SVG per basis type, written into docs/src/assets/benchmarks/ for embedding in the
# "Benchmarks" docs page. Run this before compare_results.jl so the page can link the images.
#
# Run with: julia --project=benchmark benchmark/plot_results.jl

using CairoMakie

const RESULTS = joinpath(@__DIR__, "results")
const ASSETS_DIR = joinpath(@__DIR__, "..", "docs", "src", "assets", "benchmarks")
const CONFIG = "U1+T(k=0)+P(p=1)"

function read_csv(path::AbstractString)
    isfile(path) || return nothing
    lines = filter(!isempty, readlines(path))
    header = String.(split(lines[1], ","))
    rows = [String.(split(l, ",")) for l in lines[2:end]]
    return header, rows
end

row_dict(header, row) = Dict(header[i] => row[i] for i in eachindex(header))

function series_for(
    path::AbstractString, mean_col::AbstractString, std_col::AbstractString
)
    data = read_csv(path)
    data === nothing && return nothing
    header, rows = data
    mean_col in header || return nothing

    Ns = Float64[]
    means = Float64[]
    stds = Float64[]
    for r in rows
        d = row_dict(header, r)
        d["config"] == CONFIG || continue
        mval = d[mean_col]
        mval == "NA" && continue
        push!(Ns, parse(Float64, d["N"]))
        push!(means, parse(Float64, mval))
        sval = get(d, std_col, "NA")
        push!(stds, sval == "NA" ? 0.0 : parse(Float64, sval))
    end
    isempty(Ns) && return nothing

    order = sortperm(Ns)
    return Ns[order], means[order], stds[order]
end

function plot_basis_type(name::AbstractString, label::AbstractString)
    sym_path = joinpath(RESULTS, "$(name)_construction.csv")
    series = (
        (series_for(sym_path, "symbasis_mean_seconds", "symbasis_std_seconds"), "SymBasis", :dodgerblue),
        (series_for(sym_path, "xdiag_mean_seconds", "xdiag_std_seconds"), "XDiag.jl", :orangered),
        (
            series_for(
                joinpath(RESULTS, "$(name)_construction_quspin.csv"),
                "quspin_mean_seconds", "quspin_std_seconds",
            ),
            "QuSpin", :seagreen,
        ),
    )
    any(!isnothing(s[1]) for s in series) || return nothing

    fig = Figure(size=(600, 400))
    ax = Axis(
        fig[1, 1];
        xlabel="N",
        ylabel="construction time (s)",
        yscale=log10,
        title="$label basis construction ($CONFIG)",
    )
    for (data, lbl, color) in series
        data === nothing && continue
        Ns, means, stds = data
        errorbars!(ax, Ns, means, stds; color=color, whiskerwidth=6)
        scatterlines!(ax, Ns, means; label=lbl, color=color, marker=:circle)
    end
    axislegend(ax; position=:lt)

    mkpath(ASSETS_DIR)
    outpath = joinpath(ASSETS_DIR, "$(name)_construction.svg")
    save(outpath, fig)
    println("wrote $outpath")
    return outpath
end

function main()
    for (name, label) in
        (("spin", "Spin-1/2"), ("fermion", "Spinless fermion"), ("boson", "Boson (d=3)"))
        plot_basis_type(name, label)
    end
end

main()
