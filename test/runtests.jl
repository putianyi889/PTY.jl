using PTY,Test

@testset "FunArray" begin
    B=FunArray(Float64,(x,y,z)->x+y*z,2,3,4)
    B[2,2,end]
    B[:,1:end,3]
    B[:,:,:]

    show(B)
    show(FunMatrix(Float64,+,3,3))
    show(FunVector(Float64,sqrt,10))
end