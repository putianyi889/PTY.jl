import Base: size, zero, fill!, *, getindex, +, promote_shape, setindex!, copy, UndefInitializer
import LinearAlgebra: dot, AdjOrTrans

"""
    bit2type(n::Integer) :: DataType

Returns minimal integer type that contains `n` bits

# Examples
```jldoctest
julia> TR.bit2type(5)
UInt8

julia> TR.bit2type(9)
UInt16

julia> TR.bit2type(32)
UInt32

julia> TR.bit2type(33)
UInt64

julia> TR.bit2type(100)
BigInt
```
"""
function bit2type(n::Integer)
    if n <= 8
        UInt8
    elseif n <= 16
        UInt16
    elseif n <= 32
        UInt32
    elseif n <= 64
        UInt64
    elseif isinf(n)
        throw(ArgumentError("doesn't support infinite bits"))
    else
        BigInt
    end
end

"""
    nthbit(x::Integer, n::Integer)

Get the `n`-th last bit of `x`. See also [`setnthbit`](@ref)

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

"""
    setnthbit(x::Integer, y::Bool, n::Integer)

Set the `n`-th last bit of `x` to `y`. See also [`nthbit`](@ref).

# Example
```jldoctest
julia> string(TR.setnthbit(0b10110, true, 1), base = 2)
"10111"

julia> string(TR.setnthbit(0b10110, false, 1), base = 2)
"10110"
```
"""
setnthbit(x::Integer, y::Bool, n::Integer) = ifelse(y, x | 1<<(n-1), x & ~(1<<(n-1)))

function rowmatmulvec(x::AbstractVector{<:Integer}, y::Integer)
    ret = zero(y)
    for u in x
        ret <<= 1
        ret += fuse(u, y)
    end
    ret
end

function colmatmulvec(x::AbstractVector{<:Integer}, y::Integer)
    ret = zero(y)
    for u in x
        ret = ifelse(isodd(y), ret ⊻ u, ret)
        y >>= 1
    end
end

"""
    Z2RowMat{C<:Integer, R<:Integer}(data::Vector{R}, size::Int)
    Z2RowMat(undef, m, n)
    Z2RowMat(::AbstractMatrix)

Z2 matrix stored in a `Vector` where each entry represents a row. `size` specifies the width. `C` and `R` are used for dispatch; they specify the integer type used to represent a column vector and a row vector respectively. See also [`bit2type`](@ref), [`Z2ColMat`](@ref)

# Example
```jldoctest
julia> TR.Z2RowMat([1, 3, 5], 3)
3×3 PTY.TR.Z2RowMat{UInt8, UInt8}:
 1  0  0
 1  1  0
 1  0  1
```
"""
mutable struct Z2RowMat{C<:Integer, R<:Integer} <: AbstractMatrix{Bool}
    data::Vector{R}
    size::Int
end

"""
    Z2ColMat{C<:Integer, R<:Integer}(data::Vector{C}, size::Int)
    Z2ColMat(undef, m, n)
    Z2ColMat(::AbstractMatrix)

Z2 matrix stored in a `Vector` where each entry represents a column. `size` specifies the height. `C` and `R` are used for dispatch; they specify the integer type used to represent a column vector and a row vector respectively. See also [`bit2type`](@ref), [`Z2RowMat`](@ref)

