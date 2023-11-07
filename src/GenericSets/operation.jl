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

for A in (HalfLine, LazyIntersection)
    @eval begin
        function union(S1::Set, S2::$A)
            S3 = setdiff(S1, S2)
            if isempty(S3)
                S2
            else
                LazyUnion(S3, S2)
            end
        end
        union(S1::$A, S2::Set) = S2 ∪ S1
        function setdiff!(S1::Set, S2::$A)
            for s in S1
                if s ∈ S2
                    pop!(S1, s)
                end
            end
            S1
        end
    end
end

function union(S1::Set, S2::LazyUnion{T,S}) where {T,S}
    S3 = setdiff(S1, S2)
    if isempty(S3)
        copy(S2)
    else
        i = findfirst(x -> x<:Set, datatype_fieldtypes(S))
        if i == nothing
            LazyUnion(S3,S2.sets...)
        else
            ret = copy(S2)
            union!(ret[i], S3)
            ret
        end
    end
end               

# setdiff
setdiff(S::AbstractSet, ::EmptySet) = S
setdiff(::UniversalSet{Real}, S::HalfLine) = HalfLine(_notop(_cmp(S)), S.a)
setdiff(S1::HalfLine, S2::HalfLine) = S1 ∩ setdiff(ℝ, S2)

