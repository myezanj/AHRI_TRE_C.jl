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

function emptydir(path::AbstractString; create::Bool=true, retries::Integer=0, wait_millis::Integer=0)
    code = ccall((_c_symbol("emptydir"), _lib()), Cint, (Cstring, Cint, Cint, Cint), path, create ? 1 : 0, retries, wait_millis)
    _raise_if_error(code)
    return nothing
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

function get_datasetname(study_name::AbstractString, asset_name::AbstractString,
    major::Integer, minor::Integer, patch::Integer; include_schema::Bool=true)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall(
        (_c_symbol("get_datasetname"), _lib()),
        Cint,
        (Cstring, Cstring, Cint, Cint, Cint, Cint, Ref{Ptr{UInt8}}),
        study_name,
        asset_name,
        major,
        minor,
        patch,
        include_schema ? 1 : 0,
        out_ptr,
    )
    return _string_result(code, out_ptr)
end

function get_datafilename(asset_name::AbstractString, major::Integer, minor::Integer, patch::Integer)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall(
        (_c_symbol("get_datafilename"), _lib()),
        Cint,
        (Cstring, Cint, Cint, Cint, Ref{Ptr{UInt8}}),
        asset_name,
        major,
        minor,
        patch,
        out_ptr,
    )
    return _string_result(code, out_ptr)
end

function get_datalake_file_path(lake_data::AbstractString, study_name::AbstractString, asset_name::AbstractString,
    source_file_path::AbstractString, major::Integer, minor::Integer, patch::Integer)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall(
        (_c_symbol("get_datalake_file_path"), _lib()),
        Cint,
        (Cstring, Cstring, Cstring, Cstring, Cint, Cint, Cint, Ref{Ptr{UInt8}}),
        lake_data,
        study_name,
        asset_name,
        source_file_path,
        major,
        minor,
        patch,
        out_ptr,
    )
    return _string_result(code, out_ptr)
end

function prepare_datafile(file_path::AbstractString, edam_format::AbstractString;
    compress::Bool=false, encrypt::Bool=false, precomputed_digest::Union{Nothing, AbstractString}=nothing)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = if precomputed_digest === nothing
        ccall(
            (_c_symbol("prepare_datafile_json"), _lib()),
            Cint,
            (Cstring, Cstring, Cint, Cint, Cstring, Ref{Ptr{UInt8}}),
            file_path,
            edam_format,
            compress ? 1 : 0,
            encrypt ? 1 : 0,
            C_NULL,
            out_ptr,
        )
    else
        ccall(
            (_c_symbol("prepare_datafile_json"), _lib()),
            Cint,
            (Cstring, Cstring, Cint, Cint, Cstring, Ref{Ptr{UInt8}}),
            file_path,
            edam_format,
            compress ? 1 : 0,
            encrypt ? 1 : 0,
            precomputed_digest,
            out_ptr,
        )
    end
    return _string_result(code, out_ptr)
end

function dataset_to_arrow(dataset_name::AbstractString, outputdir::AbstractString; replace::Bool=false)
    out_would_overwrite = Ref{Cint}(0)
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall(
        (_c_symbol("dataset_to_arrow_output_path"), _lib()),
        Cint,
        (Cstring, Cstring, Cint, Ref{Cint}, Ref{Ptr{UInt8}}),
        dataset_name,
        outputdir,
        replace ? 1 : 0,
        out_would_overwrite,
        out_ptr,
    )
    path = _string_result(code, out_ptr)
    return (path=path, would_overwrite=(out_would_overwrite[] != 0))
end

function dataset_to_csv(dataset_name::AbstractString, outputdir::AbstractString; compress::Bool=false, replace::Bool=false)
    out_would_overwrite = Ref{Cint}(0)
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall(
        (_c_symbol("dataset_to_csv_output_path"), _lib()),
        Cint,
        (Cstring, Cstring, Cint, Cint, Ref{Cint}, Ref{Ptr{UInt8}}),
        dataset_name,
        outputdir,
        compress ? 1 : 0,
        replace ? 1 : 0,
        out_would_overwrite,
        out_ptr,
    )
    path = _string_result(code, out_ptr)
    return (path=path, would_overwrite=(out_would_overwrite[] != 0))
