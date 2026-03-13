using Test
using AHRI_TRE_C

@testset "AHRI_TRE_C" begin
    # Smoke test: module loads and exports a callable API function.
    @test isdefined(AHRI_TRE_C, :load_library!)
    @test hasmethod(AHRI_TRE_C.load_library!, Tuple{})
end
