module Helper

import Base: //, (:)
import LazyArrays: BroadcastArray, converteltype

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

end # module