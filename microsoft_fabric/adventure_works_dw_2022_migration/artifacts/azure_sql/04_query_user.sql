
----------------- START roles -----------------
CREATE ROLE etl_executor;

GRANT EXECUTE ON dbo.usp_start_run TO etl_executor;

GRANT EXECUTE ON dbo.usp_end_run TO etl_executor;

GRANT EXECUTE ON dbo.usp_start_sub_run TO etl_executor;

GRANT EXECUTE ON dbo.usp_end_sub_run TO etl_executor;

GRANT EXECUTE ON dbo.usp_list_validation_rules TO etl_executor;

GRANT EXECUTE ON dbo.usp_list_tables_project TO etl_executor;

GRANT EXECUTE ON dbo.usp_list_years_fact_table_to_process TO etl_executor;
----------------- END roles -----------------


----------------- START connection Synapse -----------------
CREATE USER [ws-synapse-projects] FROM EXTERNAL PROVIDER;

ALTER ROLE etl_executor ADD MEMBER [ws-synapse-projects];
----------------- END connection Synapse -----------------


----------------- START connection Fabric -----------------
CREATE USER [ws_adventure_works_dw_2022_migration] FROM EXTERNAL PROVIDER;

ALTER ROLE etl_executor ADD MEMBER [ws_adventure_works_dw_2022_migration];
----------------- END connection Fabric -----------------


