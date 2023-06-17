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

include("TR/gates.jl")
include("TR/comblogic.jl")
include("TR/z2mat.jl")

end # module