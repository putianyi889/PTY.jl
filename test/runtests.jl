using PTY,Test

@testset "TR" begin
	@testset "elementary logic" begin
		@test TR.AND(true, false) === TR.AND(false, false) === TR.AND(false, true) === false
		@test TR.AND(true, true) === true
		@test TR.AND(true, true, false) === false
		@test TR.XOR(true) === TR.XOR(true, false) === TR.XOR(true, false, false) === true
		@test TR.XOR(false) === TR.XOR(true, true) === TR.XOR(false, false) === TR.XOR(true, true, false) === TR.XOR(false, false, false) === false
	end

	@testset "comblogic" begin
		inputs = 8:15; outputs = [false, true, true, true, true, true, true, false]
		retAND, retXOR = TR.CombLogic(2, inputs, outputs)
		@test retAND == [(true, [0b1101, 0b1011]), (true, [0b1110, 0b1011]), (true, [0b1110, 0b1101])]
		@test isempty(retXOR)

		@test TR.plan2string(TR.AND, 3, true, [0b1101, 0b1011]) === TR.plan2string(TR.AND, 3, (true, [0b1101, 0b1011])) === "~&(~ac, ~ab)"
		@test TR.plan2string(TR.XOR, 4, false, [0x12, 0x09, 0x04]) === "^(~b, ad, c)"
	end
end