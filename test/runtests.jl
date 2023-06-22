using PTY, Test, Aqua, Documenter, LinearAlgebra

DocMeta.setdocmeta!(PTY, :DocTestSetup, :(using PTY); recursive=true)

@testset "Docs" begin
	doctest(PTY)
end
@testset "Aqua" begin
	Aqua.test_all(PTY, ambiguities = false, piracy = false)
end
@testset "TR" begin
	@testset "elementary logic" begin
		@test TR.AND(true, false) === TR.AND(false, false) === TR.AND(false, true) === false
		@test TR.AND(true, true) === true
		@test TR.AND(true, true, false) === false
		@test TR.XOR(true) === TR.XOR(true, false) === TR.XOR(true, false, false) === true
		@test TR.XOR(false) === TR.XOR(true, true) === TR.XOR(false, false) === TR.XOR(true, true, false) === TR.XOR(false, false, false) === false
	end

	@testset "Z2 linear algebra" begin
		@testset "constructors" begin
			@test TR.Z2Vector(0b10110, 5) == TR.Z2Vector([0, 1, 1, 0, 1]) == [0, 1, 1, 0, 1]
			@test TR.Z2RowMat([1, 2, 4, 8, 0], 5) == TR.Z2RowMat(Diagonal([1, 1, 1, 1, 0])) == TR.Z2ColMat([1, 2, 4, 8, 0], 5) == TR.Z2ColMat(Diagonal([1, 1, 1, 1, 0])) == Diagonal([1, 1, 1, 1, 0])
		end

		@testset "interface" begin
			v = TR.Z2Vector(0b10110, 5)
			M = TR.Z2RowMat([1, 3, 7, 15, 30], 5)
			N = TR.Z2ColMat([1, 3, 7, 15, 30], 5)

			# size
			@test size(v) == (5, )
			@test size(M) == size(N) == (5, 5)

			# setindex!, getindex
			M[5, 1] = true
			N[1, 5] = true
			@test M == TR.Z2RowMat([1, 3, 7, 15, 31], 5)
			@test N == TR.Z2ColMat([1, 3, 7, 15, 31], 5)

			# zero
			@test zero(M) == zero(N) == zeros(5, 5)
			@test zero(M) isa TR.Z2RowMat
			@test zero(N) isa TR.Z2ColMat

			# one
			@test one(M) == one(Matrix(M)) == one(N)
			@test one(M) isa TR.Z2RowMat
			@test one(N) isa TR.Z2ColMat

			# copy
			@test copy(M) == M
			@test copy(N) == N
			@test copy(M) isa TR.Z2RowMat
			@test copy(N) isa TR.Z2ColMat

			# fill!
			Mc = copy(M)
			Nc = copy(N)
			fill!(Mc, false)
			fill!(Nc, false)
			@test Mc == Nc == zeros(5, 5)
			fill!(Mc, true)
			fill!(Nc, true)
			@test Mc == Nc == ones(5, 5)
		end

		@testset "bitwise" begin
			m1 = rand(Bool, 5, 5)
			m2 = rand(Bool, 5, 5)
			n1 = rand(Bool, 5, 5)
			n2 = rand(Bool, 5, 5)

			M1 = TR.Z2RowMat(m1)
			M2 = TR.Z2RowMat(m2)
			N1 = TR.Z2ColMat(n1)
			N2 = TR.Z2ColMat(n2)

			@test ~M1 == ~.(m1) && isa(~M1, TR.Z2RowMat)
			@test ~N1 == ~.(n1) && isa(~N1, TR.Z2ColMat)

			for op in (:&, :|, :⊻, :⊼, :⊽)
				@test op(M1, M2) == op.(m1, m2) && isa(op(M1, M2), TR.Z2RowMat)
				@test op(N1, N2) == op.(n1, n2) && isa(op(N1, N2), TR.Z2ColMat)
			end
		end
	end

	@testset "comblogic" begin

		@testset "Gates" begin
			G1 = TR.AndGate(true, 3, [0b1101, 0b1011])
			G2 = TR.XorGate(false, 4, [0x12, 0x09, 0x04])
			@test G1 isa TR.CombGate
			@test G2 isa TR.CombGate
			@test TR.gate2string(G1) === "~&(~ac, ~ab)"
			@test TR.gate2string(G2) === "^(~b, ad, c)"
		end
		inputs = 8:15; outputs = [false, true, true, true, true, true, true, false]
		ret = TR.CombLogic(2, inputs, outputs)
		@test ret == [TR.AndGate(true, 3, [0b1101, 0b1011]), TR.AndGate(true, 3, [0b1110, 0b1011]), TR.AndGate(true, 3, [0b1110, 0b1101])]
	end
end
@testset "special functions" begin
	@testset "mittagleffler" begin
		z = randn(100)
		@test SpecFun.mittleff.(2, -(z.^2)) ≈ cos.(z)
	end
	@testset "fracpochhammer" begin
		@test SpecFun.fracpochhammer(1, 2, 3) ≡ 0.25
		@test SpecFun.fracpochhammer(1, 2, 0.5, 1, 3) ≡ 0.125
	end
end
@testset "ContinuedFraction" begin
	x = rand(100)
	@test getindex.(ContFrac.cfrac.(exp, x), 10) ≈ exp.(x)
	@test getindex.(ContFrac.cfrac.(log, x .+ 1), 10) ≈ log.(x .+ 1) # not working for log(0+)
	@test getindex.(ContFrac.cfrac.(atanh, 0.5 * x), 10) ≈ atanh.(0.5 * x) # not working for atanh(-1+) and atanh(1-)
	@test getindex.(ContFrac.cfrac.(csc, x), 10) ≈ csc.(x)
	@test getindex.(ContFrac.cfrac.(sin, x), 10) ≈ sin.(x)
	@test getindex.(ContFrac.cfrac.(tan, x), 10) ≈ tan.(x)
end
@testset "Infinities" begin
	using PTY.Infs: ∞
	@testset "construction" begin
		@test Infs.Infinity(Complex) isa Infs.Infinity{Complex}
		@test Infs.PosInf(Irrational) isa Infs.PosInf{Irrational}
		@test Infs.NegInf(AbstractFloat) isa Infs.NegInf{AbstractFloat}
		@test Infs.NotANumber() isa Infs.NotANumber{Bool}
	end

	@testset "algebra" begin
		@test 1 + ∞ ≡ +Int(∞)
		@test 1.0 + ∞ ≡ 1 + Float64(∞) ≡ +Float64(∞)
		@test 1 - ∞ ≡ -Int(∞) ≡ Int(-∞)
		@test ∞ + ∞ ≡ +∞
		@test ∞ - ∞ ≡ Infs.NotANumber()
		@test -∞ - ∞ ≡ -∞
	end
end
@testset "examples" begin
	function segmentdisplay()
		include("../examples/segment-display.jl")
	end
	@test segmentdisplay() == 6
end