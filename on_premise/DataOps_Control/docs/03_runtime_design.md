# Runtime Design

## Purpose

This document describes how the `runtime` schema records and controls execution activity for `DataOps_Control`.

It covers the execution control layer, execution history layer, runtime states, status behavior, duration tracking, skipped steps, watermark control, watermark execution history, and current status derivation behavior.

SQL scripts remain the source of truth for exact table and procedure definitions.

## Runtime Model Overview

The `runtime` schema has two main responsibilities:

| Runtime Layer | Purpose | Answers | Tables |
|---|---|---|---|
| Execution control layer | Defines the planned execution scope, control state, and committed runtime control values. | What should run, what is ready, what is waiting, what is blocked, and what committed watermark value controls the next execution. | `runtime.execution_plans`, `runtime.execution_plan_processes`, `runtime.execution_watermark_controls` |
| Execution history layer | Records the project run, process steps, and watermark ranges actually used during execution. | What actually ran, when it ran, how it ended, and what watermark range was used. | `runtime.execution_runs`, `runtime.execution_steps`, `runtime.execution_watermarks` |

## Runtime Plan Management

Runtime Plan Management controls the planned execution scope for a project execution attempt.

| Concept | Table | Runtime Layer | Responsibility |
|---|---|---|---|
| Execution plan | `runtime.execution_plans` | Execution control layer | Defines one controlled execution scope for a project. |
| Execution plan process | `runtime.execution_plan_processes` | Execution control layer | Defines the processes included in the plan and their current control state. |

### Relationship Summary

| Object | Role |
|---|---|
| `metadata.project_processes` | Defines all possible controlled processes. |
| `runtime.execution_plans` | Groups selected processes into one execution control scope. |
| `runtime.execution_plan_processes` | Stores the process-level control state within the plan. |

### Core Design Rules

| Rule | Description |
|---|---|
| Metadata defines possible processes | `metadata.project_processes` defines what can be selected into an execution plan. |
| Execution plan defines control scope | `runtime.execution_plans` defines the project, plan type, root process, and plan status. |
| Plan processes define included scope | `runtime.execution_plan_processes` stores the processes included in the plan. |
| Plan state tracks readiness | Plan processes track states such as `PENDING`, `READY`, `WAITING`, `RUNNING`, `SUCCESS`, `OBSERVED`, `FAILED`, `BLOCKED`, and `SKIPPED`. |
| Plans support recovery and reprocessing | A plan can represent scheduled, manual, recovery, reprocessing, backfill, validation-only, or reconciliation-only execution scope. |
| Plans do not record actual execution history | Actual project runs and process executions are recorded separately in `runtime.execution_runs` and `runtime.execution_steps`. |

### Runtime Flow

```text
metadata.project_processes
        ↓ selected into
runtime.execution_plan_processes
        ↓ grouped by
runtime.execution_plans
```

### Questions Answered

| Question | Answered By |
|---|---|
| What execution scope is being prepared? | `runtime.execution_plans` |
| Why is this execution being prepared? | `runtime.execution_plans` |
| What is the root process of the scope? | `runtime.execution_plans` |
| Which processes are included in this plan? | `runtime.execution_plan_processes` |
| Which processes are ready, waiting, blocked, skipped, failed, observed, or completed? | `runtime.execution_plan_processes` |

## Runtime Execution History Management

Runtime Execution History Management records what actually happened during project and process execution.

| Concept | Table | Runtime Layer | Responsibility |
|---|---|---|---|
| Execution run | `runtime.execution_runs` | Execution history layer | Stores one actual project-level execution instance. |
| Execution step | `runtime.execution_steps` | Execution history layer | Stores one actual process-level execution instance inside a run. |

### Relationship Summary

| Object | Role |
|---|---|
| `metadata.projects` | Defines the project being executed. |
| `metadata.project_processes` | Defines the process executed by a step. |
| `runtime.execution_runs` | Records the actual project execution. |
| `runtime.execution_steps` | Records the actual process execution inside a run. |
| `reference.status_codes` | Standardizes run and step statuses. |

### Core Design Rules

| Rule | Description |
|---|---|
| Runs record project execution | Each execution run represents one actual execution of a registered project. |
| Steps record process execution | Each execution step represents one runtime instance of a metadata process. |
| Metadata remains reusable | Runtime records do not replace metadata definitions. |
| Statuses are standardized | Run and step statuses use `reference.status_codes`. |
| Duration is timestamp-based | Execution duration is derived from start and end timestamps. |
| Run status is derived from steps | A run can be closed as `SUCCESS`, `FAILED`, or `OBSERVED` based on related step outcomes. |
| Parent step status can be derived | A parent step can be closed based on direct child step statuses. |
| Skipped steps are recorded | Skipped child processes can be registered as execution steps for traceability. |

### Run and Step Statuses

| Status | Meaning |
|---|---|
| `PENDING` | The execution is registered but has not started. |
| `RUNNING` | The execution is in progress. |
| `SUCCESS` | The execution completed and expected controls passed. |
| `FAILED` | The execution failed due to a technical or controlled failure condition. |
| `SKIPPED` | The execution step was intentionally skipped. |
| `OBSERVED` | The execution completed technically, but evidence requires review. |

### Execution Run Closure Logic

Run closure logic derives the final run status from related execution steps.

| Runtime Condition | Final Run Behavior |
|---|---|
| Run has no steps | Run is closed as `OBSERVED`. |
| Any step is `PENDING` or `RUNNING` | Run cannot be closed. |
| Any step is `FAILED` | Run is closed as `FAILED`. |
| No failed steps, but at least one step is `OBSERVED` | Run is closed as `OBSERVED`. |
| Otherwise | Run is closed as `SUCCESS`. |

