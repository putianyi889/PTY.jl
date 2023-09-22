# PTY.jl

Documentation for PTY.jl

## Type piracies by `PTY.Helper`

- `//` falls back to `/` for float inputs
- `:` for range construction now supports complex arithmetic progressions
- `AbstractArray{T, N}(A::BroadcastArray{S, N})` for eltype conversion
- `eps` supports complex inputs
- `ceil` and `floor` support complex inputs.

## `PTY.TR` for Terraria
See also [``\\mathbb{Z}_2``-linear-algebra](@ref).

```@autodocs
Modules = [PTY.TR]
```

## `PTY.SpecFun` for special functions

```@autodocs
Modules = [PTY.SpecFun]
```

## `PTY.ContFrac` for continued fractions

```@autodocs
Modules = [PTY.ContFrac]
```

## `PTY.Infs` for infinities

This is an experiment of rewriting `Infinities.jl`. This module is not expected to work at present.

## `PTY.GenericSets` for sets

```@autodocs
Modules = [PTY.GenericSets]
```