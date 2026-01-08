# Synapse Dedicated DW → Microsoft Fabric DW Migration (Medallion + Control Plane)

This project demonstrates a practical data warehouse migration from Azure Synapse Dedicated SQL Pool (source DW) to Microsoft Fabric Warehouse (target DW), using a medallion-style processing flow (Bronze → Silver → Gold) and an external control plane for operational metadata.

The solution is designed to be:

* Re-runnable / idempotent
* Observable (run tracking, step logs, row counts)
* Scalable by partition for large fact tables (year-based export/load)

## 1. Architecture

The project consists of three main components:

* **Azure SQL Database**: control plane that enables run tracking and centralized logging.
* **Azure Synapse Dedicated SQL Pool**: data source (AdventureWorksDW2022).
* **Microsoft Fabric**: data destination.

![Data Processing Design](docs/img/data_processing_design.png)

## 2. About data

This project uses the sample data warehousing: AdventureWorksDW2022, which was loaded to Synapse dedicated pool.

## 3. Workflow

### 3.1. Azure SQL Database

A dedicated Azure SQL database is used to store process control and operational metadata, decoupled from the analytical data stored in Fabric.

This control layer provides:

* Auditability of pipeline executions.
* Run tracking across Synapse and Fabric components.
* Centralized logging.

| Table | Description |
|--------|--------------|
| **projects** | stores all data engineering projects, but only one is used at the time. For this project is id = 1 |
| **runs** | stores all main pipeline executions. For this project there are two: AdventureWorksDW2022 - Synapse and AdventureWorksDW2022 - Fabric |
| **sub_runs** | stores all sub pipeline executions. For example: extract data from one table in bronze layer |
| **logs** | stores all messages, metrics, and error information |
| **project_tables** | stores all tables that are part of the migration process, where only active ones are processed |
| **validation_rules** | stores metadata information about each column of the structured data, in order to be in validation process |
| **fact_table_years** | stores years of a fact, in order to be used for filtering and partition |

![Azure SQL Diagram](docs/img/azure_sql_diagram.png)

### 3.2. Azure Synapse Dedicated SQL Pool

The goal of this project is to migrate data in Synapse to Fabric, so AdventureWorksDW2022 database was created in Synapse Dedicated Pool, in order to be used as a data source.

In Synapse, the project copy data from tables to parquet files, where there is a file per dimension table. In case of fact tables, the data was partion by calendar year.

#### 3.2.1. Main pipeline

This is the started pipeline.

Steps:

* **Start process**: register a new pipeline execution in dbo.runs table (Synapse and AdventureWorksDW2022).
* **Get tables**: get tables from dbo.project_tables, which are part of this project.
* **ForEach**: execute a pipeline by table, where there are two workflows: dimension and fact tables.
* **End process**: update state of pipeline execution to COMPLETED.

![Synapse Main Pipeline](docs/img/synapse_main_pipeline.png)

Run executions:

![Synapse Pipeline Execution](docs/img/synapse_pipeline_execution.png)

Sub run executions:

![Synapse Sub Pipeline Execution](docs/img/synapse_sub_pipeline_execution.png)

#### 3.2.2. Dimension pipeline

This pipeline extract data for dimension tables.

Steps:

* **Start sub process**: register a new pipeline execution in dbo.sub_runs table.
* **Delete previous extraction**: delete files from previous executions.
* **Extract data**: copy data from dedicated table to a parquet file.
* **End sub process**: update state of pipeline execution to COMPLETED.

![Synapse Dim Pipeline](docs/img/synapse_dim_pipeline.png)

#### 3.2.3. Fact pipeline

This pipeline extract data for fact tables.

Steps:

* **Start sub process**: register a new pipeline execution in dbo.sub_runs table.
* **Delete previous extraction**: delete files from previous executions.
* **Get year partitions**: get calendar year for current fact table.
* **ForEach partition**: copy data from dedicated table to a parquet file by year.
* **End sub process**: update state of pipeline execution to COMPLETED.

![Synapse Fact Pipeline](docs/img/synapse_fact_pipeline.png)

### 3.3. Microsoft Fabric

This is the destination part of the migration process, where final data is stored in Data Warehouse layer, meanwhile there are copies in Lakehouse for bronze and silver data.

#### 3.3.1. Main pipeline

This is the started pipeline.

Steps:

* **Start process**: register a new pipeline execution in dbo.runs table (Fabric and AdventureWorksDW2022).
* **Extract validation rules Azure**: extract data from dbo.validation_rules (Azure SQL) and load into a delta table in Lakehouse with the same name.
* **Pipeline bronze process**: bronze process.
* **Pipeline silver processe**: silver process.
* **Pipeline dw staging process**: data warehouse staging process.
* **Pipeline dw production process**: data warehouse production process.
* **End sub process**: update state of pipeline execution to COMPLETED.

![Fabric Main Pipeline](docs/img/fabric_main_pipeline.png)

#### 3.3.2. Bronze dimension pipeline

This pipeline orchestrates bronze process.

Steps:

* **Get tables**: get tables to process.
* **ForEach tables**: call bronze pipelines.

![Fabric Bronze Pipeline](docs/img/fabric_bronze_pipeline.png)

#### 3.3.3. Bronze dimension pipeline

This pipeline extract data for dimension tables, by reading parquet files using PySpark and storing data into delta tables (bronze schema).

Steps:

* **Start sub process**: register a new pipeline execution in dbo.sub_runs table.
* **Notebook bronze layer**: bronze process using PySpark. There is only one notebook for all dimension tables, so it uses parameters to identify each table.
* **End sub process**: update state of pipeline execution to COMPLETED.

![Fabric Bronze Dim Pipeline](docs/img/fabric_bronze_dim_pipeline.png)

