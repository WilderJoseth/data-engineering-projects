# CI/CD and Deployment Strategy

## Document Goal

This document defines the CI/CD and deployment strategy for the Sales Reporting Modernization project.

The purpose is to describe how the current Fabric project is organized across environments, workspaces, Fabric items, connections, repository branches, and deployment promotion.

This document reflects the current project setup. It is not intended to be a generic CI/CD implementation manual.

## Environment and Deployment Strategy

Workspace names include the environment suffix because the workspace is the main deployment boundary. The deployment pipeline promotes approved Fabric items from development to production.

| Environment | Suffix | Workspace Name | Deployment Stage | Purpose |
|---|---|---|---|---|
| Development | dev | `ws_sales_reporting_modernization_dev` | Development | Build, modify and test Fabric items |
| Production | prod | `ws_sales_reporting_modernization_prod` | Production | Host approved reporting workloads |

The expected promotion path is:

```text
DEV → PROD
```

## Fabric Items

The current Fabric project includes the following core items.

| Item Type | Item Name | Purpose |
|---|---|---|
| Lakehouse | `lh_sales_operational` | Stores Bronze and Silver operational data |
| Warehouse | `wh_sales_analytics` | Stores Staging and Gold analytical data |
| Power BI Semantic Model | `sm_sales_analytics` | Provides the governed reporting consumption layer |
| Deployment Pipeline | `dp_sales_reporting_modernization` | Promotes Fabric items across DEV, TEST, and PROD |

## Connection Strategy

Connections are configured inside Fabric and are part of the workspace setup.

Connection names should remain consistent across DEV, TEST, and PROD. The workspace determines the environment, while each connection points to the environment-specific endpoint.

| Connection | Purpose | Category |
|---|---|---|
| On-premise SQL Server connection | Connects to source SQL Server databases such as `Sales_Operational` and `Sales_Analytics` | Source connection |
| Azure SQL connection | Connects to `DataOps_Control` for metadata, execution tracking, validation, and reconciliation | Control connection |
| Lakehouse connection | Supports access to `lh_sales_operational`, including SQL view usage where required | Target/component connection |
| Warehouse connection | Supports SQL operations against `wh_sales_analytics` | Target/component connection |
| Fabric Data Pipelines connection | Supports pipeline-to-pipeline orchestration where required | Orchestration connection |

Secrets and credentials should be managed through Fabric connection settings and should not be stored in the GitHub repository.

## Deployment Folder Plan

The deployment folder is not yet created, but it should be added later to support controlled releases.

Recommended structure:

```text
/deployment
  deployment_order.md
  release_checklist.md
  release_notes_template.md
  manual_deployment_steps.md
```

| File | Purpose |
|---|---|
| `deployment_order.md` | Defines the order for deploying Fabric items, scripts, and supporting objects |
| `release_checklist.md` | Defines pre-release and post-release checks |
| `release_notes_template.md` | Captures what changed in each release |
| `manual_deployment_steps.md` | Documents manual steps required because Fabric Git integration is not enabled |

## Release Validation

Release validation should confirm that the promoted environment is usable before it is accepted.

| Validation Area | Expected Check |
|---|---|
| Workspace | Correct workspace is used for the target environment |
| Fabric items | Lakehouse, Warehouse, pipelines, notebooks, and deployment pipeline items are available where expected |
| Connections | Source, control, Lakehouse, Warehouse, and pipeline connections point to the correct environment endpoints |
| Schemas and tables | Required Bronze, Silver, Staging, and Gold objects are available |
| Pipelines | Required pipelines are present and runnable |
| Notebooks | Required notebooks are present and linked where needed |
| Data checks | Required validation and reconciliation checks can be executed after load processing |

## Assumptions and Constraints

| Type | Statement | Description |
|---|---|---|
| Constraint | Fabric Git integration is not enabled | The project uses GitHub for external artifact versioning, not direct workspace synchronization |
| Constraint | Configuration files are skipped for now | Environment configuration is currently managed through workspace separation, item naming, parameters, and Fabric connections |
| Assumption | One workspace exists per environment | DEV, TEST, and PROD are separated through dedicated Fabric workspaces |
| Assumption | Fabric item names remain consistent | Item names do not include environment suffixes because the workspace identifies the environment |
| Assumption | Semantic model is out of scope for this phase | Semantic model deployment will be added later |

## Conclusion

The CI/CD and deployment strategy defines how the current Fabric project is organized across DEV, TEST, and PROD.

The project uses one workspace per environment, consistent Fabric item names across environments, a Fabric deployment pipeline for promotion, and GitHub as the external repository for documentation, scripts, notebooks, pipeline artifacts, and deployment support files.

Because direct Fabric Git integration is not enabled in the trial environment, deployment is handled through a controlled manual-assisted process supported by repository artifacts, workspace separation, consistent naming, Fabric connections, and release validation.
