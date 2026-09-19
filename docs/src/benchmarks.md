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
| 8 | U1 | 70 | 7.272e-06 ± 8.6e-06 s | 4.064e-06 ± 6.5e-06 s | 3.688e-05 ± 1.5e-05 s | 0.56x | 5.07x |
| 8 | U1+T(k=0) | 10 | 1.202e-05 ± 1.2e-05 s | 5.453e-05 ± 2.8e-05 s | 4.504e-05 ± 1.2e-05 s | 4.54x | 3.75x |
| 8 | U1+T(k=0)+P(p=1) | 8 | 7.133e-05 ± 5.9e-05 s | 0.0001266 ± 2.7e-05 s | 5.394e-05 ± 1.5e-05 s | 1.77x | 0.76x |
| 10 | U1 | 252 | 9.897e-06 ± 8.9e-06 s | 4.058e-06 ± 6.3e-06 s | 3.681e-05 ± 1.1e-05 s | 0.41x | 3.72x |
| 10 | U1+T(k=0) | 26 | 0.0004525 ± 0.00087 s | 0.0001002 ± 2.4e-05 s | 5.142e-05 ± 8.4e-06 s | 0.22x | 0.11x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 0.0004701 ± 0.00077 s | 0.0002288 ± 2.4e-05 s | 6.198e-05 ± 8.3e-06 s | 0.49x | 0.13x |
| 12 | U1 | 924 | 2.245e-05 ± 8.8e-06 s | 4.75e-06 ± 6.5e-06 s | 4.269e-05 ± 9.1e-06 s | 0.21x | 1.90x |
| 12 | U1+T(k=0) | 80 | 8.073e-05 ± 2.4e-05 s | 0.0002802 ± 2.4e-05 s | 9.169e-05 ± 1.6e-05 s | 3.47x | 1.14x |
| 12 | U1+T(k=0)+P(p=1) | 50 | 0.000189 ± 0.00024 s | 0.0005069 ± 1.8e-05 s | 0.0001212 ± 1.3e-05 s | 2.68x | 0.64x |
| 14 | U1 | 3432 | 0.0001094 ± 1.8e-05 s | 5.245e-06 ± 6.5e-06 s | 6.953e-05 ± 1.1e-05 s | 0.05x | 0.64x |
| 14 | U1+T(k=0) | 246 | 0.0008202 ± 0.00095 s | 0.001491 ± 0.0017 s | 0.0002236 ± 1.5e-05 s | 1.82x | 0.27x |
| 14 | U1+T(k=0)+P(p=1) | 133 | 0.0008902 ± 0.00097 s | 0.00139 ± 2.9e-05 s | 0.0003294 ± 1.7e-05 s | 1.56x | 0.37x |
| 16 | U1 | 12870 | 0.0004425 ± 0.00011 s | 6.877e-06 ± 8.4e-06 s | 0.0001488 ± 9.6e-06 s | 0.02x | 0.34x |
| 16 | U1+T(k=0) | 810 | 0.0005928 ± 0.00034 s | 0.003861 ± 2.2e-05 s | 0.0007375 ± 1.4e-05 s | 6.51x | 1.24x |
| 16 | U1+T(k=0)+P(p=1) | 440 | 0.0008968 ± 0.00028 s | 0.005371 ± 0.0016 s | 0.001122 ± 1.2e-05 s | 5.99x | 1.25x |

### Spin-1/2 — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 3.091e-07 ± 1.1e-09 s | N/A (no decoupled API) | 1.798e-07 ± 2.2e-09 s |

### Spinless fermion — basis construction