#### 3.3.4. Bronze fact pipeline

This pipeline extract data for fact tables, by reading parquet files using PySpark and storing data into delta tables (bronze schema). However, the execution is done by table and year partition.

Steps:

* **Get year partitions**: get calendar year for current fact table.
* **Start sub process**: register a new pipeline execution in dbo.sub_runs table.
* **Notebook bronze layer**: bronze process using PySpark. There is only one notebook for all fact tables, so it uses parameters to identify each table.
* **End sub process**: update state of pipeline execution to COMPLETED.

![Fabric Bronze Fact Pipeline](docs/img/fabric_bronze_fact_pipeline.png)

#### 3.3.5. Silver dimension pipeline

This pipeline orchestrates silver process.

* **Get tables**: get tables to process.
* **Filter only dimension tables**: filter dimension tables.
* **ForEach dimension tables**: call silver pipelines for dimension and fact tables.
* **Filter only fact tables**: filter fact tables.
* **ForEach fact tables**: call silver pipelines for fact and fact tables.

![Fabric Silver Pipeline](docs/img/fabric_silver_pipeline.png)

#### 3.3.6. Silver dimension pipeline

This pipeline extract, clean and transform data for dimension tables, by using PySpark and storing data into delta tables (silver schema).

Steps:

* **Start sub process**: register a new pipeline execution in dbo.sub_runs table.
* **Notebook silver layer**: silver process using PySpark. There is one notebook per table, in order to have custom validations depending on the table.
* **End sub process**: update state of pipeline execution to COMPLETED.

![Fabric Silver Dim Pipeline](docs/img/fabric_silver_dim_pipeline.png)

#### 3.3.7. Silver dimension pipeline

This pipeline extract, clean and transform data for fact tables, by using PySpark and storing data into delta tables (silver schema). However, the execution is done by table and year partition.

Steps:

* **Get year partitions**: get calendar year for current fact table.
* **Start sub process**: register a new pipeline execution in dbo.sub_runs table.
* **Notebook silver layer**: silver process using PySpark. There is one notebook per table, in order to have custom validations depending on the table. But, the execution is by year partition.
* **End sub process**: update state of pipeline execution to COMPLETED.

![Fabric Silver Fact Pipeline](docs/img/fabric_silver_fact_pipeline.png)

#### 3.3.8. Data Warehouse staging pipeline

This pipeline orchestrates data warehouse staging process.

Steps:

* **Get tables**: get tables to process.
* **ForEach tables**: call staging pipelines for dimension and fact tables.
* **Load DimDate**: create date data based on calendar years ingested into fact tables.

![Fabric DW Staging Pipeline](docs/img/fabric_dw_staging_pipeline.png)

#### 3.3.9. Data Warehouse staging dimension pipeline

This pipeline load data for dimension tables into data warehouse (staging schema).

Steps:

* **Start sub process**: register a new pipeline execution in dbo.sub_runs table.
* **Truncate staging table**: delete data from previous executions.
* **Load staging table**: read data from Lakehouse and load it into Data Warehouse using SQL stored procedures. There is one stored procedure per table.
* **End sub process**: update state of pipeline execution to COMPLETED.

![Fabric DW Staging Dim Pipeline](docs/img/fabric_dw_staging_dim_pipeline.png)

#### 3.3.10. Data Warehouse staging fact pipeline

This pipeline load data for fact tables into data warehouse (staging schema). However, the execution is done by table and year partition.

Steps:

* **Get year partitions**: get calendar year for current fact table.
* **Start sub process**: register a new pipeline execution in dbo.sub_runs table.
* **Remove data year staging table**: delete data from previous executions.
* **Load staging table**: read data from Lakehouse and load it into Data Warehouse using SQL stored procedures. There is one stored procedure per table.
* **End sub process**: update state of pipeline execution to COMPLETED.

![Fabric DW Staging Fact Pipeline](docs/img/fabric_dw_staging_fact_pipeline.png)

#### 3.3.11. Data Warehouse production pipeline

This pipeline orchestrates data warehouse production process.

Steps:

* **Get tables**: get tables to process.
* **Filter only dimension tables**: filter dimension tables.
* **ForEach dimension tables**: call production pipelines for dimension and fact tables.
* **Load DimDate**: load date data.
* **Filter only fact tables**: filter fact tables.
* **ForEach fact tables**: call production pipelines for fact and fact tables.

![Fabric DW Production Pipeline](docs/img/fabric_dw_production_pipeline.png)

#### 3.3.12. Data Warehouse production dimension pipeline

This pipeline load data for dimension tables into data warehouse (production schema).

Steps:

* **Start sub process**: register a new pipeline execution in dbo.sub_runs table.
* **Load production table**: read data from staging schema and load it into production Data Warehouse using SQL stored procedures. There is one stored procedure per table. Additionally, it uses slowly changing dimension type 2 to load data.
* **End sub process**: update state of pipeline execution to COMPLETED.

![Fabric DW Production Dim Pipeline](docs/img/fabric_dw_production_dim_pipeline.png)

#### 3.3.13. Data Warehouse production dimension pipeline

This pipeline load data for fact tables into data warehouse (production schema). However, the execution is done by table and year partition.

Steps:

* **Get year partitions**: get calendar year for current fact table.
* **Start sub process**: register a new pipeline execution in dbo.sub_runs table.
* **Load staging table**: read data from Lakehouse and load it into Data Warehouse using SQL stored procedures. There is one stored procedure per table. Additionally, data from previous execution is remove by year.
* **End sub process**: update state of pipeline execution to COMPLETED.

![Fabric DW Production Fact Pipeline](docs/img/fabric_dw_production_fact_pipeline.png)


