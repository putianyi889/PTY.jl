module SpecFun

using SpecialFunctions: gamma

include("SpecFun/mittagleffler.jl")
include("SpecFun/linearfraction.jl")

logistic(r, x) = r*x*(1-x)

end # module