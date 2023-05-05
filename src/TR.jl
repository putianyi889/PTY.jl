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

LFSR(plan::AbstractVector{Int}, len::Int) = [GenRecur(n, plan, len) for n in 1:(1<<len - 1)]

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

function CombLogic(lamps::Integer, args::Integer, inputs::AbstractVector{<:Integer}, outputs::AbstractVector{Bool})
	stack = MVector{lamps, UInt8}(undef)
	top = 1
	stack[1] = 0
	retAND = Vector{Tuple{Bool,Vector{UInt8}}}()
	retXOR = Vector{Tuple{Bool,Vector{UInt8}}}()
	cases = 1 << (args + true)
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