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
            @test Sz_symᵢ.apply == apply_Nₛ
            @test Sz_symᵢ.factors == factor2ₛ[i]
        end
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
            @test Z_sym2.apply == apply_flip
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
                @test transl_sym1ₛ.apply == apply_perm
                @test transl_sym1ₛ.factors ≈ [
                    cis(-2π * r * k / length(perm1))
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
                    cis(-2π * r * k / length(perm2))
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
                @test transl_sym3ₛ.apply == apply_perm
                @test transl_sym3ₛ.factors ≈ [
                    cis(-2π * r * k / (length(perm3) ÷ 2))
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
            @test refl_symᵢ.cycles == [
                (; perm=1:length(perm2) |> collect), (; perm=perm2),
            ]
            @test refl_symᵢ.check == check_perm
            @test refl_symᵢ.apply == apply_perm
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
                @test rot_sym1.apply == apply_perm
                @test rot_sym1.factors ≈ [
                    cis(-2π * i * r / R1)
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
                    cis(-2π * i * r / R2)
                    for i in 0:(R2-1)
                ]
            end
        end
    end
end
