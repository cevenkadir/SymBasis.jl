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
| 8 | U1 | 70 | 7.787e-06 ± 1.3e-05 s | 5.293e-06 ± 8.6e-06 s | 1.81e-05 ± 1e-05 s | 0.68x | 2.32x |
| 8 | U1+T(k=0) | 10 | 1.21e-05 ± 1.7e-05 s | 4.904e-05 ± 4.6e-05 s | 2.088e-05 ± 5.9e-06 s | 4.05x | 1.73x |
| 8 | U1+T(k=0)+P(p=1) | 8 | 0.0002341 ± 0.00035 s | 0.0002363 ± 0.00052 s | 2.35e-05 ± 5.2e-06 s | 1.01x | 0.10x |
| 10 | U1 | 252 | 1.165e-05 ± 1.5e-05 s | 5.439e-06 ± 8.8e-06 s | 1.575e-05 ± 3.2e-06 s | 0.47x | 1.35x |
| 10 | U1+T(k=0) | 26 | 0.0005662 ± 0.00085 s | 8.194e-05 ± 3.6e-05 s | 2.7e-05 ± 4.8e-06 s | 0.14x | 0.05x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 0.000546 ± 0.00068 s | 0.0001503 ± 4.1e-05 s | 3.604e-05 ± 4.7e-06 s | 0.28x | 0.07x |
| 12 | U1 | 924 | 1.92e-05 ± 1.5e-05 s | 5.044e-06 ± 8.9e-06 s | 2.153e-05 ± 2.7e-06 s | 0.26x | 1.12x |
| 12 | U1+T(k=0) | 80 | 0.0005215 ± 0.00088 s | 0.0001712 ± 3.1e-05 s | 5.656e-05 ± 5.4e-06 s | 0.33x | 0.11x |
| 12 | U1+T(k=0)+P(p=1) | 50 | 0.0008024 ± 0.00089 s | 0.0002894 ± 4.8e-05 s | 8.264e-05 ± 7.9e-06 s | 0.36x | 0.10x |
| 14 | U1 | 3432 | 0.0006228 ± 0.00075 s | 6.264e-06 ± 9.1e-06 s | 3.998e-05 ± 5.3e-06 s | 0.01x | 0.06x |
| 14 | U1+T(k=0) | 246 | 0.0007793 ± 0.00065 s | 0.0006236 ± 2.6e-05 s | 0.0001601 ± 4e-06 s | 0.80x | 0.21x |
| 14 | U1+T(k=0)+P(p=1) | 133 | 0.0004869 ± 0.00079 s | 0.00077 ± 6.4e-05 s | 0.0002482 ± 7.5e-06 s | 1.58x | 0.51x |
| 16 | U1 | 12870 | 0.0005928 ± 0.00082 s | 8.417e-06 ± 1.1e-05 s | 0.0001005 ± 4.8e-06 s | 0.01x | 0.17x |
| 16 | U1+T(k=0) | 810 | 0.0002788 ± 4.1e-05 s | 0.002189 ± 0.00015 s | 0.0005643 ± 1.1e-05 s | 7.85x | 2.02x |
| 16 | U1+T(k=0)+P(p=1) | 440 | 0.000554 ± 0.00011 s | 0.002711 ± 5.7e-05 s | 0.0008919 ± 1.2e-05 s | 4.89x | 1.61x |

### Spin-1/2 — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 8.96e-08 ± 3.1e-09 s | N/A (no decoupled API) | 1.572e-07 ± 9.1e-10 s |

### Spinless fermion — basis construction

