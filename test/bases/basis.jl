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

        iter_result3 = iterate(b, Val(:sg))
        @test iter_result3 !== nothing
        @test iter_result3[1] == b.sg
        @test iter_result3[2] == Val(:done)

        # Test that iteration terminates (tests the selected line)
        iter_result4 = iterate(b, Val(:done))
        @test iter_result4 === nothing

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

    @testset "isequal, == and hash for Basis" begin
        N = 2
        dofo = dof_object(Spin(1 // 2))

        b1 = basis(dofo, N; is_sorted=true)
        b2 = basis(dofo, N; is_sorted=true)

        # Basis with different norms
        b_diff_norms = Basis(b1.states, 2 .* b1.norms)

        # Basis with different states (sorted in descending order)
        b_diff_states = Basis(reverse(b1.states), b1.norms)

        # isequal: equal bases
        @test isequal(b1, b2)

        # isequal: different norms
        @test !isequal(b1, b_diff_norms)

        # isequal: different states
        @test !isequal(b1, b_diff_states)

        # ==: equal bases
        @test b1 == b2

        # ==: different norms
        @test !(b1 == b_diff_norms)

        # ==: different states
        @test !(b1 == b_diff_states)

        # hash: equal bases produce equal hashes
        @test hash(b1) == hash(b2)

        # hash: different norms produce different hashes
        @test hash(b1) != hash(b_diff_norms)

        # hash: different states produce different hashes
        @test hash(b1) != hash(b_diff_states)

        # hash with salt: consistent with isequal
        h = UInt(42)
        @test hash(b1, h) == hash(b2, h)
        @test hash(b1, h) != hash(b_diff_norms, h)
        @test hash(b1, h) != hash(b_diff_states, h)

        # isequal and == agree with each other
        @test isequal(b1, b2) == (b1 == b2)
        @test isequal(b1, b_diff_norms) == (b1 == b_diff_norms)
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

    @testset "basis without any symmetry (Boson)" begin
        # Boson(1) with 2 sites: base-2, 4 total states
        N1 = 2
        dofo1 = dof_object(Boson(1))
        test_basis_result(dofo1, N1;
            expected_states=[bi"00"2, bi"01"2, bi"10"2, bi"11"2],
            expected_norms=ones(Float64, 2^N1)
        )

        # Boson(2) with 2 sites: base-3, 9 total states
        N2 = 2
        dofo2 = dof_object(Boson(2))
        test_basis_result(dofo2, N2;
            expected_states=[
                bi"00"3, bi"01"3, bi"02"3, bi"10"3, bi"11"3, bi"12"3, bi"20"3, bi"21"3, bi"22"3
            ],
            expected_norms=ones(Float64, 3^N2)
        )

        # Boson(1) with 3 sites: base-2, 8 total states
        N3 = 3
        dofo3 = dof_object(Boson(1))
        test_basis_result(dofo3, N3;
            expected_states=[
                bi"000"2, bi"001"2, bi"010"2, bi"011"2, bi"100"2, bi"101"2, bi"110"2, bi"111"2
            ],
            expected_norms=ones(Float64, 2^N3)
        )
    end

    @testset "basis with TotalBosonicNumber" begin
        # Boson(1) with 2 sites, 1 particle: only states with sum=1
        # bi"01"2 and bi"10"2
        @testset "Boson(1), N=2, n_particles=1" begin
            dofo = dof_object(Boson(1))
            sg = sym(TotalBosonicNumber(1, 2), dofo)
            test_basis_result(dofo, 2, sg;
                expected_states=[bi"01"2, bi"10"2],
                expected_norms=ones(Float64, 2)
            )
        end

        # Boson(2) with 2 sites, 2 particles: states with sum=2
        # bi"02"3, bi"11"3, bi"20"3
        @testset "Boson(2), N=2, n_particles=2" begin
            dofo = dof_object(Boson(2))
            sg = sym(TotalBosonicNumber(2, 2), dofo)
            test_basis_result(dofo, 2, sg;
                expected_states=[bi"02"3, bi"11"3, bi"20"3],
                expected_norms=ones(Float64, 3)
            )
        end

        # Boson(1) with 3 sites, 0 particles: only state with sum=0
        # bi"000"2
        @testset "Boson(1), N=3, n_particles=0" begin
            dofo = dof_object(Boson(1))
            sg = sym(TotalBosonicNumber(0, 3), dofo)
            test_basis_result(dofo, 3, sg;
                expected_states=[bi"000"2],
                expected_norms=[1.0]
            )
        end

        # Boson(1) with 3 sites, 1 particle: states with sum=1
        # bi"001"2, bi"010"2, bi"100"2
        @testset "Boson(1), N=3, n_particles=1" begin
            dofo = dof_object(Boson(1))
            sg = sym(TotalBosonicNumber(1, 3), dofo)
            test_basis_result(dofo, 3, sg;
                expected_states=[bi"001"2, bi"010"2, bi"100"2],
                expected_norms=ones(Float64, 3)
            )
        end

        # Boson(2) with 3 sites, 1 particle: states with sum=1
        # bi"001"3, bi"010"3, bi"100"3
        @testset "Boson(2), N=3, n_particles=1" begin
            dofo = dof_object(Boson(2))
            sg = sym(TotalBosonicNumber(1, 3), dofo)
            test_basis_result(dofo, 3, sg;
                expected_states=[bi"001"3, bi"010"3, bi"100"3],
                expected_norms=ones(Float64, 3)
            )
        end

        # Boson(2) with 3 sites, 2 particles: states with sum=2
        # bi"002"3, bi"011"3, bi"020"3, bi"101"3, bi"110"3, bi"200"3
        @testset "Boson(2), N=3, n_particles=2" begin
            dofo = dof_object(Boson(2))
            sg = sym(TotalBosonicNumber(2, 3), dofo)
            test_basis_result(dofo, 3, sg;
                expected_states=[bi"002"3, bi"011"3, bi"020"3, bi"101"3, bi"110"3, bi"200"3],
                expected_norms=ones(Float64, 6)
            )
        end

        # Boson(1) with 4 sites, 2 particles: C(4,2)=6 states
        # bi"0011"2, bi"0101"2, bi"0110"2, bi"1001"2, bi"1010"2, bi"1100"2
        @testset "Boson(1), N=4, n_particles=2" begin
            dofo = dof_object(Boson(1))
            sg = sym(TotalBosonicNumber(2, 4), dofo)
            test_basis_result(dofo, 4, sg;
                expected_states=[bi"0011"2, bi"0101"2, bi"0110"2, bi"1001"2, bi"1010"2, bi"1100"2],
                expected_norms=ones(Float64, 6)
            )
        end

        # Boson(3) with 2 sites, 3 particles: states with sum=3
        # bi"03"4, bi"12"4, bi"21"4, bi"30"4
        @testset "Boson(3), N=2, n_particles=3" begin
            dofo = dof_object(Boson(3))
            sg = sym(TotalBosonicNumber(3, 2), dofo)
            test_basis_result(dofo, 2, sg;
                expected_states=[bi"03"4, bi"12"4, bi"21"4, bi"30"4],
                expected_norms=ones(Float64, 4)
            )
        end

        # Boson(2) with 2 sites, 0 particles: only state with sum=0
        # bi"00"3
        @testset "Boson(2), N=2, n_particles=0" begin
            dofo = dof_object(Boson(2))
            sg = sym(TotalBosonicNumber(0, 2), dofo)
            test_basis_result(dofo, 2, sg;
                expected_states=[bi"00"3],
                expected_norms=[1.0]
            )
        end
    end

    @testset "basis without any symmetry (SpinlessFermion)" begin
        N1 = 2
        dofo1 = dof_object(SpinlessFermion())
        test_basis_result(dofo1, N1;
            expected_states=[bi"0"2, bi"1"2, bi"10"2, bi"11"2],
            expected_norms=ones(Float64, 2^N1)
        )

        N2 = 3
        test_basis_result(dofo1, N2;
            expected_states=[
                bi"0"2, bi"1"2, bi"10"2, bi"11"2, bi"100"2, bi"101"2, bi"110"2,
                bi"111"2
            ],
            expected_norms=ones(Float64, 2^N2)
        )
    end

    @testset "basis with TotalSpinlessFermionicNumber" begin
        @testset "N=4, n_particles=2" begin
            N = 4
            dofo = dof_object(SpinlessFermion())
            sg = sym(TotalSpinlessFermionicNumber(2, N), dofo)
            test_basis_result(dofo, N, sg;
                expected_states=[bi"11"2, bi"101"2, bi"110"2, bi"1001"2, bi"1010"2, bi"1100"2],
                expected_norms=ones(Float64, 6)
            )
        end

        @testset "N=4, n_particles=0" begin
            N = 4
            dofo = dof_object(SpinlessFermion())
            sg = sym(TotalSpinlessFermionicNumber(0, N), dofo)
            test_basis_result(dofo, N, sg;
                expected_states=[bi"0"2],
                expected_norms=[1.0]
            )
        end
    end

    @testset "basis with spinless-fermion translation" begin
        N = 4
        dofo = dof_object(SpinlessFermion())
        perm = [2, 3, 4, 1] # cyclic translation

        @testset "n_particles=2, k=0" begin
            csg = sym(TotalSpinlessFermionicNumber(2, N), dofo) ∘
                  sym(Translational(0, perm), dofo)
            test_basis_result(dofo, N, csg;
                expected_states=[bi"11"2],
                expected_norms=Float64[4],
                check_commutative=true
            )

            test_states = [bi"0011"2, bi"1001"2]
            test_reps = [bi"11"2, bi"11"2]
            test_factors = Float64[1, -1]
            test_representatives(test_states, test_reps, test_factors, csg)
        end

        @testset "n_particles=2, k=1" begin
            csg = sym(TotalSpinlessFermionicNumber(2, N), dofo) ∘
                  sym(Translational(1, perm), dofo)
            test_basis_result(dofo, N, csg;
                expected_states=[bi"11"2, bi"101"2],
                expected_norms=Float64[4, 8],
                check_commutative=true
            )
        end
    end

    @testset "basis with spinless-fermion spatial reflection" begin
        N = 4
        dofo = dof_object(SpinlessFermion())
        perm = [4, 3, 2, 1] # reflection

        @testset "R = 1" begin
            sg = sym(SpatialReflection(1, perm), dofo)
            test_basis_result(dofo, N, sg;
                expected_states=[bi"0"2, bi"1"2, bi"10"2, bi"11"2, bi"101"2, bi"111"2,
                    bi"1011"2, bi"1111"2],
                expected_norms=Float64[4, 2, 2, 2, 2, 2, 2, 4]
            )
        end

        @testset "R = -1" begin
            sg = sym(SpatialReflection(-1, perm), dofo)
            test_basis_result(dofo, N, sg;
                expected_states=[bi"1"2, bi"10"2, bi"11"2, bi"101"2, bi"110"2, bi"111"2,
                    bi"1001"2, bi"1011"2],
                expected_norms=Float64[2, 2, 2, 2, 4, 2, 4, 2]
            )
        end

        @testset "n_particles=2 and R = 1" begin
            csg = sym(TotalSpinlessFermionicNumber(2, N), dofo) ∘
                  sym(SpatialReflection(1, perm), dofo)
            test_basis_result(dofo, N, csg;
                expected_states=[bi"11"2, bi"101"2],
                expected_norms=Float64[2, 2],
                check_commutative=true
            )
        end

        @testset "n_particles=2 and R = -1" begin
            csg = sym(TotalSpinlessFermionicNumber(2, N), dofo) ∘
                  sym(SpatialReflection(-1, perm), dofo)
            test_basis_result(dofo, N, csg;
                expected_states=[bi"11"2, bi"101"2, bi"110"2, bi"1001"2],
                expected_norms=Float64[2, 2, 4, 4],
                check_commutative=true
            )
        end
    end

    @testset "basis without any symmetry (SpinfulFermion)" begin
        # spin-1/2, max_occupancy=2 -> B=4 (digit0=empty, digit1=down, digit2=up, digit3=doublon)
        N1 = 1
        dofo1 = dof_object(SpinfulFermion(1 // 2, 2))
        test_basis_result(dofo1, N1;
            expected_states=[bi"0"4, bi"1"4, bi"2"4, bi"3"4],
            expected_norms=ones(Float64, 4^N1)
        )

        N2 = 2
        test_basis_result(dofo1, N2;
            expected_states=[
                bi"0"4, bi"1"4, bi"2"4, bi"3"4, bi"10"4, bi"11"4, bi"12"4, bi"13"4,
                bi"20"4, bi"21"4, bi"22"4, bi"23"4, bi"30"4, bi"31"4, bi"32"4, bi"33"4
            ],
            expected_norms=ones(Float64, 4^N2)
        )
    end

    @testset "basis with TotalSpinfulFermionicNumber" begin
        # N=2, n_up=1, n_down=1: the 4 ways to place one up- and one down-fermion on 2
        # sites -- either on the same site (a doublon, other site empty) or on different
        # sites (one up-only, one down-only), in either order.
        N = 2
        dofo = dof_object(SpinfulFermion(1 // 2, 2))
        sg = sym(TotalSpinfulFermionicNumber(1, 1, N), dofo)
        test_basis_result(dofo, N, sg;
            expected_states=[bi"3"4, bi"12"4, bi"21"4, bi"30"4],
            expected_norms=ones(Float64, 4)
        )
    end

    @testset "basis with spinful-fermion translation" begin
        N = 4
        dofo = dof_object(SpinfulFermion(1 // 2, 2))
        perm = [2, 3, 4, 1] # cyclic translation
        nud_sg = sym(TotalSpinfulFermionicNumber(1, 1, N), dofo)

        @testset "n_up=1, n_down=1, k=0" begin
            # Every representative here belongs to a generic (trivial-stabilizer) orbit of
            # size 4, so -- as for a single particle on a ring -- each contributes the same
            # norm (=4, the full translation order) to every momentum sector; summing the
            # dimension over k=0..3 reproduces the full n_up=1,n_down=1 dimension (4*4=16).
            csg = nud_sg ∘ sym(Translational(0, perm), dofo)
            test_basis_result(dofo, N, csg;
                expected_states=[bi"3"4, bi"12"4, bi"21"4, bi"102"4],
                expected_norms=Float64[4, 4, 4, 4],
                check_commutative=true
            )
        end

        @testset "n_up=1, n_down=1, k=1" begin
            csg = nud_sg ∘ sym(Translational(1, perm), dofo)
            test_basis_result(dofo, N, csg;
                expected_states=[bi"3"4, bi"12"4, bi"21"4, bi"102"4],
                expected_norms=Float64[4, 4, 4, 4],
                check_commutative=true
            )

            # A doublon (digit3, sign-free under permutation -- see the "SpinfulFermion"
            # nested testset in "sym of Translational") translated by r=1,2,3 sites picks up
            # only the momentum phase cispi(-2*1*r/4), no fermionic sign.
            test_states = [bi"3"4, bi"30"4, bi"300"4, bi"3000"4]
            test_reps = [bi"3"4, bi"3"4, bi"3"4, bi"3"4]
            test_factors = ComplexF64[1, -1im, -1, 1im]
            test_representatives(test_states, test_reps, test_factors, csg)
        end
    end

    @testset "basis with spinful-fermion spatial reflection" begin
        N = 4
        dofo = dof_object(SpinfulFermion(1 // 2, 2))
        perm = [4, 3, 2, 1] # reflection
        nud_sg = sym(TotalSpinfulFermionicNumber(1, 1, N), dofo)

        @testset "n_up=1, n_down=1, R = 1" begin
            csg = nud_sg ∘ sym(SpatialReflection(1, perm), dofo)
            test_basis_result(dofo, N, csg;
                expected_states=[
                    bi"3"4, bi"12"4, bi"21"4, bi"30"4, bi"102"4, bi"120"4, bi"201"4, bi"1002"4
                ],
                expected_norms=Float64[2, 2, 2, 2, 2, 2, 2, 2],
                check_commutative=true
            )
        end

        @testset "n_up=1, n_down=1, R = -1" begin
            csg = nud_sg ∘ sym(SpatialReflection(-1, perm), dofo)
            test_basis_result(dofo, N, csg;
                expected_states=[
                    bi"3"4, bi"12"4, bi"21"4, bi"30"4, bi"102"4, bi"120"4, bi"201"4, bi"1002"4
                ],
                expected_norms=Float64[2, 2, 2, 2, 2, 2, 2, 2],
                check_commutative=true
            )
        end
    end

    @testset "basis with spinful-fermion spin inversion (FermionicSpinInversion)" begin
        # FermionicSpinInversion is only a meaningful (non-degenerate) symmetry when
        # n_up == n_down (it maps a (N_up,N_down) sector to (N_down,N_up)).
        N = 2
        dofo = dof_object(SpinfulFermion(1 // 2, 2))
        nud_sg = sym(TotalSpinfulFermionicNumber(1, 1, N), dofo)

        @testset "z = 1" begin
            # The two doublon-containing states (site1=doublon/site2=empty and vice versa)
            # are each individually invariant under the up/down relabel, but pick up the
            # doublon's own -1 sign_lut factor -- so they only survive in the z=-1 sector.
            # Only the genuine 2-element orbit {bi"12"4, bi"21"4} survives at z=1.
            csg = nud_sg ∘ sym(FermionicSpinInversion(1, N), dofo)
            test_basis_result(dofo, N, csg;
                expected_states=[bi"12"4],
                expected_norms=Float64[2],
                check_commutative=true
            )
        end

        @testset "z = -1" begin
            csg = nud_sg ∘ sym(FermionicSpinInversion(-1, N), dofo)
            test_basis_result(dofo, N, csg;
                expected_states=[bi"3"4, bi"12"4, bi"30"4],
                expected_norms=Float64[4, 2, 4],
                check_commutative=true
            )
        end
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
                    expected_states=[bi"0"2, bi"1"2, bi"11"2, bi"101"2, bi"111"2, bi"1111"2],
                    expected_norms=Float64[16, 4, 4, 8, 4, 16]
                )
            end

            @testset "k = 1" begin
                sg = sym(Translational(1, perm), dofo)
                test_basis_result(dofo, N, sg;
                    expected_states=[bi"1"2, bi"11"2, bi"111"2],
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
                    expected_states=[bi"0"3, bi"1"3, bi"2"3, bi"11"3, bi"12"3, bi"21"3,
                        bi"22"3, bi"111"3, bi"112"3, bi"122"3, bi"222"3],
                    expected_norms=Float64[9, 3, 3, 3, 3, 3, 3, 9, 3, 3, 9]
                )
            end

            @testset "k = 1" begin
                sg = sym(Translational(1, perm), dofo)
                test_basis_result(dofo, N, sg;
                    expected_states=[bi"1"3, bi"2"3, bi"11"3, bi"12"3, bi"21"3, bi"22"3,
                        bi"112"3, bi"122"3],
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
                expected_states=[bi"0"2, bi"1"2, bi"10"2, bi"11"2, bi"101"2, bi"111"2],
                expected_norms=Float64[4, 2, 4, 2, 4, 4]
            )
        end

        @testset "spin-1 with spatial reflection symmetry" begin
            N = 2
            dofo = dof_object(Spin(2 // 1))
            perm = [2, 1] # reflection

            sg = sym(SpatialReflection(-1, perm), dofo)
            test_basis_result(dofo, N, sg;
                expected_states=[bi"1"5, bi"2"5, bi"3"5, bi"4"5, bi"12"5,
                    bi"13"5, bi"14"5, bi"23"5, bi"24"5, bi"34"5],
                expected_norms=Float64[2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
            )
        end

        @testset "spin-1/2 with spin inversion symmetry" begin
            N = 2
            dofo = dof_object(Spin(1 // 2))

            for z in [1, -1]
                sg = sym(SpinInversion(z, N), dofo)
                # For spin-1/2, no state is its own flip, so both spin inversion sectors
                # have the same representative: the smaller-valued state of {bi"01"2, bi"10"2}
                expected_rep = bi"01"2
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
                    expected_states=[bi"2"3, bi"11"3],
                    expected_norms=Float64[2, 4]
                )
            end

            @testset "z = -1" begin
                sg = sym(SpinInversion(-1, N), dofo)
                # bi"11"3 is excluded (norm=0 for z=-1), leaving one state from the pair
                test_basis_result(dofo, N, sg;
                    expected_states=[bi"2"3],
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
                    expected_states=[bi"11"2, bi"101"2, bi"110"2],
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
                    expected_states=[bi"11"2, bi"101"2],
                    expected_norms=Float64[4, 8],
                    check_commutative=true
                )
            end

            @testset "k = 1 and Sz = 0 for N = 4" begin
                csg = sym(TotalMagnetization(0 // 1, N), dofo) ∘
                      sym(Translational(1, perm), dofo)
                test_basis_result(dofo, N, csg;
                    expected_states=[bi"11"2],
                    expected_norms=Float64[4],
                    check_commutative=true
                )
            end

            @testset "k = 0 and Sz = -1 for N = 4" begin
                csg = sym(TotalMagnetization(-1 // 1, N), dofo) ∘
                      sym(Translational(0, perm), dofo)
                test_basis_result(dofo, N, csg;
                    expected_states=[bi"1"2],
                    expected_norms=Float64[4],
                    check_commutative=true
                )
            end

            @testset "k = 3 and Sz = -1 for N = 4" begin
                csg = sym(TotalMagnetization(-1 // 1, N), dofo) ∘
                      sym(Translational(3, perm), dofo)
                test_basis_result(dofo, N, csg;
                    expected_states=[bi"1"2],
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
                    expected_states=[bi"22"3, bi"112"3, bi"121"3, bi"202"3, bi"1111"3],
                    expected_norms=Float64[16, 8, 16, 32, 64],
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
                test_reps = [bi"1"2, bi"111"2, bi"11"2]
                test_factors = ComplexF64[1, 1, -1im]
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
                test_reps = [bi"1"3, bi"2"3, bi"11"3, bi"12"3]
                test_factors = ComplexF64[1, cispi(-2 / 3), cispi(2 / 3), 1]
                test_representatives(test_states, test_reps, test_factors, sg)
            end
        end

        @testset "spin-1/2 with spatial reflection symmetry" begin
            @testset "R = -1 for N = 3" begin
                N = 3
                dofo = dof_object(Spin(1 // 2))
                perm = [3, 2, 1] # reflection
                sg = sym(SpatialReflection(-1, perm), dofo)
                test_states = [bi"1"2, bi"11"2]
                test_reps = [bi"1"2, bi"11"2]
                test_representatives(test_states, test_reps, Float64[1, 1], sg)
            end
        end

        @testset "spin-1 with spatial reflection symmetry" begin
            @testset "R = -1 for N = 2" begin
                N = 2
                dofo = dof_object(Spin(1 // 1))
                perm = [2, 1] # reflection
                sg = sym(SpatialReflection(-1, perm), dofo)
                test_states = [bi"01"3, bi"20"3, bi"21"3]
                test_reps = [bi"1"3, bi"2"3, bi"12"3]
                test_representatives(test_states, test_reps, Float64[1, -1, -1], sg)
            end
        end

        @testset "spin-1/2 with spin inversion symmetry" begin
            @testset "z = -1 for N = 2" begin
                N = 2
                dofo = dof_object(Spin(1 // 2))
                sg = sym(SpinInversion(-1, N), dofo)

                # Representative is whichever of the flip pair has the smaller value
                test_states = [bi"01"2, bi"10"2]
                test_reps = [bi"01"2, bi"01"2]
                test_factors = Float64[1, -1]

                test_representatives(test_states, test_reps, test_factors, sg)
            end
        end

        @testset "spin-1 with spin inversion symmetry" begin
            @testset "z = 1 for N = 2" begin
                N = 2
                dofo = dof_object(Spin(1 // 1))
                sg = sym(SpinInversion(1, N), dofo)
                test_states = [bi"2"3, bi"11"3, bi"20"3]
                test_reps = [bi"2"3, bi"11"3, bi"2"3]
                test_representatives(test_states, test_reps, Float64[1, 1, 1], sg)
            end

            @testset "z = -1 for N = 2" begin
                N = 2
                dofo = dof_object(Spin(1 // 1))
                sg = sym(SpinInversion(-1, N), dofo)
                test_states = [bi"2"3, bi"11"3, bi"20"3]
                test_reps = [bi"2"3, bi"11"3, bi"2"3]
                test_factors = Float64[1, 1, -1]
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
                test_states = [bi"101"2]
                test_reps = [bi"101"2]
                test_representatives(test_states, test_reps, ComplexF64[1], csg)
            end

            @testset "Sz = 1, k = 0, R = 1 for N = 4" begin
                csg = sym(TotalMagnetization(1 // 1, N), dofo) ∘
                      sym(Translational(0, perm_T), dofo) ∘
                      sym(SpatialReflection(1, perm_R), dofo)
                test_states = [bi"1110"2]
                test_reps = [bi"111"2]
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
                        expected_states=[bi"0"2, bi"1"2, bi"11"2, bi"110"2, bi"111"2, bi"1111"2],
                        expected_norms=Float64[16, 4, 4, 8, 4, 16]
                    )
                end

                @testset "r = 1" begin
                    sg = sym(Rotational(1, perm_R2), dofo)
                    test_basis_result(dofo, N, sg;
                        expected_states=[bi"1"2, bi"11"2, bi"111"2],
                        expected_norms=Float64[4, 4, 4]
                    )
                end

                @testset "r = 2" begin
                    sg = sym(Rotational(2, perm_R2), dofo)
                    test_basis_result(dofo, N, sg;
                        expected_states=[bi"1"2, bi"11"2, bi"110"2, bi"111"2],
                        expected_norms=Float64[4, 4, 8, 4]
                    )
                end

                @testset "r = 3" begin
                    sg = sym(Rotational(3, perm_R2), dofo)
                    test_basis_result(dofo, N, sg;
                        expected_states=[bi"1"2, bi"11"2, bi"111"2],
                        expected_norms=Float64[4, 4, 4]
                    )
                end
            end

            @testset "Sz = 0 and Rotational" begin
                sgSz = sym(TotalMagnetization(0 // 1, N), dofo)

                @testset "r = 0" begin
                    csg = sgSz ∘ sym(Rotational(0, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=[bi"11"2, bi"110"2],
                        expected_norms=Float64[4, 8],
                        check_commutative=true
                    )
                end

                @testset "r = 1" begin
                    csg = sgSz ∘ sym(Rotational(1, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=[bi"11"2],
                        expected_norms=Float64[4],
                        check_commutative=true
                    )
                end

                @testset "r = 2" begin
                    csg = sgSz ∘ sym(Rotational(2, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=[bi"11"2, bi"110"2],
                        expected_norms=Float64[4, 8],
                        check_commutative=true
                    )
                end

                @testset "r = 3" begin
                    csg = sgSz ∘ sym(Rotational(3, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=[bi"11"2],
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
                            expected_states=[bi"111"2],
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
                        expected_states=[bi"22"3, bi"112"3, bi"121"3, bi"211"3, bi"220"3, bi"1111"3],
                        expected_norms=Float64[4, 4, 4, 4, 8, 16],
                        check_commutative=true
                    )
                end

                @testset "r = 1" begin
                    csg = sgSz ∘ sym(Rotational(1, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=[bi"22"3, bi"112"3, bi"121"3, bi"211"3],
                        expected_norms=Float64[4, 4, 4, 4],
                        check_commutative=true
                    )
                end

                @testset "r = 2" begin
                    csg = sgSz ∘ sym(Rotational(2, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=[bi"22"3, bi"112"3, bi"121"3, bi"211"3, bi"220"3],
                        expected_norms=Float64[4, 4, 4, 4, 8],
                        check_commutative=true
                    )
                end

                @testset "r = 3" begin
                    csg = sgSz ∘ sym(Rotational(3, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=[bi"22"3, bi"112"3, bi"121"3, bi"211"3],
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
                        expected_states=[bi"222"3, bi"1122"3, bi"1221"3],
                        expected_norms=Float64[4, 4, 8],
                        check_commutative=true
                    )
                end

                @testset "r = 1" begin
                    csg = sgSz ∘ sym(Rotational(1, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=[bi"222"3, bi"1122"3],
                        expected_norms=Float64[4, 4],
                        check_commutative=true
                    )
                end

                @testset "r = 2" begin
                    csg = sgSz ∘ sym(Rotational(2, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=[bi"222"3, bi"1122"3, bi"1221"3],
                        expected_norms=Float64[4, 4, 8],
                        check_commutative=true
                    )
                end

                @testset "r = 3" begin
                    csg = sgSz ∘ sym(Rotational(3, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=[bi"222"3, bi"1122"3],
                        expected_norms=Float64[4, 4],
                        check_commutative=true
                    )
                end
            end
        end

        @testset "2x2 spinless fermion with Rotational symmetry" begin
            N = 4
            dofo = dof_object(SpinlessFermion())

            @testset "Rotational only" begin
                @testset "r = 0" begin
                    sg = sym(Rotational(0, perm_R2), dofo)
                    test_basis_result(dofo, N, sg;
                        expected_states=[bi"0"2, bi"1"2, bi"11"2, bi"111"2],
                        expected_norms=Float64[16, 4, 4, 4]
                    )
                end

                @testset "r = 1" begin
                    sg = sym(Rotational(1, perm_R2), dofo)
                    test_basis_result(dofo, N, sg;
                        expected_states=[bi"1"2, bi"11"2, bi"110"2, bi"111"2],
                        expected_norms=Float64[4, 4, 8, 4]
                    )
                end

                @testset "r = 2" begin
                    sg = sym(Rotational(2, perm_R2), dofo)
                    test_basis_result(dofo, N, sg;
                        expected_states=[bi"1"2, bi"11"2, bi"111"2, bi"1111"2],
                        expected_norms=Float64[4, 4, 4, 16]
                    )
                end

                @testset "r = 3" begin
                    sg = sym(Rotational(3, perm_R2), dofo)
                    test_basis_result(dofo, N, sg;
                        expected_states=[bi"1"2, bi"11"2, bi"110"2, bi"111"2],
                        expected_norms=Float64[4, 4, 8, 4]
                    )
                end
            end

            @testset "n_particles=2 and Rotational" begin
                sgpn = sym(TotalSpinlessFermionicNumber(2, N), dofo)

                @testset "r = 0" begin
                    csg = sgpn ∘ sym(Rotational(0, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=[bi"11"2],
                        expected_norms=Float64[4],
                        check_commutative=true
                    )
                end

                @testset "r = 1" begin
                    csg = sgpn ∘ sym(Rotational(1, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=[bi"11"2, bi"110"2],
                        expected_norms=Float64[4, 8],
                        check_commutative=true
                    )
                end

                @testset "r = 2" begin
                    csg = sgpn ∘ sym(Rotational(2, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=[bi"11"2],
                        expected_norms=Float64[4],
                        check_commutative=true
                    )
                end

                @testset "r = 3" begin
                    csg = sgpn ∘ sym(Rotational(3, perm_R2), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=[bi"11"2, bi"110"2],
                        expected_norms=Float64[4, 8],
                        check_commutative=true
                    )
                end
            end
        end

        @testset "2x2 spinful fermion with Rotational symmetry" begin
            N = 4
            dofo = dof_object(SpinfulFermion(1 // 2, 2))

            @testset "n_up=1, n_down=1 and Rotational" begin
                sgpn = sym(TotalSpinfulFermionicNumber(1, 1, N), dofo)
                # Generic (trivial-stabilizer) orbits: every r sector gets the same 4
                # representatives with the same norm, exactly as for pure translation above.
                for r in 0:3
                    @testset "r = $r" begin
                        csg = sgpn ∘ sym(Rotational(r, perm_R2), dofo)
                        test_basis_result(dofo, N, csg;
                            expected_states=[bi"3"4, bi"12"4, bi"21"4, bi"120"4],
                            expected_norms=Float64[4, 4, 4, 4],
                            check_commutative=true
                        )
                    end
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
                    expected_states=[bi"11111111"2, bi"101111111"2, bi"111101111"2],
                    expected_norms=Float64[4, 4, 16],
                    check_commutative=true
                )
            end

            @testset "r = $r" for r in 1:3
                csg = sgSz ∘ sym(Rotational(r, perm_R3), dofo)
                test_basis_result(dofo, N, csg;
                    expected_states=[bi"11111111"2, bi"101111111"2],
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
                        expected_states=[bi"122222222"3, bi"212222222"3, bi"222212222"3],
                        expected_norms=Float64[4, 4, 16],
                        check_commutative=true
                    )
                end

                @testset "r = $r" for r in 1:3
                    csg = sgSz ∘ sym(Rotational(r, perm_R3), dofo)
                    test_basis_result(dofo, N, csg;
                        expected_states=[bi"122222222"3, bi"212222222"3],
                        expected_norms=Float64[4, 4],
                        check_commutative=true
                    )
                end
            end
        end
    end

    @testset "basis with SpinMultipole symmetry" begin
        @testset "SpinMultipole only (rank=1, dipole)" begin
            @testset "spin-1/2" begin
                N = 3
                dofo = dof_object(Spin(1 // 2))
                w = Rational{Int}[1, 2, 4]
                ss_pos = SpinMultipole(1 // 2, w, N)
                test_basis_result(dofo, N, sym(ss_pos, dofo);
                    expected_states=[bi"100"2],
                    expected_norms=Float64[1]
                )

                ss_neg = SpinMultipole(-1 // 2, w, N)
                test_basis_result(dofo, N, sym(ss_neg, dofo);
                    expected_states=[bi"011"2],
                    expected_norms=Float64[1]
                )
            end

            @testset "spin-1" begin
                N = 3
                dofo = dof_object(Spin(1 // 1))
                w = Rational{Int}[1, 2, 3]
                ss_neg = SpinMultipole(-6 // 1, w, N)
                test_basis_result(dofo, N, sym(ss_neg, dofo);
                    expected_states=[bi"000"3],
                    expected_norms=Float64[1]
                )
                ss_pos = SpinMultipole(6 // 1, w, N)
                test_basis_result(dofo, N, sym(ss_pos, dofo);
                    expected_states=[bi"222"3],
                    expected_norms=Float64[1]
                )
            end
        end

        @testset "SpinMultipole only (rank=2, quadrupole)" begin
            @testset "spin-1/2" begin
                N = 3
                dofo = dof_object(Spin(1 // 2))
                w = Rational{Int}[1, 2, 3]
                ss_q3 = SpinMultipole(3 // 1, w, N; rank=2)
                test_basis_result(dofo, N, sym(ss_q3, dofo);
                    expected_states=[bi"101"2],
                    expected_norms=Float64[1]
                )

                ss_qm3 = SpinMultipole(-3 // 1, w, N; rank=2)
                test_basis_result(dofo, N, sym(ss_qm3, dofo);
                    expected_states=[bi"010"2],
                    expected_norms=Float64[1]
                )
            end

            @testset "spin-1" begin
                N = 2
                dofo = dof_object(Spin(1 // 1))
                w = Rational{Int}[1, 2]
                ss_qm3 = SpinMultipole(-3 // 1, w, N; rank=2)
                test_basis_result(dofo, N, sym(ss_qm3, dofo);
                    expected_states=[bi"02"3],
                    expected_norms=Float64[1]
                )
                ss_q3 = SpinMultipole(3 // 1, w, N; rank=2)
                test_basis_result(dofo, N, sym(ss_q3, dofo);
                    expected_states=[bi"20"3],
                    expected_norms=Float64[1]
                )
            end
        end

        @testset "TotalMagnetization + SpinMultipole rank=1 (origin independence)" begin
            @testset "spin-1/2" begin
                N = 4
                dofo = dof_object(Spin(1 // 2))
                sg_sz = sym(TotalMagnetization(0 // 1, N), dofo)

                for w in (Rational{Int}[1, 2, 3, 4], Rational{Int}[2, 3, 4, 5])
                    @testset "w=$w, dipole=0" begin
                        ss_dip0 = SpinMultipole(0 // 1, w, N)
                        test_basis_result(dofo, N, sg_sz ∘ sym(ss_dip0, dofo);
                            expected_states=[bi"0110"2, bi"1001"2],
                            expected_norms=Float64[1, 1]
                        )
                    end
                end

                for w in (Rational{Int}[1, 2, 3, 4], Rational{Int}[2, 3, 4, 5])
                    @testset "w=$w, dipole=1" begin
                        ss_dip1 = SpinMultipole(1 // 1, w, N)
                        test_basis_result(dofo, N, sg_sz ∘ sym(ss_dip1, dofo);
                            expected_states=[bi"1010"2],
                            expected_norms=Float64[1]
                        )
                    end
                end
            end

            @testset "spin-1" begin
                N = 3
                dofo = dof_object(Spin(1 // 1))
                sg_sz = sym(TotalMagnetization(0 // 1, N), dofo)

                for w in (Rational{Int}[1, 2, 3], Rational{Int}[2, 3, 4])
                    @testset "w=$w, dipole=1" begin
                        ss_dip1 = SpinMultipole(1 // 1, w, N)
                        test_basis_result(dofo, N, sg_sz ∘ sym(ss_dip1, dofo);
                            expected_states=[bi"120"3, bi"201"3],
                            expected_norms=Float64[1, 1]
                        )
                    end
                end

                for w in (Rational{Int}[1, 2, 3], Rational{Int}[2, 3, 4])
                    @testset "w=$w, dipole=2" begin
                        ss_dip2 = SpinMultipole(2 // 1, w, N)
                        test_basis_result(dofo, N, sg_sz ∘ sym(ss_dip2, dofo);
                            expected_states=[bi"210"3],
                            expected_norms=Float64[1]
                        )
                    end
                end
            end
        end

        @testset """TotalMagnetization + SpinMultipole rank=1 + SpinMultipole rank=2 (origin
        independence)""" begin
            @testset "spin-1/2" begin
                N = 4
                dofo = dof_object(Spin(1 // 2))
                sg_sz = sym(TotalMagnetization(0 // 1, N), dofo)

                for w in (Rational{Int}[1, 2, 3, 4], Rational{Int}[2, 3, 4, 5])
                    @testset "w=$w, dipole=0, quad=-2" begin
                        ss_dip = SpinMultipole(0 // 1, w, N)
                        ss_quad = SpinMultipole(-2 // 1, w, N; rank=2)
                        csg = sg_sz ∘ sym(ss_dip, dofo) ∘ sym(ss_quad, dofo)
                        test_basis_result(dofo, N, csg;
                            expected_states=[bi"0110"2],
                            expected_norms=Float64[1]
                        )
                    end

                    @testset "w=$w, dipole=0, quad=+2" begin
                        ss_dip = SpinMultipole(0 // 1, w, N)
                        ss_quad = SpinMultipole(2 // 1, w, N; rank=2)
                        csg = sg_sz ∘ sym(ss_dip, dofo) ∘ sym(ss_quad, dofo)
                        test_basis_result(dofo, N, csg;
                            expected_states=[bi"1001"2],
                            expected_norms=Float64[1]
                        )
                    end
                end
            end

            @testset "spin-1" begin
                N = 4
                dofo = dof_object(Spin(1 // 1))
                sg_sz = sym(TotalMagnetization(0 // 1, N), dofo)

                for w in (Rational{Int}[1, 2, 3, 4], Rational{Int}[2, 3, 4, 5])
                    @testset "w=$w, dipole=0, quad=-4" begin
                        ss_dip = SpinMultipole(0 // 1, w, N)
                        ss_quad = SpinMultipole(-4 // 1, w, N; rank=2)
                        csg = sg_sz ∘ sym(ss_dip, dofo) ∘ sym(ss_quad, dofo)
                        test_basis_result(dofo, N, csg;
                            expected_states=[bi"0220"3],
                            expected_norms=Float64[1]
                        )
                    end

                    @testset "w=$w, dipole=0, quad=+4" begin
                        ss_dip = SpinMultipole(0 // 1, w, N)
                        ss_quad = SpinMultipole(4 // 1, w, N; rank=2)
                        csg = sg_sz ∘ sym(ss_dip, dofo) ∘ sym(ss_quad, dofo)
                        test_basis_result(dofo, N, csg;
                            expected_states=[bi"2002"3],
                            expected_norms=Float64[1]
                        )
                    end
                end
            end
        end

        @testset "TotalMagnetization + SpinMultipole rank=2 (origin dependence)" begin
            @testset "spin-1/2" begin
                N = 4
                dofo = dof_object(Spin(1 // 2))
                sg_sz = sym(TotalMagnetization(0 // 1, N), dofo)

                w1 = Rational{Int}[1, 2, 3, 4]
                ss_q1 = SpinMultipole(-10 // 1, w1, N; rank=2)
                test_basis_result(dofo, N, sg_sz ∘ sym(ss_q1, dofo);
                    expected_states=[bi"0011"2],
                    expected_norms=Float64[1]
                )
                ss_q2 = SpinMultipole(5 // 1, w1, N; rank=2)
                test_basis_result(dofo, N, sg_sz ∘ sym(ss_q2, dofo);
                    expected_states=[bi"1010"2],
                    expected_norms=Float64[1]
                )

                w2 = Rational{Int}[2, 3, 4, 5]
                ss_q3 = SpinMultipole(-14 // 1, w2, N; rank=2)
                test_basis_result(dofo, N, sg_sz ∘ sym(ss_q3, dofo);
                    expected_states=[bi"0011"2],
                    expected_norms=Float64[1]
                )

                ss_q4 = SpinMultipole(-10 // 1, w2, N; rank=2)
                b_empty = basis(dofo, N, sg_sz ∘ sym(ss_q4, dofo); is_sorted=true)
                @test isempty(b_empty.states)
            end

            @testset "spin-1" begin
                N = 4
                dofo = dof_object(Spin(1 // 1))
                sg_sz = sym(TotalMagnetization(0 // 1, N), dofo)

                w1 = Rational{Int}[1, 2, 3, 4]
                ss_qm10 = SpinMultipole(-10 // 1, w1, N; rank=2)
                test_basis_result(dofo, N, sg_sz ∘ sym(ss_qm10, dofo);
                    expected_states=[bi"0202"3],
                    expected_norms=Float64[1]
                )

                w2 = Rational{Int}[2, 3, 4, 5]
                ss_qm14 = SpinMultipole(-14 // 1, w2, N; rank=2)
                test_basis_result(dofo, N, sg_sz ∘ sym(ss_qm14, dofo);
                    expected_states=[bi"0202"3],
                    expected_norms=Float64[1]
                )

                ss_qm10_w2 = SpinMultipole(-10 // 1, w2, N; rank=2)
                b_empty = basis(dofo, N, sg_sz ∘ sym(ss_qm10_w2, dofo); is_sorted=true)
                @test isempty(b_empty.states)
            end
        end
    end

    @testset "basis with 2D SpinfulFermion lattice symmetries" begin
        # 3x3 square lattice (avoids the length-2-periodic-axis degeneracy where
        # translation-by-1 and reflection coincide as the same permutation), sites labeled
        # column-major via CartesianIndices/LinearIndices, mirroring test/fhm_2d.jl's
        # lattice_perms and test/spinless_fermions_2d.jl.
        Lx, Ly = 3, 3
        N = Lx * Ly
        dofo = dof_object(SpinfulFermion(1 // 2, 2))

        lin = LinearIndices((Lx, Ly))
        cart = CartesianIndices((Lx, Ly))
        Tx_perm = lin[[CartesianIndex(mod1(r[1] + 1, Lx), r[2]) for r in cart][:]]
        Ty_perm = lin[[CartesianIndex(r[1], mod1(r[2] + 1, Ly)) for r in cart][:]]
        Px_perm = lin[[CartesianIndex(Lx - r[1] + 1, r[2]) for r in cart][:]]
        Py_perm = lin[[CartesianIndex(r[1], Ly - r[2] + 1) for r in cart][:]]
        @test Tx_perm != Px_perm && Ty_perm != Py_perm # genuinely independent generators here

        nud_sg = sym(TotalSpinfulFermionicNumber(1, 1, N), dofo)
        Tx_sg = sym(Translational(0, Tx_perm), dofo)
        Ty_sg = sym(Translational(0, Ty_perm), dofo)

        @testset "translation only (kx=0, ky=0)" begin
            csg = nud_sg ∘ Tx_sg ∘ Ty_sg
            test_basis_result(dofo, N, csg;
                expected_states=[
                    bi"3"4, bi"12"4, bi"21"4, bi"1002"4, bi"1020"4, bi"1200"4,
                    bi"2001"4, bi"2010"4, bi"2100"4
                ],
                expected_norms=Float64[9, 9, 9, 9, 9, 9, 9, 9, 9],
                check_commutative=true
            )
        end

        @testset "+ reflection-x, reflection-y (px=1, py=1)" begin
            csg = nud_sg ∘ Tx_sg ∘ Ty_sg ∘
                  sym(SpatialReflection(1, Px_perm), dofo) ∘
                  sym(SpatialReflection(1, Py_perm), dofo)
            test_basis_result(dofo, N, csg;
                expected_states=[bi"3"4, bi"12"4, bi"1002"4, bi"1020"4],
                expected_norms=Float64[144, 72, 72, 36],
                check_commutative=true
            )
        end

        @testset "+ fermionic spin inversion (sblock)" begin
            csgTP = nud_sg ∘ Tx_sg ∘ Ty_sg ∘
                    sym(SpatialReflection(1, Px_perm), dofo) ∘
                    sym(SpatialReflection(1, Py_perm), dofo)

            @testset "z = 1 (empty sector)" begin
                csg = csgTP ∘ sym(FermionicSpinInversion(1, N), dofo)
                b = basis(dofo, N, csg; is_sorted=true)
                @test is_commutative(b, csg)
                @test isempty(b.states)
            end

            @testset "z = -1" begin
                csg = csgTP ∘ sym(FermionicSpinInversion(-1, N), dofo)
                test_basis_result(dofo, N, csg;
                    expected_states=[bi"3"4, bi"12"4, bi"1002"4, bi"1020"4],
                    expected_norms=Float64[576, 288, 288, 144],
                    check_commutative=true
                )
            end
        end
    end
end
