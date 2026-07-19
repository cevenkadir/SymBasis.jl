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
| 8 | U1 | 70 | 3.056e-05 ± 4e-05 s | 4.391e-06 ± 7.3e-06 s | 3.993e-05 ± 1.3e-05 s | 0.14x | 1.31x |
| 8 | U1+T(k=0) | 10 | 4.498e-05 ± 2.1e-05 s | 5.26e-05 ± 3.1e-05 s | 4.798e-05 ± 1.1e-05 s | 1.17x | 1.07x |
| 8 | U1+T(k=0)+P(p=1) | 8 | 6.081e-05 ± 3.5e-05 s | 0.0001244 ± 2.8e-05 s | 4.909e-05 ± 1e-05 s | 2.05x | 0.81x |
| 10 | U1 | 252 | 4.599e-05 ± 4.3e-05 s | 5.472e-06 ± 7.6e-06 s | 3.406e-05 ± 7.6e-06 s | 0.12x | 0.74x |
| 10 | U1+T(k=0) | 26 | 6.093e-05 ± 3.7e-05 s | 0.0001028 ± 3.7e-05 s | 5.47e-05 ± 1e-05 s | 1.69x | 0.90x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 0.000266 ± 0.00032 s | 0.0002258 ± 2.6e-05 s | 6.488e-05 ± 9.7e-06 s | 0.85x | 0.24x |
| 12 | U1 | 924 | 0.0001906 ± 5.3e-05 s | 5.303e-06 ± 7.4e-06 s | 4.523e-05 ± 9.7e-06 s | 0.03x | 0.24x |
| 12 | U1+T(k=0) | 80 | 0.0003815 ± 0.00064 s | 0.0002657 ± 3.6e-05 s | 9.111e-05 ± 1.1e-05 s | 0.70x | 0.24x |
| 12 | U1+T(k=0)+P(p=1) | 50 | 0.0001409 ± 2.8e-05 s | 0.0004926 ± 2.2e-05 s | 0.0001192 ± 1.1e-05 s | 3.50x | 0.85x |
| 14 | U1 | 3432 | 0.0003852 ± 0.00022 s | 5.664e-06 ± 7.2e-06 s | 6.342e-05 ± 7.1e-06 s | 0.01x | 0.16x |
| 14 | U1+T(k=0) | 246 | 0.0001875 ± 4e-05 s | 0.0009194 ± 3.3e-05 s | 0.0002306 ± 1.6e-05 s | 4.90x | 1.23x |
| 14 | U1+T(k=0)+P(p=1) | 133 | 0.000352 ± 0.00014 s | 0.001307 ± 5.9e-05 s | 0.0003331 ± 1.3e-05 s | 3.71x | 0.95x |
| 16 | U1 | 12870 | 0.0006407 ± 0.00065 s | 7.353e-06 ± 9.9e-06 s | 0.0001509 ± 1.5e-05 s | 0.01x | 0.24x |
| 16 | U1+T(k=0) | 810 | 0.0005159 ± 0.0001 s | 0.003628 ± 6e-05 s | 0.0007384 ± 1.4e-05 s | 7.03x | 1.43x |
| 16 | U1+T(k=0)+P(p=1) | 440 | 0.0009887 ± 0.00018 s | 0.004727 ± 0.001 s | 0.001132 ± 2.2e-05 s | 4.78x | 1.15x |

### Spin-1/2 — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 2.885e-07 ± 9.1e-09 s | N/A (no decoupled API) | 3.153e-07 ± 3e-07 s |

### Spinless fermion — basis construction

