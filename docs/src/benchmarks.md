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
| 8 | U1 | 70 | 6.264e-06 ± 8.3e-06 s | 4.739e-06 ± 7.9e-06 s | 2.552e-05 ± 1.2e-05 s | 0.76x | 4.07x |
| 8 | U1+T(k=0) | 10 | 1.162e-05 ± 1.3e-05 s | 9.04e-05 ± 0.00018 s | 2.749e-05 ± 9.1e-06 s | 7.78x | 2.37x |
| 8 | U1+T(k=0)+P(p=1) | 8 | 0.0001195 ± 0.00016 s | 0.0001006 ± 3.3e-05 s | 3.182e-05 ± 1e-05 s | 0.84x | 0.27x |
| 10 | U1 | 252 | 9.581e-06 ± 1.1e-05 s | 4.446e-06 ± 7e-06 s | 2.078e-05 ± 5.4e-06 s | 0.46x | 2.17x |
| 10 | U1+T(k=0) | 26 | 3.532e-05 ± 3.3e-05 s | 7.871e-05 ± 2.6e-05 s | 3.497e-05 ± 7.8e-06 s | 2.23x | 0.99x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 0.0001134 ± 0.00024 s | 0.0001801 ± 3.4e-05 s | 4.21e-05 ± 6.5e-06 s | 1.59x | 0.37x |
| 12 | U1 | 924 | 2.183e-05 ± 1.2e-05 s | 4.517e-06 ± 6.9e-06 s | 2.829e-05 ± 6.7e-06 s | 0.21x | 1.30x |
| 12 | U1+T(k=0) | 80 | 8.937e-05 ± 6.1e-05 s | 0.0002109 ± 2.5e-05 s | 6.686e-05 ± 8.3e-06 s | 2.36x | 0.75x |
| 12 | U1+T(k=0)+P(p=1) | 50 | 7.727e-05 ± 2.9e-05 s | 0.0003717 ± 3.1e-05 s | 9.422e-05 ± 1.1e-05 s | 4.81x | 1.22x |
| 14 | U1 | 3432 | 0.000124 ± 9.8e-05 s | 5.352e-06 ± 7.5e-06 s | 4.953e-05 ± 9.4e-06 s | 0.04x | 0.40x |
| 14 | U1+T(k=0) | 246 | 0.0004229 ± 0.00089 s | 0.0007187 ± 3e-05 s | 0.00018 ± 7.4e-06 s | 1.70x | 0.43x |
| 14 | U1+T(k=0)+P(p=1) | 133 | 0.0003785 ± 0.0006 s | 0.001587 ± 0.0012 s | 0.0002797 ± 1.4e-05 s | 4.19x | 0.74x |
| 16 | U1 | 12870 | 0.0003369 ± 6.6e-05 s | 6.945e-06 ± 9.6e-06 s | 0.0001182 ± 1.2e-05 s | 0.02x | 0.35x |
| 16 | U1+T(k=0) | 810 | 0.0003867 ± 0.00013 s | 0.002956 ± 3.6e-05 s | 0.0006168 ± 1.3e-05 s | 7.64x | 1.60x |
| 16 | U1+T(k=0)+P(p=1) | 440 | 0.0008139 ± 0.00052 s | 0.003747 ± 3.3e-05 s | 0.0009969 ± 1.3e-05 s | 4.60x | 1.22x |

### Spin-1/2 — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 2.634e-07 ± 9.3e-10 s | N/A (no decoupled API) | 1.613e-07 ± 1.2e-09 s |

### Spinless fermion — basis construction

