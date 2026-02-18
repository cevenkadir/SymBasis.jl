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
end
