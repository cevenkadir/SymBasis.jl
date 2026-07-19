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
| 8 | U1 | 70 | 3.15e-05 ± 2.9e-05 s | 3.083e-06 ± 4.6e-06 s | 2.491e-05 ± 1.2e-05 s | 0.10x | 0.79x |
| 8 | U1+T(k=0) | 10 | 4.865e-05 ± 5.4e-05 s | 0.0001932 ± 5e-05 s | 2.638e-05 ± 7.1e-06 s | 3.97x | 0.54x |
| 8 | U1+T(k=0)+P(p=1) | 8 | 7.547e-05 ± 5.5e-05 s | 0.0002385 ± 2.2e-05 s | 2.901e-05 ± 5.1e-06 s | 3.16x | 0.38x |
| 10 | U1 | 252 | 5.34e-05 ± 3.4e-05 s | 2.2e-06 ± 3.5e-06 s | 3.138e-05 ± 2.7e-05 s | 0.04x | 0.59x |
| 10 | U1+T(k=0) | 26 | 6.739e-05 ± 2.4e-05 s | 0.0002434 ± 4e-05 s | 2.962e-05 ± 4.8e-06 s | 3.61x | 0.44x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 9.635e-05 ± 4.3e-05 s | 0.0002895 ± 3.1e-05 s | 3.727e-05 ± 3.5e-06 s | 3.00x | 0.39x |
| 12 | U1 | 924 | 6.844e-05 ± 4.9e-05 s | 2.883e-06 ± 3.5e-06 s | 2.842e-05 ± 2.2e-06 s | 0.04x | 0.42x |
| 12 | U1+T(k=0) | 80 | 9.853e-05 ± 4.2e-05 s | 0.0002653 ± 2.2e-05 s | 4.75e-05 ± 2.3e-06 s | 2.69x | 0.48x |
| 12 | U1+T(k=0)+P(p=1) | 50 | 0.0001407 ± 2.5e-05 s | 0.0003843 ± 3.3e-05 s | 7.439e-05 ± 2.8e-06 s | 2.73x | 0.53x |
| 14 | U1 | 3432 | 0.0001368 ± 3.9e-05 s | 3.967e-06 ± 3.8e-06 s | 4.784e-05 ± 2.2e-06 s | 0.03x | 0.35x |
| 14 | U1+T(k=0) | 246 | 0.0002018 ± 3.1e-05 s | 0.0005313 ± 1.3e-05 s | 0.0001129 ± 3e-06 s | 2.63x | 0.56x |
| 14 | U1+T(k=0)+P(p=1) | 133 | 0.000242 ± 2.5e-05 s | 0.0007871 ± 2.4e-05 s | 0.0002149 ± 9.7e-06 s | 3.25x | 0.89x |
| 16 | U1 | 12870 | 0.0002776 ± 3.5e-05 s | 5.3e-06 ± 5.2e-06 s | 0.0001226 ± 3e-06 s | 0.02x | 0.44x |
| 16 | U1+T(k=0) | 810 | 0.0003748 ± 2.1e-05 s | 0.001842 ± 6.2e-05 s | 0.0003584 ± 2.2e-06 s | 4.92x | 0.96x |
| 16 | U1+T(k=0)+P(p=1) | 440 | 0.0007599 ± 3.5e-05 s | 0.002435 ± 7e-05 s | 0.0007374 ± 1.4e-05 s | 3.20x | 0.97x |

### Spin-1/2 — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 2.6e-07 ± 3e-09 s | N/A (no decoupled API) | 1.027e-06 ± 2.6e-09 s |

### Spinless fermion — basis construction

