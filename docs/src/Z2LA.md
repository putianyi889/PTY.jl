# Z2 linear algebra

Since this implementation uses bitwise operations, it's significantly faster than the generic interface provided by [`Nemo.jl`](https://github.com/Nemocas/Nemo.jl).

Defines [`Z2Vector`](@ref), [`Z2RowMat`](@ref) and [`Z2ColMat`](@ref).

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

|Method|Z2Vector|Z2RowMat|Z2ColMat|Tested|
|:-:|:-:|:-:|:-:|:-:|
|size|✅|✅|✅|✅|
|getindex|✅|✅|✅|✅|
|setindex!|✅|✅|✅|❌|
|zero|✅|✅|✅|❌|
|copy|✅|✅|✅|❌|
|similar|✅|❌|❌|❌|
|fill!|✅|✅|✅|❌|
|lmul!|✅|❌|❌|❌|
|rmul!|✅|❌|❌|❌|
|+|✅|✅|✅|❌|
|transpose|❌|❌|❌|❌|
|adjoint|❌|❌|❌|❌|

## Algebra

|Method|Implemented|Tested|
|:-:|:-:|:-:|
|`dot(::Z2Vector, ::Z2Vector)`|✅|❌|
|`*(::Z2RowMat, ::Z2Vector)`|✅|❌|
|`*(::Z2ColMat, ::Z2Vector)`|✅|❌|
|`*(::Z2RowMat, ::Z2RowMat)*`|❌|❌|
