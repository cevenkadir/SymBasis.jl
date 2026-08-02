@testset "Testing SymGroup's predefined functions..." begin
    using BitPermutations: BitPermutation
    @testset "check_perm" begin
        state1 = bi"11010"2
        perm = BitPermutation{UInt}(perm_k([2, 3, 4, 5, 1], 1))
        @test !check_perm((; perm=perm), state1, false)
        @test check_perm((; perm=perm), state1, true)

        state2 = bi"5410"6
        perm = perm_k([4, 3, 2, 1, 5], 1)
        @test !check_perm((; perm=perm), state2, false)
        @test check_perm((; perm=perm), state2, true)

    end
    @testset "apply_perm" begin
        state1 = bi"10011"2
        perm1 = BitPermutation{UInt}(perm_k([2, 1, 4, 5, 3], 1))
        @test apply_perm((; perm=perm1), state1) == bi"1011"2
        perm1 = BitPermutation{UInt}(perm_k([2, 1, 4, 5, 3], 2))
        @test apply_perm((; perm=perm1), state1) == bi"111"2

        state2 = bi"1302"5
        perm2 = perm_k([3, 5, 4, 2, 6, 1], 1)
        @test apply_perm((; perm=perm2), state2) == bi"200103"5
        perm2 = perm_k([3, 5, 4, 2, 6, 1], 2)
        @test apply_perm((; perm=perm2), state2) == bi"320001"5
    end

    @testset "check_Nₛ" begin
        state1 = bi"11010"2
        @test !check_Nₛ((; N0=2, N1=3, N=5), state1, false)
        @test check_Nₛ((; N0=2, N1=3, N=5), state1, true)

        state2 = bi"5410"6
        @test !check_Nₛ((; N0=2, N1=1, N2=0, N3=0, N4=1, N5=1, N=5), state2, false)
        @test check_Nₛ((; N0=2, N1=1, N2=0, N3=0, N4=1, N5=1, N=5), state2, true)
    end

    @testset "apply_Nₛ" begin
        state1 = bi"10011"2
        @test apply_Nₛ((; N0=2, N1=3, N=5), state1) == bi"10011"2

        state2 = bi"1302"5
        @test apply_Nₛ((; N0=1, N1=1, N2=1, N3=1, N4=0, N=4), state2) == bi"1302"5
    end

    @testset "check_multipole" begin
        # Binary (B=2), rank-1, D=1, uniform rational weights
        # bi"10011"2: digits (low→high) 1,1,0,0,1 → m = 1/2,1/2,-1/2,-1/2,1/2 → Σm = 1/2
        state1 = bi"10011"2
        p1 = (; qₛ=[1 // 2], weights=ones(Rational{Int}, 5, 1), N=5, atol=0.0, rtol=0.0)
        @test check_multipole(p1, state1, true) == true
        @test check_multipole(p1, state1, false) == false
        # Non-matching target
        p1_bad = (; qₛ=[3 // 2], weights=ones(Rational{Int}, 5, 1), N=5, atol=0.0, rtol=0.0)
        @test check_multipole(p1_bad, state1, true) == false

        # Base-6 (B=6), rank-1, D=1, uniform weights
        # bi"5410"6: digits 0,1,4,5 → m = -5/2,-3/2,3/2,5/2 → Σm = 0
        state2 = bi"5410"6
        p2 = (; qₛ=[0 // 1], weights=ones(Rational{Int}, 4, 1), N=4, atol=0.0, rtol=0.0)
        @test check_multipole(p2, state2, true) == true
        p2_bad = (; qₛ=[1 // 1], weights=ones(Rational{Int}, 4, 1), N=4, atol=0.0, rtol=0.0)
        @test check_multipole(p2_bad, state2, true) == false

        # Binary, rank-1, D=2: alternating site weights [1,0],[0,1],[1,0],[0,1],[1,0]
        # state1 digits 1,1,0,0,1 → sum[1] = 1/2+(-1/2)+1/2 = 1/2, sum[2] = 1/2+(-1/2) = 0
        weights3 = Rational{Int}[1 0; 0 1; 1 0; 0 1; 1 0]
        p3 = (; qₛ=[1 // 2, 0 // 1], weights=weights3, N=5, atol=0.0, rtol=0.0)
        @test check_multipole(p3, state1, true) == true
        p3_bad = (; qₛ=[1 // 2, 1 // 2], weights=weights3, N=5, atol=0.0, rtol=0.0)
        @test check_multipole(p3_bad, state1, true) == false

        # Float weights with tolerance: same as p1 but Float64, Σm ≈ 0.5
        p4 = (; qₛ=[0.5], weights=ones(Float64, 5, 1), N=5, atol=1e-10, rtol=1e-10)
        @test check_multipole(p4, state1, true) == true
        p4_close = (;
            qₛ=[0.5 + 1e-15],
            weights=ones(Float64, 5, 1),
            N=5,
            atol=1e-10,
            rtol=1e-10
        )
        @test check_multipole(p4_close, state1, true) == true
        p4_far = (;
            qₛ=[0.5 + 1e-5],
            weights=ones(Float64, 5, 1),
            N=5,
            atol=1e-10,
            rtol=1e-10
        )
        @test check_multipole(p4_far, state1, true) == false
    end

    @testset "apply_multipole" begin
        # apply_multipole always returns the state unchanged
        state1 = bi"10011"2
        p1 = (; qₛ=[1 // 2], weights=ones(Rational{Int}, 5, 1), N=5, atol=0.0, rtol=0.0)
        @test apply_multipole(p1, state1) == state1

        # Works regardless of qₛ mismatch: still returns the state
        p1_bad = (; qₛ=[3 // 2], weights=ones(Rational{Int}, 5, 1), N=5, atol=0.0, rtol=0.0)
        @test apply_multipole(p1_bad, state1) == state1

        # Base-6 state
        state2 = bi"5410"6
        p2 = (; qₛ=[0 // 1], weights=ones(Rational{Int}, 4, 1), N=4, atol=0.0, rtol=0.0)
        @test apply_multipole(p2, state2) == state2
    end

    @testset "check_flip" begin
        # Binary state: bi"11010"2 has N0=2, N1=3
        state1 = bi"11010"2
        sites1 = collect(1:5)
        @test !check_flip(
            (; is_flipped=false, sites=sites1, N0=2, N1=3, N=5),
            state1,
            false
        )
        @test check_flip((; is_flipped=false, sites=sites1, N0=2, N1=3, N=5), state1, true)
        # Mismatched counts return false regardless of prev_bool
        @test !check_flip((; is_flipped=false, sites=sites1, N0=3, N1=2, N=5), state1, true)
        # is_flipped flag does not affect the check
        @test check_flip((; is_flipped=true, sites=sites1, N0=2, N1=3, N=5), state1, true)

        # Non-binary state (base 5): bi"1302"5 has N0=1, N1=1, N2=1, N3=1, N4=0 at sites 1-4
        state2 = bi"1302"5
        sites2 = collect(1:4)
        @test !check_flip(
            (; is_flipped=false, sites=sites2, N0=1, N1=1, N2=1, N3=1, N4=0, N=4),
            state2,
            false
        )
        @test check_flip(
            (; is_flipped=false, sites=sites2, N0=1, N1=1, N2=1, N3=1, N4=0, N=4),
            state2,
            true
        )
        # Mismatched counts
        @test !check_flip(
            (; is_flipped=false, sites=sites2, N0=2, N1=1, N2=1, N3=0, N4=0, N=4),
            state2,
            true
        )
    end

    @testset "apply_flip" begin
        # Binary state: bi"11010"2 (value=26)
        state1 = bi"11010"2
        sites1 = collect(1:5)
        # is_flipped=false: returns unchanged state
        @test apply_flip(
            (; is_flipped=false, sites=sites1, N0=2, N1=3, N=5),
            state1
        ) == state1
        # is_flipped=true: flip all 5 bits → value 5 = bi"101"2
        @test apply_flip(
            (; is_flipped=true, sites=sites1, N0=2, N1=3, N=5),
            state1
        ) == bi"101"2
        # Flip only sites [1, 2]: 26 → 25 = bi"11001"2
        @test apply_flip(
            (; is_flipped=true, sites=collect(1:2), N0=2, N1=3, N=5),
            state1
        ) == bi"11001"2

        # Non-binary state (base 5): bi"1302"5 (digits pos1=2,pos2=0,pos3=3,pos4=1)
        state2 = bi"1302"5
        sites2 = collect(1:4)
        # is_flipped=false: returns unchanged state
        @test apply_flip(
            (; is_flipped=false, sites=sites2, N0=1, N1=1, N2=1, N3=1, N4=0, N=4),
            state2
        ) == state2
        # is_flipped=true: flip all 4 digits → bi"3142"5
        @test apply_flip(
            (; is_flipped=true, sites=sites2, N0=1, N1=1, N2=1, N3=1, N4=0, N=4),
            state2
        ) == bi"3142"5
    end

    @testset "TotalMagnetization constructors" begin
        # Test Integer constructor
        tm1 = TotalMagnetization(2, 5)
        @test tm1.mag == 2 // 1
        @test tm1.N == 5

        tm2 = TotalMagnetization(-3, 10)
        @test tm2.mag == -3 // 1
        @test tm2.N == 10

        tm3 = TotalMagnetization(0, 4)
        @test tm3.mag == 0 // 1
        @test tm3.N == 4

        # Test AbstractFloat constructor
        tm4 = TotalMagnetization(0.5, 6)
        @test tm4.mag == 1 // 2
        @test tm4.N == 6

        tm5 = TotalMagnetization(-1.5, 8)
        @test tm5.mag == -3 // 2
        @test tm5.N == 8

        tm6 = TotalMagnetization(2.0, 7)
        @test tm6.mag == 2 // 1
        @test tm6.N == 7
    end

    @testset "sym of TotalMagnetization" begin
        dofo1 = dof_object(Spin(1 // 2))
        Sz_sym1ₛ = [sym(TotalMagnetization(Sz, 2), dofo1) for Sz in -1//1:1//1]
        cycle1ₛ = [
            [(; N0=2, N1=0, N=2)],
            [(; N0=1, N1=1, N=2)],
            [(; N0=0, N1=2, N=2)]
        ]
        factor1ₛ = [[1.0,], [1.0,], [1.0,]]
        for (i, Sz_symᵢ) in enumerate(Sz_sym1ₛ)
            @test Sz_symᵢ.dofo == dofo1
            @test Sz_symᵢ.cycles == cycle1ₛ[i]
            @test Sz_symᵢ.check == check_Nₛ
            @test Sz_symᵢ.apply == apply_Nₛ
            @test Sz_symᵢ.factors == factor1ₛ[i]
        end

        # Spin-1 (base 3) sectors can admit several digit-count signatures. Those are
        # collapsed into a single `WeightedCounts` cycle: digit `d` is the projection
        # `d - s`, so the sector is `Σ d == Sz + N*s` and one digit pass decides membership
        # for every signature at once.
        WC = SymBasis.SymGroups.WeightedCounts
        dofo2 = dof_object(Spin(1 // 1))
        Sz_sym2ₛ = [sym(TotalMagnetization(Sz, 3), dofo2) for Sz in -3//2:3//2]
        cycle2ₛ = [
            [(; N0=3, N1=0, N2=0, N=3)],
            [(; wc=WC(((0, 1, 2),), (2,), [(1, 2, 0), (2, 0, 1)]), N=3)],
            [(; wc=WC(((0, 1, 2),), (4,), [(0, 2, 1), (1, 0, 2)]), N=3)],
            [(; N0=0, N1=0, N2=3, N=3)]
        ]
        factor2ₛ = [[1.0,], [1.0,], [1.0,], [1.0,]]
        for (i, Sz_symᵢ) in enumerate(Sz_sym2ₛ)
            @test Sz_symᵢ.dofo == dofo2
            @test Sz_symᵢ.cycles == cycle2ₛ[i]
            @test Sz_symᵢ.check == check_Nₛ
            @test Sz_symᵢ.apply == apply_Nₛ
            @test Sz_symᵢ.factors == factor2ₛ[i]
        end

        # The collapsed cycle must select exactly the states matching one of the signatures
        # it replaced -- entries 2 and 3 are the multi-signature sectors.
        digit_sig(bi, n, B) = ntuple(d -> sum(x -> x == d - 1, eachdigit(bi, n)), B)
        all_sigs = [
            [(3, 0, 0)], [(1, 2, 0), (2, 0, 1)], [(0, 2, 1), (1, 0, 2)], [(0, 0, 3)]
        ]
        for (i, sigs) in enumerate(all_sigs)
            expected = [
                bi for bi in BaseInt(UInt(0); base=3):BaseInt(UInt(3^3 - 1); base=3)
                if digit_sig(bi, 3, 3) in sigs
            ]
            @test basis(dofo2, 3, Sz_sym2ₛ[i]).states == expected
        end
    end

    @testset "SpinMultipole constructor" begin
        # RANK=1, D=1: _build_eff_weights is identity, so stored weights == input
        w1 = ones(Rational{Int}, 4)
        ss1 = SpinMultipole(1 // 2, w1, 4)
        @test ss1.qₛ == [1 // 2]
        @test ss1.weights == ones(Rational{Int}, 4, 1)
        @test ss1.N == 4
        @test ss1.rtol == 0.0
        @test ss1.atol == 0.0

        # RANK=1, D=2: effective weights still identical to input
        w2 = Rational{Int}[1 0; 0 1; 1 0; 0 1]
        ss2 = SpinMultipole([1 // 2, 0 // 1], w2, 4)
        @test ss2.qₛ == [1 // 2, 0 // 1]
        @test ss2.weights == w2
        @test ss2.N == 4

        # RANK=2, D=1: effective weights are element-wise squares of input column
        w3 = Rational{Int}[1, 2, 1, 2]
        ss3 = SpinMultipole(1 // 4, w3, 4; rank=2)
        @test ss3.qₛ == reshape([1 // 4], 1, 1)
        @test ss3.weights == Rational{Int}[1//1; 4//1; 1//1; 4//1;;]

        # RANK=2, D=2: effective weights are kron([w1,w2],[w1,w2]) per row
        w4 = Rational{Int}[1 2; 3 1]
        qₛ4 = Rational{Int}[1 0; 0 1]  # symmetric 2×2
        ss4 = SpinMultipole(qₛ4, w4, 2)
        @test ss4.qₛ == qₛ4
        @test ss4.weights == Rational{Int}[1 2 2 4; 9 3 3 1]

        # Custom tolerances
        ss5 = SpinMultipole(0.5, ones(4), 4; rtol=1e-6, atol=1e-8)
        @test ss5.rtol == 1e-6
        @test ss5.atol == 1e-8

        # Convenience constructor: scalar + vector, rank=1 (default)
        ss6 = SpinMultipole(1 // 2, ones(Rational{Int}, 4), 4)
        @test ss6.qₛ == [1 // 2]
        @test ss6.weights == ones(Rational{Int}, 4, 1)
        @test ss6.N == 4

        # Convenience constructor with rank=2, D=1: kron([1],[1])=[1] → eff weights=ones
        ss7 = SpinMultipole(1 // 4, ones(Rational{Int}, 4), 4; rank=2)
        @test ss7.qₛ == reshape([1 // 4], 1, 1)
        @test ss7.weights == ones(Rational{Int}, 4, 1)

        # AssertionError: 0-dimensional qₛ (RANK=0)
        @test_throws AssertionError SpinMultipole(fill(1 // 2), ones(Rational{Int}, 4, 1), 4)
        # ArgumentError: non-square qₛ (size (2,3) → D=2 but second dim is 3)
        @test_throws ArgumentError SpinMultipole(
            Rational{Int}[1 0 0; 0 1 0], ones(Rational{Int}, 4, 2), 4
        )
        # ArgumentError: asymmetric qₛ (qₛ[1,2] ≠ qₛ[2,1])
        @test_throws ArgumentError SpinMultipole(
            Rational{Int}[1 2; 3 1], ones(Rational{Int}, 4, 2), 4
        )
        # AssertionError: weights rows ≠ N
        @test_throws AssertionError SpinMultipole([1 // 2], ones(Rational{Int}, 3, 1), 4)
    end

    @testset "sym of SpinMultipole" begin
        # Spin-1/2, N=4, RANK=1, D=1, uniform rational weights
        dofo1 = dof_object(Spin(1 // 2))
        w1 = ones(Rational{Int}, 4)
        ss1 = SpinMultipole(1 // 2, w1, 4)
        ms1 = sym(ss1, dofo1)
        @test ms1.dofo == dofo1
        @test ms1.cycles == [(; qₛ=ss1.qₛ, weights=ss1.weights, N=4, atol=0.0, rtol=0.0)]
        @test ms1.check == check_multipole
        @test ms1.apply == apply_multipole
        @test ms1.factors == ones(1)

        # Spin-1, N=3, RANK=1, D=1, non-uniform weights, custom tolerances
        dofo2 = dof_object(Spin(1 // 1))
        w2 = Rational{Int}[1, 2, 1]
        ss2 = SpinMultipole(0 // 1, w2, 3; atol=1e-8, rtol=1e-8)
        ms2 = sym(ss2, dofo2)
        @test ms2.dofo == dofo2
        @test ms2.cycles == [(; qₛ=ss2.qₛ, weights=ss2.weights, N=3, atol=1e-8, rtol=1e-8)]
        @test ms2.check == check_multipole
        @test ms2.apply == apply_multipole
        @test ms2.factors == ones(1)

        # Spin-1/2, RANK=2, D=1: quadrupole-like symmetry
        dofo3 = dof_object(Spin(1 // 2))
        w3 = Rational{Int}[1, 1, 1]
        ss3 = SpinMultipole(3 // 4, w3, 3; rank=2)
        ms3 = sym(ss3, dofo3)
        @test ms3.dofo == dofo3
        @test ms3.cycles == [(; qₛ=ss3.qₛ, weights=ss3.weights, N=3, atol=0.0, rtol=0.0)]
        @test ms3.check == check_multipole
        @test ms3.apply == apply_multipole
        @test ms3.factors == ones(1)

        # Non-Spin DoFObject should throw
        dofo4 = DoFObject(:Emoji, (:🥳, :🙈))
        @test_throws AssertionError sym(ss1, dofo4)
    end

    @testset "SpinInversion constructor" begin
        p1 = SpinInversion(1, 4)
        @test p1.z == 1
        @test p1.N == 4

        p2 = SpinInversion(-1, 6)
        @test p2.z == -1
        @test p2.N == 6

        # Invalid parity quantum number should throw
        @test_throws AssertionError SpinInversion(0, 4)
        @test_throws AssertionError SpinInversion(2, 4)
    end

    @testset "sym of SpinInversion" begin
        # Spin-1/2, N=2: combos_spin_sum(1//2, 0, 2) = [(; N0=1, N1=1, N=2)]
        dofo1 = dof_object(Spin(1 // 2))
        sites1 = collect(1:2)
        cycle1 = [
            (; is_flipped=false, sites=sites1, N0=1, N1=1, N=2),
            (; is_flipped=true, sites=sites1, N0=1, N1=1, N=2),
        ]
        for z in [1, -1]
            Z_sym1 = sym(SpinInversion(z, 2), dofo1)
            @test Z_sym1.dofo == dofo1
            @test Z_sym1.cycles == cycle1
            @test Z_sym1.check == check_flip
            @test Z_sym1.apply == apply_flip
            @test Z_sym1.factors == [z^0, z^1]
        end

        # Spin-1, N=2: combos_spin_sum(1//1, 0, 2) gives two combos, which collapse into a
        # single `WeightedCounts` cycle -- so the group has one cycle per flip, not one per
        # (flip, signature) pair.
        WC = SymBasis.SymGroups.WeightedCounts
        dofo2 = dof_object(Spin(1 // 1))
        sites2 = collect(1:2)
        wc2 = WC(((0, 1, 2),), (2,), [(0, 2, 0), (1, 0, 1)])
        cycle2 = [
            (; is_flipped=false, sites=sites2, wc=wc2, N=2),
            (; is_flipped=true, sites=sites2, wc=wc2, N=2),
        ]
        for z in [1, -1]
            Z_sym2 = sym(SpinInversion(z, 2), dofo2)
            @test Z_sym2.dofo == dofo2
            @test Z_sym2.cycles == cycle2
            @test Z_sym2.check == check_flip
            @test Z_sym2.apply == apply_flip
            @test Z_sym2.factors == [z^0, z^1]

            # Same sector as the uncollapsed representation: the Sz = 0 states of two
            # spin-1 sites are |0,2⟩, |1,1⟩ and |2,0⟩, of which the flip-even/odd
            # combination keeps two resp. one.
            states = basis(dofo2, 2, Z_sym2).states
            @test states == (z == 1 ?
                             [BaseInt(UInt(2); base=3), BaseInt(UInt(4); base=3)] :
                             [BaseInt(UInt(2); base=3)])
        end
    end

    @testset "Translational constructor" begin
        t1 = Translational(1, [2, 3, 1])
        @test t1.k == 1
        @test t1.perm == [2, 3, 1]

        @test_throws AssertionError Translational(0, [1, 2, 3])
        @test_throws AssertionError Translational(0, [2, 2, 1])
    end

    @testset "sym of Translational" begin
        @testset "without BitPermutation" begin
            dofo1 = DoFObject(:Emoji, (:🥳, :🙈, :👀))
            perm1 = [2, 3, 1]
            for k in 0:(length(perm1)-1)
                transl_sym1ₛ = sym(Translational(k, perm1), dofo1)
                @test transl_sym1ₛ.dofo == dofo1
                @test [c.perm for c in transl_sym1ₛ.cycles] == [
                    [1, 2, 3], perm1, perm1[perm1]
                ]
                @test [c.invperm for c in transl_sym1ₛ.cycles] == [
                    Base.invperm([1, 2, 3]),
                    Base.invperm(perm1),
                    Base.invperm(perm1[perm1])
                ]
                @test transl_sym1ₛ.check == check_perm
                @test transl_sym1ₛ.apply == apply_perm
                @test transl_sym1ₛ.factors ≈ [
                    cispi(-2 * r * k / length(perm1))
                    for r in 0:(length(perm1)-1)
                ]
            end
        end

        @testset "with BitPermutation" begin
            dofo2 = DoFObject(:YinYang, (:⚫️, :⚪️))
            perm2 = [2, 1]
            cycles = [
                (; perm=BitPermutation{UInt}(1:length(perm2) |> collect)),
                (; perm=BitPermutation{UInt}(perm2))
            ]
            for k in 0:(length(perm2)-1)
                transl_sym2ₛ = sym(Translational(k, perm2), dofo2)
                @test transl_sym2ₛ.dofo == dofo2
                @test all(
                    transl_sym2ₛ.cycles[i].perm.vector == cycles[i].perm.vector
                    for i in 1:length(transl_sym2ₛ.cycles)
                )
                @test transl_sym2ₛ.check == check_perm
                @test transl_sym2ₛ.apply == apply_perm
                @test transl_sym2ₛ.factors ≈ [
                    cispi(-2 * r * k / length(perm2))
                    for r in 0:(length(perm2)-1)
                ]
            end
        end

        @testset "early exit" begin
            dofo3 = DoFObject(:Test, (:A, :B, :C))
            perm3 = [2, 3, 1, 5, 6, 4]
            for k in 0:(length(perm3)÷2-1)
                transl_sym3ₛ = sym(Translational(k, perm3), dofo3)
                @test transl_sym3ₛ.dofo == dofo3
                @test [c.perm for c in transl_sym3ₛ.cycles] == [
                    1:length(perm3) |> collect,
                    perm3,
                    perm3[perm3],
                ]
                @test transl_sym3ₛ.check == check_perm
                @test transl_sym3ₛ.apply == apply_perm
                @test transl_sym3ₛ.factors ≈ [
                    cispi(-2 * r * k / (length(perm3) ÷ 2))
                    for r in 0:(length(perm3)÷2-1)
                ]
            end
        end

        @testset "SpinlessFermion" begin
            dofo4 = dof_object(SpinlessFermion())
            perm4 = [2, 1]
            transl_sym4 = sym(Translational(1, perm4), dofo4)

            @test transl_sym4.dofo == dofo4
            @test all(
                transl_sym4.cycles[i].perm.vector == BitPermutation{UInt}(perm_k(perm4, i - 1)).vector
                for i in 1:length(transl_sym4.cycles)
            )
            @test transl_sym4.check == check_perm
            @test transl_sym4.phase == phase_perm_fermionic
            @test transl_sym4.factors ≈ [cispi(-2 * r / length(perm4)) for r in 0:(length(perm4)-1)]

            state = bi"11"2
            transformed_state = transl_sym4.apply(transl_sym4.cycles[2], state)
            phase = transl_sym4.phase(transl_sym4.cycles[2], state)
            @test transformed_state == state
            @test phase == -1
        end

        @testset "SpinfulFermion" begin
            dofo5 = dof_object(SpinfulFermion(1 // 2, 2)) # B=4
            perm5 = [2, 1]
            transl_sym5 = sym(Translational(1, perm5), dofo5)

            @test transl_sym5.dofo == dofo5
            # B=4 (not 2): cycles carry a plain perm vector (not BitPermutation), plus a
            # per-digit occupation-parity lookup for the fermionic phase.
            @test [c.perm for c in transl_sym5.cycles] == [[1, 2], perm5]
            @test all(c.parity == (false, true, true, false) for c in transl_sym5.cycles)
            @test transl_sym5.check == check_perm
            @test transl_sym5.phase == phase_perm_fermionic
            @test transl_sym5.factors ≈ [cispi(-2 * r / length(perm5)) for r in 0:(length(perm5)-1)]

            # site1 = down-only (digit1), site2 = up-only (digit2); swapping them is an odd
            # permutation of 2 occupied (odd-parity) digits, so the phase is -1.
            state = bi"12"4
            transformed_state = transl_sym5.apply(transl_sym5.cycles[2], state)
            phase = transl_sym5.phase(transl_sym5.cycles[2], state)
            @test transformed_state == bi"21"4
            @test phase == -1
        end

    end

    @testset "SpatialReflection constructor" begin
        p1 = SpatialReflection(-1, [4, 3, 2, 1])
        @test p1.p == -1
        @test p1.perm == [4, 3, 2, 1]

        @test_throws AssertionError SpatialReflection(0, [4, 3, 2, 1])
        @test_throws AssertionError SpatialReflection(1, [1, 2, 3, 4])
        @test_throws AssertionError SpatialReflection(1, [2, 2, 3, 1])
    end

    @testset "sym of SpatialReflection" begin
        dofo1 = dof_object(Spin(1 // 2))
        q_nums1 = [-1, 1]
        perm1 = [5, 4, 3, 2, 1]
        cycles1 = [
            (; perm=BitPermutation{UInt}(1:length(perm1) |> collect)),
            (; perm=BitPermutation{UInt}(perm1))
        ]
        refl_sym1ₛ = [
            sym(SpatialReflection(p, perm1), dofo1) for p in q_nums1
        ]
        for (i, qᵢ) in enumerate(q_nums1)
            refl_symᵢ = refl_sym1ₛ[i]
            @test refl_symᵢ.dofo == dofo1
            @test all(
                refl_symᵢ.cycles[j].perm.vector == cycles1[j].perm.vector
                for j in 1:length(refl_symᵢ.cycles)
            )
            @test refl_symᵢ.check == check_perm
            @test refl_symᵢ.apply == apply_perm
            @test refl_symᵢ.factors ≈ [qᵢ^0, qᵢ^1]
        end

        dofo2 = DoFObject(:Emoji, (:🥳, :🙈, :👀, :🍀))
        q_nums2 = [1, -1]
        perm2 = [4, 3, 2, 1]
        refl_sym2ₛ = [
            sym(SpatialReflection(p, perm2), dofo2) for p in q_nums2
        ]
        for (i, qᵢ) in enumerate(q_nums2)
            refl_symᵢ = refl_sym2ₛ[i]
            @test refl_symᵢ.dofo == dofo2
            @test [c.perm for c in refl_symᵢ.cycles] == [
                1:length(perm2) |> collect, perm2,
            ]
            @test refl_symᵢ.check == check_perm
            @test refl_symᵢ.apply == apply_perm
            @test refl_symᵢ.factors ≈ [qᵢ^0, qᵢ^1]
        end

        @testset "SpinlessFermion" begin
            dofo3 = dof_object(SpinlessFermion())
            perm3 = [2, 1]

            for p in [-1, 1]
                refl_sym3 = sym(SpatialReflection(p, perm3), dofo3)
                @test refl_sym3.dofo == dofo3
                @test all(
                    refl_sym3.cycles[i].perm.vector == BitPermutation{UInt}(perm_k(perm3, i - 1)).vector
                    for i in 1:length(refl_sym3.cycles)
                )
                @test refl_sym3.check == check_perm
                @test refl_sym3.phase == phase_perm_fermionic
                @test refl_sym3.factors ≈ [p^0, p^1]
            end

            state = bi"11"2
            refl_sym3 = sym(SpatialReflection(1, perm3), dofo3)
            transformed_state = refl_sym3.apply(refl_sym3.cycles[2], state)
            phase = refl_sym3.phase(refl_sym3.cycles[2], state)
            @test transformed_state == state
            @test phase == -1
        end

        @testset "SpinfulFermion" begin
            dofo4 = dof_object(SpinfulFermion(1 // 2, 2)) # B=4
            perm4 = [2, 1]

            for p in [-1, 1]
                refl_sym4 = sym(SpatialReflection(p, perm4), dofo4)
                @test refl_sym4.dofo == dofo4
                @test [c.perm for c in refl_sym4.cycles] == [[1, 2], perm4]
                @test all(c.parity == (false, true, true, false) for c in refl_sym4.cycles)
                @test refl_sym4.check == check_perm
                @test refl_sym4.phase == phase_perm_fermionic
                @test refl_sym4.factors ≈ [p^0, p^1]
            end

            # site1 = down-only (digit1), site2 = up-only (digit2); reflecting swaps them,
            # an odd permutation of 2 occupied (odd-parity) digits, so the phase is -1.
            refl_sym4 = sym(SpatialReflection(1, perm4), dofo4)
            state = bi"12"4
            transformed_state = refl_sym4.apply(refl_sym4.cycles[2], state)
            phase = refl_sym4.phase(refl_sym4.cycles[2], state)
            @test transformed_state == bi"21"4
            @test phase == -1
        end

    end

    @testset "Rotational constructor" begin
        r1 = Rotational(1, [2, 4, 1, 3])
        @test r1.r == 1
        @test r1.perm == [2, 4, 1, 3]

        r2 = Rotational(0, [3, 6, 9, 2, 5, 8, 1, 4, 7])
        @test r2.r == 0
        @test r2.perm == [3, 6, 9, 2, 5, 8, 1, 4, 7]

        # Identity permutation not allowed
        @test_throws AssertionError Rotational(1, 1:4 |> collect)
        # Duplicate elements not allowed
        @test_throws AssertionError Rotational(1, 1:9 |> collect)
    end

    @testset "sym of Rotational" begin
        @testset "without BitPermutation" begin
            dofo1 = DoFObject(:Emoji, (:A, :B, :C))
            perm1 = [3, 6, 9, 2, 5, 8, 1, 4, 7] # 90 degrees rotation for 3x3 square lattice
            R1 = 4
            for r in 0:(R1-1)
                rot_sym1 = sym(Rotational(r, perm1), dofo1)
                @test rot_sym1.dofo == dofo1
                @test [c.perm for c in rot_sym1.cycles] == [
                    1:length(perm1) |> collect,
                    perm1,
                    perm1[perm1],
                    perm1[perm1[perm1]]
                ]
                @test rot_sym1.check == check_perm
                @test rot_sym1.apply == apply_perm
                @test rot_sym1.factors ≈ [
                    cispi(-2 * i * r / R1)
                    for i in 0:(R1-1)
                ]
            end
        end

        @testset "with BitPermutation" begin
            dofo2 = dof_object(Spin(1 // 2))
            perm2 = [2, 4, 1, 3]  # order 4
            R2 = 4
            cycles2 = [
                (; perm=BitPermutation{UInt}(perm_k(perm2, 0))),
                (; perm=BitPermutation{UInt}(perm_k(perm2, 1))),
                (; perm=BitPermutation{UInt}(perm_k(perm2, 2))),
                (; perm=BitPermutation{UInt}(perm_k(perm2, 3))),
            ]
            for r in 0:(R2-1)
                rot_sym2 = sym(Rotational(r, perm2), dofo2)
                @test rot_sym2.dofo == dofo2
                @test all(
                    rot_sym2.cycles[i].perm.vector == cycles2[i].perm.vector
                    for i in 1:length(rot_sym2.cycles)
                )
                @test rot_sym2.check == check_perm
                @test rot_sym2.apply == apply_perm
                @test rot_sym2.factors ≈ [
                    cispi(-2 * i * r / R2)
                    for i in 0:(R2-1)
                ]
            end
        end

        @testset "SpinfulFermion" begin
            dofo3 = dof_object(SpinfulFermion(1 // 2, 2)) # B=4
            perm3 = [3, 6, 9, 2, 5, 8, 1, 4, 7] # 90 degrees rotation for 3x3 square lattice
            R3 = 4
            for r in 0:(R3-1)
                rot_sym3 = sym(Rotational(r, perm3), dofo3)
                @test rot_sym3.dofo == dofo3
                @test [c.perm for c in rot_sym3.cycles] == [
                    1:length(perm3) |> collect,
                    perm3,
                    perm3[perm3],
                    perm3[perm3[perm3]]
                ]
                @test all(c.parity == (false, true, true, false) for c in rot_sym3.cycles)
                @test rot_sym3.check == check_perm
                @test rot_sym3.phase == phase_perm_fermionic
                @test rot_sym3.factors ≈ [cispi(-2 * i * r / R3) for i in 0:(R3-1)]
            end
        end
    end

    @testset "TotalBosonicNumber constructor" begin
        # Test with zero particles
        pnc1 = TotalBosonicNumber(0, 4)
        @test pnc1.n_particles == 0
        @test pnc1.N == 4

        # Test with positive particles
        pnc2 = TotalBosonicNumber(3, 5)
        @test pnc2.n_particles == 3
        @test pnc2.N == 5

        # Test with large particle numbers
        pnc3 = TotalBosonicNumber(100, 10)
        @test pnc3.n_particles == 100
        @test pnc3.N == 10

        # Test with different integer types
        pnc4 = TotalBosonicNumber(Int8(2), Int32(3))
        @test pnc4.n_particles == 2
        @test pnc4.N == 3

        # Invalid: negative particles should throw AssertionError
        @test_throws AssertionError TotalBosonicNumber(-1, 4)
        @test_throws AssertionError TotalBosonicNumber(-10, 5)
    end

    @testset "sym of TotalBosonicNumber" begin
        # Boson with max occupancy 3, 2 sites, 2 total particles
        dofo1 = dof_object(Boson(3))
        pnc1 = TotalBosonicNumber(2, 2)
        N_sym1 = sym(pnc1, dofo1)

        @test N_sym1.dofo == dofo1
        @test N_sym1.check == check_Nₛ
        @test N_sym1.apply == apply_Nₛ
        @test length(N_sym1.cycles) >= 1
        @test all(haskey(c, :N) for c in N_sym1.cycles)
        @test all(c.N == 2 for c in N_sym1.cycles)
        @test length(N_sym1.factors) == length(N_sym1.cycles)
        @test all(isone, N_sym1.factors)  # All factors should be 1.0

        # Boson with max occupancy 2, 3 sites, 1 total particle
        dofo2 = dof_object(Boson(2))
        pnc2 = TotalBosonicNumber(1, 3)
        N_sym2 = sym(pnc2, dofo2)

        @test N_sym2.dofo == dofo2
        @test N_sym2.check == check_Nₛ
        @test N_sym2.apply == apply_Nₛ
        # For 1 particle distributed among 3 sites: only one configuration
        # (N0=2, N1=1, N=3) meaning 2 sites empty, 1 site has 1 particle
        @test length(N_sym2.cycles) == 1
        @test all(isone, N_sym2.factors)

        # Boson with max occupancy 1, 2 sites, 0 total particles
        dofo3 = dof_object(Boson(1))
        pnc3 = TotalBosonicNumber(0, 2)
        N_sym3 = sym(pnc3, dofo3)

        @test N_sym3.dofo == dofo3
        @test N_sym3.check == check_Nₛ
        @test N_sym3.apply == apply_Nₛ
        # For 0 particles: only one configuration (N0=2, N1=0, N=2)
        @test length(N_sym3.cycles) == 1
        @test all(isone, N_sym3.factors)

        # Boson with max occupancy 5, 4 sites, 3 total particles
        dofo4 = dof_object(Boson(5))
        pnc4 = TotalBosonicNumber(3, 4)
        N_sym4 = sym(pnc4, dofo4)

        @test N_sym4.dofo == dofo4
        @test N_sym4.check == check_Nₛ
        @test N_sym4.apply == apply_Nₛ
        # Multiple configurations possible for 3 particles on 4 sites
        @test length(N_sym4.cycles) >= 1
        @test all(c.N == 4 for c in N_sym4.cycles)
        @test length(N_sym4.factors) == length(N_sym4.cycles)
        @test all(isone, N_sym4.factors)
    end

    @testset "TotalSpinlessFermionicNumber constructor" begin
        pnf1 = TotalSpinlessFermionicNumber(0, 4)
        @test pnf1.n_particles == 0
        @test pnf1.N == 4

        pnf2 = TotalSpinlessFermionicNumber(3, 5)
        @test pnf2.n_particles == 3
        @test pnf2.N == 5

        pnf3 = TotalSpinlessFermionicNumber(Int8(2), Int32(6))
        @test pnf3.n_particles == 2
        @test pnf3.N == 6

        @test_throws AssertionError TotalSpinlessFermionicNumber(-1, 4)
        @test_throws AssertionError TotalSpinlessFermionicNumber(5, 4)
    end

    @testset "sym of TotalSpinlessFermionicNumber" begin
        dofo1 = dof_object(SpinlessFermion())
        pnf1 = TotalSpinlessFermionicNumber(2, 4)
        N_sym1 = sym(pnf1, dofo1)

        @test N_sym1.dofo == dofo1
        @test N_sym1.check == check_Nₛ
        @test N_sym1.apply == apply_Nₛ
        @test all(c.N == 4 for c in N_sym1.cycles)
        @test length(N_sym1.factors) == length(N_sym1.cycles)
        @test all(isone, N_sym1.factors)

        # Exactly one occupancy pattern count tuple for N=4, n_particles=0.
        dofo2 = dof_object(SpinlessFermion(T=UInt32, Ti=Int32))
        pnf2 = TotalSpinlessFermionicNumber(0, 4)
        N_sym2 = sym(pnf2, dofo2)

        @test N_sym2.dofo == dofo2
        @test N_sym2.check == check_Nₛ
        @test N_sym2.apply == apply_Nₛ
        @test length(N_sym2.cycles) == 1
        @test all(c.N == 4 for c in N_sym2.cycles)
        @test all(isone, N_sym2.factors)

        # The spinless fermion number symmetry is only valid on :SpinlessFermion dofo.
        @test_throws AssertionError sym(TotalSpinlessFermionicNumber(1, 2), dof_object(Boson(1)))
    end

    @testset "TotalSpinfulFermionicNumber constructor" begin
        pnf1 = TotalSpinfulFermionicNumber(1, 1, 2)
        @test pnf1.n_up == 1
        @test pnf1.n_down == 1
        @test pnf1.N == 2

        pnf2 = TotalSpinfulFermionicNumber(0, 2, 3)
        @test pnf2.n_up == 0
        @test pnf2.n_down == 2
        @test pnf2.N == 3

        pnf3 = TotalSpinfulFermionicNumber(Int8(1), Int8(0), Int32(3))
        @test pnf3.n_up == 1
        @test pnf3.n_down == 0
        @test pnf3.N == 3

        @test_throws AssertionError TotalSpinfulFermionicNumber(-1, 0, 2)
        @test_throws AssertionError TotalSpinfulFermionicNumber(0, -1, 2)
        @test_throws AssertionError TotalSpinfulFermionicNumber(2, 2, 3)
    end

    @testset "sym of TotalSpinfulFermionicNumber" begin
        dofo1 = dof_object(SpinfulFermion(1 // 2, 2))

        # N=2, n_up=1, n_down=1: two digit-count signatures ("down+up" and
        # "empty+doublon"), collapsed into a single cycle testing `N_up` and `N_down`
        # directly via per-digit weight tables.
        N_sym1 = sym(TotalSpinfulFermionicNumber(1, 1, 2), dofo1)
        @test N_sym1.dofo == dofo1
        @test N_sym1.check == check_Nₛ
        @test N_sym1.apply == apply_Nₛ
        @test N_sym1.cycles == [(;
            wc=SymBasis.SymGroups.WeightedCounts(
                ((0, 0, 1, 1), (0, 1, 0, 1)), (1, 1), [(0, 1, 1, 0), (1, 0, 0, 1)]
            ),
            N=2
        )]
        @test length(N_sym1.factors) == length(N_sym1.cycles)
        @test all(isone, N_sym1.factors)

        # The collapse must not change the sector: |↓↑⟩, |↑↓⟩, |0,↑↓⟩ and |↑↓,0⟩ are the
        # four N_up = N_down = 1 states of two sites.
        @test basis(dofo1, 2, N_sym1).states ==
              [BaseInt(UInt(v); base=4) for v in (3, 6, 9, 12)]

        # N=3, n_up=1, n_down=0: only one digit-count cycle (2 empties, 1 up-only)
        N_sym2 = sym(TotalSpinfulFermionicNumber(1, 0, 3), dofo1)
        @test N_sym2.dofo == dofo1
        @test N_sym2.check == check_Nₛ
        @test N_sym2.apply == apply_Nₛ
        @test all(c.N == 3 for c in N_sym2.cycles)
        @test length(N_sym2.factors) == length(N_sym2.cycles)
        @test all(isone, N_sym2.factors)

        # Only valid on a :SpinfulFermion dofo.
        @test_throws AssertionError sym(TotalSpinfulFermionicNumber(1, 1, 2), dof_object(SpinlessFermion()))

        # Only valid on a spin-1/2 SpinfulFermion (exactly 2 distinct projections).
        dofo_spin1 = dof_object(SpinfulFermion(1 // 1, 2))
        @test_throws AssertionError sym(TotalSpinfulFermionicNumber(1, 1, 2), dofo_spin1)
    end

    @testset "FermionicSpinInversion constructor" begin
        z1 = FermionicSpinInversion(1, 4)
        @test z1.z == 1
        @test z1.N == 4

        z2 = FermionicSpinInversion(-1, 6)
        @test z2.z == -1
        @test z2.N == 6

        # Invalid parity quantum number should throw
        @test_throws AssertionError FermionicSpinInversion(0, 4)
        @test_throws AssertionError FermionicSpinInversion(2, 4)
    end

    @testset "sym of FermionicSpinInversion" begin
        dofo1 = dof_object(SpinfulFermion(1 // 2, 2))
        sites1 = collect(1:2)
        # r=0: identity relabel/sign_lut. r=1: swap down(digit1)/up(digit2), doublon(digit3)
        # picks up a -1 sign (binomial(2,2)=1 is odd), empty/singly-occupied do not.
        cycle1 = [
            (; relabel=(0, 1, 2, 3), sign_lut=(1, 1, 1, 1), sites=sites1),
            (; relabel=(0, 2, 1, 3), sign_lut=(1, 1, 1, -1), sites=sites1),
        ]
        for z in [1, -1]
            Z_sym1 = sym(FermionicSpinInversion(z, 2), dofo1)
            @test Z_sym1.dofo == dofo1
            @test Z_sym1.cycles == cycle1
            @test Z_sym1.check == check_perm
            @test Z_sym1.factors == [z^0, z^1]
        end

        # Concrete apply+phase check: site1=doublon (digit3), site2=down-only (digit1).
        # Under the swap relabel, the doublon stays a doublon (relabel[4]=3) while the
        # down-only site becomes up-only (relabel[2]=2); the doublon alone contributes the
        # sign, so the total phase is sign_lut[4] * sign_lut[2] = (-1) * 1 = -1.
        Z_sym1 = sym(FermionicSpinInversion(1, 2), dofo1)
        state = bi"13"4
        cyc = Z_sym1.cycles[2]
        @test Z_sym1.apply(cyc, state) == bi"23"4
        @test Z_sym1.phase(cyc, state) == -1

        # Only valid on a :SpinfulFermion dofo.
        @test_throws AssertionError sym(FermionicSpinInversion(1, 2), dof_object(Boson(1)))
    end

    @testset "sector-state enumeration" begin
        # `basis` scans the candidate states in order and relies on them arriving ascending
        # and duplicate-free. Multi-signature sectors are enumerated one signature block at
        # a time and merged, so those are the interesting cases.
        candidates(sg, ::Type{V}, N) where {V} =
            SymBasis.SymGroups._candidate_states(sg.check, sg.cycles, V, N)

        cases = [
            ("boson B=3 N=6 n=6",
                dof_object(Boson(2)), 6, TotalBosonicNumber(6, 6)),
            ("boson B=4 N=5 n=7",
                dof_object(Boson(3)), 5, TotalBosonicNumber(7, 5)),
            ("spinful B=4 N=5 (2,3)",
                dof_object(SpinfulFermion(1 // 2, 2)), 5,
                TotalSpinfulFermionicNumber(2, 3, 5)),
            ("spin-1 B=3 N=5 Sz=0",
                dof_object(Spin(1 // 1)), 5, TotalMagnetization(0, 5)),
            ("spin-1/2 B=2 N=6 Sz=0",
                dof_object(Spin(1 // 2)), 6, TotalMagnetization(0, 6)),
        ]

        for (name, dofo, N, ss) in cases
            sg = sym(ss, dofo)
            B = length(dofo)
            V = typeof(BaseInt(UInt(0); base=B))
            cand = candidates(sg, V, N)

            @test cand !== nothing
            @test issorted(cand)
            @test allunique(cand)

            # The candidate set is a superset of the sector and a subset of all N-digit
            # states passing the check for some cycle -- here it is exactly the latter.
            brute = [
                bi for bi in BaseInt(UInt(0); base=B):BaseInt(UInt(B^N - 1); base=B)
                if any(c -> sg.check(c, bi, true), sg.cycles)
            ]
            @test cand == brute

            # Every candidate really does enter the basis: these groups act trivially, so
            # the sector dimension equals the candidate count.
            @test length(basis(dofo, N, sg).states) == length(cand)
        end

        # Sector dimensions against independently computed expectations.
        # Bosons: the number of length-N occupation vectors with entries in 0..max_occ
        # summing to `total`, counted by a straightforward convolution.
        function n_bounded_vectors(N, max_occ, total)
            dp = zeros(Int, total + 1)
            dp[1] = 1
            for _ in 1:N
                nxt = zeros(Int, total + 1)
                for s in 0:total, d in 0:max_occ
                    s + d <= total && (nxt[s+d+1] += dp[s+1])
                end
                dp = nxt
            end
            return dp[total+1]
        end
        for (max_occ, N, total) in ((2, 6, 6), (3, 5, 7), (2, 7, 5))
            dofo_b = dof_object(Boson(max_occ))
            sg = sym(TotalBosonicNumber(total, N), dofo_b)
            @test length(basis(dofo_b, N, sg).states) ==
                  n_bounded_vectors(N, max_occ, total)
        end

        # Spinful fermions: choosing which sites hold an up and which hold a down are
        # independent, so dim = C(N, n_up) * C(N, n_down).
        dofo_sf = dof_object(SpinfulFermion(1 // 2, 2))
        for (nu, nd, N) in ((2, 3, 5), (3, 3, 6), (1, 4, 6))
            sg = sym(TotalSpinfulFermionicNumber(nu, nd, N), dofo_sf)
            @test length(basis(dofo_sf, N, sg).states) == binomial(N, nu) * binomial(N, nd)
        end
    end
end
