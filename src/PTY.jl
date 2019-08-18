module PTY

export FunArray,FunVector,FunMatrix

struct FunArray{T,n} <: AbstractArray{T,n}
    fun::Function
    sz::Tuple{TT,1} where TT <: Integer
end
Base.size(A::FunArray)=A.sz
Base.getindex(A::FunArray{T,N},I::Vararg{Int, N}) where {T,N}=A.fun(I)

const FunVector{T}=FunArray{T,1}
const FunMatrix{T}=FunArray{T,2}

FunArray(T::Type,fun::Function,sz...)=FunArray{T,length(sz)}(fun,sz)

end # module
