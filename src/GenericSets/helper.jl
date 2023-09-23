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