# Security and Roles

## Purpose

Describe the `DataOps_Control` database security model, role responsibilities, permissions, and access boundaries.

SQL scripts remain the source of truth for exact grants.

## Framework Security Scope

Security in this project means framework-level security for `DataOps_Control`.

| Security Area | Framework Responsibility |
|---|---|
| Metadata configuration | Control who can maintain project, system, object, process, scope, metric, and notification metadata. |
| Runtime execution | Control who can execute approved runtime procedures and create execution state/history. |
| Observability evidence | Control who can publish and review error, validation, reconciliation, and monitoring evidence. |
| Reference data | Control who can maintain or read reusable framework codes. |

The framework does not replace enterprise IAM, access approval, or broader access governance workflows.

## Role Responsibilities

| Role | Intended Users | Responsibility |
|---|---|---|
| `DataOps_Admin` | Framework maintainers, deployment scripts, administrative users | Maintains framework objects, metadata, reference data, and administrative configuration. |
| `DataOps_Project_Executor` | SSIS packages, SQL Server Agent jobs, Azure Data Factory pipelines, Fabric Data Pipelines, custom execution services | Reads framework metadata, executes approved runtime/observability procedures, and writes execution evidence. |

## Access Responsibility Model

| Responsibility | Expected Access Pattern |
|---|---|
| Administration / configuration | Can manage metadata and reference configuration through controlled administrator, configuration, or deployment processes. |
| Execution | Can read metadata, execute framework procedures, and write runtime or observability records as needed for execution. |
| Reader / reviewer | Can inspect metadata, runtime history, and observability evidence without changing framework configuration. |
| Direct table updates | Should be restricted where possible, especially for executor identities. |

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
| `DataOps_Project_Executor` | `observability.usp_log_error` | `EXECUTE` through `observability` schema | Publish technical error records through the approved logging procedure. |

## Least Privilege Model

| Principle | Description | Why This Is Enough |
|---|---|---|
| Separate administration from execution | Administrative users maintain framework configuration. Project service accounts execute against that configuration. | Executors do not need to change metadata definitions to run controlled processes. |
| Read-only metadata for executors | Pipeline tools can read metadata needed for orchestration but cannot change framework definitions through executor role permissions. | Process, table, batch, dependency, and action metadata can be consumed with `SELECT` access only. |
| Read-only reference data for executors | Pipeline tools can read standard status, validation, and metric codes but cannot modify them. | Execution logic needs stable codes for consistency, but code maintenance is an administrative task. |
| Controlled runtime updates | Execution lifecycle should be handled through stored procedures instead of direct table updates. | Executors can start and close runs or steps without broad direct modification rights on runtime tables. |
| Evidence publishing only where required | Executor accounts can directly publish validation, reconciliation, and monitoring evidence. Technical error logging is procedure-only through `observability.usp_log_error`. | Runtime evidence can be captured without allowing changes to framework configuration. |
| Project-specific identities | Each consuming project should use its own login or service account mapped to a database user. | Access can be reviewed, isolated, revoked, or audited per consuming project. |

## Metadata and Evidence Protection

| Area | Rule |
|---|---|
| Metadata | Normal runtime execution should not modify metadata tables. Metadata changes should happen through administrator, configuration, or deployment processes. |
| Runtime | Runtime procedures may insert or update execution state and history according to framework lifecycle rules. |
| Observability | Observability procedures may insert evidence records. Evidence should remain append-only during normal execution. |
| Direct updates | Direct table updates should be reserved for controlled administration, correction, or deployment scenarios. |

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
| Enterprise access governance | Enterprise access approval workflows are outside the framework scope. |
| Enterprise IAM workflows | Identity lifecycle, provisioning workflows, and enterprise IAM policy management are outside the framework scope. |
| Business stewardship workflows | Governance stewardship, approvals, and ownership workflows are outside the framework scope. |
| Privacy and compliance management | Full privacy/compliance management is outside current scope or future scope. |
| Sensitive data classification | Sensitive data classification workflows are future scope unless explicitly implemented. |

## Source SQL Scripts

| Script | Relevant Content |
|---|---|
| `database/ddl/09_create_security.sql` | Role creation and permission grants. |
| `database/users/01_create_project_executor_user.sql` | Example project executor user setup. |
| `database/users/02_create_dataops_admin_user.sql` | Example admin user setup. |
