var documenterSearchIndex = {"docs":
[{"location":"Z2LA/#\\mathbb{Z}_2-linear-algebra","page":"mathbbZ_2 linear algebra","title":"mathbbZ_2 linear algebra","text":"","category":"section"},{"location":"Z2LA/","page":"mathbbZ_2 linear algebra","title":"mathbbZ_2 linear algebra","text":"Since this implementation uses bitwise operations, it's significantly faster than the generic interface provided by Nemo.jl.","category":"page"},{"location":"Z2LA/","page":"mathbbZ_2 linear algebra","title":"mathbbZ_2 linear algebra","text":"Defines Z2Vector, Z2RowMat and Z2ColMat.","category":"page"},{"location":"Z2LA/#Construction","page":"mathbbZ_2 linear algebra","title":"Construction","text":"","category":"section"},{"location":"Z2LA/#Vectors","page":"mathbbZ_2 linear algebra","title":"Vectors","text":"","category":"section"},{"location":"Z2LA/","page":"mathbbZ_2 linear algebra","title":"mathbbZ_2 linear algebra","text":"Constructor Implemented\nfrom an integer and a bitlength ✅\nfrom undef ❌\nfrom a vector ✅","category":"page"},{"location":"Z2LA/#Matrices","page":"mathbbZ_2 linear algebra","title":"Matrices","text":"","category":"section"},{"location":"Z2LA/","page":"mathbbZ_2 linear algebra","title":"mathbbZ_2 linear algebra","text":"Constructing from undef sets all entries to zero since methods are implemented assuming that all higher bits are zero.","category":"page"},{"location":"Z2LA/","page":"mathbbZ_2 linear algebra","title":"mathbbZ_2 linear algebra","text":"Constructor Z2RowMat Z2ColMat\nfrom a vector and a bitlength ✅ ✅\nfrom undef ✅ ✅\nfrom a matrix ✅ ✅","category":"page"},{"location":"Z2LA/#Interface","page":"mathbbZ_2 linear algebra","title":"Interface","text":"","category":"section"},{"location":"Z2LA/","page":"mathbbZ_2 linear algebra","title":"mathbbZ_2 linear algebra","text":"getindex and setindex! are only implemented for single entries at the moment, which means accessing a submatrix is relatively slow.","category":"page"},{"location":"Z2LA/","page":"mathbbZ_2 linear algebra","title":"mathbbZ_2 linear algebra","text":"Method Z2Vector Z2RowMat Z2ColMat\nsize ✅ ✅ ✅\ngetindex ✅ ✅ ✅\nsetindex! ✅ ✅ ✅\nzero ✅ ✅ ✅\none 🔘 ✅ ✅\ncopy ✅ ✅ ✅\nsimilar ✅ ✅ ✅\nfill! ✅ ✅ ✅\nlmul! ✅ ✅ ✅\nrmul! ✅ ✅ ✅\n+ ✅ ✅ ✅\ntranspose 🔘 ✅ ✅\nadjoint 🔘 ✅ ✅\nistril 🔘 ❌ ❌\nistriu 🔘 ❌ ❌\nrank 🔘 ✅ ✅\ndet 🔘 ✅ ✅","category":"page"},{"location":"Z2LA/#Bitwise-operations","page":"mathbbZ_2 linear algebra","title":"Bitwise operations","text":"","category":"section"},{"location":"Z2LA/","page":"mathbbZ_2 linear algebra","title":"mathbbZ_2 linear algebra","text":"Operation Z2Vector Z2RowMat Z2ColMat\n~ ❌ ✅ ✅\n& ❌ ✅ ✅\n| ❌ ✅ ✅\n⊻ ❌ ✅ ✅\n⊽ ❌ ✅ ✅\n⊼ ❌ ✅ ✅","category":"page"},{"location":"Z2LA/#Algebra","page":"mathbbZ_2 linear algebra","title":"Algebra","text":"","category":"section"},{"location":"Z2LA/","page":"mathbbZ_2 linear algebra","title":"mathbbZ_2 linear algebra","text":"Method Implemented Complexity\ndot(::Z2Vector, ::Z2Vector) ✅ O(1)\n*(::Z2RowMat, ::Z2Vector) ✅ O(n)\n*(::Z2ColMat, ::Z2Vector) ✅ O(n)\n*(::Z2RowMat, ::Z2RowMat) ✅ O(n^2)\n\\(::Z2RowMat, ::Z2RowMat) ✅ O(n^2)","category":"page"},{"location":"#PTY.jl","page":"PTY.jl","title":"PTY.jl","text":"","category":"section"},{"location":"","page":"PTY.jl","title":"PTY.jl","text":"Documentation for PTY.jl","category":"page"},{"location":"#Type-piracies-by-PTY.Helper","page":"PTY.jl","title":"Type piracies by PTY.Helper","text":"","category":"section"},{"location":"","page":"PTY.jl","title":"PTY.jl","text":"// falls back to / for float inputs\n: for range construction now supports complex arithmetic progressions\nAbstractArray{T, N}(A::BroadcastArray{S, N}) for eltype conversion","category":"page"},{"location":"#PTY.TR-for-Terraria","page":"PTY.jl","title":"PTY.TR for Terraria","text":"","category":"section"},{"location":"","page":"PTY.jl","title":"PTY.jl","text":"See also \\mathbb{Z}_2-linear-algebra.","category":"page"},{"location":"","page":"PTY.jl","title":"PTY.jl","text":"Modules = [PTY.TR]","category":"page"},{"location":"#PTY.TR.CombGate","page":"PTY.jl","title":"PTY.TR.CombGate","text":"(AndGate|XorGate){T<:Integer, V<:AbstractVector{<:Integer}}(gatestate::Bool, args::T, lampstates::V) <:AbstractGate\nCombGate{T, V} = Union{AndGate{T, V}, XorGate{T, V}}\n\nCombinatory gates in Terraria. gatestate tells the default (when all inputs are zero) state of the gate. args tells the number of inputs. lampstates lists how the inputs are wired to each logic lamp. \n\nExample\n\nConsider AndGate(false, 4, [0x12, 0x09, 0x04]). It's an AND gate whose default state is OFF. Since there are 4 args (named a-d), we consider the last 5 bits of each entry of lampstates. The leading bit tells the default state of the lamps. The other 4 bits (from lower to higher) tell which args are wired to the lamp. i.e.,\n\n0x12 = 0b10010 means the default state of the first lamp is ON and only b is connected to the lamp.\n0x09 = 0b01001 means the default state of the second lamp is OFF and a and d are connected to the lamp.\n0x04 = 0b00100 means the default state of the third lamp is OFF and only c is connected to the lamp.\n\njulia> TR.AndGate(false, 4, [0x12, 0x09, 0x04])\n&(~b, ad, c)\n\nThe output is visualized via gate2string.\n\n\n\n\n\n","category":"type"},{"location":"#PTY.TR.AndGate","page":"PTY.jl","title":"PTY.TR.AndGate","text":"(AndGate|XorGate){T<:Integer, V<:AbstractVector{<:Integer}}(gatestate::Bool, args::T, lampstates::V) <:AbstractGate\nCombGate{T, V} = Union{AndGate{T, V}, XorGate{T, V}}\n\nCombinatory gates in Terraria. gatestate tells the default (when all inputs are zero) state of the gate. args tells the number of inputs. lampstates lists how the inputs are wired to each logic lamp. \n\nExample\n\nConsider AndGate(false, 4, [0x12, 0x09, 0x04]). It's an AND gate whose default state is OFF. Since there are 4 args (named a-d), we consider the last 5 bits of each entry of lampstates. The leading bit tells the default state of the lamps. The other 4 bits (from lower to higher) tell which args are wired to the lamp. i.e.,\n\n0x12 = 0b10010 means the default state of the first lamp is ON and only b is connected to the lamp.\n0x09 = 0b01001 means the default state of the second lamp is OFF and a and d are connected to the lamp.\n0x04 = 0b00100 means the default state of the third lamp is OFF and only c is connected to the lamp.\n\njulia> TR.AndGate(false, 4, [0x12, 0x09, 0x04])\n&(~b, ad, c)\n\nThe output is visualized via gate2string.\n\n\n\n\n\n","category":"type"},{"location":"#PTY.TR.XorGate","page":"PTY.jl","title":"PTY.TR.XorGate","text":"(AndGate|XorGate){T<:Integer, V<:AbstractVector{<:Integer}}(gatestate::Bool, args::T, lampstates::V) <:AbstractGate\nCombGate{T, V} = Union{AndGate{T, V}, XorGate{T, V}}\n\nCombinatory gates in Terraria. gatestate tells the default (when all inputs are zero) state of the gate. args tells the number of inputs. lampstates lists how the inputs are wired to each logic lamp. \n\nExample\n\nConsider AndGate(false, 4, [0x12, 0x09, 0x04]). It's an AND gate whose default state is OFF. Since there are 4 args (named a-d), we consider the last 5 bits of each entry of lampstates. The leading bit tells the default state of the lamps. The other 4 bits (from lower to higher) tell which args are wired to the lamp. i.e.,\n\n0x12 = 0b10010 means the default state of the first lamp is ON and only b is connected to the lamp.\n0x09 = 0b01001 means the default state of the second lamp is OFF and a and d are connected to the lamp.\n0x04 = 0b00100 means the default state of the third lamp is OFF and only c is connected to the lamp.\n\njulia> TR.AndGate(false, 4, [0x12, 0x09, 0x04])\n&(~b, ad, c)\n\nThe output is visualized via gate2string.\n\n\n\n\n\n","category":"type"},{"location":"#PTY.TR.Z2ColMat","page":"PTY.jl","title":"PTY.TR.Z2ColMat","text":"Z2ColMat{C<:Integer, R<:Integer}(data::Vector{C}, size::Int)\nZ2ColMat(undef, m, n)\nZ2ColMat(::AbstractMatrix)\n\nmathbbZ_2 matrix stored in a Vector where each entry represents a column. size specifies the height. C and R are used for dispatch; they specify the integer type used to represent a column vector and a row vector respectively. See also bit2type, Z2RowMat\n\nExample\n\njulia> TR.Z2ColMat([1, 3, 5], 3)\n3×3 PTY.TR.Z2ColMat{UInt8, UInt8}:\n 1  1  1\n 0  1  0\n 0  0  1\n\n\n\n\n\n","category":"type"},{"location":"#PTY.TR.Z2RowMat","page":"PTY.jl","title":"PTY.TR.Z2RowMat","text":"Z2RowMat{C<:Integer, R<:Integer}(data::Vector{R}, size::Int)\nZ2RowMat(undef, m, n)\nZ2RowMat(::AbstractMatrix)\n\nmathbbZ_2 matrix stored in a Vector where each entry represents a row. size specifies the width. C and R are used for dispatch; they specify the integer type used to represent a column vector and a row vector respectively. See also bit2type, Z2ColMat\n\nExample\n\njulia> TR.Z2RowMat([1, 3, 5], 3)\n3×3 PTY.TR.Z2RowMat{UInt8, UInt8}:\n 1  0  0\n 1  1  0\n 1  0  1\n\n\n\n\n\n","category":"type"},{"location":"#PTY.TR.Z2Vector","page":"PTY.jl","title":"PTY.TR.Z2Vector","text":"Z2Vector{T<:Integer}(data::T, size::Int)\nZ2Vector(::AbstractVector)\n\nmathbbZ_2 vector stored in an integer data where each bit represents an entry. size specifies the length.\n\nExample\n\njulia> TR.Z2Vector(0b10110, 5)\n5-element PTY.TR.Z2Vector{UInt8}:\n 0\n 1\n 1\n 0\n 1\n\n\n\n\n\n","category":"type"},{"location":"#PTY.TR.CombLogic-Tuple{Integer, AbstractVector{<:Integer}, AbstractVector{Bool}}","page":"PTY.jl","title":"PTY.TR.CombLogic","text":"CombLogic(lamps, inputs, outputs::AbstractVector{Bool})\n\nReturn the lists of possible combinatory logics for given inputs and outputs.\n\nArguments\n\nlamps::Integer: the number of logic lamps on the gate, from 2 to 7.\ninputs::AbstractVector{<:Integer}: the list of input values specified by the lower bits of entries, with a 1 in front of the first bit.\noutputs::AbstractVector{Bool}: the expected return values of the logic. This should have the same length as inputs, although it's not strictly checked.\n\nExample\n\nImagine we want to check if a 4-bit input can be divided by 3. Further, the input is expected to have only one decimal digit, i.e. in 0:9. We don't care how the logic behaves for inputs 10:15. The truth table would be\n\nin out  in out\n0000 true  0101 false\n0001 false  0110 true\n0010 false  0111 false\n0011 true  1000 false\n0100 false  1001 true\n\nNow we try to find a configuration with least lamps.\n\njulia> inputs = 16:25; # `0:9` with the 5th last bit set to `1`\n\njulia> outputs = [true, false, false, true, false, false, true, false, false, true];\n\njulia> TR.CombLogic(2, inputs, outputs) # there is no 2-lamp logic\nPTY.TR.CombGate{Int64, StaticArraysCore.SVector{2, UInt8}}[]\n\njulia> TR.CombLogic(3, inputs, outputs) # there are 12 3-lamp logics, all of which use XOR gates\n12-element Vector{PTY.TR.CombGate{Int64, StaticArraysCore.SVector{3, UInt8}}}:\n ^(~b, ad, c)\n ^(~b, abd, bc)\n ^(~ac, ad, ab)\n ^(~ac, abd, a)\n ^(~ac, cd, bc)\n ^(~ac, bcd, c)\n ^(~bd, c, a)\n ^(~bd, bc, ab)\n ^(~bd, cd, ad)\n ^(~bd, bcd, abd)\n ^(~acd, bc, c)\n ^(~acd, abd, ad)\n\nSee also CombGate\n\n\n\n\n\n","category":"method"},{"location":"#PTY.TR.bit2type-Tuple{Integer}","page":"PTY.jl","title":"PTY.TR.bit2type","text":"bit2type(n::Integer) :: DataType\n\nReturns minimal integer type that contains n bits\n\nExamples\n\njulia> TR.bit2type(5)\nUInt8\n\njulia> TR.bit2type(9)\nUInt16\n\njulia> TR.bit2type(32)\nUInt32\n\njulia> TR.bit2type(33)\nUInt64\n\njulia> TR.bit2type(100)\nBigInt\n\n\n\n\n\n","category":"method"},{"location":"#PTY.TR.gate2string-Tuple{PTY.TR.CombGate}","page":"PTY.jl","title":"PTY.TR.gate2string","text":"gate2string(G::CombGate)\n\nConvert a CombGate into a readable string. See also CombGate, lampstate2string, logicsymb.\n\n\n\n\n\n","category":"method"},{"location":"#PTY.TR.getbit-Tuple{Integer, Integer}","page":"PTY.jl","title":"PTY.TR.getbit","text":"getbit(x::Integer, n::Integer)\n\nGet the n-th (counting from zero) last bit of x. See also setbit\n\nExample\n\njulia> [TR.getbit(0b10110, n) for n in 0:4]\n5-element Vector{Bool}:\n 0\n 1\n 1\n 0\n 1\n\n\n\n\n\n","category":"method"},{"location":"#PTY.TR.lampstate2string-Tuple{Integer, Integer}","page":"PTY.jl","title":"PTY.TR.lampstate2string","text":"lampstate2string(lampstate::Integer, args::Integer)\n\nConvert binary coded lampstate into a readable string. args tells the number of distinct inputs.\n\nExamples\n\njulia> TR.lampstate2string(0b1111, 4)\n\"abcd\"\n\njulia> TR.lampstate2string(0b11101, 4)\n\"~acd\"\n\njulia> TR.lampstate2string(0b10000, 4)\n\"~\"\n\n\n\n\n\n","category":"method"},{"location":"#PTY.TR.logicsymb-Tuple{typeof(PTY.TR.AND)}","page":"PTY.jl","title":"PTY.TR.logicsymb","text":"logicsymb(::typeof(AND|XOR)|::CombGate)\n\nReturn '&' or '^' according to input.\n\n\n\n\n\n","category":"method"},{"location":"#PTY.TR.setbit-Tuple{Integer, Bool, Integer}","page":"PTY.jl","title":"PTY.TR.setbit","text":"setbit(x::Integer, y::Bool, n::Integer)\n\nSet the n-th (counting from zero) last bit of x to y. See also getbit.\n\nExample\n\njulia> string(TR.setbit(0b10110, true, 0), base = 2)\n\"10111\"\n\njulia> string(TR.setbit(0b10110, false, 0), base = 2)\n\"10110\"\n\n\n\n\n\n","category":"method"},{"location":"#PTY.TR.type2bit-Union{Tuple{Type{T}}, Tuple{T}} where T<:Integer","page":"PTY.jl","title":"PTY.TR.type2bit","text":"type2bit(::Type{T})\n\nThe inverse of bit2type.\n\n\n\n\n\n","category":"method"},{"location":"#PTY.TR.z2number-Tuple{Bool}","page":"PTY.jl","title":"PTY.TR.z2number","text":"z2number(::Number)\nz2number(::AbstractMatrix{<:Number})\n\nConvert Number to Bool in the mathbbZ_2 sense.\n\nExamples\n\njulia> TR.z2number(25)\ntrue\n\njulia> TR.z2number(1:5)\n5-element BitVector:\n 1\n 0\n 1\n 0\n 1\n\n\n\n\n\n","category":"method"},{"location":"#PTY.SpecFun-for-special-functions","page":"PTY.jl","title":"PTY.SpecFun for special functions","text":"","category":"section"},{"location":"","page":"PTY.jl","title":"PTY.jl","text":"Modules = [PTY.SpecFun]","category":"page"},{"location":"#PTY.SpecFun.fracpochhammer-Tuple{Any, Any, Any}","page":"PTY.jl","title":"PTY.SpecFun.fracpochhammer","text":"fracpochhammer(a, b, n)\n\nCalculate the fraction of two Pochhammer symbols frac(a)_n(b)_n by multiplying the fractions. This approach reduces the risk of overflow/underflow when n is large.\n\nExamples\n\njulia> SpecFun.fracpochhammer(1, 2, 3) # (1 * 2 * 3) / (2 * 3 * 4)\n0.25\n\nfracpochhammer(a, b, stepa, stepb, n)\n\nSimilar to fracpochhammer(a, b, n), except that the steps of the Pochhammer symbols are not necessarily 1.\n\nExamples\n\njulia> SpecFun.fracpochhammer(1, 2, 0.5, 1, 3) # (1 * 1.5 * 2) / (2 * 3 * 4)\n0.125\n\n\n\n\n\n","category":"method"},{"location":"#PTY.SpecFun.mittleff-NTuple{4, Any}","page":"PTY.jl","title":"PTY.SpecFun.mittleff","text":"mittleff(α, β, γ, z)\nmittleff(α, β, z) = mittleff(α, β, 1, z)\nmittleff(α, z) = mittleff(α, 1, z)\n\nCompute the Mittag-Leffler function of one variable z. The codes are translated from https://uk.mathworks.com/matlabcentral/fileexchange/48154-the-mittag-leffler-function\n\n\n\n\n\n","category":"method"},{"location":"#PTY.ContFrac-for-continued-fractions","page":"PTY.jl","title":"PTY.ContFrac for continued fractions","text":"","category":"section"},{"location":"","page":"PTY.jl","title":"PTY.jl","text":"Modules = [PTY.ContFrac]","category":"page"},{"location":"#PTY.ContFrac.ContinuedFraction","page":"PTY.jl","title":"PTY.ContFrac.ContinuedFraction","text":"ContinuedFraction(b0, a, b)\n\nThe continued fraction b_0+fraca_1b_1+fraca_2b_2+fraca_3b_3+fraca_4b_4+cdots. Each entry represents a truncated fraction.\n\nExample\n\njulia> using InfiniteArrays, FillArrays\n\njulia> ContFrac.ContinuedFraction(1, Ones{Int}(∞), Ones{Int}(∞)) # the golden ratio\nℵ₀-element PTY.ContFrac.ContinuedFraction{Rational{Int64}, Ones{Rational{Int64}, 1, Tuple{InfiniteArrays.OneToInf{Int64}}}, Ones{Rational{Int64}, 1, Tuple{InfiniteArrays.OneToInf{Int64}}}} with indices OneToInf():\n   2//1\n   3//2\n   5//3\n   8//5\n  13//8\n  21//13\n  34//21\n  55//34\n  89//55\n 144//89\n    ⋮\n\n\n\n\n\n","category":"type"},{"location":"#PTY.ContFrac.cfrac-Union{Tuple{T}, Tuple{typeof(exp), T}} where T","page":"PTY.jl","title":"PTY.ContFrac.cfrac","text":"cfrac(f, x)\n\nThe continued fraction converging to f(x). Currently supported functions: exp, log, sin, tan, csc, atanh\n\n\n\n\n\n","category":"method"},{"location":"#PTY.Infs-for-infinities","page":"PTY.jl","title":"PTY.Infs for infinities","text":"","category":"section"},{"location":"","page":"PTY.jl","title":"PTY.jl","text":"This is an experiment of rewriting Infinities.jl. This module is not expected to work at present.","category":"page"}]
}
