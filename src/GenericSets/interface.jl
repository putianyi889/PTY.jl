# length
length(::EmptySet) = 0
length(::HalfLine) = +∞
length(::Interval) = +∞
length(::UniversalSet{Real}) = +∞

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
minimum(::EmptySet) = throw(MethodError(minimum, ∅))
maximum(::EmptySet) = throw(MethodError(maximum, ∅))
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

interior(S::LazyIntersection) = intersect(map(interior, S.sets)...)
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
for (A,B) in ((EmptySet, AbstractSet),)
    @eval begin
        issubset(::$A, ::$B) = true
        union(::$A, S::$B) = S
        union(S::$B, ::$A) = S
        intersect(S::$A, ::$B) = S
        intersect(::$B, S::$A) = S
    end
end
for A in (EmptySet,)
    @eval begin
        Base.issubset(::$A, ::$A) = true
        Base.union(::$A, S::$A) = S
        Base.intersect(S::$A, ::$A) = S
    end
end
for (A,B) in ((AbstractSet, UniversalSet), (UniversalSet, UniversalSet))
    @eval begin
        issubset(::$A{<:T}, ::$B{T}) where T = true
        union(::$A{<:T}, S::$B{T}) where T = S
        union(S::$B{T}, ::$A{<:T}) where T = S
        intersect(S::$A{<:T}, ::$B{T}) where T = S
        intersect(::$B{T}, S::$A{<:T}) where T = S
    end
end
for A in (UniversalSet,)
    @eval begin
        issubset(::$A{T}, ::$A{T}) where T = true
        union(::$A{T}, S::$A{T}) where T = S
        intersect(S::$A{T}, ::$A{T}) where T = S
    end
end

issubset(S1::AbstractSet{<:Real}, S2::HalfLine{:L,:C}) = infimum(S1) ∈ S2
issubset(S1::AbstractSet{<:Real}, S2::HalfLine{:R,:C}) = supremum(S1) ∈ S2
issubset(S1::AbstractSet{<:Real}, S2::HalfLine{LR,:O}) where LR = S1 ⊆ closure(S2) && S2.a ∉ S1

issubset(x, S::LazyIntersection) = all(Fix1(issubset,x), S.sets)