module Helper

import Base: //, (:), eps, ceil, floor, front, tail
import LazyArrays: BroadcastArray, converteltype

export demote_type

//(x::AbstractFloat, y) = x / y
//(x, y::AbstractFloat) = x / y
//(x::AbstractFloat, y::AbstractFloat) = x / y

(:)(start, step, stop) = (:)(promote(start, step, stop)...)
function (:)(start::Complex, step::Complex, stop::Complex) 
    if iszero(real(step))
        im * (imag(start):imag(step):imag(stop))
    elseif iszero(imag(step))
        real(start):real(step):real(stop)
    else
        (real(start):real(step):real(stop)) + im * (imag(start):imag(step):imag(stop))
    end
end

AbstractArray{T, N}(A::BroadcastArray{S, N}) where {T, N, S} = BroadcastArray{T,N}(A.f, A.args...)

eps(::Type{Complex{T}}) where T = eps(T)
ceil(z::Complex) = ceil(real(z)) + ceil(imag(z))im
floor(z::Complex) = floor(real(z)) + floor(imag(z))im

"""
    demote_type

The inverse of [`promote_type`](https://docs.julialang.org/en/v1/base/base/#Base.promote_type)

# Example

```jldoctest
julia> Helper.demote_type(Float64, Int)
Int64
```
"""
demote_type(a) = a
demote_type(a,b) = ifelse(promote_type(a,b)==a, b,a)
demote_type(a,b...) = demote_type(a, demote_type(b...))

"""
    _invop(op)

Return `invop` such that `invop(a,b) = op(b,a)`.

# Example

```jldoctest
julia> Helper._invop(<)
> (generic function with 3 methods)
```
"""
_invop(::typeof(>)) = <
_invop(::typeof(<)) = >
_invop(::typeof(≥)) = ≤
_invop(::typeof(≤)) = ≥
_invop(::typeof(==)) = ==
_invop(::typeof(!=)) = !=

_notop(::typeof(>)) = ≤
_notop(::typeof(<)) = ≥
_notop(::typeof(≥)) = <
_notop(::typeof(≤)) = >
_notop(::typeof(==)) = !=
_notop(::typeof(!=)) = ==

front(A::AbstractVector) = A[1:end-1]
tail(A::AbstractVector) = A[2:end]

end # module