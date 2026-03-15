using Libdl

const _lib_ref = Ref{String}("")
const _symbol_prefix_ref = Ref{Union{Nothing, String}}(nothing)

const _NEW_ROOT_ENV = "TRE_C_ROOT"
const _OLD_ROOT_ENV = "AHRI_TRE_C_ROOT"
const _NEW_LIB_ENV = "TRE_C_LIB"
const _OLD_LIB_ENV = "AHRI_TRE_C_LIB"
const _NEW_VERSION_MIN_ENV = "TRE_C_VERSION_MIN"
const _OLD_VERSION_MIN_ENV = "AHRI_TRE_C_VERSION_MIN"
const _NEW_VERSION_MAX_ENV = "TRE_C_VERSION_MAX"
const _OLD_VERSION_MAX_ENV = "AHRI_TRE_C_VERSION_MAX"
const _DEFAULT_VERSION_MIN = "0.2.0"
const _DEFAULT_VERSION_MAX = "0.2.x"
const _SYNC_LATEST_ENV = "TRE_C_SYNC_LATEST"
const _LATEST_REMOTE_URL = "https://github.com/myezanj/AHRI_TRE.c.git"

function _first_env(names::Tuple{Vararg{String}})::Union{Nothing, String}
    for name in names
        if haskey(ENV, name)
            value = strip(ENV[name])
            if !isempty(value)
                return value
            end
        end
    end
    return nothing
end

function _parse_semver_tuple(version::AbstractString)::NTuple{3, Int}
    m = match(r"^\s*(\d+)\.(\d+)\.(\d+)", String(version))
    if m === nothing
        error("Invalid C core version '$(version)'. Expected semver like '0.2.0'.")
    end
    return (parse(Int, m.captures[1]), parse(Int, m.captures[2]), parse(Int, m.captures[3]))
end

function _version_meets_min(current::NTuple{3, Int}, min_spec::AbstractString)::Bool
    return current >= _parse_semver_tuple(min_spec)
end

function _version_meets_max(current::NTuple{3, Int}, max_spec::AbstractString)::Bool
    spec = lowercase(strip(String(max_spec)))
    if occursin('x', spec) || occursin('*', spec)
        tokens = split(spec, '.')
        current_parts = (current[1], current[2], current[3])
        for i in 1:min(3, length(tokens))
            token = strip(tokens[i])
            if token == "x" || token == "*"
                return true
            end
            if isnothing(match(r"^\d+$", token)) || current_parts[i] != parse(Int, token)
                return false
            end
        end
        return true
    end
    return current <= _parse_semver_tuple(spec)
end

function _validate_core_version_window!()
    min_spec = something(_first_env((_NEW_VERSION_MIN_ENV, _OLD_VERSION_MIN_ENV)), _DEFAULT_VERSION_MIN)
    max_spec = something(_first_env((_NEW_VERSION_MAX_ENV, _OLD_VERSION_MAX_ENV)), _DEFAULT_VERSION_MAX)
    version_ptr = ccall((_c_symbol("version"), _lib()), Ptr{UInt8}, ())
    core_version = version_ptr == C_NULL ? "" : unsafe_string(version_ptr)
    current = _parse_semver_tuple(core_version)

    if !_version_meets_min(current, min_spec) || !_version_meets_max(current, max_spec)
        error("AHRI_TRE C core version '$(core_version)' is outside the supported window [$(min_spec), $(max_spec)]. " *
              "Adjust TRE_C_VERSION_MIN/TRE_C_VERSION_MAX or install a compatible core.")
    end

    return nothing
end

function _normalized_remote(url::AbstractString)::String
    out = strip(String(url))
    out = replace(out, r"\.git$" => "")
    out = replace(out, "git@github.com:" => "https://github.com/")
    return out
end

function _want_latest_sync()::Bool
    val = get(ENV, _SYNC_LATEST_ENV, "1")
    val_l = lowercase(strip(val))
    return !(val_l in ("0", "false", "no", "off"))
end

function _repo_uses_latest_remote(repo_root::AbstractString)::Bool
    gitdir = joinpath(repo_root, ".git")
    if !isdir(gitdir)
        return false
    end
    try
        remote = readchomp(`git -C $(repo_root) config --get remote.origin.url`)
        return _normalized_remote(remote) == _normalized_remote(_LATEST_REMOTE_URL)
    catch
        return false
    end
end

function _sync_repo_latest!(repo_root::AbstractString)
    try
        run(`git -C $(repo_root) fetch origin --quiet`)
        run(`git -C $(repo_root) pull --ff-only --quiet`)
    catch
        # Continue with local checkout if network/auth/ff-only sync fails.
    end
    return nothing
end

