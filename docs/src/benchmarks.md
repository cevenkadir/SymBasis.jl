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
| 8 | U1 | 70 | 5.526e-06 ± 9e-06 s | 4.693e-06 ± 8.2e-06 s | 1.638e-05 ± 9e-06 s | 0.85x | 2.96x |
| 8 | U1+T(k=0) | 10 | 9.884e-06 ± 1.5e-05 s | 3.868e-05 ± 3.7e-05 s | 1.836e-05 ± 5.8e-06 s | 3.91x | 1.86x |
| 8 | U1+T(k=0)+P(p=1) | 8 | 4.332e-05 ± 5.4e-05 s | 8.09e-05 ± 3.5e-05 s | 2.05e-05 ± 6.3e-06 s | 1.87x | 0.47x |
| 10 | U1 | 252 | 8.198e-06 ± 1.1e-05 s | 3.223e-06 ± 4e-06 s | 1.35e-05 ± 2.5e-06 s | 0.39x | 1.65x |
| 10 | U1+T(k=0) | 26 | 2.734e-05 ± 2.7e-05 s | 6.162e-05 ± 2.4e-05 s | 2.298e-05 ± 2.6e-06 s | 2.25x | 0.84x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 0.0001351 ± 4e-06 s | 0.0001335 ± 3.4e-05 s | 2.786e-05 ± 2.6e-06 s | 0.99x | 0.21x |
| 12 | U1 | 924 | 1.649e-05 ± 1.3e-05 s | 4.954e-06 ± 8.1e-06 s | 1.758e-05 ± 2.1e-06 s | 0.30x | 1.07x |
| 12 | U1+T(k=0) | 80 | 4.492e-05 ± 2.9e-05 s | 0.0001701 ± 3e-05 s | 4.739e-05 ± 4.2e-06 s | 3.79x | 1.06x |
| 12 | U1+T(k=0)+P(p=1) | 50 | 0.0002866 ± 0.00039 s | 0.0002904 ± 2.5e-05 s | 6.311e-05 ± 5.7e-06 s | 1.01x | 0.22x |
| 14 | U1 | 3432 | 7.789e-05 ± 4.8e-05 s | 4.388e-06 ± 5.9e-06 s | 2.989e-05 ± 2.2e-06 s | 0.06x | 0.38x |
| 14 | U1+T(k=0) | 246 | 8.396e-05 ± 2.7e-05 s | 0.0005432 ± 2.2e-05 s | 0.0001343 ± 4.3e-06 s | 6.47x | 1.60x |
| 14 | U1+T(k=0)+P(p=1) | 133 | 0.0001127 ± 2.7e-05 s | 0.0007849 ± 3.8e-05 s | 0.0001878 ± 5.3e-06 s | 6.96x | 1.67x |
| 16 | U1 | 12870 | 0.0002221 ± 2e-05 s | 8.152e-06 ± 1.6e-05 s | 7.748e-05 ± 8.2e-06 s | 0.04x | 0.35x |
| 16 | U1+T(k=0) | 810 | 0.0002486 ± 5.6e-05 s | 0.002187 ± 4.4e-05 s | 0.0004684 ± 7.8e-06 s | 8.80x | 1.88x |
| 16 | U1+T(k=0)+P(p=1) | 440 | 0.0005538 ± 0.00047 s | 0.002731 ± 4.4e-05 s | 0.0006804 ± 2.5e-05 s | 4.93x | 1.23x |

### Spin-1/2 — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 8.383e-08 ± 4.7e-09 s | N/A (no decoupled API) | 2.143e-07 ± 3.2e-08 s |

### Spinless fermion — basis construction

