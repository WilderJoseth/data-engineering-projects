# Solution Design

## Purpose

This document describes the technical design of `DataOps_Control`, a metadata-driven control framework for data engineering projects.

## Target Architecture

`DataOps_Control` is organized into four responsibility-based schemas:

| Schema | Responsibility |
|---|---|
| `metadata` | Defines projects, databases, processes, controlled target tables, target columns, source-to-target mappings, process-to-table scope, and batch metadata managed by the framework. |
| `runtime` | Tracks execution runs and execution steps. Runtime execution is process-based. |
| `observability` | Stores validation results, reconciliation results, and technical error logs generated during execution. |
| `reference` | Stores controlled code values used by the framework, such as statuses and validation types. |

## Data Model

The data model is organized around four main areas:

| Area | Main tables |
|---|---|
| Metadata | `projects`, `project_databases`, `project_database_mappings`, `project_processes`, `project_tables`, `project_table_mappings`, `project_process_tables`, `project_columns`, `project_table_batches` |
| Runtime | `execution_runs`, `execution_steps` |
| Observability | `error_logs`, `validation_results`, `reconciliation_results` |
| Reference | `status_codes`, `validation_codes` |

![DataOps_Control Data Model](img/data_model_DataOps_Control.png)

### Core Model Interpretation

The framework uses project-based execution tracking, where `runtime.execution_runs` records the execution of each registered project. However, each project has at least one process, which is stored in `metadata.project_processes` and whose executions are recorded in `runtime.execution_steps`.

When a process represents a table-level load, the table is associated with that process through `metadata.project_process_tables`.

The model separates three different relationship concepts:

| Table | Relationship type | Meaning |
|---|---|---|
| `metadata.project_database_mappings` | Source-to-target database mapping | Identifies how data moves from one registered database or platform to another. |
| `metadata.project_table_mappings` | Source-to-target table mapping | Identifies source-to-target table lineage or data movement. |
| `metadata.project_process_tables` | Process-to-table execution scope | Identifies which controlled table is handled by a registered process. |

## Table Implementation Standards

### Naming Rules

| Object | Standard |
|---|---|
| Tables | Use `snake_case`, for example `metadata.project_database_mappings`. |
| Primary keys | `pk_[schema]_[table]` |
| Foreign keys | `fk_[schema]_[table]_[column]` |
| Unique constraints | `uk_[schema]_[table]_[column_or_purpose]` |
| Default constraints | `df_[schema]_[table]_[column]` |

### Key and Identifier Column Guidelines

- All tables should have a primary key constraint.
- Metadata tables should avoid auto-incremental IDs to keep identifiers predictable.
- Reference tables use manually assigned IDs because they are treated as framework constants.
- Runtime and observability tables should use auto-incremental IDs.

### Bridge Table Rules

Bridge tables use composite primary keys when the relationship itself is the entity.

Examples:

- `metadata.project_database_mappings`
- `metadata.project_table_mappings`
- `metadata.project_process_tables`

### Audit Columns

Common audit/control columns used across the model include:

| Column | Purpose | Type | Allow nulls | Default value |
|---|---|---|---|---|
| `created_at` | When the record was inserted. | DATETIME2 | No | SYSUTCDATETIME() |
| `created_by` | User or process that inserted the record. | VARCHAR(50) | No | USER_NAME() |
| `is_active` | Indicates whether the record is active in the target model. | BIT | No | 1 |

## Table Catalog

### metadata

#### Table summary

| Table | Description |
|---|---|
| `projects` | Registers data engineering projects managed by the framework. |
| `project_databases` | Registers databases, platforms, or logical data stores associated with each project. |
| `project_database_mappings` | Defines source-to-target database mappings. |
| `project_processes` | Defines logical processes and process hierarchy. |
| `project_tables` | Registers controlled target tables or managed objects. |
| `project_table_mappings` | Defines source-to-target table mappings. |
| `project_process_tables` | Associates controlled tables with the processes responsible for executing them. |
| `project_columns` | Stores target-side column metadata for registered tables. |
| `project_table_batches` | Defines batch slices for reloadable tables. |

#### Important columns

| Table | Column | Description |
|---|---|---|
| `project_databases` | `platform_type` | Identifies the technology or platform, such as Oracle, SQL Server, Azure SQL, Fabric Lakehouse, or Fabric Warehouse. |
| `project_databases` | `database_role` | Classifies the role of the database, such as source, target, operational, analytical, or control-related. |
| `project_database_mappings` | `database_source_id`, `database_target_id` | Defines database-level source-to-target relationships. |
| `project_processes` | `project_id` | Associates the process with a registered project. |
| `project_processes` | `parent_process_id` | Supports process hierarchy, such as parent process, subprocess, table load, or batch process. |
| `project_tables` | `schema_name` | Stores the schema of the registered controlled object. |
| `project_tables` | `is_fact_table` | Identifies analytical fact tables. |
| `project_tables` | `is_transactional_table` | Identifies transactional tables that may require incremental or batch processing. |
| `project_tables` | `batch_column_active` | Indicates whether the table supports batch-based processing. |
| `project_tables` | `rerun_required` | Marks a table for controlled reprocessing. |
| `project_table_mappings` | `table_source_id`, `table_target_id` | Defines table-level source-to-target relationships. |
| `project_process_tables` | `process_id`, `table_id` | Defines which controlled table is handled by a registered process. |
| `project_columns` | `is_nullable` | Supports metadata-driven not-null validation. |
| `project_columns` | `is_watermark` | Identifies columns used for incremental load logic. |
| `project_columns` | `is_reconciliation_column` | Identifies columns used in reconciliation metrics. |
| `project_table_batches` | `batch_column_name` | Identifies the column used to define the batch. |
| `project_table_batches` | `batch_value` | Stores the batch identifier, such as `202401`. |
| `project_table_batches` | `batch_start_value`, `batch_end_value` | Support range-based batch definitions. |
| `project_table_batches` | `rerun_required` | Marks a specific batch for controlled reprocessing. |