```@example benchmarks
plot_construction("fermion", "Spinless fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 8 | U1 | 70 | 6.448e-06 ± 8.7e-06 s | 4.402e-06 ± 7.6e-06 s | 3.289e-05 ± 2e-05 s | 0.68x | 5.10x |
| 8 | U1+T(k=0) | 9 | 1.227e-05 ± 1.5e-05 s | 4.615e-05 ± 2.6e-05 s | 3.529e-05 ± 7.2e-06 s | 3.76x | 2.88x |
| 8 | U1+T(k=0)+P(p=1) | 6 | 0.0004125 ± 0.00076 s | 9.899e-05 ± 3.5e-05 s | 3.981e-05 ± 7.9e-06 s | 0.24x | 0.10x |
| 10 | U1 | 252 | 1.022e-05 ± 1.2e-05 s | 4.256e-06 ± 6.6e-06 s | 3.028e-05 ± 6.5e-06 s | 0.42x | 2.96x |
| 10 | U1+T(k=0) | 26 | 0.0002257 ± 0.00035 s | 8.306e-05 ± 2.7e-05 s | 4.485e-05 ± 5.2e-06 s | 0.37x | 0.20x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 0.0001666 ± 0.00013 s | 0.0001732 ± 3e-05 s | 5.585e-05 ± 7.7e-06 s | 1.04x | 0.34x |
| 12 | U1 | 924 | 1.979e-05 ± 1.1e-05 s | 5.142e-06 ± 7.6e-06 s | 3.661e-05 ± 5.8e-06 s | 0.26x | 1.85x |
| 12 | U1+T(k=0) | 76 | 5.64e-05 ± 2.6e-05 s | 0.0002298 ± 2.9e-05 s | 8.497e-05 ± 6.7e-06 s | 4.07x | 1.51x |
| 12 | U1+T(k=0)+P(p=1) | 33 | 8.84e-05 ± 4.1e-05 s | 0.0003848 ± 3e-05 s | 0.0001188 ± 7.6e-06 s | 4.35x | 1.34x |
| 14 | U1 | 3432 | 0.0004443 ± 0.00093 s | 5.547e-06 ± 7.7e-06 s | 5.511e-05 ± 1e-05 s | 0.01x | 0.12x |
| 14 | U1+T(k=0) | 246 | 0.0001213 ± 3.4e-05 s | 0.0008105 ± 4.2e-05 s | 0.0001771 ± 7.1e-06 s | 6.68x | 1.46x |
| 14 | U1+T(k=0)+P(p=1) | 113 | 0.0002793 ± 0.0002 s | 0.001221 ± 0.0003 s | 0.000283 ± 1.3e-05 s | 4.37x | 1.01x |
| 16 | U1 | 12870 | 0.000423 ± 0.00011 s | 6.948e-06 ± 9.4e-06 s | 0.0001153 ± 6.4e-06 s | 0.02x | 0.27x |
| 16 | U1+T(k=0) | 809 | 0.0006543 ± 0.00067 s | 0.003384 ± 3.4e-05 s | 0.000617 ± 1.2e-05 s | 5.17x | 0.94x |
| 16 | U1+T(k=0)+P(p=1) | 422 | 0.0007272 ± 0.00025 s | 0.004157 ± 8.5e-05 s | 0.0009937 ± 1.1e-05 s | 5.72x | 1.37x |

### Spinless fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 3.11e-07 ± 3.2e-09 s | N/A (no decoupled API) | 1.51e-06 ± 2.8e-08 s |

### Spinful fermion — basis construction

```@example benchmarks
plot_construction("spinful_fermion", "Spinful fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 4 | U1 | 36 | 7.343e-06 ± 9.1e-06 s | 6.165e-06 ± 1e-05 s | 3.558e-05 ± 1e-05 s | 0.84x | 4.85x |
| 4 | U1+T(k=0) | 10 | 1.161e-05 ± 1.3e-05 s | 3.065e-05 ± 3.1e-05 s | 4.209e-05 ± 8.8e-06 s | 2.64x | 3.63x |
| 4 | U1+T(k=0)+P(p=1) | 6 | 1.254e-05 ± 1.3e-05 s | 5.316e-05 ± 3.8e-05 s | 4.592e-05 ± 8.8e-06 s | 4.24x | 3.66x |
| 6 | U1 | 400 | 1.777e-05 ± 1.3e-05 s | 5.347e-06 ± 9.7e-06 s | 4.096e-05 ± 1.1e-05 s | 0.30x | 2.31x |
| 6 | U1+T(k=0) | 68 | 0.0004843 ± 0.00084 s | 4.593e-05 ± 3.3e-05 s | 8.048e-05 ± 7.6e-06 s | 0.09x | 0.17x |
| 6 | U1+T(k=0)+P(p=1) | 38 | 7.175e-05 ± 3.6e-05 s | 9.052e-05 ± 4e-05 s | 0.0001201 ± 1e-05 s | 1.26x | 1.67x |
| 8 | U1 | 4900 | 0.0002145 ± 4.2e-05 s | 6.048e-06 ± 1.1e-05 s | 0.0001232 ± 6.5e-06 s | 0.03x | 0.57x |
| 8 | U1+T(k=0) | 618 | 0.0003225 ± 3.1e-05 s | 9.823e-05 ± 3.5e-05 s | 0.0004416 ± 1.2e-05 s | 0.30x | 1.37x |
| 8 | U1+T(k=0)+P(p=1) | 318 | 0.0004944 ± 9.6e-05 s | 0.000323 ± 0.00038 s | 0.0007577 ± 1.2e-05 s | 0.65x | 1.53x |
| 10 | U1 | 63504 | 0.002583 ± 0.001 s | 5.965e-06 ± 1e-05 s | 0.0009005 ± 3e-05 s | 0.00x | 0.35x |
| 10 | U1+T(k=0) | 6352 | 0.003918 ± 0.00099 s | 0.0002953 ± 3.7e-05 s | 0.005614 ± 1.5e-05 s | 0.08x | 1.43x |
| 10 | U1+T(k=0)+P(p=1) | 3212 | 0.005615 ± 0.0008 s | 0.0006691 ± 4.3e-05 s | 0.009675 ± 2.9e-05 s | 0.12x | 1.72x |
| 12 | U1 | 853776 | 0.01789 ± 0.0064 s | 6.426e-06 ± 1e-05 s | 0.01241 ± 0.00015 s | 0.00x | 0.69x |
| 12 | U1+T(k=0) | 71188 | 0.0439 ± 0.0065 s | 0.00155 ± 5.6e-05 s | 0.0784 ± 0.00028 s | 0.04x | 1.79x |
| 12 | U1+T(k=0)+P(p=1) | 35694 | 0.07286 ± 0.006 s | 0.00394 ± 0.00016 s | 0.1337 ± 0.00038 s | 0.05x | 1.84x |

### Spinful fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 1.088e-06 ± 5.6e-09 s | N/A (no decoupled API) | 1.819e-06 ± 5.9e-09 s |

### Boson (d=3) — basis construction

```@example benchmarks
plot_construction("boson", "Boson (d=3)")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 6 | U1 | 141 | 9.734e-06 ± 9.9e-06 s | 4.869e-06 ± 7.1e-06 s | 3.498e-05 ± 8.8e-06 s | 0.50x | 3.59x |
| 6 | U1+T(k=0) | 26 | 1.771e-05 ± 1.3e-05 s | 0.0002153 ± 0.00056 s | 4.867e-05 ± 8.2e-06 s | 12.16x | 2.75x |
| 6 | U1+T(k=0)+P(p=1) | 18 | 0.0001587 ± 0.00029 s | 8.41e-05 ± 3.3e-05 s | 5.571e-05 ± 1.3e-05 s | 0.53x | 0.35x |
| 8 | U1 | 1107 | 7.626e-05 ± 2.9e-05 s | 6.215e-06 ± 7.6e-06 s | 6.544e-05 ± 6e-06 s | 0.08x | 0.86x |
| 8 | U1+T(k=0) | 142 | 0.0001193 ± 6.4e-05 s | 0.0001899 ± 2.6e-05 s | 0.00017 ± 1.1e-05 s | 1.59x | 1.42x |
| 8 | U1+T(k=0)+P(p=1) | 84 | 0.0006695 ± 0.00082 s | 0.0002828 ± 3.8e-05 s | 0.0002012 ± 1.9e-05 s | 0.42x | 0.30x |
| 10 | U1 | 8953 | 0.0004987 ± 0.00027 s | 1.031e-05 ± 9e-06 s | 0.0002417 ± 5.6e-06 s | 0.02x | 0.48x |
| 10 | U1+T(k=0) | 902 | 0.001537 ± 0.00095 s | 0.001481 ± 2.4e-05 s | 0.001272 ± 1.5e-05 s | 0.96x | 0.83x |
| 10 | U1+T(k=0)+P(p=1) | 486 | 0.001126 ± 0.00042 s | 0.001884 ± 3.6e-05 s | 0.001475 ± 1.7e-05 s | 1.67x | 1.31x |
| 12 | U1 | 73789 | 0.002369 ± 0.00028 s | 2.979e-05 ± 1.2e-05 s | 0.001787 ± 1.5e-05 s | 0.01x | 0.75x |
| 12 | U1+T(k=0) | 6166 | 0.005193 ± 0.0007 s | 0.01383 ± 2.9e-05 s | 0.01189 ± 2.6e-05 s | 2.66x | 2.29x |
| 12 | U1+T(k=0)+P(p=1) | 3179 | 0.008217 ± 0.00064 s | 0.01652 ± 4.4e-05 s | 0.01403 ± 4.9e-05 s | 2.01x | 1.71x |

### Boson (d=3) — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 1.383e-06 ± 2.7e-09 s | N/A (no decoupled API) | 2.968e-07 ± 5.7e-08 s |

