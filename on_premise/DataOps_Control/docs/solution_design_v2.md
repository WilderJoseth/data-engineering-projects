# DataOps_Control v2 - Process Actions and Dependencies Design Note

## Purpose

This document captures the main v2 design changes for `DataOps_Control`.

The v2 direction improves the framework by moving orchestration decisions from table-level execution flags toward process-level execution metadata.

The main additions are:

- Process-level orchestration.
- Ordered process actions.
- Explicit process dependencies.
- Removal of ambiguous process `position` ordering.

## Background

In the current model, `runtime.execution_steps` represents the execution of a registered process from `metadata.project_processes`.

A process can control one table or multiple tables through `metadata.project_process_tables`.

Examples:

```text
AddressType Load
    -> AddressType

Geography Load
    -> CountryRegion
    -> StateProvince
    -> SalesTerritory
```

This means the framework should not assume that one process always equals one table.

Some processes are simple single-table loads. Other processes are grouped processes that orchestrate multiple related tables internally.

## Design Direction

For v2, orchestration should focus on process-level execution.

The parent ETL package or pipeline should:

1. Read executable child processes from metadata.
2. Evaluate process dependencies.
3. Loop over each process that is allowed to run.
4. Start one runtime execution step for the process.
5. Execute the ordered technical actions configured for that process.
6. Register validation, reconciliation, and error evidence as needed.
7. End the execution step as `Success`, `Observed`, `Failed`, or `Skipped`.

Conceptually:

```text
Parent process
    -> list executable child processes
        -> evaluate dependencies
            -> for each allowed process
                -> start execution step
                -> execute configured process actions
                -> write observability evidence
                -> end execution step
```

## Removal of project_processes.position

The `position` column in `metadata.project_processes` is removed in v2.

Reason:

```text
position suggests execution order,
but it does not define or enforce dependency.
```

A process can appear before another process for display or documentation purposes without being a true dependency.

Examples:

```text
Product Load depends on ProductCategory Load.
Product Load does not necessarily depend on every process listed before it.
```

Therefore, process ordering should not be inferred from a generic position value.

The replacement concepts are:

```text
parent_process_id
    -> process hierarchy or grouping

project_process_dependencies
    -> required execution dependencies

project_process_actions.position
    -> ordered technical actions inside one process
```

## New Metadata Concept: Process Dependencies

A process dependency represents a required execution relationship between two registered processes.

Recommended table:

```sql
CREATE TABLE [metadata].[project_process_dependencies]
(
    [project_process_id] INT NOT NULL,
    [dependency_project_process_id] INT NOT NULL,

    CONSTRAINT [pk_metadata_project_process_dependencies]
        PRIMARY KEY
        (
            [project_process_id],
            [dependency_project_process_id]
        ),

    CONSTRAINT [fk_metadata_project_process_dependencies_project_process_id]
        FOREIGN KEY ([project_process_id])
        REFERENCES [metadata].[project_processes]([id]),

    CONSTRAINT [fk_metadata_project_process_dependencies_dependency_project_process_id]
        FOREIGN KEY ([dependency_project_process_id])
        REFERENCES [metadata].[project_processes]([id]),

    CONSTRAINT [ck_metadata_project_process_dependencies_no_self_dependency]
        CHECK ([project_process_id] <> [dependency_project_process_id])
);
```

Relationship direction:

```text
project_process_id
    = process that depends on another process

dependency_project_process_id
    = process that must complete first
```

Example:

```sql
INSERT INTO [metadata].[project_process_dependencies]
(
    [project_process_id],
    [dependency_project_process_id]
)
VALUES
    (18, 11); -- Product Load depends on ProductCategory Load
```

## Why the Dependency Table Is Needed

Dependencies can exist at different levels:

```text
1. Dependencies between child processes under the same parent.
2. Dependencies between parent/group processes.
3. Cross-parent dependencies.
```

Examples:

```text
Same parent:
    StateProvince Load depends on CountryRegion Load

Parent-level:
    PKG_MASTER_DATA depends on PKG_REFERENCE_DATA

Cross-parent:
    Product Load under PKG_MASTER_DATA depends on ProductCategory Load under PKG_REFERENCE_DATA
```