### Execution Step Parent Closure Logic

Parent step closure logic derives the final parent step status from direct child execution steps.

| Direct Child Step Condition | Parent Step Behavior |
|---|---|
| Any direct child step is `FAILED` | Parent step is closed as `FAILED`. |
| No failed direct child steps, but at least one direct child step is `OBSERVED` | Parent step is closed as `OBSERVED`. |
| Otherwise | Parent step is closed as `SUCCESS`. |

### Questions Answered

| Question | Answered By |
|---|---|
| What project execution happened? | `runtime.execution_runs` |
| What process executed? | `runtime.execution_steps` |
| When did the run or step start? | `runtime.execution_runs`, `runtime.execution_steps` |
| When did the run or step end? | `runtime.execution_runs`, `runtime.execution_steps` |
| How did the run or step finish? | `runtime.execution_runs`, `runtime.execution_steps` |
| Which child processes were skipped? | `runtime.execution_steps` |
| What final status was derived for a run? | `runtime.usp_end_execution_run` |
| What final status was derived for a parent step? | `runtime.usp_end_parent_execution_step` |

## Runtime Watermark Management

Runtime Watermark Management controls the incremental processing boundary for process-based executions.

| Concept | Table | Runtime Layer | Responsibility |
|---|---|---|---|
| Watermark control | `runtime.execution_watermark_controls` | Execution control layer | Stores the current watermark rule and last successfully committed value for a process/table/column combination. |
| Execution watermark | `runtime.execution_watermarks` | Execution history layer | Stores the actual watermark range used by a specific execution step. |

### Relationship Summary

| Object | Role |
|---|---|
| `metadata.project_processes` | Defines the process controlled by the watermark. |
| `metadata.project_tables` | Defines the source table controlled by the watermark. |
| `metadata.project_columns` | Defines the column used as the watermark. |
| `runtime.execution_steps` | Records the process execution that used the watermark. |
| `runtime.execution_watermark_controls` | Stores the current watermark rule and committed value. |
| `runtime.execution_watermarks` | Stores the actual watermark range used by an execution step. |

### Core Design Rules

| Rule | Description |
|---|---|
| Metadata defines structure | Processes, tables, and watermark columns are defined in `metadata`. |
| Runtime stores changing state | Watermark values change during execution, so committed values are stored in `runtime`. |
| Watermark configuration is process/table/column based | A process may use a specific table column as its incremental control boundary. |
| Execution ranges are frozen per step | The actual lower and upper bounds used by a step are stored for traceability. |
| Watermark values commit only after success | Failed or blocked execution steps must not advance the committed watermark. |

### Range Calculation

An incremental range is created from the previous committed value, the configured operators, and the execution-time upper bound.

Example:

| Previous Committed Value | Lower Operator | Upper Operator | Upper Bound Strategy |
|---|---|---|---|
| `2026-07-01 00:00:00` | `>` | `<=` | `EXECUTION_START_TIME` |

If the execution starts at:

```text
2026-07-06 00:00:00
```

The generated filter can be interpreted as:

```sql
WHERE watermark_column >  '2026-07-01 00:00:00'
  AND watermark_column <= '2026-07-06 00:00:00'
```

The actual range used by the step is stored in `runtime.execution_watermarks`.

### Operator Behavior

| Operator | Use Case |
|---|---|
| `>` | Standard incremental load after the last committed value. |
| `>=` | Reprocesses the boundary value to avoid missing records. Requires idempotent load logic. |
| `<` | Reverse or special processing. Rare. |
| `<=` | Reverse or upper-bound processing. Rare. |
| `BETWEEN` | Explicit range processing, usually closer to batch or reprocessing scenarios. |

Recommended default for normal incremental loads:

```sql
WHERE watermark_column > previous_committed_value
  AND watermark_column <= extraction_upper_bound
```

## Important Design Distinctions

The runtime model separates control definitions, execution history, and changing runtime state.

| Distinction | Meaning | Why It Matters |
|---|---|---|
| Execution control vs execution history | Execution control defines what should run or what value controls the next execution. Execution history records what actually happened. | Separates planned behavior and current control state from execution evidence. |
| Execution plan vs execution run | An execution plan defines the controlled execution scope. An execution run records one actual project execution instance. | A plan is about intended execution; a run is about historical execution. |
| Execution plan process vs execution step | A plan process tracks readiness, waiting, blocking, and inclusion in the plan. An execution step records the result of an actual process execution. | A process can be waiting or blocked without having an execution step. |
| Plan state vs step status | Plan state tracks control behavior such as `READY`, `WAITING`, or `BLOCKED`. Step status tracks actual execution outcome such as `SUCCESS`, `FAILED`, or `OBSERVED`. | Keeps control-state management separate from execution result tracking. |
| Watermark control vs execution watermark | Watermark control stores the current rule and committed value. Execution watermark stores the actual range used by one execution step. | Separates current incremental control from watermark execution history. |
| Watermark column vs committed watermark value | The watermark column is defined in metadata. The committed watermark value is stored in runtime. | Metadata defines structure; runtime stores changing state. |
| Process hierarchy vs dependency enforcement | Process hierarchy and dependencies are defined in metadata. Runtime plan state can represent waiting or blocking, but orchestration still controls execution order. | Avoids describing metadata or runtime state as a full orchestration engine. |

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

## Source SQL Scripts

| Script | Relevant Content |
|---|---|
| `database/ddl/05_create_runtime_tables.sql` | Runtime execution plan, execution run, execution step, watermark control, watermark history, and related runtime tables. |
| `database/ddl/07_create_stored_procedures.sql` | Runtime procedures for plan, run, step, parent step, skipped step, and watermark behavior. |
| `database/ddl/10_create_views.sql` | Runtime review views. |
