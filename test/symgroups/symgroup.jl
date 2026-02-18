@testset "Testing SymGroup..." begin
    @testset "Construction of SymGroup" begin
        dofo = DoFObject(:Pet, (:🐶, :🐱, :🐢, :🦜))
        N = 4
        perm = mod1.((1:N) .+ 1, N)
        cycle = [(; perm=perm_k(perm, i)) for i in 0:(N-1)]
        factors = [1.0 for _ in 1:length(cycle)]

        sg1 = SymGroup(dofo, cycle, check_perm, apply_perm, factors, N)
        @test sg1.dofo == dofo
        @test sg1.cycles == cycle
        @test sg1.check == check_perm
        @test sg1.apply == apply_perm
        @test sg1.factors == factors
        @test sg1.N == N

        @test_throws AssertionError SymGroup(
            dofo, cycle, check_perm, apply_perm, factors[1:end-1], N
        )
    end

    @testset "Construction of CombSymGroup" begin

        dofo = dof_object(Spin(1 // 2))
        N = 3
        perm = mod1.((1:N) .+ 1, N)
        cycle = [
            [
                (; N0=N0, N1=length(perm) - N0, N=N),
                (; perm=perm_k(perm, i))]
            for i in 0:(N-1), N0 in 1:(N-1)
        ]
        checks = [check_perm, check_Nₛ]
        applies = [apply_perm, apply_Nₛ]
        factors = [1.0 for i in 0:(N-1), N0 in 1:(N-1)]

        csg1 = CombSymGroup(dofo, cycle, checks, applies, factors, N)
        @test csg1.dofo == dofo
        @test csg1.cycles == cycle
        @test csg1.check == checks
        @test csg1.apply == applies
        @test csg1.factors == factors
        @test csg1.N == N

        @test_throws AssertionError CombSymGroup(
            dofo, cycle, checks, applies, factors[1:end-1, :], N
        )
        @test_throws AssertionError CombSymGroup(
            dofo, cycle, checks, applies, factors[:, 1:end-1], N
        )
        @test_throws AssertionError CombSymGroup(
            dofo, cycle, checks[1:end-1], applies, factors, N
        )
        @test_throws AssertionError CombSymGroup(
            dofo, cycle, checks, applies[1:end-1], factors, N
        )
    end

    @testset "∘ for SymGroup" begin
        dofo = dof_object(Spin(3 // 2))
        N = 3
        sg1 = sym(TotalMagnetization(1 // 2, N), dofo)
        sg2 = sym(Translational(1, mod1.((1:N) .+ 1, N)), dofo)
        sg3 = sym(SpatialReflection(-1, mod1.(N:-1:1, N)), dofo)
        csg = sg1 ∘ sg2

        @testset "SymGroup ∘ SymGroup" begin
            @test csg.dofo == dofo
            @test csg.check == [sg1.check, sg2.check]
            @test csg.apply == [sg1.apply, sg2.apply]
            for i in eachindex(sg1.cycles), j in eachindex(sg2.cycles)
                @test csg.cycles[i, j] == [sg1.cycles[i], sg2.cycles[j]]
                @test csg.factors[i, j] ≈ sg1.factors[i] * sg2.factors[j]
            end

            @test_throws AssertionError begin
                sg1 ∘ sym(TotalMagnetization(1 // 2, N + 1), dof_object(Spin(3 // 2)))
            end
        end

        @testset "CombSymGroup ∘ SymGroup" begin
            csg2 = csg ∘ sg3
            @test csg2.dofo == dofo
            @test csg2.check == vcat(csg.check..., sg3.check)
            @test csg2.apply == vcat(csg.apply..., sg3.apply)
            for i in eachindex(sg1.cycles),
                j in eachindex(sg2.cycles),
                k in eachindex(sg3.cycles)

                @test csg2.cycles[i, j, k] == vcat(csg.cycles[i, j], sg3.cycles[k])
                @test csg2.factors[i, j, k] ≈ csg.factors[i, j] * sg3.factors[k]
            end

            @test_throws AssertionError begin
                csg ∘ sym(
                    SpatialReflection(-1, mod1.((N-1):-1:1, N)), dof_object(Spin(3 // 2))
                )
            end
        end

        @testset "SymGroup ∘ CombSymGroup" begin
            csg3 = sg3 ∘ csg
            @test csg3.dofo == dofo
            @test csg3.check == vcat(sg3.check, csg.check...)
            @test csg3.apply == vcat(sg3.apply, csg.apply...)
            for i in eachindex(sg3.cycles),
                j in eachindex(sg1.cycles),
                k in eachindex(sg2.cycles)

                @test csg3.cycles[i, j, k] == vcat(sg3.cycles[i], csg.cycles[j, k])
                @test csg3.factors[i, j, k] ≈ sg3.factors[i] * csg.factors[j, k]
            end

            @test_throws AssertionError begin
                sym(
                    SpatialReflection(-1, mod1.((N-1):-1:1, N)), dof_object(Spin(3 // 2))
                ) ∘ csg
            end
        end

        @testset "CombSymGroup ∘ CombSymGroup" begin
            csg4 = csg ∘ csg
            @test csg4.dofo == dofo
            @test csg4.check == vcat(csg.check..., csg.check...)
            @test csg4.apply == vcat(csg.apply..., csg.apply...)
            for i in eachindex(sg1.cycles),
                j in eachindex(sg2.cycles),
                k in eachindex(sg1.cycles),
                l in eachindex(sg2.cycles)

                @test csg4.cycles[i, j, k, l] == vcat(csg.cycles[i, j], csg.cycles[k, l])
                @test csg4.factors[i, j, k, l] ≈ csg.factors[i, j] * csg.factors[k, l]
            end
        end
    end

    @testset "_make_hashset for SymGroup" begin
        dofo = dof_object(Spin(1 // 2))
        N = 3
        sg1 = sym(TotalMagnetization(1 // 2, N), dofo)

        hashset_sg1 = _make_hashset(sg1)

        @test SmallHashSet{length(sg1.cycles),UInt}() == hashset_sg1
    end

    @testset "_make_hashset for CombSymGroup" begin
        dofo = dof_object(Spin(1 // 2))
        N = 3
        sg1 = sym(TotalMagnetization(1 // 2, N), dofo)
        sg2 = sym(Translational(1, mod1.((1:N) .+ 1, N)), dofo)
        csg = sg1 ∘ sg2

        hashset_csg = _make_hashset(csg)

        @test SmallHashSet{length(csg.cycles),UInt}() == hashset_csg
    end

    # @testset "_cycles_preview" begin
    #     # Test empty cycles
    #     @test SymBasis.SymGroups._cycles_preview([]) == "∅"

    #     # Test with few items (less than maxitems)
    #     cycles = [(; a=1, b=2), (; a=3, b=4), (; a=5, b=6)]
    #     preview = SymBasis.SymGroups._cycles_preview(cycles)
    #     @test contains(preview, "a = 1")
    #     @test contains(preview, "a = 3")
    #     @test contains(preview, "a = 5")
    #     @test !contains(preview, "…")

    #     # Test with many items (more than maxitems)
    #     cycles_many = [(; x=i) for i in 1:10]
    #     preview_many = SymBasis.SymGroups._cycles_preview(cycles_many; maxitems=4)
    #     @test contains(preview_many, "x = 1")
    #     @test contains(preview_many, "x = 4")
    #     @test !contains(preview_many, "x = 5")
    #     @test contains(preview_many, "…")
    # end

    # @testset "_print_kv" begin
    #     # Test basic key-value printing
    #     io = IOBuffer()
    #     SymBasis.SymGroups._print_kv(io, "Key1:", "Value1")
    #     str = String(take!(io))
    #     @test contains(str, "Key1:")
    #     @test contains(str, "Value1")

    #     # Test with custom indent
    #     io2 = IOBuffer()
    #     SymBasis.SymGroups._print_kv(io2, "Key2:", "Value2"; indent=4)
    #     str2 = String(take!(io2))
    #     @test startswith(str2, "    ")
    #     @test contains(str2, "Key2:")
    #     @test contains(str2, "Value2")
    # end

    @testset "Base.summary for SymGroup" begin
        dofo = dof_object(Spin(1 // 2))
        N = 3
        sg = sym(TotalMagnetization(1 // 2, N), dofo)

        summ = summary(sg)
        @test contains(summ, "SymGroup")
        @test contains(summ, "cycle(s)")
        @test contains(summ, string(length(sg.cycles)))
    end

    @testset "Base.summary for CombSymGroup" begin
        dofo = dof_object(Spin(1 // 2))
        N = 3
        sg1 = sym(TotalMagnetization(1 // 2, N), dofo)
        sg2 = sym(Translational(1, mod1.((1:N) .+ 1, N)), dofo)
        csg = sg1 ∘ sg2

        summ = summary(csg)
        @test contains(summ, "CombSymGroup")
        @test contains(summ, "size of cycles")
        @test contains(summ, string(size(csg.cycles)))
    end

    @testset "Base.show for SymGroup" begin
        dofo = dof_object(Spin(1 // 2))
        N = 3
        sg = sym(TotalMagnetization(1 // 2, N), dofo)

        # Test compact show
        io_compact = IOContext(IOBuffer(), :compact => true)
        show(io_compact, sg)
        str_compact = String(take!(io_compact.io))
        @test contains(str_compact, "SymGroup")
        @test contains(str_compact, "cycle(s)")

        # Test non-compact show
        io = IOBuffer()
        show(io, sg)
        str = String(take!(io))
        @test contains(str, "SymGroup")
        @test contains(str, "N:")
        @test contains(str, "DoF-object:")
        @test contains(str, "cycles:")
        @test contains(str, "factors:")
        @test contains(str, "check:")
        @test contains(str, "apply:")

        # Test text/plain MIME
        io_mime = IOBuffer()
        show(io_mime, MIME("text/plain"), sg)
        str_mime = String(take!(io_mime))
        @test contains(str_mime, "SymGroup")
        @test contains(str_mime, "N:")

        # Test edge case: SymGroup with zero cycles
        sg_empty = SymGroup(dofo, NamedTuple[], check_perm, apply_perm, Float64[], N)
        io_empty = IOBuffer()
        show(io_empty, sg_empty)
        str_empty = String(take!(io_empty))
        @test contains(str_empty, "SymGroup")
        @test contains(str_empty, "∅")
    end

    @testset "Base.show for CombSymGroup" begin
        dofo = dof_object(Spin(1 // 2))
        N = 3
        sg1 = sym(TotalMagnetization(1 // 2, N), dofo)
        sg2 = sym(Translational(1, mod1.((1:N) .+ 1, N)), dofo)
        csg = sg1 ∘ sg2

        # Test compact show
        io_compact = IOContext(IOBuffer(), :compact => true)
        show(io_compact, csg)
        str_compact = String(take!(io_compact.io))
        @test contains(str_compact, "CombSymGroup")
        @test contains(str_compact, "size of cycles")

        # Test non-compact show
        io = IOBuffer()
        show(io, csg)
        str = String(take!(io))
        @test contains(str, "CombSymGroup")
        @test contains(str, "N:")
        @test contains(str, "DoF-object:")
        @test contains(str, "cycles:")
        @test contains(str, "factors:")
        @test contains(str, "check:")
        @test contains(str, "apply:")
        @test contains(str, "preview")

        # Test text/plain MIME
        io_mime = IOBuffer()
        show(io_mime, MIME("text/plain"), csg)
        str_mime = String(take!(io_mime))
        @test contains(str_mime, "CombSymGroup")
        @test contains(str_mime, "N:")
        @test contains(str_mime, "preview")
    end
end
