module Infs

import Base: +, -, ==
import Base: promote_rule, convert, iszero, isinf, isfinite, isnan, zero, one, oneunit, show, string


# Definitions
abstract type AbstractInf{T<:Number} end
abstract type AbstractNaN{T<:Number} end
const ExtendedNumber{T<:Number} = Union{T, AbstractInf{T}, AbstractNaN{T}}

struct Infinity{T<:Number} <: AbstractInf{T} end
struct NotANumber{T<:Number} <: AbstractNaN{T} end
struct PosInf{T<:Real} <: AbstractInf{T} end
struct NegInf{T<:Real} <: AbstractInf{T} end
struct ComplexInf{T<:Complex} <: AbstractInf{T}
    z::T
end


# Construct from type
for Typ in (:Infinity, :PosInf, :NegInf, :NotANumber)
    @eval $Typ(T::Type) = $Typ{T}()
    @eval $Typ() = $Typ(Bool)
end


# IO
const ∞ = Infinity(Bool)
show(io::IO, x::ExtendedNumber) = print(io, string(x))
string(::Infinity{T}) where T = "∞{$T}"
string(::PosInf{T}) where T = "+∞{$T}"
string(::NegInf{T}) where T = "-∞{$T}"
string(z::ComplexInf) = "∞($(z.z))"
string(::NotANumber{T}) where T = "NaN{$T}"


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


# Promotion and conversion
promote_rule(::Type{<:AbstractInf{T}}, ::Type{<:AbstractInf{S}}) where {T, S} = ExtendedNumber{promote_type(T, S)}
promote_rule(::Type{<:AbstractInf{T}}, ::Type{S}) where {T, S<:Number} = ExtendedNumber{promote_type(T, S)}
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
for Typ in (Infinity, PosInf, NegInf)
    @eval AbstractInf{T}(::$Typ) where T<:Number = $Typ(T)
    @eval (::Type{T})(::$Typ) where T<:Number = $Typ(T)
end

# Algebra
+(::Infinity{T}) where T = PosInf(T)
-(::Infinity{T}) where T = NegInf(T)

+(::PosInf{T}) where T = PosInf(T)
+(::NegInf{T}) where T = NegInf(T)

-(::PosInf{T}) where T = NegInf(T)
-(::NegInf{T}) where T = PosInf(T)

+(x::ExtendedNumber{T}, y::ExtendedNumber{T}) where T<:Number = (+x) + (+y)
-(x::ExtendedNumber{T}, y::ExtendedNumber{T}) where T<:Number = (+x) + (-y)

+(x::ExtendedNumber{T}, y::ExtendedNumber{S}) where {T<:Number,S<:Number} = +(promote(x,y)...)
-(x::ExtendedNumber{T}, y::ExtendedNumber{S}) where {T<:Number,S<:Number} = -(promote(x,y)...)

+(::PosInf{T}, ::NegInf{T}) where T = NotANumber(T)
+(::PosInf{T}, ::PosInf{T}) where T = PosInf(T)
+(::NegInf{T}, ::PosInf{T}) where T = NotANumber(T)
+(::NegInf{T}, ::NegInf{T}) where T = NegInf(T)

+(::PosInf{T}, ::T) where T<:Number = PosInf(T)
+(::T, ::PosInf{T}) where T<:Number = PosInf(T)
+(::NegInf{T}, ::T) where T<:Number = NegInf(T)
+(::T, ::NegInf{T}) where T<:Number = NegInf(T)

end # module