using Documenter
using SymBasis

const REPOLINK = "https://github.com/cevenkadir/SymBasis.jl"
const CANONICAL = "https://cevenkadir.github.io/SymBasis.jl/"

@info "Generating Documenter.jl site"
makedocs(;
    modules=[SymBasis],
    authors="Kadir Çeven",
    repo=Remotes.GitHub("cevenkadir", "SymBasis.jl"),
    sitename="SymBasis.jl",
    format=Documenter.HTML(
        prettyurls=get(ENV, "CI", nothing) == "true",
        repolink=REPOLINK,
        canonical=CANONICAL,
    ),
    pages=[
        "Home" => "index.md",
        "Manual" => [
            "Getting started" => "manual/getting_started.md",
            "Defining DoF-object(s)" => "manual/defining_dof_objects.md",
            "Defining symmetry group(s)" => "manual/defining_sym_groups.md",
            "Basis construction" => "manual/basis_construction.md",
            "Determining representative states" => "manual/representative_states.md",
        ],
        "Examples" => [
            "Quantum mechanical spins" => "examples/spins.md",
        ],
        "API Reference" => [
            "DigitBase" => "api/digitbase.md",
            "DoFObjects" => "api/dofobjects.md",
            "Miscs" => "api/miscs.md",
            "SymGroups" => "api/symgroups.md",
            "Bases" => "api/bases.md",
        ],
    ]
)

# Deploy to GitHub Pages
@info "Deploying to GitHub"
deploydocs(
    repo="github.com/cevenkadir/SymBasis.jl.git",
    push_preview=true,
)
