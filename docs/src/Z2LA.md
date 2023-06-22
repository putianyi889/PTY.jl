# ``\mathbb{Z}_2`` linear algebra

Since this implementation uses bitwise operations, it's significantly faster than the generic interface provided by [`Nemo.jl`](https://github.com/Nemocas/Nemo.jl).

Defines [`Z2Vector`](@ref TR.Z2Vector), [`Z2RowMat`](@ref TR.Z2RowMat) and [`Z2ColMat`](@ref TR.Z2ColMat).

## Construction

### Vectors

|Constructor|Implemented|Tested|
|:-:|:-:|:-:|
|from an integer and a bitlength|✅|✅|
|from undef|❌|❌|
|from a vector|✅|✅|

### Matrices

Constructing from `undef` sets all entries to zero since methods are implemented assuming that all higher bits are zero.

|Constructor|Z2RowMat|Z2ColMat|Tested|
|:-:|:-:|:-:|:-:|
|from a vector and a bitlength|✅|✅|✅|
|from undef|✅|✅|✅|
|from a matrix|✅|✅|✅|

## Interface

`getindex` and `setindex!` are only implemented for single entries at the moment, which means accessing a submatrix is relatively slow.

|Method|Z2Vector|Z2RowMat|Z2ColMat|Tested|
|:-:|:-:|:-:|:-:|:-:|
|size|✅|✅|✅|✅|
|getindex|✅|✅|✅|✅|
|setindex!|✅|✅|✅|✅|
|zero|✅|✅|✅|✅|
|one|🔘|✅|✅|✅|
|copy|✅|✅|✅|✅|
|similar|✅|✅|✅|❌|
|fill!|✅|✅|✅|✅|
|lmul!|✅|✅|✅|❌|
|rmul!|✅|✅|✅|❌|
|+|✅|✅|✅|❌|
|transpose|🔘|✅|✅|❌|
|adjoint|🔘|✅|✅|❌|
|istril|🔘|❌|❌|❌|
|istriu|🔘|❌|❌|❌|
|rank|🔘|✅|✅|❌|
|det|🔘|✅|✅|❌|

## Bitwise operations
|Operation|Z2Vector|Z2RowMat|Z2ColMat|Tested|
|:-:|:-:|:-:|:-:|:-:|
|~|❌|✅|✅|❌|
|&|❌|✅|✅|❌|
|\||❌|✅|✅|❌|
|⊻|❌|✅|✅|❌|
|⊽|❌|✅|✅|❌|
|⊼|❌|✅|✅|❌|

## Algebra

|Method|Implemented|Complexity|Tested|
|:-:|:-:|:-:|:-:|
|`dot(::Z2Vector, ::Z2Vector)`|✅|``O(1)``|❌|
|`*(::Z2RowMat, ::Z2Vector)`|✅|``O(n)``|❌|
|`*(::Z2ColMat, ::Z2Vector)`|✅|``O(n)``|❌|
|`*(::Z2RowMat, ::Z2RowMat)`|✅|``O(n^2)``|❌|
|`\(::Z2RowMat, ::Z2RowMat)`|✅|``O(n^2)``|❌|