using Aqua
using SymBasis
using Test

Aqua.test_all(
    SymBasis;
    # Deliberately disabled: `DoFObject(type, ldof::NTuple{B,T_ldof})` and
    # `all_permutations(t::NTuple{N,T})` only leave `T_ldof`/`T` unbound for the degenerate
    # empty tuple (`B == 0`, `N == 0`), which is not a meaningful input. `NTuple` cannot
    # express "at least one element", and narrowing the public signatures would be a
    # breaking change.
    unbound_args=false,
    # `Aqua` is only a test dependency. The Downgrade CI job promotes it into `[deps]` for
    # its locked `Pkg.test` run, and Aqua would then report it as an unused dependency.
    stale_deps=(; ignore=[:Aqua]),
)
