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
| 8 | U1 | 70 | 0.0001951 ± 0.00024 s | 4.914e-06 ± 7.3e-06 s | 2.249e-05 ± 1.1e-05 s | 0.03x | 0.12x |
| 8 | U1+T(k=0) | 10 | 4.151e-05 ± 3.7e-05 s | 0.00055 ± 0.0016 s | 2.827e-05 ± 7.8e-06 s | 13.25x | 0.68x |
| 8 | U1+T(k=0)+P(p=1) | 8 | 5.337e-05 ± 3e-05 s | 0.0001078 ± 4.2e-05 s | 2.852e-05 ± 6.6e-06 s | 2.02x | 0.53x |
| 10 | U1 | 252 | 3.714e-05 ± 3.9e-05 s | 5.12e-06 ± 7.6e-06 s | 1.966e-05 ± 3.4e-06 s | 0.14x | 0.53x |
| 10 | U1+T(k=0) | 26 | 5.263e-05 ± 4e-05 s | 9.552e-05 ± 3.1e-05 s | 3.428e-05 ± 6.8e-06 s | 1.81x | 0.65x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 6.51e-05 ± 2.7e-05 s | 0.0001762 ± 4.5e-05 s | 4.335e-05 ± 5e-06 s | 2.71x | 0.67x |
| 12 | U1 | 924 | 5.624e-05 ± 5e-05 s | 5.318e-06 ± 7.8e-06 s | 2.695e-05 ± 3.7e-06 s | 0.09x | 0.48x |
| 12 | U1+T(k=0) | 80 | 6.697e-05 ± 3.9e-05 s | 0.0002214 ± 2.8e-05 s | 6.977e-05 ± 1.1e-05 s | 3.31x | 1.04x |
| 12 | U1+T(k=0)+P(p=1) | 50 | 0.0001099 ± 5.5e-05 s | 0.0003732 ± 5.4e-05 s | 0.0001045 ± 6.4e-06 s | 3.40x | 0.95x |
| 14 | U1 | 3432 | 9.879e-05 ± 4.5e-05 s | 7.643e-06 ± 8.8e-06 s | 5.274e-05 ± 4.1e-06 s | 0.08x | 0.53x |
| 14 | U1+T(k=0) | 246 | 0.0001179 ± 4.7e-05 s | 0.0007574 ± 2.9e-05 s | 0.000213 ± 9.2e-06 s | 6.42x | 1.81x |
| 14 | U1+T(k=0)+P(p=1) | 133 | 0.000265 ± 0.0002 s | 0.00262 ± 0.0047 s | 0.0003254 ± 8.5e-06 s | 9.89x | 1.23x |
| 16 | U1 | 12870 | 0.0006455 ± 0.00065 s | 7.57e-06 ± 8.7e-06 s | 0.000142 ± 4.4e-06 s | 0.01x | 0.22x |
| 16 | U1+T(k=0) | 810 | 0.000496 ± 0.00042 s | 0.003001 ± 8.5e-05 s | 0.0007131 ± 2.9e-05 s | 6.05x | 1.44x |
| 16 | U1+T(k=0)+P(p=1) | 440 | 0.0006231 ± 3.7e-05 s | 0.003777 ± 8.6e-05 s | 0.001106 ± 5e-05 s | 6.06x | 1.78x |

### Spin-1/2 — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 1.124e-07 ± 1.9e-09 s | N/A (no decoupled API) | 1.853e-07 ± 1.3e-09 s |

### Spinless fermion — basis construction