```@example benchmarks
plot_construction("fermion", "Spinless fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 8 | U1 | 70 | 7.667e-06 ± 1.3e-05 s | 5.029e-06 ± 9.2e-06 s | 2.051e-05 ± 6.7e-06 s | 0.66x | 2.68x |
| 8 | U1+T(k=0) | 9 | 1.302e-05 ± 1.8e-05 s | 4.68e-05 ± 3e-05 s | 2.638e-05 ± 1e-05 s | 3.59x | 2.03x |
| 8 | U1+T(k=0)+P(p=1) | 6 | 7.049e-05 ± 0.00013 s | 0.0001027 ± 4.3e-05 s | 2.756e-05 ± 3.9e-06 s | 1.46x | 0.39x |
| 10 | U1 | 252 | 1.331e-05 ± 1.6e-05 s | 8.099e-06 ± 1.2e-05 s | 2.137e-05 ± 5.7e-06 s | 0.61x | 1.61x |
| 10 | U1+T(k=0) | 26 | 4.162e-05 ± 3.7e-05 s | 8.818e-05 ± 4e-05 s | 3.122e-05 ± 2.6e-06 s | 2.12x | 0.75x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 5.399e-05 ± 3.6e-05 s | 0.0001702 ± 5.7e-05 s | 3.886e-05 ± 3.6e-06 s | 3.15x | 0.72x |
| 12 | U1 | 924 | 1.728e-05 ± 1.6e-05 s | 5.48e-06 ± 1e-05 s | 2.655e-05 ± 4.9e-06 s | 0.32x | 1.54x |
| 12 | U1+T(k=0) | 76 | 5.918e-05 ± 3.2e-05 s | 0.000199 ± 3.5e-05 s | 6.12e-05 ± 5e-06 s | 3.36x | 1.03x |
| 12 | U1+T(k=0)+P(p=1) | 33 | 7.919e-05 ± 3.7e-05 s | 0.0003431 ± 4.3e-05 s | 7.984e-05 ± 7.2e-06 s | 4.33x | 1.01x |
| 14 | U1 | 3432 | 0.0002813 ± 0.00061 s | 6.065e-06 ± 8.9e-06 s | 3.79e-05 ± 2.6e-06 s | 0.02x | 0.13x |
| 14 | U1+T(k=0) | 246 | 0.0001577 ± 9.1e-05 s | 0.0007175 ± 3.1e-05 s | 0.0001587 ± 4.1e-06 s | 4.55x | 1.01x |
| 14 | U1+T(k=0)+P(p=1) | 113 | 0.0002613 ± 0.00027 s | 0.0008563 ± 6.3e-05 s | 0.0002432 ± 5.1e-06 s | 3.28x | 0.93x |
| 16 | U1 | 12870 | 0.0002387 ± 7e-05 s | 8.256e-06 ± 1.2e-05 s | 0.000101 ± 6.3e-06 s | 0.03x | 0.42x |
| 16 | U1+T(k=0) | 809 | 0.0004774 ± 0.00039 s | 0.002639 ± 4.4e-05 s | 0.0005634 ± 9e-06 s | 5.53x | 1.18x |
| 16 | U1+T(k=0)+P(p=1) | 422 | 0.0009224 ± 0.00077 s | 0.003062 ± 8.6e-05 s | 0.0008862 ± 6.4e-06 s | 3.32x | 0.96x |

### Spinless fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 1.45e-07 ± 1.1e-08 s | N/A (no decoupled API) | 1.471e-06 ± 1.2e-08 s |

### Spinful fermion — basis construction

```@example benchmarks
plot_construction("spinful_fermion", "Spinful fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 4 | U1 | 36 | 7.63e-06 ± 1.2e-05 s | 6.883e-06 ± 1.2e-05 s | 2.424e-05 ± 8.7e-06 s | 0.90x | 3.18x |
| 4 | U1+T(k=0) | 10 | 1.186e-05 ± 1.8e-05 s | 3.69e-05 ± 4.1e-05 s | 3.132e-05 ± 8.3e-06 s | 3.11x | 2.64x |
| 4 | U1+T(k=0)+P(p=1) | 6 | 1.267e-05 ± 1.6e-05 s | 5.583e-05 ± 4.7e-05 s | 3.204e-05 ± 6.1e-06 s | 4.41x | 2.53x |
| 6 | U1 | 400 | 2.235e-05 ± 1.6e-05 s | 6.989e-06 ± 1.4e-05 s | 2.846e-05 ± 6.1e-06 s | 0.31x | 1.27x |
| 6 | U1+T(k=0) | 68 | 9.024e-05 ± 0.00013 s | 4.805e-05 ± 4.3e-05 s | 5.521e-05 ± 2.9e-06 s | 0.53x | 0.61x |
| 6 | U1+T(k=0)+P(p=1) | 38 | 0.0001504 ± 0.0002 s | 9.078e-05 ± 5.1e-05 s | 8.474e-05 ± 9.1e-06 s | 0.60x | 0.56x |
| 8 | U1 | 4900 | 0.000234 ± 5.7e-05 s | 7.057e-06 ± 1.3e-05 s | 8.099e-05 ± 4.7e-06 s | 0.03x | 0.35x |
| 8 | U1+T(k=0) | 618 | 0.0003698 ± 0.00015 s | 8.658e-05 ± 4.1e-05 s | 0.0004141 ± 9e-06 s | 0.23x | 1.12x |
| 8 | U1+T(k=0)+P(p=1) | 318 | 0.0006094 ± 0.00064 s | 0.000169 ± 4.8e-05 s | 0.000689 ± 7.7e-06 s | 0.28x | 1.13x |
| 10 | U1 | 63504 | 0.002236 ± 0.00024 s | 6.353e-06 ± 1.2e-05 s | 0.000804 ± 3.5e-05 s | 0.00x | 0.36x |
| 10 | U1+T(k=0) | 6352 | 0.003943 ± 0.00064 s | 0.0002419 ± 6.1e-05 s | 0.005282 ± 1.6e-05 s | 0.06x | 1.34x |
| 10 | U1+T(k=0)+P(p=1) | 3212 | 0.005073 ± 0.00076 s | 0.0004684 ± 6.2e-05 s | 0.008783 ± 1.3e-05 s | 0.09x | 1.73x |
| 12 | U1 | 853776 | 0.02131 ± 0.0091 s | 7.541e-06 ± 1.3e-05 s | 0.01183 ± 0.0003 s | 0.00x | 0.55x |
| 12 | U1+T(k=0) | 71188 | 0.04321 ± 0.0087 s | 0.001597 ± 8.5e-05 s | 0.07369 ± 0.00012 s | 0.04x | 1.71x |
| 12 | U1+T(k=0)+P(p=1) | 35694 | 0.0703 ± 0.0077 s | 0.003742 ± 0.00027 s | 0.1247 ± 0.0061 s | 0.05x | 1.77x |

### Spinful fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 1.117e-06 ± 3.1e-08 s | N/A (no decoupled API) | 1.813e-06 ± 6.8e-08 s |

### Boson (d=3) — basis construction

```@example benchmarks
plot_construction("boson", "Boson (d=3)")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 6 | U1 | 141 | 1.138e-05 ± 1.4e-05 s | 5.619e-06 ± 9e-06 s | 2.648e-05 ± 1.1e-05 s | 0.49x | 2.33x |
| 6 | U1+T(k=0) | 26 | 2.178e-05 ± 2e-05 s | 0.0001455 ± 0.00033 s | 3.621e-05 ± 5.6e-06 s | 6.68x | 1.66x |
| 6 | U1+T(k=0)+P(p=1) | 18 | 0.0004538 ± 0.00079 s | 8.48e-05 ± 5e-05 s | 4.163e-05 ± 4.8e-06 s | 0.19x | 0.09x |
| 8 | U1 | 1107 | 0.0003447 ± 7.2e-05 s | 7.264e-06 ± 9.1e-06 s | 5.061e-05 ± 3.6e-06 s | 0.02x | 0.15x |
| 8 | U1+T(k=0) | 142 | 0.0001271 ± 5.1e-05 s | 0.0001722 ± 3.5e-05 s | 0.0001428 ± 1.2e-05 s | 1.35x | 1.12x |
| 8 | U1+T(k=0)+P(p=1) | 84 | 0.0005203 ± 0.0007 s | 0.0002442 ± 4.3e-05 s | 0.0001709 ± 5.7e-06 s | 0.47x | 0.33x |
| 10 | U1 | 8953 | 0.0003192 ± 9.1e-05 s | 1.395e-05 ± 1.4e-05 s | 0.0002129 ± 4.9e-06 s | 0.04x | 0.67x |
| 10 | U1+T(k=0) | 902 | 0.001306 ± 0.00089 s | 0.001257 ± 8.2e-05 s | 0.001165 ± 1.2e-05 s | 0.96x | 0.89x |
| 10 | U1+T(k=0)+P(p=1) | 486 | 0.001173 ± 0.00015 s | 0.001652 ± 5.6e-05 s | 0.001537 ± 1.3e-05 s | 1.41x | 1.31x |
| 12 | U1 | 73789 | 0.002831 ± 0.00056 s | 3.017e-05 ± 1.2e-05 s | 0.001677 ± 5.2e-05 s | 0.01x | 0.59x |
| 12 | U1+T(k=0) | 6166 | 0.005079 ± 0.00057 s | 0.01068 ± 0.00015 s | 0.01154 ± 9.8e-05 s | 2.10x | 2.27x |
| 12 | U1+T(k=0)+P(p=1) | 3179 | 0.008134 ± 0.0011 s | 0.01247 ± 0.00034 s | 0.01501 ± 0.00012 s | 1.53x | 1.85x |

### Boson (d=3) — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 1.41e-06 ± 1.6e-08 s | N/A (no decoupled API) | 5.096e-07 ± 2.9e-07 s |

