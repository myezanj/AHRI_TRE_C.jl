# AHRI_TRE_C (Julia)

Julia package wrapping the AHRI TRE C core shared library.

This package is designed to call the C core from the AHRI_TRE.C project.

Conversion behavior should be validated against the canonical Julia source repository: `https://github.com/AHRIORG/AHRI_TRE.jl`.

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
