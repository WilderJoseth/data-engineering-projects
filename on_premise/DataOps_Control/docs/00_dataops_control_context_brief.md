# DataOps_Control Context Brief

## Purpose

This document is a reusable project context summary for other ChatGPT chats or project evaluations. Use it when assessing whether `DataOps_Control` can support another data engineering project.

## What DataOps_Control Is

`DataOps_Control` is a metadata-driven control framework focused on operational metadata management for data engineering pipelines.

It supports pipeline control, execution tracking, observability, validation/reconciliation evidence, dependency-aware execution, recovery-style execution, and watermarking. It does not move data itself. External tools such as SSIS, SQL Server Agent, Azure Data Factory, Fabric Data Pipelines, or custom services perform the actual data movement and transformation work.

## Core Capabilities

- Project and system metadata registration
- Table, column, and process metadata
- Process hierarchy and dependency modeling
- Execution plans and plan processes
- Dependency-aware readiness
- Execution runs and steps
- Status and state tracking
- Runtime watermark controls
- Execution watermark history
- Error, validation, reconciliation, and monitoring evidence
- Recovery-style execution through new plans
- Security roles and least privilege

## Schema Responsibility Summary

| Schema | Responsibility | Example Tables |
|---|---|---|
| `reference` | Stores reusable framework codes. | `status_codes`, `validation_codes`, `monitoring_metric_codes` |
| `metadata` | Stores project configuration, process definitions, dependencies, object metadata, execution scope, actions, monitoring configuration, and notification metadata. | `projects`, `project_databases`, `project_tables`, `project_columns`, `project_processes`, `project_process_dependencies`, `project_process_actions` |
| `runtime` | Stores execution plans, plan process states, execution runs, execution steps, watermark controls, and watermark history. | `execution_plans`, `execution_plan_processes`, `execution_runs`, `execution_steps`, `execution_watermark_controls`, `execution_watermarks` |
| `observability` | Stores execution evidence and reviewable results. | `error_logs`, `validation_results`, `reconciliation_results`, `monitoring_results` |

## Execution Lifecycle Summary

```text
Metadata configuration
-> Metadata validation / scope selection
-> Execution plan
-> Dependency evaluation
-> Execution run
-> Execution steps
-> Observability evidence
-> Watermark commit/non-commit
-> Run and plan closure
-> Recovery/reprocessing plan if needed
```

## Current Implemented Status Model

Implemented statuses:

- `PENDING`
- `READY`
- `RUNNING`
- `SUCCESS`
- `FAILED`
- `OBSERVED`
- `BLOCKED`
- `SKIPPED`
- `CANCELLED`

`WAITING` is not part of the current implemented model.

`REQUIRES_RERUN` is not part of the current implemented model.

Recovery and rerun behavior is represented by creating a new execution plan, not by reusing the prior plan or changing a status to `REQUIRES_RERUN`.

## How To Use This Framework In Another Project

| Project Need | How DataOps_Control Can Help |
|---|---|
| Pipeline inventory | Register projects, systems, tables, columns, processes, and actions. |
| Process orchestration control | Define controlled process scope and expose metadata for an external orchestrator. |
| Dependency management | Store process dependencies and evaluate readiness before execution. |
| Incremental load tracking | Store watermark controls and per-step watermark history. |
| Validation/reconciliation evidence | Capture validation findings and reconciliation metrics by execution step. |
| Monitoring evidence | Capture configured monitoring metrics and threshold outcomes. |
| Failure/recovery tracking | Preserve failed history and create new recovery, rerun, reprocessing, or backfill plans. |
| Execution audit/history | Track plans, runs, steps, final statuses, timings, and observability evidence. |

## When DataOps_Control Is A Good Fit

- Multiple pipelines or processes need controlled execution tracking.
- Incremental loads need watermark control.
- Dependencies need visibility before and during execution.
- Execution evidence needs to be reviewed after runs.
- Recovery or reprocessing needs clear scope and preserved history.
- An external orchestrator needs a SQL Server control database.

## When It Is Not Enough By Itself

- Actual data movement
- Transformation logic
- Enterprise data catalog
- Business glossary
- Enterprise IAM
- Notification delivery engine
- Full data quality rule engine

## Questions To Ask When Applying It To A New Project

- What are the projects, systems, tables, and processes?
- What processes depend on others?
- Which loads are full vs incremental?
- Which columns control watermarking?
- What validations and reconciliations are required?
- What metrics should be monitored?
- What should happen on failure, observed outcome, skipped process, or cancellation?
- What orchestrator will call the framework procedures?

## Validation Status

| Validation Area | Status |
|---|---|
| Fresh deployment | Passed |
| Happy-path functional scenario | Passed |
| Failure/recovery scenario | Passed |
| Watermark commit and non-commit behavior | Tested and passed |
| Security grants | Validated |

`DataOps_Control` v2 is ready as a deployable and functionally validated metadata-driven control framework for data engineering pipeline control scenarios.