`parent_process_id` can represent hierarchy, but it cannot represent these dependency rules.

The dependency table becomes the source of truth for required execution order.

## Dependency Enforcement Boundary

The table stores dependency metadata.

It does not, by itself, enforce runtime behavior.

The ETL/orchestration layer or future framework logic should use the dependency table to decide whether a process can run.

Recommended rule for v2:

```text
If a required dependency failed, the dependent process should be skipped.
```

Example:

```text
ProductCategory Load = Failed
Product Load = Skipped
```

This is better than marking `Product Load` as failed, because the process was not executed. It was intentionally skipped due to a failed prerequisite.

## New Metadata Concept: Process Actions

A process action represents one ordered technical operation executed as part of a process.

Examples of process actions:

- Load staging table.
- Validate and load work table.
- Register reconciliation results.
- Load final table.
- Execute grouped table load logic.

For example:

```text
AddressType Load
    1. Load staging table
    2. Validate and load work table
    3. Register reconciliation results
    4. Load final table
```

## Proposed Table: metadata.project_process_actions

```sql
CREATE TABLE [metadata].[project_process_actions]
(
    [id] INT NOT NULL,
    [project_process_id] INT NOT NULL,
    [position] SMALLINT NOT NULL,

    [action_name] VARCHAR(100) NOT NULL,
    [action_type] VARCHAR(30) NOT NULL,

    [execution_database_id] SMALLINT NULL,
    [schema_name] VARCHAR(50) NOT NULL,
    [object_name] VARCHAR(128) NOT NULL,

    [is_required] BIT NOT NULL,
    [is_active] BIT NOT NULL,
    [created_at] DATETIME2 NOT NULL,
    [created_by] VARCHAR(50) NOT NULL
);
```

Recommended constraints and defaults:

- Primary key on `id`.
- Foreign key from `project_process_id` to `metadata.project_processes(id)`.
- Foreign key from `execution_database_id` to `metadata.project_databases(id)`.
- Unique constraint on `(project_process_id, position)`.
- Default `is_required = 1`.
- Default `is_active = 1`.
- Default `created_at = SYSUTCDATETIME()`.
- Default `created_by = USER_NAME()`.

## Why execution_database_id Is Included

`execution_database_id` identifies where the executable action is located.

This is intentionally different from the database of the controlled table.

The existing relationship `metadata.project_process_tables` answers this question:

```text
Which controlled table or tables belong to this process?
```

The new `metadata.project_process_actions.execution_database_id` answers a different question:

```text
Where should the executable action be run?
```

Therefore:

```text
project_tables.database_id
    = database where the controlled table is registered

project_process_actions.execution_database_id
    = database where the executable action is located
```

## Relationship with project_process_tables

`metadata.project_process_tables` remains the source of truth for process-to-table execution scope.

It defines the table or tables that a process controls.

`metadata.project_process_actions` does not replace that relationship. It only describes the technical actions that run inside the process.

Recommended interpretation:

```text
metadata.project_processes
    -> logical process definition

metadata.project_process_dependencies
    -> required execution dependencies

metadata.project_process_tables
    -> controlled table scope for the process

metadata.project_process_actions
    -> ordered executable actions for the process

runtime.execution_steps
    -> one runtime record per process execution

observability.*
    -> validation, reconciliation, and error evidence for the process execution
```

## Validation and Reconciliation Boundary

The framework should continue to treat validation and reconciliation as process-level evidence.

For a single-table process, the validation may be directly related to one table.

For a grouped process, the validation may summarize multiple internal table operations.

Example:

```text
Geography Load
    -> CountryRegion
    -> StateProvince
    -> SalesTerritory
```

`Geography Load` should still be allowed to produce one process-level validation or reconciliation decision, even though it touches multiple tables internally.

## Recommended Orchestration Pattern

