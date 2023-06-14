using PTY, Test, Aqua, Documenter

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

	@testset "LFSR" begin
		
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