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