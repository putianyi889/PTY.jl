module ContFrac

import Base: getindex, size, eltype, *, copy, +
import Base.Broadcast: BroadcastStyle
import InfiniteArrays: ∞
import LazyArrays: Vcat, LazyArrayStyle
import FillArrays: Fill, Ones
using PTYQoL

"""
    ContinuedFraction(b0, a, b)

The continued fraction ``b_0+\\frac{a_1}{b_1+\\frac{a_2}{b_2+\\frac{a_3}{b_3+\\frac{a_4}{b_4+\\cdots}}}}``. Each entry represents a truncated fraction.

# Example

```jldoctest
julia> using InfiniteArrays, FillArrays

julia> ContFrac.ContinuedFraction(1, Ones{Int}(∞), Ones{Int}(∞)) # the golden ratio
ℵ₀-element PTY.ContFrac.ContinuedFraction{Rational{Int64}, Ones{Rational{Int64}, 1, Tuple{InfiniteArrays.OneToInf{Int64}}}, Ones{Rational{Int64}, 1, Tuple{InfiniteArrays.OneToInf{Int64}}}} with indices OneToInf():
    2
   3//2
   5//3
   8//5
  13//8
  21//13
  34//21
  55//34
  89//55
 144//89
    ⋮
```
"""
struct ContinuedFraction{V,S<:AbstractVector{V},T<:AbstractVector{V}} <:AbstractVector{V}
    b0::V
    a::S
    b::T
end
function ContinuedFraction(b0::V, a::AbstractVector{V}, b::AbstractVector{V}) where V<:Union{Integer, Complex{<:Integer}}
    T = rationaltype(V)
    ContinuedFraction(T(b0), convert(AbstractVector{T}, a), convert(AbstractVector{T}, b))
end
function ContinuedFraction(b0::V1, a::AbstractVector{V2}, b::AbstractVector{V3}) where {V1, V2, V3}
    T = promote_type(V1,V2,V3)
    ContinuedFraction(T(b0), convert(AbstractVector{T}, a), convert(AbstractVector{T}, b))
end
function ContinuedFraction(a::AbstractVector{U}, b::AbstractVector{V}) where {U, V}
    T = promote_type(U, V)
    ContinuedFraction(zero(T), convert(AbstractVector{T}, a), convert(AbstractVector{T}, b))
end

rationaltype(::Type{T}) where T = T
rationaltype(::Type{T}) where T<:Integer = Rational{T}
rationaltype(::Type{Complex{T}}) where T<:Integer = Complex{Rational{T}}

# Abstract interfaces
size(v::ContinuedFraction) = size(v.a)
function getindex(v::ContinuedFraction, k::Integer)
    ret = zero(eltype(v))
    for j in k:-1:1
        ret = v.a[j] / (v.b[j] + ret)
    end
    ret + v.b0
end
@struct_copy ContinuedFraction
BroadcastStyle(::Type{<:ContinuedFraction}) = LazyArrayStyle{1}()

+(x::Number, v::ContinuedFraction) = ContinuedFraction(x+v.b0, copy(v.a), copy(v.b))
+(v::ContinuedFraction, x::Number) = ContinuedFraction(v.b0+x, copy(v.a), copy(v.b))

"""
    cfrac(f, x)

The continued fraction converging to `f(x)`. Currently supported functions: `exp`, `log`, `sin`, `tan`, `csc`, `atanh`
"""
cfrac(::typeof(exp), x::T) where T = ContinuedFraction(one(T), Vcat(2*x, Fill(x^2, ∞)), Vcat(2-x, T(6):T(4):∞))
cfrac(::typeof(atanh), x::T) where T = ContinuedFraction(zero(T), Vcat(x, -(x:x:x*∞).^2), one(T):T(2):∞)
# cfrac(::typeof(sec), x::T) where T = 
function cfrac(::typeof(csc), x::T) where T 
    a = (T(2):T(2):∞) .* (T(3):T(2):∞)
    b = Fill(x^2, ∞)
    ContinuedFraction(1//x, Vcat(x, a.*b), a-b)
end
cfrac(::typeof(tan), x::T) where T = ContinuedFraction(zero(x), Vcat(x, Fill(-x^2, ∞)), one(T):T(2):∞)
cfrac(::typeof(sin), x) = Vcat(x, inv.(cfrac(csc, x)))
cfrac(::typeof(log), x) = 2 * cfrac(atanh, (x-1) // (x+1))

end # module