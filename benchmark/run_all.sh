#!/usr/bin/env bash
# Orchestrates the full SymBasis vs XDiag.jl vs QuSpin basis-construction benchmark.
#
# Usage:
#   BENCH_SWEEP=quick|large ./run_all.sh
#
# Assumes `python` on PATH is a Python environment with QuSpin installed (locally: activate
# your conda/venv env first, e.g. `conda activate quspin_env`; in CI: `pip install quspin`
# before this script runs -- QuSpin isn't on conda-forge, but ships manylinux wheels on PyPI).
#
# The primary comparison pins JULIA_NUM_THREADS=1 and OMP_NUM_THREADS=1 so SymBasis's
# internally multithreaded `basis()` is compared on equal footing with QuSpin's/XDiag's
# effectively single-threaded 1D basis construction. Re-run afterwards with a higher
# JULIA_NUM_THREADS (e.g. `JULIA_NUM_THREADS=4 julia --project=benchmark benchmark/spin_basis.jl`)
# to see SymBasis's multithreaded scaling -- those numbers are not folded into the docs page.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export JULIA_NUM_THREADS=1
export OMP_NUM_THREADS=1

echo "== BENCH_SWEEP=${BENCH_SWEEP:-quick} =="

echo "-- SymBasis + XDiag.jl (spin) --"
julia --project="$HERE" "$HERE/spin_basis.jl"

echo "-- SymBasis + XDiag.jl (spinless fermion) --"
julia --project="$HERE" "$HERE/fermion_basis.jl"

echo "-- SymBasis + XDiag.jl (boson) --"
julia --project="$HERE" "$HERE/boson_basis.jl"

echo "-- QuSpin (spin, fermion, boson) --"
if command -v python >/dev/null 2>&1 && python -c "import quspin" >/dev/null 2>&1; then
    python "$HERE/quspin_bench.py"
else
    echo "quspin not importable from the active python -- skipping QuSpin benchmarks" >&2
fi

echo "-- Plotting results --"
julia --project="$HERE" "$HERE/plot_results.jl"

echo "-- Aggregating results --"
julia --project="$HERE" "$HERE/compare_results.jl"

echo "Done. See $HERE/../docs/src/benchmarks.md"
