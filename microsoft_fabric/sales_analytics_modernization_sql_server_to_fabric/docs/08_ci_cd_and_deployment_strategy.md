# CI/CD and Deployment Strategy

## Document Goal

This document defines the CI/CD and deployment strategy for the Sales Analytics Modernization project.

The goal is to describe how development, testing, and production changes are managed, versioned, configured, and promoted across the target reporting platform.

This document focuses on deployment strategy and environment management. It does not define detailed pipeline implementation, security permissions, or operational runbook procedures.

## CI/CD Strategy Overview

The CI/CD strategy is based on environment separation, source control, controlled promotion, and environment-specific configuration.

| Area | Strategy |
|---|---|
| Environment separation | Use separate environments for development, testing, and production workloads |
| Source control | Store project artifacts, scripts, notebooks, and documentation in Git |
| Deployment promotion | Promote approved changes from development to test and then to production |
| Configuration management | Keep environment-specific values outside reusable code where possible |
| Release validation | Validate deployed objects before they are accepted for reporting use |
| Rollback support | Use source control and controlled deployment steps to support recovery from failed releases |

## Environment Strategy

The project uses separate environments to reduce risk and isolate development activity from trusted reporting workloads.

| Environment | Purpose | Expected Usage |
|---|---|---|
| Development | Build and modify project objects | Used for active development, experimentation, and unit-level testing |
| Test | Validate releases before production | Used for deployment testing, integration checks, and release validation |
| Production | Host trusted reporting workloads | Used for accepted data pipelines, Gold reporting objects, and the Power BI semantic model |

Each environment should use equivalent logical components, but with environment-specific names, connections, and configuration values.

## Fabric Workspace Strategy

Fabric workspaces should be separated by environment.

| Environment | Workspace Purpose | Example Naming Pattern |
|---|---|---|
| Development | Development workspace for building Fabric objects | `ws_sales_modernization_dev` |
| Test | Testing workspace for validating promoted changes | `ws_sales_modernization_test` |
| Production | Production workspace for trusted reporting workloads | `ws_sales_modernization_prod` |

Workspace separation helps prevent development changes from affecting production reporting.

## Target Component Strategy by Environment

Each environment should contain its own Fabric target components.

| Component | Development | Test | Production |
|---|---|---|---|
| Lakehouse | Development Lakehouse objects | Test Lakehouse objects | Production Lakehouse objects |
| Warehouse | Development Warehouse objects | Test Warehouse objects | Production Warehouse objects |
| Pipelines / Dataflows | Development orchestration | Test orchestration | Production orchestration |
| Notebooks | Development transformation logic | Tested transformation logic | Approved transformation logic |
| Semantic Model | Development semantic model | Test semantic model | Production semantic model |

Production components should only receive approved changes through the deployment process.

## Source Control Strategy

Git is used as the source control system for project artifacts.

| Artifact Type | Source Control Strategy |
|---|---|
| Documentation | Stored in Git as Markdown files |
| SQL scripts | Stored in Git and organized by object type or deployment purpose |
| Notebooks | Stored in Git where supported by Fabric lifecycle management |
| Pipelines | Stored in Git where supported by Fabric lifecycle management |
| Semantic model definitions | Stored in Git or managed through Fabric-supported lifecycle features where applicable |
| Configuration templates | Stored in Git without environment secrets |
| Environment-specific values | Managed through parameters, variables, deployment rules, or secure configuration mechanisms |

Git should be treated as the authoritative source for project documentation and deployable artifacts.

## Repository Organization

The repository should separate documentation, source scripts, Fabric artifacts, and deployment assets.

| Repository Area | Purpose |
|---|---|
| `/docs` | Architecture, strategy, and project documentation |
| `/sql` | SQL scripts for Warehouse, control objects, and utility objects |
| `/notebooks` | Notebook-based transformation and processing logic |
| `/pipelines` | Pipeline definitions or deployment references where applicable |
| `/semantic-model` | Semantic model definitions or related metadata where applicable |
| `/deployment` | Deployment scripts, release checklists, and environment configuration templates |
| `/tests` | Validation, reconciliation, and smoke-test scripts |

The exact repository layout may evolve as Fabric artifacts and deployment methods are finalized.

## Branching Strategy

The project should use a simple branching model.

| Branch | Purpose |
|---|---|
| `main` | Represents production-ready approved content |
| `develop` | Represents integrated development content ready for test validation |
| Feature branches | Used for specific changes, fixes, or enhancements |

Changes should be reviewed before they are merged into `main`.

For a portfolio implementation, the branching strategy should remain simple and easy to maintain.

## Deployment Flow

Changes should follow a controlled promotion path.

