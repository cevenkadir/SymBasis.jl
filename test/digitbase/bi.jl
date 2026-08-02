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

        # Edge case: underflow check when permute decreases digit value
        d = BaseInt(UInt(1); base=10, Ti=Int)  # Value is 1 (digit at pos 1 is 1)
        # Permute position 1: digit 1 → digit 0 (decreasing)
        # This should work fine as 1 - 1 * 10^0 = 0 >= typemin(UInt)
        dp = permute(d, 1, [5, 0, 2, 3, 4, 1, 6, 7, 8, 9])
        @test dp.value == 0

        # Edge case: overflow check when permute increases digit value
        # Using UInt8 type with a value near typemax
        e = BaseInt(UInt8(254); base=10, Ti=Int)  # Value is 254
        # digit at position 1 is 4, position 2 is 5, position 3 is 2
        # Permute position 1: digit 4 → digit 5 (increasing by 1)
        # new_val would be 254 + 1 = 255, which is still <= typemax(UInt8) = 255
        ep = permute(e, 1, [1, 2, 3, 4, 5, 0, 6, 7, 8, 9])
        @test ep.value == 255

        # Edge case: overflow error when permute would exceed typemax
        f = BaseInt(UInt8(255); base=10, Ti=Int)  # Value is 255 (max for UInt8)
        # digit at position 1 is 5, position 2 is 5, position 3 is 2
        # Try to permute position 1: digit 5 → digit 6 (increasing)
        # new_val would be 255 + 1 = 256 > typemax(UInt8) = 255
        @test_throws OverflowError permute(f, 1, [1, 2, 3, 4, 5, 6, 7, 8, 9, 0])
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

        # Edge case: underflow check when write decreases digit value
        d = BaseInt(UInt(5); base=10, Ti=Int)  # Value is 5 (digit at pos 1 is 5)
        # Write position 1: digit 5 → digit 0 (decreasing by 5)
        # new_val = 5 - 5 = 0 >= typemin(UInt)
        dw = write(d, 1, 0)
        @test dw.value == 0

        # Edge case: overflow check when write increases digit value
        # Using UInt8 type with a value near typemax
        e = BaseInt(UInt8(245); base=10, Ti=Int)  # Value is 245
        # digit at position 1 is 5, position 2 is 4, position 3 is 2
        # Write position 1: digit 5 → digit 9 (increasing by 4)
        # new_val = 245 + 4 = 249 <= typemax(UInt8) = 255
        ew = write(e, 1, 9)
        @test ew.value == 249

        # Edge case: overflow error when write would exceed typemax
        f = BaseInt(UInt8(255); base=10, Ti=Int)  # Value is 255 (max for UInt8)
        # digit at position 1 is 5, position 2 is 5, position 3 is 2
        # Try to write position 1: digit 5 → digit 6 (increasing by 1)
        # new_val = 255 + 1 = 256 > typemax(UInt8) = 255
        @test_throws OverflowError write(f, 1, 6)

        # Edge case: another overflow test with larger delta
        g = BaseInt(UInt8(200); base=10, Ti=Int)  # Value is 200
        # digit at position 1 is 0, position 2 is 0, position 3 is 2
        # Try to write position 2: digit 0 → digit 9 (increasing by 90)
        # new_val = 200 + 90 = 290 > typemax(UInt8) = 255
        @test_throws OverflowError write(g, 2, 9)
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

    @testset "eachdigit for BaseInt" begin
        # Agrees with `read` across bases, and pads with zeros past the value's length.
        for (base, val, n) in [(2, 0b1011, 6), (4, 1234, 8), (3, 500, 7), (2, 0, 4),
            (10, 90210, 6), (6, 12345, 3)]
            b = BaseInt(UInt(val); base=base)
            @test collect(eachdigit(b, n)) == [read(b, i) for i in 1:n]
        end

        b = bi"1011"2
        @test collect(eachdigit(b, 4)) == UInt[1, 1, 0, 1]
        @test length(eachdigit(b, 7)) == 7
        @test eltype(eachdigit(b, 7)) == UInt
        @test collect(eachdigit(b, 0)) == UInt[]

        # Iteration must not allocate: it is meant for the innermost loops.
        b4 = BaseInt(UInt(1234); base=4)
        sumdigits(x, n) = (s = zero(UInt); for d in eachdigit(x, n)
            s += d
        end; s)
        sumdigits(b4, 8)
        @test (@allocated sumdigits(b4, 8)) == 0
        @test sumdigits(b4, 8) == sum(read(b4, i) for i in 1:8)

        @test_throws ArgumentError eachdigit(b, -1)
    end

    @testset "power-of-two digit fast path matches the generic arithmetic" begin
        # `read`/`flip`/`inc`/`dec`/`write`/`permute` take a shift-and-mask path when the
        # base is a power of two. It must agree with the plain `B^(pos-1)` / `÷` / `%`
        # arithmetic everywhere, including where a narrow `T` makes the place value exceed
        # the width of the stored value.
        ref_digit(v, B, pos) = (v ÷ B^(pos - 1)) % B

        for base in (2, 3, 4, 5, 8, 10, 16), T in (UInt8, UInt16, UInt64)
            vals = T === UInt8 ? (T(0):typemax(T)) :         # exhaustive for UInt8
                   T.(rand(UInt16, 64))                       # sampled otherwise
            for v in vals, pos in 1:6
                b = BaseInt(T(v); base=base, Ti=Int)
                @test read(b, pos) == ref_digit(v, base, pos)
                @test count(b, [pos], read(b, pos) % base) == 1
            end
        end

        # Round-trip and mutation consistency on the power-of-two bases, against digits
        # recovered independently through `eachdigit`.
        for base in (2, 4, 8, 16)
            for v in rand(UInt32, 200), pos in 1:4
                b = BaseInt(UInt(v); base=base)
                digits_before = collect(eachdigit(b, 8))

                @test read(b, pos) == digits_before[pos]
                @test read(flip(b, pos), pos) == (base - 1) - read(b, pos)
                @test read(write(b, pos, 1), pos) == 1
                @test collect(eachdigit(write(b, pos, 1), 8)) ==
                      [i == pos ? UInt(1) : digits_before[i] for i in 1:8]

                # `inc`/`dec` are exact inverses away from the carry/borrow boundaries.
                if read(b, pos) < base - 1
                    @test dec(inc(b, pos), pos) == b
                end
                if read(b, pos) > 0
                    @test inc(dec(b, pos), pos) == b
                end

                perm = circshift(0:(base-1), 1)
                @test read(permute(b, pos, perm), pos) == perm[read(b, pos)+1]
            end
        end
    end

    @testset "contiguous-range read/count match the per-position path" begin
        # `read`/`count` over a UnitRange walk the digits once instead of looking each
        # position up independently. The result must be identical to the generic method,
        # which is reached by passing the very same positions as a plain vector.
        for base in (2, 3, 4, 5, 8, 10, 16), T in (UInt8, UInt64)
            vals = T === UInt8 ? T.(0:8:255) : T.(rand(UInt32, 40))
            ranges = [1:1, 1:4, 1:12, 2:5, 3:3, 7:20, 5:4]  # last one is empty
            for v in vals, r in ranges
                b = BaseInt(T(v); base=base, Ti=Int)
                @test read(b, r) == read(b, collect(r))
                @test typeof(read(b, r)) == typeof(read(b, collect(r)))
                for d in 0:min(base - 1, 3)
                    @test count(b, r, d) == count(b, collect(r), d)
                end
            end
        end

        # Positions past the width of the stored value read as zero on both paths.
        b8 = BaseInt(UInt8(200); base=4, Ti=Int)
        @test read(b8, 1:10) == read(b8, collect(1:10))
        @test count(b8, 1:10, 0) == count(b8, collect(1:10), 0)

        # Unordered, repeated and strided positions keep using the generic path.
        b = BaseInt(UInt(1234); base=4)
        @test read(b, [4, 1, 1, 2]) == [read(b, 4), read(b, 1), read(b, 1), read(b, 2)]
        @test read(b, 1:2:7) == [read(b, p) for p in 1:2:7]
        @test count(b, [3, 3, 1], 1) == count(b, [3, 3, 1], 1)

        # Empty and invalid ranges behave like the generic method.
        @test read(b, 3:2) == UInt[]
        @test count(b, 3:2, 1) == 0
        @test_throws ArgumentError read(b, 0:3)
        @test_throws ArgumentError count(b, 0:3, 1)
        @test_throws ArgumentError count(b, 1:3, 4)
    end
end
