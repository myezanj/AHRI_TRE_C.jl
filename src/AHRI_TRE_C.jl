module AHRI_TRE_C

export load_library!, version, sha256_file_hex, verify_sha256_file, path_to_file_uri, file_uri_to_path
export is_ncname, to_ncname, strip_html, infer_label_from_field_name
export get_redcap_choices_for_field_json, get_redcap_choices_for_field
export parse_flavour, map_sql_type_to_tre, extract_table_from_sql
export parse_in_list_values_json, parse_in_list_values
export parse_check_constraint_values_json, parse_check_constraint_values, get_check_constraint_values
export map_redcap_value_type, map_value_type
export parse_redcap_choices_json, parse_redcap_choices

# Compatibility/API-surface exports requested for parity with AHRI_TRE.jl.
export ColumnInfo, DatabaseFlavour
export _normalize_remote, _strip_html
export add_datastore_orcid, add_domain, add_entity, add_entity_relation, add_study, add_study_domain
export add_transformation, add_transformation_input, add_transformation_output, add_variable
export attach_datafile, attach_datafile_version, caller_file_runtime, closedatastore, connect_mssql
export convert_missing_to_string, create_asset, create_dataset_meta, create_duckdb_table_sql
export create_lake_database, create_store_database, create_transformation
export createassets, createdatastore, createentities, createmapping, createstudies
export createtransformations, createvariables
export dataset_to_arrow, dataset_to_csv, dataset_to_dataframe, dataset_variables
export emptydir, ensure_mssql_driver_registered, ensure_vocabulary
export find_mssql_driver_in_directory, find_system_odbc_driver
export get_asset, get_assetversions, get_code_table_vocabulary
export get_column_comment, get_column_type_info, get_datafile, get_datafile_meta, get_datafile_metadata
export get_datafilename, get_datalake_file_path, get_dataset, get_dataset_variables, get_dataset_versions
export get_datasetname, get_domain, get_domain_variables, get_domainentities, get_domainrelations, get_domains
export get_eav_variable_names, get_entity, get_entityrelation, get_enum_values, get_foreign_key_reference
export get_latest_version, get_namedkey, get_original_column_type, get_query_columns
export get_studies, get_study, get_study_assets, get_study_datafiles, get_study_datasets
export get_study_domains, get_study_variables, get_study_variables_df, get_studyid
export get_table, get_table_columns, get_variable, get_variable_id
export get_vocabularies, get_vocabulary, git_commit_info
export ingest_file, ingest_file_version, ingest_redcap_project
export initstudytypes, initvalue_types, insertdata, insertwithidentity
export is_code_table, is_enum_type, julia_type_to_sql_string, lines
export list_domainentities, list_domainrelations, list_study_assets_df, list_study_transformations
export load_query, make_asset, makeparams
export prepare_datafile, prepareinsertstatement, prepareselectstatement
export quote_ident, quote_identifier, quote_sql_str
export read_dataset
export redcap_export_eav, redcap_fields, redcap_metadata, redcap_post, redcap_post_tofile
export redcap_project_info, redcap_project_info_df
export register_datafile, register_dataset, register_redcap_datadictionary
export save_asset_version, save_dataset_variables, save_version
export savedataframe, selectdataframe, set_version
export sha256_digest_hex, sql_meta, sql_to_dataset
export table_exists, table_has_primary_key
export transaction_begin, transaction_commit, transaction_rollback
export transform_eav_to_dataset, transform_eav_to_table, tre_type_to_duckdb_sql
export update_domain, update_variable, updatevalues
export upsert_entity, upsert_entityrelation, upsert_study, upsert_variable
export verify_sha256_digest, vocabulary_items, wrap_query_for_metadata

include("runtime.jl")
include("api.jl")
include("compat_api.jl")

end