| Step | Description |
|---|---|
| 1. Develop | Build or modify objects in the development environment |
| 2. Commit | Save changes to Git with a meaningful commit message |
| 3. Review | Review code, scripts, configuration, and documentation updates |
| 4. Promote to Test | Deploy approved changes to the test environment |
| 5. Validate | Run deployment checks, smoke tests, and reconciliation checks where applicable |
| 6. Promote to Production | Deploy validated changes to the production environment |
| 7. Confirm Release | Confirm that production objects are available and reporting outputs are stable |

Production deployment should not be performed directly from unreviewed development changes.

## Deployment Scope

Deployment scope depends on the artifact type.

| Artifact | Deployment Approach |
|---|---|
| Lakehouse objects | Promote supported Fabric items and deploy required schema/table scripts where needed |
| Warehouse objects | Deploy schema, table, view, and stored procedure scripts through controlled SQL deployment |
| Notebooks | Promote through Fabric lifecycle management where supported |
| Pipelines | Promote through Fabric lifecycle management where supported |
| Semantic Model | Promote through Fabric lifecycle management or semantic-model deployment process where supported |
| Documentation | Promote through Git review and repository release process |
| Configuration | Apply environment-specific values during or after deployment |

Some Fabric items may require a hybrid approach that combines Fabric deployment features with SQL scripts or manual configuration steps.

## Configuration Strategy

Configuration must be separated from reusable logic.

| Configuration Type | Example | Strategy |
|---|---|---|
| Environment names | Dev, Test, Prod | Managed by deployment configuration |
| Workspace names | Fabric workspace per environment | Environment-specific value |
| Lakehouse names | `lh_sales_operational` or environment-specific equivalent | Environment-specific value |
| Warehouse names | `wh_sales_analytics` or environment-specific equivalent | Environment-specific value |
| Connection values | SQL Server, Warehouse, Lakehouse, control database connections | Managed through secure environment configuration |
| Runtime parameters | Batch period, source system, load mode | Managed through pipeline or control metadata |
| Secrets | Passwords, keys, tokens | Must not be stored directly in Git |

Reusable code should reference configuration values instead of hardcoding environment-specific settings.

## Deployment Validation

Each deployment should be validated before it is accepted.

| Validation Area | Expected Check |
|---|---|
| Object availability | Confirm deployed objects exist in the target environment |
| Schema consistency | Confirm expected schemas, tables, views, and columns are available |
| Pipeline availability | Confirm required orchestration objects are deployed and runnable |
| Notebook availability | Confirm required notebooks are deployed and linked correctly |
| Configuration | Confirm environment-specific values point to the correct environment |
| Data validation | Run selected validation and reconciliation checks after data loads |
| Reporting validation | Confirm the semantic model and reports connect to the correct Gold objects |

Deployment validation should be lightweight but sufficient to prevent broken releases from reaching reporting users.

## Release Control

Production releases should be controlled and traceable.

| Control | Description |
|---|---|
| Release notes | Summarize what changed in the release |
| Approval | Confirm the release is approved before production deployment |
| Deployment log | Record what was deployed, when, and by whom |
| Validation result | Confirm release validation completed successfully |
| Rollback plan | Identify how to recover if the release fails |

For this project, release control can be lightweight, but it should still be explicit.

## Rollback Strategy

Rollback depends on the type of change.

| Change Type | Rollback Approach |
|---|---|
| Documentation | Revert Git commit or restore prior version |
| SQL object change | Redeploy previous SQL script version or restore prior object definition |
| Notebook change | Revert to previous Git version and redeploy |
| Pipeline change | Revert to previous Git or deployed version |
| Semantic model change | Revert to previous approved semantic model version where supported |
| Configuration issue | Restore prior environment-specific configuration values |
| Data issue | Rerun the affected object, batch, or period according to the load strategy |

Rollback should prioritize restoring trusted reporting behavior as quickly as possible.

## Assumptions and Constraints

| Type | Statement | Description |
|---|---|---|
| Assumption | Fabric workspaces are separated by environment | Development, test, and production workloads are isolated from each other |
| Assumption | Git is used for source control | Project artifacts and deployment assets are versioned in a repository |
| Assumption | Deployment features may vary by Fabric item type | Some objects may require Fabric deployment features while others may require scripts or manual configuration |
| Requirement | Production changes must be reviewed | Production should only receive approved changes |
| Requirement | Environment-specific configuration must be isolated | Secrets and environment values must not be hardcoded into reusable artifacts |
| Constraint | Control database design is still evolving | Detailed DataOps control deployment behavior will be documented separately when finalized |

## Conclusion

The CI/CD and deployment strategy defines how project artifacts are versioned, validated, and promoted across development, test, and production environments.

The strategy uses environment separation, Git-based source control, controlled deployment promotion, and environment-specific configuration to reduce deployment risk.

This approach supports a stable target reporting platform by ensuring that changes are reviewed, tested, traceable, and recoverable before they are accepted into production.
