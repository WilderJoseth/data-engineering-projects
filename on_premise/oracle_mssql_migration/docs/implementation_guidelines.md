# Implementation Guidelines

## Purpose

This document defines practical implementation rules for building the SQL Server objects, SSIS packages, stored procedures, and `DataOps_Control` integration used by the Sales domain migration solution.

## Naming Conventions

### Schema Naming

- Names should follow `lowercase`, for example `staging`.

### Table Naming

- Business tables should use `PascalCase`, for example `prod.SalesOrderHeader`.
- Staging/work tables should use `PascalCase`, for example `staging.SalesOrderHeader`.
- Control tables should use `snake_case`, for example `control.reconcilation_results`.

### Stored Procedure Naming

- Names should follow the following structure: `usp_[action]_[TableName]`. Exeptions may apply.

| Prefix | Purpose | Example |
|---|---|---|
| `usp_cleanup_` | Clean staging/work objects | `usp_cleanup_tables` |
| `usp_load_` | Load data into tables | `usp_load_AddressType` |
| `usp_validate_` | Validate staged or working data | `usp_validate_AddressType` |
| `usp_reconcile_` | Register reconciliation checks | `usp_reconcile_AddressType` |
| `usp_register_` | Register execution, step, log, or result metadata | `usp_register_reconcilation_result` |

### SSIS Package and Task Naming

SSIS package names should reflect the migration area or load type.

| Object | Naming example |
|---|---|
| Main operational orchestration package | `PKG_OPERATIONAL_MIGRATION` |
| Reference data package | `PKG_REFERENCE_DATA` |
| Master data package | `PKG_MASTER_DATA` |
| Transactional data package | `PKG_TRANSACTIONAL_DATA` |
| Analytics orchestration package | `PKG_ANALYTICS_MIGRATION` |
| Dimension package | `PKG_DIMENSION_DATA` |
| Fact package | `PKG_FACT_DATA` |

SSIS task names should be action-oriented, for example:

- `Start Subprocess`
- `Get Load Configuration`
- `Extract Customer to Staging`

## Data Type Mapping Guidelines

Oracle source types should be mapped to SQL Server target types based on business meaning, precision, and expected usage.

| Oracle source type | SQL Server target type | Mapping rule |
|---|---|---|
| `NUMBER(p, 0)` | `INT` or `BIGINT` | Use for whole-number identifiers, counters, etc. |
| `NUMBER(p, s)` | `DECIMAL(p, s)` | Use for monetary values, rates, percentages, etc. |
| `VARCHAR2(n)` | `VARCHAR(n)` or `NVARCHAR(n)` | Use for text attributes. Use `NVARCHAR` when Unicode support is required. |
| `CHAR(n)` | `CHAR(n)` | Use for fixed or short code values when length is stable. |
| `DATE` | `DATE` or `DATETIME2` | Use `DATE` for date-only attributes. Use `DATETIME2` when time values must be preserved. |
| `TIMESTAMP` | `DATETIME2` | Use when datetime precision is required. |

## Key and Identifier Guidelines

### Surrogate Keys

Final target tables should use SQL Server-generated surrogate primary keys when the target model requires independent SQL Server relationships.

Examples:

| Table type | Example surrogate key |
|---|---|
| Operational entity | `customer_key` |
| Analytical dimension | `customer_key` |
| Analytical fact | `fact_sales_key` or composite load/business key depending on design |

### Source Business Keys

Source identifiers should be preserved where they are needed for:

- source-to-target traceability
- reconciliation
- rerun logic
- dependency resolution
- historical audit
- integration with other source-derived objects

Examples:

| Source identifier | Target usage |
|---|---|
| `CUSTOMERID` | `source_customer_id` |
| `PRODUCTID` | `source_product_id` |
| `SALESORDERID` | `source_sales_order_id` |
| `SALESORDERDETAILID` | `source_sales_order_detail_id` |

### Audit Columns

Final business tables may include audit/technical columns when required.

Common audit columns:

