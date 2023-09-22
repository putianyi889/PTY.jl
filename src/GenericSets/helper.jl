macro subset_pair(A, B)
    esc(quote
        issubset(::$A, ::$B) = true
        union(::$A, S::$B) = S
        union(S::$B, ::$A) = S
        intersect(S::$A, ::$B) = S
        intersect(::$B, S::$A) = S
    end)
end
macro subset_pair_with_T(A, B)
    esc(quote
        issubset(::$A{<:T}, ::$B{T}) where T = true
        union(::$A{<:T}, S::$B{T}) where T = S
        union(S::$B{T}, ::$A{<:T}) where T = S
        intersect(S::$A{<:T}, ::$B{T}) where T = S
        intersect(::$B{T}, S::$A{<:T}) where T = S
    end)
end
@inline _subsetintersect(s1,s2) = s1⊆s2 ? s1 : s2
@inline _subsetunion(s1,s2) = s1⊆s2 ? s2 : s1

function _minimum(S::AbstractSet)
    ret = infimum(S)
    if ret ∈ S
        ret
    else
        throw(ArgumentError("$S doesn't have minimum. Try `infimum` instead."))
    end
end
function _maximum(S::AbstractSet)
    ret = supremum(S)
    if ret ∈ S
        ret
    else
        throw(ArgumentError("$S doesn't have maximum. Try `supremum` instead."))
    end
end
macro abstract_minmax(T)
    esc(quote
        minimum(S::$T) = _minimum(S)
        maximum(S::$T) = _maximum(S)
    end)
end