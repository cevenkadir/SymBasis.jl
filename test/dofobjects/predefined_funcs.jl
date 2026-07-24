@testset "Testing DoFObject's predefined functions..." begin
    @testset "dof_object of :Spin for DoFObject" begin
        dofo1 = dof_object(Spin(1 // 2; T=UInt32, Ti=Int32))
        @test dofo1.type == :Spin
        @test dofo1.ldof == (-1 // 2, 1 // 2)
        @test typeof(dofo1) == DoFObject{2,Rational{Int64},UInt32,Int32}

        dofo2 = dof_object(Spin(1 // 1))
        @test dofo2.type == :Spin
        @test dofo2.ldof == (-1 // 1, 0 // 1, 1 // 1)
        @test typeof(dofo2) == DoFObject{3,Rational{Int64},UInt64,Int64}

        dofo3 = dof_object(Spin(3 // 2; T=Int16, Ti=Int16))
        @test dofo3.type == :Spin
        @test dofo3.ldof == (-3 // 2, -1 // 2, 1 // 2, 3 // 2)
        @test typeof(dofo3) == DoFObject{4,Rational{Int64},Int16,Int16}
    end

    @testset "Boson construction (UInt auto-sizing)" begin
        # max_occupancy=3 ≤ 255 → UInt8
        b1 = Boson(3)
        @test typeof(b1) == Boson{UInt8,UInt64,Int64}
        @test b1.max_occupancy === UInt8(3)

        # max_occupancy=256 > 255 → UInt16
        b2 = Boson(256)
        @test typeof(b2) == Boson{UInt16,UInt64,Int64}
        @test b2.max_occupancy === UInt16(256)

        # custom T and Ti
        b3 = Boson(3; T=UInt32, Ti=Int32)
        @test typeof(b3) == Boson{UInt8,UInt32,Int32}
        @test b3.max_occupancy === UInt8(3)
    end

    @testset "dof_object of :Boson for DoFObject" begin
        dofo1 = dof_object(Boson(3))
        @test dofo1.type == :Boson
        @test dofo1.ldof == (0, 1, 2, 3)
        @test typeof(dofo1) == DoFObject{4,Int64,UInt64,Int64}

        dofo2 = dof_object(Boson(256))
        @test dofo2.type == :Boson
        @test dofo2.ldof == Tuple(0:256)
        @test typeof(dofo2) == DoFObject{257,Int64,UInt64,Int64}

        dofo3 = dof_object(Boson(3; T=UInt32, Ti=Int32))
        @test dofo3.type == :Boson
        @test dofo3.ldof == (0, 1, 2, 3)
        @test typeof(dofo3) == DoFObject{4,Int64,UInt32,Int32}
    end

    @testset "SpinlessFermion construction and dof_object" begin
        sf1 = SpinlessFermion()
        @test typeof(sf1) == SpinlessFermion{UInt64,Int64}

        sf2 = SpinlessFermion(T=UInt32, Ti=Int32)
        @test typeof(sf2) == SpinlessFermion{UInt32,Int32}

        dofo1 = dof_object(sf1)
        @test dofo1.type == :SpinlessFermion
        @test dofo1.ldof == (0, 1)
        @test typeof(dofo1) == DoFObject{2,Int64,UInt64,Int64}

        dofo2 = dof_object(sf2)
        @test dofo2.type == :SpinlessFermion
        @test dofo2.ldof == (0, 1)
        @test typeof(dofo2) == DoFObject{2,Int64,UInt32,Int32}
    end

    @testset "SpinfulFermion construction (UInt auto-sizing)" begin
        # max_occupancy=3 ≤ 255 → UInt8
        sf1 = SpinfulFermion(1 // 2, 3)
        @test typeof(sf1) == SpinfulFermion{Rational{Int64},UInt8,UInt64,Int64}
        @test sf1.max_occupancy === UInt8(3)

        # max_occupancy=256 > 255 → UInt16
        sf2 = SpinfulFermion(1 // 2, 256)
        @test typeof(sf2) == SpinfulFermion{Rational{Int64},UInt16,UInt64,Int64}
        @test sf2.max_occupancy === UInt16(256)

        # custom T and Ti
        sf3 = SpinfulFermion(1 // 2, 3; T=UInt32, Ti=Int32)
        @test typeof(sf3) == SpinfulFermion{Rational{Int64},UInt8,UInt32,Int32}
        @test sf3.max_occupancy === UInt8(3)
    end

    @testset "dof_object of :SpinfulFermion for DoFObject" begin
        # spin-1/2, max_occupancy=2: doublons allowed, B=4
        dofo1 = dof_object(SpinfulFermion(1 // 2, 2))
        @test dofo1.type == :SpinfulFermion
        @test dofo1.ldof == (
            Rational{Int64}[], Rational{Int64}[-1//2], Rational{Int64}[1//2],
            Rational{Int64}[-1//2, 1//2]
        )
        @test typeof(dofo1) == DoFObject{4,Vector{Rational{Int64}},UInt64,Int64}

        # spin-1/2, max_occupancy=1: doublons forbidden, B=3
        dofo2 = dof_object(SpinfulFermion(1 // 2, 1))
        @test dofo2.type == :SpinfulFermion
        @test dofo2.ldof == (
            Rational{Int64}[], Rational{Int64}[-1//2], Rational{Int64}[1//2]
        )
        @test typeof(dofo2) == DoFObject{3,Vector{Rational{Int64}},UInt64,Int64}

        # custom T and Ti
        dofo3 = dof_object(SpinfulFermion(1 // 2, 2; T=UInt32, Ti=Int32))
        @test dofo3.type == :SpinfulFermion
        @test dofo3.ldof == dofo1.ldof
        @test typeof(dofo3) == DoFObject{4,Vector{Rational{Int64}},UInt32,Int32}
    end
end
