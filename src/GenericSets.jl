module GenericSets

import Base: in, intersect, issubset, show, union, Fix1, minimum, maximum, setdiff, length
using PTY.Infs: ∞
using LinearAlgebra: norm

export interior, closure

include("GenericSets/helper.jl")

struct EmptySet <: AbstractSet{Any} end
"""
    ∅

The empty set.
"""
const ∅ = EmptySet()
@subset_pair EmptySet AbstractSet

"""
    UniversalSet{T} <: AbstractSet{T}

The set containing all elements of type `T`. Some commonly used sets have shortcuts:

- `ℝ = UniversalSet{Real}()`
- `ℂ = UniversalSet{Complex}()`
- `ℤ = UniversalSet{Integer}()`
- `ℚ = UniversalSet{Rational{Integer}}()`
"""
struct UniversalSet{T} <: AbstractSet{T} end
const ℝ = UniversalSet{Real}()
const ℂ = UniversalSet{Complex}()
const ℤ = UniversalSet{Integer}()
const ℚ = UniversalSet{Rational{Integer}}()
@subset_pair_with_T AbstractSet UniversalSet

const AbsFiniteDimVecSet{N,T} = AbstractSet{NTuple{N,T}}

abstract type AbstractBall{N,OC,T} <: AbsFiniteDimVecSet{N,T} end

struct Ball{N,OC,T} <: AbstractBall{N,OC,T}
    c::NTuple{N,T}
    r::NTuple{N,T}
end

"""
    HalfLine{LR,OC,T}(a) <: AbstractSet{Real}
    HalfLine(op, a)

Half-infinite interval. `LR ∈ (:L,:R)` (referring to left and right) and `OC ∈ (:O,:C)` (referring to open and closed) denote the type of the endpoint and `a` is the endpoint. `HalfLine(op, a)` is a more comprehensive way of construction, where `op ∈ (<, >, ≤, ≥)` and `HalfLine(op, a) = {x|op(x,a)}`.

# Example

```jldoctest
julia> HalfLine{:R,:O}(2)
{x|x<2}

julia> HalfLine(≥,1)
{x|x>=1}
```
"""
struct HalfLine{LR,OC,T} <: AbstractSet{Real}
    a::T
end
HalfLine{LR,OC}(a::T) where {LR,OC,T<:Real} = HalfLine{LR,OC,T}(a)
HalfLine(s::Union{typeof(>),typeof(<),typeof(≥),typeof(≤)}, a) = _invcmp(s)(a)

function simplify(S::HalfLine{:L})
    if isnan(S.a)
        throw(DomainError(S.a))
    elseif isinf(S.a)
        ifelse(0 ∈ S, ℝ, ∅)
    else
        S
    end
end

_cmp(::HalfLine{:L,:O}) = >
_cmp(::HalfLine{:R,:O}) = <
_cmp(::HalfLine{:L,:C}) = ≥
_cmp(::HalfLine{:R,:C}) = ≤
_invcmp(::typeof(>)) = HalfLine{:L,:O}
_invcmp(::typeof(<)) = HalfLine{:R,:O}
_invcmp(::typeof(≥)) = HalfLine{:L,:C}
_invcmp(::typeof(≤)) = HalfLine{:R,:C}

struct ReduceSets{T,F,S} <: AbstractSet{T}
    sets::S
end
ReduceSets{T,F}(S::Tuple) where {T,F} = ReduceSets{T,F,typeof(S)}(S)
ReduceSets{T,F}(S::AbstractSet...) where {T,F} = ReduceSets{T,F}(S)

const LazyIntersection{T,S} = ReduceSets{T,typeof(∩),S}
const LazyUnion{T,S} = ReduceSets{T,typeof(∪),S}
const Interval{OC1,OC2,T1,T2} = LazyIntersection{Real,Tuple{HalfLine{:L,OC1,T1}, HalfLine{:R,OC2,T2}}}
LazyIntersection(S::AbstractSet...) = LazyIntersection{promote_type(map(eltype,S)...)}(S)
LazyUnion(S::AbstractSet...) = LazyUnion{promote_type(map(eltype,S)...)}(S)
Interval{OC1,OC2}(a, b) where {OC1,OC2} = HalfLine{:L,OC1}(a) ∩ HalfLine{:R,OC2}(b)

@subset_pair EmptySet LazyIntersection

struct CartesianProduct{T,S} <: AbstractSet{T}
    sets::S
end

include("GenericSets/interface.jl")
include("GenericSets/operation.jl")
include("GenericSets/io.jl")

end # module