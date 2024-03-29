import Base: one, isone, inv, ∘, promote_rule, show, getproperty, ==
using PTY.Helper: str_coef, str_add

"""
    AbstractLinearFractionalMap <: Function

The abstract type for linear fractional maps.
"""
abstract type AbstractLinearFractionalMap{T} <: Function end

"""
    LinearFractionalMap(a, b, c, d)

The function ``x\\to \\frac{ax+b}{cx+d}``

# Example
```jldoctest
julia> PTY.SpecFun.LinearFractionalMap(1, 2, 3, 4)
x → (1.0x + 2.0) / (3.0x + 4.0)
```
"""
struct LinearFractionalMap{T} <: AbstractLinearFractionalMap{T}
    a::T
    b::T
    c::T
    d::T

    function LinearFractionalMap{T}(a::T, b::T, c::T, d::T) where T
        a*d == b*c && throw(ArgumentError("LinearFractionalMap($a, $b, $c, $d) is not a linear fractional map"))
        new(a, b, c, d)
    end
end
LinearFractionalMap(a::T,b::T,c::T,d::T) where T = LinearFractionalMap{float(T)}(float(a),float(b),float(c),float(d))
LinearFractionalMap(a,b,c,d) = LinearFractionalMap(promote(a,b,c,d)...)

"""
    LinearFractionalMap(z1=>w1, z2=>w2, z3=>w3)

A linear fractional map that maps `(z1,z2,z3)` to `(w1,w2,w3)`.

# Example
```jldoctest
julia> PTY.SpecFun.LinearFractionalMap(0=>-im, 1=>1, Inf=>im)
x → ((1.0 - 1.0im)x - 1.0 - 1.0im) / ((-1.0 - 1.0im)x + 1.0 - 1.0im)

julia> PTY.SpecFun.LinearFractionalMap(0=>Inf, Inf=>0, 1=>1)
x → (0.0x - 1.0) / (-1.0x + 0.0)
```
"""
LinearFractionalMap(p1::Pair, p2::Pair, p3::Pair) = inv(normal_lf_map(p1.second,p2.second,p3.second)) ∘ normal_lf_map(p1.first,p2.first,p3.first)
LinearFractionalMap(M::AbstractLinearFractionalMap) = LinearFractionalMap(M.a, M.b, M.c, M.d)
function normal_lf_map(z1,z2,z3)
    z1,z2,z3 = promote(z1,z2,z3)
    if z1==z2 || z1==z3 || z2==z3
        throw(ArgumentError("can't map ($z1, $z2, $z3) to (0, 1, ∞)"))
    end
    if isinf(z3)
        LinearFractionalMap(-1, z1, 0, z1-z2)
    elseif isinf(z2)
        LinearFractionalMap(1, -z1, 1, -z3)
    elseif isinf(z1)
        LinearFractionalMap(0, z3-z2, -1, z3)
    else
        LinearFractionalMap(z2-z3, z1*(z3-z2), z2-z1, z3*(z1-z2))
    end
end

"""
    AffineMap(a, b)
    AffineMap(z1=>w1, z2=>w2)

The function ``x\\to ax+b``. See also [`LinearFractionalMap`](@ref)

# Examples
```jldoctest
julia> PTY.SpecFun.AffineMap(1, 2)
x → 1.0x + 2.0

julia> PTY.SpecFun.AffineMap(0=>1, 1=>0)
x → -1.0x + 1.0
```
"""
struct AffineMap{T} <: AbstractLinearFractionalMap{T}
    a::T
    b::T

    function AffineMap{T}(a::T, b::T) where T
        iszero(a) && throw(ArgumentError("AffineMap($a, $b) is not an affine map"))
        new(a, b)
    end
end
@inline function getproperty(A::AffineMap{T}, p::Symbol) where T
    if p == :c
        zero(T)
    elseif p == :d
        one(T)
    else
        getfield(A, p)
    end
end
AffineMap(a::T,b::T) where T = AffineMap{float(T)}(float(a),float(b))
AffineMap(a,b) = AffineMap(promote(a,b)...)
AffineMap(p1::Pair, p2::Pair) = AffineMap((p2.second-p1.second) / (p2.first-p1.first), (p2.first*p1.second - p1.first*p2.second) / (p2.first-p1.first))
function AffineMap(M::AbstractLinearFractionalMap)
    if iszero(M.c)
        AffineMap(M.a/M.d, M.b/M.d)
    else
        throw(InexactError(:AffineMap, AffineMap, M))
    end
end

inv(M::AbstractLinearFractionalMap) = LinearFractionalMap(-M.d, M.b, M.c, -M.a)
inv(M::AffineMap) = AffineMap(inv(M.a), -M.b/M.a)

isone(M::AbstractLinearFractionalMap) = M.a==M.d && iszero(M.b) && iszero(M.c)
isone(M::AffineMap) = isone(M.a) && iszero(M.b)

one(::AbstractLinearFractionalMap{T}) where T = LinearFractionalMap{T}(one(T),zero(T),zero(T),one(T))
one(::AffineMap{T}) where T = AffineMap{T}(one(T),zero(T))

function (M::AbstractLinearFractionalMap)(x::Number)
    if isinf(x)
        M.a / M.c
    else
        (M.a*x + M.b) / (M.c*x + M.d)
    end
end
(M::AffineMap)(x::Number) = M.a*x + M.b

∘(M::AbstractLinearFractionalMap, N::AbstractLinearFractionalMap) = LinearFractionalMap(M.a*N.a+M.b*N.c, M.a*N.b+M.b*N.d, M.c*N.a+M.d*N.c, M.c*N.b+M.d*N.d)
∘(M::AffineMap, N::AffineMap) = AffineMap(M.a*N.a, M.a*N.b + M.b)

function ==(M::AbstractLinearFractionalMap, N::AbstractLinearFractionalMap)
    if iszero(M.c)
        M.a/M.d == N.a/N.d && M.b/M.d == N.b/N.d && iszero(N.c)
    else
        M.a/M.c == N.a/N.c && M.b/M.c == N.b/N.c && M.d/M.c == N.d/N.c
    end
end

show(io::IO, ::MIME"text/plain", M::LinearFractionalMap) = print(io, "x → ", str_coef(str_coef(M.a)*"x "*str_add(M.b)), " / ", str_coef(str_coef(M.c)*"x "*str_add(M.d)))
show(io::IO, ::MIME"text/plain", M::AffineMap) = print(io, "x → ", str_coef(M.a), "x ", str_add(M.b))