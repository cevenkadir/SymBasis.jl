# Benchmarks

Symmetry-resolved basis construction and representative-state lookup speed, compared against [XDiag.jl](https://github.com/awietek/XDiag.jl) and [QuSpin](https://quspin.github.io/QuSpin/). SymBasis is benchmarked against its own dev checkout; XDiag.jl and QuSpin are whatever their latest released versions were at the time this page was generated. Regenerated automatically on every SymBasis release.

Sweep: `BENCH_SWEEP=quick`

### Spin-1/2 — basis construction

![Spin-1/2 construction time](assets/benchmarks/spin_construction.svg)

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 8 | U1 | 70 | 1.321e-05 ± 1.9e-05 s | 3.961e-06 ± 6.7e-06 s | 2.422e-05 ± 1.2e-05 s | 0.30x | 1.83x |
| 8 | U1+T(k=0) | 10 | 1.889e-05 ± 2.4e-05 s | 4.453e-05 ± 2.4e-05 s | 2.469e-05 ± 6.8e-06 s | 2.36x | 1.31x |
| 8 | U1+T(k=0)+P(p=1) | 8 | 2.464e-05 ± 2.1e-05 s | 9.424e-05 ± 3.2e-05 s | 3.127e-05 ± 8.1e-06 s | 3.82x | 1.27x |
| 10 | U1 | 252 | 2.601e-05 ± 4e-05 s | 4.049e-06 ± 6.8e-06 s | 1.97e-05 ± 3.6e-06 s | 0.16x | 0.76x |
| 10 | U1+T(k=0) | 26 | 3.034e-05 ± 2.3e-05 s | 8.326e-05 ± 2.5e-05 s | 3.5e-05 ± 6.2e-06 s | 2.74x | 1.15x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 4.438e-05 ± 3.7e-05 s | 0.0001665 ± 3.6e-05 s | 4.098e-05 ± 4.3e-06 s | 3.75x | 0.92x |
| 12 | U1 | 924 | 3.782e-05 ± 4.8e-05 s | 4.729e-06 ± 6.8e-06 s | 2.869e-05 ± 6e-06 s | 0.13x | 0.76x |
| 12 | U1+T(k=0) | 80 | 4.32e-05 ± 2.7e-05 s | 0.0002447 ± 2.4e-05 s | 7.441e-05 ± 5.8e-06 s | 5.66x | 1.72x |
| 12 | U1+T(k=0)+P(p=1) | 50 | 8.147e-05 ± 3.8e-05 s | 0.0003648 ± 4.7e-05 s | 0.0001064 ± 5.2e-06 s | 4.48x | 1.31x |
| 14 | U1 | 3432 | 8.155e-05 ± 4.7e-05 s | 7.854e-06 ± 9.9e-06 s | 5.449e-05 ± 6.2e-06 s | 0.10x | 0.67x |
| 14 | U1+T(k=0) | 246 | 0.0001059 ± 3.1e-05 s | 0.0007485 ± 3.2e-05 s | 0.0001913 ± 5.5e-06 s | 7.07x | 1.81x |
| 14 | U1+T(k=0)+P(p=1) | 133 | 0.0001972 ± 4.5e-05 s | 0.0009849 ± 4.6e-05 s | 0.0003032 ± 1.8e-05 s | 4.99x | 1.54x |
| 16 | U1 | 12870 | 0.0001943 ± 5.2e-05 s | 9.915e-06 ± 1.5e-05 s | 0.0001306 ± 4.9e-06 s | 0.05x | 0.67x |
| 16 | U1+T(k=0) | 810 | 0.0003332 ± 3e-05 s | 0.002961 ± 7.5e-05 s | 0.000734 ± 1.9e-05 s | 8.89x | 2.20x |
| 16 | U1+T(k=0)+P(p=1) | 440 | 0.0006549 ± 4.5e-05 s | 0.003508 ± 6.4e-05 s | 0.001063 ± 5.6e-05 s | 5.36x | 1.62x |

### Spin-1/2 — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 1.016e-07 ± 3e-09 s | N/A (no decoupled API) | 6.322e-07 ± 2.5e-08 s |

### Spinless fermion — basis construction

![Spinless fermion construction time](assets/benchmarks/fermion_construction.svg)

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 8 | U1 | 70 | 1.53e-05 ± 2.6e-05 s | 4.194e-06 ± 6.4e-06 s | 2.167e-05 ± 8.2e-06 s | 0.27x | 1.42x |
| 8 | U1+T(k=0) | 9 | 2.158e-05 ± 2.4e-05 s | 4.601e-05 ± 2.4e-05 s | 2.8e-05 ± 7.3e-06 s | 2.13x | 1.30x |
| 8 | U1+T(k=0)+P(p=1) | 6 | 3.217e-05 ± 2.4e-05 s | 9.584e-05 ± 3.6e-05 s | 3.053e-05 ± 4.5e-06 s | 2.98x | 0.95x |
| 10 | U1 | 252 | 2.623e-05 ± 4.7e-05 s | 5.397e-06 ± 7.5e-06 s | 2.344e-05 ± 6e-06 s | 0.21x | 0.89x |
| 10 | U1+T(k=0) | 26 | 4.134e-05 ± 2.5e-05 s | 9.388e-05 ± 3.2e-05 s | 3.405e-05 ± 5.1e-06 s | 2.27x | 0.82x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 7.147e-05 ± 3.1e-05 s | 0.0001825 ± 4.3e-05 s | 5.168e-05 ± 2e-05 s | 2.55x | 0.72x |
| 12 | U1 | 924 | 3.97e-05 ± 4.6e-05 s | 4.927e-06 ± 6.8e-06 s | 2.743e-05 ± 4.2e-06 s | 0.12x | 0.69x |
| 12 | U1+T(k=0) | 76 | 0.0001029 ± 3.1e-05 s | 0.0002853 ± 3.6e-05 s | 6.669e-05 ± 5.2e-06 s | 2.77x | 0.65x |
| 12 | U1+T(k=0)+P(p=1) | 33 | 0.0001971 ± 4.1e-05 s | 0.0003971 ± 4.4e-05 s | 9.245e-05 ± 5.2e-06 s | 2.01x | 0.47x |
| 14 | U1 | 3432 | 8.262e-05 ± 5.3e-05 s | 1.242e-05 ± 1.6e-05 s | 4.814e-05 ± 3.5e-06 s | 0.15x | 0.58x |
| 14 | U1+T(k=0) | 246 | 0.0003873 ± 4.1e-05 s | 0.001036 ± 4e-05 s | 0.0001907 ± 6.7e-06 s | 2.67x | 0.49x |
| 14 | U1+T(k=0)+P(p=1) | 113 | 0.0008195 ± 4.8e-05 s | 0.001263 ± 4.9e-05 s | 0.0002904 ± 5.9e-06 s | 1.54x | 0.35x |
| 16 | U1 | 12870 | 0.0002026 ± 5.5e-05 s | 1.118e-05 ± 1.8e-05 s | 0.0001257 ± 7e-06 s | 0.06x | 0.62x |
| 16 | U1+T(k=0) | 809 | 0.001491 ± 8.1e-05 s | 0.004123 ± 0.00013 s | 0.000661 ± 8.1e-06 s | 2.76x | 0.44x |
| 16 | U1+T(k=0)+P(p=1) | 422 | 0.003016 ± 0.00012 s | 0.004689 ± 0.00024 s | 0.001056 ± 1e-05 s | 1.55x | 0.35x |

### Spinless fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 1.295e-06 ± 2e-08 s | N/A (no decoupled API) | 4.877e-06 ± 5.7e-08 s |

### Boson (d=3) — basis construction

![Boson (d=3) construction time](assets/benchmarks/boson_construction.svg)

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 6 | U1 | 141 | 4.365e-05 ± 6.6e-05 s | 5.244e-06 ± 6.9e-06 s | 2.592e-05 ± 8.7e-06 s | 0.12x | 0.59x |
| 6 | U1+T(k=0) | 26 | 7.736e-05 ± 7.5e-05 s | 5.457e-05 ± 2.7e-05 s | 3.967e-05 ± 7.7e-06 s | 0.71x | 0.51x |
| 6 | U1+T(k=0)+P(p=1) | 18 | 0.0001156 ± 7.5e-05 s | 8.739e-05 ± 3.3e-05 s | 4.281e-05 ± 6e-06 s | 0.76x | 0.37x |
| 8 | U1 | 1107 | 0.000159 ± 5.4e-05 s | 7.643e-06 ± 7.9e-06 s | 5.031e-05 ± 7.1e-06 s | 0.05x | 0.32x |
| 8 | U1+T(k=0) | 142 | 0.0004909 ± 3.9e-05 s | 0.0002556 ± 3.7e-05 s | 0.0001566 ± 9.4e-06 s | 0.52x | 0.32x |
| 8 | U1+T(k=0)+P(p=1) | 84 | 0.0006655 ± 4.6e-05 s | 0.000331 ± 4e-05 s | 0.0002027 ± 6.8e-06 s | 0.50x | 0.30x |
| 10 | U1 | 8953 | 0.001399 ± 6.4e-05 s | 1.667e-05 ± 1.8e-05 s | 0.0002587 ± 4.3e-06 s | 0.01x | 0.18x |
| 10 | U1+T(k=0) | 902 | 0.005009 ± 0.00021 s | 0.001909 ± 5.1e-05 s | 0.001385 ± 1.6e-05 s | 0.38x | 0.28x |
| 10 | U1+T(k=0)+P(p=1) | 486 | 0.006905 ± 0.00025 s | 0.002208 ± 5.8e-05 s | 0.001835 ± 3.7e-05 s | 0.32x | 0.27x |
| 12 | U1 | 73789 | 0.01527 ± 0.00082 s | 3.473e-05 ± 1.8e-05 s | 0.002045 ± 6.6e-05 s | 0.00x | 0.13x |
| 12 | U1+T(k=0) | 6166 | 0.05223 ± 0.00088 s | 0.01699 ± 0.00024 s | 0.01381 ± 0.00029 s | 0.33x | 0.26x |
| 12 | U1+T(k=0)+P(p=1) | 3179 | 0.07296 ± 0.00083 s | 0.01877 ± 0.00042 s | 0.01838 ± 0.00046 s | 0.26x | 0.25x |

### Boson (d=3) — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 6.338e-06 ± 1.1e-07 s | N/A (no decoupled API) | 1.197e-06 ± 2.5e-08 s |

