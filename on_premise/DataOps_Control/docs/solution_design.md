# Solution Design

## Purpose

This document describes the technical design of `DataOps_Control`, a metadata-driven control framework for data engineering projects.

## Schema Organization

`DataOps_Control` is organized into four responsibility-based schemas:

| Schema | Responsibility |
|---|---|
| `metadata` | Defines projects, databases, processes, controlled target tables, target columns, source-to-target mappings, process-to-table scope, and batch metadata managed by the framework. |
| `runtime` | Tracks execution runs and execution steps. |
| `observability` | Stores validation results, reconciliation results, and technical error logs generated during execution. |
| `reference` | Stores controlled code values used by the framework, such as statuses and validation types. |

## Data Model

| Area | Main tables |
|---|---|
| Metadata | `projects`, `project_databases`, `project_database_mappings`, `project_processes`, `project_tables`, `project_table_mappings`, `project_process_tables`, `project_columns`, `project_table_batches` |
| Runtime | `execution_runs`, `execution_steps` |
| Observability | `error_logs`, `validation_results`, `reconciliation_results` |
| Reference | `status_codes`, `validation_codes` |

This model should be read from metadata to runtime. The `metadata` schema defines what can be executed, the `runtime` schema records what was executed, the `observability` schema stores execution evidence, and the `reference` schema standardizes controlled codes used by the framework.

![DataOps_Control Data Model](img/data_model_DataOps_Control.png)

## Tables

### Table Implementation Standards

#### Naming Rules

| Object | Standard |
|---|---|
| Tables | Use `snake_case`, for example `metadata.project_database_mappings`. |
| Primary keys | `pk_[schema]_[table]` |
| Foreign keys | `fk_[schema]_[table]_[column]` |
| Unique constraints | `uk_[schema]_[table]_[column_or_purpose]` |
| Default constraints | `df_[schema]_[table]_[column]` |

#### Key and Identifier Column Guidelines

- All tables should have a primary key constraint.
- Metadata tables should avoid auto-incremental IDs to keep identifiers predictable.
- Reference tables use manually assigned IDs because they are treated as framework constants.
- Runtime and observability tables should use auto-incremental IDs.

#### Bridge Table Rules

Bridge tables use composite primary keys when the relationship itself is the entity.

Examples:

- `metadata.project_database_mappings`
- `metadata.project_table_mappings`
- `metadata.project_process_tables`

#### Audit Columns

Common audit/control columns used across the model include:

| Column | Purpose | Type | Allow nulls | Default value |
|---|---|---|---|---|
| `created_at` | When the record was inserted. | DATETIME2 | No | SYSUTCDATETIME() |
| `created_by` | User or process that inserted the record. | VARCHAR(50) | No | USER_NAME() |
| `is_active` | Indicates whether the record is active in the model. | BIT | No | 1 |

### Table Catalog

#### metadata

##### Table summary

| Table | Description |
|---|---|
| `projects` | Registers data engineering projects managed by the framework. |
| `project_databases` | Registers databases, platforms, or logical data stores associated with each project. |
| `project_database_mappings` | Defines source-to-target database mappings. |
| `project_processes` | Defines logical processes and process hierarchy. |
| `project_tables` | Registers source tables, target tables, or managed objects when they are needed for mapping, execution control, batch filtering, validation, or reconciliation. |
| `project_table_mappings` | Defines source-to-target table mappings. |
| `project_process_tables` | Associates controlled tables with the processes responsible for executing them. |
| `project_columns` | Stores column metadata for registered tables. |
| `project_table_batches` | Defines batch slices for reloadable tables. |

##### Important columns

