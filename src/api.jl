function version()::String
    ptr = ccall((_c_symbol("version"), _lib()), Ptr{UInt8}, ())
    return unsafe_string(ptr)
end

function sha256_file_hex(path::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("sha256_file_hex"), _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), path, out_ptr)
    return _string_result(code, out_ptr)
end

function verify_sha256_file(path::AbstractString, expected_hex::AbstractString)::Bool
    out_match = Ref{Cint}(0)
    code = ccall((_c_symbol("verify_sha256_file"), _lib()), Cint, (Cstring, Cstring, Ref{Cint}), path, expected_hex, out_match)
    _raise_if_error(code)
    return out_match[] != 0
end

function path_to_file_uri(path::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("path_to_file_uri"), _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), path, out_ptr)
    return _string_result(code, out_ptr)
end

function file_uri_to_path(uri::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("file_uri_to_path"), _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), uri, out_ptr)
    return _string_result(code, out_ptr)
end

function is_ncname(value::AbstractString; strict::Bool=false)::Bool
    out_valid = Ref{Cint}(0)
    code = ccall((_c_symbol("is_ncname"), _lib()), Cint, (Cstring, Cint, Ref{Cint}), value, strict ? 1 : 0, out_valid)
    _raise_if_error(code)
    return out_valid[] != 0
end

function to_ncname(value::AbstractString; replacement::AbstractString="_", prefix::AbstractString="_", avoid_reserved::Bool=true, strict::Bool=false)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall(
        (_c_symbol("to_ncname"), _lib()),
        Cint,
        (Cstring, Cstring, Cstring, Cint, Cint, Ref{Ptr{UInt8}}),
        value,
        replacement,
        prefix,
        avoid_reserved ? 1 : 0,
        strict ? 1 : 0,
        out_ptr,
    )
    return _string_result(code, out_ptr)
end

function strip_html(text::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("strip_html"), _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), text, out_ptr)
    return _string_result(code, out_ptr)
end

function infer_label_from_field_name(field_name::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("infer_label_from_field_name"), _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), field_name, out_ptr)
    return _string_result(code, out_ptr)
end

function get_redcap_choices_for_field_json(field_type::AbstractString, choices::Union{Nothing, AbstractString}=nothing)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = if choices === nothing
        ccall((_c_symbol("get_redcap_choices_for_field_json"), _lib()), Cint,
            (Cstring, Cstring, Ref{Ptr{UInt8}}), field_type, C_NULL, out_ptr)
    else
        ccall((_c_symbol("get_redcap_choices_for_field_json"), _lib()), Cint,
            (Cstring, Cstring, Ref{Ptr{UInt8}}), field_type, choices, out_ptr)
    end
    return _string_result(code, out_ptr; null_default="[]")
end

function parse_flavour(flavour::AbstractString)::Int
    out_flavour = Ref{Cint}(0)
    code = ccall((_c_symbol("parse_flavour"), _lib()), Cint, (Cstring, Ref{Cint}), flavour, out_flavour)
    _raise_if_error(code)
    return Int(out_flavour[])
end

function map_sql_type_to_tre(sql_type::AbstractString)::Int
    out_type = Ref{Cint}(0)
    code = ccall((_c_symbol("map_sql_type_to_tre"), _lib()), Cint, (Cstring, Ref{Cint}), sql_type, out_type)
    _raise_if_error(code)
    return Int(out_type[])
end

function extract_table_from_sql(sql::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("extract_table_from_sql"), _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), sql, out_ptr)
    return _string_result(code, out_ptr; null_default="")
end

function parse_in_list_values_json(values_str::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("parse_in_list_values_json"), _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), values_str, out_ptr)
    return _string_result(code, out_ptr; null_default="[]")
end

function parse_check_constraint_values_json(constraint_def::AbstractString, column_name::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("parse_check_constraint_values_json"), _lib()), Cint, (Cstring, Cstring, Ref{Ptr{UInt8}}), constraint_def, column_name, out_ptr)
    return _string_result(code, out_ptr; null_default="[]")
end

function map_redcap_value_type(field_type::AbstractString, validation::Union{Nothing, AbstractString}=nothing)
    out_type = Ref{Cint}(0)
    out_fmt = Ref{Ptr{UInt8}}(C_NULL)
    code = if validation === nothing
        ccall((_c_symbol("map_redcap_value_type"), _lib()), Cint, (Cstring, Cstring, Ref{Cint}, Ref{Ptr{UInt8}}), field_type, C_NULL, out_type, out_fmt)
    else
        ccall((_c_symbol("map_redcap_value_type"), _lib()), Cint, (Cstring, Cstring, Ref{Cint}, Ref{Ptr{UInt8}}), field_type, validation, out_type, out_fmt)
    end
    _raise_if_error(code)

    fmt = nothing
    try
        if out_fmt[] != C_NULL
            fmt = unsafe_string(out_fmt[])
        end
    finally
        _free_c_string(out_fmt[])
    end

    return Int(out_type[]), fmt
end

function parse_redcap_choices_json(choices::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("parse_redcap_choices_json"), _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), choices, out_ptr)
    return _string_result(code, out_ptr; null_default="[]")
end
