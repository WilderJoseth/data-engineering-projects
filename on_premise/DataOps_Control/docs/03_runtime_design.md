# Runtime Design

## Purpose

This document describes how the `runtime` schema records and controls execution activity for `DataOps_Control`.

It covers execution plans, plan state, execution history, status behavior, dependency enforcement, parent/group status derivation, recovery, reprocessing, watermark control, and watermark history.

SQL scripts remain the source of truth for exact table and procedure definitions.

## Runtime Model Overview

The `runtime` schema has two main responsibilities:

| Runtime Layer | Purpose | Answers | Tables |
|---|---|---|---|
| Execution control layer | Defines planned execution scope, readiness state, and committed runtime control values. | What should run, what is ready, what is pending, what is blocked, and what watermark value controls the next execution. | `runtime.execution_plans`, `runtime.execution_plan_processes`, `runtime.execution_watermark_controls` |
| Execution history layer | Records project runs, process steps, and watermark ranges used during execution. | What actually ran, when it ran, how it ended, and what watermark range was used. | `runtime.execution_runs`, `runtime.execution_steps`, `runtime.execution_watermarks` |

## Runtime Plan Management

An execution plan defines the controlled process scope for one execution attempt.

| Concept | Table | Runtime Layer | Responsibility |
|---|---|---|---|
| Execution plan | `runtime.execution_plans` | Execution control layer | Defines one controlled execution scope for a project, plan type, and selected root or scope. |
| Execution plan process | `runtime.execution_plan_processes` | Execution control layer | Stores included processes and their current control state inside the plan. |

### Relationship Summary

| Object | Role |
|---|---|
| `metadata.project_processes` | Defines all possible controlled processes. |
| `metadata.project_process_dependencies` | Defines dependency relationships between processes. |
| `runtime.execution_plans` | Groups selected processes into one execution control scope. |
| `runtime.execution_plan_processes` | Stores process-level readiness and control state within the plan. |
| `runtime.execution_runs` | Records the actual execution created from the plan. |

### Plan Lifecycle Rules

| Phase | Runtime Rule |
|---|---|
| Plan creation | Create a plan from validated metadata, plan type, and selected execution scope. |
| Metadata validation | Validate project, processes, dependencies, actions, scope, batches, and watermarks before activation. |
| Plan activation | Activate the plan only after validation succeeds. |
| Dependency evaluation | Set plan processes to `READY`, `PENDING`, `BLOCKED`, `SKIPPED`, or another valid state. |
| Run creation | Create an execution run from an active plan. |
| State updates | Update plan process state as execution steps start, finish, fail, block, or are skipped. |
| Closure | Close the plan when all included processes reach a final state. |
| Cancellation | Preserve completed history and mark remaining plan scope according to cancellation policy. |
| Recovery decision | Create a new recovery, rerun, reprocessing, or backfill plan when additional execution is needed. |

### Plan Reuse Rules

| Scenario | Reuse Same Plan? | Recommended Behavior |
|---|---:|---|
| Continue the same active execution attempt | Maybe | Continue only when it is the same controlled attempt. |
| Recovery after failure or blocking | No | Create a new recovery plan. |
| Manual rerun | No | Create a new manual or rerun plan. |
| Reprocessing existing data | No | Create a new reprocessing plan. |
| Backfill historical data | No | Create a new backfill plan. |
| Unrelated execution attempt | No | Create a separate plan. |

Plans should not be reused for unrelated execution attempts because the plan is part of execution control history.

### Plan State vs Run and Step Status

Plan state describes control readiness. Run and step status describe actual execution outcomes.

| Term | Applies To | Purpose | Examples |
|---|---|---|---|
| Plan state | Execution plan process | Tracks readiness and control state before, during, and after execution. | `PENDING`, `READY`, `RUNNING`, `BLOCKED`, `CANCELLED` |
| Run status | Execution run | Tracks the project-level execution outcome. | `SUCCESS`, `RUNNING`, `FAILED`, `OBSERVED`, `SKIPPED` |
| Step status | Execution step | Tracks the process-level execution outcome. | `SUCCESS`, `RUNNING`, `FAILED`, `OBSERVED`, `SKIPPED` |

### Status Transition Rules

Runtime status changes should follow controlled transitions. Direct manual changes should be avoided.

| From | To | Meaning |
|---|---|---|
| `PENDING` | `READY` | Required conditions are satisfied. |
| `PENDING` | `BLOCKED` | A required dependency failed or was blocked. |
| `READY` | `RUNNING` | Execution starts. |
| `RUNNING` | `SUCCESS` | Execution completed successfully. |
| `RUNNING` | `FAILED` | Execution failed. |
| `RUNNING` | `OBSERVED` | Execution completed with non-blocking evidence requiring attention. |

