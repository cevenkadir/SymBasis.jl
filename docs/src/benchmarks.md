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
| 8 | U1 | 70 | 6.961e-06 ± 1.1e-05 s | 4.597e-06 ± 7.5e-06 s | 2.313e-05 ± 1.1e-05 s | 0.66x | 3.32x |
| 8 | U1+T(k=0) | 10 | 1.156e-05 ± 1.4e-05 s | 4.602e-05 ± 2.9e-05 s | 2.717e-05 ± 9e-06 s | 3.98x | 2.35x |
| 8 | U1+T(k=0)+P(p=1) | 8 | 6.902e-05 ± 7.7e-05 s | 0.0001008 ± 3.3e-05 s | 3.181e-05 ± 9.4e-06 s | 1.46x | 0.46x |
| 10 | U1 | 252 | 9.567e-06 ± 1.1e-05 s | 4.434e-06 ± 7.6e-06 s | 2.072e-05 ± 5.2e-06 s | 0.46x | 2.17x |
| 10 | U1+T(k=0) | 26 | 0.0004469 ± 0.0009 s | 7.973e-05 ± 2.7e-05 s | 3.284e-05 ± 7.1e-06 s | 0.18x | 0.07x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 0.0003541 ± 0.00034 s | 0.0001786 ± 3.7e-05 s | 4.29e-05 ± 6.3e-06 s | 0.50x | 0.12x |
| 12 | U1 | 924 | 1.555e-05 ± 1.3e-05 s | 4.881e-06 ± 7.2e-06 s | 2.867e-05 ± 5.9e-06 s | 0.31x | 1.84x |
| 12 | U1+T(k=0) | 80 | 6.07e-05 ± 2.7e-05 s | 0.0002124 ± 2.8e-05 s | 6.58e-05 ± 8.3e-06 s | 3.50x | 1.08x |
| 12 | U1+T(k=0)+P(p=1) | 50 | 0.0001024 ± 7.3e-05 s | 0.0003714 ± 3.7e-05 s | 9.471e-05 ± 1e-05 s | 3.63x | 0.92x |
| 14 | U1 | 3432 | 6.742e-05 ± 3.5e-05 s | 5.647e-06 ± 7.8e-06 s | 4.602e-05 ± 5.3e-06 s | 0.08x | 0.68x |
| 14 | U1+T(k=0) | 246 | 0.0001293 ± 2.8e-05 s | 0.0007198 ± 3.3e-05 s | 0.0001788 ± 8.3e-06 s | 5.57x | 1.38x |
| 14 | U1+T(k=0)+P(p=1) | 133 | 0.00022 ± 8.8e-05 s | 0.001022 ± 4.8e-05 s | 0.0002806 ± 1.1e-05 s | 4.64x | 1.28x |
| 16 | U1 | 12870 | 0.0002451 ± 8.1e-05 s | 6.819e-06 ± 9e-06 s | 0.000117 ± 8.9e-06 s | 0.03x | 0.48x |
| 16 | U1+T(k=0) | 810 | 0.0006754 ± 0.00073 s | 0.002943 ± 3.1e-05 s | 0.0006159 ± 1.3e-05 s | 4.36x | 0.91x |
| 16 | U1+T(k=0)+P(p=1) | 440 | 0.00108 ± 0.00088 s | 0.003814 ± 0.00015 s | 0.0009954 ± 1.9e-05 s | 3.53x | 0.92x |

### Spin-1/2 — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 2.758e-07 ± 2.1e-09 s | N/A (no decoupled API) | 1.609e-07 ± 1.5e-09 s |

### Spinless fermion — basis construction

