# Framework Data Model

## Purpose

This document describes the framework-level data model of `DataOps_Control`.

It covers schema responsibilities, framework object groups, naming conventions, and common data model rules.

SQL scripts remain the source of truth for exact table definitions, columns, constraints, indexes, procedures, functions, views, roles, and seed data.

## Project Scope Positioning

`DataOps_Control` belongs to the operational metadata management area of data governance.

It is a metadata-driven control framework for data engineering pipelines. The framework stores control metadata, runtime tracking records, observability evidence, reference codes, and framework security boundaries.

| Scope Level | Position |
|---|---|
| Broad discipline | Data governance |
| Subdomain | Metadata management |
| Project focus | Operational metadata management |
| Architecture | Metadata-driven control architecture |
| Solution type | Metadata-driven control framework |

The framework supports pipeline control and review, but it does not replace external orchestration or data movement tools.

## Schema Organization

| Schema | Responsibility |
|---|---|
| `metadata` | Stores project, database, table, column, process, batch, dependency, mapping, action, metric, and notification definitions. |
| `runtime` | Stores execution plans, execution runs, execution steps, runtime states, statuses, and timing records. |
| `observability` | Stores error logs, validation results, reconciliation results, and monitoring results. |
| `reference` | Stores reusable framework codes such as statuses, validation codes, and monitoring metric codes. |

## Framework Object Groups

| Schema | Object Group | Main Objects |
|---|---|---|
| `metadata` | Project and system configuration | `projects`, `project_databases`, `project_database_mappings` |
| `metadata` | Object and lineage configuration | `project_tables`, `project_table_mappings`, `project_columns` |
| `metadata` | Process configuration | `project_processes`, `project_process_dependencies`, `project_process_actions` |
| `metadata` | Execution scope configuration | `project_process_tables`, `project_table_batches`, `project_process_table_batches` |
| `metadata` | Monitoring and notification configuration | `project_process_monitoring_metrics`, `project_notifications` |
| `runtime` | Execution planning, tracking, and watermark control | `execution_plans`, `execution_plan_processes`, `execution_runs`, `execution_steps`, `execution_watermark_controls`, `execution_watermarks` |
| `observability` | Execution evidence | `error_logs`, `validation_results`, `reconciliation_results`, `monitoring_results` |
| `reference` | Framework codes | `status_codes`, `validation_codes`, `monitoring_metric_codes` |

## Naming Conventions

| Object Type | Pattern | Example |
|---|---|---|
| Database | PascalCase | `DataOps_Control` |
| Schema | Lowercase responsibility name | `metadata`, `runtime`, `observability`, `reference` |
| Table | Lowercase plural noun | `execution_runs`, `validation_results` |
| Primary key column | `id` for entity tables | `metadata.projects.id` |
| Bridge table key columns | `<referenced_entity>_id` columns, usually composite | `process_id`, `table_id`, `batch_id` |
| Foreign key column | `<referenced_entity>_id` | `project_id`, `execution_run_id` |
| Date/time column | `<event>_at` where possible | `created_at`, `started_at`, `ended_at` |
| Boolean column | `is_<condition>` where possible | `is_active`, `is_required` |
| Stored procedure | `<schema>.usp_<verb>_<object_or_action>` | `runtime.usp_start_execution_run` |
| Function | `<schema>.ufn_<verb_or_return_value>` | `metadata.ufn_list_project_process_actions` |
| View | `<schema>.vw_<entity_or_summary_purpose>` | `runtime.vw_execution_step_summary` |
| Primary key constraint | `PK_<schema>_<table_name>` | `PK_runtime_execution_runs` |
| Foreign key constraint | `FK_<schema>_<table_name>_<column_name>` | `FK_runtime_execution_steps_execution_run_id` |
| Unique constraint | `UK_<schema>_<table_name>_<column_or_purpose>` | `UK_metadata_projects_name` |
| Default constraint | `DF_<schema>_<table_name>_<column_name>` | `DF_metadata_projects_is_active` |
| Check constraint | `CK_<schema>_<table_name>_<rule_name>` | `CK_runtime_execution_runs_end_run_date` |
| Index | `IX_<schema>_<table_name>_<column_or_purpose>` | `IX_runtime_execution_steps_execution_run_id` |

## Common Data Model Rules

| Rule | Description |
|---|---|
| Responsibility-based schemas | Framework objects are grouped by metadata, runtime, observability, and reference responsibilities. |
| Configuration vs execution | Metadata defines what can be controlled; runtime records what actually executed. |
| Execution evidence separation | Observability records execution evidence separately from runtime lifecycle records. |
| Reference code standardization | Statuses, validation codes, and metric codes are centralized in the `reference` schema. |
| Active flag | Metadata and reference objects generally use `is_active` to allow controlled deactivation. |
| Basic audit fields | Objects commonly include `created_at` and `created_by` for insert-level traceability. |
| Composite bridges | Relationship tables use composite primary keys where the relationship itself is the entity. |
| Runtime identities | Runtime and observability records use identity keys because they represent execution events, state records, or evidence records. |
| Design-level documentation | Markdown documents summarize responsibilities and design intent. SQL scripts define the exact database contract. |

## Known Boundaries

| Area | Boundary |
|---|---|
| Data movement | `DataOps_Control` does not move data directly. External pipeline tools perform execution. |
| Documentation scope | Markdown documents explain design intent. SQL scripts define the exact database contract. |
| Enterprise data catalog | The framework can store operational technical metadata, but it is not a full enterprise catalog platform. |
| Business glossary | Business term definitions are outside the current framework scope. |
| Data stewardship workflows | Governance approvals and stewardship processes are outside the current framework scope. |
| Enterprise access governance | Identity management and enterprise access approval workflows are outside the current framework scope. |
| Privacy and compliance management | Sensitive data policy management, classification workflows, and compliance rules are future or external scope. |
| Advanced lineage visualization | Source-to-target and process-level metadata can support lineage review, but advanced visualization is future scope. |
| Metadata change history | Basic audit fields exist, but full metadata change history and versioning are future scope. |
| Runtime state rules | Status transition rules are part of the conceptual design; configurable transition metadata is future scope. |
| SLA management | SLA tracking and enforcement are future or optional scope. |
| Retention and cleanup policies | Retention and cleanup rules are future or optional scope. |