```@example benchmarks
plot_construction("fermion", "Spinless fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 8 | U1 | 70 | 7.081e-06 ± 8.2e-06 s | 4.397e-06 ± 6.9e-06 s | 5.181e-05 ± 1.3e-05 s | 0.62x | 7.32x |
| 8 | U1+T(k=0) | 9 | 1.206e-05 ± 1.2e-05 s | 7.513e-05 ± 8.8e-05 s | 6.485e-05 ± 1.2e-05 s | 6.23x | 5.38x |
| 8 | U1+T(k=0)+P(p=1) | 6 | 6.083e-05 ± 7.6e-05 s | 0.0001312 ± 2.9e-05 s | 7.186e-05 ± 1.1e-05 s | 2.16x | 1.18x |
| 10 | U1 | 252 | 1.034e-05 ± 1e-05 s | 4.332e-06 ± 6.5e-06 s | 5.313e-05 ± 1.1e-05 s | 0.42x | 5.14x |
| 10 | U1+T(k=0) | 26 | 4.617e-05 ± 3.5e-05 s | 0.000109 ± 2.5e-05 s | 7.816e-05 ± 9.9e-06 s | 2.36x | 1.69x |
| 10 | U1+T(k=0)+P(p=1) | 16 | 5.756e-05 ± 3.6e-05 s | 0.001405 ± 0.0037 s | 9.498e-05 ± 1.6e-05 s | 24.40x | 1.65x |
| 12 | U1 | 924 | 2.108e-05 ± 1.3e-05 s | 4.132e-06 ± 6.2e-06 s | 6.124e-05 ± 8.7e-06 s | 0.20x | 2.91x |
| 12 | U1+T(k=0) | 76 | 0.0002855 ± 0.0006 s | 0.0003429 ± 0.00015 s | 0.0001084 ± 2.4e-05 s | 1.20x | 0.38x |
| 12 | U1+T(k=0)+P(p=1) | 33 | 0.000191 ± 0.0003 s | 0.0005257 ± 2.1e-05 s | 0.0001195 ± 1.3e-05 s | 2.75x | 0.63x |
| 14 | U1 | 3432 | 0.0003568 ± 0.00036 s | 5.88e-06 ± 7.6e-06 s | 6.361e-05 ± 8e-06 s | 0.02x | 0.18x |
| 14 | U1+T(k=0) | 246 | 0.0002459 ± 0.00022 s | 0.001117 ± 4.5e-05 s | 0.0002221 ± 9.8e-06 s | 4.54x | 0.90x |
| 14 | U1+T(k=0)+P(p=1) | 113 | 0.0005236 ± 0.00057 s | 0.0015 ± 4.9e-05 s | 0.0003239 ± 1.1e-05 s | 2.86x | 0.62x |
| 16 | U1 | 12870 | 0.0002922 ± 9.2e-05 s | 9.759e-06 ± 9.9e-06 s | 0.0001508 ± 1.1e-05 s | 0.03x | 0.52x |
| 16 | U1+T(k=0) | 809 | 0.0006822 ± 0.00044 s | 0.00452 ± 2.7e-05 s | 0.0007412 ± 2e-05 s | 6.63x | 1.09x |
| 16 | U1+T(k=0)+P(p=1) | 422 | 0.001231 ± 0.00072 s | 0.006033 ± 0.0015 s | 0.001139 ± 2.4e-05 s | 4.90x | 0.93x |

### Spinless fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 16 | U1+T(k=0)+P(p=1) | 10000 | 3.799e-07 ± 2.3e-09 s | N/A (no decoupled API) | 1.891e-06 ± 5e-08 s |

### Spinful fermion — basis construction

```@example benchmarks
plot_construction("spinful_fermion", "Spinful fermion")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 4 | U1 | 36 | 8.206e-06 ± 9.1e-06 s | 5.746e-06 ± 9.3e-06 s | 6.776e-05 ± 2.5e-05 s | 0.70x | 8.26x |
| 4 | U1+T(k=0) | 10 | 1.187e-05 ± 1.2e-05 s | 3.363e-05 ± 3e-05 s | 7.792e-05 ± 1.7e-05 s | 2.83x | 6.57x |
| 4 | U1+T(k=0)+P(p=1) | 6 | 1.419e-05 ± 1.3e-05 s | 6.32e-05 ± 3.6e-05 s | 8.197e-05 ± 1.2e-05 s | 4.45x | 5.78x |
| 6 | U1 | 400 | 2.453e-05 ± 1.6e-05 s | 5.404e-06 ± 9.1e-06 s | 7.192e-05 ± 1.2e-05 s | 0.22x | 2.93x |
| 6 | U1+T(k=0) | 68 | 0.0001347 ± 0.00011 s | 5.224e-05 ± 3.1e-05 s | 0.0001285 ± 1.2e-05 s | 0.39x | 0.95x |
| 6 | U1+T(k=0)+P(p=1) | 38 | 9.866e-05 ± 3.4e-05 s | 0.0001088 ± 3.5e-05 s | 0.0001601 ± 4e-05 s | 1.10x | 1.62x |
| 8 | U1 | 4900 | 0.0002768 ± 3.5e-05 s | 5.017e-06 ± 8.6e-06 s | 0.0001247 ± 1.1e-05 s | 0.02x | 0.45x |
| 8 | U1+T(k=0) | 618 | 0.0004078 ± 5.5e-05 s | 0.0001193 ± 3.2e-05 s | 0.0005275 ± 1.7e-05 s | 0.29x | 1.29x |
| 8 | U1+T(k=0)+P(p=1) | 318 | 0.0005543 ± 8.5e-05 s | 0.0002765 ± 4e-05 s | 0.000919 ± 1.3e-05 s | 0.50x | 1.66x |
| 10 | U1 | 63504 | 0.00297 ± 0.00081 s | 5.546e-06 ± 9.5e-06 s | 0.001067 ± 3e-05 s | 0.00x | 0.36x |
| 10 | U1+T(k=0) | 6352 | 0.005042 ± 0.00079 s | 0.0004 ± 8.4e-05 s | 0.006444 ± 2.2e-05 s | 0.08x | 1.28x |
| 10 | U1+T(k=0)+P(p=1) | 3212 | 0.007215 ± 0.0012 s | 0.003926 ± 0.0065 s | 0.01137 ± 4.5e-05 s | 0.54x | 1.58x |
| 12 | U1 | 853776 | 0.02168 ± 0.0075 s | 6.487e-06 ± 9.3e-06 s | 0.01542 ± 0.00013 s | 0.00x | 0.71x |
| 12 | U1+T(k=0) | 71188 | 0.05834 ± 0.0064 s | 0.002048 ± 0.00011 s | 0.0896 ± 0.00027 s | 0.04x | 1.54x |
| 12 | U1+T(k=0)+P(p=1) | 35694 | 0.09412 ± 0.0065 s | 0.005102 ± 7.9e-05 s | 0.1583 ± 0.00053 s | 0.05x | 1.68x |

