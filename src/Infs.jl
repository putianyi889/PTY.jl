module Infs

import Base: +, -, ==, *, isless
import Base: promote_rule, convert, iszero, isinf, isfinite, isnan, zero, one, oneunit, show, string, to_index

import Infinities: ℵ₀


# Definitions
abstract type AbstractInf{T<:Number} end
abstract type AbstractNaN{T<:Number} end
const ExtendedNumber{T<:Number} = Union{T, AbstractInf{T}, AbstractNaN{T}}

struct NDiInf{T<:Number} <: AbstractInf{T} end
struct NotANumber{T<:Number} <: AbstractNaN{T} end
struct PosInf{T<:Real} <: AbstractInf{T} end
struct NegInf{T<:Real} <: AbstractInf{T} end
struct DiInf{T<:Real} <: AbstractInf{Complex{T}}
    z::Complex{T}
end

const ComplexInf{T<:Real} = NDiInf{Complex{T}}
const RealInf{T<:Real} = NDiInf{T}


# Construct from type
for Typ in (:UnsignedInf, :PosInf, :NegInf, :NotANumber, :NDiInf, :ComplexInf, :RealInf)
    @eval $Typ(T::Type) = $Typ{T}()
    @eval $Typ() = $Typ(Bool)
end


# IO
const ∞ = PosInf()
const ±∞ = UnsignedInf()
show(io::IO, x::ExtendedNumber) = print(io, string(x))
string(::RealInf{T}) where T<:Real = "±∞{$T}"
string(::PosInf{T}) where T = "∞{$T}"
string(::NegInf{T}) where T = "-∞{$T}"
string(::ComplexInf{T}) where T = "̃∞{$T}"
string(::NotANumber{T}) where T = "NaN{$T}"
string(x::DiInf) = "($(x.z))∞"


# Interface
iszero(::AbstractInf) = false
iszero(::AbstractNaN) = false
isfinite(::ExtendedNumber) = false
isinf(::AbstractInf) = true
isinf(::AbstractNaN) = false
isnan(::AbstractInf) = false
isnan(::AbstractNaN) = true

zero(::Type{ExtendedNumber{T}}) where T = zero(T)
one(::Type{ExtendedNumber{T}}) where T = one(T)
oneunit(::Type{ExtendedNumber{T}}) where T = oneunit(T)

to_index(::PosInf{<:Integer}) = ℵ₀

# Promotion and conversion
for Typ in (AbstractInf, AbstractNaN)
    @eval promote_rule(::Type{<:$Typ{T}}, ::Type{<:$Typ{S}}) where {T, S} = ExtendedNumber{promote_type(T, S)}
    @eval promote_rule(::Type{<:$Typ{T}}, ::Type{S}) where {T, S} = ExtendedNumber{promote_type(T, S)}
end
#promote_rule(::Type{Infinity{T}}, ::Type{S}) where {T, S} = ExtendedNumber{promote_type(T, S)}

convert(::Type{ExtendedNumber{T}}, x) where {T} = ExtendedNumber{T}(x)
convert(::Type{ExtendedNumber{T}}, x::ExtendedNumber{T}) where T = ExtendedNumber{T}(x)

function ExtendedNumber{T}(x::Number) where T
    if isnan(x)
        NotANumber(T)
    elseif isinf(x)
        ifelse(x>0, PosInf(T), NegInf(T))
    else
        T(x)
    end
end
ExtendedNumber{T}(x::AbstractInf{S}) where {T,S} = AbstractInf{T}(x)
ExtendedNumber{T}(x::AbstractNaN{S}) where {T,S} = AbstractNaN{T}(x)
AbstractNaN{T}(::NotANumber) where T = NotANumber(T)
for Typ in (NDiInf, PosInf, NegInf)
    @eval AbstractInf{T}(::$Typ) where T<:Number = $Typ(T)
    @eval (::Type{T})(::$Typ) where T<:Number = $Typ(T)
end

# Compare


# Algebra
-(::NDiInf{T}) where T = UnsignedInf(T)
-(::NotANumber{T}) where T = NotANumber(T)

+(::PosInf{T}) where T = PosInf(T)
+(::NegInf{T}) where T = NegInf(T)
-(::PosInf{T}) where T = NegInf(T)
-(::NegInf{T}) where T = PosInf(T)

+(::ExtendedNumber{T}, ::ExtendedNumber{T}) where T<:Number = NotANumber(T)
-(x::ExtendedNumber{T}, y::ExtendedNumber{T}) where T<:Number = x + (-y)

+(x::ExtendedNumber{T}, y::ExtendedNumber{S}) where {T<:Number,S<:Number} = +(promote(x,y)...)
-(x::ExtendedNumber{T}, y::ExtendedNumber{S}) where {T<:Number,S<:Number} = -(promote(x,y)...)

+(::PosInf{T}, ::NegInf{T}) where T = NotANumber(T)
+(::PosInf{T}, ::PosInf{T}) where T = PosInf(T)
+(::NegInf{T}, ::PosInf{T}) where T = NotANumber(T)
+(::NegInf{T}, ::NegInf{T}) where T = NegInf(T)

+(x::AbstractInf{T}, ::T) where T<:Number = x
+(::T, x::AbstractInf{T}) where T<:Number = x



# infinite arrays
abstract type AbstractInfArray{T, N} <: AbstractArray{T, N} end
struct InfStepRange{T} <: AbstractRange{T}
    start::T
    step::T
end
struct InfUnitRange{T} <: AbstractUnitRange{T}
    start::T
end

end # module