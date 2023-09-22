# length
length(::EmptySet) = 0
length(::HalfLine) = +∞
length(::Interval) = +∞

# infimum & supremum
infimum(S::AbstractSet) = isfinite(length(S)) ? minimum(S) : throw(MethodError(infimum, S))
supremum(S::AbstractSet) = isfinite(length(S)) ? maximum(S) : throw(MethodError(supremum, S))

infimum(S::HalfLine{:L}) = S.a
infimum(::HalfLine{:R}) = -∞
supremum(S::HalfLine{:R}) = S.a
supremum(::HalfLine{:L}) = +∞

infimum(S::LazyIntersection) = maximum(map(infimum, S.sets))
supremum(S::LazyIntersection) = minimum(map(supremum, S.sets))

# minimum & maximum
@abstract_minmax HalfLine
@abstract_minmax ReduceSets

# interior, closure, boundary
interior(S::AbstractSet) = isfinite(length(S)) ? ∅ : throw(MethodError(interior, S))
closure(S::AbstractSet) = isfinite(length(S)) ? S : throw(MethodError(closure, S))
boundary(S::AbstractSet) = setdiff(closure(S), interior(S))

interior(B::Ball{N,OC,T}) where {N,OC,T} = Ball{N,:O,T}(B.c,B.r)
closure(B::Ball{N,OC,T}) where {N,OC,T} = Ball{N,:C,T}(B.c,B.r)

interior(S::HalfLine{LR,OC}) where {LR,OC} = HalfLine{LR,:O}(S.a)
closure(S::HalfLine{LR,OC}) where {LR,OC} = HalfLine{LR,:C}(S.a)

interior(S::Interval) = interior(S.sets[1]) ∩ interior(S.sets[2])
closure(S::Interval) = closure(S.sets[1]) ∩ closure(S.sets[2])

# in
in(x, ::EmptySet) = false
in(x::T, ::UniversalSet{T}) where T = true

in(x, B::Ball{N,:O}) where N = norm(x-B.c,2) < B.r
in(x, B::Ball{N,:C}) where N = norm(x-B.c,2) ≤ B.r

in(x, S::HalfLine) = _cmp(S)(x, S.a)

in(x, S::LazyIntersection) = all(Fix1(in,x), S.sets)
in(x, S::LazyUnion) = any(Fix1(in,x), S.sets)

in(x, P::CartesianProduct) = all(map(in, x, P.sets))

# issubset
issubset(S1::HalfLine{LR,:O}, S2::HalfLine{LR,OC}) where {LR,OC} = in(S1.a, closure(S2))
issubset(S1::HalfLine{LR,:C}, S2::HalfLine{LR,OC}) where {LR,OC} = in(S1.a, S2)
issubset(S1::AbstractSet{<:Real}, S2::HalfLine{:L,:C}) = infimum(S1) ∈ S2
issubset(S1::AbstractSet{<:Real}, S2::HalfLine{:R,:C}) = supremum(S1) ∈ S2
issubset(S1::AbstractSet{<:Real}, S2::HalfLine{LR,:O}) where LR = S1 ⊆ closure(S2) && S2.a ∉ S1

issubset(x, S::LazyIntersection) = all(Fix1(issubset,x), S.sets)