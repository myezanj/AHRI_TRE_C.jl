# AHRI_TRE_C (Julia)

Julia package wrapping the AHRI TRE C core shared library.

This package is designed to call the C core from the AHRI_TRE.C project.

Maintainer: Njabulo Myeza (author, creator) - njabulo.myeza@ahri.org

Conversion behavior should be validated against the canonical Julia source repository: `https://github.com/AHRIORG/AHRI_TRE.jl`.

## C ABI symbol policy

The Julia wrapper now calls Julia-style unprefixed C symbols as the primary target (for example: `version`, `last_error`, `map_value_type`).

Prefixed symbols (for example: `ahri_tre_version`, `ahri_tre_last_error`) remain available in the C core as compatibility aliases and are safe for older consumers.

## Activate and use

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()

using AHRI_TRE_C
AHRI_TRE_C.load_library!()
println(AHRI_TRE_C.version())
```

## Run tests

```julia
using Pkg
Pkg.activate(".")
Pkg.test()
```

If TRE.C (or legacy AHRI_TRE.C) is a sibling repository, set:

```julia
ENV["TRE_C_ROOT"] = raw"C:\path\to\TRE.C"
```

Set `ENV["TRE_C_LIB"]` to override the shared library path directly.

By default, library discovery now attempts to fast-forward sync local clones whose
`origin` is `https://github.com/myezanj/AHRI_TRE.c.git` before resolving the
shared library path. To disable this behavior:

```julia
ENV["TRE_C_SYNC_LATEST"] = "0"
```

Legacy compatibility is still supported for `ENV["AHRI_TRE_C_ROOT"]` and `ENV["AHRI_TRE_C_LIB"]`.
