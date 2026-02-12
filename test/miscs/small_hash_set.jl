@testset "Testing SmallHashSet..." begin
    @testset "Construction of SmallHashSet" begin
        s1 = SmallHashSet{2,UInt8}()
        @test s1.data == NTuple{2,UInt8}((0, 0))
        @test s1.count == 0

        s2 = SmallHashSet([1, 2, 3])
        @test s2.data == NTuple{3,Int}((1, 2, 3))
        @test s2.count == 3

        s3 = SmallHashSet(UInt[1, 2, 2, 3, 3, 3])
        @test s3.data == NTuple{3,UInt}((1, 2, 3))
        @test s3.count == 3
    end

    @testset "Base.empty! for SmallHashSet" begin
        s1 = SmallHashSet(UInt[0, 1])
        Base.empty!(s1)
        @test s1.count == 0
        @test s1.data == NTuple{2,UInt}((0, 0))

        s2 = SmallHashSet([-1 // 2, 1 // 2, 1 // 2])
        Base.empty!(s2)
        @test s2.count == 0
        @test s2.data == NTuple{2,Rational{Int}}((0 // 1, 0 // 1))
    end

    @testset "Base.iterate for SmallHashSet" begin
        s = SmallHashSet([10, 20, 30])
        collected = collect(s)
        @test collected == [10, 20, 30]

        s_empty = SmallHashSet{3,Int}()
        collected_empty = collect(s_empty)
        @test collected_empty == Int[]
    end

    @testset "Base.in for SmallHashSet" begin
        s = SmallHashSet([5, 10, 15])
        @test 10 in s
        @test !(20 in s)

        s_empty = SmallHashSet{3,Int}()
        @test !(0 in s_empty)
        @test !(1 in s_empty)
    end

    @testset "Base.length for SmallHashSet" begin
        s = SmallHashSet([1, 2, 3, 4])
        @test length(s) == 4

        s_empty = SmallHashSet{5,Int}()
        @test length(s_empty) == 0
    end

    @testset "Base.push! for SmallHashSet" begin
        s = SmallHashSet{3,Int8}()
        Base.push!(s, 10 |> Int8)
        @test s.data == NTuple{3,Int8}((10, 0, 0))
        @test s.count == 1

        Base.push!(s, 20 |> Int8)
        @test s.data == NTuple{3,Int8}((10, 20, 0))
        @test s.count == 2

        Base.push!(s, 10 |> Int8) # duplicate
        @test s.data == NTuple{3,Int8}((10, 20, 0))
        @test s.count == 2

        Base.push!(s, 30 |> Int8)
        @test s.data == NTuple{3,Int8}((10, 20, 30))
        @test s.count == 3

        @test_throws BoundsError Base.push!(s, 40 |> Int8)
    end

    @testset "Base.hash for SmallHashSet" begin
        s1 = SmallHashSet([1, 2, 3])
        s2 = SmallHashSet([1, 2, 3])
        s3 = SmallHashSet([1, 2, 4])

        # Test that equal sets have the same hash
        @test hash(s1) == hash(s2)

        # Test that different sets likely have different hashes
        @test hash(s1) != hash(s3)

        # Test hash with custom seed
        seed = UInt(12345)
        h1 = hash(s1, seed)
        h2 = hash(s2, seed)
        @test h1 == h2
        @test typeof(h1) == UInt

        # Test that empty sets hash correctly
        s_empty1 = SmallHashSet{3,Int}()
        s_empty2 = SmallHashSet{3,Int}()
        @test hash(s_empty1) == hash(s_empty2)

        # Test that sets with different counts have different hashes
        s_partial = SmallHashSet{3,Int}()
        push!(s_partial, 1)
        @test hash(s_partial) != hash(s_empty1)
    end

    @testset "Base.== for SmallHashSet" begin
        s1 = SmallHashSet([10, 20, 30])
        s2 = SmallHashSet([10, 20, 30])
        s3 = SmallHashSet([10, 20, 40])

        # Test equality of identical sets
        @test s1 == s2

        # Test inequality of different sets
        @test !(s1 == s3)

        # Test equality with empty sets
        s_empty1 = SmallHashSet{3,Int}()
        s_empty2 = SmallHashSet{3,Int}()
        @test s_empty1 == s_empty2

        # Test inequality between empty and non-empty sets
        @test !(s1 == s_empty1)

        # Test sets with same data but different counts
        s4 = SmallHashSet{3,Int}()
        push!(s4, 10)
        push!(s4, 20)
        s5 = SmallHashSet{3,Int}()
        push!(s5, 10)
        @test !(s4 == s5)
    end

    @testset "Base.isequal for SmallHashSet" begin
        s1 = SmallHashSet([5, 15, 25])
        s2 = SmallHashSet([5, 15, 25])
        s3 = SmallHashSet([5, 15, 35])

        # Test isequal for identical sets
        @test isequal(s1, s2)

        # Test isequal for different sets
        @test !isequal(s1, s3)

        # Test isequal with empty sets
        s_empty1 = SmallHashSet{3,Int}()
        s_empty2 = SmallHashSet{3,Int}()
        @test isequal(s_empty1, s_empty2)

        # Test isequal between empty and non-empty sets
        @test !isequal(s1, s_empty1)

        # Test that isequal and == behave the same for SmallHashSet
        @test isequal(s1, s2) == (s1 == s2)
        @test isequal(s1, s3) == (s1 == s3)

        # Test sets with different counts
        s4 = SmallHashSet{3,Int}()
        push!(s4, 5)
        push!(s4, 15)
        s5 = SmallHashSet{3,Int}()
        push!(s5, 5)
        @test !isequal(s4, s5)
    end
end
