@testset "Testing auxiliary functions of Miscs..." begin
    @testset "combos_spin_sum" begin
        res1 = combos_spin_sum(1 // 2, 0, 4)
        @test length(res1) == 1
        @test res1[1] == (N0=2, N1=2, N=4)

        res2 = combos_spin_sum(1 // 2, 1 // 2, 8)
        @test length(res2) == 0

        res3 = combos_spin_sum(1 // 2, 2, 8)
        @test length(res3) == 1
        @test res3[1] == (N0=2, N1=6, N=8)

        res4 = combos_spin_sum(1 // 1, 0, 8)
        @test length(res4) == 5
        @test all(
            r == res4[id_r]
            for (id_r, r) in enumerate(
                [
                (N0=0, N1=8, N2=0, N=8),
                (N0=1, N1=6, N2=1, N=8),
                (N0=2, N1=4, N2=2, N=8),
                (N0=3, N1=2, N2=3, N=8),
                (N0=4, N1=0, N2=4, N=8)
            ]
            )
        )

        res5 = combos_spin_sum(3 // 2, 1 // 2, 5)
        @test length(res5) == 6
        @test all(
            [
            r == res5[id_r]
            for (id_r, r) in enumerate(
                [
                (N0=0, N1=2, N2=3, N3=0, N=5),
                (N0=0, N1=3, N2=1, N3=1, N=5),
                (N0=1, N1=0, N2=4, N3=0, N=5),
                (N0=1, N1=1, N2=2, N3=1, N=5),
                (N0=1, N1=2, N2=0, N3=2, N=5),
                (N0=2, N1=0, N2=1, N3=2, N=5)
            ]
            )
        ]
        )

    end

    @testset "perm_k" begin
        arr = [3, 1, 2]

        res0 = perm_k(arr, 0)
        @test length(res0) == 3
        @test res0 == collect(1:length(arr))

        res1 = perm_k(arr, 2)
        @test length(res1) == 3
        @test all(
            perm_k(arr, id_res) == res
            for (id_res, res) in enumerate(
                [
                [3, 1, 2],
                [2, 3, 1],
                [1, 2, 3]
            ]
            )
        )
    end

    @testset "perm_wrapper" begin
        using BitPermutations: BitPermutation
        perm = [3, 1, 2]

        res1 = perm_wrapper(perm, 2)
        @test res1 isa BitPermutation{UInt64}

        res2 = perm_wrapper(perm, 10)
        @test res2 == perm
    end
end