function _candidate_core_roots()::Vector{String}
    roots = String[]
    seen = Set{String}()

    for env_name in (_NEW_ROOT_ENV, _OLD_ROOT_ENV)
        if haskey(ENV, env_name)
            root = normpath(ENV[env_name])
            if !(root in seen)
                push!(roots, root)
                push!(seen, root)
            end
        end
    end

    sibling_names = ["TRE.C", "TRE.c", "TRE.jl", "AHRI_TRE.C", "AHRI_TRE.c", "AHRI_TRE.jl"]
    anchor = normpath(@__DIR__)
    while true
        parent = dirname(anchor)
        for name in sibling_names
            sibling = normpath(joinpath(parent, name))
            if !(sibling in seen)
                push!(roots, sibling)
                push!(seen, sibling)
            end
        end
        if parent == anchor
            break
        end
        anchor = parent
    end

    return roots
end

function _default_library_path()::String
    if haskey(ENV, _NEW_LIB_ENV)
        return ENV[_NEW_LIB_ENV]
    end
    if haskey(ENV, _OLD_LIB_ENV)
        return ENV[_OLD_LIB_ENV]
    end

    for repo_root in _candidate_core_roots()
        if _want_latest_sync() && _repo_uses_latest_remote(repo_root)
            _sync_repo_latest!(repo_root)
        end

        if Sys.iswindows()
            candidates = [
                joinpath(repo_root, "c_core", "build", "Release", "tre_c.dll"),
                joinpath(repo_root, "c_core", "build", "tre_c.dll"),
                joinpath(repo_root, "c_core", "build", "Release", "ahri_tre_c.dll"),
                joinpath(repo_root, "c_core", "build", "ahri_tre_c.dll"),
            ]
        elseif Sys.isapple()
            candidates = [
                joinpath(repo_root, "c_core", "build", "libtre_c.dylib"),
                joinpath(repo_root, "c_core", "build", "Release", "libtre_c.dylib"),
                joinpath(repo_root, "c_core", "build", "libahri_tre_c.dylib"),
                joinpath(repo_root, "c_core", "build", "Release", "libahri_tre_c.dylib"),
            ]
        else
            candidates = [
                joinpath(repo_root, "c_core", "build", "libtre_c.so"),
                joinpath(repo_root, "c_core", "build", "Release", "libtre_c.so"),
                joinpath(repo_root, "c_core", "build", "libahri_tre_c.so"),
                joinpath(repo_root, "c_core", "build", "Release", "libahri_tre_c.so"),
            ]
        end

        for candidate in candidates
            if isfile(candidate)
                return candidate
            end
        end
    end

    error("Could not find TRE C shared library. Set ENV[\"TRE_C_LIB\"] (or legacy ENV[\"AHRI_TRE_C_LIB\"]).")
end

function load_library!(path::Union{Nothing, AbstractString}=nothing)
    _lib_ref[] = path === nothing ? _default_library_path() : String(path)
    _symbol_prefix_ref[] = nothing
    _validate_core_version_window!()
    return nothing
end

function _lib()
    if isempty(_lib_ref[])
        load_library!()
    end
    return _lib_ref[]
end

function _detect_symbol_prefix()::String
    handle = Libdl.dlopen(_lib())
    try
        if Libdl.dlsym_e(handle, :tre_last_error) != C_NULL
            return "tre_"
        end
        if Libdl.dlsym_e(handle, :ahri_tre_last_error) != C_NULL
            return "ahri_tre_"
        end
    finally
        Libdl.dlclose(handle)
    end

    error("Could not detect TRE C symbol prefix in loaded shared library.")
end

function _c_symbol(name::AbstractString)::Symbol
    if _symbol_prefix_ref[] === nothing
        _symbol_prefix_ref[] = _detect_symbol_prefix()
    end
    return Symbol(_symbol_prefix_ref[] * name)
end

function _last_error()::String
    ptr = ccall((_c_symbol("last_error"), _lib()), Ptr{UInt8}, ())
    return ptr == C_NULL ? "Unknown AHRI_TRE C error" : unsafe_string(ptr)
end

function _raise_if_error(code::Integer)
    if code != 0
        error("AHRI_TRE C error $(code): $(_last_error())")
    end
    return nothing
end

function _free_c_string(ptr::Ptr{UInt8})
    if ptr != C_NULL
        ccall((_c_symbol("free"), _lib()), Cvoid, (Ptr{Cvoid},), ptr)
    end
    return nothing
end

function _string_result(code::Integer, out_ptr::Ref{Ptr{UInt8}}; null_default::String="")::String
    _raise_if_error(code)
    try
        return out_ptr[] == C_NULL ? null_default : unsafe_string(out_ptr[])
    finally
        _free_c_string(out_ptr[])
    end
end
