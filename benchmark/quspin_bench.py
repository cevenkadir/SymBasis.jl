"""
Compare QuSpin vs SymBasis/XDiag.jl: spin-1/2, spinless-fermion, and boson chains,
symmetry-resolved basis construction and representative-state lookup. Reports mean +/- std
timing over multiple samples.

Run with whatever python is active on PATH (a conda env with quspin installed, activated
beforehand -- either locally via `conda activate quspin_env`, or in CI via
conda-incubator/setup-miniconda):
    python benchmark/quspin_bench.py

Sweep size selectable via: BENCH_SWEEP=quick|large (default quick)
"""

import csv
import os
import statistics
import timeit

import numpy as np
from quspin.basis import (
    spin_basis_1d,
    spinless_fermion_basis_1d,
    boson_basis_1d,
    spin_basis_general,
    spinless_fermion_basis_general,
    boson_basis_general,
)

HERE = os.path.dirname(os.path.abspath(__file__))
RESULTS_DIR = os.path.join(HERE, "results")
os.makedirs(RESULTS_DIR, exist_ok=True)

MAX_OCCUPANCY = 2
D = MAX_OCCUPANCY + 1  # local dimension for the boson chain, matches the Julia scripts

CONFIGS = ("u1", "u1_t", "u1_t_p")
CONFIG_LABELS = {"u1": "U1", "u1_t": "U1+T(k=0)", "u1_t_p": "U1+T(k=0)+P(p=1)"}


def sweep_sizes(kind):
    sweep = os.environ.get("BENCH_SWEEP", "quick")
    if kind == "spin_fermion":
        return (16, 18, 20, 22, 24) if sweep == "large" else (8, 10, 12, 14, 16)
    elif kind == "boson":
        return (10, 12, 14) if sweep == "large" else (6, 8, 10, 12)
    raise ValueError(f"unknown sweep kind {kind}")


def benchmark_stats(f, samples=10):
    """One untimed warmup call, then `samples` single-call timings via `timeit.repeat`
    (`number=1`, matching the `evals=1` semantics used on the Julia/BenchmarkTools side).
    Returns `(result, mean_seconds, std_seconds)`.
    """
    result = f()
    times = timeit.repeat(f, repeat=samples, number=1)
    return result, statistics.mean(times), statistics.stdev(times)


def write_csv(path, header, rows):
    with open(path, "w", newline="") as fh:
        writer = csv.writer(fh)
        writer.writerow(header)
        writer.writerows(rows)
    return path


def blocks_1d(config):
    if config == "u1":
        return {}
    elif config == "u1_t":
        return dict(kblock=0)
    else:
        return dict(kblock=0, pblock=1)


def blocks_general(N, config):
    if config == "u1":
        return {}
    T = (np.arange(N) + 1) % N
    if config == "u1_t":
        return dict(kblock=(T, 0))
    P = np.arange(N)[::-1]
    return dict(kblock=(T, 0), pblock=(P, 1))


def bench_spin():
    Ns = sweep_sizes("spin_fermion")
    rows = []
    last_N = None
    for N in Ns:
        for config in CONFIGS:
            nup = N // 2
            basis, mean_t, std_t = benchmark_stats(
                lambda: spin_basis_1d(N, Nup=nup, **blocks_1d(config))
            )
            print(f"spin N={N} {CONFIG_LABELS[config]}: dim={basis.Ns}  QuSpin={mean_t}±{std_t}s")
            rows.append((N, CONFIG_LABELS[config], basis.Ns, mean_t, std_t))
            if config == "u1_t_p":
                last_N = N
    write_csv(
        os.path.join(RESULTS_DIR, "spin_construction_quspin.csv"),
        ["N", "config", "dim", "quspin_mean_seconds", "quspin_std_seconds"],
        rows,
    )
    representative_bench("spin", spin_basis_general, dict(Nup=last_N // 2), last_N)


def bench_fermion():
    Ns = sweep_sizes("spin_fermion")
    rows = []
    last_N = None
    for N in Ns:
        for config in CONFIGS:
            nf = N // 2
            basis, mean_t, std_t = benchmark_stats(
                lambda: spinless_fermion_basis_1d(N, Nf=nf, **blocks_1d(config))
            )
            print(f"fermion N={N} {CONFIG_LABELS[config]}: dim={basis.Ns}  QuSpin={mean_t}±{std_t}s")
            rows.append((N, CONFIG_LABELS[config], basis.Ns, mean_t, std_t))
            if config == "u1_t_p":
                last_N = N
    write_csv(
        os.path.join(RESULTS_DIR, "fermion_construction_quspin.csv"),
        ["N", "config", "dim", "quspin_mean_seconds", "quspin_std_seconds"],
        rows,
    )
    representative_bench(
        "fermion", spinless_fermion_basis_general, dict(Nf=last_N // 2), last_N
    )


def bench_boson():
    Ns = sweep_sizes("boson")
    rows = []
    last_N = None
    for N in Ns:
        for config in CONFIGS:
            nb = N  # average filling of 1 boson/site, matches the Julia boson script
            basis, mean_t, std_t = benchmark_stats(
                lambda: boson_basis_1d(N, Nb=nb, sps=D, **blocks_1d(config))
            )
            print(f"boson N={N} {CONFIG_LABELS[config]}: dim={basis.Ns}  QuSpin={mean_t}±{std_t}s")
            rows.append((N, CONFIG_LABELS[config], basis.Ns, mean_t, std_t))
            if config == "u1_t_p":
                last_N = N
    write_csv(
        os.path.join(RESULTS_DIR, "boson_construction_quspin.csv"),
        ["N", "config", "dim", "quspin_mean_seconds", "quspin_std_seconds"],
        rows,
    )
    representative_bench(
        "boson", boson_basis_general, dict(Nb=last_N, sps=D), last_N, local_dim=D
    )


def representative_bench(name, general_cls, pcon_kwargs, N, local_dim=2, nsamples=10_000):
    gen_basis = general_cls(N, make_basis=False, **pcon_kwargs, **blocks_general(N, "u1_t_p"))
    rng = np.random.default_rng(0)
    states = rng.integers(0, local_dim**N, size=nsamples, dtype=np.int64)

    _, batch_mean, batch_std = benchmark_stats(lambda: gen_basis.representative(states))
    mean_per_call = batch_mean / nsamples
    std_per_call = batch_std / nsamples

    print(
        f"{name} representative lookup (N={N}, U1+T+P, {nsamples} samples): "
        f"QuSpin={mean_per_call}±{std_per_call}s/call"
    )
    write_csv(
        os.path.join(RESULTS_DIR, f"{name}_representative_quspin.csv"),
        ["N", "config", "nsamples", "quspin_mean_seconds_per_call", "quspin_std_seconds_per_call"],
        [(N, CONFIG_LABELS["u1_t_p"], nsamples, mean_per_call, std_per_call)],
    )


if __name__ == "__main__":
    bench_spin()
    bench_fermion()
    bench_boson()
