# Julia Developer Tips

A selling point of Julia is that Julia tries to be generic: irrelevant packages should work together out of the box. While this is much appreciated by users, it's not so trivial to create a package that is fully compatible with vanilla Julia, let alone other packages. That's because vanilla Julia has many special types and methods that need to be taken care of.

This document is updated as of Julia 1.9.2.

- `*(A::AbstractMatrix, B::AbstractMatrix)[1,:] == A[1,:] * B`? Wrong!
- `AbstractArray(A::AbstractArray) == A`? Wrong!
- Assuming dimensions match, `(a:b:c) + (d:e:f) == (a+d):(b+e):(c+f)`? Wrong!
- `*(n::Int, r::OrdinalRange) isa OrdinalRange`? Wrong!
- `(a+b)+c ≡ a+(b+c)`? Wrong!
- `a*b ≡ [a]⋅[b] ≡ sum([a].*[b])`? All Wrong!
- Many "generic" methods are sources of ambiguities.

## `AbstractQ` from QR decomposition

The `Q` factor of a QR factorization have two sizes:


However, a slice or view of Q only has one size.

## The `AbstractArray` constructor

While `AbstractArray` is frequently used to promote types, especially eltypes, (somehow vanilla Julia still doesn't have a method for eltype conversion,) it's technically not supported by Julia Base. Julia Base has two major array types: concrete `Array` and lazy `AbstractRange`. By default, calling `AbstractArray{T}` on an `AbstractArray` will materialize it to `Array`, while `AbstractArray` without the eltype specification is undefined by design.

For custom types in most packages, `V{T}(A::V) where V<:AbstractArray` does the eltype conversion. However, it's not supported by ranges for a couple of reasons.
- The `AbstractRange` constructor is simply not a thing.
- See [OrdinalRange](@ref)

## `OrdinalRange`

By definition from the documentation, `OrdinalRange` only supports integer eltypes and converting the eltype to float normally give a `StepRangeLen`.

However, you could use the basic constructor to get `OrdinalRange` with float entries.

Manipulating `OrdinalRange` usually falls back to `StepRangeLen` even if the eltype remains integer.

## Integer type stabilities of `Bool`, `dot` and `sum`

The vast issues that `Bool` has is because of these rules:
- `+(::Bool, ::Bool) ::Int64`
- `+(::Bool, ::Int8) ::Int8` (similar for `Int16`, etc.)
- `*(::Bool, ::Bool) ::Bool` 

The way `dot` works is that it first decides a return type `T` that should be obtained by multiplying and adding entries, then accumulate values to `zero(T)`. This is essential for zero-length arrays and should work for general types, where `Bool` is excluded.

`sum` promotes all short integers to `Int64`.