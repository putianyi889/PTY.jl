import Base: size, zero, fill!, getindex, promote_shape, setindex!, copy, transpose, adjoint, similar, one
import Base: *, +, &, |, ⊻, ⊼, ⊽, ~, \
import Base: UndefInitializer, Dims
import LinearAlgebra: dot, AdjOrTrans, mul!, rank, det, checksquare, ldiv!, SingularException

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

type2bit(::Type{T}) where T<:Integer = sizeof(T) << 3

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
    ret
end

function matrank!(x::AbstractVector{T}) where T<:Integer
    r = 0
    for i in lastindex(x):-1:1
        k = trailing_zeros(x[i])
        if k < type2bit(T)
            r += true
            for j in i-1:-1:1
                if isodd(x[j] >> k)
                    x[j] ⊻= x[i]
                end
            end
        end
    end
    r
end

function matdet!(x::AbstractVector{T}) where T<:Integer
    for i in lastindex(x):-1:1
        k = trailing_zeros(x[i])
        if k == type2bit(T)
            return false
        end
        for j in i-1:-1:1
            if isodd(x[j] >> k)
                x[j] ⊻= x[i]
            end
        end
    end
    return true
end

function rowmatldivrowmat!(z::AbstractVector{U}, x::AbstractVector{T}, y::AbstractVector{U}) where {T,U}
    p = zeros(T, length(x))
    for i in eachindex(x)
        if iszero(x[i])
            throw(SingularException(i))
        end
        k = trailing_zeros(x[i])
        for j in 1:i-1
            if isodd(x[j] >> k)
                x[j] ⊻= x[i]
                y[j] ⊻= y[i]
            end
        end
        for j in i+1:lastindex(x)
            if isodd(x[j] >> k)
                x[j] ⊻= x[i]
                y[j] ⊻= y[i]
            end
        end
        p[k+1] = i
    end
    for i in eachindex(p)
        z[i] = y[p[i]]
    end
end

"""
    z2number(::Number)
    z2number(::AbstractMatrix{<:Number})

Convert `Number` to `Bool` in the ``\\mathbb{Z}_2`` sense.

# Examples

```jldoctest
julia> TR.z2number(25)
true

julia> TR.z2number(1:5)
5-element BitVector:
 1
 0
 1
 0
 1
```
"""
z2number(x::Bool) = x
z2number(x::Integer) = isodd(x)
z2number(x::Number) = z2number(Integer(x))
z2number(x::AbstractArray{Bool}) = x
z2number(x::AbstractArray{<:Number}) = z2number.(x)

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
Z2RowMat{C,R}(::UndefInitializer, m::Integer, n::Integer) where {C,R} = Z2RowMat{C,R}(zeros(R, m), n)
Z2ColMat{C,R}(::UndefInitializer, m::Integer, n::Integer) where {C,R} = Z2ColMat{C,R}(zeros(C, n), m)
function Z2RowMat(A::AbstractMatrix)
    m, n = size(A)
    ret = Z2RowMat(undef, m, n)
    ret .= z2number(A)
end
function Z2ColMat(A::AbstractMatrix)
    m, n = size(A)
    ret = Z2ColMat(undef, m, n)
    ret .= z2number(A)
end
for Typ in (:Z2RowMat, :Z2ColMat)
    @eval $Typ(::UndefInitializer, m::Integer, n::Integer) = $Typ{bit2type(m), bit2type(n)}(undef, m, n)
end

size(A::Z2RowMat) = (length(A.data), A.size)
size(A::Z2ColMat) = (A.size, length(A.data))

getindex(A::Z2RowMat, i::Integer, j::Integer) = nthbit(A.data[i], j)
getindex(A::Z2ColMat, i::Integer, j::Integer) = nthbit(A.data[j], i)

function setindex!(A::Z2RowMat, x::Number, i::Integer, j::Integer)
    A.data[i] = setnthbit(A.data[i], z2number(x), j)
end
function setindex!(A::Z2ColMat, x::Number, i::Integer, j::Integer)
    A.data[j] = setnthbit(A.data[j], z2number(x), i)
end

