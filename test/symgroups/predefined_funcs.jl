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
            @test Sz_symᵢ.apply == apply_Nₛ_generic
            @test Sz_symᵢ.factors == factor1ₛ[i]
        end

        dofo2 = dof_object(Spin(1 // 1))
        Sz_sym2ₛ = [sym(TotalMagnetization(Sz, 3), dofo2) for Sz in -3//2:3//2]
        cycle2ₛ = [
            [(; N0=3, N1=0, N2=0, N=3)],
            [(; N0=1, N1=2, N2=0, N=3), (; N0=2, N1=0, N2=1, N=3)],
            [(; N0=0, N1=2, N2=1, N=3), (; N0=1, N1=0, N2=2, N=3)],
            [(; N0=0, N1=0, N2=3, N=3)]
        ]
        factor2ₛ = [[1.0,], [1.0, 1.0], [1.0, 1.0], [1.0,]]
        for (i, Sz_symᵢ) in enumerate(Sz_sym2ₛ)
            @test Sz_symᵢ.dofo == dofo2
            @test Sz_symᵢ.cycles == cycle2ₛ[i]
            @test Sz_symᵢ.check == check_Nₛ
            @test Sz_symᵢ.apply == apply_Nₛ_generic
            @test Sz_symᵢ.factors == factor2ₛ[i]
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
        @test ms1.apply == apply_multipole_generic
        @test ms1.factors == ones(1)

        # Spin-1, N=3, RANK=1, D=1, non-uniform weights, custom tolerances
        dofo2 = dof_object(Spin(1 // 1))
        w2 = Rational{Int}[1, 2, 1]
        ss2 = SpinMultipole(0 // 1, w2, 3; atol=1e-8, rtol=1e-8)
        ms2 = sym(ss2, dofo2)
        @test ms2.dofo == dofo2
        @test ms2.cycles == [(; qₛ=ss2.qₛ, weights=ss2.weights, N=3, atol=1e-8, rtol=1e-8)]
        @test ms2.check == check_multipole
        @test ms2.apply == apply_multipole_generic
        @test ms2.factors == ones(1)

        # Spin-1/2, RANK=2, D=1: quadrupole-like symmetry
        dofo3 = dof_object(Spin(1 // 2))
        w3 = Rational{Int}[1, 1, 1]
        ss3 = SpinMultipole(3 // 4, w3, 3; rank=2)
        ms3 = sym(ss3, dofo3)
        @test ms3.dofo == dofo3
        @test ms3.cycles == [(; qₛ=ss3.qₛ, weights=ss3.weights, N=3, atol=0.0, rtol=0.0)]
        @test ms3.check == check_multipole
        @test ms3.apply == apply_multipole_generic
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
            @test Z_sym1.apply == apply_flip_generic
            @test Z_sym1.factors == [z^0, z^1]
        end

        # Spin-1, N=2: combos_spin_sum(1//1, 0, 2) gives two combos
        dofo2 = dof_object(Spin(1 // 1))
        sites2 = collect(1:2)
        cycle2 = [
            (; is_flipped=false, sites=sites2, N0=0, N1=2, N2=0, N=2),
            (; is_flipped=false, sites=sites2, N0=1, N1=0, N2=1, N=2),
            (; is_flipped=true, sites=sites2, N0=0, N1=2, N2=0, N=2),
            (; is_flipped=true, sites=sites2, N0=1, N1=0, N2=1, N=2),
        ]
        for z in [1, -1]
            Z_sym2 = sym(SpinInversion(z, 2), dofo2)
            @test Z_sym2.dofo == dofo2
            @test Z_sym2.cycles == cycle2
            @test Z_sym2.check == check_flip
            @test Z_sym2.apply == apply_flip_generic
            @test Z_sym2.factors == [z^0, z^0, z^1, z^1]
        end
    end

    @testset "sym of Translational" begin
        @testset "without BitPermutation" begin
            dofo1 = DoFObject(:Emoji, (:🥳, :🙈, :👀))
            perm1 = [2, 3, 1]
            for k in 0:(length(perm1)-1)
                transl_sym1ₛ = sym(Translational(k, perm1), dofo1)
                @test transl_sym1ₛ.dofo == dofo1
                @test transl_sym1ₛ.cycles == [
                    (; perm=[1, 2, 3]), (; perm=perm1), (; perm=perm1[perm1])
                ]
                @test transl_sym1ₛ.check == check_perm
                @test transl_sym1ₛ.apply == apply_perm_generic
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
                @test transl_sym2ₛ.apply == apply_perm_generic
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
                @test transl_sym3ₛ.cycles == [
                    (; perm=1:length(perm3) |> collect),
                    (; perm=perm3),
                    (; perm=perm3[perm3]),
                ]
                @test transl_sym3ₛ.check == check_perm
                @test transl_sym3ₛ.apply == apply_perm_generic
                @test transl_sym3ₛ.factors ≈ [
                    cispi(-2 * r * k / (length(perm3) ÷ 2))
                    for r in 0:(length(perm3)÷2-1)
                ]
            end
        end
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
            @test refl_symᵢ.apply == apply_perm_generic
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
            @test refl_symᵢ.cycles == [
                (; perm=1:length(perm2) |> collect), (; perm=perm2),
            ]
            @test refl_symᵢ.check == check_perm
            @test refl_symᵢ.apply == apply_perm_generic
            @test refl_symᵢ.factors ≈ [qᵢ^0, qᵢ^1]
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
                @test rot_sym1.cycles == [
                    (; perm=1:length(perm1) |> collect),
                    (; perm=perm1),
                    (; perm=perm1[perm1]),
                    (; perm=perm1[perm1[perm1]])
                ]
                @test rot_sym1.check == check_perm
                @test rot_sym1.apply == apply_perm_generic
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
                @test rot_sym2.apply == apply_perm_generic
                @test rot_sym2.factors ≈ [
                    cispi(-2 * i * r / R2)
                    for i in 0:(R2-1)
                ]
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
        @test N_sym1.apply == apply_Nₛ_generic
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
        @test N_sym2.apply == apply_Nₛ_generic
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
        @test N_sym3.apply == apply_Nₛ_generic
        # For 0 particles: only one configuration (N0=2, N1=0, N=2)
        @test length(N_sym3.cycles) == 1
        @test all(isone, N_sym3.factors)

        # Boson with max occupancy 5, 4 sites, 3 total particles
        dofo4 = dof_object(Boson(5))
        pnc4 = TotalBosonicNumber(3, 4)
        N_sym4 = sym(pnc4, dofo4)

        @test N_sym4.dofo == dofo4
        @test N_sym4.check == check_Nₛ
        @test N_sym4.apply == apply_Nₛ_generic
        # Multiple configurations possible for 3 particles on 4 sites
        @test length(N_sym4.cycles) >= 1
        @test all(c.N == 4 for c in N_sym4.cycles)
        @test length(N_sym4.factors) == length(N_sym4.cycles)
        @test all(isone, N_sym4.factors)
    end
end