Blocked transitions:

| From | To | Why Blocked |
|---|---|---|
| `SUCCESS` | `RUNNING` | Requires a new plan, rerun, recovery, or reprocessing scope. |
| `FAILED` | `SUCCESS` | Failed work must execute again before becoming successful. |
| `BLOCKED` | `SUCCESS` | A blocked process did not execute. |
| `PENDING` | `SUCCESS` | A process should not succeed without execution or explicit derivation. |

### Dependency Enforcement Behavior

Dependency relationships are stored in `metadata.project_process_dependencies`. Runtime logic, procedures, functions, or views enforce whether a planned process can run.

| Dependency Outcome | Dependent Process State |
|---|---|
| All dependencies are `SUCCESS` | `READY` |
| Any dependency is `FAILED` or `BLOCKED` | `BLOCKED` |
| Any included dependency has another status, including `PENDING`, `RUNNING`, `OBSERVED`, `SKIPPED`, or `CANCELLED` | Keep dependent process `PENDING` unless external logic changes the policy. |

Dependencies between executable processes are blocking by default. Dependencies involving parent/group processes may be informational unless runtime logic handles them explicitly.

## Runtime Execution History Management

Runtime Execution History Management records what actually happened during project and process execution.

| Concept | Table | Runtime Layer | Responsibility |
|---|---|---|---|
| Execution run | `runtime.execution_runs` | Execution history layer | Stores one actual project-level execution instance. |
| Execution step | `runtime.execution_steps` | Execution history layer | Stores one actual process-level execution instance inside a run. |

### Core Design Rules

| Rule | Description |
|---|---|
| Runs record project execution | Each execution run represents one actual execution of a registered project. |
| Steps record process execution | Each execution step represents one runtime instance of a metadata process. |
| Metadata remains reusable | Runtime records do not replace metadata definitions. |
| Statuses are standardized | Run and step statuses use `reference.status_codes`. |
| Duration is timestamp-based | Execution duration is derived from start and end timestamps. |
| Run status is derived from steps | A run can be closed as `SUCCESS`, `FAILED`, or `OBSERVED` based on related step outcomes. |
| Skipped steps are recorded | Skipped child processes can be registered as execution steps for traceability. |

### Execution Run Closure Logic

| Runtime Condition | Final Run Behavior |
|---|---|
| Run has no steps | Run is closed as `OBSERVED`. |
| Any step is `PENDING` or `RUNNING` | Run cannot be closed. |
| Any step is `FAILED` | Run is closed as `FAILED`. |
| No failed steps, but at least one step is `OBSERVED` | Run is closed as `OBSERVED`. |
| Otherwise | Run is closed as `SUCCESS`. |

### Parent / Group Process Status Rules

Current parent step closure derives status mainly from direct child execution steps.

| Direct Child Condition | Parent / Group Result |
|---|---|
| All children are `SUCCESS` | `SUCCESS` |
| Any child is `FAILED` | `FAILED` |
| Any child is `OBSERVED` and none failed | `OBSERVED` |
| Successful and skipped children with no failures or observed children | `SUCCESS` |

Parent/group derivation uses direct children only unless recursive aggregation is explicitly added later. Broader `BLOCKED`, `SKIPPED`, or `CANCELLED` parent/group derivation may be handled at the plan-process level or added as a future enhancement.

### Recovery and Reprocessing Rules

Recovery and reprocessing define what should run again without overwriting previous execution history.

Automated recovery plan generation is not implemented in SQL yet. Recovery, rerun, reprocessing, and backfill are supported through plan types and caller-selected execution scope.

| Term | Meaning |
|---|---|
| Recovery | Rerun failed or blocked scope after an execution problem. |
| Rerun | Execute a selected process again, manually or as part of recovery. |
| Reprocessing | Intentionally reload existing data, usually for a known range or object. |
| Backfill | Load historical data that was not previously processed. |

#### Recovery Scope

| Previous Status | Include in Recovery? | Rule |
|---|---:|---|
| `FAILED` | Yes | The process attempted execution and failed. |
| `BLOCKED` | Yes | The process did not run because upstream work failed or blocked. |
| `OBSERVED` | Maybe | Depends on severity or user decision. |
| `SUCCESS` | No, by default | Successful unrelated work should not rerun by default. |
| `SKIPPED` | No, by default | Include only when explicitly selected. |

Recovery creates a new execution plan and new runtime history. It should not overwrite the previous plan, run, steps, or observability evidence.

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

