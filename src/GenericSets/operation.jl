# intersect & union
intersect(S1::HalfLine{LR}, S2::HalfLine{LR}) where LR = _subsetintersect(S1, S2)
union(S1::HalfLine{LR}, S2::HalfLine{LR}) where LR = _subsetunion(S1, S2)
function intersect(S1::HalfLine{:L}, S2::HalfLine{:R})
    if S1.a < S2.a
        LazyIntersection(S1,S2)
    elseif S1.a > S2.a
        ∅
    elseif _cmp(S1) == (≥) && _cmp(S2) == (≤)
        Set(S1.a)
    else
        ∅
    end
end
function union(S1::HalfLine{:L}, S2::HalfLine{:R})
    if S1.a < S2.a
        ℝ
    elseif S1.a > S2.a
        LazyUnion(S2,S1)
    elseif _cmp(S1) == (≥) && _cmp(S2) == (≤)
        ℝ
    else
        LazyUnion(S2,S1)
    end
end
intersect(S1::HalfLine{:R}, S2::HalfLine{:L}) = S2 ∩ S1
union(S1::HalfLine{:R}, S2::HalfLine{:L}) = S2 ∪ S1

intersect(S1::LazyIntersection{T}, S2::LazyIntersection{S}) where {T,S} = LazyIntersection{promote_type(T,S)}(S1.sets...,S2.sets...)
union(S1::LazyUnion{T}, S2::LazyUnion{S}) where {T,S} = LazyUnion{promote_type(T,S)}(S1.sets...,S2.sets...)

# setdiff
setdiff(S::AbstractSet, ::EmptySet) = S
setdiff(::EmptySet, ::AbstractSet) = ∅
setdiff(::EmptySet, ::EmptySet) = ∅
setdiff(::UniversalSet{Real}, S::HalfLine) = HalfLine(_notop(_cmp(S)), S.a)
setdiff(S1::HalfLine, S2::HalfLine) = S1 ∩ setdiff(ℝ, S2)