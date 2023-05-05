module TR

using StaticArrays: MVector, SVector

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
	CombLogic(lamps, args, inputs, outputs::AbstractVector{Bool})

Return the lists of possible combinatory logics for given `inputs` and `outputs`.

# Arguments	
- `lamps::Integer`: the number of logic lamps on the gate, from `2` to `7`.
- `args::Integer`: the number of input values.
- `inputs::AbstractVector{<:Integer}`: the list of input values specified by the lower bits of entries. 
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

Then we set `inputs = 0:9` and `outputs = [true, false, false, true, false, false, true, false, false, true]`. Now try to find a configuration with least lamps.
```julia-repl
julia> CombLogic(2, 4, inputs, outputs)
(Tuple{Bool, StaticArraysCore.SVector{UInt8}}[], Tuple{Bool, StaticArraysCore.SVector{UInt8}}[])

julia> CombLogic(3, 4, inputs, outputs)
(Tuple{Bool, SVector{3, UInt8}}[], Tuple{Bool, SVector{3, UInt8}}[(0, [0x12, 0x09, 0x04]), (0, [0x12, 0x0b, 0x06]), (0, [0x15, 0x09, 0x03]), (0, [0x15, 0x0b, 0x01]), (0, [0x15, 0x0c, 0x06]), (0, [0x15, 0x0e, 0x04]), (0, [0x1a, 0x04, 0x01]), (0, [0x1a, 0x06, 0x03]), (0, [0x1a, 0x0c, 0x09]), (0, [0x1a, 0x0e, 0x0b]), (0, [0x1d, 0x06, 0x04]), (0, [0x1d, 0x0b, 0x09])])
```
The first result says that there is no 2-lamp logic for the purpose. The second result says that there is no 3-lamp AND logic but many 3-lamp XOR logics for the purpose. Take the first logic `(0, [0x12, 0x09, 0x04])` for example. The leading `false` tells the default state of the gate. Since there are 4 args, we consider the last 5 bits of each entry of the following `Vector`. The leading bit tells the default state of the lamps. The other 4 bits tell which args are connected to the lamp. i.e.,
- `0x12 = 0b10010` means the default state of the first lamp is `ON` and only the third input is connected to the lamp.
- `0x09 = 0b01001` means the default state of the second lamp is `OFF` and the first and the fourth inputs are connected to the lamp.
- `0x04 = 0b00100` means the default state of the third lamp is `OFF` and only the second input is connected to the lamp.
"""
function CombLogic(lamps::Integer, args::Integer, inputs::AbstractVector{<:Integer}, outputs::AbstractVector{Bool})
	stack = MVector{lamps, UInt8}(undef)
	top = 1
	stack[1] = 0
	retAND = Vector{Tuple{Bool,SVector{lamps, UInt8}}}()
	retXOR = Vector{Tuple{Bool,SVector{lamps, UInt8}}}()
	cases = 1 << (args + true)
	inputs = inputs .| (1 << args)
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

end # module