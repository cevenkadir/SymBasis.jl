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
| 8 | U1 | 70 | 2.294e-05 ± 3.5e-05 s | 4.949e-06 ± 7.9e-06 s | 2.349e-05 ± 1.1e-05 s | 0.22x | 1.02x |
| 8 | U1+T(k=0) | 10 | 3.346e-05 ± 3.3e-05 s | 4.44e-05 ± 3e-05 s | 2.922e-05 ± 1e-05 s | 1.33x | 0.87x |
| 8 | U1+T(k=0)+P(p=1) | 8 | 3.611e-05 ± 3.4e-05 s | 9.828e-05 ± 3.1e-05 s | 3.029e-05 ± 8.5e-06 s | 2.72x | 0.84x |
| 10 | U1 | 252 | 2.948e-05 ± 3.8e-05 s | 4.602e-06 ± 7.7e-06 s | 2.364e-05 ± 7.7e-06 s | 0.16x | 0.80x |
| 10 | U1+T(k=0) | 26 | 0.0005324 ± 0.00089 s | 0.0001083 ± 0.00012 s | 3.404e-05 ± 7e-06 s | 0.20x | 0.06x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 0.0002184 ± 0.00041 s | 0.0001708 ± 3.1e-05 s | 4.471e-05 ± 7.1e-06 s | 0.78x | 0.20x |
| 12 | U1 | 924 | 0.0003478 ± 0.00027 s | 7.197e-06 ± 1.5e-05 s | 2.813e-05 ± 5.1e-06 s | 0.02x | 0.08x |
| 12 | U1+T(k=0) | 80 | 6.644e-05 ± 3e-05 s | 0.0002099 ± 2.4e-05 s | 6.758e-05 ± 1.1e-05 s | 3.16x | 1.02x |
| 12 | U1+T(k=0)+P(p=1) | 50 | 0.0001683 ± 0.00021 s | 0.0003678 ± 3.3e-05 s | 9.247e-05 ± 1.4e-05 s | 2.18x | 0.55x |
| 14 | U1 | 3432 | 0.0001138 ± 6.2e-05 s | 6.055e-06 ± 9.9e-06 s | 4.713e-05 ± 6.1e-06 s | 0.05x | 0.41x |
| 14 | U1+T(k=0) | 246 | 0.0002549 ± 0.00033 s | 0.0007302 ± 3.2e-05 s | 0.0001804 ± 1.3e-05 s | 2.86x | 0.71x |
| 14 | U1+T(k=0)+P(p=1) | 133 | 0.0004974 ± 0.00055 s | 0.001025 ± 4e-05 s | 0.0002747 ± 1.1e-05 s | 2.06x | 0.55x |
| 16 | U1 | 12870 | 0.0005885 ± 0.00047 s | 7.252e-06 ± 1e-05 s | 0.0001172 ± 8.1e-06 s | 0.01x | 0.20x |
| 16 | U1+T(k=0) | 810 | 0.0004077 ± 5.2e-05 s | 0.00292 ± 0.00012 s | 0.0006173 ± 1e-05 s | 7.16x | 1.51x |
| 16 | U1+T(k=0)+P(p=1) | 440 | 0.001161 ± 0.00071 s | 0.003675 ± 4e-05 s | 0.0009742 ± 2.3e-05 s | 3.17x | 0.84x |

### Spin-1/2 — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 2.612e-07 ± 1.1e-09 s | N/A (no decoupled API) | 1.61e-07 ± 1.7e-09 s |

### Spinless fermion — basis construction

