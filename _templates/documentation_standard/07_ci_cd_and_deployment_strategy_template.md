# CI/CD and Deployment Strategy

## Document Goal

This document defines the CI/CD and deployment strategy for the <Project Name> project.

## Environment and Workspace Strategy

The project uses <Number> environments.

| Environment | Environment / Workspace Name | Purpose |
|---|---|---|
| Development | <Development Environment Name> | Build, modify, and validate items before production deployment |
| Production | <Production Environment Name> | Host approved reporting workloads |

Environment names include the environment suffix because <Deployment Boundary> is the main deployment boundary. Item names remain consistent across environments unless a platform requires environment-specific naming.

## Deployment Pipeline Strategy

The project uses <Deployment Tool or Pipeline>.

| Deployment Pipeline | Purpose |
|---|---|
| <Deployment Pipeline Name> | Promotes approved items from Development to Production |

The expected promotion path is:

```text
Development -> Production
```

## Environment Items

Each environment contains the core items required for the workload.

| Item Type | Item Name | Purpose |
|---|---|---|
| <Target Component> | <Target Component Name> | <Purpose> |
| <Target Component> | <Target Component Name> | <Purpose> |
| Configuration store | <Configuration Object Name> | Stores stage-specific values used by pipelines and jobs |
| Jobs / Notebooks / Scripts | <Directory Name> | Stores setup, transformation, validation, or utility logic |
| Pipelines | <Directory Name> | Stores ingestion, transformation, validation, and orchestration pipelines |

## Connection Strategy

Connections are configured per environment and managed through <Connection Management Tool>. Physical connection names include environment context when the platform requires separate connection instances.

Pipeline and job logic should not hardcode environment-specific connection names. Instead, <Configuration Store> stores the correct connection ID for each deployment stage.

| Development Connection | Production Connection | Purpose | Category |
|---|---|---|---|
| <Connection Name> | <Connection Name> | Connects to <Source System> | Source connection |
| <Connection Name> | <Connection Name> | Connects to <Target Component> | Target connection |
| <Connection Name> | <Connection Name> | Connects to <Control Platform> | Control connection |

## Configuration Strategy

The project uses <Configuration Store> to manage stage-specific values for Development and Production.

| Configuration Store | Purpose |
|---|---|
| <Configuration Store Name> | Stores stage-specific values used by pipelines, jobs, notebooks, or scripts |

The configuration store has default values for Development and production-specific values for Production.

| Variable | Development Value | Production Value | Purpose |
|---|---|---|---|
| <Variable Name> | <Development Value> | <Production Value> | Resolves <Purpose> |
| <Variable Name> | <Development Value> | <Production Value> | Resolves <Purpose> |
| <Variable Name> | <Development Value> | <Production Value> | Resolves <Purpose> |

Configuration values allow the same pipeline and job logic to run in different stages without hardcoding environment-specific connection IDs, item IDs, workspace IDs, or connection strings.

## Deployment Approach by Asset

Not every asset is deployed in the same way. The project promotes logic and stage-aware configuration, while platform containers and internal data objects are created or controlled per environment.

| Asset | Deployment Approach |
|---|---|
| Environments | Created manually or through approved infrastructure scripts |
| Target components | Created manually or through setup scripts per environment |
| Configuration store | Promoted and configured per stage with Development and Production values |
| Pipelines | Promoted through <Deployment Tool> |
| Jobs / Notebooks / Scripts | Promoted through <Deployment Tool> |
| Internal tables or objects | Created by setup scripts in each environment |
| Data | Not promoted; loaded by environment-specific pipelines |

## Repository and Deployment Artifacts

<Repository Platform> is used to manage project artifacts outside the target platform.

The repository root folder is:

```text
<Repository Name>
```

Recommended repository structure:

```text
<Repository Name>
|-- artifacts
|   |-- source
|   |   |-- <Source Platform>
|   |       |-- <Source System>
|   |-- target
|   |   |-- <Target Platform>
|   |       |-- pipelines
|   |       |-- jobs
|   |       |-- scripts
|   |-- deployment
|       |-- <Target Platform>
|           |-- configuration
|           |-- validation_checklists
|-- docs
|   |-- diagrams
|   |-- images
|-- README.md
```

| Repository Area | Purpose |
|---|---|
| `artifacts/source/<Source Platform>/<Source System>` | Stores source artifacts related to the source system |
| `artifacts/target/<Target Platform>/pipelines` | Stores pipeline artifacts |
| `artifacts/target/<Target Platform>/jobs` | Stores job, notebook, or script artifacts |
| `artifacts/deployment/<Target Platform>/configuration` | Stores configuration mapping notes and stage value references |
| `artifacts/deployment/<Target Platform>/validation_checklists` | Stores deployment and post-deployment validation checklists |
| `docs/diagrams` | Stores architecture and deployment diagrams |
| `docs/images` | Stores supporting documentation images |
