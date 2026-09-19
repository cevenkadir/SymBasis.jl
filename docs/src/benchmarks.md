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
| 8 | U1 | 70 | 5.634e-05 ± 9.6e-05 s | 4.008e-06 ± 6.9e-06 s | 2.513e-05 ± 1.3e-05 s | 0.07x | 0.45x |
| 8 | U1+T(k=0) | 10 | 6.585e-05 ± 9.3e-05 s | 4.929e-05 ± 3.4e-05 s | 3.66e-05 ± 1.9e-05 s | 0.75x | 0.56x |
| 8 | U1+T(k=0)+P(p=1) | 8 | 3.607e-05 ± 2.1e-05 s | 0.00106 ± 0.0028 s | 3.368e-05 ± 9.2e-06 s | 29.38x | 0.93x |
| 10 | U1 | 252 | 9.768e-05 ± 9.3e-05 s | 4.669e-06 ± 6.6e-06 s | 2.267e-05 ± 4.5e-06 s | 0.05x | 0.23x |
| 10 | U1+T(k=0) | 26 | 6.098e-05 ± 6.4e-05 s | 9.102e-05 ± 2.7e-05 s | 4.069e-05 ± 7e-06 s | 1.49x | 0.67x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 6.093e-05 ± 3.8e-05 s | 0.0001944 ± 4.1e-05 s | 4.59e-05 ± 4.5e-06 s | 3.19x | 0.75x |
| 12 | U1 | 924 | 6.842e-05 ± 4.6e-05 s | 4.922e-06 ± 7.3e-06 s | 3.348e-05 ± 1.1e-05 s | 0.07x | 0.49x |
| 12 | U1+T(k=0) | 80 | 6.971e-05 ± 2.9e-05 s | 0.0002533 ± 2.7e-05 s | 7.841e-05 ± 7.5e-06 s | 3.63x | 1.12x |
| 12 | U1+T(k=0)+P(p=1) | 50 | 8.665e-05 ± 3e-05 s | 0.0004092 ± 3.2e-05 s | 0.0001099 ± 8.1e-06 s | 4.72x | 1.27x |
| 14 | U1 | 3432 | 8.823e-05 ± 2.8e-05 s | 5.377e-06 ± 6.7e-06 s | 5.469e-05 ± 4.8e-06 s | 0.06x | 0.62x |
| 14 | U1+T(k=0) | 246 | 0.000311 ± 0.00036 s | 0.0008782 ± 2.4e-05 s | 0.0002174 ± 1e-05 s | 2.82x | 0.70x |
| 14 | U1+T(k=0)+P(p=1) | 133 | 0.0001682 ± 2.9e-05 s | 0.001166 ± 6.4e-05 s | 0.0003363 ± 8.6e-06 s | 6.93x | 2.00x |
| 16 | U1 | 12870 | 0.0003493 ± 6.1e-05 s | 7.464e-06 ± 8e-06 s | 0.000144 ± 5.9e-06 s | 0.02x | 0.41x |
| 16 | U1+T(k=0) | 810 | 0.0003796 ± 5.9e-05 s | 0.003488 ± 0.00036 s | 0.0007682 ± 1.2e-05 s | 9.19x | 2.02x |
| 16 | U1+T(k=0)+P(p=1) | 440 | 0.0005883 ± 0.0001 s | 0.004394 ± 0.00097 s | 0.001204 ± 1e-05 s | 7.47x | 2.05x |

### Spin-1/2 — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 1.357e-07 ± 5.3e-09 s | N/A (no decoupled API) | 2.115e-07 ± 3.5e-09 s |

### Spinless fermion — basis construction

