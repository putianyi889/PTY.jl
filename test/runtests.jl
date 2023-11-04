using PTY, Test, Aqua, Documenter, LinearAlgebra, Nemo

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
			v[2] = false
			M[5, 1] = true
			N[1, 5] = true
			@test v == [0, 0, 1, 0, 1]
			@test M == TR.Z2RowMat([1, 3, 7, 15, 31], 5)
			@test N == TR.Z2ColMat([1, 3, 7, 15, 31], 5)

			# zero
			@test zero(v) == zeros(5) && zero(v) isa TR.Z2Vector
			@test zero(M) == zero(N) == zeros(5, 5) && zero(M) isa TR.Z2RowMat && zero(N) isa TR.Z2ColMat

			# one
			@test one(M) == one(Matrix(M)) == one(N)
			@test one(M) isa TR.Z2RowMat
			@test one(N) isa TR.Z2ColMat

			# copy
			@test copy(v) == v && copy(v) isa TR.Z2Vector
			@test copy(M) == M && copy(M) isa TR.Z2RowMat
			@test copy(N) == N && copy(N) isa TR.Z2ColMat

			# fill!
			vc = copy(v)
			Mc = copy(M)
			Nc = copy(N)
			fill!(vc, false)
			fill!(Mc, false)
			fill!(Nc, false)
			@test vc == zeros(5)
			@test Mc == Nc == zeros(5, 5)
			fill!(vc, true)
			fill!(Mc, true)
			fill!(Nc, true)
			@test vc == ones(5)
			@test Mc == Nc == ones(5, 5)

			# lmul!, rmul!
			@test lmul!(true, copy(v)) == v == rmul!(copy(v), true)
			@test lmul!(true, copy(M)) == M == rmul!(copy(M), true)
			@test lmul!(true, copy(N)) == N == rmul!(copy(N), true)
			@test lmul!(false, copy(v)) == zero(v) == rmul!(copy(v), false)
			@test lmul!(false, copy(M)) == zero(M) == rmul!(copy(M), false)
			@test lmul!(false, copy(N)) == zero(N) == rmul!(copy(N), false)
		end

		@testset "bitwise" begin
			m1 = rand(Bool, 5, 5)
			m2 = rand(Bool, 5, 5)
			n1 = rand(Bool, 5, 5)
			n2 = rand(Bool, 5, 5)
			v1 = rand(Bool, 5)
			v2 = rand(Bool, 5)

			M1 = TR.Z2RowMat(m1)
			M2 = TR.Z2RowMat(m2)
			N1 = TR.Z2ColMat(n1)
			N2 = TR.Z2ColMat(n2)
			V1 = TR.Z2Vector(v1)
			V2 = TR.Z2Vector(v2)

			@test ~M1 == (~).(m1) && isa(~M1, TR.Z2RowMat)
			@test ~N1 == (~).(n1) && isa(~N1, TR.Z2ColMat)
			@test ~V1 == (~).(v1) && isa(~V1, TR.Z2Vector)

			for op in (&, |, ⊻, ⊼, ⊽)
				@test op(M1, M2) == op.(m1, m2) && isa(op(M1, M2), TR.Z2RowMat)
				@test op(N1, N2) == op.(n1, n2) && isa(op(N1, N2), TR.Z2ColMat)
				@test op(V1, V2) == op.(v1, v2) && isa(op(V1, V2), TR.Z2Vector)
			end
		end

		@testset "algebra" begin
			Z2 = residue_ring(ZZ, 2)
			M = [rand(Bool, 5, 5) for n in 1:100] 
			AM = [matrix(Z2, M[n]) for n in 1:100]
			BM = TR.Z2RowMat.(M)
			CM = TR.Z2ColMat.(M)

			N = [rand(Bool, 5, 5) for n in 1:100] 
			AN = [matrix(Z2, N[n]) for n in 1:100]
			BN = TR.Z2RowMat.(N)
			CN = TR.Z2ColMat.(N)

			tB = BM .+ BN
			tC = CM .+ CN
			@test Matrix.(AM .+ AN) == tB == tC && eltype(tB) <: TR.Z2RowMat && eltype(tC) <: TR.Z2ColMat

			tB = BM .* BN
			tC = CM .* CN
			@test Matrix.(AM .* AN) == BM .* BN == CM .* CN && eltype(tB) <: TR.Z2RowMat && eltype(tC) <: TR.Z2ColMat
			@test det.(AM) == det.(BM) == det.(CM)
			@test rank.(AM) == rank.(BM) == rank.(CM)

			# find an invertible matrix
			while true
				m = rand(Bool, 5, 5)
				if isodd(det(m))
					break
				end
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
		x = inv.(z)
		@test SpecFun.mittleff.(2, -(z.^2)) ≈ cos.(z)
		@test SpecFun.mittleff.(2, -(x.^2)) ≈ cos.(x)
		@test SpecFun.mittleff.(4, z.^4) ≈ (cosh.(z)+cos.(z))./2
		@test SpecFun.mittleff.(4, x.^4) ≈ (cosh.(x)+cos.(x))./2

		@test_throws MethodError SpecFun.mittleff(im, 1.0) # complex parameter
		@test SpecFun.mittleff(-1, 1.0) ≈ 1 - ℯ # negative parameter
		SpecFun.mittleff(2, 1, 2, 1.0) # 3 parameters
		@test SpecFun.mittleff(1, 5, 0.0) ≈ 1/24 # gamma function
	end
	@testset "fracpochhammer" begin
		@test SpecFun.fracpochhammer(1, 2, 3) ≡ 0.25
		@test SpecFun.fracpochhammer(1, 2, 0.5, 1, 3) ≡ 0.125
	end
	@testset "linearfraction" begin
		A = SpecFun.LinearFractionalMap(1, 2, 3, 4)
		B = SpecFun.AffineMap(1, 2)
		C = SpecFun.LinearFractionalMap(B)

		@test SpecFun.AffineMap(C) == C == B
		@test one(A) == one(B) == identity == inv(A)∘A == A∘inv(A) == inv(B)∘B == B∘inv(B)
		@test_throws InexactError SpecFun.AffineMap(A)
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

	@testset "comparison" begin
		@test 1 < +∞
		@test 1 > -∞
		@test -∞ ≤ +∞
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
@testset "GenericSets" begin
	using PTY.GenericSets: ∅, ℝ, HalfLine, infimum, supremum, interior, closure, boundary
	@testset "construction" begin
		@test ∅ isa AbstractSet
		@test ℝ isa AbstractSet{Real}
		@test HalfLine(<,1) isa AbstractSet{Real}
		@test HalfLine(>=,0) isa AbstractSet{Real}
	end

	@testset "interface" begin
		A = ∅
		B = HalfLine(>, 0)
		C = HalfLine(≤, 1)
		D = Set(1)
		E = B ∩ C

		@testset "length" begin
			@test length(∅) == 0
			@test length(B) == +∞
			@test length(E) == +∞
		end

		@testset "infsup" begin
			@test infimum(D) == supremum(D) == 1
			@test infimum(B) == infimum(E) == 0
			@test supremum(B) == +∞
			@test infimum(C) == -∞
			@test supremum(C) == supremum(E) == 1
		end

		@testset "minmax" begin
			@test_throws MethodError minimum(A)
			@test_throws MethodError maximum(A)
			@test_throws ArgumentError minimum(B)
			@test maximum(B) == +∞
			@test minimum(C) == -∞
			@test maximum(C) == 1
			@test_throws ArgumentError minimum(E)
			@test maximum(E) == 1
		end

		@testset "interior" begin
			@test interior(A) == ∅
			@test interior(B) == HalfLine(>, 0)
			@test interior(C) == HalfLine(<, 1)
			@test interior(D) == ∅
			@test interior(E) == HalfLine(>, 0) ∩ HalfLine(<, 1)
		end

		@testset "closure" begin
			@test closure(A) == ∅
			@test closure(B) == HalfLine(≥, 0)
			@test closure(C) == HalfLine(≤, 1)
			@test closure(D) == D
			@test closure(E) == HalfLine(≥, 0) ∩ HalfLine(≤, 1)
		end

		@testset "boundary" begin
			@test boundary(A) == ∅
			@test boundary(B) == Set(0)
			@test boundary(C) == Set(1)
			@test boundary(D) == D
			@test_skip boundary(E) == Set([0,1])
		end
	end

	@testset "operation" begin
		A = ∅
		B = HalfLine(>, 0)
		C = HalfLine(≤, 1)
		D = HalfLine(<, 0)
		E = HalfLine(≥, 1)
		Y = ℝ
		Z = Set(1)
		
		@testset "issubset" begin
			for AA in (A,B,C,D,E,Y,Z)
				@test A ∩ AA == AA ∩ A == A
				@test A ∪ AA == AA ∪ A == Y ∩ AA == AA ∩ Y == AA
				@test Y ∪ AA == AA ∪ Y == Y
				@test A ⊆ AA
				@test AA ⊆ Y
			end
			for (AA,BB) in ((B,B),(E,B),(Z,B),(C,C),(D,C),(Z,C),(D,D),(E,E),(Z,E))
				@test AA ⊆ BB
				@test AA ∩ BB == BB ∩ AA == AA
				@test AA ∪ BB == BB ∪ AA == BB
			end
		end

		@testset "intersect" begin
			@test B ∩ D == D ∩ B == D ∩ E == E ∩ D == D ∩ Z == Z ∩ D == A
			@test B ∩ C isa GenericSets.Interval
			@test C ∩ B isa GenericSets.Interval
			@test C ∩ E == E ∩ C == Z
		end

		@testset "union" begin
			@test B ∪ D isa GenericSets.LazyUnion
			@test D ∪ B isa GenericSets.LazyUnion
			@test D ∪ E isa GenericSets.LazyUnion
			@test E ∪ D isa GenericSets.LazyUnion
			@test D ∪ Z isa GenericSets.LazyUnion
			@test Z ∪ D isa GenericSets.LazyUnion
			@test B ∪ C == C ∪ B == C ∪ E == E ∪ C == ℝ
		end
	end
end
@testset "examples" begin
	function segmentdisplay()
		include("../examples/segment-display.jl")
	end
	@test segmentdisplay() == 6
end