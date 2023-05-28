module SpecFun

include("SpecFun/mittagleffler.jl")

"""
    fracpochhammer(a, b, n)

Calculate the fraction of two Pochhammer symbols ``\\frac{(a)_n}{(b)_n}`` by multiplying the fractions. This approach reduces the risk of overflow/underflow when ``n`` is large.

# Examples
```jldoctest
julia> SpecFun.fracpochhammer(1, 2, 3) # (1 * 2 * 3) / (2 * 3 * 4)
0.25
```
"""
fracpochhammer(a,b,n) = prod(range(a,length=n)./range(b,length=n));

"""
    fracpochhammer(a, b, stepa, stepb, n)

Similar to `fracpochhammer(a, b, n)`, except that the steps of the Pochhammer symbols are not necessarily ``1``.

# Examples
```jldoctest
julia> SpecFun.fracpochhammer(1, 2, 0.5, 1, 3) # (1 * 1.5 * 2) / (2 * 3 * 4)
0.125
```
"""
fracpochhammer(a,b,stepa,stepb,n) = prod(range(a,step=stepa,length=n)./range(b,step=stepb,length=n));

end # module