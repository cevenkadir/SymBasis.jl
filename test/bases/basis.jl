# Version constant: true when running Julia < 1.13
const IS_PRE_V113 = VERSION.major == 1 && VERSION.minor < 13

# Select a value based on Julia version (< 1.13 → pre, >= 1.13 → post)
vsel(pre, post) = IS_PRE_V113 ? pre : post

# Helper function to test that unsorted basis matches sorted basis
function test_unsorted_basis(dofo, N, args...; sorted_states, sorted_norms)
    states_unsorted, norms_unsorted = basis(dofo, N, args...; is_sorted=false)
    sorted_indices = sortperm(states_unsorted)
    @test states_unsorted[sorted_indices] == sorted_states
    @test norms_unsorted[sorted_indices] == sorted_norms
end

# Helper function to test representative states
function test_representatives(test_states, expected_reps, expected_factors, sg)
    for (i, state) in enumerate(test_states)
        rep_state, rep_factor = representative(state, sg)
        @test rep_state == expected_reps[i]
        @test rep_factor ≈ expected_factors[i]
    end
end

# Helper to compute a basis, optionally assert is_commutative, assert states/norms,
# and call test_unsorted_basis. Returns the Basis object.
function test_basis_result(dofo, N, args...;
    expected_states, expected_norms,
    check_commutative=false)
    b = basis(dofo, N, args...; is_sorted=true)
    check_commutative && @test is_commutative(b, last(args))
    @test b.states == expected_states
    @test b.norms == expected_norms
    test_unsorted_basis(dofo, N, args...; sorted_states=b.states, sorted_norms=b.norms)
    return b
end

