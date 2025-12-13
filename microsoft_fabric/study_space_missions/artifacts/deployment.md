# Deployment steps

## 1. Azure SQL DB - control_db

Execute T-SQL query sql/azure_sql_database/01_query_control.sql, which creates the following objects:

1. Schema: study_space_missions_db
2. Tables:
    * study_space_missions_db.runs
    * study_space_missions_db.sub_runs
    * study_space_missions_db.logs
    * study_space_missions_db.validation_rules
3. Storeds:
    * study_space_missions_db.usp_start_run
    * study_space_missions_db.usp_end_run
    * study_space_missions_db.usp_start_sub_run
    * study_space_missions_db.usp_end_sub_run
    * study_space_missions_db.register_log
4. Load study_space_missions_db.validation_rules

The query asumes that database **control_db** is already created.

## 2. Fabric

### 2.1. Lakehouse

1. Create lakehouse **lakehouse_main**.
2. Execute notebook **notebooks/01_notebook_environment.ipynb**, which creates the following objects:
    * Schemas: control, bronze and silver.
    * Delta tables: control.logs, control.validation_rules, bronze.missions and silver.missions.
3. Create folders: archive, invalid and raw.

### 2.2. Warehouse

1. Create warehouse **warehouse_main**.
2. Execute T-SQL query warehouse/01_query_tables.sql, which creates the following objects:
    * Schemas: staging and production.
    * Tables: staging.fact_missions and production.fact_missions.
3. Execute T-SQL query warehouse/02_query_procedures.sql, which creates the following objects:
    * Storeds:
        * staging.usp_clean_tables
        * staging.usp_load_fact_missions
        * production.usp_clean_tables
        * production.usp_load_fact_missions

### 2.3. Pipelines

#### 2.3.1. 01_pl_main

There are the following objects:

* **Lookup**: start process procedure.
* **Set variables**: get id run
* **Get Metadata**: explore data source files.
* **If Condition**:
    * **True**: execute pipeline 02_pl_sub_main.
    * **False**: register log control.
* **Stored procedures**: complete process.

There are the following parameters:

* **in_parameter_path_source**: raw data source (synapse datastorage).
* **in_parameter_path_destination**: lakehouse folder raw.
* **in_parameter_is_initial**: if it is initial or incremental load.
* **in_parameter_path_archive**: lakehouse folder archive.

#### 2.3.2. 02_pl_sub_main

There are the following objects:

* **Get Metadata**: get list of files.
* **Copy data**:
    * Load validation rules.
    * Copy to archive destination.
* **ForEach**: copy files to lakehouse raw folder.
* **If Condition**:
    * **True**: execute pipeline 03_pl_etl_medallion + 04_pl_gold_warehouse + truncate tables process (notebooks/02_notebook_initial_load_prep.ipynb).
    * **False**: execute pipeline 03_pl_etl_medallion + 04_pl_gold_warehouse.
* **Delete data**: delete raw files.

There are the following parameters:

* **in_parameter_path_source**: raw data source (synapse datastorage).
* **in_parameter_path_destination**: lakehouse folder raw.
* **in_parameter_is_initial**: if it is initial or incremental load.
* **in_parameter_path_archive**: lakehouse folder archive.
* **in_parameter_run_id**: id run.
* **in_parameter_process_date**: process date run.

#### 2.3.3. 03_pl_etl_medallion

There are the following objects:

* **Stored procedure**: start and complete procedure.
* **Notebooks**: notebooks/04_notebook_bronze_layer.ipýnb and notebooks/05_notebook_silver_layer.ipýnb
* **Copy data**: load logs back to Azure SQL.
* Set varibles.

There are the following parameters:

* **in_parameter_run_id**: id run.
* **in_parameter_process_date**: process date run.

#### 2.3.4. 04_pl_gold_warehouse

There are the following objects:

* **Stored procedure**:
    * Start and complete sub process.
    * Clean staging tables.
    * Load staging tables.
    * Load production tables.
    
There are the following parameters:

* **in_parameter_run_id**: id run.
* **in_parameter_process_date**: process date run.