# Example
```jldoctest
julia> TR.Z2ColMat([1, 3, 5], 3)
3×3 PTY.TR.Z2ColMat{UInt8, UInt8}:
 1  1  1
 0  1  0
 0  0  1
```
"""
mutable struct Z2ColMat{C<:Integer, R<:Integer} <: AbstractMatrix{Bool}
    data::Vector{C}
    size::Int
end
const Z2Mat{C,R} = Union{Z2RowMat{C,R}, Z2ColMat{C,R}}
Z2RowMat(data::AbstractVector{<:Integer}, cols::Integer) = Z2RowMat{bit2type(length(data)), bit2type(cols)}(data, cols)
Z2ColMat(data::AbstractVector{<:Integer}, rows::Integer) = Z2ColMat{bit2type(rows), bit2type(length(data))}(data, rows)
function Z2RowMat(::UndefInitializer, m::Integer, n::Integer)
    C = bit2type(m)
    R = bit2type(n)
    Z2RowMat{C,R}(Vector{R}(undef, m), n)
end
function Z2ColMat(::UndefInitializer, m::Integer, n::Integer)
    C = bit2type(m)
    R = bit2type(n)
    Z2RowMat{C,R}(Vector{C}(undef, n), m)
end
function Z2RowMat(A::AbstractMatrix{Bool})
    m, n = size(A)
    ret = Z2RowMat(undef, m, n)
    ret .= A
end
function Z2ColMat(A::AbstractMatrix{Bool})
    m, n = size(A)
    ret = Z2ColMat(undef, m, n)
    ret .= A
end
for Typ in (:Z2RowMat, :Z2ColMat)
    @eval $Typ(A::AbstractMatrix) = $Typ(Bool.(mod.(A,2)))
end

size(A::Z2RowMat) = (length(A.data), A.size)
size(A::Z2ColMat) = (A.size, length(A.data))

getindex(A::Z2RowMat, i, j) = nthbit(A.data[i], j)
getindex(A::Z2ColMat, i, j) = nthbit(A.data[j], i)

function setindex!(A::Z2RowMat, x::Bool, i, j)
    A.data[i] = setnthbit(A.data[i], x, j)
end
function setindex!(A::Z2ColMat, x::Bool, i, j)
    A.data[j] = setnthbit(A.data[j], x, i)
end

for Typ in (Z2RowMat, Z2ColMat)
    for op in (:zero, :copy)
        @eval $op(A::$Typ{C,R}) where {C,R} = $Typ{C,R}($op(A.data), A.size)
    end
end
#similar(M::Z2RowMat; dims) = Z2Matrix(undef, dims)

function fill!(A::Z2RowMat{C,R}, x::Bool) where {C,R}
    fill!(A.data, ifelse(x, typemax(R), zero(R)))
    A
end
function fill!(A::Z2ColMat{C,R}, x::Bool) where {C,R}
    fill!(A.data, ifelse(x, typemax(C), zero(C)))
    A
end

"""
    Z2Vector{T<:Integer}(data::T, size::Int)
    Z2Vector(::AbstractVector)

Z2 vector stored in an integer `data` where each bit represents an entry. `size` specifies the length.

# Example

```jldoctest
julia> TR.Z2Vector(0b10110, 5)
5-element PTY.TR.Z2Vector{UInt8}:
 0
 1
 1
 0
 1
```
"""
mutable struct Z2Vector{T<:Integer} <: AbstractVector{Bool}
    data::T
    size::Int
end
Z2Vector(data::Integer, size::Integer) = Z2Vector{bit2type(size)}(data, size)
function Z2Vector(v::AbstractVector{Bool})
    T = bit2type(length(v))
    ret = 0
    for x in Iterators.reverse(v)
        ret <<= 1
        ret += x
    end
    Z2Vector{T}(ret, length(v))
end
Z2Vector(v::AbstractVector) = Z2Vector(Bool.(mod.(v,2)))

size(v::Z2Vector) = (v.size, )
getindex(v::Z2Vector, i) = nthbit(v.data, i)
function setindex!(v::Z2Vector, x::Bool, i)
    v.data = setnthbit(v.data, x, i)
    v
end

zero(v::Z2Vector{T}) where T = Z2Vector{T}(zero(T), v.size)
copy(v::Z2Vector{T}) where T = Z2Vector{T}(v.data, v.size)
similar(v::Z2Vector) = copy(v)

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

function +(u::Z2Vector{T}, v::Z2Vector{T}) where T
    promote_shape(u, v)
    Z2Vector(u.data ⊻ v.data, u.size)
end
function +(u::Z2RowMat{C,R}, v::Z2RowMat{C,R}) where {C,R}
    promote_shape(u, v)
    Z2RowMat{C,R}(u.data .⊻ v.data, u.size)
end
function +(u::Z2ColMat{C,R}, v::Z2ColMat{C,R}) where {C,R}
    promote_shape(u, v)
    Z2ColMat{C,R}(u.data .⊻ v.data, u.size)
end

function dot(u::Z2Vector, v::Z2Vector)
    if length(u) != length(v)
        throw(DimensionMismatch("first array has length $(length(u)) which does not match the length of the second, $(length(v))."))
    end
    fuse(u.data, v.data)
end

function *(A::Z2RowMat{C,R}, v::Z2Vector{T}) where {C,R,T}
    if size(A, 2) != length(v)
        throw(DimensionMismatch("second dimension of A, $nA, does not match length of v, $(length(v))"))
    end
    Z2Vector{C}(rowmatmulvec(A.data, v.data), size(A, 1))
end
function *(A::Z2ColMat{C,R}, v::Z2Vector{T}) where {C,R,T}
    if size(A, 2) != length(v)
        throw(DimensionMismatch("second dimension of A, $nA, does not match length of v, $(length(v))"))
    end
    Z2Vector{C}(colmatmulvec(A.data, v.data), size(A,1))
end