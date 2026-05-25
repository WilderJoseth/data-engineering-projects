# Metadata-Driven Control Framework for Data Engineering Projects

## Overview

This project presents the design and implementation of `DataOps_Control`, a reusable metadata-driven control framework for data engineering projects.

`DataOps_Control` provides a centralized SQL Server control database designed to support metadata management, pipeline execution tracking, source-to-target mappings, validation summaries, reconciliation results, error logging, batch control, and rerun/recovery logic.

## Logical Data Model

The following diagram provides a high-level view of the `DataOps_Control` model, including its main metadata, runtime, observability, and reference components.

![DataOps_Control Logical Data Model](docs/img/logical_data_model_DataOps_Control.png)

## Problem Context

Data engineering projects often start with simple ETL/ELT pipelines, but as they grow, they require stronger operational control.

Common challenges include:

- Knowing which pipelines, tables, or batches were executed.
- Tracking whether an execution succeeded, failed, or requires another execution.
- Managing initial loads, incremental loads, and batch-based processing.
- Keeping source-to-target mappings documented and reusable.
- Capturing validation and reconciliation results in a consistent way.
- Logging technical errors with enough context for troubleshooting.
- Avoiding hardcoded status and validation values inside ETL packages, stored procedures, or orchestration logic.
- Supporting multiple projects without creating a new control structure every time.

## Project Scope

- Metadata management.
- Source-to-target database and table mappings.
- Process-to-table execution scope.
- Execution run and execution step tracking.
- Validation and reconciliation result capture.
- Technical error logging.
- Batch control.
- Execution, rerun, recovery, and backfill support.

## Out of Scope

- Implementing full business-specific ETL/ELT pipelines.
- Replacing orchestration tools such as SSIS, SQL Server Agent, Azure Data Factory, Fabric Data Pipelines, or Airflow.
- Storing row-level rejected records centrally.
- Owning business-specific validation or reconciliation decisions.
- Implementing a full data quality engine.
- Providing a user interface for monitoring or metadata management.
- Implementing automated alerting or notification workflows.
- Supporting every possible data platform integration in the first version.

## Repository Structure

```text
database/
|-- ddl/        # Database, schema, table, procedure, function, role, permission, and view scripts
|-- seed/       # Reference and sample domain metadata
|-- tests/      # Smoke, table-flow, and batch-flow test scripts
|-- users/      # User creation scripts for admin and project execution access
`-- cleanup/    # Cleanup scripts for resetting seeded or test data

docs/
|-- img/        # Logical data model and Entity Relationship diagrams
`-- solution_design.md
```

## Related Documentation

For the technical design, see:

- [Solution Design](docs/solution_design.md)

## Environment Assumptions

- SQL Server 2022 or compatible version.
- Scripts are intended to be executed using SQL Server Management Studio or sqlcmd.
- `DataOps_Control` is deployed as a separate control database.
- Consuming projects access the database through project-specific users assigned to framework roles.
- The first implementation is intended for a fresh database deployment. Existing database upgrades are outside the scope of this version.

## How to Run

The database scripts should be executed manually in the order shown below.

> Note: The DDL scripts are intended for a fresh `DataOps_Control` database deployment. They are not designed to be rerun against an existing database without cleanup or manual object removal.

### 1. Create database objects

Execute the scripts in `database/ddl/` in this order:

```text
01_create_database.sql
02_create_schemas.sql
03_create_reference_tables.sql
04_create_metadata_tables.sql
05_create_runtime_tables.sql
06_create_observability_tables.sql
07_create_stored_procedures.sql
08_create_functions.sql
09_create_security.sql
10_create_views.sql
```

### 2. Load seed data

Execute the scripts in `database/seed/` in this order:

```text
01_seed_reference_data.sql
02_seed_sales_domain_metadata.sql
```

### 3. Create test users

Execute the user scripts in `database/users/` if you want to test access using dedicated SQL Server logins and database users.

```text
01_create_project_executor_user.sql
02_create_dataops_admin_user.sql
```

These scripts are optional for local testing. They are not required to create the database objects.

### 4. Run validation tests

Execute the scripts in `database/tests/` in this order:

```text
00_smoke_test_framework_objects.sql
01_test_table_data_flow.sql
02_test_batch_data_flow.sql
```

The smoke test verifies that the required schemas, tables, procedures, functions, roles, and reference values exist before running the functional data-flow tests.