### Spinful fermion — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 1.399e-06 ± 1.2e-08 s | N/A (no decoupled API) | 2.213e-06 ± 9.2e-09 s |

### Boson (d=3) — basis construction

```@example benchmarks
plot_construction("boson", "Boson (d=3)")
```

| N | config | dim | SymBasis | XDiag | QuSpin | XDiag/SymBasis | QuSpin/SymBasis |
|---|---|---|---|---|---|---|---|
| 6 | U1 | 141 | 1.128e-05 ± 1e-05 s | 4.575e-06 ± 6.6e-06 s | 6.089e-05 ± 1.3e-05 s | 0.41x | 5.40x |
| 6 | U1+T(k=0) | 26 | 2.339e-05 ± 1.9e-05 s | 0.0004482 ± 0.0013 s | 8.185e-05 ± 1.3e-05 s | 19.16x | 3.50x |
| 6 | U1+T(k=0)+P(p=1) | 18 | 5.472e-05 ± 2.9e-05 s | 0.0001555 ± 0.00019 s | 9.025e-05 ± 1.4e-05 s | 2.84x | 1.65x |
| 8 | U1 | 1107 | 7.337e-05 ± 2.3e-05 s | 6.287e-06 ± 6.8e-06 s | 0.0002021 ± 0.00033 s | 0.09x | 2.75x |
| 8 | U1+T(k=0) | 142 | 0.0007732 ± 0.00089 s | 0.0002597 ± 3.5e-05 s | 0.0002173 ± 2.8e-05 s | 0.34x | 0.28x |
| 8 | U1+T(k=0)+P(p=1) | 84 | 0.0005397 ± 0.00084 s | 0.0003973 ± 4.1e-05 s | 0.0002246 ± 1.1e-05 s | 0.74x | 0.42x |
| 10 | U1 | 8953 | 0.0008259 ± 0.00069 s | 1.116e-05 ± 8.6e-06 s | 0.0002898 ± 9.7e-06 s | 0.01x | 0.35x |
| 10 | U1+T(k=0) | 902 | 0.0009784 ± 0.00031 s | 0.002069 ± 3.3e-05 s | 0.001488 ± 1.5e-05 s | 2.11x | 1.52x |
| 10 | U1+T(k=0)+P(p=1) | 486 | 0.001543 ± 0.00071 s | 0.002607 ± 4.7e-05 s | 0.001801 ± 1.8e-05 s | 1.69x | 1.17x |
| 12 | U1 | 73789 | 0.003353 ± 0.00059 s | 2.857e-05 ± 9.4e-06 s | 0.002096 ± 1.2e-05 s | 0.01x | 0.63x |
| 12 | U1+T(k=0) | 6166 | 0.00632 ± 0.00087 s | 0.01924 ± 7.5e-05 s | 0.01413 ± 7.2e-05 s | 3.04x | 2.24x |
| 12 | U1+T(k=0)+P(p=1) | 3179 | 0.01078 ± 0.0011 s | 0.02319 ± 0.0011 s | 0.01688 ± 2.4e-05 s | 2.15x | 1.57x |

### Boson (d=3) — representative lookup (seconds/call, amortized over batch)

| N | config | nsamples | SymBasis | XDiag | QuSpin |
|---|---|---|---|---|---|
| 12 | U1+T(k=0)+P(p=1) | 10000 | 1.717e-06 ± 2.1e-09 s | N/A (no decoupled API) | 3.168e-07 ± 1.8e-09 s |