| Column | Purpose |
|---|---|
| `created_at` | Timestamp when the record was inserted. |
| `updated_at` | Timestamp when the record was last updated. |
| `run_id` | Execution run that inserted or updated the record. |
| `is_active` | Indicates whether the record is active in the target model. |

Audit columns should support traceability without replacing detailed execution history stored in `DataOps_Control`.


## Table Implementation Standards

### Nullability Rules

- Required business keys and required descriptive values should be `NOT NULL`.
- Optional source values should remain nullable unless a default value is valid and intentional.
- Nullability should be based on business meaning, not only on source metadata.

### Default Value Rules

Default values should be used only when they represent valid technical or business behavior.

Examples:

| Default | Acceptable use |
|---|---|
| `created_at = SYSUTCDATETIME()` | Technical insert timestamp. |
| `is_active = 1` | Active record by default, when applicable. |
| `unknown_key = -1` | Unknown/default dimension member, when used intentionally. |

Avoid defaults that hide data-quality problems.

### Constraint Rules

- Primary keys should be defined on final business tables.
- Foreign keys should be defined where they support target integrity and do not conflict with the migration/reload strategy.
- Unique constraints or indexes should be considered for preserved source business keys.
- Check constraints can be used for stable domain rules.

### Indexing Guidelines

Indexes should support:

- business key lookups during `MERGE` or UPSERT operations
- source-to-target reconciliation
- foreign key joins
- batch filtering by period
- analytical joins from facts to dimensions

Indexing should be added intentionally based on load and query patterns.

---

## Stored Procedure Implementation Pattern

SSIS orchestrates the workflow, while SQL Server stored procedures handle database-side validation, transformation, final loading, reconciliation, and status updates.

### Validation Procedure Pattern

Validation procedures should:

1. Read staged records for the current table or batch.
2. Apply required data-quality rules.
3. Write validation errors or warnings to `DataOps_Control.validation_results`.
4. Mark valid records for loading into `work`.
5. Return status or row counts to the SSIS package when required.

### Work Load Procedure Pattern

Work load procedures should:

1. Read valid staged records.
2. Apply standardization and transformation rules.
3. Resolve parent keys where required.
4. Load transformed data into the `work` schema.

### Final Load Procedure Pattern

Final load procedures should use the strategy appropriate to the load type.

| Load type | Final load strategy |
|---|---|
| Reference / master | `MERGE` or UPSERT using source business keys. |
| Transactional | Controlled delete and reload by batch period. |
| Dimension | `MERGE` or UPSERT for Type 1 dimensions unless otherwise defined. |
| Fact | Batch load with dimension key resolution and duplicate key protection. |

### Reconciliation Procedure Pattern

Reconciliation procedures should register results in `DataOps_Control.reconciliation_results`.

Common reconciliation checks include:

- source-to-staging row counts
- work-to-final row counts
- missing business keys
- duplicate business keys
- orphan child records
- financial totals for transactional and fact loads

### Cleanup Procedure Pattern

Cleanup procedures should remove only the staging/work data related to the current scope.

Cleanup scope may be:

- full reference scope
- full master scope
- a specific table
- a specific `yyyyMM` batch period

Cleanup behavior should be controlled and should not remove final business data unless part of an explicit rerun strategy.

---

## SSIS Implementation Guidelines

### Project Parameters

Common project-level parameters may include:

| Parameter | Purpose |
|---|---|
| `ProjectId` | Identifies the registered project in `DataOps_Control`. |
| `EnvironmentName` | Identifies the execution environment, such as `DEV`, `TEST`, or `PROD`. |
| `SourceConnectionName` | Identifies the Oracle source connection. |
| `TargetConnectionName` | Identifies the SQL Server target connection. |
| `DataOpsConnectionName` | Identifies the `DataOps_Control` connection. |

### Package Parameters

Common package-level parameters may include:

| Parameter | Purpose |
|---|---|
| `ExecutionRunId` | Identifies the current execution run. |
| `ExecutionStepId` | Identifies the current execution step. |
| `ProjectTableId` | Identifies the table being processed. |
| `BatchPeriodYYYYMM` | Identifies the current batch period when batching is used. |
| `BatchStartDate` | Inclusive start boundary for batch extraction. |
| `BatchEndDate` | Exclusive end boundary for batch extraction. |
| `RerunRequired` | Indicates whether the object is being reprocessed. |

