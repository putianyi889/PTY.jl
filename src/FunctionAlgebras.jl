module FunctionAlgebras

import Base: ^, ∘, tuple, +, *, -, /, Fix1, Fix2

struct PowerOfFunction{F} <: Function
    f::F
    p
end
function ^(f::Function, p)
    if iszero(p)
        identity
    elseif isone(p)
        f
    else
        PowerOfFunction(f,p)
    end
end
^(f::PowerOfFunction, p) = f.f ^ (f.p * p)

function (f::PowerOfFunction)(x)
    ret = x
    for _ in 1:f.p
        ret = f(ret...)
    end
    ret
end

struct ConstFunction{T} <: Function
    c::T
end
(f::ConstFunction)(x...) = f.c

end # module