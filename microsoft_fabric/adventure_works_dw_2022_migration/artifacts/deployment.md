# Deployment steps

### Prerequisites
- Azure SQL Database (control plane)
- Azure Synapse Dedicated SQL Pool (source warehouse)
- Microsoft Fabric Workspace with:
  - Lakehouse
  - Warehouse
  - Pipelines enabled
- Storage location for Parquet exports (Synapse extract output)
- Permissions:
  - Create/execute SQL objects (Azure SQL + Synapse + Fabric Warehouse)
  - Read/write permissions to the export storage location
  - Fabric permission to create tables in Lakehouse/Warehouse and run pipelines

### Configuration (values to update)
- Azure SQL DB name: `control_db`
- Fabric Lakehouse name: `lakehouse_main`
- Fabric Warehouse name: `warehouse_main`
- Export folder pattern (Synapse → Parquet): `.../<table_name>/` and for fact: `.../FactFinance/year=<YYYY>/`
- Pipeline parameters used across stages:
  - `run_id`
  - `process_date`
  - `table_name`
  - `year` (FactFinance only)

## 1. Azure SQL DB - control_db

Execute T-SQL query artifacts/azure_sql/01_query_create_objects.sql, which creates the following tables:

* dbo.projects
* dbo.runs
* dbo.sub_runs
* dbo.logs
* dbo.project_tables
* dbo.stages
* dbo.validation_rules
* dbo.fact_table_years

Execute T-SQL query artifacts/azure_sql/02_query_create_storeds.sql, which creates the following objects:

* dbo.usp_start_run
* dbo.usp_end_run
* dbo.usp_start_sub_run
* dbo.usp_end_sub_run
* dbo.usp_list_validation_rules
* dbo.usp_list_tables_project
* dbo.usp_list_years_fact_table_to_process

Execute T-SQL query artifacts/azure_sql/03_query_insert_data.sql to load data.

## 2. Synapse

The project includes a pipeline to load AdventureWorksDW2022 database (on-premise) into a dedicated pool, however it is optional. The idea is to have a database in Synapse.

Objects to load into Synapse:

1. Scripts:
    * artifacts/synapse/sql/01_query_create_objects.sql
    * artifacts/synapse/sql/02_query_create_storeds.sql
2. Pipelines:
    * artifacts/pipelines/pl_AdventureWorksDW2022_on_premise_support_live.zip

For migration, the project starts with the following objects:

1. artifacts/pipelines/pl_AdventureWorksDW2022_extract_dim_support_live.zip
2. artifacts/pipelines/pl_AdventureWorksDW2022_extract_fact_support_live.zip
3. artifacts/pipelines/pl_AdventureWorksDW2022_extract_main_support_live.zip

## 3. Fabric

### 3.1. Lakehouse

1. Create lakehouse lakehouse_main.
2. Execute notebook artifacts/fabric/notebooks/01_notebook_environment.ipynb, which creates the following objects
    * **Schemas**: control, bronze and silver.
    * **Delta tables**:
        * control.validation_rules
        * control.logs
        * bronze.FactFinance
        * bronze.DimOrganization
        * bronze.DimDepartmentGroup
        * bronze.DimScenario
        * bronze.DimAccount
        * silver.FactFinance
        * silver.DimOrganization
        * silver.DimDepartmentGroup
        * silver.DimScenario
        * silver.DimAccount

### 3.2. Warehouse

1. Create warehouse warehouse_main.
2. Execute T-SQL query artifacts/fabric/sql/01_query_create_objects.sql, which creates the following objects:
    * **Schemas**: staging and production.
    * **Tables**:
        * staging.FactFinance
        * staging.DimDate
        * staging.DimOrganization
        * staging.DimDepartmentGroup
        * staging.DimScenario
        * staging.DimAccount
        * production.FactFinance
        * production.DimDate
        * production.DimOrganization
        * production.DimDepartmentGroup
        * production.DimScenario
        * production.DimAccount
3. Execute T-SQL query artifacts/fabric/sql/02_query_create_sp.sql, which creates the following storeds:
    * staging.usp_load_FactFinance
    * staging.usp_load_DimDate
    * staging.usp_load_DimOrganization
    * staging.usp_load_DimDepartmentGroup
    * staging.usp_load_DimScenario
    * staging.usp_load_DimAccount
    * production.usp_load_DimDate
    * production.usp_load_DimOrganization
    * production.usp_load_DimDepartmentGroup
    * production.usp_load_DimScenario
    * production.usp_load_DimAccount
    * production.usp_load_FactFinance

### 3.3. Pipelines

1. Restore the pipeline: artifacts/fabric/pipelines/02_pl_etl_bronze_dimension_table.zip
2. Restore the pipeline: artifacts/fabric/pipelines/02_pl_etl_bronze_fact_table.zip
3. Restore the pipeline: artifacts/fabric/pipelines/02_pl_etl_bronze.zip
4. Restore the pipeline: artifacts/fabric/pipelines/03_pl_etl_silver_dimension_table.zip
5. Restore the pipeline: artifacts/fabric/pipelines/03_pl_etl_silver_fact_table.zip
6. Restore the pipeline: artifacts/fabric/pipelines/03_pl_etl_silver.zip
7. Restore the pipeline: artifacts/fabric/pipelines/04_pl_dw_staging_dimension_table.zip
8. Restore the pipeline: artifacts/fabric/pipelines/04_pl_dw_staging_fact_table.zip
9. Restore the pipeline: artifacts/fabric/pipelines/04_pl_dw_staging.zip
10. Restore the pipeline: artifacts/fabric/pipelines/05_pl_dw_production_dimension_table.zip
11. Restore the pipeline: artifacts/fabric/pipelines/05_pl_dw_production_fact_table.zip
12. Restore the pipeline: artifacts/fabric/pipelines/05_pl_dw_production.zip
13. Restore the pipeline: artifacts/fabric/pipelines/01_pl_main.zip