```@example benchmarks
plot_construction("fermion", "Spinless fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 8 | U1 | 70 | 5.44e-06 ± 8.5e-06 s | 4.533e-06 ± 8e-06 s | 2.099e-05 ± 7.2e-06 s | 0.83x | 3.86x |
| 8 | U1+T(k=0) | 9 | 1.088e-05 ± 1.7e-05 s | 3.763e-05 ± 2.8e-05 s | 2.485e-05 ± 3.7e-06 s | 3.46x | 2.28x |
| 8 | U1+T(k=0)+P(p=1) | 6 | 4.597e-05 ± 7.3e-05 s | 8.493e-05 ± 3.3e-05 s | 2.838e-05 ± 4e-06 s | 1.85x | 0.62x |
| 10 | U1 | 252 | 9.55e-06 ± 1.5e-05 s | 3.512e-06 ± 4.7e-06 s | 2.048e-05 ± 2.1e-06 s | 0.37x | 2.14x |
| 10 | U1+T(k=0) | 26 | 2.941e-05 ± 2.5e-05 s | 6.842e-05 ± 2.2e-05 s | 3.61e-05 ± 6.7e-06 s | 2.33x | 1.23x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 3.796e-05 ± 2.5e-05 s | 0.0001455 ± 2.6e-05 s | 4.506e-05 ± 8.7e-06 s | 3.83x | 1.19x |
| 12 | U1 | 924 | 1.589e-05 ± 1.1e-05 s | 4.141e-06 ± 5.4e-06 s | 3.08e-05 ± 6.8e-06 s | 0.26x | 1.94x |
| 12 | U1+T(k=0) | 76 | 4.585e-05 ± 2.6e-05 s | 0.0001875 ± 2.9e-05 s | 6.977e-05 ± 4e-06 s | 4.09x | 1.52x |
| 12 | U1+T(k=0)+P(p=1) | 33 | 5.596e-05 ± 3.3e-05 s | 0.0003055 ± 2.1e-05 s | 9.239e-05 ± 3.3e-06 s | 5.46x | 1.65x |
| 14 | U1 | 3432 | 7.369e-05 ± 4.9e-05 s | 4.3e-06 ± 5.2e-06 s | 4.709e-05 ± 5.3e-06 s | 0.06x | 0.64x |
| 14 | U1+T(k=0) | 246 | 0.0001787 ± 0.00025 s | 0.0006569 ± 2.7e-05 s | 0.0001587 ± 3.3e-05 s | 3.68x | 0.89x |
| 14 | U1+T(k=0)+P(p=1) | 113 | 0.0001222 ± 3.5e-05 s | 0.0008807 ± 4.8e-05 s | 0.0001881 ± 4e-06 s | 7.21x | 1.54x |
| 16 | U1 | 12870 | 0.0003132 ± 0.00021 s | 5.221e-06 ± 6.3e-06 s | 7.771e-05 ± 6e-06 s | 0.02x | 0.25x |
| 16 | U1+T(k=0) | 809 | 0.0003212 ± 8.1e-05 s | 0.00262 ± 4.5e-05 s | 0.0004685 ± 5.7e-06 s | 8.16x | 1.46x |
| 16 | U1+T(k=0)+P(p=1) | 422 | 0.0005151 ± 0.00039 s | 0.003154 ± 4.6e-05 s | 0.0006691 ± 3.5e-06 s | 6.12x | 1.30x |

### Spinless fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 1.219e-07 ± 8.2e-10 s | N/A (no decoupled API) | 1.209e-06 ± 4.4e-09 s |

### Spinful fermion — basis construction

```@example benchmarks
plot_construction("spinful_fermion", "Spinful fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 4 | U1 | 36 | 6.403e-06 ± 1e-05 s | 7.577e-06 ± 1.1e-05 s | 2.453e-05 ± 8.7e-06 s | 1.18x | 3.83x |
| 4 | U1+T(k=0) | 10 | 8.867e-06 ± 1.3e-05 s | 2.932e-05 ± 3.6e-05 s | 2.945e-05 ± 5.8e-06 s | 3.31x | 3.32x |
| 4 | U1+T(k=0)+P(p=1) | 6 | 1.01e-05 ± 1.5e-05 s | 4.9e-05 ± 4e-05 s | 3.194e-05 ± 4.6e-06 s | 4.85x | 3.16x |
| 6 | U1 | 400 | 1.353e-05 ± 1.2e-05 s | 4.579e-06 ± 7.9e-06 s | 2.897e-05 ± 4.3e-06 s | 0.34x | 2.14x |
| 6 | U1+T(k=0) | 68 | 3.828e-05 ± 3e-05 s | 3.539e-05 ± 2.6e-05 s | 5.816e-05 ± 2.1e-06 s | 0.92x | 1.52x |
| 6 | U1+T(k=0)+P(p=1) | 38 | 6.165e-05 ± 3.4e-05 s | 8.008e-05 ± 6.6e-05 s | 8.929e-05 ± 4.3e-06 s | 1.30x | 1.45x |
| 8 | U1 | 4900 | 0.0001889 ± 0.00016 s | 4.742e-06 ± 7.5e-06 s | 9.599e-05 ± 3.6e-06 s | 0.03x | 0.51x |
| 8 | U1+T(k=0) | 618 | 0.0003166 ± 0.00021 s | 7.131e-05 ± 3.1e-05 s | 0.000344 ± 7.6e-05 s | 0.23x | 1.09x |
| 8 | U1+T(k=0)+P(p=1) | 318 | 0.0004905 ± 0.00042 s | 0.0001586 ± 3.4e-05 s | 0.000528 ± 4.1e-06 s | 0.32x | 1.08x |
| 10 | U1 | 63504 | 0.001997 ± 0.001 s | 5.122e-06 ± 8.7e-06 s | 0.0005775 ± 1.3e-05 s | 0.00x | 0.29x |
| 10 | U1+T(k=0) | 6352 | 0.002889 ± 0.00078 s | 0.0005896 ± 0.0012 s | 0.003852 ± 1.5e-05 s | 0.20x | 1.33x |
| 10 | U1+T(k=0)+P(p=1) | 3212 | 0.004461 ± 0.00087 s | 0.0004812 ± 4.2e-05 s | 0.006735 ± 7.7e-05 s | 0.11x | 1.51x |
| 12 | U1 | 853776 | 0.01337 ± 0.0073 s | 5.92e-06 ± 9.9e-06 s | 0.008755 ± 7.7e-05 s | 0.00x | 0.66x |
| 12 | U1+T(k=0) | 71188 | 0.03195 ± 0.0067 s | 0.001049 ± 5.3e-05 s | 0.05397 ± 0.00011 s | 0.03x | 1.69x |
| 12 | U1+T(k=0)+P(p=1) | 35694 | 0.04896 ± 0.0062 s | 0.002687 ± 7.3e-05 s | 0.0924 ± 0.00088 s | 0.05x | 1.89x |

### Spinful fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 9.764e-07 ± 1.1e-08 s | N/A (no decoupled API) | 1.435e-06 ± 5.4e-08 s |

### Boson (d=3) — basis construction

```@example benchmarks
plot_construction("boson", "Boson (d=3)")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 6 | U1 | 141 | 7.775e-06 ± 1e-05 s | 5.241e-06 ± 8.4e-06 s | 2.756e-05 ± 8.9e-06 s | 0.67x | 3.55x |
| 6 | U1+T(k=0) | 26 | 1.685e-05 ± 1.7e-05 s | 4.325e-05 ± 3.9e-05 s | 3.527e-05 ± 4.6e-06 s | 2.57x | 2.09x |
| 6 | U1+T(k=0)+P(p=1) | 18 | 4.671e-05 ± 6.9e-05 s | 0.0001511 ± 0.00028 s | 4.223e-05 ± 8.9e-06 s | 3.24x | 0.90x |
| 8 | U1 | 1107 | 0.0002834 ± 9.8e-05 s | 6.087e-06 ± 8.3e-06 s | 4.931e-05 ± 4.4e-06 s | 0.02x | 0.17x |
| 8 | U1+T(k=0) | 142 | 0.0003524 ± 0.00049 s | 0.0001644 ± 3.2e-05 s | 0.0001429 ± 3.5e-06 s | 0.47x | 0.41x |
| 8 | U1+T(k=0)+P(p=1) | 84 | 0.0007932 ± 0.00078 s | 0.0002349 ± 2.8e-05 s | 0.0001773 ± 4e-06 s | 0.30x | 0.22x |
| 10 | U1 | 8953 | 0.0007194 ± 0.00076 s | 8.965e-06 ± 8.2e-06 s | 0.0002032 ± 1.8e-05 s | 0.01x | 0.28x |
| 10 | U1+T(k=0) | 902 | 0.0006361 ± 0.00053 s | 0.001231 ± 3.1e-05 s | 0.001149 ± 6.6e-06 s | 1.93x | 1.81x |
| 10 | U1+T(k=0)+P(p=1) | 486 | 0.001073 ± 0.00049 s | 0.00157 ± 0.00014 s | 0.001366 ± 7.4e-06 s | 1.46x | 1.27x |
| 12 | U1 | 73789 | 0.002437 ± 0.0012 s | 2.371e-05 ± 1e-05 s | 0.001525 ± 1.1e-05 s | 0.01x | 0.63x |
| 12 | U1+T(k=0) | 6166 | 0.003895 ± 0.00051 s | 0.01222 ± 0.0013 s | 0.0111 ± 4.1e-05 s | 3.14x | 2.85x |
| 12 | U1+T(k=0)+P(p=1) | 3179 | 0.006209 ± 0.00067 s | 0.01413 ± 0.0027 s | 0.01323 ± 4.9e-05 s | 2.28x | 2.13x |

### Boson (d=3) — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 1.274e-06 ± 4.7e-09 s | N/A (no decoupled API) | 2.408e-07 ± 1.2e-09 s |

