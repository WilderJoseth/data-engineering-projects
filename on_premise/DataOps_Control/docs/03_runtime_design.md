# Runtime Design

## Purpose

This document describes how the `runtime` schema records execution activity for `DataOps_Control`, including project-level runs, process-level execution steps, runtime statuses, duration tracking, skipped steps, and parent step status derivation.

SQL scripts remain the source of truth for exact table and procedure definitions.

## Runtime Tables

| Design Role / Concept | Table | Responsibility |
|---|---|---|
| Execution run | `runtime.execution_runs` | Stores one runtime record for each execution of a registered project. |
| Execution step | `runtime.execution_steps` | Stores one runtime record for each executed metadata process inside an execution run. |

## Important Design Distinctions

The runtime model separates execution records from metadata definitions and observability evidence.

| Distinction | Meaning | Why It Matters |
|---|---|---|
| Project vs execution run | A project is configured in `metadata.projects`. An execution run is one runtime instance of that project. | Keeps reusable project configuration separate from execution history. |
| Process definition vs execution step | A process is reusable metadata in `metadata.project_processes`. An execution step records one runtime instance of that process. | Metadata defines what can run; runtime records what actually ran. |
| Run status vs step status | Run status summarizes the overall project execution. Step status records the result of one process execution. | A run can be failed or observed because of one or more step outcomes. |
| Start timestamp vs end timestamp | Start timestamps are captured when runs or steps are created. End timestamps are captured when they are closed. | Duration is derived from recorded timestamps instead of stored as a separate source value. |
| Leaf step status vs parent step status | Leaf step status is supplied by the caller or project-specific logic. Parent step status can be derived from direct child step statuses. | Project logic remains responsible for detailed status decisions, while group status can be summarized. |
| Process hierarchy vs runtime parent derivation | Hierarchy is defined in metadata. Runtime parent derivation evaluates execution steps for direct child processes. | Parent status derivation depends on runtime records and does not recursively resolve all descendants. |
| Skipped process metadata vs skipped execution step | A non-required child process is metadata. A skipped execution step is a runtime record created to show it was intentionally skipped in a run. | Execution history can show both executed and intentionally skipped child processes. |
| Dependency metadata vs dependency enforcement | Dependencies are stored in `metadata.project_process_dependencies`. Runtime procedures do not fully enforce dependency order. | Orchestration tools remain responsible for applying dependency rules during execution. |

## Runtime Procedures and Views

| Object Type | Name | Purpose |
|---|---|---|
| Procedure | `runtime.usp_start_execution_run` | Creates a running execution run for an active project and returns the run identifier. |
| Procedure | `runtime.usp_start_execution_step` | Creates a running execution step for an active process inside an open execution run and returns the step identifier. |
| Procedure | `runtime.usp_end_execution_step` | Closes an execution step using a caller-provided final status. |
| Procedure | `runtime.usp_end_parent_execution_step` | Closes a parent execution step using direct child step statuses. |
| Procedure | `runtime.usp_register_skipped_child_execution_steps` | Creates skipped execution step records for active direct child processes that are not required for execution. |
| Procedure | `runtime.usp_end_execution_run` | Closes an execution run and derives the final run status from related execution steps. |
| View | `runtime.vw_execution_run_summary` | Returns execution run status, project context, run dates, and run duration for review. |
| View | `runtime.vw_execution_step_summary` | Returns execution step status, project/process context, step dates, and step duration for review. |

## Runtime Status Behavior

Runtime status values are controlled by `reference.status_codes`.

| Status | Meaning |
|---|---|
| `Pending` | The execution is registered but has not started. |
| `Running` | The execution is in progress. |
| `Success` | The execution completed and expected controls passed. |
| `Failed` | The execution failed due to a technical or controlled failure condition. |
| `Skipped` | The execution step was intentionally skipped. |
| `Observed` | The execution completed technically, but evidence requires review. |

### Execution Run Closure Logic

| Runtime Condition | Final Run Behavior |
|---|---|
| Run has no steps | Run is closed as `Observed`. |
| Any step is `Pending` or `Running` | Run cannot be closed. |
| Any step is `Failed` | Run is closed as `Failed`. |
| No failed steps, but at least one step is `Observed` | Run is closed as `Observed`. |
| Otherwise | Run is closed as `Success`. |

### Execution Step Parent Closure Logic

| Direct Child Step Condition | Parent Step Behavior |
|---|---|
| Any direct child step is `Failed` | Parent step is closed as `Failed`. |
| No failed direct child steps, but at least one direct child step is `Observed` | Parent step is closed as `Observed`. |
| Otherwise | Parent step is closed as `Success`. |

## Source SQL Scripts

| Script | Relevant Content |
|---|---|
| `database/ddl/05_create_runtime_tables.sql` | Runtime execution run and execution step tables. |
| `database/ddl/07_create_stored_procedures.sql` | Runtime procedures for run, step, parent step, and skipped step behavior. |
| `database/ddl/10_create_views.sql` | Runtime review views. |
