@testset "Tests for BaseIntRange" begin
    @testset "Construction of BaseIntRange" begin
        r1 = BaseIntRange(bi"0"2, bi"1"2, bi"11"2)
        @test r1.first == bi"0"2
        @test r1.step == bi"1"2
        @test r1.last == bi"11"2

        r2 = BaseIntRange(bi"5"10, bi"1"10, bi"10"10)
        @test r2.first == bi"5"10
        @test r2.step == bi"1"10
        @test r2.last == bi"10"10

        r3 = BaseIntRange(bi"1"4, bi"2"4, bi"100"4)
        @test r3.first == bi"1"4
        @test r3.step == bi"2"4
        @test r3.last == bi"100"4
    end

    @testset "Base.:(:)" begin
        r1 = bi"0"2:bi"11"2
        @test r1.first == bi"0"2
        @test r1.step == bi"1"2
        @test r1.last == bi"11"2

        r2 = bi"5"10:bi"1"10:bi"10"10
        @test r2.first == bi"5"10
        @test r2.step == bi"1"10
        @test r2.last == bi"10"10

        # "40"5 (=20) is not reachable from 1 in steps of 2, so the constructor snaps `last`
        # down to the nearest reachable value, "34"5 (=19), exactly as `Base` ranges do
        # (e.g. `last(1:2:20) == 19`).
        r3 = bi"1"5:bi"2"5:bi"40"5
        @test r3.first == bi"1"5
        @test r3.step == bi"2"5
        @test r3.last == bi"34"5
        @test last(r3) == bi"34"5

        # Base-2 case matching the reported issue: 0:2:7 must not keep an unreachable
        # "111" (=7) as its last element -- the reachable value is "110" (=6).
        r4 = bi"0"2:bi"10"2:bi"111"2
        @test r4.last == bi"110"2
        @test last(r4) == bi"110"2
    end

    @testset "Base.length for BaseIntRange" begin
        r1 = bi"0"2:bi"11"2
        @test length(r1) == 4

        r2 = bi"3"4:bi"1"4:bi"20"4
        @test length(r2) == 6

        r3 = bi"3"7:bi"2"7:bi"100"7
        @test length(r3) == 24

        r4 = bi"1"2:bi"1"2
        @test length(r4) == 1

        r5 = bi"1"4:bi"0"4
        @test length(r5) == 0
    end

    @testset "Base.collect for BaseIntRange" begin
        r1 = bi"0"2:bi"11"2
        collected1 = collect(r1)
        expected1 = [bi"0"2, bi"1"2, bi"10"2, bi"11"2]
        @test collected1 == expected1

        r2 = bi"5"10:bi"1"10:bi"10"10
        collected2 = collect(r2)
        expected2 = [bi"5"10, bi"6"10, bi"7"10, bi"8"10, bi"9"10, bi"10"10]
        @test collected2 == expected2

        r3 = bi"1"2:bi"10"2:bi"1001"2
        collected3 = collect(r3)
        expected3 = [bi"1"2, bi"11"2, bi"101"2, bi"111"2, bi"1001"2]
        @test collected3 == expected3
    end

    @testset "Base.show for BaseIntRange" begin
        r1 = bi"0"2:bi"11"2
        io1 = IOBuffer()
        show(io1, r1)
        output1 = String(take!(io1))
        @test output1 == "(0)₂:(1)₂:(11)₂"

        r2 = bi"15"10:bi"1"10:bi"20"10
        io2 = IOBuffer()
        show(io2, r2)
        output2 = String(take!(io2))
        @test output2 == "(15)₁₀:(1)₁₀:(20)₁₀"

        r3 = bi"3"7:bi"2"7:bi"100"7
        io3 = IOBuffer()
        show(io3, r3)
        output3 = String(take!(io3))
        @test output3 == "(3)₇:(2)₇:(100)₇"
    end

    @testset "Base.iterate for BaseIntRange" begin
        r1 = bi"0"2:bi"11"2
        map(x -> x, r1) == [bi"0"2, bi"1"2, bi"10"2, bi"11"2] || @test false

        r2 = bi"100"3:bi"10"3:bi"200"3
        map(x -> x, r2) == [bi"100"3, bi"110"3, bi"120"3, bi"200"3] || @test false
    end

    @testset "Base.getindex for BaseIntRange" begin
        r1 = bi"0"2:bi"11"2
        @test r1[1] == bi"0"2
        @test r1[2] == bi"1"2
        @test r1[3] == bi"10"2
        @test r1[4] == bi"11"2

        r2 = bi"5"6:bi"2"6:bi"20"6
        @test r2[1] == bi"5"6
        @test r2[2] == bi"11"6
        @test r2[3] == bi"13"6
        @test r2[4] == bi"15"6
    end

    @testset "Base.eltype for BaseIntRange" begin
        r1 = bi"0"2:bi"11"2
        @test eltype(r1) == BaseInt{UInt64,Int64,2}
        @test eltype(typeof(r1)) == BaseInt{UInt64,Int64,2}

        r2 = bi"5"10:bi"1"10:bi"10"10
        @test eltype(r2) == BaseInt{UInt64,Int64,10}
        @test eltype(typeof(r2)) == BaseInt{UInt64,Int64,10}

        r3 = bi"1"3:bi"2"3:bi"100"3
        @test eltype(r3) == BaseInt{UInt64,Int64,3}
    end

    @testset "Base.IteratorSize for BaseIntRange" begin
        r1 = bi"0"2:bi"11"2
        @test Base.IteratorSize(typeof(r1)) == Base.HasLength()
        @test Base.IteratorSize(BaseIntRange{Int64,Int64,2}) == Base.HasLength()

        r2 = bi"5"10:bi"1"10:bi"10"10
        @test Base.IteratorSize(typeof(r2)) == Base.HasLength()
    end

    @testset "Base.IteratorEltype for BaseIntRange" begin
        r1 = bi"0"2:bi"11"2
        @test Base.IteratorEltype(typeof(r1)) == Base.HasEltype()
        @test Base.IteratorEltype(BaseIntRange{Int64,Int64,2}) == Base.HasEltype()

        r2 = bi"5"10:bi"1"10:bi"10"10
        @test Base.IteratorEltype(typeof(r2)) == Base.HasEltype()

        r3 = bi"1"5:bi"2"5:bi"100"5
        @test Base.IteratorEltype(typeof(r3)) == Base.HasEltype()
    end

    @testset "Base.firstindex for BaseIntRange" begin
        r1 = bi"0"2:bi"11"2
        @test firstindex(r1) == 1

        r2 = bi"5"10:bi"1"10:bi"10"10
        @test firstindex(r2) == 1

        r3 = bi"1"3:bi"2"3:bi"100"3
        @test firstindex(r3) == 1

        r4 = bi"1"2:bi"1"2
        @test firstindex(r4) == 1

        r5 = bi"1"4:bi"0"4
        @test firstindex(r5) == 1

        # Test that firstindex is consistent with getindex
        r6 = bi"10"7:bi"2"7:bi"50"7
        @test firstindex(r6) == 1
        @test r6[firstindex(r6)] == r6.first
    end
end
