using PTY, Test, Aqua, Documenter

DocMeta.setdocmeta!(PTY, :DocTestSetup, :(using PTY); recursive=true)

@testset "Docs" begin
	doctest(PTY)
end
@testset "Aqua" begin
	Aqua.test_all(PTY)
end
@testset "TR" begin
	@testset "elementary logic" begin
		@test TR.AND(true, false) === TR.AND(false, false) === TR.AND(false, true) === false
		@test TR.AND(true, true) === true
		@test TR.AND(true, true, false) === false
		@test TR.XOR(true) === TR.XOR(true, false) === TR.XOR(true, false, false) === true
		@test TR.XOR(false) === TR.XOR(true, true) === TR.XOR(false, false) === TR.XOR(true, true, false) === TR.XOR(false, false, false) === false
	end

	@testset "comblogic" begin

		@testset "Gates" begin
			G1 = TR.AndGate(true, 3, [0b1101, 0b1011])
			G2 = TR.XorGate(false, 4, [0x12, 0x09, 0x04])
			@test G1 isa TR.CombGate
			@test G2 isa TR.CombGate
			@test String(G1) === "~&(~ac, ~ab)"
			@test String(G2) === "^(~b, ad, c)"
		end
		inputs = 8:15; outputs = [false, true, true, true, true, true, true, false]
		ret = TR.CombLogic(2, inputs, outputs)
		@test ret == [TR.AndGate(true, 3, [0b1101, 0b1011]), TR.AndGate(true, 3, [0b1110, 0b1011]), TR.AndGate(true, 3, [0b1110, 0b1101])]
	end
end