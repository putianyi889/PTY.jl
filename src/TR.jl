module TR

using StaticArrays: MVector, SVector
using DataFrames: DataFrame

@inline AND(args::Bool...) = all(args)
@inline XOR(args::Bool...) = sum(args) == 1
@inline fuse(input::Integer) = isodd(count_ones(input))
@inline fuse(setup::Integer, input::Integer) = fuse(setup & input)

function LFSR(state::Int, plan::AbstractVector{Int}, len::Int)
	ret = state
	for k in 1:len
		if isodd(state)
			ret ⊻= plan[k]
		end
		state >>= 1
	end
	return ret
end

LFSR(plan::AbstractVector{Int}, len::Int) = [LFSR(n, plan, len) for n in 1:(1<<len - 1)]

function checkTTAND(setup::AbstractVector{<:Integer}, inputs::AbstractVector{<:Integer}, outputs::AbstractVector{Bool})
	for (input, output) in zip(inputs, outputs)
		if AND(fuse.(setup, input)...) != output
			return false
		end
	end
	return true
end
function checkTTNAND(setup::AbstractVector{<:Integer}, inputs::AbstractVector{<:Integer}, outputs::AbstractVector{Bool})
	for (input, output) in zip(inputs, outputs)
		if AND(fuse.(setup, input)...) == output
			return false
		end
	end
	return true
end
function checkTTXOR(setup::AbstractVector{<:Integer}, inputs::AbstractVector{<:Integer}, outputs::AbstractVector{Bool})
	for (input, output) in zip(inputs, outputs)
		if XOR(fuse.(setup, input)...) != output
			return false
		end
	end
	return true
end
function checkTTNXOR(setup::AbstractVector{<:Integer}, inputs::AbstractVector{<:Integer}, outputs::AbstractVector{Bool})
	for (input, output) in zip(inputs, outputs)
		if XOR(fuse.(setup, input)...) == output
			return false
		end
	end
	return true
end

"""
	CombLogic(lamps, inputs, outputs::AbstractVector{Bool})

Return the lists of possible combinatory logics for given `inputs` and `outputs`.

# Arguments	
- `lamps::Integer`: the number of logic lamps on the gate, from `2` to `7`.
- `inputs::AbstractVector{<:Integer}`: the list of input values specified by the lower bits of entries, with a `1` in front of the first bit.
- `outputs::AbstractVector{Bool}`: the expected return values of the logic. This should have the same length as `inputs`, although it's not strictly checked.

# Example
Imagine we want to check if a 4-bit input can be divided by 3. Further, the input is expected to have only one decimal digit, i.e. in `0:9`. We don't care how the logic behaves for inputs `10:15`. The truth table would be

```
|  in|  out|
|0000| true|
|0001|false|
|0010|false|
|0011| true|
|0100|false|
|0101|false|
|0110| true|
|0111|false|
|1000|false|
|1001| true|
```

Then we set `inputs = 16:25` (which is `0:9` with the 5th last bit set to `1`) and `outputs = [true, false, false, true, false, false, true, false, false, true]`. Now try to find a configuration with least lamps.
```julia-repl
julia> CombLogic(2, inputs, outputs)
(Tuple{Bool, StaticArraysCore.SVector{UInt8}}[], Tuple{Bool, StaticArraysCore.SVector{UInt8}}[])

julia> CombLogic(3, inputs, outputs)
(Tuple{Bool, SVector{3, UInt8}}[], Tuple{Bool, SVector{3, UInt8}}[(0, [0x12, 0x09, 0x04]), (0, [0x12, 0x0b, 0x06]), (0, [0x15, 0x09, 0x03]), (0, [0x15, 0x0b, 0x01]), (0, [0x15, 0x0c, 0x06]), (0, [0x15, 0x0e, 0x04]), (0, [0x1a, 0x04, 0x01]), (0, [0x1a, 0x06, 0x03]), (0, [0x1a, 0x0c, 0x09]), (0, [0x1a, 0x0e, 0x0b]), (0, [0x1d, 0x06, 0x04]), (0, [0x1d, 0x0b, 0x09])])
```
The first result says that there is no 2-lamp logic for the purpose. The second result says that there is no 3-lamp AND logic but many 3-lamp XOR logics for the purpose. To convert the results to readable texts, see `plan2string`.
"""
function CombLogic(lamps::Integer, inputs::AbstractVector{<:Integer}, outputs::AbstractVector{Bool})
	args = ndigits(inputs[1], base = 2)
	stack = MVector{lamps, UInt8}(undef)
	top = 1
	stack[1] = 0
	retAND = Vector{Tuple{Bool,SVector{lamps, UInt8}}}()
	retXOR = Vector{Tuple{Bool,SVector{lamps, UInt8}}}()
	cases = 1 << args
	while top > 0
		if top == lamps
			for k in 0:stack[lamps - 1]
				stack[lamps] = k
				if checkTTAND(stack, inputs, outputs)
					push!(retAND, (false, SVector(stack)))
				elseif checkTTNAND(stack, inputs, outputs)
					push!(retAND, (true, SVector(stack)))
				end
				if checkTTXOR(stack, inputs, outputs)
					push!(retXOR, (false, SVector(stack)))
				elseif checkTTNXOR(stack, inputs, outputs)
					push!(retXOR, (true, SVector(stack)))
				end
			end
			top = lamps - true
		elseif top == 1
			stack[1] += true
			if stack[1] > cases
				break
			else
				top = 2
			end
		else
			stack[top] += true
			if stack[top] > stack[top - 1]
				stack[top] = 0
				top -= true
			else
				top += true
			end
		end
	end
	return retAND, retXOR
