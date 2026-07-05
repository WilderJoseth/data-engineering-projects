# Metadata Design

## Purpose

This document describes how the `metadata` schema defines the configurable control model for `DataOps_Control`, including projects, systems, objects, processes, execution scope, monitoring, and notification configuration.

SQL scripts remain the source of truth for exact table definitions.

## Metadata Tables

| Design Role / Concept | Table | Responsibility |
|---|---|---|
| Project boundary | `metadata.projects` | Stores the highest-level control unit for a DataOps project. |
| System registration | `metadata.project_databases` | Stores databases, platforms, systems, or logical stores used by a project. |
| Database lineage | `metadata.project_database_mappings` | Defines source-to-target database relationships. |
| Object registration | `metadata.project_tables` | Stores source, target, staging, work, or controlled object metadata. |
| Table lineage | `metadata.project_table_mappings` | Defines source-to-target table relationships. |
| Column control metadata | `metadata.project_columns` | Stores column metadata used for validation, reconciliation, and watermark identification. |
| Process definition | `metadata.project_processes` | Stores reusable controlled process metadata and parent-child hierarchy. |
| Process dependency | `metadata.project_process_dependencies` | Defines prerequisite relationships between processes. |
| Process action definition | `metadata.project_process_actions` | Defines ordered executable action templates for a process. |
| Process-object scope | `metadata.project_process_tables` | Defines which tables or objects are handled by each process. |
| Batch definition | `metadata.project_table_batches` | Defines reusable source-table batch slices. |
| Process-batch scope | `metadata.project_process_table_batches` | Assigns batch slices to a specific process-table execution scope. |
| Monitoring configuration | `metadata.project_process_monitoring_metrics` | Defines expected monitoring metrics, thresholds, and severity for a process. |
| Notification configuration | `metadata.project_notifications` | Stores notification configuration for project processes. |

## Important Design Distinctions

The metadata model separates related concepts that are often confused in DataOps control frameworks.

| Distinction | Meaning | Why It Matters |
|---|---|---|
| Project boundary vs system registration | A project is the highest-level control boundary. Systems/databases are assets registered inside that project. | Keeps project ownership separate from physical or logical data platforms. |
| System registration vs database lineage | `project_databases` registers systems. `project_database_mappings` defines source-to-target relationships between them. | Registration says what exists; lineage says how systems are related. |
| Object registration vs table lineage | `project_tables` registers controlled objects. `project_table_mappings` defines source-to-target relationships between objects. | Object inventory is separate from source-target mapping. |
| Table lineage vs execution scope | Lineage defines source-target relationships. Execution scope defines which object a process controls during execution. | A table can be mapped for lineage without being directly executed by every process. |
| Process definition vs execution step | A process is reusable metadata. An execution step is a runtime instance of that process. | Metadata defines what can run; runtime records what actually ran. |
| Process hierarchy vs process dependency | Hierarchy groups processes using parent-child relationships. Dependencies define prerequisites between processes. | A child process is not automatically a dependency, and a dependency does not imply hierarchy. |
| Process action vs process execution | Process actions define executable templates. External orchestration tools execute them. | `DataOps_Control` stores execution metadata but does not run pipeline actions by itself. |
| Batch definition vs process-batch scope | `project_table_batches` defines reusable batch slices. `project_process_table_batches` assigns those slices to a specific process-table scope. | Batch definitions can be reused across process execution scopes. |
| Watermark column vs runtime watermark value | Metadata identifies columns that can support incremental logic. Runtime watermark values are not fully tracked yet. | The current model supports watermark identification, not complete watermark state management. |
| Monitoring definition vs monitoring result | Monitoring metadata defines expected metrics and thresholds. Monitoring results store captured runtime values. | Definitions belong to `metadata`; execution evidence belongs to `observability`. |
| Notification metadata vs notification delivery | Notification metadata stores configuration. Delivery attempts and results are not fully logged yet. | Current support is configuration-focused, not a complete notification execution system. |
| Basic audit fields vs audit history | Metadata tables include basic create/update fields. Full metadata change history is not implemented. | Current auditability is basic and should not be described as full historical audit tracking. |

## Metadata Views and Functions

| Object Type | Name | Purpose |
|---|---|---|
| Function | `metadata.ufn_list_project_process_children` | Returns active immediate child processes marked as required. |
| Function | `metadata.ufn_list_project_process_actions` | Returns active required actions and command templates for one process. |
| Function | `metadata.ufn_list_project_process_table_batches` | Returns active required batches for one process. |
| View | `metadata.vw_project_process_hierarchy` | Returns immediate process hierarchy for review. |
| View | `metadata.vw_project_process_dependency_summary` | Returns process dependency metadata for review. |
| View | `metadata.vw_project_process_action_summary` | Returns configured process actions for review. |
| View | `metadata.vw_project_batch_execution_scope` | Returns process-table-batch scope for review. |
| View | `metadata.vw_project_table_lineage_summary` | Returns source-to-target table lineage for review. |
| View | `metadata.vw_project_process_monitoring_metric_summary` | Returns configured process monitoring thresholds for review. |

## Source SQL Scripts

| Script | Relevant Content |
|---|---|
| `database/ddl/04_create_metadata_tables.sql` | Metadata tables and relationships. |
| `database/ddl/08_create_functions.sql` | Metadata helper functions. |
| `database/ddl/10_create_views.sql` | Metadata review views. |
