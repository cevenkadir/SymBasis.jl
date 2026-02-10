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
end
