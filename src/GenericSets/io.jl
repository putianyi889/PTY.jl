show(io::IO, ::MIME"text/plain", S::HalfLine) = print(io, "{x|x", _cmp(S), S.a, "}")
show(io::IO, S::HalfLine) = print(io, "{x|x", _cmp(S), S.a, "}")
show(io::IO, ::MIME"text/plain", ::EmptySet) = print(io, "∅")
show(io::IO, ::MIME"text/plain", ::UniversalSet{Real}) = print(io, "ℝ")
show(io::IO, ::MIME"text/plain", S::Interval) = print(io, "{x|", S.sets[1].a, _invop(_cmp(S.sets[1])), 'x', _cmp(S.sets[2]), S.sets[2].a, '}')
function show(io::IO, mime::MIME"text/plain", S::ReduceSets{T,F}) where {T,F}
    print(io, F.instance)
    show(io, mime, S.sets)
end