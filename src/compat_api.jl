# Compatibility symbols for parity with AHRI_TRE.jl function surface.
# Where possible we provide aliases; otherwise a clear not-implemented error.

if !isdefined(@__MODULE__, :DatabaseFlavour)
    @enum DatabaseFlavour begin
        MSSQLFlavour = 1
        PostgreSQLFlavour = 2
        DuckDBFlavour = 3
        SQLiteFlavour = 4
        MySQLFlavour = 5
    end
end

if !isdefined(@__MODULE__, :ColumnInfo)
    Base.@kwdef struct ColumnInfo
        name::String = ""
        sql_type::String = ""
        tre_type::Int = 0
        nullable::Bool = true
        comment::Union{Nothing, String} = nothing
    end
end

if !isdefined(@__MODULE__, :_strip_html)
    _strip_html(text::AbstractString)::String = strip_html(text)
end

if !isdefined(@__MODULE__, :_normalize_remote)
    function _normalize_remote(remote::AbstractString)::String
        out = strip(String(remote))
        out = replace(out, r"\.git$" => "")
        out = replace(out, "git@github.com:" => "https://github.com/")
        out = replace(out, "git@gitlab.com:" => "https://gitlab.com/")
        out = replace(out, "git@bitbucket.org:" => "https://bitbucket.org/")
        return out
    end
end

if !isdefined(@__MODULE__, :sha256_digest_hex)
    sha256_digest_hex(path::AbstractString)::String = sha256_file_hex(path)
end

if !isdefined(@__MODULE__, :verify_sha256_digest)
    verify_sha256_digest(path::AbstractString, expected_hex::AbstractString)::Bool = verify_sha256_file(path, expected_hex)
end

if !isdefined(@__MODULE__, :quote_identifier)
    quote_identifier(name::AbstractString)::String = string('"', replace(String(name), '"' => "\"\""), '"')
end

if !isdefined(@__MODULE__, :quote_ident)
    quote_ident(name::AbstractString)::String = quote_identifier(name)
end

if !isdefined(@__MODULE__, :get_check_constraint_values)
    get_check_constraint_values(constraint_def::AbstractString, column_name::AbstractString)::String = parse_check_constraint_values(constraint_def, column_name)
end

const _requested_api_symbols = Symbol[
    :add_datastore_orcid,
    :add_domain,
    :add_entity,
    :add_entity_relation,
    :add_study,
    :add_study_domain,
    :add_transformation,
    :add_transformation_input,
    :add_transformation_output,
    :add_variable,
    :attach_datafile,
    :attach_datafile_version,
    :caller_file_runtime,
    :closedatastore,
    :connect_mssql,
    :convert_missing_to_string,
    :create_asset,
    :create_dataset_meta,
    :create_duckdb_table_sql,
    :create_lake_database,
    :create_store_database,
    :create_transformation,
    :createassets,
    :createdatastore,
    :createentities,
    :createmapping,
    :createstudies,
    :createtransformations,
    :createvariables,
    :dataset_to_arrow,
    :dataset_to_csv,
    :dataset_to_dataframe,
    :dataset_variables,
    :emptydir,
    :ensure_mssql_driver_registered,
    :ensure_vocabulary,
    :find_mssql_driver_in_directory,
    :find_system_odbc_driver,
    :get_asset,
    :get_assetversions,
    :get_code_table_vocabulary,
    :get_column_comment,
    :get_column_type_info,
    :get_datafile,
    :get_datafile_meta,
    :get_datafile_metadata,
    :get_datafilename,
    :get_datalake_file_path,
    :get_dataset,
    :get_dataset_variables,
    :get_dataset_versions,
    :get_datasetname,
    :get_domain,
    :get_domain_variables,
    :get_domainentities,
    :get_domainrelations,
    :get_domains,
    :get_eav_variable_names,
    :get_entity,
    :get_entityrelation,
    :get_enum_values,
    :get_foreign_key_reference,
    :get_latest_version,
    :get_namedkey,
    :get_original_column_type,
    :get_query_columns,
    :get_studies,
    :get_study,
    :get_study_assets,
    :get_study_datafiles,
    :get_study_datasets,
    :get_study_domains,
    :get_study_variables,
    :get_study_variables_df,
    :get_studyid,
    :get_table,
    :get_table_columns,
    :get_variable,
    :get_variable_id,
    :get_vocabularies,
    :get_vocabulary,
    :git_commit_info,
    :ingest_file,
    :ingest_file_version,
    :ingest_redcap_project,
    :initstudytypes,
    :initvalue_types,
    :insertdata,
    :insertwithidentity,
    :is_code_table,
    :is_enum_type,
    :julia_type_to_sql_string,
    :lines,
    :list_domainentities,
    :list_domainrelations,
    :list_study_assets_df,
    :list_study_transformations,
    :load_query,
    :make_asset,
    :makeparams,
    :prepare_datafile,
    :prepareinsertstatement,
    :prepareselectstatement,
    :quote_sql_str,
    :read_dataset,
    :redcap_export_eav,
    :redcap_fields,
    :redcap_metadata,
    :redcap_post,
    :redcap_post_tofile,
    :redcap_project_info,
    :redcap_project_info_df,
    :register_datafile,
    :register_dataset,
    :register_redcap_datadictionary,
    :save_asset_version,
    :save_dataset_variables,
    :save_version,
    :savedataframe,
    :selectdataframe,
    :set_version,
    :sql_meta,
    :sql_to_dataset,
    :table_exists,
    :table_has_primary_key,
    :transaction_begin,
    :transaction_commit,
    :transaction_rollback,
    :transform_eav_to_dataset,
    :transform_eav_to_table,
    :tre_type_to_duckdb_sql,
    :update_domain,
    :update_variable,
    :updatevalues,
    :upsert_entity,
    :upsert_entityrelation,
    :upsert_study,
    :upsert_variable,
    :vocabulary_items,
    :wrap_query_for_metadata,
]

for sym in _requested_api_symbols
    if !isdefined(@__MODULE__, sym)
        @eval function $(sym)(args...; kwargs...)
            error("Function $(string($(QuoteNode(sym)))) is not implemented in this AHRI_TRE_C wrapper build.")
        end
    end
end