```@example benchmarks
plot_construction("fermion", "Spinless fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 8 | U1 | 70 | 2.26e-05 ± 3.3e-05 s | 4.586e-06 ± 7.3e-06 s | 2.885e-05 ± 8.9e-06 s | 0.20x | 1.28x |
| 8 | U1+T(k=0) | 9 | 3.395e-05 ± 3.3e-05 s | 4.502e-05 ± 2.7e-05 s | 3.971e-05 ± 1.3e-05 s | 1.33x | 1.17x |
| 8 | U1+T(k=0)+P(p=1) | 6 | 3.739e-05 ± 2.9e-05 s | 0.000102 ± 3.1e-05 s | 4.125e-05 ± 7.9e-06 s | 2.73x | 1.10x |
| 10 | U1 | 252 | 2.952e-05 ± 3.9e-05 s | 5.031e-06 ± 7.4e-06 s | 2.931e-05 ± 5.9e-06 s | 0.17x | 0.99x |
| 10 | U1+T(k=0) | 26 | 3.909e-05 ± 3.7e-05 s | 8.558e-05 ± 2.8e-05 s | 4.705e-05 ± 7.2e-06 s | 2.19x | 1.20x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 5.715e-05 ± 4.2e-05 s | 0.0001773 ± 3.3e-05 s | 5.703e-05 ± 6.8e-06 s | 3.10x | 1.00x |
| 12 | U1 | 924 | 5.613e-05 ± 7.6e-05 s | 5.342e-06 ± 7.5e-06 s | 3.62e-05 ± 5e-06 s | 0.10x | 0.64x |
| 12 | U1+T(k=0) | 76 | 0.0001121 ± 0.00014 s | 0.0002336 ± 2.8e-05 s | 8.583e-05 ± 1.1e-05 s | 2.08x | 0.77x |
| 12 | U1+T(k=0)+P(p=1) | 33 | 0.0001192 ± 9.2e-05 s | 0.0003844 ± 3.7e-05 s | 0.0001193 ± 7.9e-06 s | 3.23x | 1.00x |
| 14 | U1 | 3432 | 7.27e-05 ± 3.5e-05 s | 5.507e-06 ± 7.1e-06 s | 5.519e-05 ± 1e-05 s | 0.08x | 0.76x |
| 14 | U1+T(k=0) | 246 | 0.0001439 ± 3.2e-05 s | 0.000803 ± 3.8e-05 s | 0.0001785 ± 7.1e-06 s | 5.58x | 1.24x |
| 14 | U1+T(k=0)+P(p=1) | 113 | 0.000513 ± 0.00082 s | 0.001087 ± 5e-05 s | 0.0002729 ± 1.2e-05 s | 2.12x | 0.53x |
| 16 | U1 | 12870 | 0.0009144 ± 0.001 s | 6.784e-06 ± 9.1e-06 s | 0.0001155 ± 7.2e-06 s | 0.01x | 0.13x |
| 16 | U1+T(k=0) | 809 | 0.001086 ± 0.0011 s | 0.003426 ± 2.8e-05 s | 0.0006142 ± 9.6e-06 s | 3.16x | 0.57x |
| 16 | U1+T(k=0)+P(p=1) | 422 | 0.001122 ± 0.00081 s | 0.004036 ± 3.1e-05 s | 0.0009641 ± 7.4e-06 s | 3.60x | 0.86x |

### Spinless fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 3.134e-07 ± 8.9e-10 s | N/A (no decoupled API) | 1.493e-06 ± 1.4e-08 s |

### Spinful fermion — basis construction

```@example benchmarks
plot_construction("spinful_fermion", "Spinful fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 4 | U1 | 36 | 4.396e-05 ± 6.3e-05 s | 6.646e-06 ± 1.1e-05 s | 3.722e-05 ± 1.3e-05 s | 0.15x | 0.85x |
| 4 | U1+T(k=0) | 10 | 0.0001298 ± 0.0002 s | 3.191e-05 ± 3.3e-05 s | 4.111e-05 ± 9.7e-06 s | 0.25x | 0.32x |
| 4 | U1+T(k=0)+P(p=1) | 6 | 3.701e-05 ± 3.5e-05 s | 5.413e-05 ± 4.2e-05 s | 4.665e-05 ± 8.7e-06 s | 1.46x | 1.26x |
| 6 | U1 | 400 | 0.0002074 ± 0.00045 s | 5.65e-06 ± 1.1e-05 s | 4.231e-05 ± 1.3e-05 s | 0.03x | 0.20x |
| 6 | U1+T(k=0) | 68 | 5.647e-05 ± 4.2e-05 s | 4.632e-05 ± 3.4e-05 s | 8.078e-05 ± 7.1e-06 s | 0.82x | 1.43x |
| 6 | U1+T(k=0)+P(p=1) | 38 | 8.739e-05 ± 3.8e-05 s | 8.692e-05 ± 4.1e-05 s | 0.000123 ± 9.8e-06 s | 0.99x | 1.41x |
| 8 | U1 | 4900 | 0.001184 ± 0.0011 s | 5.982e-06 ± 1e-05 s | 0.0001233 ± 6.8e-06 s | 0.01x | 0.10x |
| 8 | U1+T(k=0) | 618 | 0.0003368 ± 6e-05 s | 0.0001797 ± 0.0003 s | 0.000443 ± 1.4e-05 s | 0.53x | 1.32x |
| 8 | U1+T(k=0)+P(p=1) | 318 | 0.0005277 ± 0.00011 s | 0.0002136 ± 4e-05 s | 0.0007614 ± 1e-05 s | 0.40x | 1.44x |
| 10 | U1 | 63504 | 0.003069 ± 0.0017 s | 6.134e-06 ± 1.1e-05 s | 0.0009007 ± 4.2e-05 s | 0.00x | 0.29x |
| 10 | U1+T(k=0) | 6352 | 0.004332 ± 0.00042 s | 0.0003051 ± 5.1e-05 s | 0.00562 ± 3.2e-05 s | 0.07x | 1.30x |
| 10 | U1+T(k=0)+P(p=1) | 3212 | 0.005451 ± 0.0006 s | 0.0006684 ± 4.7e-05 s | 0.009735 ± 2.5e-05 s | 0.12x | 1.79x |
| 12 | U1 | 853776 | 0.02339 ± 0.014 s | 9.124e-06 ± 1.3e-05 s | 0.01237 ± 0.0002 s | 0.00x | 0.53x |
| 12 | U1+T(k=0) | 71188 | 0.04085 ± 0.0037 s | 0.001552 ± 5.8e-05 s | 0.07863 ± 0.00022 s | 0.04x | 1.92x |
| 12 | U1+T(k=0)+P(p=1) | 35694 | 0.06801 ± 0.0033 s | 0.003927 ± 0.00014 s | 0.1349 ± 0.00037 s | 0.06x | 1.98x |

### Spinful fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 1.105e-06 ± 4.8e-09 s | N/A (no decoupled API) | 1.822e-06 ± 1.1e-08 s |

### Boson (d=3) — basis construction

```@example benchmarks
plot_construction("boson", "Boson (d=3)")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 6 | U1 | 141 | 5.468e-05 ± 7.7e-05 s | 4.863e-06 ± 7.5e-06 s | 3.945e-05 ± 1.4e-05 s | 0.09x | 0.72x |
| 6 | U1+T(k=0) | 26 | 8.788e-05 ± 5.7e-05 s | 4.872e-05 ± 2.8e-05 s | 5.042e-05 ± 8.9e-06 s | 0.55x | 0.57x |
| 6 | U1+T(k=0)+P(p=1) | 18 | 5.286e-05 ± 4e-05 s | 8.847e-05 ± 3.6e-05 s | 5.438e-05 ± 8.9e-06 s | 1.67x | 1.03x |
| 8 | U1 | 1107 | 6.605e-05 ± 4e-05 s | 9.259e-06 ± 9e-06 s | 6.385e-05 ± 6.6e-06 s | 0.14x | 0.97x |
| 8 | U1+T(k=0) | 142 | 0.0001166 ± 3.5e-05 s | 0.0001894 ± 3e-05 s | 0.0001689 ± 8.4e-06 s | 1.62x | 1.45x |
| 8 | U1+T(k=0)+P(p=1) | 84 | 0.0002149 ± 6e-05 s | 0.000285 ± 3.4e-05 s | 0.0001987 ± 1.4e-05 s | 1.33x | 0.92x |
| 10 | U1 | 8953 | 0.0006881 ± 0.00069 s | 1.052e-05 ± 9.1e-06 s | 0.000246 ± 1.3e-05 s | 0.02x | 0.36x |
| 10 | U1+T(k=0) | 902 | 0.0005943 ± 4.5e-05 s | 0.00147 ± 3.8e-05 s | 0.001262 ± 1.6e-05 s | 2.47x | 2.12x |
| 10 | U1+T(k=0)+P(p=1) | 486 | 0.001218 ± 0.0005 s | 0.001857 ± 4e-05 s | 0.001471 ± 1.7e-05 s | 1.52x | 1.21x |
| 12 | U1 | 73789 | 0.002818 ± 0.00071 s | 2.41e-05 ± 9.5e-06 s | 0.001833 ± 4.2e-05 s | 0.01x | 0.65x |
| 12 | U1+T(k=0) | 6166 | 0.00536 ± 0.00087 s | 0.0139 ± 0.0003 s | 0.0119 ± 3.3e-05 s | 2.59x | 2.22x |
| 12 | U1+T(k=0)+P(p=1) | 3179 | 0.007803 ± 0.00028 s | 0.01654 ± 0.00016 s | 0.01425 ± 0.00071 s | 2.12x | 1.83x |

### Boson (d=3) — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 1.425e-06 ± 3.6e-09 s | N/A (no decoupled API) | 2.779e-07 ± 6.3e-10 s |

