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

    @testset "sym of TotalMagnetization" begin
        dofo1 = dof_object(:Spin, 1 // 2)
        Sz_sym1ₛ = [sym(:TotalMagnetization, dofo1, Sz, 2) for Sz in -1//1:1//1]
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

        dofo2 = dof_object(:Spin, 1 // 1)
        Sz_sym2ₛ = [sym(:TotalMagnetization, dofo2, Sz, 3) for Sz in -3//2:3//2]
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

    @testset "sym of Translational" begin
        dofo1 = DoFObject(:Emoji, (:🥳, :🙈, :👀))
        perm1 = [2, 3, 1]
        for k in 0:(length(perm1)-1)
            transl_sym1ₛ = sym(:Translational, dofo1, k, perm1)
            @test transl_sym1ₛ.dofo == dofo1
            @test transl_sym1ₛ.cycles == [
                (; perm=[1, 2, 3]), (; perm=perm1), (; perm=perm1[perm1])
            ]
            @test transl_sym1ₛ.check == check_perm
            @test transl_sym1ₛ.apply == apply_perm
            @test transl_sym1ₛ.factors ≈ [
                exp(-2im * π * r * k / length(perm1))
                for r in 0:(length(perm1)-1)
            ]
        end

        dofo2 = DoFObject(:YinYang, (:⚫️, :⚪️))
        perm2 = [2, 1]
        cycles = [
            (; perm=BitPermutation{UInt}(1:length(perm2) |> collect)),
            (; perm=BitPermutation{UInt}(perm2))
        ]
        for k in 0:(length(perm2)-1)
            transl_sym2ₛ = sym(:Translational, dofo2, k, perm2)
            @test transl_sym2ₛ.dofo == dofo2
            @test all(
                transl_sym2ₛ.cycles[i].perm.vector == cycles[i].perm.vector
                for i in 1:length(transl_sym2ₛ.cycles)
            )
            @test transl_sym2ₛ.check == check_perm
            @test transl_sym2ₛ.apply == apply_perm
            @test transl_sym2ₛ.factors ≈ [
                exp(-2im * π * r * k / length(perm2))
                for r in 0:(length(perm2)-1)
            ]
        end
    end

    @testset "sym of SpatialReflection" begin
        dofo1 = dof_object(:Spin, 1 // 2)
        q_nums1 = [-1, 1]
        perm1 = [5, 4, 3, 2, 1]
        cycles1 = [
            (; perm=BitPermutation{UInt}(1:length(perm1) |> collect)),
            (; perm=BitPermutation{UInt}(perm1))
        ]
        refl_sym1ₛ = [
            sym(:SpatialReflection, dofo1, p, perm1) for p in q_nums1
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
            sym(:SpatialReflection, dofo2, p, perm2) for p in q_nums2
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
end
