# AHRI_TRE_C (Julia)

Julia package wrapping the AHRI TRE C core shared library.

This package is designed to call the C core from the AHRI_TRE.C project.

Conversion behavior should be validated against the canonical Julia source repository: `https://github.com/AHRIORG/AHRI_TRE.jl`.

## C ABI symbol policy

The Julia wrapper now calls Julia-style unprefixed C symbols as the primary target (for example: `version`, `last_error`, `map_value_type`).

Prefixed symbols (for example: `ahri_tre_version`, `ahri_tre_last_error`) remain available in the C core as compatibility aliases and are safe for older consumers.

## Activate and use

```julia
using Pkg
Pkg.activate("wrappers/julia")
Pkg.instantiate()

using AHRI_TRE_C
AHRI_TRE_C.load_library!()
println(AHRI_TRE_C.version())
```

If AHRI_TRE.C is a sibling repository, set:

```julia
ENV["AHRI_TRE_C_ROOT"] = raw"C:\path\to\AHRI_TRE.C"
```

Set `ENV["AHRI_TRE_C_LIB"]` to override the shared library path directly.