### runtime

#### Table summary

| Table | Description |
|---|---|
| `execution_runs` | Tracks project-level execution runs. |
| `execution_steps` | Tracks process-level execution steps. A process may represent a package, subprocess, table-level load, or batch-level activity. |

#### Important columns

| Table | Column | Description |
|---|---|---|
| `execution_runs` | `start_run_date`, `end_run_date` | Track the execution duration of a project run. |
| `execution_runs` | `status_code_id` | References the controlled status of the execution run. |
| `execution_runs` | `project_id` | Associates the run with a registered project. |
| `execution_steps` | `status_code_id` | References the controlled status of the execution step. |
| `execution_steps` | `execution_run_id` | Associates the step with a project execution run. |
| `execution_steps` | `project_process_id` | Links the runtime step to the defined process metadata. |

### observability

#### Table summary

| Table | Description |
|---|---|
| `error_logs` | Stores technical error records. |
| `reconciliation_results` | Stores reconciliation metrics generated during execution. |
| `validation_results` | Stores summary-level validation results. |

#### Important columns

| Table | Column | Description |
|---|---|---|
| `error_logs` | `error_source` | Identifies where the error came from, such as a package, task, stored procedure, or pipeline activity. |
| `error_logs` | `details` | Stores technical error details. |
| `error_logs` | `execution_step_id` | Links the error to the execution step where it occurred. |
| `reconciliation_results` | `metric_name` | Identifies the reconciliation metric, such as `ROW_COUNT`, `TOTAL_DUE`, or `SALES_AMOUNT`. |
| `reconciliation_results` | `reconciliation_key` | Identifies the reconciliation scope or grouping, such as `TOTAL`, `BATCH=2011-05`, or `TERRITORY=NORTHWEST`. |
| `reconciliation_results` | `reconciliation_side` | Identifies the side being measured, such as `SOURCE`, `TARGET`, `STAGING`, `WORK`, or `FINAL`. |
| `reconciliation_results` | `metric_value_decimal`, `metric_value_bigint` | Store decimal or integer reconciliation values. |
| `validation_results` | `validation_code_id` | References the controlled validation type. |
| `validation_results` | `affected_row_count` | Stores the number of rows affected by the validation result. |
| `validation_results` | `details` | Stores a summary of the validation result. |

### reference

#### Table summary

| Table | Description |
|---|---|
| `status_codes` | Stores controlled execution status values. |
| `validation_codes` | Stores controlled validation types and severity levels. |

#### Important columns

| Table | Column | Description |
|---|---|---|
| `status_codes` | `id` | Stable manually assigned status identifier used by runtime tables. |
| `status_codes` | `code` | Stores values such as `Pending`, `Running`, `Success`, `Failed`, `Skipped`, `RerunRequired`, or `Observed`. |
| `validation_codes` | `id` | Stable manually assigned validation identifier used by validation result records. |
| `validation_codes` | `code` | Stores validation identifiers such as `NOT_NULL`, `FK_CHECK`, or `DUPLICATE`. |
| `validation_codes` | `severity` | Classifies the validation impact, such as error, warning, or information. |

## Stored Procedure and Function Design

### Design Rules

| Rule | Description |
|---|---|
| Keep procedures focused | Each procedure should have one clear responsibility. |
| Use process-based runtime tracking | Runtime procedures create or update `execution_runs` and `execution_steps`. |
| Do not embed business reconciliation logic | Business-specific validation and reconciliation decisions belong to the process owner or project-specific procedures. |
| Use set-based inserts for observability results | `validation_results` and `reconciliation_results` may receive multiple rows per execution step, so they are loaded directly using set-based inserts. |
| Use generic procedures for single operational actions | Starting/ending runs, starting/ending steps, and logging technical errors are handled by reusable procedures. |

### Naming Rules

- Stored procedures should follow: `usp_[action]_[object_or_process]`.
- User-defined functions should follow: `ufn_[action]_[object_or_process]`.
- Exceptions may apply when a shorter or clearer name improves readability.

### Stored Procedure Catalog

| Object | Type | Purpose |
|---|---|---|
| `runtime.usp_start_execution_run` | Stored procedure | Creates an execution run with `Running` status and returns `execution_run_id`. |
| `runtime.usp_start_execution_step` | Stored procedure | Creates an execution step with `Running` status and returns `execution_step_id`. |
| `runtime.usp_end_execution_step` | Stored procedure | Updates an execution step with its final status and end date. |
| `runtime.usp_end_execution_run` | Stored procedure | Ends an execution run and derives the final run status from its execution steps. |
| `observability.usp_log_error` | Stored procedure | Inserts a technical error record for an execution step. |
| `metadata.ufn_list_project_processes_tables` | Inline table-valued function | Lists active child processes and associated controlled tables for a parent process. |