end

function makeparams(n::Integer)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("makeparams_json"), _lib()), Cint, (Cint, Ref{Ptr{UInt8}}), n, out_ptr)
    return _string_result(code, out_ptr)
end

function quote_ident(name::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("quote_ident"), _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), name, out_ptr)
    return _string_result(code, out_ptr)
end

function quote_identifier(name::AbstractString, flavour_id::Integer=parse_flavour("postgres"))::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("quote_identifier"), _lib()), Cint, (Cstring, Cint, Ref{Ptr{UInt8}}), name, flavour_id, out_ptr)
    return _string_result(code, out_ptr)
end

function quote_sql_str(value::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("quote_sql_str"), _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), value, out_ptr)
    return _string_result(code, out_ptr)
end

function julia_type_to_sql_string(julia_type::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("julia_type_to_sql_string"), _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), julia_type, out_ptr)
    return _string_result(code, out_ptr)
end

function tre_type_to_duckdb_sql(value_type_id::Integer)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("tre_type_to_duckdb_sql"), _lib()), Cint, (Cint, Ref{Ptr{UInt8}}), value_type_id, out_ptr)
    return _string_result(code, out_ptr)
end

function find_system_odbc_driver(driver_name::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("find_system_odbc_driver"), _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), driver_name, out_ptr)
    return _string_result(code, out_ptr)
end

function find_mssql_driver_in_directory()::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("find_mssql_driver_in_directory"), _lib()), Cint, (Ref{Ptr{UInt8}},), out_ptr)
    return _string_result(code, out_ptr)
end

function ensure_mssql_driver_registered(driver_name::AbstractString="ODBC Driver 18 for SQL Server")::Bool
    out_available = Ref{Cint}(0)
    code = ccall((_c_symbol("ensure_mssql_driver_registered"), _lib()), Cint, (Cstring, Ref{Cint}), driver_name, out_available)
    _raise_if_error(code)
    return out_available[] != 0
end

function _normalize_remote(url::AbstractString)::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("normalize_git_remote"), _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), url, out_ptr)
    return _string_result(code, out_ptr)
end

function git_commit_info(dir::AbstractString="."; short_hash::Bool=true, script_path::AbstractString="")::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall(
        (_c_symbol("git_commit_info_json"), _lib()),
        Cint,
        (Cstring, Cint, Cstring, Ref{Ptr{UInt8}}),
        dir,
        short_hash ? 1 : 0,
        script_path,
        out_ptr,
    )
    return _string_result(code, out_ptr)
end

function caller_file_runtime(hint_path::AbstractString="")::String
    out_ptr = Ref{Ptr{UInt8}}(C_NULL)
    code = ccall((_c_symbol("caller_file_runtime"), _lib()), Cint, (Cstring, Ref{Ptr{UInt8}}), hint_path, out_ptr)
    return _string_result(code, out_ptr)
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
        ccall((_c_symbol("map_value_type"), _lib()), Cint, (Cstring, Cstring, Ref{Cint}, Ref{Ptr{UInt8}}), field_type, C_NULL, out_type, out_fmt)
    else
        ccall((_c_symbol("map_value_type"), _lib()), Cint, (Cstring, Cstring, Ref{Cint}, Ref{Ptr{UInt8}}), field_type, validation, out_type, out_fmt)
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

function get_redcap_choices_for_field(field_type::AbstractString, choices::Union{Nothing, AbstractString}=nothing)::String
    return get_redcap_choices_for_field_json(field_type, choices)
end

function parse_in_list_values(values_str::AbstractString)::String
    return parse_in_list_values_json(values_str)
end

function parse_check_constraint_values(constraint_def::AbstractString, column_name::AbstractString)::String
    return parse_check_constraint_values_json(constraint_def, column_name)
end

function get_check_constraint_values(constraint_def::AbstractString, column_name::AbstractString)::String
    return parse_check_constraint_values(constraint_def, column_name)
end

function map_value_type(field_type::AbstractString, validation::Union{Nothing, AbstractString}=nothing)
    return map_redcap_value_type(field_type, validation)
end

function parse_redcap_choices(choices::AbstractString)::String
    return parse_redcap_choices_json(choices)
end