| Table | Column | Description |
|---|---|---|
| `project_databases` | `platform_type` | Identifies the technology or platform, such as Oracle, SQL Server, Azure SQL, Fabric Lakehouse, or Fabric Warehouse. |
| `project_databases` | `database_role` | Classifies the role of the database, such as source, target, operational, analytical, or control-related. |
| `project_database_mappings` | `database_source_id`, `database_target_id` | Defines database-level source-to-target relationships. |
| `project_processes` | `project_id` | Associates the process with a registered project. |
| `project_processes` | `parent_process_id` | Supports process hierarchy, such as parent process, subprocess, table load, or batch process. |
| `project_tables` | `schema_name` | Stores the schema of the registered controlled object. For target tables, this usually represents the final target schema. |
| `project_tables` | `is_fact_table` | Identifies analytical fact tables. |
| `project_tables` | `is_transactional_table` | Identifies transactional tables that may require incremental or batch processing. |
| `project_tables` | `batch_column_active` | Indicates whether the table supports batch-based processing. |
| `project_tables` | `execution_required` | Marks a table as requiring execution. |
| `project_table_mappings` | `table_source_id`, `table_target_id` | Defines table-level source-to-target relationships. |
| `project_process_tables` | `process_id`, `table_id` | Defines which controlled table is handled by a registered process. |
| `project_columns` | `is_nullable` | Supports metadata-driven not-null validation. |
| `project_columns` | `is_watermark` | Identifies columns used for incremental load logic. |
| `project_columns` | `is_reconciliation_column` | Identifies columns used in reconciliation metrics. |
| `project_table_batches` | `batch_column_name` | Identifies the column used to define the batch. |
| `project_table_batches` | `batch_value` | Stores the batch identifier, such as `202401`. |
| `project_table_batches` | `batch_start_value`, `batch_end_value` | Support range-based batch definitions. |
| `project_table_batches` | `execution_required` | Marks a specific batch as requiring execution. |
| `project_table_batches` | `batch_column_type` | Stores the data type of the batch column and is used by dynamic SQL logic to apply the correct conversion. |

#### runtime

##### Table summary

| Table | Description |
|---|---|
| `execution_runs` | Tracks project-level execution runs. |
| `execution_steps` | Tracks process-level execution steps. A process may represent a package, subprocess, table-level load, or batch-level activity. |

##### Important columns

| Table | Column | Description |
|---|---|---|
| `execution_runs` | `start_run_date`, `end_run_date` | Track the execution duration of a project run. |
| `execution_runs` | `status_code_id` | References the controlled status of the execution run. |
| `execution_runs` | `project_id` | Associates the run with a registered project. |
| `execution_steps` | `status_code_id` | References the controlled status of the execution step. |
| `execution_steps` | `execution_run_id` | Associates the step with a project execution run. |
| `execution_steps` | `project_process_id` | Links the runtime step to the defined process metadata. |

#### observability

##### Table summary

| Table | Description |
|---|---|
| `error_logs` | Stores technical error records. |
| `reconciliation_results` | Stores reconciliation metrics generated during execution. |
| `validation_results` | Stores summary-level validation results. |

##### Important columns

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

#### reference

##### Table summary

| Table | Description |
|---|---|
| `status_codes` | Stores controlled execution status values. |
| `validation_codes` | Stores controlled validation types and severity levels. |

##### Important columns

| Table | Column | Description |
|---|---|---|
| `status_codes` | `id` | Stable manually assigned status identifier used by runtime tables. |
| `status_codes` | `code` | Stores values such as `Pending`, `Running`, `Success`, `Failed`, `Skipped`, `RerunRequired`, or `Observed`. |
| `validation_codes` | `id` | Stable manually assigned validation identifier used by validation result records. |
| `validation_codes` | `code` | Stores validation identifiers such as `NOT_NULL`, `FK_CHECK`, or `DUPLICATE`. |
| `validation_codes` | `severity` | Classifies the validation impact, such as error, warning, or information. |

## Stored Procedures and Functions

### Implementation Standards

| Rule | Description |
|---|---|
| Keep procedures focused | Each procedure should have one clear responsibility. |
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
| `metadata.ufn_list_project_process_table_batches` | Inline table-valued function | Lists active child processes, target tables, source batch tables and batch definitions for a given parent process. |

## Framework Execution Model

`DataOps_Control` uses a process-based execution model. The framework separates configuration, runtime tracking, and execution evidence so that different projects can use the same control structure without embedding project-specific business rules in the control database.

### Main Execution Concepts

The framework records execution at two runtime levels:

| Level | Table | Purpose |
|---|---|---|
| Project run | `runtime.execution_runs` | Represents one execution of a registered project. |
| Process step | `runtime.execution_steps` | Represents one executed process within the project run. |

A project is registered in `metadata.projects`, and each project contains one or more processes registered in `metadata.project_processes`.

The main runtime path is:

```text
metadata.projects
    ├── defines → metadata.project_processes
    └── runs as → runtime.execution_runs
                    └── runtime.execution_steps → one metadata.project_process
```

Table context is resolved through process metadata:

```text
metadata.project_processes
    → metadata.project_process_tables
        → metadata.project_tables
```

Source-to-target lineage is defined separately:

```text
metadata.project_table_mappings
    source table → target table
```

This separation keeps the runtime model centered on processes, while still allowing table-level tracking when a process represents a table load.

### Source and Target Table Interpretation

`metadata.project_tables` can register source tables, target tables, or managed objects.

Source tables are registered when they are needed for source-to-target mappings, batch filtering, validation, or reconciliation. Target tables are registered when they are controlled by execution, validation, reconciliation, or final model rules.

Source-to-target relationships are defined through `metadata.project_table_mappings`.

Batch definitions use `metadata.project_table_batches.batch_source_table_id` because batch filters are applied against the source table used to extract data.

### Data Flow Types

The framework supports three common execution patterns:

| Flow type | When it is used |
|---|---|
| Table load flow | A controlled table is loaded as a single execution unit. |
| Grouped table load flow | A parent process groups multiple related table-level processes. |
| Batch load flow | A large or transactional source table is processed in smaller slices. |

### Table Load Flow

A table load is used when a controlled table is loaded as a single execution unit.

Examples:

- `AddressType Load`
- `ProductCategory Load`
- `Customer Load`
- `DimCustomer Load`

In this pattern, each table-level load should have a registered process.

Example metadata structure:

```text
Project: Oracle to SQL Server Migration

Reference Data Load
    ├── AddressType Load        → metadata.project_tables.AddressType
    ├── ProductCategory Load    → metadata.project_tables.ProductCategory
    ├── ShipMethod Load         → metadata.project_tables.ShipMethod
    └── SpecialOffer Load       → metadata.project_tables.SpecialOffer
```

The parent process, `Reference Data Load`, is used for orchestration. The child processes represent table-level execution units.

At runtime, each child process creates its own execution step:

| execution_step | project_process | controlled table |
|---|---|---|
| Step 1 | `AddressType Load` | `AddressType` |
| Step 2 | `ProductCategory Load` | `ProductCategory` |
| Step 3 | `ShipMethod Load` | `ShipMethod` |
| Step 4 | `SpecialOffer Load` | `SpecialOffer` |

Observability records are linked to the execution step.

Example reconciliation for `AddressType Load`:

| metric_name | reconciliation_key | reconciliation_side | metric_value_bigint | execution_step_id |
|---|---|---|---:|---:|
| `ROW_COUNT` | `TOTAL` | `SOURCE` | 6 | 4 |
| `ROW_COUNT` | `TOTAL` | `TARGET` | 6 | 4 |

### Grouped Table Load Flow

A grouped table load is used when one parent process organizes multiple related table-level processes.

Example:

```text
Geography Load
    ├── CountryRegion Load
    ├── StateProvince Load
    └── SalesTerritory Load
```

Recommended pattern:

| Process type | Purpose | Table mapping |
|---|---|---|
| Parent process | Orchestration or grouping | Usually no direct table mapping |
| Child process | Table-level execution | Maps to one controlled table |

Example with table mapping:

```text
Geography Load
    ├── CountryRegion Load  → CountryRegion
    ├── StateProvince Load  → StateProvince
    └── SalesTerritory Load → SalesTerritory
```

This pattern keeps observability clear. Technical errors, validation summaries, and reconciliation metrics can be linked to the specific table-level execution step instead of being attached only to the parent group.

### Batch Load Flow

A batch load is used when a large or transactional table is processed in smaller slices.

Examples:

- Monthly sales orders.
- Daily transactions.
- Date-range based fact loads.
- Historical backfills.

Batch definitions are stored in `metadata.project_table_batches`.

The batch definition is based on the source table used for filtering, not necessarily the final target table.

Example batch metadata:

| source table | batch_column_name | batch_column_type | batch_value | batch_start_value | batch_end_value |
|---|---|---|---|---|---|
| `SALES_SALESORDERHEADER` | `OrderDate` | `DATETIME` | `2011-05` | `2011-05-01` | `2011-05-31` |
| `SALES_SALESORDERHEADER` | `OrderDate` | `DATETIME` | `2011-06` | `2011-06-01` | `2011-06-30` |