```@example benchmarks
plot_construction("fermion", "Spinless fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 8 | U1 | 70 | 2.753e-05 ± 3.4e-05 s | 5.243e-06 ± 8e-06 s | 2.864e-05 ± 8.2e-06 s | 0.19x | 1.04x |
| 8 | U1+T(k=0) | 9 | 6.928e-05 ± 4.7e-05 s | 5.233e-05 ± 3.2e-05 s | 3.632e-05 ± 9.5e-06 s | 0.76x | 0.52x |
| 8 | U1+T(k=0)+P(p=1) | 6 | 5.789e-05 ± 3.1e-05 s | 0.0004888 ± 0.0012 s | 3.795e-05 ± 5e-06 s | 8.44x | 0.66x |
| 10 | U1 | 252 | 4.972e-05 ± 5e-05 s | 5.991e-06 ± 9.1e-06 s | 3.014e-05 ± 3.3e-06 s | 0.12x | 0.61x |
| 10 | U1+T(k=0) | 26 | 0.0001153 ± 0.00015 s | 9.381e-05 ± 3.1e-05 s | 5.095e-05 ± 5.7e-06 s | 0.81x | 0.44x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 0.0002075 ± 0.00019 s | 0.0001844 ± 3.9e-05 s | 5.957e-05 ± 6e-06 s | 0.89x | 0.29x |
| 12 | U1 | 924 | 0.0001368 ± 9.2e-05 s | 5.304e-06 ± 7.8e-06 s | 3.841e-05 ± 4.1e-06 s | 0.04x | 0.28x |
| 12 | U1+T(k=0) | 76 | 0.0001022 ± 5.1e-05 s | 0.0002421 ± 3.2e-05 s | 8.123e-05 ± 1.4e-05 s | 2.37x | 0.79x |
| 12 | U1+T(k=0)+P(p=1) | 33 | 0.0001922 ± 3.7e-05 s | 0.0004857 ± 0.00035 s | 0.0001031 ± 6.4e-06 s | 2.53x | 0.54x |
| 14 | U1 | 3432 | 0.0001948 ± 0.00021 s | 6.761e-06 ± 8.5e-06 s | 5.246e-05 ± 3.8e-06 s | 0.03x | 0.27x |
| 14 | U1+T(k=0) | 246 | 0.0004603 ± 0.00051 s | 0.0008843 ± 2.7e-05 s | 0.0002096 ± 5.6e-06 s | 1.92x | 0.46x |
| 14 | U1+T(k=0)+P(p=1) | 113 | 0.0009327 ± 0.0005 s | 0.001173 ± 0.00013 s | 0.0002983 ± 2.2e-05 s | 1.26x | 0.32x |
| 16 | U1 | 12870 | 0.0006018 ± 0.00056 s | 8.187e-06 ± 1e-05 s | 0.00013 ± 4e-06 s | 0.01x | 0.22x |
| 16 | U1+T(k=0) | 809 | 0.001144 ± 0.00045 s | 0.0033 ± 6.9e-05 s | 0.0006788 ± 3.5e-05 s | 2.88x | 0.59x |
| 16 | U1+T(k=0)+P(p=1) | 422 | 0.002244 ± 0.00027 s | 0.00389 ± 0.00013 s | 0.001061 ± 5e-06 s | 1.73x | 0.47x |

### Spinless fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 1.326e-06 ± 4.2e-08 s | N/A (no decoupled API) | 1.893e-06 ± 7.2e-08 s |

### Spinful fermion — basis construction

```@example benchmarks
plot_construction("spinful_fermion", "Spinful fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 4 | U1 | 36 | 0.0002466 ± 0.00058 s | 6.488e-06 ± 1.1e-05 s | 3.368e-05 ± 9.6e-06 s | 0.03x | 0.14x |
| 4 | U1+T(k=0) | 10 | 6.075e-05 ± 3e-05 s | 3.747e-05 ± 3.6e-05 s | 3.871e-05 ± 6.9e-06 s | 0.62x | 0.64x |
| 4 | U1+T(k=0)+P(p=1) | 6 | 0.0001488 ± 0.00011 s | 5.738e-05 ± 4.2e-05 s | 4.523e-05 ± 1.1e-05 s | 0.39x | 0.30x |
| 6 | U1 | 400 | 7.861e-05 ± 4.1e-05 s | 6.612e-06 ± 1.1e-05 s | 3.95e-05 ± 5.1e-06 s | 0.08x | 0.50x |
| 6 | U1+T(k=0) | 68 | 0.0001655 ± 4.1e-05 s | 5.685e-05 ± 3.6e-05 s | 7.547e-05 ± 6.2e-06 s | 0.34x | 0.46x |
| 6 | U1+T(k=0)+P(p=1) | 38 | 0.0003306 ± 0.00016 s | 9.705e-05 ± 4.6e-05 s | 0.0001053 ± 1.2e-05 s | 0.29x | 0.32x |
| 8 | U1 | 4900 | 0.0006065 ± 9.3e-05 s | 8.745e-06 ± 1.7e-05 s | 9.753e-05 ± 6.6e-06 s | 0.01x | 0.16x |
| 8 | U1+T(k=0) | 618 | 0.001662 ± 8.5e-05 s | 0.0001105 ± 4.4e-05 s | 0.000488 ± 7.2e-06 s | 0.07x | 0.29x |
| 8 | U1+T(k=0)+P(p=1) | 318 | 0.002812 ± 0.00016 s | 0.0106 ± 0.01 s | 0.0008432 ± 5e-06 s | 3.77x | 0.30x |
| 10 | U1 | 63504 | 0.007655 ± 0.00052 s | 6.472e-06 ± 1e-05 s | 0.000978 ± 4.6e-05 s | 0.00x | 0.13x |
| 10 | U1+T(k=0) | 6352 | 0.02634 ± 0.0014 s | 0.0005807 ± 0.00081 s | 0.006744 ± 0.00047 s | 0.02x | 0.26x |
| 10 | U1+T(k=0)+P(p=1) | 3212 | 0.04637 ± 0.0022 s | 0.0006674 ± 7e-05 s | 0.01111 ± 0.00037 s | 0.01x | 0.24x |
| 12 | U1 | 853776 | 0.1211 ± 0.027 s | 7.813e-06 ± 1.1e-05 s | 0.01383 ± 0.00067 s | 0.00x | 0.11x |
| 12 | U1+T(k=0) | 71188 | 0.4364 ± 0.01 s | 0.002233 ± 0.00061 s | 0.08949 ± 0.0014 s | 0.01x | 0.21x |
| 12 | U1+T(k=0)+P(p=1) | 35694 | 0.7685 ± 0.02 s | 0.004701 ± 0.0002 s | 0.1577 ± 0.0012 s | 0.01x | 0.21x |

### Spinful fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 1.211e-05 ± 6.6e-07 s | N/A (no decoupled API) | 2.267e-06 ± 4.9e-08 s |

### Boson (d=3) — basis construction

```@example benchmarks
plot_construction("boson", "Boson (d=3)")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 6 | U1 | 141 | 9.801e-05 ± 0.00013 s | 5.673e-06 ± 7.6e-06 s | 3.492e-05 ± 9.1e-06 s | 0.06x | 0.36x |
| 6 | U1+T(k=0) | 26 | 0.0001372 ± 6.9e-05 s | 8.974e-05 ± 0.00014 s | 4.896e-05 ± 6.1e-06 s | 0.65x | 0.36x |
| 6 | U1+T(k=0)+P(p=1) | 18 | 0.000183 ± 5.3e-05 s | 0.0002331 ± 0.00047 s | 5.66e-05 ± 7.5e-06 s | 1.27x | 0.31x |
| 8 | U1 | 1107 | 0.0005814 ± 0.00064 s | 7.397e-06 ± 7.2e-06 s | 6.841e-05 ± 6.9e-06 s | 0.01x | 0.12x |
| 8 | U1+T(k=0) | 142 | 0.0003798 ± 4.3e-05 s | 0.0006231 ± 0.0013 s | 0.0001752 ± 1.6e-05 s | 1.64x | 0.46x |
| 8 | U1+T(k=0)+P(p=1) | 84 | 0.0006431 ± 0.00018 s | 0.0003092 ± 3.6e-05 s | 0.0002116 ± 6.3e-06 s | 0.48x | 0.33x |
| 10 | U1 | 8953 | 0.001052 ± 0.00028 s | 1.415e-05 ± 9.8e-06 s | 0.0002719 ± 6.7e-06 s | 0.01x | 0.26x |
| 10 | U1+T(k=0) | 902 | 0.00338 ± 0.0002 s | 0.001727 ± 0.00012 s | 0.001399 ± 9e-06 s | 0.51x | 0.41x |
| 10 | U1+T(k=0)+P(p=1) | 486 | 0.004891 ± 0.00024 s | 0.002229 ± 0.00015 s | 0.001994 ± 7.8e-05 s | 0.46x | 0.41x |
| 12 | U1 | 73789 | 0.009394 ± 0.00063 s | 3.059e-05 ± 1.1e-05 s | 0.002246 ± 0.00015 s | 0.00x | 0.24x |
| 12 | U1+T(k=0) | 6166 | 0.03396 ± 0.0017 s | 0.01582 ± 0.00032 s | 0.01441 ± 0.0006 s | 0.47x | 0.42x |
| 12 | U1+T(k=0)+P(p=1) | 3179 | 0.05321 ± 0.0022 s | 0.01716 ± 0.0002 s | 0.01869 ± 0.00053 s | 0.32x | 0.35x |

### Boson (d=3) — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 6.479e-06 ± 4.3e-07 s | N/A (no decoupled API) | 3.486e-07 ± 1.5e-08 s |

