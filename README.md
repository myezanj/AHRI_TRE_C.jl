# AHRI_TRE_C (Julia)

Julia package wrapping the AHRI TRE C core shared library.

This package is designed to call the C core from the AHRI_TRE.C project.

Maintainer: Njabulo Myeza (author, creator) - njabulo.myeza@ahri.org

Conversion behavior should be validated against the canonical Julia source repository: `https://github.com/AHRIORG/AHRI_TRE.jl`.

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

Legacy compatibility is still supported for `ENV["AHRI_TRE_C_ROOT"]` and `ENV["AHRI_TRE_C_LIB"]`.
