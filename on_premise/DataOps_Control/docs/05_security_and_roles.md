# Security and Roles

## Purpose

Describe the `DataOps_Control` database security model, role responsibilities, permissions, and access boundaries.

SQL scripts remain the source of truth for exact grants.

## Role Responsibilities

| Role | Intended Users | Responsibility |
|---|---|---|
| `DataOps_Admin` | Framework maintainers, deployment scripts, administrative users | Maintains framework objects, metadata, reference data, and administrative configuration. |
| `DataOps_Project_Executor` | SSIS packages, SQL Server Agent jobs, Azure Data Factory pipelines, Fabric Data Pipelines, custom execution services | Reads framework metadata, executes approved runtime/observability procedures, and writes execution evidence. |

## Permission Summary

| Role | Permission Area | Granted Access | Objective |
|---|---|---|---|
| `DataOps_Admin` | `metadata` schema | `SELECT`, `INSERT`, `UPDATE`, `DELETE` | Maintain framework metadata and configuration. |
| `DataOps_Admin` | `reference` schema | `SELECT`, `INSERT`, `UPDATE`, `DELETE` | Maintain reusable status, validation, and metric codes. |
| `DataOps_Admin` | `runtime` schema | `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `EXECUTE` | Support administrative correction, troubleshooting, and runtime procedure execution. |
| `DataOps_Admin` | `observability` schema | `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `EXECUTE` | Support administrative correction, troubleshooting, and observability procedure execution. |
| `DataOps_Project_Executor` | `metadata` schema | `SELECT` | Read process, table, batch, dependency, and action metadata required for execution. |
| `DataOps_Project_Executor` | `reference` schema | `SELECT` | Read standard status, validation, and metric codes. |
| `DataOps_Project_Executor` | `runtime` schema | `SELECT`, `EXECUTE` | Start and close execution runs and steps through approved runtime procedures. |
| `DataOps_Project_Executor` | `observability` schema | `SELECT`, `EXECUTE` | Execute approved observability procedures and read captured evidence for troubleshooting. |
| `DataOps_Project_Executor` | `observability.validation_results` | `INSERT` | Publish validation result records produced by external pipeline tools. |
| `DataOps_Project_Executor` | `observability.reconciliation_results` | `INSERT` | Publish reconciliation result records produced by external pipeline tools. |
| `DataOps_Project_Executor` | `observability.monitoring_results` | `INSERT` | Publish monitoring result records produced by external pipeline tools. |
| `DataOps_Project_Executor` | `observability.error_logs` | `INSERT` | Publish error records produced during process execution. |

## Least Privilege Model

| Principle | Description | Why This Is Enough |
|---|---|---|
| Separate administration from execution | Administrative users maintain framework configuration. Project service accounts execute against that configuration. | Executors do not need to change metadata definitions to run controlled processes. |
| Read-only metadata for executors | Pipeline tools can read metadata needed for orchestration but cannot change framework definitions through executor role permissions. | Process, table, batch, dependency, and action metadata can be consumed with `SELECT` access only. |
| Read-only reference data for executors | Pipeline tools can read standard status, validation, and metric codes but cannot modify them. | Execution logic needs stable codes for consistency, but code maintenance is an administrative task. |
| Controlled runtime updates | Execution lifecycle should be handled through stored procedures instead of direct table updates. | Executors can start and close runs or steps without broad direct modification rights on runtime tables. |
| Evidence publishing only where required | Executor accounts can publish validation, reconciliation, monitoring, and error evidence without broad metadata or reference permissions. | Runtime evidence can be captured without allowing changes to framework configuration. |
| Project-specific identities | Each consuming project should use its own login or service account mapped to a database user. | Access can be reviewed, isolated, revoked, or audited per consuming project. |

## Recommended Access Path

```text
Project service account
    -> Database user in DataOps_Control
        -> DataOps_Project_Executor
```

Administrative access follows a separate path:

```text
Framework maintainer
    -> Database user in DataOps_Control
        -> DataOps_Admin
```

## User and Login Boundary

The framework security script does not create SQL Server logins or database users.

| Item | Responsibility |
|---|---|
| SQL Server login | Created outside the framework role script. |
| Database user | Created or mapped outside the framework role script. |
| Role membership | Assigned after the database user exists. |
| Secrets | Managed outside `DataOps_Control`. |

## Known Boundaries

| Area | Current Boundary |
|---|---|
| Fine-grained project isolation | Roles are framework-level roles. Per-project row-level security is not implemented. |
| Login/user provisioning | Logins and users are handled outside the main security role script. |
| Secret storage | Secrets are not stored or managed by the framework tables. |
| Notification delivery security | Notification metadata exists, but delivery execution and delivery credentials are outside the current security model. |
| Direct runtime table writes | `DataOps_Admin` can maintain runtime tables directly. Executor access is intended to use procedures. |

## Source SQL Scripts

| Script | Relevant Content |
|---|---|
| `database/ddl/09_create_security.sql` | Role creation and permission grants. |
| `database/users/01_create_project_executor_user.sql` | Example project executor user setup. |
| `database/users/02_create_dataops_admin_user.sql` | Example admin user setup. |