The target table is resolved through `metadata.project_table_mappings`.

Example:

```text
metadata.project_table_batches.batch_source_table_id → SALES_SALESORDERHEADER
metadata.project_table_mappings.table_source_id      → SALES_SALESORDERHEADER
metadata.project_table_mappings.table_target_id      → SalesOrderHeader
```

A batch load process may be represented as:

```text
SalesOrderHeader Load
    ├── Batch 2011-05
    ├── Batch 2011-06
    └── Batch 2011-07
```

The table-level process controls the load, while batch metadata defines which source slice should be processed.

For a batch execution, reconciliation metrics should include the batch context in `reconciliation_key`.

Example row-count reconciliation:

| metric_name | reconciliation_key | reconciliation_side | metric_value_bigint | execution_step_id |
|---|---|---|---:|---:|
| `ROW_COUNT` | `BATCH=2011-05` | `SOURCE` | 436 | 25 |
| `ROW_COUNT` | `BATCH=2011-05` | `TARGET` | 436 | 25 |

Example amount reconciliation:

| metric_name | reconciliation_key | reconciliation_side | metric_value_decimal | execution_step_id |
|---|---|---|---:|---:|
| `TOTAL_DUE` | `BATCH=2011-05` | `SOURCE` | 815233.4200 | 25 |
| `TOTAL_DUE` | `BATCH=2011-05` | `TARGET` | 815233.4200 | 25 |

### Observability and Status Behavior

Observability tables store execution evidence, not business ownership decisions.

| Table | Purpose |
|---|---|
| `observability.error_logs` | Stores technical error details. |
| `observability.validation_results` | Stores summary-level validation findings. |
| `observability.reconciliation_results` | Stores reconciliation metrics. |

`DataOps_Control` does not store row-level rejected business records centrally.

It also does not own business-specific reconciliation decisions. For example, source and target row counts may not match when the target is an aggregated table. In that case, the project-specific reconciliation procedure should register comparable metrics, such as `INVOICE_COUNT` or `TOTAL_AMOUNT`, instead of raw row counts.

The process owner or project-specific procedure decides whether an execution step completed as `Success`, `Observed`, or `Failed`.

Execution statuses are controlled through `reference.status_codes`.

| Status | Meaning |
|---|---|
| `Pending` | The execution is registered but has not started. |
| `Running` | The execution is currently in progress. |
| `Success` | The execution completed and expected control checks passed. |
| `Observed` | The execution completed technically, but validation or reconciliation results require review. |
| `Failed` | The execution failed due to a technical error. |
| `Skipped` | The execution was intentionally skipped. |
| `RerunRequired` | The object or process is marked for reprocessing. |

For execution runs, the final status is derived from the related execution steps:

| Step results | Final run status |
|---|---|
| Any step is `Failed` | `Failed` |
| No failed steps, but at least one step is `Observed` | `Observed` |
| All completed steps are successful or skipped | `Success` |

### End-to-End Example: AddressType Load

This example shows how the main objects work together for a simple table load.

| Step | What happens | Main objects involved |
|---:|---|---|
| 1 | The project run starts. | `runtime.usp_start_execution_run`, `runtime.execution_runs` |
| 2 | The `AddressType Load` process starts. | `runtime.usp_start_execution_step`, `runtime.execution_steps`, `metadata.project_processes` |
| 3 | The process table context is resolved. | `metadata.project_process_tables`, `metadata.project_tables` |
| 4 | The table is loaded by the project-specific ETL logic. | Project-specific package or stored procedure |
| 5 | Validation summaries and reconciliation metrics are inserted in bulk. | `observability.validation_results`, `observability.reconciliation_results` |
| 6 | Technical errors, if any, are logged. | `observability.usp_log_error`, `observability.error_logs` |
| 7 | The process-specific logic decides the final step status. | `Success`, `Observed`, or `Failed` |
| 8 | The execution step is ended with the final status. | `runtime.usp_end_execution_step` |
| 9 | The execution run is ended after all steps finish. | `runtime.usp_end_execution_run` |

This keeps `DataOps_Control` generic. The framework records metadata, execution state, and observability evidence, while project-specific logic owns the actual business validation and reconciliation decisions.

