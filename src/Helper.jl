module Helper

import Base: //, (:), eps, ceil, floor
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

The inverse of [`promote_type`](@ref)
"""
demote_type(a) = a
demote_type(a,b) = ifelse(promote_type(a,b)==a, b,a)
demote_type(a,b...) = demote_type(a, demote_type(b...))

"""
    _invop(op)

Return `invop` such that `invop(a,b) = op(b,a)`.
"""
_invop(::typeof(>)) = <
_invop(::typeof(<)) = >
_invop(::typeof(≥)) = ≤
_invop(::typeof(≤)) = ≥
_invop(::typeof(==)) = ==
_invop(::typeof(!=)) = !=

end # module