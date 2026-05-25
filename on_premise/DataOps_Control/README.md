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
├── ddl/        # Database, schema, table, procedure, and function scripts
├── seed/       # Reference and sample domain metadata
└── tests/      # Table-flow and batch-flow test scripts

docs/
├── img/        # Logical and Entity Relationship diagrams
└── solution_design.md
```

## Related Documentation

For the technical design, see:

- [Solution Design](docs/solution_design.md)
