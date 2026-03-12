module AHRI_TRE_C

export load_library!, version, sha256_file_hex, verify_sha256_file, path_to_file_uri, file_uri_to_path, is_ncname, to_ncname
export parse_flavour, map_sql_type_to_tre, extract_table_from_sql, parse_in_list_values
export parse_check_constraint_values, map_value_type, parse_redcap_choices
export strip_html, infer_label_from_field_name, get_redcap_choices_for_field
export parse_in_list_values_json, parse_check_constraint_values_json, map_redcap_value_type
export parse_redcap_choices_json, get_redcap_choices_for_field_json

const _lib_ref = Ref{String}("")

function _candidate_core_roots()::Vector{String}
    roots = String[]
    seen = Set{String}()

    if haskey(ENV, "AHRI_TRE_C_ROOT")
        root = normpath(ENV["AHRI_TRE_C_ROOT"])
        push!(roots, root)
        push!(seen, root)
    end

    sibling_names = ["AHRI_TRE.C", "AHRI_TRE.c", "AHRI_TRE.jl"]
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
    if haskey(ENV, "AHRI_TRE_C_LIB")
        return ENV["AHRI_TRE_C_LIB"]
    end

    for repo_root in _candidate_core_roots()
        if Sys.iswindows()
            candidates = [
                joinpath(repo_root, "c_core", "build", "Release", "ahri_tre_c.dll"),
                joinpath(repo_root, "c_core", "build", "ahri_tre_c.dll"),
            ]
        elseif Sys.isapple()
            candidates = [
                joinpath(repo_root, "c_core", "build", "libahri_tre_c.dylib"),
                joinpath(repo_root, "c_core", "build", "Release", "libahri_tre_c.dylib"),
            ]
        else
            candidates = [
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

    error("Could not find AHRI TRE C shared library. Set ENV[\"AHRI_TRE_C_LIB\"].")
end

function load_library!(path::Union{Nothing, AbstractString}=nothing)
    _lib_ref[] = path === nothing ? _default_library_path() : String(path)
    return nothing
end

function _lib()
    if isempty(_lib_ref[])
        load_library!()
    end
    return _lib_ref[]
end

function _last_error()
    ptr = ccall((:last_error, _lib()), Ptr{UInt8}, ())
    return ptr == C_NULL ? "Unknown AHRI_TRE C error" : unsafe_string(ptr)
end

function version()::String
    ptr = ccall((:version, _lib()), Ptr{UInt8}, ())
    return unsafe_string(ptr)
end

function sha256_file_hex(path::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((:sha256_file_hex, _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), path, out_ptr)
    if code != 0
        error("AHRI_TRE C error $(code): $(_last_error())")
    end
    try
        return unsafe_string(out_ptr[])
    finally
        ccall((:free_ptr, _lib()), Cvoid, (Ptr{Cvoid},), out_ptr[])
    end
end

function verify_sha256_file(path::AbstractString, expected_hex::AbstractString)::Bool
    out_match = Ref{Cint}(0)
    code = ccall((:verify_sha256_file, _lib()), Cint, (Cstring, Cstring, Ref{Cint}), path, expected_hex, out_match)
    if code != 0
        error("AHRI_TRE C error $(code): $(_last_error())")
    end
    return out_match[] != 0
end

function path_to_file_uri(path::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((:path_to_file_uri, _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), path, out_ptr)
    if code != 0
        error("AHRI_TRE C error $(code): $(_last_error())")
    end
    try
        return unsafe_string(out_ptr[])
    finally
        ccall((:free_ptr, _lib()), Cvoid, (Ptr{Cvoid},), out_ptr[])
    end
end

function file_uri_to_path(uri::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((:file_uri_to_path, _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), uri, out_ptr)
    if code != 0
        error("AHRI_TRE C error $(code): $(_last_error())")
    end
    try
        return unsafe_string(out_ptr[])
    finally
        ccall((:free_ptr, _lib()), Cvoid, (Ptr{Cvoid},), out_ptr[])
    end
end

function is_ncname(value::AbstractString; strict::Bool=false)::Bool
    out_valid = Ref{Cint}(0)
    code = ccall((:is_ncname, _lib()), Cint, (Cstring, Cint, Ref{Cint}), value, strict ? 1 : 0, out_valid)
    if code != 0
        error("AHRI_TRE C error $(code): $(_last_error())")
    end
    return out_valid[] != 0
end

function to_ncname(value::AbstractString; replacement::AbstractString="_", prefix::AbstractString="_", avoid_reserved::Bool=true, strict::Bool=false)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall(
        (:to_ncname, _lib()),
        Cint,
        (Cstring, Cstring, Cstring, Cint, Cint, Ref{Ptr{UInt8}}),
        value,
        replacement,
        prefix,
        avoid_reserved ? 1 : 0,
        strict ? 1 : 0,
        out_ptr,
    )
    if code != 0
        error("AHRI_TRE C error $(code): $(_last_error())")
    end
    try
        return unsafe_string(out_ptr[])
    finally
        ccall((:free_ptr, _lib()), Cvoid, (Ptr{Cvoid},), out_ptr[])
    end
end

function strip_html(text::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((:strip_html, _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), text, out_ptr)
    if code != 0
        error("AHRI_TRE C error $(code): $(_last_error())")
    end
    try
        return unsafe_string(out_ptr[])
    finally
        ccall((:free_ptr, _lib()), Cvoid, (Ptr{Cvoid},), out_ptr[])
    end
end

function infer_label_from_field_name(field_name::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((:infer_label_from_field_name, _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), field_name, out_ptr)
    if code != 0
        error("AHRI_TRE C error $(code): $(_last_error())")
    end
    try
        return unsafe_string(out_ptr[])
    finally
        ccall((:free_ptr, _lib()), Cvoid, (Ptr{Cvoid},), out_ptr[])
    end
end

function get_redcap_choices_for_field_json(field_type::AbstractString, choices::Union{Nothing, AbstractString}=nothing)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = if choices === nothing
        ccall((:get_redcap_choices_for_field_json, _lib()), Cint,
            (Cstring, Cstring, Ref{Ptr{UInt8}}), field_type, C_NULL, out_ptr)
    else
        ccall((:get_redcap_choices_for_field_json, _lib()), Cint,
            (Cstring, Cstring, Ref{Ptr{UInt8}}), field_type, choices, out_ptr)
    end
    if code != 0
        error("AHRI_TRE C error $(code): $(_last_error())")
    end
    try
        return out_ptr[] == C_NULL ? "[]" : unsafe_string(out_ptr[])
    finally
        ccall((:free_ptr, _lib()), Cvoid, (Ptr{Cvoid},), out_ptr[])
    end
end

function get_redcap_choices_for_field(field_type::AbstractString, choices::Union{Nothing, AbstractString}=nothing)::String
    return get_redcap_choices_for_field_json(field_type, choices)
end

function parse_flavour(flavour::AbstractString)::Int
    out_flavour = Ref{Cint}(0)
    code = ccall((:parse_flavour, _lib()), Cint, (Cstring, Ref{Cint}), flavour, out_flavour)
    if code != 0
        error("AHRI_TRE C error $(code): $(_last_error())")
    end
    return Int(out_flavour[])
end

function map_sql_type_to_tre(sql_type::AbstractString)::Int
    out_type = Ref{Cint}(0)
    code = ccall((:map_sql_type_to_tre, _lib()), Cint, (Cstring, Ref{Cint}), sql_type, out_type)
    if code != 0
        error("AHRI_TRE C error $(code): $(_last_error())")
    end
    return Int(out_type[])
end

function extract_table_from_sql(sql::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((:extract_table_from_sql, _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), sql, out_ptr)
    if code != 0
        error("AHRI_TRE C error $(code): $(_last_error())")
    end
    try
        return out_ptr[] == C_NULL ? "" : unsafe_string(out_ptr[])
    finally
        ccall((:free_ptr, _lib()), Cvoid, (Ptr{Cvoid},), out_ptr[])
    end
end

function parse_in_list_values_json(values_str::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((:parse_in_list_values_json, _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), values_str, out_ptr)
    if code != 0
        error("AHRI_TRE C error $(code): $(_last_error())")
    end
    try
        return out_ptr[] == C_NULL ? "[]" : unsafe_string(out_ptr[])
    finally
        ccall((:free_ptr, _lib()), Cvoid, (Ptr{Cvoid},), out_ptr[])
    end
end

function parse_in_list_values(values_str::AbstractString)::String
    return parse_in_list_values_json(values_str)
end

function parse_check_constraint_values_json(constraint_def::AbstractString, column_name::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((:parse_check_constraint_values_json, _lib()), Cint, (Cstring, Cstring, Ref{Ptr{UInt8}}), constraint_def, column_name, out_ptr)
    if code != 0
        error("AHRI_TRE C error $(code): $(_last_error())")
    end
    try
        return out_ptr[] == C_NULL ? "[]" : unsafe_string(out_ptr[])
    finally
        ccall((:free_ptr, _lib()), Cvoid, (Ptr{Cvoid},), out_ptr[])
    end
end

function parse_check_constraint_values(constraint_def::AbstractString, column_name::AbstractString)::String
    return parse_check_constraint_values_json(constraint_def, column_name)
end

function map_redcap_value_type(field_type::AbstractString, validation::Union{Nothing, AbstractString}=nothing)
    out_type = Ref{Cint}(0)
    out_fmt = Ref{Ptr{UInt8}}(C_NULL)
    code = if validation === nothing
        ccall((:map_value_type, _lib()), Cint, (Cstring, Cstring, Ref{Cint}, Ref{Ptr{UInt8}}), field_type, C_NULL, out_type, out_fmt)
    else
        ccall((:map_value_type, _lib()), Cint, (Cstring, Cstring, Ref{Cint}, Ref{Ptr{UInt8}}), field_type, validation, out_type, out_fmt)
    end
    if code != 0
        error("AHRI_TRE C error $(code): $(_last_error())")
    end
    fmt = nothing
    try
        if out_fmt[] != C_NULL
            fmt = unsafe_string(out_fmt[])
        end
    finally
        if out_fmt[] != C_NULL
            ccall((:free_ptr, _lib()), Cvoid, (Ptr{Cvoid},), out_fmt[])
        end
    end
    return Int(out_type[]), fmt
end

function map_value_type(field_type::AbstractString, validation::Union{Nothing, AbstractString}=nothing)
    return map_redcap_value_type(field_type, validation)
end

function parse_redcap_choices_json(choices::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((:parse_redcap_choices_json, _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), choices, out_ptr)
    if code != 0
        error("AHRI_TRE C error $(code): $(_last_error())")
    end
    try
        return out_ptr[] == C_NULL ? "[]" : unsafe_string(out_ptr[])
    finally
        ccall((:free_ptr, _lib()), Cvoid, (Ptr{Cvoid},), out_ptr[])
    end
end

function parse_redcap_choices(choices::AbstractString)::String
    return parse_redcap_choices_json(choices)
end

end