```text
1. Get executable child processes for a parent process.
2. For each candidate process, evaluate dependencies.
3. If dependencies are satisfied, start runtime.execution_steps.
4. Get active process actions ordered by position.
5. Execute each action using execution_database_id, schema_name, and object_name.
6. If an action fails, log the technical error and end the process step as Failed.
7. If dependencies failed before execution, mark or record the process as Skipped.
8. If actions complete but validation/reconciliation needs review, end the step as Observed.
9. Otherwise, end the step as Success.
```

## Design Boundary for v2

For the first v2 implementation, this feature should stay practical:

- Dependencies are stored explicitly.
- Actions are ordered by `project_process_actions.position`.
- One process execution creates one runtime execution step.
- Action metadata describes what the ETL layer should call.
- The framework does not become a full workflow engine yet.
- Circular dependency detection can be handled by a test script or future validation function.
- Dependency level calculation can be added later if needed.

## Summary

The v2 design separates five concerns:

```text
What belongs together?
    -> metadata.project_processes.parent_process_id

What must run before another process?
    -> metadata.project_process_dependencies

Which table or tables does the process control?
    -> metadata.project_process_tables

Which technical actions should run inside the process?
    -> metadata.project_process_actions

What happened during execution?
    -> runtime and observability schemas
```

This allows `DataOps_Control` to support loop-based ETL execution, ordered process actions, and explicit dependencies while keeping runtime tracking at the process level.

## Process Hierarchy Function: `metadata.ufn_list_process_children`

### Purpose

`metadata.ufn_list_process_children` lists all active descendant processes under a selected root process.

The function starts from one process id and returns its children, grandchildren, and deeper descendants until the last hierarchy level.

This function is intended for:

- Understanding the process hierarchy under a selected root process.
- Supporting ETL orchestration inspection.
- Identifying which descendant processes require execution.
- Showing whether each process has explicit dependencies.
- Debugging hierarchy configuration.

It does not calculate dependency levels or execution ranks.

### Function Signature

```sql
CREATE OR ALTER FUNCTION [metadata].[ufn_list_process_children]
(
    @p_root_project_process_id INT
)
RETURNS TABLE
```

### Input Parameter

| Parameter | Description |
|---|---|
| `@p_root_project_process_id` | Root process used as the hierarchy scope anchor. The root process itself is not returned. |

Example:

```sql
SELECT *
FROM [metadata].[ufn_list_process_children](1);
```

If process `1` is `Sales_Operational_Migration`, the function returns all active child processes under that operational migration root.

Example:

```text
Sales_Operational_Migration
    -> PKG_REFERENCE_DATA
        -> AddressType Load
        -> ProductCategory Load
        -> Geography Load
    -> PKG_MASTER_DATA
        -> CreditCard Load
        -> Product Load
        -> Customer Load
    -> PKG_TRANSACTIONAL_DATA
        -> Sales Load
```

### Output Columns

| Column | Description |
|---|---|
| `project_id` | Project that owns the process hierarchy. |
| `root_project_process_id` | Process id used as the function input. |
| `root_project_process_name` | Name of the selected root process. |
| `project_process_id` | Descendant process id returned by the function. |
| `project_process_name` | Descendant process name. |
| `parent_process_id` | Parent process of the returned process. |
| `parent_process_name` | Parent process name. |
| `hierarchy_level` | Structural depth under the selected root process. Direct children are level 1. |
| `table_count` | Number of active controlled tables assigned to the process through `metadata.project_process_tables`. |
| `execution_required` | Derived from assigned controlled tables. If at least one assigned table requires execution, the process requires execution. |
| `dependency_count` | Number of explicit dependencies registered for the process in `metadata.project_process_dependencies`. |
| `has_dependencies` | Boolean indicator derived from `dependency_count`. |
| `hierarchy_path` | Technical path used to represent the recursive traversal from the selected root process. |

### Important Column Meanings

#### `hierarchy_level`

`hierarchy_level` describes the structural depth of a process under the selected root process.

Example:

```text
Sales_Operational_Migration              root process, not returned
    PKG_REFERENCE_DATA                    hierarchy_level = 1
        AddressType Load                  hierarchy_level = 2
        ProductCategory Load              hierarchy_level = 2
```

