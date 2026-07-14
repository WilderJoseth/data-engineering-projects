# DataOps_Control

`DataOps_Control` is a metadata-driven control framework for data engineering pipelines. It provides a SQL Server control database for operational metadata management, execution control, runtime tracking, observability, validation and reconciliation evidence, dependency-aware execution, and watermark control.

The framework does not move data itself. It supports external orchestration and execution tools such as SSIS, SQL Server Agent, Azure Data Factory, Fabric Data Pipelines, or custom services.

## Current v2 Capabilities

- Metadata configuration for projects, databases, tables, columns, process hierarchy, dependencies, actions, monitoring metrics, and notifications.
- Execution plans that define controlled execution scope.
- Plan process states with dependency-aware readiness.
- Execution runs and execution steps for actual runtime history.
- Runtime status model: `PENDING`, `READY`, `RUNNING`, `SUCCESS`, `FAILED`, `OBSERVED`, `BLOCKED`, `SKIPPED`, `CANCELLED`.
- Runtime watermark controls and per-step execution watermark history.
- Observability evidence for technical errors, validation results, reconciliation results, and monitoring results.
- Security roles with least-privilege executor access.
- Review views for metadata, runtime, watermark, and observability inspection.
- Functional scenario tests for happy path, failure, recovery, observed, skipped, cancellation, and watermark behavior.

## Architecture Summary

`DataOps_Control` is organized into four responsibility-based schemas:

| Schema | Purpose |
|---|---|
| `metadata` | Stores project configuration, process definitions, dependencies, table/column metadata, execution scope, actions, monitoring configuration, and notification metadata. |
| `runtime` | Stores execution plans, plan processes, execution runs, execution steps, committed watermark controls, and per-step watermark history. |
| `observability` | Stores technical errors, validation evidence, reconciliation evidence, and monitoring results. |
| `reference` | Stores controlled framework codes such as statuses, validation codes, and monitoring metric codes. |

## Deployment

Run the scripts against SQL Server in this order:

```text
database/ddl/01_create_database.sql
database/ddl/02_create_schemas.sql
database/ddl/03_create_reference_tables.sql
database/ddl/04_create_metadata_tables.sql
database/ddl/05_create_runtime_tables.sql
database/ddl/06_create_observability_tables.sql
database/ddl/07_create_stored_procedures.sql
database/ddl/08_create_functions.sql
database/ddl/09_create_security.sql
database/ddl/10_create_views.sql
database/seed/01_seed_reference_data.sql
```

Run `database/users/*` only when local SQL login/user setup is needed. Those scripts are templates for local/test access and are not required to create the framework objects.

The reference seed script is clean-database oriented and inserts fixed framework IDs. Re-running it against populated reference tables may fail unless cleanup is performed first.

## Validation Status

Final local deployment validation passed:

- Local fresh deployment completed with `sqlcmd -b`.
- All deployment scripts returned exit code `0`.
- Schemas, tables, procedures, views, seed data, and security grants were validated.
- Final deployment readiness: **Ready**.

See [deployment validation report](docs/review/00_deployment_validation_report_v2.md).

Functional validation passed:

- Happy-path runtime scenario passed.
- Failure/recovery scenario passed.
- Watermark commit and non-commit behavior passed.
- `OBSERVED`, `SKIPPED`, `CANCELLED`, `FAILED`, and `BLOCKED` behavior passed.
- Review views returned expected scenario rows.

See:

- [functional scenario test report](docs/review/00_functional_scenario_test_report.md)
- [failure/recovery scenario test report](docs/review/00_failure_recovery_scenario_test_report.md)
- [validation summary](docs/06_validation_summary.md)

## Status Model

Current implemented statuses:

- `PENDING`
- `READY`
- `RUNNING`
- `SUCCESS`
- `FAILED`
- `OBSERVED`
- `BLOCKED`
- `SKIPPED`
- `CANCELLED`

`WAITING` and `REQUIRES_RERUN` are not part of the current implemented model.

## Key Documentation

- [Project standards](docs/00_project_standards.md)
- [Framework data model](docs/01_framework_data_model.md)
- [Metadata design](docs/02_metadata_design.md)
- [Runtime design](docs/03_runtime_design.md)
- [Observability design](docs/04_observability_design.md)
- [Security and roles](docs/05_security_and_roles.md)
- [Validation summary](docs/06_validation_summary.md)

Validation and review reports:

- [Design/implementation gap review v3](docs/review/00_design_implementation_gap_review_v3.md)
- [Project standards review v2](docs/review/00_project_standards_review_v2.md)
- [Deployment validation report v2](docs/review/00_deployment_validation_report_v2.md)
- [Functional scenario test report](docs/review/00_functional_scenario_test_report.md)
- [Failure/recovery scenario test report](docs/review/00_failure_recovery_scenario_test_report.md)

## Boundaries

`DataOps_Control` is intentionally focused on operational control metadata. It does not:

- Replace an enterprise data catalog.
- Replace enterprise IAM or access governance.
- Perform data movement.
- Deliver notifications directly; notification delivery is future or external.
- Automatically generate recovery plans; recovery and reprocessing use plan types and caller-selected scope.

## Repository Structure

```text
database/
|-- ddl/      # Database, schema, table, procedure, function, security, and view scripts
|-- seed/     # Framework reference seed data
|-- tests/    # Smoke and functional scenario tests
|-- users/    # Optional local/test login and user templates
`-- cleanup/  # Cleanup scripts for framework objects and seeded data

docs/
|-- review/   # Validation and review reports
|-- img/      # Data model images
`-- *.md      # Design and validation documentation
```