end

# TODO: convert the results to text
const alphabet = "abcdefghijklmnopqrstuvwxyz"
logicsymb(::typeof(AND)) = '&'
logicsymb(::typeof(XOR)) = '^'

"""
	plan2string(f, args, gatestate, lampstates)
	plan2string(f, args, (gatestate, lampstates))

Convert the output of `CombLogic` to readable text.
# Arguments
- `f::Function`: must be `AND` or `XOR`.
- `args::Integer`: number of input wires.
- `gatestate::Bool`: the default state of the gate.
- `lampstates::AbstractVector{<:Integer}`: tells how the inputs are connected to the lamps.

# Example
Consider `plan2string(XOR, 4, false, [0x12, 0x09, 0x04])`. It's an `XOR` gate whose default state is `OFF`. Since there are `4` args (named `a-d`), we consider the last `5` bits of each entry of the following `Vector`. The leading bit tells the default state of the lamps. The other 4 bits (from lower to higher) tell which args are connected to the lamp. i.e.,
- `0x12 = 0b10010` means the default state of the first lamp is `ON` and only `b` is connected to the lamp.
- `0x09 = 0b01001` means the default state of the second lamp is `OFF` and `a` and `d` are connected to the lamp.
- `0x04 = 0b00100` means the default state of the third lamp is `OFF` and only `c` is connected to the lamp.

```julia-repl
julia> plan2string(XOR, 4, false, [0x12, 0x09, 0x04])
"^(~b, ad, c)"

julia> plan2string(AND, 6, (true, [0x7e, 0x70, 0x51]))
"~&(~bcdef, ~ef, ~ae)"
```
"""
function plan2string(f, args::Integer, gatestate::Bool, lampstates::AbstractVector{<:Integer})
	ret = ifelse(gatestate, "~", "") * logicsymb(f) * "(" * lampstate2string(lampstates[1], args)
	for k in 2:lastindex(lampstates)
		ret *= ", "
		ret *= lampstate2string(lampstates[k], args)
	end
	ret *= ")"
	return ret
end
plan2string(f, args, plan::Tuple{Bool, <:AbstractVector{<:Integer}}) = plan2string(f, args, plan...)
function lampstate2string(lampstate::Integer, args::Integer)
	ret = ifelse(isodd(lampstate >> args), "~", "")
	for k in 1:args
		if isodd(lampstate)
			ret *= alphabet[k]
		end
		lampstate >>= 1
	end
	return ret
end
end # module