This column is about hierarchy only. It does not define execution dependency.

#### `dependency_count`

`dependency_count` indicates how many explicit dependency rows exist for the process.

Example:

```text
Product Load
    dependency_count = 1
```

This means the process has one registered prerequisite process.

`dependency_count` does not identify the dependency by itself. Use a dependency-detail function or direct query against `metadata.project_process_dependencies` to see which processes are required.

#### `has_dependencies`

`has_dependencies` is a simple flag derived from `dependency_count`.

```text
dependency_count > 0 -> has_dependencies = 1
dependency_count = 0 -> has_dependencies = 0
```

This is useful for orchestration inspection because the ETL layer can easily identify processes that need dependency checks before execution.

#### `hierarchy_path`

`hierarchy_path` is a technical path used by the recursive query.

Example:

```text
/1/4/10/
```

This means:

```text
Sales_Operational_Migration
    -> PKG_REFERENCE_DATA
        -> AddressType Load
```

`hierarchy_path` is useful for debugging and cycle prevention. It should not be interpreted as execution order.

### Why Dependency Level Was Removed

An earlier design considered returning a `dependency_level` column.

That was removed from this core function because dependency level can become confusing when a function returns a full process subtree that mixes parent/group processes and table-level processes.

For example, a child process may have no direct dependency and appear as level 1, while its parent group depends on another parent group. This creates ambiguity unless dependency inheritance rules are explicitly implemented.

The v2 design keeps the function simpler:

```text
hierarchy_level
    = where the process is located in the process tree

dependency_count / has_dependencies
    = whether the process has explicit dependency metadata
```

Dependency ranking or parallel execution grouping can be added later as a separate advanced function if needed.

### Relationship with Process Dependencies

`metadata.ufn_list_process_children` does not replace `metadata.project_process_dependencies`.

The function only summarizes dependency presence.

The source of truth remains:

```text
metadata.project_process_dependencies
```

Relationship direction:

```text
project_process_id
    = process that depends on another process

dependency_project_process_id
    = process that must complete first
```

Example:

```sql
INSERT INTO [metadata].[project_process_dependencies]
(
    [project_process_id],
    [dependency_project_process_id]
)
VALUES
    (18, 11); -- Product Load depends on ProductCategory Load
```

### Relationship with Process Actions

The hierarchy function identifies which processes exist under a selected root and whether they require execution.

Once the orchestration layer selects a process to run, it should use the process action function to retrieve ordered actions for that specific process.

Recommended flow:

```text
1. Select a root process.
2. Call metadata.ufn_list_process_children(root_process_id).
3. Identify executable descendant or child processes.
4. For each process selected for execution:
       - start runtime execution step
       - call metadata.ufn_list_process_actions(process_id)
       - execute actions in position order
       - register observability evidence
       - end runtime execution step
```

### Recommended Usage

For process hierarchy inspection:

```sql
SELECT
    [hierarchy_level],
    [parent_process_name],
    [project_process_id],
    [project_process_name],
    [table_count],
    [execution_required],
    [dependency_count],
    [has_dependencies],
    [hierarchy_path]
FROM [metadata].[ufn_list_process_children](1)
ORDER BY
    [hierarchy_level],
    [parent_process_name],
    [project_process_name];
```

For an ETL package such as `PKG_REFERENCE_DATA`:

```sql
SELECT
    [project_process_id],
    [project_process_name],
    [table_count],
    [execution_required],
    [dependency_count],
    [has_dependencies]
FROM [metadata].[ufn_list_process_children](4)
WHERE [execution_required] = 1
ORDER BY
    [hierarchy_level],
    [project_process_name];
```

### Design Boundary

This function should not become a full dependency scheduler.

It should answer:

```text
Which processes are under this root?
How deep are they in the hierarchy?
Do they control tables?
Do they require execution?
Do they have explicit dependencies?
```

It should not answer:

```text
Which exact dependency must complete first?
Which process can run in parallel?
Which dependency level should run first?
```

Those concerns should be handled by separate dependency-detail functions, test scripts, or orchestration logic.

