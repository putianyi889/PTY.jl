# Z2 linear algebra

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
|one|🔘|✅|✅|❌|
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

## Bitwise operations
|Operation|Z2Vector|Z2RowMat|Z2ColMat|Tested|
|:-:|:-:|:-:|:-:|:-:|
|~|❌|✅|✅|❌|
|&|❌|✅|✅|❌|
|||❌|✅|✅|❌|
|⊻|❌|✅|✅|❌|
|⊽|❌|✅|✅|❌|
|⊼|❌|✅|✅|❌|

## Algebra

|Method|Implemented|Tested|
|:-:|:-:|:-:|
|`dot(::Z2Vector, ::Z2Vector)`|✅|❌|
|`*(::Z2RowMat, ::Z2Vector)`|✅|❌|
|`*(::Z2ColMat, ::Z2Vector)`|✅|❌|
|`*(::Z2RowMat, ::Z2RowMat)`|✅|❌|
|`\(::Z2RowMat, ::Z2RowMat)`|✅|❌|