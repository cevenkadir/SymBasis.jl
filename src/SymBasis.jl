module SymBasis

# DigitBase submodule
include("digitbase/DigitBase.jl")

using .DigitBase: BaseInt
export BaseInt

using .DigitBase: @bi_str
export @bi_str

using .DigitBase: flip, inc, dec, permute
export flip, inc, dec, permute

using .DigitBase: num_digits_in_base
export num_digits_in_base

using .DigitBase: eachdigit
export eachdigit

using .DigitBase: BaseIntRange
export BaseIntRange

# DoFObjects submodule
include("dofobjects/DoFObjects.jl")
using .DoFObjects: DoFObject
export DoFObject

using .DoFObjects: bint
export bint

using .DoFObjects: AbstractDoFSpec
export AbstractDoFSpec

using .DoFObjects: Spin, Boson, SpinlessFermion, SpinfulFermion
export Spin, Boson, SpinlessFermion, SpinfulFermion

using .DoFObjects: dof_object
export dof_object

include("miscs/Miscs.jl")

# SymGroups submodule
include("symgroups/SymGroups.jl")
using .SymGroups: SymGroup, CombSymGroup
export SymGroup, CombSymGroup

using .SymGroups: AbstractSymSpec
export AbstractSymSpec

using .SymGroups: Translational, SpatialReflection, Rotational
export Translational, SpatialReflection, Rotational

using .SymGroups: check_Nₛ, check_perm, check_flip
export check_Nₛ, check_perm, check_flip

using .SymGroups: apply_Nₛ, apply_perm, apply_flip
export apply_Nₛ, apply_perm, apply_flip

using .SymGroups: WeightedCounts
export WeightedCounts

using .SymGroups: phase_unity
export phase_unity

using .SymGroups: sym
export sym

using .SymGroups: TotalMagnetization, SpinMultipole, SpinInversion
export TotalMagnetization, SpinMultipole, SpinInversion

using .SymGroups: check_multipole
export check_multipole

using .SymGroups: apply_multipole
export apply_multipole

using .SymGroups: ParticleNumberConservation, TotalBosonicNumber
export ParticleNumberConservation, TotalBosonicNumber

using .SymGroups: TotalSpinlessFermionicNumber
export TotalSpinlessFermionicNumber

using .SymGroups: TotalSpinfulFermionicNumber, FermionicSpinInversion
export TotalSpinfulFermionicNumber, FermionicSpinInversion

using .SymGroups: phase_perm_fermionic
export phase_perm_fermionic

# Bases submodule
include("bases/Bases.jl")
using .Bases: Basis
export Basis

using .Bases: basis
export basis

using .Bases: is_commutative, representative
export is_commutative, representative

using .Bases: state_index
export state_index

# Precompile the common construction flows on tiny systems, so the first real `basis`
# call in a session does not pay for compiling the whole pipeline.
using PrecompileTools: @setup_workload, @compile_workload

@setup_workload begin
    N = 4
    perm = mod1.((1:N) .+ 1, N)
    refl = mod1.(reverse(1:N), N)

    @compile_workload begin
        # Spin-1/2: magnetization sector, combined with translation and reflection.
        spin = dof_object(Spin(1 // 2))
        sz = sym(TotalMagnetization(0 // 1, N), spin)
        tr = sym(Translational(0, perm), spin)
        rf = sym(SpatialReflection(1, refl), spin)
        sz_tr = sz ∘ tr
        basis(spin, N, sz)
        b = basis(spin, N, sz_tr)
        basis(spin, N, sz ∘ tr ∘ rf)
        basis(spin, N, sz_tr; is_sorted=true)
        st = first(b.states)
        representative(st, sz_tr)
        state_index(b, st)
        is_commutative(b, sz_tr)

        # Bosons (B > 2) with particle-number conservation.
        bos = dof_object(Boson(2))
        basis(bos, N, sym(TotalBosonicNumber(2, N), bos))

        # Spinless fermions: number conservation, alone and with a fermionic-phase symmetry.
        fer = dof_object(SpinlessFermion())
        nf = sym(TotalSpinlessFermionicNumber(2, N), fer)
        basis(fer, N, nf)
        basis(fer, N, nf ∘ sym(Translational(0, perm), fer))

        # Full basis without symmetries, and the digit helpers.
        basis(spin, N)
        for d in eachdigit(st, N)
            d
        end
        pos = 1
        flip(st, pos)
        inc(st, pos)
        dec(st, pos)
        permute(st, perm)
        num_digits_in_base(2, 2)
        bint(spin)
        for s in BaseIntRange(st, st, st)
            s
        end

        # The `show` methods: these fire on the first REPL display of any returned value,
        # and `Basis` alone is the largest single first-call cost in the package.
        for x in (b, sz, sz_tr, spin, st, BaseIntRange(st, st, st))
            show(devnull, MIME"text/plain"(), x)
            show(devnull, x)
        end
    end
end

end
