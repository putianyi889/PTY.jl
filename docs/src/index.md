# PTY.jl

Documentation for PTY.jl

## Type piracies by `PTY.Helper`

- `//` falls back to `/` for float inputs
- `:` for range construction now supports complex arithmetic progressions
- `AbstractArray{T, N}(A::BroadcastArray{S, N})` for eltype conversion

## `PTY.TR` for Terraria

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

### Type hierarchy

```@example
using PTY, TypeTree # hide
print(join(tt(Infs.AbstractInf))) # hide
```