for Typ in (Z2RowMat, Z2ColMat)
    for op in (:zero, :copy, :~)
        @eval $op(A::$Typ{C,R}) where {C,R} = $Typ{C,R}($op(A.data), A.size)
    end
    for op in (:&, :|, :⊻, :⊽, :⊼)
        @eval function $op(A::$Typ{C,R}, B::$Typ{C,R}) where {C,R}
            promote_shape(A, B)
            $Typ{C,R}($op.(A.data, B.data), A.size)
        end
    end
    @eval begin
        similar(A::$Typ) = zero(A)
        similar(A::$Typ, dims::Dims{2}) = $Typ(undef, dims...)
        similar(A::$Typ, ::Type{Bool}, dims::Dims{2}) = similar(A, dims)

        function lmul!(x::Number, A::$Typ)
            if !z2number(x)
                fill!(A, false)
            end
        end
        function rmul!(A::$Typ, x::Number)
            if !z2number(x)
                fill!(A, false)
            end
        end

        function one(A::$Typ{C,R}) where {C,R}
            m = checksquare(A)
            $Typ{C,R}(one(C) .<< (0:m-1), m)
        end

        rank(A::$Typ) = matrank!(copy(A.data))
        det(A::$Typ) = matdet!(copy(A.data))
    end
end

function fill!(A::Z2RowMat{C,R}, x::Number) where {C,R}
    fill!(A.data, ifelse(z2number(x), typemax(R), zero(R)))
    A
end
function fill!(A::Z2ColMat{C,R}, x::Number) where {C,R}
    fill!(A.data, ifelse(z2number(x), typemax(C), zero(C)))
    A
end

for op in (:transpose, :adjoint)
    @eval $op(A::Z2RowMat{C,R}) where {C,R} = Z2ColMat{R,C}(A.data, A.size)
    @eval $op(A::Z2ColMat{C,R}) where {C,R} = Z2RowMat{R,C}(A.data, A.size)
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
getindex(v::Z2Vector, i::Integer) = nthbit(v.data, i)
function setindex!(v::Z2Vector, x::Number, i::Integer)
    v.data = setnthbit(v.data, z2number(x), i)
    v
end

zero(v::Z2Vector{T}) where T = Z2Vector{T}(zero(T), v.size)
copy(v::Z2Vector{T}) where T = Z2Vector{T}(v.data, v.size)
similar(v::Z2Vector) = copy(v)

function fill!(v::Z2Vector{T}, x::Number) where T
    v.data = ifelse(z2number(x), typemax(T), zero(T))
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

for Typ in (Z2RowMat, Z2ColMat)
    @eval begin
        function *(A::$Typ{C1,R1}, B::$Typ{C2,R2}) where {C1,R1,C2,R2}
            C = $Typ{C1,R2}(undef, size(A, 1), size(B, 2))
            mul!(C, A, B)
        end
    end
end

@inline function check_mul_mismatch(A, B)
    if size(A, 2) != size(B, 1)
        throw(DimensionMismatch("A has dimensions $(size(A)) but B has dimensions $(size(B))"))
    end
end

@inline function check_div_mismatch(A, B)
    if size(A, 1) != size(B, 1)
        throw(DimensionMismatch("A has dimensions $(size(A)) but B has dimensions $(size(B))"))
    end
end

function mul!(C::Z2RowMat{C1,R2}, A::Z2RowMat{C1,R1}, B::Z2RowMat{C2,R2}) where {C1,R1,C2,R2}
    check_mul_mismatch(A, B)
    for j in eachindex(C.data)
        C.data[j] = colmatmulvec(B.data, A.data[j])
    end
    C
end
function mul!(C::Z2ColMat{C1,R2}, A::Z2ColMat{C1,R1}, B::Z2ColMat{C2,R2}) where {C1,R1,C2,R2}
    check_mul_mismatch(A, B)
    for j in eachindex(C.data)
        C.data[j] = colmatmulvec(A.data, B.data[j])
    end
    C
end
function mul!(C::Z2RowMat{C1,R2}, A::Z2RowMat{C1,R1}, B::Z2ColMat{C2,R2}) where {C1,R1,C2,R2} # TODO
    check_mul_mismatch(A, B)
end

function ldiv!(C::Z2RowMat{C1,R2}, A::Z2RowMat{C1,R1}, B::Z2RowMat{C1,R2}) where {C1,R1,R2}
    rowmatldivrowmat!(C.data, copy(A.data), copy(B.data))
    C
end

function \(A::Z2RowMat{C1,R1}, B::Z2RowMat{C1,R2}) where {C1,R1,R2}
    check_div_mismatch(A, B)
    C = similar(B)
    ldiv!(C, A, B)
end