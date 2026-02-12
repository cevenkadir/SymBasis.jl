@testset "Tests for BaseInt" begin
    @testset "Construction of BaseInt" begin
        b = BaseInt(10 |> UInt; base=2, Ti=Int)
        @test b.value == 10
        @test typeof(b) == BaseInt{UInt,Int,2}

        b2 = BaseInt(255; base=6, Ti=Int16)
        @test b2.value == 255
        @test typeof(b2) == BaseInt{Int,Int16,6}

        b3 = BaseInt(1000 |> UInt16; base=10, Ti=Int8)
        @test b3.value == 1000
        @test typeof(b3) == BaseInt{UInt16,Int8,10}
    end

    @testset "Macro bi_str for BaseInt" begin
        b = bi"101"2
        @test b.value == 5

        b2 = bi"101"3
        @test b2.value == 10

        b3 = BaseInt(5 |> UInt; base=2)
        @test b3 == b
    end

    @testset "Base.copy for BaseInt" begin
        b = BaseInt(101; base=2)
        cb = copy(b)

        @test cb == b
    end

    @testset "Base.:(==) for BaseInt" begin
        a1 = bi"101"2
        a2 = bi"101"2
        @test a1 == a2

        b1 = bi"105"6
        b2 = bi"104"6
        @test b1 != b2

        c1 = bi"123"4
        c2 = bi"123"5
        @test c1 != c2
    end

    @testset "Base.isequal for BaseInt" begin
        a1 = bi"235"6
        a2 = bi"235"6
        @test isequal(a1, a2)

        b1 = bi"120"3
        b2 = bi"121"3
        @test !isequal(b1, b2)

        c1 = bi"45"8
        c2 = bi"45"9
        @test !isequal(c1, c2)
    end

    @testset "Base.hash for BaseInt" begin
        a1 = bi"321"7
        a2 = bi"321"7
        @test hash(a1) == hash(a2)

        b1 = bi"210"4
        b2 = bi"211"4
        @test hash(b1) != hash(b2)

        c1 = bi"56"9
        c2 = bi"56"10
        @test hash(c1) != hash(c2)
    end

    @testset "Base.iterate for BaseInt" begin
        b = bi"123"4
        digits = collect(b)
        @test digits == [bi"123"4,]

        b2 = bi"4567"8
        digits2 = collect(b2)
        @test digits2 == [bi"4567"8,]

        b3 = bi"890"10
        digits3 = collect(b3)
        @test digits3 == [bi"890"10,]
    end

    @testset "Base.show for BaseInt" begin
        b = bi"1101"2
        io = IOBuffer()
        show(io, b)
        str = String(take!(io))
        @test str == "(1101)₂"

        b2 = bi"254"6
        io2 = IOBuffer()
        show(io2, b2)
        str2 = String(take!(io2))
        @test str2 == "(254)₆"

        b3 = bi"0201"5
        io3 = IOBuffer()
        show(io3, b3)
        str3 = String(take!(io3))
        @test str3 == "(201)₅"
    end

    @testset "flip for BaseInt" begin
        a = bi"1010"2
        af = flip(a, 2)
        afₛ = flip(a, [2, 4])
        @test af == bi"1000"2
        @test afₛ == bi"0000"2

        b = bi"345"6
        bf = flip(b, 1)
        bfₛ = flip(b, [1, 3])
        @test bf == bi"340"6
        @test bfₛ == bi"240"6

        c = bi"1203"4
        cf = flip(c, 5)
        cfₛ = flip(c, [6, 7])
        @test cf == bi"31203"4
        @test cfₛ == bi"3301203"4
    end

    @testset "inc for BaseInt" begin
        a = bi"101"2
        ai = inc(a, 2)
        aiₛ = inc(a, [1, 3])
        @test ai == bi"111"2
        @test aiₛ == bi"1010"2

        b = bi"345"6
        bi = inc(b, 1)
        biₛ = inc(b, [2, 3])
        @test bi == bi"350"6
        @test biₛ == bi"455"6

        c = bi"1203"4
        ci = inc(c, 5)
        ciₛ = inc(c, [6, 8])
        @test ci == bi"11203"4
        @test ciₛ == bi"10101203"4

        # Edge case: carry propagation through existing digit positions
        # Incrementing a digit creating carry that propagates to next position
        d = bi"1011"2  # Binary: increment position 2 (the second 1)
        di = inc(d, 2)
        @test di == bi"1101"2  # Carry propagates from position 2 to position 3

        # Edge case: carry propagation creates new leading digit
        e = bi"1101"2  # Increment position 3
        ei = inc(e, 3)
        # Carry propagates through positions 3-4 and creates new position 5
        @test ei == bi"10001"2

        # Edge case: carry propagation in higher base
        f = bi"1455"6  # Increment position 1 (5 becomes 0, carry to position 2)
        fi = inc(f, 1)
        @test fi == bi"1500"6  # Carry propagates from position 1 to position 2

        # Edge case: carry propagation through multiple positions
        g = bi"1155"6  # Increment position 1
        gi = inc(g, 1)
        # Position 1: 5→0 + carry, Position 2: 5→0 + carry, Position 3: 1→2
        @test gi == bi"1200"6

        # Edge case: increment causing carry in middle positions
        h = bi"10111"2  # Increment position 2
        hi = inc(h, 2)
        @test hi == bi"11001"2  # Carry propagates through positions 2-4

        # Edge case: carry in base 3 with consecutive max digits
        i = bi"1022"3  # Increment position 1
        ii = inc(i, 1)
        # Position 1: 2→0 + carry, Position 2: 2→0 + carry, Position 3: 0→1
        @test ii == bi"1100"3

        # Edge case: single carry without propagation
        j = bi"1010"2  # Increment position 1
        ji = inc(j, 1)
        @test ji == bi"1011"2  # No carry propagation needed
    end

    @testset "dec for BaseInt" begin
        a = bi"101"2
        ad = dec(a, 1)
        adₛ = dec(a, [2, 3])
        @test ad == bi"100"2
        @test adₛ == bi"111"2

        b = bi"345"6
        bd = dec(b, 3)
        bdₛ = dec(b, [1, 2])
        @test bd == bi"245"6
        @test bdₛ == bi"334"6

        c = bi"1203"4
        cd = dec(c, 5)
        cdₛ = dec(c, [6, 8])
        @test cd == bi"31203"4
        @test cdₛ == bi"30301203"4

        # Edge case: borrow propagation through multiple zero positions
        # Decrementing position 1 when all lower positions are 0
        d = bi"10000"2  # Binary: decrement position 1 (which is 0)
        dd = dec(d, 1)
        # Borrow propagates from position 5 through all intermediate positions
        @test dd == bi"01111"2

        # Edge case: borrow propagation in higher base
        e = bi"1500"6  # Decrement position 1 (which is 0, need to borrow)
        ed = dec(e, 1)
        @test ed == bi"1455"6  # Position 1→5, borrow from position 2: [0,5] → [5,4]

        # Edge case: borrow propagation through multiple positions in base 6
        f = bi"1200"6  # Decrement position 1
        fd = dec(f, 1)
        @test fd == bi"1155"6  # Borrow from position 3, fill positions 1-2 with 5

        # Edge case: borrow causing cascading changes in binary
        g = bi"100000"2  # Decrement position 2
        gd = dec(g, 2)
        @test gd == bi"011110"2  # Borrow from position 6, fill positions 2-5 with 1

        # Edge case: borrow in base 3 with multiple zeros
        h = bi"10000"3  # Decrement position 1
        hd = dec(h, 1)
        @test hd == bi"02222"3  # Borrow from position 5, fill positions 1-4 with 2

        # Edge case: borrow without intermediate zeros
        i = bi"1010"2  # Decrement position 2 (which is 1, no borrow needed)
        id = dec(i, 2)
        @test id == bi"1000"2  # Direct decrement, no borrow propagation
    end

    @testset "num_digits_in_base for BaseInt" begin
        a = bi"10101"2
        @test num_digits_in_base(a.value, 2) == 5

        b = bi"3456"7
        @test num_digits_in_base(b.value, 7) == 4

        c = bi"120303"4
        @test num_digits_in_base(c.value, 4) == 6

        d = bi"01306"10
        @test num_digits_in_base(d.value, 10) == 4
    end

    @testset "permute (dof) for BaseInt" begin
        a = bi"1234"5
        ap = permute(a, [2, 4, 1, 3])
        @test ap == bi"2413"5

        b = bi"56789"10
        bp = permute(b, [5, 4, 3, 2, 1])
        @test bp == bi"98765"10

        c = bi"1203"4
        cp = permute(c, [3, 1, 4, 2])
        @test cp == bi"132"4

        d = bi"427"8
        dp = permute(d, [1, 4, 2, 3])
        @test dp == bi"4207"8
    end

    @testset "permute (ldof) for BaseInt" begin
        a = bi"1234"5
        ap = permute(a, 2, [1, 3, 4, 0, 2])
        @test ap == bi"1204"5

        b = bi"20312"4
        bp = permute(b, 4, [2, 1, 0, 3])
        @test bp == bi"22312"4

        c = bi"55031"6
        cp = permute(c, [1, 4], [0, 2, 4, 1, 5, 3])
        @test cp == bi"53032"6
    end

    @testset "read for BaseInt" begin
        a = bi"02153"7
        digit_a = read(a, 2)
        @test digit_a == 5

        b = bi"10101"2
        digits_b = read(b, [1, 3, 5])
        @test digits_b == [1, 1, 1]

        c = bi"3456"7
        digits_c = read(c, [2, 4])
        @test digits_c == [5, 3]

        d = bi"120303"4
        digits_d = read(d, [1, 2, 3, 4, 5, 6])
        @test digits_d == [3, 0, 3, 0, 2, 1]
    end

    @testset "write for BaseInt" begin
        a = bi"12210"3
        aw = write(a, 2, 2)
        @test aw == bi"12220"3

        b = bi"11111"2
        bw = write(b, [1, 3, 5], [0, 0, 0])
        @test bw == bi"01010"2

        c = bi"120303"4
        cw = write(c, [1, 2, 3, 4, 5, 6], [0, 1, 0, 1, 0, 1])
        @test cw == bi"101010"4
    end

    @testset "count for BaseInt" begin
        a = bi"120120"3
        count_a = count(a, [1, 2, 3, 4], 0)
        @test count_a == 2

        b = bi"000666"7
        count_b = count(b, [1, 2, 3, 4, 5, 6], 2)
        @test count_b == 0

        c = bi"345345"6
        counts_c = count(c, [1, 2, 3, 4], [2, 3, 4, 5])
        @test counts_c == [0, 1, 1, 2]
    end
end