### Watermark Commit Rules

Watermark commits should be conservative. Commit only after successful execution and after blocking validation and reconciliation rules pass.

| Final Outcome | Commit Watermark? | Rule |
|---|---:|---|
| `SUCCESS` | Yes | Execution completed and blocking checks passed. |
| `FAILED` | No | Execution or blocking evidence failed. |
| `BLOCKED` | No | Process did not execute. |
| `SKIPPED` | No | Process was intentionally excluded. |
| `OBSERVED` | Depends | Commit only when evidence is explicitly non-blocking and accepted by rule. |

### Range Calculation

An incremental range is created from the previous committed value, configured operators, and execution-time upper bound.

| Previous Committed Value | Lower Operator | Upper Operator | Upper Bound Strategy |
|---|---|---|---|
| `2026-07-01 00:00:00` | `>` | `<=` | `EXECUTION_START_TIME` |

Recommended default for normal incremental loads:

```sql
WHERE watermark_column > previous_committed_value
  AND watermark_column <= extraction_upper_bound
```

## Important Design Distinctions

| Distinction | Meaning | Why It Matters |
|---|---|---|
| Execution control vs execution history | Execution control defines what should run or what value controls the next execution. Execution history records what actually happened. | Separates planned behavior and current control state from execution evidence. |
| Execution plan vs execution run | An execution plan defines controlled execution scope. An execution run records one actual project execution instance. | A plan is intended execution; a run is historical execution. |
| Execution plan process vs execution step | A plan process tracks readiness and inclusion in the plan. An execution step records actual process execution. | A process can be not ready or blocked without having an execution step. |
| Plan state vs step status | Plan state tracks readiness and control. Step status tracks actual execution outcome. | Prevents mixing control state with execution result. |
| Dependency metadata vs enforcement | Metadata stores relationships. Runtime logic enforces readiness. | Keeps metadata definitions separate from runtime decisions. |
| Watermark control vs execution watermark | Watermark control stores current rule and committed value. Execution watermark stores the range used by one step. | Separates current incremental control from execution history. |

## Runtime Procedures and Views

| Object Type | Name | Purpose |
|---|---|---|
| Procedure | `runtime.usp_create_execution_plan` | Creates a pending execution plan for a project and plan type. |
| Procedure | `runtime.usp_add_execution_plan_process` | Adds one process to an execution plan. |
| Procedure | `runtime.usp_evaluate_execution_plan_dependencies` | Evaluates included process dependencies and sets plan process readiness. |
| Procedure | `runtime.usp_close_execution_plan` | Closes or cancels an execution plan after plan processes reach valid closure states. |
| Procedure | `runtime.usp_start_execution_run` | Creates a running execution run for an active project, optionally linked to an execution plan. |
| Procedure | `runtime.usp_start_execution_step` | Creates a running execution step for an active process, optionally linked to a ready plan process. |
| Procedure | `runtime.usp_end_execution_step` | Closes an execution step using a caller-provided final status. |
| Procedure | `runtime.usp_end_parent_execution_step` | Closes a parent execution step using direct child step statuses. |
| Procedure | `runtime.usp_register_skipped_child_execution_steps` | Creates skipped execution step records for active direct child processes that are not required for execution. |
| Procedure | `runtime.usp_end_execution_run` | Closes a run and derives the final run status from related execution steps. |
| Procedure | `runtime.usp_register_execution_watermark` | Registers the watermark range used by an execution step. |
| Procedure | `runtime.usp_commit_execution_watermark` | Finalizes watermark history and commits the control value only for allowed outcomes. |
| View | `runtime.vw_execution_run_summary` | Returns execution run status, project context, run dates, and run duration for review. |
| View | `runtime.vw_execution_step_summary` | Returns execution step status, project/process context, step dates, and step duration for review. |
| View | `runtime.vw_execution_plan_summary` | Returns execution plan status, project context, plan dates, and duration for review. |
| View | `runtime.vw_execution_plan_process_summary` | Returns plan process status, process context, and dependency evaluation details. |
| View | `runtime.vw_execution_watermark_summary` | Returns watermark controls and optional execution watermark history. |

## Source SQL Scripts

| Script | Relevant Content |
|---|---|
| `database/ddl/05_create_runtime_tables.sql` | Runtime execution plan, execution run, execution step, watermark control, watermark history, and related runtime tables. |
| `database/ddl/07_create_stored_procedures.sql` | Runtime procedures for plan, run, step, parent step, skipped step, and watermark behavior. |
| `database/ddl/10_create_views.sql` | Runtime review views. |
