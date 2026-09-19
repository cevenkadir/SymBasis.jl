# Benchmarks

Symmetry-resolved basis construction and representative-state lookup speed, compared against [XDiag.jl](https://github.com/awietek/XDiag.jl) and [QuSpin](https://quspin.github.io/QuSpin/). SymBasis is benchmarked against its own dev checkout; XDiag.jl and QuSpin are whatever their latest released versions were at the time this page was generated. Regenerated automatically on every SymBasis release.

Threads are left at each library's own defaults (`JULIA_NUM_THREADS=auto`, `OMP_NUM_THREADS` unset) rather than pinned to 1 -- these numbers reflect out-of-the-box performance, not a strictly single-threaded comparison.

Sweep: `BENCH_SWEEP=quick`

```@example benchmarks
using CairoMakie # hide
CairoMakie.activate!(type = "svg") # hide
include(joinpath(@__DIR__, "..", "..", "benchmark", "plotting.jl")) # hide
nothing # hide
```

### Spin-1/2 — basis construction

```@example benchmarks
plot_construction("spin", "Spin-1/2")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 8 | U1 | 70 | 6.888e-06 ± 7.4e-06 s | 4.089e-06 ± 6.8e-06 s | 3.719e-05 ± 1.6e-05 s | 0.59x | 5.40x |
| 8 | U1+T(k=0) | 10 | 1.169e-05 ± 1.1e-05 s | 0.0001074 ± 0.0002 s | 4.72e-05 ± 1.8e-05 s | 9.19x | 4.04x |
| 8 | U1+T(k=0)+P(p=1) | 8 | 0.0001118 ± 8.2e-05 s | 0.0001286 ± 2.8e-05 s | 5.504e-05 ± 1.5e-05 s | 1.15x | 0.49x |
| 10 | U1 | 252 | 1.153e-05 ± 1.3e-05 s | 4.281e-06 ± 6.6e-06 s | 3.449e-05 ± 7.7e-06 s | 0.37x | 2.99x |
| 10 | U1+T(k=0) | 26 | 0.0002552 ± 0.00054 s | 0.0001015 ± 2.9e-05 s | 5.159e-05 ± 8.7e-06 s | 0.40x | 0.20x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 0.0001425 ± 0.00011 s | 0.0002565 ± 0.00012 s | 6.353e-05 ± 1.2e-05 s | 1.80x | 0.45x |
| 12 | U1 | 924 | 2.542e-05 ± 1.9e-05 s | 4.608e-06 ± 6.3e-06 s | 4.293e-05 ± 8.5e-06 s | 0.18x | 1.69x |
| 12 | U1+T(k=0) | 80 | 0.0005367 ± 0.00083 s | 0.00028 ± 2.2e-05 s | 8.949e-05 ± 1.3e-05 s | 0.52x | 0.17x |
| 12 | U1+T(k=0)+P(p=1) | 50 | 0.0003412 ± 0.00049 s | 0.0008311 ± 0.0011 s | 0.0001258 ± 1.2e-05 s | 2.44x | 0.37x |
| 14 | U1 | 3432 | 0.0003442 ± 0.00042 s | 4.911e-06 ± 6.1e-06 s | 7.392e-05 ± 1.4e-05 s | 0.01x | 0.21x |
| 14 | U1+T(k=0) | 246 | 0.0007715 ± 0.001 s | 0.0009983 ± 1.8e-05 s | 0.0002314 ± 2.3e-05 s | 1.29x | 0.30x |
| 14 | U1+T(k=0)+P(p=1) | 133 | 0.0005191 ± 0.00052 s | 0.001408 ± 2.6e-05 s | 0.0003308 ± 1.8e-05 s | 2.71x | 0.64x |
| 16 | U1 | 12870 | 0.000532 ± 0.00024 s | 6.483e-06 ± 7.6e-06 s | 0.0001514 ± 1.1e-05 s | 0.01x | 0.28x |
| 16 | U1+T(k=0) | 810 | 0.0004809 ± 6.3e-05 s | 0.004012 ± 1.8e-05 s | 0.0007397 ± 2.3e-05 s | 8.34x | 1.54x |
| 16 | U1+T(k=0)+P(p=1) | 440 | 0.001179 ± 0.0008 s | 0.005093 ± 0.00055 s | 0.001133 ± 2e-05 s | 4.32x | 0.96x |

### Spin-1/2 — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 3.104e-07 ± 8.5e-10 s | N/A (no decoupled API) | 1.79e-07 ± 1.7e-09 s |

### Spinless fermion — basis construction

```@example benchmarks
plot_construction("fermion", "Spinless fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 8 | U1 | 70 | 7.168e-06 ± 8.4e-06 s | 4.538e-06 ± 7.1e-06 s | 5.189e-05 ± 1.3e-05 s | 0.63x | 7.24x |
| 8 | U1+T(k=0) | 9 | 1.224e-05 ± 1.2e-05 s | 0.0001006 ± 0.00018 s | 6.439e-05 ± 1e-05 s | 8.22x | 5.26x |
| 8 | U1+T(k=0)+P(p=1) | 6 | 0.0002504 ± 0.00037 s | 0.0001259 ± 2.6e-05 s | 7.31e-05 ± 1.1e-05 s | 0.50x | 0.29x |
| 10 | U1 | 252 | 1.029e-05 ± 9.9e-06 s | 4.25e-06 ± 6.3e-06 s | 5.303e-05 ± 1e-05 s | 0.41x | 5.15x |
| 10 | U1+T(k=0) | 26 | 4.219e-05 ± 2.8e-05 s | 0.0001077 ± 2.5e-05 s | 7.838e-05 ± 1.1e-05 s | 2.55x | 1.86x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 0.0001414 ± 0.00015 s | 0.0002395 ± 2.1e-05 s | 9.251e-05 ± 1.3e-05 s | 1.69x | 0.65x |
| 12 | U1 | 924 | 2.129e-05 ± 9.4e-06 s | 4.71e-06 ± 5.9e-06 s | 5.952e-05 ± 9.7e-06 s | 0.22x | 2.80x |
| 12 | U1+T(k=0) | 76 | 0.0001283 ± 6.2e-05 s | 0.0003099 ± 3.7e-05 s | 0.0001144 ± 2.3e-05 s | 2.41x | 0.89x |
| 12 | U1+T(k=0)+P(p=1) | 33 | 0.0001012 ± 3.6e-05 s | 0.0005237 ± 2.3e-05 s | 0.0001208 ± 1.5e-05 s | 5.18x | 1.19x |
| 14 | U1 | 3432 | 0.0001316 ± 4.5e-05 s | 5.262e-06 ± 6.2e-06 s | 6.37e-05 ± 8.1e-06 s | 0.04x | 0.48x |
| 14 | U1+T(k=0) | 246 | 0.0005224 ± 0.00083 s | 0.001101 ± 3.1e-05 s | 0.0002216 ± 1.2e-05 s | 2.11x | 0.42x |
| 14 | U1+T(k=0)+P(p=1) | 113 | 0.0002604 ± 4.8e-05 s | 0.0015 ± 6.2e-05 s | 0.0003233 ± 9.7e-06 s | 5.76x | 1.24x |
| 16 | U1 | 12870 | 0.0005847 ± 0.00037 s | 6.812e-06 ± 8.2e-06 s | 0.0001502 ± 1.4e-05 s | 0.01x | 0.26x |
| 16 | U1+T(k=0) | 809 | 0.0004349 ± 4.9e-05 s | 0.004473 ± 0.00012 s | 0.0007303 ± 1.2e-05 s | 10.29x | 1.68x |
| 16 | U1+T(k=0)+P(p=1) | 422 | 0.0007882 ± 7.3e-05 s | 0.005474 ± 0.00016 s | 0.001119 ± 9.2e-06 s | 6.95x | 1.42x |

### Spinless fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 3.706e-07 ± 1.6e-09 s | N/A (no decoupled API) | 1.903e-06 ± 8.4e-08 s |

### Spinful fermion — basis construction

```@example benchmarks
plot_construction("spinful_fermion", "Spinful fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 4 | U1 | 36 | 7.997e-06 ± 8.9e-06 s | 5.543e-06 ± 8.5e-06 s | 6.217e-05 ± 1.2e-05 s | 0.69x | 7.77x |
| 4 | U1+T(k=0) | 10 | 1.182e-05 ± 1.2e-05 s | 0.0003461 ± 0.001 s | 7.335e-05 ± 1.1e-05 s | 29.27x | 6.21x |
| 4 | U1+T(k=0)+P(p=1) | 6 | 1.421e-05 ± 1.4e-05 s | 6.346e-05 ± 4.6e-05 s | 8.603e-05 ± 1.2e-05 s | 4.46x | 6.05x |
| 6 | U1 | 400 | 1.951e-05 ± 1.2e-05 s | 4.899e-06 ± 8.4e-06 s | 7.315e-05 ± 1.2e-05 s | 0.25x | 3.75x |
| 6 | U1+T(k=0) | 68 | 0.0004623 ± 0.00079 s | 5.379e-05 ± 3.1e-05 s | 0.0001358 ± 1.7e-05 s | 0.12x | 0.29x |
| 6 | U1+T(k=0)+P(p=1) | 38 | 0.0002914 ± 0.00011 s | 0.000109 ± 3.5e-05 s | 0.0001762 ± 3.8e-05 s | 0.37x | 0.60x |
| 8 | U1 | 4900 | 0.0006519 ± 0.00054 s | 5.325e-06 ± 8.8e-06 s | 0.0001291 ± 2e-05 s | 0.01x | 0.20x |
| 8 | U1+T(k=0) | 618 | 0.0005705 ± 0.00026 s | 0.0001218 ± 3.1e-05 s | 0.0005289 ± 1.6e-05 s | 0.21x | 0.93x |
| 8 | U1+T(k=0)+P(p=1) | 318 | 0.000881 ± 0.0004 s | 0.0003168 ± 0.00015 s | 0.0009199 ± 1.6e-05 s | 0.36x | 1.04x |
| 10 | U1 | 63504 | 0.002896 ± 0.00054 s | 5.976e-06 ± 9.5e-06 s | 0.001066 ± 3.9e-05 s | 0.00x | 0.37x |
| 10 | U1+T(k=0) | 6352 | 0.00473 ± 0.00064 s | 0.0003894 ± 3.4e-05 s | 0.006466 ± 2.5e-05 s | 0.08x | 1.37x |
| 10 | U1+T(k=0)+P(p=1) | 3212 | 0.007073 ± 0.00044 s | 0.001035 ± 0.0005 s | 0.01148 ± 4.4e-05 s | 0.15x | 1.62x |
| 12 | U1 | 853776 | 0.02252 ± 0.0072 s | 6.424e-06 ± 9e-06 s | 0.01469 ± 0.00021 s | 0.00x | 0.65x |
| 12 | U1+T(k=0) | 71188 | 0.05566 ± 0.0062 s | 0.002044 ± 7e-05 s | 0.08983 ± 0.00022 s | 0.04x | 1.61x |
| 12 | U1+T(k=0)+P(p=1) | 35694 | 0.09662 ± 0.0088 s | 0.005117 ± 9.7e-05 s | 0.1591 ± 0.0015 s | 0.05x | 1.65x |

### Spinful fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 1.413e-06 ± 1e-08 s | N/A (no decoupled API) | 2.223e-06 ± 1e-08 s |

### Boson (d=3) — basis construction

```@example benchmarks
plot_construction("boson", "Boson (d=3)")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 6 | U1 | 141 | 1.088e-05 ± 9.6e-06 s | 4.935e-06 ± 6.9e-06 s | 6.042e-05 ± 1.4e-05 s | 0.45x | 5.55x |
| 6 | U1+T(k=0) | 26 | 2.135e-05 ± 1.4e-05 s | 0.0001434 ± 0.0003 s | 8.124e-05 ± 1.3e-05 s | 6.72x | 3.81x |
| 6 | U1+T(k=0)+P(p=1) | 18 | 0.0005807 ± 0.00074 s | 0.0001081 ± 3.1e-05 s | 8.865e-05 ± 1.1e-05 s | 0.19x | 0.15x |
| 8 | U1 | 1107 | 0.0001637 ± 0.00013 s | 6.99e-06 ± 8.1e-06 s | 9.846e-05 ± 1e-05 s | 0.04x | 0.60x |
| 8 | U1+T(k=0) | 142 | 0.0001733 ± 5e-05 s | 0.0002552 ± 2.6e-05 s | 0.0002329 ± 1.8e-05 s | 1.47x | 1.34x |
| 8 | U1+T(k=0)+P(p=1) | 84 | 0.0008602 ± 0.0012 s | 0.0003838 ± 3.1e-05 s | 0.0002271 ± 2e-05 s | 0.45x | 0.26x |
| 10 | U1 | 8953 | 0.0007656 ± 0.0009 s | 1.102e-05 ± 8.4e-06 s | 0.0002928 ± 1.1e-05 s | 0.01x | 0.38x |
| 10 | U1+T(k=0) | 902 | 0.0007943 ± 0.00026 s | 0.002017 ± 3.8e-05 s | 0.001489 ± 1.3e-05 s | 2.54x | 1.87x |
| 10 | U1+T(k=0)+P(p=1) | 486 | 0.001438 ± 0.00049 s | 0.002578 ± 4.4e-05 s | 0.001801 ± 1.1e-05 s | 1.79x | 1.25x |
| 12 | U1 | 73789 | 0.003202 ± 0.00063 s | 2.814e-05 ± 8.6e-06 s | 0.002111 ± 1.1e-05 s | 0.01x | 0.66x |
| 12 | U1+T(k=0) | 6166 | 0.006405 ± 0.00071 s | 0.01888 ± 6.5e-05 s | 0.01409 ± 1.3e-05 s | 2.95x | 2.20x |
| 12 | U1+T(k=0)+P(p=1) | 3179 | 0.00982 ± 0.00068 s | 0.0226 ± 3.9e-05 s | 0.01689 ± 1.9e-05 s | 2.30x | 1.72x |

### Boson (d=3) — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 1.713e-06 ± 5.3e-09 s | N/A (no decoupled API) | 3.165e-07 ± 6e-10 s |