```@example benchmarks
plot_construction("fermion", "Spinless fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 8 | U1 | 70 | 4.233e-05 ± 4.6e-05 s | 4.902e-06 ± 7.4e-06 s | 4.749e-05 ± 1.1e-05 s | 0.12x | 1.12x |
| 8 | U1+T(k=0) | 9 | 4.892e-05 ± 2.3e-05 s | 5.777e-05 ± 3.7e-05 s | 6.094e-05 ± 9.3e-06 s | 1.18x | 1.25x |
| 8 | U1+T(k=0)+P(p=1) | 6 | 0.0001019 ± 6.8e-05 s | 0.000129 ± 3.2e-05 s | 6.852e-05 ± 9.5e-06 s | 1.27x | 0.67x |
| 10 | U1 | 252 | 4.306e-05 ± 3.8e-05 s | 4.746e-06 ± 6.9e-06 s | 4.96e-05 ± 8.2e-06 s | 0.11x | 1.15x |
| 10 | U1+T(k=0) | 26 | 7.537e-05 ± 3.5e-05 s | 0.0001091 ± 3e-05 s | 7.624e-05 ± 9e-06 s | 1.45x | 1.01x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 0.0002735 ± 0.00042 s | 0.0002332 ± 2.8e-05 s | 9.353e-05 ± 8.9e-06 s | 0.85x | 0.34x |
| 12 | U1 | 924 | 5.975e-05 ± 3.9e-05 s | 5.376e-06 ± 7.4e-06 s | 6.395e-05 ± 1.3e-05 s | 0.09x | 1.07x |
| 12 | U1+T(k=0) | 76 | 0.0001321 ± 3.7e-05 s | 0.0002996 ± 2.8e-05 s | 0.0001115 ± 3.1e-05 s | 2.27x | 0.84x |
| 12 | U1+T(k=0)+P(p=1) | 33 | 0.0003461 ± 0.00013 s | 0.0005129 ± 2.3e-05 s | 0.0001194 ± 1.2e-05 s | 1.48x | 0.34x |
| 14 | U1 | 3432 | 0.0002781 ± 0.00023 s | 8.401e-06 ± 1.5e-05 s | 6.777e-05 ± 1.3e-05 s | 0.03x | 0.24x |
| 14 | U1+T(k=0) | 246 | 0.0003976 ± 5.2e-05 s | 0.001026 ± 3.4e-05 s | 0.0002244 ± 1.5e-05 s | 2.58x | 0.56x |
| 14 | U1+T(k=0)+P(p=1) | 113 | 0.0007945 ± 4.8e-05 s | 0.001428 ± 5.4e-05 s | 0.0003264 ± 1.6e-05 s | 1.80x | 0.41x |
| 16 | U1 | 12870 | 0.000463 ± 0.00022 s | 1.024e-05 ± 1.8e-05 s | 0.0001489 ± 1.1e-05 s | 0.02x | 0.32x |
| 16 | U1+T(k=0) | 809 | 0.001366 ± 0.0002 s | 0.004207 ± 0.00011 s | 0.0007402 ± 1.2e-05 s | 3.08x | 0.54x |
| 16 | U1+T(k=0)+P(p=1) | 422 | 0.003086 ± 0.00029 s | 0.005042 ± 8.6e-05 s | 0.001125 ± 1.2e-05 s | 1.63x | 0.36x |

### Spinless fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 1.819e-06 ± 2.5e-09 s | N/A (no decoupled API) | 1.891e-06 ± 7.7e-08 s |

### Boson (d=3) — basis construction

```@example benchmarks
plot_construction("boson", "Boson (d=3)")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 6 | U1 | 141 | 0.0002003 ± 0.00035 s | 5.281e-06 ± 7.1e-06 s | 5.786e-05 ± 1.3e-05 s | 0.03x | 0.29x |
| 6 | U1+T(k=0) | 26 | 0.0001208 ± 3.3e-05 s | 6.028e-05 ± 3.2e-05 s | 8.13e-05 ± 1.2e-05 s | 0.50x | 0.67x |
| 6 | U1+T(k=0)+P(p=1) | 18 | 0.0001878 ± 3.8e-05 s | 0.0001099 ± 3e-05 s | 9.342e-05 ± 1.1e-05 s | 0.59x | 0.50x |
| 8 | U1 | 1107 | 0.0002735 ± 0.00018 s | 6.501e-06 ± 6.9e-06 s | 0.0001009 ± 1.5e-05 s | 0.02x | 0.37x |
| 8 | U1+T(k=0) | 142 | 0.0005539 ± 0.00011 s | 0.0002572 ± 3.6e-05 s | 0.0002317 ± 1.1e-05 s | 0.46x | 0.42x |
| 8 | U1+T(k=0)+P(p=1) | 84 | 0.001019 ± 0.00035 s | 0.0003875 ± 3.9e-05 s | 0.0002251 ± 1.3e-05 s | 0.38x | 0.22x |
| 10 | U1 | 8953 | 0.001754 ± 0.00075 s | 1.166e-05 ± 9.3e-06 s | 0.0002932 ± 9.4e-06 s | 0.01x | 0.17x |
| 10 | U1+T(k=0) | 902 | 0.004393 ± 0.0003 s | 0.001961 ± 6.2e-05 s | 0.001504 ± 1.2e-05 s | 0.45x | 0.34x |
| 10 | U1+T(k=0)+P(p=1) | 486 | 0.007435 ± 0.00035 s | 0.002512 ± 9.5e-05 s | 0.001812 ± 2e-05 s | 0.34x | 0.24x |
| 12 | U1 | 73789 | 0.01072 ± 0.00062 s | 3.149e-05 ± 1.2e-05 s | 0.002125 ± 3e-05 s | 0.00x | 0.20x |
| 12 | U1+T(k=0) | 6166 | 0.04952 ± 0.0019 s | 0.0183 ± 0.00016 s | 0.01413 ± 7.2e-05 s | 0.37x | 0.29x |
| 12 | U1+T(k=0)+P(p=1) | 3179 | 0.07914 ± 0.0027 s | 0.02175 ± 0.00015 s | 0.01707 ± 7.2e-05 s | 0.27x | 0.22x |

### Boson (d=3) — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 6.862e-06 ± 2.6e-08 s | N/A (no decoupled API) | 3.17e-07 ± 5.9e-10 s |

