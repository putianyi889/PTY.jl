import Base: one, isone, inv, ∘, promote_rule

abstract type AbstractLinearFractionalMap{T} <: Function end

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
LinearFractionalMap(p1::Pair, p2::Pair, p3::Pair) = normal_lf_map(p1.second,p2.second,p3.second) \ normal_lf_map(p1.first,p2.first,p3.first)
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
∘(M::AffineMap, N::AffineMap) = Affinemap(M.a*N.a, M.a*N.b + M.b)