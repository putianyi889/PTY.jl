module TR

using StaticArrays: MVector, SVector
using Graphs: SimpleDiGraph, add_edge!
export AND, XOR
export AndGate, XorGate, CombGate

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

"""
	(AndGate|XorGate){T<:Integer, V<:AbstractVector{<:Integer}}(gatestate::Bool, args::T, lampstates::V) <:AbstractGate
	CombGate{T, V} = Union{AndGate{T, V}, XorGate{T, V}}

Combinatory gates in Terraria. `gatestate` tells the default (when all inputs are zero) state of the gate. `args` tells the number of inputs. `lampstates` lists how the inputs are wired to each logic lamp. 

# Example
Consider `AndGate(false, 4, [0x12, 0x09, 0x04])`. It's an `AND` gate whose default state is `OFF`. Since there are `4` args (named `a-d`), we consider the last `5` bits of each entry of `lampstates`. The leading bit tells the default state of the lamps. The other 4 bits (from lower to higher) tell which args are wired to the lamp. i.e.,
- `0x12 = 0b10010` means the default state of the first lamp is `ON` and only `b` is connected to the lamp.
- `0x09 = 0b01001` means the default state of the second lamp is `OFF` and `a` and `d` are connected to the lamp.
- `0x04 = 0b00100` means the default state of the third lamp is `OFF` and only `c` is connected to the lamp.

```jldoctest
julia> TR.AndGate(false, 4, [0x12, 0x09, 0x04])
&(~b, ad, c)
```

The output is visualized via [`gate2string`](@ref).
"""
AndGate, XorGate, CombGate

abstract type AbstractGate end
struct AndGate{T<:Integer, V<:AbstractVector{<:Integer}} <:AbstractGate
	gatestate::Bool
	args::T
	lampstates::V
end
struct XorGate{T<:Integer, V<:AbstractVector{<:Integer}} <:AbstractGate
	gatestate::Bool
	args::T
	lampstates::V
end
const CombGate{T, V} = Union{AndGate{T, V}, XorGate{T, V}}
for GATE in (:AndGate, :XorGate)
	#@eval $GATE(gatestate::Bool, args::Integer, lampstates::AbstractVector{<:Integer}) = $GATE{typeof(args), typeof(lampstates)}(gatestate, args, lampstates)
	@eval Base.:(==)(A::$GATE, B::$GATE) = (A.gatestate == B.gatestate) && (A.args == B.args) && (A.lampstates == B.lampstates)
end

"""
	gate2string(G::CombGate)

Convert a `CombGate` into a readable string. See also [`CombGate`](@ref), [`lampstate2string`](@ref), [`logicsymb`](@ref).
"""
function gate2string(G::CombGate)
	ret = IOBuffer()
	print(ret, ifelse(G.gatestate, '~', ""), logicsymb(G), '(', lampstate2string(G.lampstates[1], G.args))
	for k in 2:lastindex(G.lampstates)
		print(ret, ", ", lampstate2string(G.lampstates[k], G.args))
	end
	print(ret, ')')
	return String(take!(ret))
end
Base.show(io::IO, G::CombGate) = print(io, gate2string(G))

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

|  in|  out||in|out|
|:-:|:-:|:-:|:-:|:-:|
|0000| true||0101|false|
|0001|false||0110| true|
|0010|false||0111|false|
|0011| true||1000|false|
|0100|false||1001| true|

Now we try to find a configuration with least lamps.
```jldoctest
julia> inputs = 16:25; # `0:9` with the 5th last bit set to `1`

julia> outputs = [true, false, false, true, false, false, true, false, false, true];

julia> TR.CombLogic(2, inputs, outputs) # there is no 2-lamp logic
PTY.TR.CombGate{Int64, StaticArraysCore.SVector{2, UInt8}}[]

julia> TR.CombLogic(3, inputs, outputs) # there are 12 3-lamp logics, all of which use XOR gates
12-element Vector{PTY.TR.CombGate{Int64, StaticArraysCore.SVector{3, UInt8}}}:
 ^(~b, ad, c)
 ^(~b, abd, bc)
 ^(~ac, ad, ab)
 ^(~ac, abd, a)
 ^(~ac, cd, bc)
 ^(~ac, bcd, c)
 ^(~bd, c, a)
 ^(~bd, bc, ab)
 ^(~bd, cd, ad)
 ^(~bd, bcd, abd)
 ^(~acd, bc, c)
 ^(~acd, abd, ad)
```
See also [`CombGate`](@ref)
"""
function CombLogic(lamps::Integer, inputs::AbstractVector{<:Integer}, outputs::AbstractVector{Bool})
	args = ndigits(inputs[1], base = 2) - true
	stack = MVector{lamps, UInt8}(undef)
	top = 1
	stack[1] = 0
	ret = Vector{CombGate{Int, SVector{lamps, UInt8}}}()
	cases = 1 << (args + true)
	while top > 0
		if top == lamps
			for k in 0:stack[lamps - 1]
				stack[lamps] = k
				if checkTTAND(stack, inputs, outputs)
					push!(ret, AndGate(false, args, SVector(stack)))
				elseif checkTTNAND(stack, inputs, outputs)
					push!(ret, AndGate(true, args, SVector(stack)))
				end
				if checkTTXOR(stack, inputs, outputs)
					push!(ret, XorGate(false, args, SVector(stack)))
				elseif checkTTNXOR(stack, inputs, outputs)
					push!(ret, XorGate(false, args, SVector(stack)))
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
	return ret
end

# TODO: convert the results to text
const alphabet = "abcdefghijklmnopqrstuvwxyz"

"""
	logicsymb(::typeof(AND|XOR)|::CombGate)

Return `'&'` or `'^'` according to input.
"""
logicsymb(::typeof(AND)) = '&'
logicsymb(::typeof(XOR)) = '^'
logicsymb(::AndGate) = '&'
logicsymb(::XorGate) = '^'

"""
	lampstate2string(lampstate::Integer, args::Integer)

Convert binary coded `lampstate` into a readable string. `args` tells the number of distinct inputs.
# Examples
```jldoctest
julia> TR.lampstate2string(0b1111, 4)
"abcd"

julia> TR.lampstate2string(0b11101, 4)
"~acd"

julia> TR.lampstate2string(0b10000, 4)
"~"
```
"""
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