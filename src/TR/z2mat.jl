import Base: size, DimsInteger, zero, fill!, *, getindex, +, promote_shape
import LinearAlgebra: dot

"""
    nthbit(x::Integer, n::Integer)

Get the `n`-th last bit of `x`.

# Example
```jldoctest
julia> [TR.nthbit(0b10110, n) for n in 1:5]
5-element Vector{Bool}:
 0
 1
 1
 0
 1
```
"""
nthbit(x::Integer, n::Integer) = isodd(x >> (n-1))

mutable struct Z2Matrix{T<:Integer, V<:AbstractVector{T}, S<:DimsInteger{2}} <: AbstractMatrix{Bool}
    data::V
    size::S
end
size(M::Z2Matrix) = M.size
getindex(M::Z2Matrix, i, j) = nthbit(M.data[i], j)
zero(M::Z2Matrix) = Z2Matrix(zero(M.data), size(M))

mutable struct Z2Vector{T<:Integer, S<:Integer} <: AbstractVector{Bool}
    data::T
    size::S
end
size(v::Z2Vector) = (v.size, )
getindex(v::Z2Vector, i) = nthbit(v.data, i)
zero(v::Z2Vector) = Z2Vector(zero(v.data), size(v))

function fill!(v::Z2Vector{T}, x::Bool) where T
    v.data = ifelse(x, typemax(T), zero(T))
    v
end



# algebra

function lmul!(x::Bool, v::Z2Vector{T}) where T
    if !x
        v.data = zero(T)
    end
end
function rmul!(v::Z2Vector{T}, x::Bool) where T
    if !x
        v.data = zero(T)
    end
end

function +(u::Z2Vector, v::Z2Vector)
    promote_shape(u, v)
    Z2Vector(u.data ⊻ v.data, u.size)
end
function +(u::Z2Matrix, v::Z2Matrix)
    promote_shape(u, v)
    Z2Matrix(u.data .⊻ v.data, u.size)
end

dot(u::Z2Vector, v::Z2Vector) = fuse(u.data, v.data)

function *(A::Z2Matrix, v::Z2Vector{T}) where T
    ret = zero(T)
    for u in A.data
        ret <= 1
        ret += fuse(u, v.data)
    end
    Z2Vector(ret, v.size)
end