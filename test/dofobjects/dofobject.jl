@testset "Testing DoFObject..." begin
    @testset "Construction of DoFObject" begin
        dofo1 = DoFObject(:Something, (-1 // 2, 1 // 2); T=UInt8, Ti=Int8)
        @test dofo1.type == :Something
        @test dofo1.ldof == (-1 // 2, 1 // 2)
        @test typeof(dofo1) == DoFObject{2,Rational{Int64},UInt8,Int8}

        dofo2 = DoFObject(:Another, NTuple{3,Int32}((0, 1, 2)); T=Int16, Ti=Int16)
        @test dofo2.type == :Another
        @test dofo2.ldof == NTuple{3,Int32}((0, 1, 2))
        @test typeof(dofo2) == DoFObject{3,Int32,Int16,Int16}
    end

    @testset "Base.:(==) for DoFObject" begin
        dofo1 = DoFObject(:Spin, (-1 // 2, 1 // 2); T=UInt8, Ti=Int8)
        dofo2 = DoFObject(:Spin, (-1 // 2, 1 // 2); T=UInt8, Ti=Int8)
        dofo3 = DoFObject(:Spin, (-1 // 1, 0 // 1, 1 // 1); T=UInt8, Ti=Int8)
        @test dofo1 == dofo2
        @test dofo1 != dofo3
    end

    @testset "Base.isequal for DoFObject" begin
        dofo1 = DoFObject(:Boson, (0, 1, 2); T=UInt8, Ti=Int8)
        dofo2 = DoFObject(:Boson, (0, 1, 2); T=UInt8, Ti=Int8)
        dofo3 = DoFObject(:Boson, (0, 1, 2, 4); T=UInt8, Ti=Int8)
        @test isequal(dofo1, dofo2)
        @test !isequal(dofo1, dofo3)
    end

    @testset "Base.hash for DoFObject" begin
        dofo1 = DoFObject(:Emoji, (:🥳, :🙈); T=UInt8, Ti=Int8)
        dofo2 = DoFObject(:Emoji, (:🥳, :🙈); T=UInt8, Ti=Int8)
        dofo3 = DoFObject(:Emoji, (:😀, :😃, :😄); T=UInt8, Ti=Int8)
        h1 = hash(dofo1)
        h2 = hash(dofo2)
        h3 = hash(dofo3)
        @test h1 == h2
        @test h1 != h3
    end

    @testset "bint function for DoFObject" begin
        dofo = DoFObject(:Spin, (-1 // 2, 1 // 2); T=UInt16, Ti=Int8)
        @test bint(dofo) == BaseInt{UInt16,Int8,2}
    end

    @testset "Base.length for DoFObject" begin
        dofo1 = DoFObject(:Spin, (-1 // 2, 1 // 2); T=UInt16, Ti=Int8)
        @test length(dofo1) == 2

        dofo2 = DoFObject(:Spin, (-1 // 1, 0 // 1, 1 // 1))
        @test length(dofo2) == 3
    end
end