@testset "Testing Basis..." begin
    @testset "Construction of Basis" begin
        # Test basic construction and iterator protocol
        N = 2
        dofo = dof_object(Spin(1 // 2))
        b = basis(dofo, N; is_sorted=true)

        # Test that Basis is properly constructed
        @test b isa Basis
        @test length(b.states) == 2^N
        @test length(b.norms) == 2^N

        # Test iterator protocol - destructuring
        states_unpacked, norms_unpacked = b
        @test states_unpacked == b.states
        @test norms_unpacked == b.norms

        # Test manual iteration
        iter_result1 = iterate(b)
        @test iter_result1 !== nothing
        @test iter_result1[1] == b.states
        @test iter_result1[2] == Val(:norms)

        iter_result2 = iterate(b, Val(:norms))
        @test iter_result2 !== nothing
        @test iter_result2[1] == b.norms
        @test iter_result2[2] == Val(:done)

        # Test that iteration terminates (tests the selected line)
        iter_result3 = iterate(b, Val(:done))
        @test iter_result3 === nothing

        # Test Base.summary
        summary_str = sprint(summary, b)
        @test occursin("Basis", summary_str)
        @test occursin("with", summary_str)
        @test occursin(string(length(b.states)), summary_str)
        @test occursin("states", summary_str)

        # Test Base.show with compact mode
        compact_str = sprint(show, b; context=:compact => true)
        @test occursin("Basis", compact_str)
        @test occursin("states=$(length(b.states))", compact_str)
        @test occursin("norms=$(length(b.norms))", compact_str)

        # Test Base.show without compact mode
        full_str = sprint(show, b)
        @test occursin("Basis", full_str)
        @test occursin("states =", full_str)
        @test occursin("norms  =", full_str)

        # Test Base.show with MIME"text/plain" for regular basis
        plain_str = sprint(show, MIME("text/plain"), b)
        @test occursin("Basis", plain_str)
        @test occursin("with $(length(b.states)) states", plain_str)
        @test occursin("states:", plain_str)
        @test occursin("norms :", plain_str)
        @test occursin("first", plain_str)
        @test occursin("(norm=", plain_str)

        # Test with empty basis
        empty_states = BaseInt{Int64,Int64,2}[]
        empty_norms = Float64[]
        empty_basis = Basis(empty_states, empty_norms)
        empty_str = sprint(show, MIME("text/plain"), empty_basis)
        @test occursin("with 0 states", empty_str)
        @test !occursin("first", empty_str)

        # Test with basis that has many states (to test truncation)
        N_large = 4
        b_large = basis(dofo, N_large; is_sorted=true)
        large_str = sprint(show, MIME("text/plain"), b_large; context=:limit => true)
        @test occursin("Basis", large_str)
        @test occursin("with $(length(b_large.states)) states", large_str)
        # Should show first 10 states and potentially ellipsis
        if length(b_large.states) > 10
            @test occursin("⋮", large_str)
        end

        # Test singular vs plural state/norm labels
        N_single = 1
        b_single = basis(dofo, N_single; is_sorted=true)
        single_str = sprint(show, MIME("text/plain"), b_single)
        @test occursin("with 2 states", single_str)
        @test occursin("first 2 states/norms:", single_str)
    end

    @testset "basis without any symmetry" begin
        N1 = 2
        dofo1 = dof_object(Spin(1 // 2))
        test_basis_result(dofo1, N1;
            expected_states=[bi"0"2, bi"1"2, bi"10"2, bi"11"2],
            expected_norms=ones(Float64, 2^N1)
        )

        N2 = 3
        test_basis_result(dofo1, N2;
            expected_states=[
                bi"0"2, bi"1"2, bi"10"2, bi"11"2, bi"100"2, bi"101"2, bi"110"2, bi"111"2
            ],
            expected_norms=ones(Float64, 2^N2)
        )

        N3 = 2
        dofo3 = dof_object(Spin(1 // 1))
        test_basis_result(dofo3, N3;
            expected_states=[
                bi"0"3, bi"1"3, bi"2"3, bi"10"3, bi"11"3, bi"12"3, bi"20"3, bi"21"3, bi"22"3
            ],
            expected_norms=ones(Float64, 3^N3)
        )
    end

    @testset "basis with one symmetry" begin
        @testset "spin-1/2 with Sz symmetry" begin
            N = 3
            dofo = dof_object(Spin(1 // 2))
            sg = sym(TotalMagnetization(-1 // 2, N), dofo)
            test_basis_result(dofo, N, sg;
                expected_states=[bi"001"2, bi"010"2, bi"100"2],
                expected_norms=ones(Float64, 3)
            )
        end

        @testset "spin-1 with Sz symmetry" begin
            N = 2
            dofo = dof_object(Spin(1 // 1))
            sg = sym(TotalMagnetization(0 // 1, N), dofo)
            test_basis_result(dofo, N, sg;
                expected_states=[bi"02"3, bi"11"3, bi"20"3],
                expected_norms=ones(Float64, 3)
            )
        end

        @testset "spin-1/2 with translational symmetry" begin
            N = 4
            dofo = dof_object(Spin(1 // 2))
            perm = [2, 3, 4, 1] # cyclic translation

            @testset "k = 0 for N = 4" begin
                sg = sym(Translational(0, perm), dofo)
                test_basis_result(dofo, N, sg;
                    expected_states=vsel(
                        [bi"0000"2, bi"1000"2, bi"1010"2, bi"1011"2, bi"1100"2, bi"1111"2],
                        [bi"0000"2, bi"0010"2, bi"0011"2, bi"0101"2, bi"1101"2, bi"1111"2]
                    ),
                    expected_norms=vsel(
                        Float64[16, 4, 8, 4, 4, 16], Float64[16, 4, 4, 8, 4, 16]
                    )
                )
            end

            @testset "k = 1" begin
                sg = sym(Translational(1, perm), dofo)
                test_basis_result(dofo, N, sg;
                    expected_states=vsel(
                        [bi"1000"2, bi"1011"2, bi"1100"2],
                        [bi"0010"2, bi"0011"2, bi"1101"2]
                    ),
                    expected_norms=Float64[4, 4, 4]
                )
            end
        end

        @testset "spin-1 with translational symmetry" begin
            N = 3
            dofo = dof_object(Spin(1 // 1))
            perm = [2, 3, 1] # cyclic translation

            @testset "k = 0 for N = 3" begin
                sg = sym(Translational(0, perm), dofo)
                test_basis_result(dofo, N, sg;
                    expected_states=vsel(
                        [bi"000"3, bi"002"3, bi"010"3, bi"011"3, bi"102"3, bi"111"3,
                            bi"120"3, bi"121"3, bi"122"3, bi"220"3, bi"222"3],
                        [bi"000"3, bi"001"3, bi"020"3, bi"021"3, bi"101"3, bi"111"3,
                            bi"120"3, bi"121"3, bi"122"3, bi"202"3, bi"222"3]
                    ),
                    expected_norms=Float64[9, 3, 3, 3, 3, 9, 3, 3, 3, 3, 9]
                )
            end

            @testset "k = 1" begin
                sg = sym(Translational(1, perm), dofo)
                test_basis_result(dofo, N, sg;
                    expected_states=vsel(
                        [bi"002"3, bi"010"3, bi"011"3, bi"102"3, bi"120"3, bi"121"3,
                            bi"122"3, bi"220"3],
                        [bi"001"3, bi"020"3, bi"021"3, bi"101"3, bi"120"3, bi"121"3,
                            bi"122"3, bi"202"3]
                    ),
                    expected_norms=Float64[3, 3, 3, 3, 3, 3, 3, 3]
                )
            end
        end

        @testset "spin-1/2 with spatial reflection symmetry" begin
            N = 3
            dofo = dof_object(Spin(1 // 2))
            perm = [3, 2, 1] # reflection

            sg = sym(SpatialReflection(1, perm), dofo)
            test_basis_result(dofo, N, sg;
                expected_states=vsel(
                    [bi"000"2, bi"010"2, bi"100"2, bi"101"2, bi"110"2, bi"111"2],
                    [bi"000"2, bi"001"2, bi"010"2, bi"011"2, bi"101"2, bi"111"2]
                ),
                expected_norms=vsel(Float64[4, 4, 2, 4, 2, 4], Float64[4, 2, 4, 2, 4, 4])
            )
        end

        @testset "spin-1 with spatial reflection symmetry" begin
            N = 2
            dofo = dof_object(Spin(2 // 1))
            perm = [2, 1] # reflection

            sg = sym(SpatialReflection(-1, perm), dofo)
            test_basis_result(dofo, N, sg;
                expected_states=vsel(
                    [bi"03"5, bi"10"5, bi"13"5, bi"14"5, bi"20"5,
                        bi"21"5, bi"23"5, bi"40"5, bi"42"5, bi"43"5],
                    [bi"10"5, bi"12"5, bi"20"5, bi"23"5, bi"24"5,
                        bi"30"5, bi"31"5, bi"40"5, bi"41"5, bi"43"5]
                ),
                expected_norms=Float64[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
            )
        end

        @testset "spin-1/2 with spin inversion symmetry" begin
            N = 2
            dofo = dof_object(Spin(1 // 2))

            for z in [1, -1]
                sg = sym(SpinInversion(z, N), dofo)
                # For spin-1/2, no state is its own flip, so both spin inversion sectors
                # have the same representative (one state from the pair {bi"01"2, bi"10"2})
                expected_rep = hash(bi"10"2) < hash(bi"01"2) ? bi"10"2 : bi"01"2
                test_basis_result(dofo, N, sg;
                    expected_states=[expected_rep],
                    expected_norms=Float64[2]
                )
            end
        end

        @testset "spin-1 with spin inversion symmetry" begin
            N = 2
            dofo = dof_object(Spin(1 // 1))

            @testset "z = 1" begin
                sg = sym(SpinInversion(1, N), dofo)
                # bi"11"3 maps to itself under flip (self-conjugate), so it's included
                # for z=1 (norm=4) but not z=-1 (norm=0)
                test_basis_result(dofo, N, sg;
                    expected_states=vsel([bi"2"3, bi"11"3], [bi"11"3, bi"20"3]),
                    expected_norms=vsel(Float64[2, 4], Float64[4, 2])
                )
            end

            @testset "z = -1" begin
                sg = sym(SpinInversion(-1, N), dofo)
                # bi"11"3 is excluded (norm=0 for z=-1), leaving one state from the pair
                test_basis_result(dofo, N, sg;
                    expected_states=vsel([bi"2"3], [bi"20"3]),
                    expected_norms=Float64[2]
                )
            end
        end

        @testset "spin-1/2 with spin inversion symmetry for N=4" begin
            N = 4
            dofo = dof_object(Spin(1 // 2))

            for z in [1, -1]
                sg = sym(SpinInversion(z, N), dofo)
                # Sz=0 sector has C(4,2)=6 states forming 3 flip pairs → 3 representatives
                test_basis_result(dofo, N, sg;
                    expected_states=vsel(
                        [bi"1001"2, bi"1010"2, bi"1100"2],
                        [bi"0011"2, bi"0101"2, bi"0110"2]
                    ),
                    expected_norms=Float64[2, 2, 2]
                )
            end
        end
    end
    @testset "basis with multiple symmetries + check" begin
        @testset "spin-1/2 with Sz and translational symmetries" begin
            N = 4
            dofo = dof_object(Spin(1 // 2))
            perm = [2, 3, 4, 1] # cyclic translation

            @testset "k = 0 and Sz = 0 for N = 4" begin
                csg = sym(TotalMagnetization(0 // 1, N), dofo) ∘
                      sym(Translational(0, perm), dofo)
                test_basis_result(dofo, N, csg;
                    expected_states=vsel([bi"1010"2, bi"1100"2], [bi"0011"2, bi"0101"2]),
                    expected_norms=vsel(Float64[8, 4], Float64[4, 8]),
                    check_commutative=true
                )
            end

            @testset "k = 1 and Sz = 0 for N = 4" begin
                csg = sym(TotalMagnetization(0 // 1, N), dofo) ∘
                      sym(Translational(1, perm), dofo)
                test_basis_result(dofo, N, csg;
                    expected_states=vsel([bi"1100"2], [bi"0011"2]),
                    expected_norms=Float64[4],
                    check_commutative=true
                )
            end

            @testset "k = 0 and Sz = -1 for N = 4" begin
                csg = sym(TotalMagnetization(-1 // 1, N), dofo) ∘
                      sym(Translational(0, perm), dofo)
                test_basis_result(dofo, N, csg;
                    expected_states=vsel([bi"1000"2], [bi"0010"2]),
                    expected_norms=Float64[4],
                    check_commutative=true
                )
            end

            @testset "k = 3 and Sz = -1 for N = 4" begin
                csg = sym(TotalMagnetization(-1 // 1, N), dofo) ∘
                      sym(Translational(3, perm), dofo)
                test_basis_result(dofo, N, csg;
                    expected_states=vsel([bi"1000"2], [bi"0010"2]),
                    expected_norms=Float64[4],
                    check_commutative=true
                )
            end
        end

        @testset "spin-1 with Sz, translational and spatial reflection symmetries" begin
            N = 4
            dofo = dof_object(Spin(1 // 1))
            perm_T = [2, 3, 4, 1] # cyclic translation
            perm_R = [4, 3, 2, 1] # reflection

            @testset "k = 0, Sz = 0 and R = 1 for N = 4" begin
                csg = sym(TotalMagnetization(0 // 1, N), dofo) ∘
                      sym(Translational(0, perm_T), dofo) ∘
                      sym(SpatialReflection(1, perm_R), dofo)
                test_basis_result(dofo, N, csg;
                    expected_states=vsel(
                        [bi"0121"3, bi"1111"3, bi"1120"3, bi"2002"3, bi"2020"3],
                        [bi"0022"3, bi"0121"3, bi"0202"3, bi"1111"3, bi"2011"3]
                    ),
                    expected_norms=vsel(
                        Float64[16, 64, 8, 16, 32],
                        Float64[16, 16, 32, 64, 8]
                    ),
                    check_commutative=true
                )
            end

            @testset "k = 1, Sz = 0 and R = -1 for N = 4" begin
                sg1 = sym(TotalMagnetization(0 // 1, N), dofo)
                sg2 = sym(Translational(1, perm_T), dofo)
                sg3 = sym(SpatialReflection(-1, perm_R), dofo)
                csg = sg1 ∘ sg2 ∘ sg3
                b = basis(dofo, N, csg; is_sorted=true)
                @test !is_commutative(b, csg)
            end

            @testset "k = 3, Sz = 0 and R = 1 for N = 4" begin
                sg1 = sym(TotalMagnetization(0 // 1, N), dofo)
                sg2 = sym(Translational(3, perm_T), dofo)
                sg3 = sym(SpatialReflection(1, perm_R), dofo)
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
                dofo = dof_object(Spin(1 // 2))
                sg = sym(TotalMagnetization(-1 // 2, N), dofo)
                test_states = [bi"001"2, bi"010"2, bi"100"2]
                test_representatives(test_states, test_states, ones(Float64, 3), sg)
            end
        end

        @testset "spin-1 with Sz symmetry" begin
            @testset "Sz = 0 for N = 2" begin
                N = 2
                dofo = dof_object(Spin(1 // 1))
                sg = sym(TotalMagnetization(0 // 1, N), dofo)
                test_states = [bi"02"3, bi"11"3, bi"20"3]
                test_representatives(test_states, test_states, ones(Float64, 3), sg)
            end
        end

        @testset "spin-1/2 with translational symmetry" begin
            @testset "k = 1 for N = 4" begin
                N = 4
                dofo = dof_object(Spin(1 // 2))
                perm = [2, 3, 4, 1] # cyclic translation
                sg = sym(Translational(1, perm), dofo)
                test_states = [bi"0001"2, bi"0111"2, bi"0110"2]
                test_reps = vsel(
                    [bi"1000"2, bi"1011"2, bi"1100"2],
                    [bi"0010"2, bi"1101"2, bi"0011"2]
                )
                test_factors = vsel(
                    ComplexF64[-1im, -1im, 1im],
                    ComplexF64[1im, -1, -1im]
                )
                test_representatives(test_states, test_reps, test_factors, sg)
            end
        end

        @testset "spin-1 with translational symmetry" begin
            @testset "k = 1 for N = 3" begin
                N = 3
                dofo = dof_object(Spin(1 // 1))
                perm = [2, 3, 1] # cyclic translation
                sg = sym(Translational(1, perm), dofo)
                test_states = [bi"001"3, bi"020"3, bi"101"3, bi"012"3]
                test_reps = vsel(
                    [bi"010"3, bi"002"3, bi"011"3, bi"120"3],
                    [bi"001"3, bi"020"3, bi"101"3, bi"120"3]
                )
                test_factors = vsel(
                    ComplexF64[cis(2π / 3), cis(-2π / 3), cis(2π / 3), cis(2π / 3)],
                    ComplexF64[1, 1, 1, cis(2π / 3)]
                )
                test_representatives(test_states, test_reps, test_factors, sg)
            end
        end

        @testset "spin-1/2 with spatial reflection symmetry" begin
            @testset "R = -1 for N = 3" begin
                N = 3
                dofo = dof_object(Spin(1 // 2))
                perm = [3, 2, 1] # reflection
                sg = sym(SpatialReflection(-1, perm), dofo)
                test_states = vsel([bi"001"2, bi"011"2], [bi"100"2, bi"110"2])
                test_reps = vsel([bi"100"2, bi"110"2], [bi"001"2, bi"011"2])
                test_representatives(test_states, test_reps, Float64[-1, -1], sg)
            end
        end

        @testset "spin-1 with spatial reflection symmetry" begin
            @testset "R = -1 for N = 2" begin
                N = 2
                dofo = dof_object(Spin(1 // 1))
                perm = [2, 1] # reflection
                sg = sym(SpatialReflection(-1, perm), dofo)
                test_states = vsel([bi"01"3, bi"20"3, bi"21"3], [bi"10"3, bi"02"3, bi"21"3])
                test_reps = vsel([bi"10"3, bi"2"3, bi"21"3], [bi"01"3, bi"20"3, bi"21"3])
                test_representatives(test_states, test_reps, Float64[-1, -1, 1], sg)
            end
        end

        @testset "spin-1/2 with spin inversion symmetry" begin
            @testset "z = -1 for N = 2" begin
                N = 2
                dofo = dof_object(Spin(1 // 2))
                sg = sym(SpinInversion(-1, N), dofo)

                # Representative is whichever of the flip pair has the smaller hash
                test_states = [bi"01"2, bi"10"2]
                if hash(bi"10"2) < hash(bi"01"2)
                    test_reps = [bi"10"2, bi"10"2]
                    test_factors = Float64[-1, 1]
                else
                    test_reps = [bi"01"2, bi"01"2]
                    test_factors = Float64[1, -1]
                end

                test_representatives(test_states, test_reps, test_factors, sg)
            end
        end

        @testset "spin-1 with spin inversion symmetry" begin
            @testset "z = 1 for N = 2" begin
                N = 2
                dofo = dof_object(Spin(1 // 1))
                sg = sym(SpinInversion(1, N), dofo)
                test_states = [bi"2"3, bi"11"3, bi"20"3]
                test_reps = vsel([bi"2"3, bi"11"3, bi"2"3], [bi"20"3, bi"11"3, bi"20"3])
                test_representatives(test_states, test_reps, Float64[1, 1, 1], sg)
            end

            @testset "z = -1 for N = 2" begin
                N = 2
                dofo = dof_object(Spin(1 // 1))
                sg = sym(SpinInversion(-1, N), dofo)
                test_states = [bi"2"3, bi"11"3, bi"20"3]
                test_reps = vsel([bi"2"3, bi"11"3, bi"2"3], [bi"20"3, bi"11"3, bi"20"3])
                test_factors = vsel(Float64[1, 1, -1], Float64[-1, 1, 1])
                test_representatives(test_states, test_reps, test_factors, sg)
            end
        end
    end

    @testset "representative with CombSymGroup" begin
        @testset "spin-1/2 with Sz, translational and spatial reflection symmetries" begin
            N = 4
            dofo = dof_object(Spin(1 // 2))
            perm_T = [2, 3, 4, 1] # cyclic translation
            perm_R = [4, 3, 2, 1] # reflection

            @testset "Sz = 0, k = 2, R = -1 for N = 4" begin
                csg = sym(TotalMagnetization(0 // 1, N), dofo) ∘
                      sym(Translational(2, perm_T), dofo) ∘
                      sym(SpatialReflection(-1, perm_R), dofo)
                test_states = vsel([bi"0101"2], [bi"1010"2])
                test_reps = vsel([bi"1010"2], [bi"0101"2])
                test_representatives(test_states, test_reps, ComplexF64[-1], csg)
            end

            @testset "Sz = 1, k = 0, R = 1 for N = 4" begin
                csg = sym(TotalMagnetization(1 // 1, N), dofo) ∘
                      sym(Translational(0, perm_T), dofo) ∘
                      sym(SpatialReflection(1, perm_R), dofo)
                test_states = [bi"1110"2]
                test_reps = vsel([bi"1011"2], [bi"1101"2])
                test_representatives(test_states, test_reps, ComplexF64[1], csg)
            end
        end
    end

    @testset "basis with Rotational symmetry" begin
        # 2x2 square lattice, sites labeled row-major:  [1 2; 3 4]
        # 90-degree CW rotation: new site i receives old site perm_R2[i]
        #   [1 2]  ->  [3 1]
        #   [3 4]      [4 2]
        perm_R2 = [3, 1, 4, 2]

        # 3x3 square lattice, sites labeled row-major: [1 2 3; 4 5 6; 7 8 9]
        # 90-degree CW rotation:
        #   [1 2 3]       [7 4 1]
        #   [4 5 6]  ->   [8 5 2]
        #   [7 8 9]       [9 6 3]
        perm_R3 = [7, 4, 1, 8, 5, 2, 9, 6, 3]

        @testset "2x2 spin-1/2 with Rotational symmetry" begin
            N = 4
            dofo = dof_object(Spin(1 // 2))

            @testset "Rotational only" begin
                @testset "r = 0" begin
                    sg = sym(Rotational(0, perm_R2), dofo)
                    test_basis_result(dofo, N, sg;
                        expected_states=vsel(
                            [bi"0"2, bi"1000"2, bi"1001"2, bi"1011"2, bi"1100"2, bi"1111"2],
                            [bi"0"2, bi"10"2, bi"11"2, bi"110"2, bi"1101"2, bi"1111"2]
                        ),
                        expected_norms=vsel(
                            Float64[16, 4, 8, 4, 4, 16], Float64[16, 4, 4, 8, 4, 16]
                        )
                    )
                end

                @testset "r = 1" begin
                    sg = sym(Rotational(1, perm_R2), dofo)
                    test_basis_result(dofo, N, sg;
                        expected_states=vsel(
                            [bi"1000"2, bi"1011"2, bi"1100"2],
                            [bi"10"2, bi"11"2, bi"1101"2]
                        ),
                        expected_norms=Float64[4, 4, 4]
                    )
                end

                @testset "r = 2" begin
                    sg = sym(Rotational(2, perm_R2), dofo)
                    test_basis_result(dofo, N, sg;
                        expected_states=vsel(
                            [bi"1000"2, bi"1001"2, bi"1011"2, bi"1100"2],
                            [bi"10"2, bi"11"2, bi"110"2, bi"1101"2]
                        ),
                        expected_norms=vsel(Float64[4, 8, 4, 4], Float64[4, 4, 8, 4])
                    )
                end

                @testset "r = 3" begin
                    sg = sym(Rotational(3, perm_R2), dofo)
                    test_basis_result(dofo, N, sg;
                        expected_states=vsel(
                            [bi"1000"2, bi"1011"2, bi"1100"2],
                            [bi"10"2, bi"11"2, bi"1101"2]
                        ),
                        expected_norms=Float64[4, 4, 4]
                    )
                end
            end

            @testset "Sz = 0 and Rotational" begin
                sgSz = sym(TotalMagnetization(0 // 1, N), dofo)

                @testset "r = 0" begin
                    csg = sgSz ∘ sym(Rotational(0, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=vsel([bi"1001"2, bi"1100"2], [bi"11"2, bi"110"2]),
                        expected_norms=vsel(Float64[8, 4], Float64[4, 8]),
                        check_commutative=true
                    )
                end

                @testset "r = 1" begin
                    csg = sgSz ∘ sym(Rotational(1, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=vsel([bi"1100"2], [bi"11"2]),
                        expected_norms=Float64[4],
                        check_commutative=true
                    )
                end

                @testset "r = 2" begin
                    csg = sgSz ∘ sym(Rotational(2, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=vsel([bi"1001"2, bi"1100"2], [bi"11"2, bi"110"2]),
                        expected_norms=vsel(Float64[8, 4], Float64[4, 8]),
                        check_commutative=true
                    )
                end

                @testset "r = 3" begin
                    csg = sgSz ∘ sym(Rotational(3, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=vsel([bi"1100"2], [bi"11"2]),
                        expected_norms=Float64[4],
                        check_commutative=true
                    )
                end
            end

            @testset "Sz = 1 and Rotational" begin
                sgSz = sym(TotalMagnetization(1 // 1, N), dofo)
                # All 4 (3-up, 1-down) states form a single orbit of size 4
                for r in 0:3
                    @testset "r = $r" begin
                        csg = sgSz ∘ sym(Rotational(r, perm_R2), dofo)
                        test_basis_result(dofo, N, csg;
                            expected_states=vsel([bi"1011"2], [bi"1101"2]),
                            expected_norms=Float64[4],
                            check_commutative=true
                        )
                    end
                end
            end
        end

        @testset "2x2 spin-1 with Rotational symmetry" begin
            N = 4
            dofo = dof_object(Spin(1 // 1))

            @testset "Sz = 0 and Rotational" begin
                sgSz = sym(TotalMagnetization(0 // 1, N), dofo)

                @testset "r = 0" begin
                    csg = sgSz ∘ sym(Rotational(0, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=vsel(
                            [bi"22"3, bi"112"3, bi"121"3, bi"1111"3, bi"1120"3, bi"2002"3],
                            [bi"112"3, bi"121"3, bi"202"3, bi"1012"3, bi"1111"3, bi"2002"3]
                        ),
                        expected_norms=vsel(
                            Float64[4, 4, 4, 16, 4, 8], Float64[4, 4, 4, 4, 16, 8]
                        ),
                        check_commutative=true
                    )
                end

                @testset "r = 1" begin
                    csg = sgSz ∘ sym(Rotational(1, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=vsel(
                            [bi"22"3, bi"112"3, bi"121"3, bi"1120"3],
                            [bi"112"3, bi"121"3, bi"202"3, bi"1012"3]
                        ),
                        expected_norms=Float64[4, 4, 4, 4],
                        check_commutative=true
                    )
                end

                @testset "r = 2" begin
                    csg = sgSz ∘ sym(Rotational(2, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=vsel(
                            [bi"22"3, bi"112"3, bi"121"3, bi"1120"3, bi"2002"3],
                            [bi"112"3, bi"121"3, bi"202"3, bi"1012"3, bi"2002"3]
                        ),
                        expected_norms=Float64[4, 4, 4, 4, 8],
                        check_commutative=true
                    )
                end

                @testset "r = 3" begin
                    csg = sgSz ∘ sym(Rotational(3, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=vsel(
                            [bi"22"3, bi"112"3, bi"121"3, bi"1120"3],
                            [bi"112"3, bi"121"3, bi"202"3, bi"1012"3]
                        ),
                        expected_norms=Float64[4, 4, 4, 4],
                        check_commutative=true
                    )
                end
            end

            @testset "Sz = 2 and Rotational" begin
                sgSz = sym(TotalMagnetization(2 // 1, N), dofo)

                @testset "r = 0" begin
                    csg = sgSz ∘ sym(Rotational(0, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=vsel(
                            [bi"222"3, bi"2112"3, bi"2121"3],
                            [bi"1221"3, bi"2022"3, bi"2121"3]
                        ),
                        expected_norms=vsel(Float64[4, 8, 4], Float64[8, 4, 4]),
                        check_commutative=true
                    )
                end

                @testset "r = 1" begin
                    csg = sgSz ∘ sym(Rotational(1, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=vsel([bi"222"3, bi"2121"3], [bi"2022"3, bi"2121"3]),
                        expected_norms=Float64[4, 4],
                        check_commutative=true
                    )
                end

                @testset "r = 2" begin
                    csg = sgSz ∘ sym(Rotational(2, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=vsel(
                            [bi"222"3, bi"2112"3, bi"2121"3],
                            [bi"1221"3, bi"2022"3, bi"2121"3]
                        ),
                        expected_norms=vsel(Float64[4, 8, 4], Float64[8, 4, 4]),
                        check_commutative=true
                    )
                end

                @testset "r = 3" begin
                    csg = sgSz ∘ sym(Rotational(3, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=vsel([bi"222"3, bi"2121"3], [bi"2022"3, bi"2121"3]),
                        expected_norms=Float64[4, 4],
                        check_commutative=true
                    )
                end
            end
        end

        @testset "3x3 spin-1/2 with Rotational symmetry" begin
            N = 9
            dofo = dof_object(Spin(1 // 2))
            # Sz = 7//2: 8 up-spins, 1 down-spin out of 9 sites
            sgSz = sym(TotalMagnetization(7 // 2, N), dofo)

            @testset "r = 0" begin
                csg = sgSz ∘ sym(Rotational(0, perm_R3), dofo)
                test_basis_result(dofo, N, csg;
                    expected_states=vsel(
                        [bi"110111111"2, bi"111101111"2, bi"111111101"2],
                        [bi"11111111"2, bi"101111111"2, bi"111101111"2]
                    ),
                    expected_norms=vsel(Float64[4, 16, 4], Float64[4, 4, 16]),
                    check_commutative=true
                )
            end

            @testset "r = $r" for r in 1:3
                csg = sgSz ∘ sym(Rotational(r, perm_R3), dofo)
                test_basis_result(dofo, N, csg;
                    expected_states=vsel(
                        [bi"110111111"2, bi"111111101"2],
                        [bi"11111111"2, bi"101111111"2]
                    ),
                    expected_norms=Float64[4, 4],
                    check_commutative=true
                )
            end
        end

        @testset "3x3 spin-1 with Rotational symmetry" begin
            N = 9
            dofo = dof_object(Spin(1 // 1))

            @testset "Sz = 9 (all-up)" begin
                # All sites at maximum spin: unique state, version-independent
                sgSz = sym(TotalMagnetization(9 // 1, N), dofo)

                @testset "r = 0" begin
                    csg = sgSz ∘ sym(Rotational(0, perm_R3), dofo)
                    b = basis(dofo, N, csg; is_sorted=true)
                    @test is_commutative(b, csg)
                    @test length(b.states) == 1
                    @test b.states == [bi"222222222"3]
                    @test b.norms == Float64[16]
                end

                @testset "r = $r (empty sector)" for r in 1:3
                    csg = sgSz ∘ sym(Rotational(r, perm_R3), dofo)
                    b = basis(dofo, N, csg; is_sorted=true)
                    @test is_commutative(b, csg)
                    @test length(b.states) == 0
                end
            end

            @testset "Sz = 8 (8 up-spins, 1 zero-spin)" begin
                sgSz = sym(TotalMagnetization(8 // 1, N), dofo)

                @testset "r = 0" begin
                    csg = sgSz ∘ sym(Rotational(0, perm_R3), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=vsel(
                            [bi"222122222"3, bi"222212222"3, bi"222222221"3],
                            [bi"221222222"3, bi"222212222"3, bi"222222212"3]
                        ),
                        expected_norms=Float64[4, 16, 4],
                        check_commutative=true
                    )
                end

                @testset "r = $r" for r in 1:3
                    csg = sgSz ∘ sym(Rotational(r, perm_R3), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=vsel(
                            [bi"222122222"3, bi"222222221"3],
                            [bi"221222222"3, bi"222222212"3]
                        ),
                        expected_norms=Float64[4, 4],
                        check_commutative=true
                    )
                end
            end
        end
    end
end