```@example benchmarks
plot_construction("fermion", "Spinless fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 8 | U1 | 70 | 0.000133 ± 0.00017 s | 3.751e-06 ± 6.3e-06 s | 3.295e-05 ± 1.1e-05 s | 0.03x | 0.25x |
| 8 | U1+T(k=0) | 9 | 3.739e-05 ± 2.5e-05 s | 5.011e-05 ± 2.8e-05 s | 3.884e-05 ± 6.3e-06 s | 1.34x | 1.04x |
| 8 | U1+T(k=0)+P(p=1) | 6 | 3.837e-05 ± 2.1e-05 s | 0.0001271 ± 7.6e-05 s | 4.671e-05 ± 9.5e-06 s | 3.31x | 1.22x |
| 10 | U1 | 252 | 3.099e-05 ± 2.8e-05 s | 4.354e-06 ± 6.7e-06 s | 3.122e-05 ± 4e-06 s | 0.14x | 1.01x |
| 10 | U1+T(k=0) | 26 | 4.308e-05 ± 3e-05 s | 0.0001219 ± 7e-05 s | 5.005e-05 ± 5e-06 s | 2.83x | 1.16x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 6.29e-05 ± 2.9e-05 s | 0.0001955 ± 3.2e-05 s | 5.934e-05 ± 7.4e-06 s | 3.11x | 0.94x |
| 12 | U1 | 924 | 4.264e-05 ± 2.9e-05 s | 4.831e-06 ± 7e-06 s | 4.064e-05 ± 5.9e-06 s | 0.11x | 0.95x |
| 12 | U1+T(k=0) | 76 | 7.123e-05 ± 2.7e-05 s | 0.0002988 ± 7.2e-05 s | 8.865e-05 ± 1.2e-05 s | 4.20x | 1.24x |
| 12 | U1+T(k=0)+P(p=1) | 33 | 8.451e-05 ± 2.7e-05 s | 0.0004328 ± 2.5e-05 s | 0.0001113 ± 7.4e-06 s | 5.12x | 1.32x |
| 14 | U1 | 3432 | 0.0001576 ± 0.00024 s | 5.285e-06 ± 7e-06 s | 6.169e-05 ± 1.9e-05 s | 0.03x | 0.39x |
| 14 | U1+T(k=0) | 246 | 0.0002333 ± 0.00024 s | 0.0009606 ± 5.9e-05 s | 0.0002266 ± 1.3e-05 s | 4.12x | 0.97x |
| 14 | U1+T(k=0)+P(p=1) | 113 | 0.000247 ± 0.00026 s | 0.001216 ± 5.2e-05 s | 0.0003366 ± 8.4e-06 s | 4.92x | 1.36x |
| 16 | U1 | 12870 | 0.0006038 ± 0.00064 s | 7.618e-06 ± 8.4e-06 s | 0.0001505 ± 4e-06 s | 0.01x | 0.25x |
| 16 | U1+T(k=0) | 809 | 0.0006814 ± 0.00013 s | 0.003833 ± 8.5e-05 s | 0.0007856 ± 1.4e-05 s | 5.63x | 1.15x |
| 16 | U1+T(k=0)+P(p=1) | 422 | 0.0008007 ± 0.00058 s | 0.004545 ± 0.00015 s | 0.001206 ± 6.9e-06 s | 5.68x | 1.51x |

### Spinless fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 1.692e-07 ± 4.2e-09 s | N/A (no decoupled API) | 2.072e-06 ± 2e-08 s |

### Spinful fermion — basis construction

```@example benchmarks
plot_construction("spinful_fermion", "Spinful fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 4 | U1 | 36 | 4.647e-05 ± 4.8e-05 s | 5.039e-06 ± 8.4e-06 s | 3.66e-05 ± 1.1e-05 s | 0.11x | 0.79x |
| 4 | U1+T(k=0) | 10 | 0.0001866 ± 0.00029 s | 3.274e-05 ± 3.1e-05 s | 4.44e-05 ± 1e-05 s | 0.18x | 0.24x |
| 4 | U1+T(k=0)+P(p=1) | 6 | 3.954e-05 ± 3.3e-05 s | 5.424e-05 ± 3.5e-05 s | 4.926e-05 ± 8e-06 s | 1.37x | 1.25x |
| 6 | U1 | 400 | 4.358e-05 ± 3.1e-05 s | 5.455e-06 ± 9.3e-06 s | 4.344e-05 ± 8.7e-06 s | 0.13x | 1.00x |
| 6 | U1+T(k=0) | 68 | 6.836e-05 ± 4.2e-05 s | 5.101e-05 ± 3.2e-05 s | 8.505e-05 ± 6.2e-06 s | 0.75x | 1.24x |
| 6 | U1+T(k=0)+P(p=1) | 38 | 0.0002198 ± 0.00031 s | 9.763e-05 ± 3.9e-05 s | 0.0001257 ± 1.4e-05 s | 0.44x | 0.57x |
| 8 | U1 | 4900 | 0.0002486 ± 5.2e-05 s | 5.999e-06 ± 9.7e-06 s | 0.0001135 ± 5.8e-06 s | 0.02x | 0.46x |
| 8 | U1+T(k=0) | 618 | 0.0009251 ± 0.0011 s | 0.0001132 ± 3.9e-05 s | 0.0005614 ± 2.2e-05 s | 0.12x | 0.61x |
| 8 | U1+T(k=0)+P(p=1) | 318 | 0.0006266 ± 0.00023 s | 0.000233 ± 4.7e-05 s | 0.0009426 ± 8e-06 s | 0.37x | 1.50x |
| 10 | U1 | 63504 | 0.002881 ± 0.00073 s | 6.066e-06 ± 9e-06 s | 0.001086 ± 3.7e-05 s | 0.00x | 0.38x |
| 10 | U1+T(k=0) | 6352 | 0.004653 ± 0.00068 s | 0.0003315 ± 5.1e-05 s | 0.007119 ± 7.6e-05 s | 0.07x | 1.53x |
| 10 | U1+T(k=0)+P(p=1) | 3212 | 0.006377 ± 0.00065 s | 0.0007343 ± 6.7e-05 s | 0.01209 ± 0.00018 s | 0.12x | 1.90x |
| 12 | U1 | 853776 | 0.02656 ± 0.0097 s | 6.928e-06 ± 9.3e-06 s | 0.01566 ± 0.00024 s | 0.00x | 0.59x |
| 12 | U1+T(k=0) | 71188 | 0.05691 ± 0.0068 s | 0.002314 ± 6e-05 s | 0.09915 ± 0.00041 s | 0.04x | 1.74x |
| 12 | U1+T(k=0)+P(p=1) | 35694 | 0.08879 ± 0.0079 s | 0.005483 ± 0.00014 s | 0.1711 ± 0.00076 s | 0.06x | 1.93x |

### Spinful fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 1.601e-06 ± 2.1e-08 s | N/A (no decoupled API) | 2.513e-06 ± 2.9e-08 s |

### Boson (d=3) — basis construction

```@example benchmarks
plot_construction("boson", "Boson (d=3)")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 6 | U1 | 141 | 0.0001484 ± 0.00015 s | 4.467e-06 ± 6.7e-06 s | 4.388e-05 ± 1.3e-05 s | 0.03x | 0.30x |
| 6 | U1+T(k=0) | 26 | 0.0002043 ± 0.00048 s | 5.762e-05 ± 3.2e-05 s | 5.837e-05 ± 7.5e-06 s | 0.28x | 0.29x |
| 6 | U1+T(k=0)+P(p=1) | 18 | 4.988e-05 ± 3.2e-05 s | 9.682e-05 ± 3.1e-05 s | 7.409e-05 ± 1.6e-05 s | 1.94x | 1.49x |
| 8 | U1 | 1107 | 7.226e-05 ± 3.5e-05 s | 6.668e-06 ± 6.8e-06 s | 8.097e-05 ± 7.3e-06 s | 0.09x | 1.12x |
| 8 | U1+T(k=0) | 142 | 0.0001416 ± 7.5e-05 s | 0.0002845 ± 0.00017 s | 0.0002034 ± 2.6e-05 s | 2.01x | 1.44x |
| 8 | U1+T(k=0)+P(p=1) | 84 | 0.0006746 ± 0.00091 s | 0.0004615 ± 0.00038 s | 0.0002466 ± 9.5e-06 s | 0.68x | 0.37x |
| 10 | U1 | 8953 | 0.0006291 ± 0.00047 s | 1.348e-05 ± 9e-06 s | 0.0003256 ± 1.2e-05 s | 0.02x | 0.52x |
| 10 | U1+T(k=0) | 902 | 0.0007406 ± 7.7e-05 s | 0.00192 ± 6.5e-05 s | 0.001615 ± 2.9e-05 s | 2.59x | 2.18x |
| 10 | U1+T(k=0)+P(p=1) | 486 | 0.001384 ± 0.00022 s | 0.002358 ± 6.6e-05 s | 0.00211 ± 1.5e-05 s | 1.70x | 1.52x |
| 12 | U1 | 73789 | 0.003407 ± 0.0013 s | 3.509e-05 ± 9.7e-06 s | 0.002366 ± 4.9e-05 s | 0.01x | 0.69x |
| 12 | U1+T(k=0) | 6166 | 0.006583 ± 0.00097 s | 0.01822 ± 0.00057 s | 0.01567 ± 0.00015 s | 2.77x | 2.38x |
| 12 | U1+T(k=0)+P(p=1) | 3179 | 0.01098 ± 0.0012 s | 0.02024 ± 0.0005 s | 0.02062 ± 0.00027 s | 1.84x | 1.88x |

### Boson (d=3) — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 1.963e-06 ± 1.9e-08 s | N/A (no decoupled API) | 3.847e-07 ± 5.9e-09 s |

