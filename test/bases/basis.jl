@testset "Testing Basis..." begin
    @testset "Construction of Basis" begin

    end

    @testset "basis without any symmetry" begin
        N1 = 2
        dofo1 = dof_object(:Spin, 1 // 2)
        states1, norms1 = basis(dofo1, N1; is_sorted=true)
        @test states1 == [bi"0"2, bi"1"2, bi"10"2, bi"11"2]
        @test norms1 == ones(Float64, 2^N1)

        N2 = 3
        states2, norms2 = basis(dofo1, N2; is_sorted=true)
        @test states2 == [
            bi"0"2,
            bi"1"2,
            bi"10"2,
            bi"11"2,
            bi"100"2,
            bi"101"2,
            bi"110"2,
            bi"111"2
        ]
        @test norms2 == ones(Float64, 2^N2)

        N3 = 2
        dofo3 = dof_object(:Spin, 1 // 1)
        states3, norms3 = basis(dofo3, N3; is_sorted=true)
        @test states3 == [
            bi"0"3,
            bi"1"3,
            bi"2"3,
            bi"10"3,
            bi"11"3,
            bi"12"3,
            bi"20"3,
            bi"21"3,
            bi"22"3
        ]
        @test norms3 == ones(Float64, 3^N3)
    end

    @testset "basis with one symmetry" begin
        @testset "spin-1/2 with Sz symmetry" begin
            N = 3
            dofo = dof_object(:Spin, 1 // 2)
            sg = sym(:TotalMagnetization, dofo, -1 // 2, N)
            states, norms = basis(dofo, N, sg; is_sorted=true)
            @test states == [bi"001"2, bi"010"2, bi"100"2]
            @test norms == ones(Float64, 3)
        end

        @testset "spin-1 with Sz symmetry" begin
            N = 2
            dofo = dof_object(:Spin, 1 // 1)
            sg = sym(:TotalMagnetization, dofo, 0 // 1, N)
            states, norms = basis(dofo, N, sg; is_sorted=true)
            @test states == [bi"02"3, bi"11"3, bi"20"3]
            @test norms == ones(Float64, 3)
        end

        @testset "spin-1/2 with translational symmetry" begin
            N = 4
            dofo = dof_object(:Spin, 1 // 2)
            perm = [2, 3, 4, 1] # cyclic translation

            @testset "k = 0 for N = 4" begin
                sg = sym(:Translational, dofo, 0, perm)
                states, norms = basis(dofo, N, sg; is_sorted=true)
                @test states == [
                    bi"0000"2,
                    bi"1000"2,
                    bi"1010"2,
                    bi"1011"2,
                    bi"1100"2,
                    bi"1111"2
                ]
                @test norms == Float64[16, 4, 8, 4, 4, 16]
            end

            @testset "k = 1" begin
                sg = sym(:Translational, dofo, 1, perm)
                states, norms = basis(dofo, N, sg; is_sorted=true)
                @test states == [
                    bi"1000"2,
                    bi"1011"2,
                    bi"1100"2
                ]
                @test norms == Float64[4, 4, 4]
            end
        end

        @testset "spin-1 with translational symmetry" begin
            N = 3
            dofo = dof_object(:Spin, 1 // 1)
            perm = [2, 3, 1] # cyclic translation

            @testset "k = 0 for N = 3" begin
                sg = sym(:Translational, dofo, 0, perm)
                states, norms = basis(dofo, N, sg; is_sorted=true)
                @test states == [
                    bi"000"3,
                    bi"002"3,
                    bi"010"3,
                    bi"011"3,
                    bi"102"3,
                    bi"111"3,
                    bi"120"3,
                    bi"121"3,
                    bi"122"3,
                    bi"220"3,
                    bi"222"3
                ]
                @test norms == Float64[9, 3, 3, 3, 3, 9, 3, 3, 3, 3, 9]
            end

            @testset "k = 1" begin
                sg = sym(:Translational, dofo, 1, perm)
                states, norms = basis(dofo, N, sg; is_sorted=true)
                @test states == [
                    bi"002"3,
                    bi"010"3,
                    bi"011"3,
                    bi"102"3,
                    bi"120"3,
                    bi"121"3,
                    bi"122"3,
                    bi"220"3
                ]
                @test norms == Float64[3, 3, 3, 3, 3, 3, 3, 3]
            end
        end

        @testset "spin-1/2 with spatial reflection symmetry" begin
            N = 3
            dofo = dof_object(:Spin, 1 // 2)
            perm = [3, 2, 1] # reflection

            sg = sym(:SpatialReflection, dofo, 1, perm)
            states, norms = basis(dofo, N, sg; is_sorted=true)
            @test states == [
                bi"000"2,
                bi"010"2,
                bi"100"2,
                bi"101"2,
                bi"110"2,
                bi"111"2
            ]
            @test norms == Float64[4, 4, 2, 4, 2, 4]
        end

        @testset "spin-1 with spatial reflection symmetry" begin
            N = 2
            dofo = dof_object(:Spin, 2 // 1)
            perm = [2, 1] # reflection

            sg = sym(:SpatialReflection, dofo, -1, perm)
            states, norms = basis(dofo, N, sg; is_sorted=true)
            @test states == [
                bi"03"5,
                bi"10"5,
                bi"13"5,
                bi"14"5,
                bi"20"5,
                bi"21"5,
                bi"23"5,
                bi"40"5,
                bi"42"5,
                bi"43"5
            ]
            @test norms == Float64[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
        end
    end
    @testset "basis with multiple symmetries + check" begin
        @testset "spin-1/2 with Sz and translational symmetries" begin
            N = 4
            dofo = dof_object(:Spin, 1 // 2)
            perm = [2, 3, 4, 1] # cyclic translation

            @testset "k = 0 and Sz = 0 for N = 4" begin
                sg1 = sym(:TotalMagnetization, dofo, 0 // 1, N)
                sg2 = sym(:Translational, dofo, 0, perm)
                csg = sg1 ∘ sg2
                b = basis(dofo, N, csg; is_sorted=true)
                @test is_commutative(b, csg)
                @test b.states == [bi"1010"2, bi"1100"2]
                @test b.norms == Float64[8, 4]
            end

            @testset "k = 1 and Sz = 0 for N = 4" begin
                sg1 = sym(:TotalMagnetization, dofo, 0 // 1, N)
                sg2 = sym(:Translational, dofo, 1, perm)
                csg = sg1 ∘ sg2
                b = basis(dofo, N, csg; is_sorted=true)
                @test is_commutative(b, csg)
                @test b.states == [bi"1100"2]
                @test b.norms == Float64[4,]
            end

            @testset "k = 0 and Sz = -1 for N = 4" begin
                sg1 = sym(:TotalMagnetization, dofo, -1 // 1, N)
                sg2 = sym(:Translational, dofo, 0, perm)
                csg = sg1 ∘ sg2
                b = basis(dofo, N, csg; is_sorted=true)
                @test is_commutative(b, csg)
                @test b.states == [bi"1000"2,]
                @test b.norms == Float64[4,]
            end

            @testset "k = 3 and Sz = -1 for N = 4" begin
                sg1 = sym(:TotalMagnetization, dofo, -1 // 1, N)
                sg2 = sym(:Translational, dofo, 3, perm)
                csg = sg1 ∘ sg2
                b = basis(dofo, N, csg; is_sorted=true)
                @test is_commutative(b, csg)
                @test b.states == [bi"1000"2,]
                @test b.norms == Float64[4,]
            end
        end

        @testset "spin-1 with Sz, translational and spatial reflection symmetries" begin
            N = 4
            dofo = dof_object(:Spin, 1 // 1)
            perm_T = [2, 3, 4, 1] # cyclic translation
            perm_R = [4, 3, 2, 1] # reflection

            @testset "k = 0, Sz = 0 and R = 1 for N = 4" begin
                sg1 = sym(:TotalMagnetization, dofo, 0 // 1, N)
                sg2 = sym(:Translational, dofo, 0, perm_T)
                sg3 = sym(:SpatialReflection, dofo, 1, perm_R)
                csg = sg1 ∘ sg2 ∘ sg3
                b = basis(dofo, N, csg; is_sorted=true)
                @test is_commutative(b, csg)
                @test b.states == [bi"121"3, bi"1111"3, bi"1120"3, bi"2002"3, bi"2020"3]
                @test b.norms == Float64[16, 64, 8, 16, 32]
            end

            @testset "k = 1, Sz = 0 and R = 1 for N = 4" begin
                sg1 = sym(:TotalMagnetization, dofo, 0 // 1, N)
                sg2 = sym(:Translational, dofo, 1, perm_T)
                sg3 = sym(:SpatialReflection, dofo, -1, perm_R)
                csg = sg1 ∘ sg2 ∘ sg3
                b = basis(dofo, N, csg; is_sorted=true)
                @test !is_commutative(b, csg)
            end

            @testset "k = 3, Sz = 0 and R = 1 for N = 4" begin
                sg1 = sym(:TotalMagnetization, dofo, 0 // 1, N)
                sg2 = sym(:Translational, dofo, 3, perm_T)
                sg3 = sym(:SpatialReflection, dofo, 1, perm_R)
                csg = sg1 ∘ sg2 ∘ sg3
                b = basis(dofo, N, csg; is_sorted=true)
                @test !is_commutative(b, csg)
            end
        end
    end

    @testset "representative with SymGroup" begin
        @testset "spin-1/2 with Sz symmetry" begin
            @testset "Sz = -1/2 for N = 3" begin
                N = 3
                dofo = dof_object(:Spin, 1 // 2)
                sg = sym(:TotalMagnetization, dofo, -1 // 2, N)

                test_states = [bi"001"2, bi"010"2, bi"100"2]
                test_factors = ones(Float64, 3)

                for (state, factor) in zip(test_states, test_factors)
                    rep_state, rep_factor = representative(state, sg)
                    @test rep_state == state
                    @test rep_factor == factor
                end
            end
        end

        @testset "spin-1 with Sz symmetry" begin
            @testset "Sz = 0 for N = 2" begin
                N = 2
                dofo = dof_object(:Spin, 1 // 1)
                sg = sym(:TotalMagnetization, dofo, 0 // 1, N)

                test_states = [bi"02"3, bi"11"3, bi"20"3]
                test_factors = ones(Float64, 3)

                for (state, factor) in zip(test_states, test_factors)
                    rep_state, rep_factor = representative(state, sg)
                    @test rep_state == state
                    @test rep_factor == factor
                end
            end
        end

        @testset "spin-1/2 with translational symmetry" begin
            @testset "k = 1 for N = 4" begin
                N = 4
                dofo = dof_object(:Spin, 1 // 2)
                perm = [2, 3, 4, 1] # cyclic translation
                sg = sym(:Translational, dofo, 1, perm)

                test_states = [bi"0001"2, bi"0111"2, bi"0110"2]
                test_reps = [bi"1000"2, bi"1011"2, bi"1100"2]
                test_factors = ComplexF64[-1im, -1im, 1im]

                for (i, state) in enumerate(test_states)
                    rep_state, rep_factor = representative(state, sg)
                    @test rep_state == test_reps[i]
                    @test rep_factor ≈ test_factors[i]
                end
            end
        end

        @testset "spin-1 with translational symmetry" begin
            @testset "k = 1 for N = 3" begin
                N = 3
                dofo = dof_object(:Spin, 1 // 1)
                perm = [2, 3, 1] # cyclic translation
                sg = sym(:Translational, dofo, 1, perm)

                test_states = [bi"001"3, bi"020"3, bi"101"3, bi"012"3]
                test_reps = [bi"010"3, bi"002"3, bi"011"3, bi"120"3]
                test_factors = ComplexF64[
                    exp(im * 2π / 3),
                    exp(-im * 2π / 3),
                    exp(im * 2π / 3),
                    exp(im * 2π / 3)
                ]

                for (i, state) in enumerate(test_states)
                    rep_state, rep_factor = representative(state, sg)
                    @test rep_state == test_reps[i]
                    @test rep_factor ≈ test_factors[i]
                end
            end
        end

        @testset "spin-1/2 with spatial reflection symmetry" begin
            @testset "R = -1 for N = 3" begin
                N = 3
                dofo = dof_object(:Spin, 1 // 2)
                perm = [3, 2, 1] # reflection
                sg = sym(:SpatialReflection, dofo, -1, perm)

                test_states = [bi"001"2, bi"011"2]
                test_reps = [bi"100"2, bi"110"2]
                test_factors = Float64[-1, -1]

                for (i, state) in enumerate(test_states)
                    rep_state, rep_factor = representative(state, sg)
                    @test rep_state == test_reps[i]
                    @test rep_factor ≈ test_factors[i]
                end
            end
        end

        @testset "spin-1 with spatial reflection symmetry" begin
            @testset "R = -1 for N = 2" begin
                N = 2
                dofo = dof_object(:Spin, 1 // 1)
                perm = [2, 1] # reflection
                sg = sym(:SpatialReflection, dofo, -1, perm)

                test_states = [bi"01"3, bi"20"3, bi"21"3]
                test_reps = [bi"10"3, bi"2"3, bi"21"3]
                test_factors = Float64[-1, -1, 1]

                for (i, state) in enumerate(test_states)
                    rep_state, rep_factor = representative(state, sg)
                    @test rep_state == test_reps[i]
                    @test rep_factor ≈ test_factors[i]
                end
            end
        end
    end

    @testset "representative with CombSymGroup" begin
        @testset "spin-1/2 with Sz, translational and spatial reflection symmetries" begin
            N = 4
            dofo = dof_object(:Spin, 1 // 2)
            perm_T = [2, 3, 4, 1] # cyclic translation
            perm_R = [4, 3, 2, 1] # reflection

            @testset "Sz = 0, k = 2, R = -1 for N = 4" begin
                sg1 = sym(:TotalMagnetization, dofo, 0 // 1, N)
                sg2 = sym(:Translational, dofo, 2, perm_T)
                sg3 = sym(:SpatialReflection, dofo, -1, perm_R)
                csg = sg1 ∘ sg2 ∘ sg3

                test_states = [bi"0101"2,]
                test_reps = [bi"1010"2,]
                test_factors = ComplexF64[-1,]

                for (i, state) in enumerate(test_states)
                    rep_state, rep_factor = representative(state, csg)
                    @test rep_state == test_reps[i]
                    @test rep_factor ≈ test_factors[i]
                end
            end

            @testset "Sz = 1, k = 0, R = 1 for N = 4" begin
                sg1 = sym(:TotalMagnetization, dofo, 1 // 1, N)
                sg2 = sym(:Translational, dofo, 0, perm_T)
                sg3 = sym(:SpatialReflection, dofo, 1, perm_R)
                csg = sg1 ∘ sg2 ∘ sg3

                test_states = [bi"1110"2,]
                test_reps = [bi"1011"2,]
                test_factors = ComplexF64[1,]

                for (i, state) in enumerate(test_states)
                    rep_state, rep_factor = representative(state, csg)
                    @test rep_state == test_reps[i]
                    @test rep_factor ≈ test_factors[i]
                end
            end
        end
    end
end