### Connection Managers

Connection managers should be separated by purpose:

- Oracle source connection
- `Sales_Operational` target connection
- `Sales_Analytics` target connection
- `DataOps_Control` connection

Connection values should be environment-configurable and should not be hardcoded inside package logic.

### Sequence Containers

Sequence containers should be used to group related work, such as:

- Independent table load
- Grouped reference load
- Master data load
- Transactional batch load
- Dimension load
- Fact load

### Event Handlers

SSIS `OnError` event handlers should register unexpected technical failures in `DataOps_Control.error_logs`.

Technical failures should be handled separately from data-quality validation failures.

### Logging Behavior

Packages should register:

- execution start
- execution end
- table or batch start
- table or batch end
- row counts
- validation results
- reconciliation results
- technical errors

Logging should be detailed enough to support troubleshooting and reruns without requiring manual package inspection.

---

## DataOps_Control Integration Pattern

`DataOps_Control` is the central control layer for project metadata, execution tracking, validation results, reconciliation results, technical errors, batch status, and rerun support.

### Execution Run Registration

A full project execution should create an `execution_runs` record.

Typical information:

- project identifier
- start time
- end time
- status
- execution trigger or initiator
- message or summary

### Execution Step Registration

Each package, subprocess, table load, or logical execution unit should create an `execution_steps` record.

Execution steps may be hierarchical through a parent execution step relationship.

Examples:

```text
PKG_REFERENCE_DATA
    -> AddressType Load
    -> Geography Load
        -> CountryRegion
        -> StateProvince
        -> SalesTerritory
```

### Error Registration

Unexpected errors should be registered in `error_logs`.

Typical information:

- execution run
- execution step
- package/task/component name
- error code
- error message
- error timestamp

### Validation Result Registration

Validation results should be registered in `validation_results`.

Typical information:

- execution run
- execution step
- table or batch
- source key
- rule code
- severity
- validation message

### Reconciliation Result Registration

Reconciliation results should be registered in `reconciliation_results`.

Typical information:

- execution run
- execution step
- table or batch
- check type
- source value
- target value
- variance
- result status

---

## Status and Rerun Standards

### Standard Status Values

Use consistent status values across execution tables.

| Status | Meaning |
|---|---|
| `Pending` | Object is waiting to run. |
| `Running` | Object is currently executing. |
| `Success` | Object completed successfully. |
| `Failed` | Object failed due to technical or validation issue. |
| `Skipped` | Object was intentionally skipped. |
| `RerunRequired` | Object is marked for reprocessing. |

### Table-Level Rerun Rules

Table-level reruns are used for reference, master, and dimension loads.

A table may be included in a rerun when:

- it is active
- it requires loading
- the previous load failed
- it is explicitly marked as rerun required
- a parent dependency was reprocessed

### Batch-Level Rerun Rules

Batch-level reruns are used for large transactional and fact loads.

A batch may be included in a rerun when:

- the batch failed
- reconciliation failed
- the batch is explicitly marked as rerun required
- the batch belongs to a selected recovery period

Transactional batch reruns should follow delete-and-reload behavior for the affected period.

---

## Batch Processing Guidelines

### Batch Period Definition

For Sales transactional loads, the batch period is based on `SalesOrderHeader.OrderDate` using `yyyyMM` format.

### Batch Start and End Boundaries

Batch filters should use inclusive start and exclusive end boundaries.

```sql
OrderDate >= @batch_start_date
AND OrderDate <  @batch_end_date
```

This avoids boundary issues when date/time values include time components.

### Batch Rerun Behavior

For transactional reruns:

1. Delete child records for the affected batch.
2. Delete parent records for the affected batch.
3. Reload parent records.
4. Reload child records.
5. Register reconciliation results.
6. Update batch status in `DataOps_Control`.

For analytical fact reruns, reload the affected fact period from the curated `Sales_Operational.prod` source and reconcile the result against the operational data.