```@example benchmarks
plot_construction("fermion", "Spinless fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 8 | U1 | 70 | 6.603e-06 ± 9.2e-06 s | 4.839e-06 ± 8e-06 s | 2.958e-05 ± 9.5e-06 s | 0.73x | 4.48x |
| 8 | U1+T(k=0) | 9 | 1.113e-05 ± 1.3e-05 s | 5.008e-05 ± 4.4e-05 s | 3.803e-05 ± 8.3e-06 s | 4.50x | 3.42x |
| 8 | U1+T(k=0)+P(p=1) | 6 | 7.388e-05 ± 6.7e-05 s | 0.0001044 ± 3.7e-05 s | 4.063e-05 ± 8.1e-06 s | 1.41x | 0.55x |
| 10 | U1 | 252 | 1.113e-05 ± 1.2e-05 s | 4.157e-06 ± 6.9e-06 s | 3.049e-05 ± 7.1e-06 s | 0.37x | 2.74x |
| 10 | U1+T(k=0) | 26 | 3.515e-05 ± 3.2e-05 s | 8.462e-05 ± 2.8e-05 s | 4.734e-05 ± 7.3e-06 s | 2.41x | 1.35x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 5.047e-05 ± 2.7e-05 s | 0.0001737 ± 3.8e-05 s | 5.662e-05 ± 6.4e-06 s | 3.44x | 1.12x |
| 12 | U1 | 924 | 2.257e-05 ± 1.8e-05 s | 4.392e-06 ± 6.9e-06 s | 3.696e-05 ± 6.2e-06 s | 0.19x | 1.64x |
| 12 | U1+T(k=0) | 76 | 0.000936 ± 0.0011 s | 0.0002344 ± 2.8e-05 s | 8.732e-05 ± 1e-05 s | 0.25x | 0.09x |
| 12 | U1+T(k=0)+P(p=1) | 33 | 0.00065 ± 0.0008 s | 0.0003869 ± 3.8e-05 s | 0.0001203 ± 8.9e-06 s | 0.60x | 0.19x |
| 14 | U1 | 3432 | 0.000558 ± 0.00041 s | 5.961e-06 ± 8.5e-06 s | 4.936e-05 ± 1e-05 s | 0.01x | 0.09x |
| 14 | U1+T(k=0) | 246 | 0.0002121 ± 0.00023 s | 0.00081 ± 3.5e-05 s | 0.0001795 ± 7.1e-06 s | 3.82x | 0.85x |
| 14 | U1+T(k=0)+P(p=1) | 113 | 0.000708 ± 0.00083 s | 0.001102 ± 5.3e-05 s | 0.0002782 ± 1.2e-05 s | 1.56x | 0.39x |
| 16 | U1 | 12870 | 0.0003162 ± 6.7e-05 s | 7.061e-06 ± 1e-05 s | 0.0001159 ± 7.4e-06 s | 0.02x | 0.37x |
| 16 | U1+T(k=0) | 809 | 0.000451 ± 0.00031 s | 0.003461 ± 0.00018 s | 0.0006174 ± 1e-05 s | 7.67x | 1.37x |
| 16 | U1+T(k=0)+P(p=1) | 422 | 0.0007421 ± 0.00038 s | 0.004155 ± 0.00012 s | 0.0009965 ± 7.4e-06 s | 5.60x | 1.34x |

### Spinless fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 3.121e-07 ± 9e-10 s | N/A (no decoupled API) | 1.496e-06 ± 7.6e-09 s |

### Spinful fermion — basis construction

```@example benchmarks
plot_construction("spinful_fermion", "Spinful fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 4 | U1 | 36 | 7.23e-06 ± 9.4e-06 s | 5.902e-06 ± 9.5e-06 s | 3.525e-05 ± 1.1e-05 s | 0.82x | 4.88x |
| 4 | U1+T(k=0) | 10 | 1.068e-05 ± 1.3e-05 s | 0.0002057 ± 0.00058 s | 4.604e-05 ± 1.9e-05 s | 19.26x | 4.31x |
| 4 | U1+T(k=0)+P(p=1) | 6 | 1.514e-05 ± 1.4e-05 s | 5.389e-05 ± 3.8e-05 s | 4.865e-05 ± 9.1e-06 s | 3.56x | 3.21x |
| 6 | U1 | 400 | 1.812e-05 ± 1.3e-05 s | 5.08e-06 ± 9.3e-06 s | 4.126e-05 ± 7.2e-06 s | 0.28x | 2.28x |
| 6 | U1+T(k=0) | 68 | 0.0001503 ± 0.0002 s | 4.687e-05 ± 3.1e-05 s | 8.433e-05 ± 1.2e-05 s | 0.31x | 0.56x |
| 6 | U1+T(k=0)+P(p=1) | 38 | 0.0005343 ± 0.00078 s | 8.911e-05 ± 4e-05 s | 0.0001226 ± 8.4e-06 s | 0.17x | 0.23x |
| 8 | U1 | 4900 | 0.00054 ± 0.00086 s | 5.597e-06 ± 9.6e-06 s | 0.0001285 ± 8.3e-06 s | 0.01x | 0.24x |
| 8 | U1+T(k=0) | 618 | 0.0003279 ± 7.8e-05 s | 9.752e-05 ± 3.9e-05 s | 0.0004526 ± 2.6e-05 s | 0.30x | 1.38x |
| 8 | U1+T(k=0)+P(p=1) | 318 | 0.0004923 ± 0.00012 s | 0.0002163 ± 4.6e-05 s | 0.0007576 ± 1.3e-05 s | 0.44x | 1.54x |
| 10 | U1 | 63504 | 0.00249 ± 0.00062 s | 5.991e-06 ± 1.1e-05 s | 0.0008941 ± 5.6e-06 s | 0.00x | 0.36x |
| 10 | U1+T(k=0) | 6352 | 0.003669 ± 0.00037 s | 0.0002947 ± 3.5e-05 s | 0.00559 ± 1.9e-05 s | 0.08x | 1.52x |
| 10 | U1+T(k=0)+P(p=1) | 3212 | 0.00565 ± 0.00063 s | 0.0006722 ± 4.5e-05 s | 0.009629 ± 1.8e-05 s | 0.12x | 1.70x |
| 12 | U1 | 853776 | 0.01915 ± 0.0064 s | 6.644e-06 ± 1.1e-05 s | 0.01302 ± 0.00012 s | 0.00x | 0.68x |
| 12 | U1+T(k=0) | 71188 | 0.04334 ± 0.0072 s | 0.001558 ± 6.1e-05 s | 0.07819 ± 0.00029 s | 0.04x | 1.80x |
| 12 | U1+T(k=0)+P(p=1) | 35694 | 0.07129 ± 0.0072 s | 0.003908 ± 5.2e-05 s | 0.134 ± 0.00031 s | 0.05x | 1.88x |

### Spinful fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 1.069e-06 ± 4.8e-09 s | N/A (no decoupled API) | 1.815e-06 ± 3.7e-09 s |

### Boson (d=3) — basis construction

```@example benchmarks
plot_construction("boson", "Boson (d=3)")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 6 | U1 | 141 | 1.135e-05 ± 1e-05 s | 5.05e-06 ± 7.6e-06 s | 3.717e-05 ± 9.5e-06 s | 0.44x | 3.27x |
| 6 | U1+T(k=0) | 26 | 1.813e-05 ± 1.5e-05 s | 0.0001346 ± 0.0003 s | 4.872e-05 ± 8.4e-06 s | 7.43x | 2.69x |
| 6 | U1+T(k=0)+P(p=1) | 18 | 0.0001697 ± 0.00033 s | 8.71e-05 ± 3.5e-05 s | 5.512e-05 ± 7.2e-06 s | 0.51x | 0.32x |
| 8 | U1 | 1107 | 0.0003431 ± 0.00022 s | 6.225e-06 ± 7.6e-06 s | 6.4e-05 ± 7.9e-06 s | 0.02x | 0.19x |
| 8 | U1+T(k=0) | 142 | 0.0001671 ± 0.00016 s | 0.0001914 ± 2.7e-05 s | 0.0001747 ± 1.4e-05 s | 1.15x | 1.05x |
| 8 | U1+T(k=0)+P(p=1) | 84 | 0.000261 ± 0.00018 s | 0.0002786 ± 3.2e-05 s | 0.0002037 ± 1.2e-05 s | 1.07x | 0.78x |
| 10 | U1 | 8953 | 0.0003928 ± 0.00011 s | 1.049e-05 ± 9.5e-06 s | 0.0002408 ± 1.2e-05 s | 0.03x | 0.61x |
| 10 | U1+T(k=0) | 902 | 0.0007197 ± 0.00028 s | 0.001481 ± 3.1e-05 s | 0.001264 ± 1.7e-05 s | 2.06x | 1.76x |
| 10 | U1+T(k=0)+P(p=1) | 486 | 0.0009909 ± 0.00013 s | 0.001882 ± 3e-05 s | 0.001495 ± 2.3e-05 s | 1.90x | 1.51x |
| 12 | U1 | 73789 | 0.002323 ± 0.00077 s | 2.446e-05 ± 1.1e-05 s | 0.001794 ± 4.8e-05 s | 0.01x | 0.77x |
| 12 | U1+T(k=0) | 6166 | 0.004888 ± 0.0009 s | 0.01383 ± 2.8e-05 s | 0.01194 ± 3e-05 s | 2.83x | 2.44x |
| 12 | U1+T(k=0)+P(p=1) | 3179 | 0.007881 ± 0.0011 s | 0.01655 ± 0.00017 s | 0.01403 ± 3.1e-05 s | 2.10x | 1.78x |

### Boson (d=3) — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 1.409e-06 ± 2.9e-09 s | N/A (no decoupled API) | 2.824e-07 ± 9.9e-09 s |