```@example benchmarks
plot_construction("fermion", "Spinless fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 8 | U1 | 70 | 5.965e-05 ± 4.9e-05 s | 2.533e-06 ± 4.3e-06 s | 2.316e-05 ± 7.1e-06 s | 0.04x | 0.39x |
| 8 | U1+T(k=0) | 9 | 5.757e-05 ± 3.8e-05 s | 0.0001796 ± 2.2e-05 s | 2.522e-05 ± 4.1e-06 s | 3.12x | 0.44x |
| 8 | U1+T(k=0)+P(p=1) | 6 | 9.283e-05 ± 4.6e-05 s | 0.0002316 ± 2.4e-05 s | 2.824e-05 ± 2.9e-06 s | 2.49x | 0.30x |
| 10 | U1 | 252 | 4.53e-05 ± 3.1e-05 s | 2.279e-06 ± 3.6e-06 s | 2.173e-05 ± 2e-06 s | 0.05x | 0.48x |
| 10 | U1+T(k=0) | 26 | 9e-05 ± 4e-05 s | 0.0002364 ± 2.7e-05 s | 2.904e-05 ± 2e-06 s | 2.63x | 0.32x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 0.0001352 ± 4.9e-05 s | 0.0004383 ± 3.5e-05 s | 3.659e-05 ± 2.7e-06 s | 3.24x | 0.27x |
| 12 | U1 | 924 | 0.0002712 ± 8.9e-05 s | 3.683e-06 ± 4.3e-06 s | 2.869e-05 ± 2.3e-06 s | 0.01x | 0.11x |
| 12 | U1+T(k=0) | 76 | 0.0002229 ± 5.5e-05 s | 0.0004052 ± 4.8e-05 s | 4.897e-05 ± 5.2e-06 s | 1.82x | 0.22x |
| 12 | U1+T(k=0)+P(p=1) | 33 | 0.0003748 ± 6.3e-05 s | 0.0006178 ± 4e-05 s | 7.277e-05 ± 2.3e-06 s | 1.65x | 0.19x |
| 14 | U1 | 3432 | 0.0001481 ± 6e-05 s | 4.842e-06 ± 4.3e-06 s | 4.836e-05 ± 2.2e-06 s | 0.03x | 0.33x |
| 14 | U1+T(k=0) | 246 | 0.0006932 ± 0.00025 s | 0.0009591 ± 3.8e-05 s | 0.0001135 ± 6.6e-06 s | 1.38x | 0.16x |
| 14 | U1+T(k=0)+P(p=1) | 113 | 0.0009614 ± 5.8e-05 s | 0.001425 ± 9.3e-05 s | 0.0002103 ± 8.1e-06 s | 1.48x | 0.22x |
| 16 | U1 | 12870 | 0.0003997 ± 3.3e-05 s | 7.579e-06 ± 4e-06 s | 0.0001294 ± 1.2e-05 s | 0.02x | 0.32x |
| 16 | U1+T(k=0) | 809 | 0.001777 ± 3.8e-05 s | 0.003265 ± 0.00028 s | 0.0003633 ± 1.2e-05 s | 1.84x | 0.20x |
| 16 | U1+T(k=0)+P(p=1) | 422 | 0.003715 ± 4.2e-05 s | 0.004352 ± 7.9e-05 s | 0.0007365 ± 2e-05 s | 1.17x | 0.20x |

### Spinless fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 2.077e-06 ± 6.5e-09 s | N/A (no decoupled API) | 6.655e-06 ± 8e-09 s |

### Boson (d=3) — basis construction

```@example benchmarks
plot_construction("boson", "Boson (d=3)")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 6 | U1 | 141 | 7.182e-05 ± 3.1e-05 s | 2.963e-06 ± 4.1e-06 s | 3.01e-05 ± 9.3e-06 s | 0.04x | 0.42x |
| 6 | U1+T(k=0) | 26 | 0.0001266 ± 2.9e-05 s | 0.0001767 ± 2.3e-05 s | 3.833e-05 ± 5.9e-06 s | 1.40x | 0.30x |
| 6 | U1+T(k=0)+P(p=1) | 18 | 0.0001965 ± 4.3e-05 s | 0.0002398 ± 2.4e-05 s | 4.793e-05 ± 7.5e-06 s | 1.22x | 0.24x |
| 8 | U1 | 1107 | 0.0001766 ± 2.6e-05 s | 4.896e-06 ± 4e-06 s | 5.632e-05 ± 1.1e-05 s | 0.03x | 0.32x |
| 8 | U1+T(k=0) | 142 | 0.0003943 ± 5.1e-05 s | 0.0002462 ± 2.7e-05 s | 0.0001519 ± 1e-05 s | 0.62x | 0.39x |
| 8 | U1+T(k=0)+P(p=1) | 84 | 0.0006875 ± 5.7e-05 s | 0.0003115 ± 3.1e-05 s | 0.0002132 ± 4.2e-06 s | 0.45x | 0.31x |
| 10 | U1 | 8953 | 0.0009145 ± 3.6e-05 s | 1.058e-05 ± 4.1e-06 s | 0.0002737 ± 7.2e-06 s | 0.01x | 0.30x |
| 10 | U1+T(k=0) | 902 | 0.003259 ± 4e-05 s | 0.0009202 ± 3.7e-05 s | 0.001306 ± 2.2e-05 s | 0.28x | 0.40x |
| 10 | U1+T(k=0)+P(p=1) | 486 | 0.005924 ± 0.00013 s | 0.001176 ± 2.5e-05 s | 0.001789 ± 1.6e-05 s | 0.20x | 0.30x |
| 12 | U1 | 73789 | 0.008018 ± 0.00018 s | 2.912e-05 ± 4.6e-06 s | 0.002143 ± 4.2e-05 s | 0.00x | 0.27x |
| 12 | U1+T(k=0) | 6166 | 0.04226 ± 0.00025 s | 0.007508 ± 0.00013 s | 0.01276 ± 6.8e-05 s | 0.18x | 0.30x |
| 12 | U1+T(k=0)+P(p=1) | 3179 | 0.07307 ± 0.00055 s | 0.009169 ± 0.00012 s | 0.01744 ± 5.5e-05 s | 0.13x | 0.24x |

### Boson (d=3) — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 9.867e-06 ± 3.5e-08 s | N/A (no decoupled API) | 1.192e-06 ± 3.2e-09 s |

