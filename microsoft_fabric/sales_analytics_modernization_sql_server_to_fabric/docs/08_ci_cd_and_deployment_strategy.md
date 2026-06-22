# CI/CD and Deployment Strategy

## Document Goal

This document defines the CI/CD and deployment strategy for the Sales Analytics Modernization project.

## Environment and Workspace Strategy

The project uses two Fabric environments.

| Environment | Workspace Name | Purpose |
|---|---|---|
| Development | `ws_sales_reporting_modernization_dev` | Build, modify, and validate Fabric items before production deployment |
| Production | `ws_sales_reporting_modernization_prod` | Host approved reporting workloads |

Workspace names include the environment suffix because the workspace is the main deployment boundary. Fabric item names remain consistent across environments; the environment is identified by the workspace, not by adding an environment suffix to every item.

## Deployment Pipeline Strategy

The project uses one Fabric deployment pipeline.

| Deployment Pipeline | Purpose |
|---|---|
| `dp_sales_reporting_modernization` | Promotes approved Fabric items from Development to Production |

The expected promotion path is:

```text
Development → Production
```

## Workspace Items

Each workspace contains the core Fabric items required for the environment.

| Item Type | Item Name | Purpose |
|---|---|---|
| Lakehouse | `lh_sales_operational` | Stores Bronze and Silver operational data |
| Warehouse | `wh_sales_analytics` | Stores Staging and Gold reporting data |
| Variable Library | `vl_sales_reporting_modernization` | Stores stage-specific values used by pipelines and notebooks |
| Notebooks | `notebooks` directory | Stores setup, transformation, validation, or utility notebooks |
| Pipelines | `pipelines` directory | Stores ingestion, transformation, validation, and orchestration pipelines |

## Connection Strategy

Connections are configured per environment and managed through Fabric connection management. Because connection objects are not treated as workspace-local objects, physical connection names include the environment suffix (`_dev`, `_prod`) to clearly separate Development and Production connection instances.

Pipeline and notebook logic should not hardcode environment-specific connection names. Instead, the Variable Library stores the correct connection id for each deployment stage.

| Development Connection          | Production Connection            | Purpose                                                 | Category             |
| ------------------------------- | -------------------------------- | ------------------------------------------------------- | -------------------- |
| `cn_sql_sales_operational_dev`  | `cn_sql_sales_operational_prod`  | Connects to the on-premise `Sales_Operational` database | Source connection    |
| `cn_sql_sales_analytics_dev`    | `cn_sql_sales_analytics_prod`    | Connects to the on-premise `Sales_Analytics` database   | Source connection    |
| `cn_sql_dataops_control_dev`    | `cn_sql_dataops_control_prod`    | Connects to the `DataOps_Control` database              | Control connection   |
| `cn_lh_sales_operational_dev`   | `cn_lh_sales_operational_prod`   | Connects to Lakehouse `lh_sales_operational`            | Lakehouse connection |
| `cn_wh_sales_analytics_dev`     | `cn_wh_sales_analytics_prod`     | Connects to Warehouse `wh_sales_analytics`              | Warehouse connection |
| `cn_pipeline_orchestration_dev` | `cn_pipeline_orchestration_prod` | Supports pipeline orchestration where required          | Pipeline connection  |

The on-premise SQL Server source connections use the on-premise data gateway.

## Variable Library Strategy

The project uses one Variable Library to manage stage-specific values for Development and Production.

| Variable Library                   | Purpose                                                      |
| ---------------------------------- | ------------------------------------------------------------ |
| `vl_sales_reporting_modernization` | Stores stage-specific values used by pipelines and notebooks |

The Variable Library has default values for Development and production-specific values for Production. Variables use the prefix `vl_`.

| Variable                              | Development Value                    | Production Value                      | Purpose                                               |
| ------------------------------------- | ------------------------------------ | ------------------------------------- | ----------------------------------------------------- |
| `vl_cn_sql_sales_operational_id`      | Id of `cn_sql_sales_operational_dev` | Id of `cn_sql_sales_operational_prod` | Resolves the `Sales_Operational` source connection    |
| `vl_cn_sql_sales_analytics_id`        | Id of `cn_sql_sales_analytics_dev`   | Id of `cn_sql_sales_analytics_prod`   | Resolves the `Sales_Analytics` source connection      |
| `vl_cn_sql_dataops_control_id`        | Id of `cn_sql_dataops_control_dev`   | Id of `cn_sql_dataops_control_prod`   | Resolves the `DataOps_Control` connection             |
| `vl_cn_lh_sales_operational_id`       | Id of `cn_lh_sales_operational_dev`  | Id of `cn_lh_sales_operational_prod`  | Resolves the Lakehouse connection                     |
| `vl_cn_wh_sales_analytics_id`         | Id of `cn_wh_sales_analytics_dev`    | Id of `cn_wh_sales_analytics_prod`    | Resolves the Warehouse connection                     |
| `vl_wh_sales_analytics_id`            | Id of DEV `wh_sales_analytics`       | Id of PROD `wh_sales_analytics`       | Resolves the Warehouse item                           |
| `vl_lh_sales_operational_id`          | Id of DEV `lh_sales_operational`     | Id of PROD `lh_sales_operational`     | Resolves the Lakehouse item                           |
| `vl_wh_sales_analytics_sql_cn_string` | DEV Warehouse SQL connection string  | PROD Warehouse SQL connection string  | Resolves the Warehouse SQL endpoint connection string |
| `vl_workspace_id`                     | Development workspace id             | Production workspace id               | Resolves the current workspace                        |

Variable Library values allow the same pipeline and notebook logic to run in different stages without hardcoding environment-specific connection ids, item ids, workspace ids, or SQL connection strings.

## Deployment Approach by Asset

Not every asset is deployed in the same way. The project promotes Fabric logic and stage-aware configuration, while platform containers and internal data objects are created or controlled per environment.

| Asset | Deployment Approach |
|---|---|
| Workspaces | Created manually per environment |
| Lakehouse | Created manually per environment as a platform container |
| Warehouse | Created manually per environment as a platform container |
| Variable Library | Promoted and configured per stage with Development and Production values |
| Pipelines | Promoted through the deployment pipeline |
| Notebooks | Promoted through the deployment pipeline |
| Lakehouse tables | Created by setup notebooks in each environment |
| Warehouse schemas, tables, and views | Created by setup SQL scripts |
| Data | Not promoted; loaded by environment-specific pipelines |

This strategy avoids relying on deployment pipeline promotion to move Lakehouse internal tables or data between environments. It also keeps Warehouse object creation explicit and repeatable through scripts, even when some Warehouse objects can be promoted by Fabric.

## Repository and Deployment Artifacts

GitHub is used to manage project artifacts outside Fabric. Direct Fabric workspace Git integration is not enabled in the current project because of trial environment limitations.

The repository root folder is:

```text
sales_analytics_modernization_sql_server_to_fabric
```

Recommended repository structure:

```text
sales_analytics_modernization_sql_server_to_fabric
├── artifacts
│   ├── source
│   │   └── sql_server
│   │       ├── Sales_Analytics
│   │       └── Sales_Operational
│   ├── target
│   │   └── fabric
│   │       ├── pipelines
│   │       │   ├── historical_reporting_data_flow
│   │       │   └── new_reporting_data_flow
│   │       └── notebooks
│   │           ├── historical_reporting_data_flow
│   │           └── new_reporting_data_flow
│   └── deployment
│       └── fabric
│           ├── lakehouse
│           ├── warehouse
│           ├── variable_library
│           └── validation_checklists
├── docs
│   ├── diagrams
│   └── images
└── README.md
```

| Repository Area | Purpose |
|---|---|
| `artifacts/source/sql_server/Sales_Operational` | Stores source artifacts related to the operational source database |
| `artifacts/source/sql_server/Sales_Analytics` | Stores source artifacts related to the analytical source database |
| `artifacts/target/fabric/pipelines/historical_reporting_data_flow` | Stores pipeline artifacts for the historical reporting data flow |
| `artifacts/target/fabric/pipelines/new_reporting_data_flow` | Stores pipeline artifacts for the new reporting data flow |
| `artifacts/target/fabric/notebooks/historical_reporting_data_flow` | Stores notebook artifacts for the historical reporting data flow |
| `artifacts/target/fabric/notebooks/new_reporting_data_flow` | Stores notebook artifacts for the new reporting data flow |
| `artifacts/deployment/fabric/lakehouse` | Stores Lakehouse setup scripts and setup notebooks |
| `artifacts/deployment/fabric/warehouse` | Stores Warehouse setup scripts |
| `artifacts/deployment/fabric/variable_library` | Stores Variable Library mapping notes and stage value references |
| `artifacts/deployment/fabric/validation_checklists` | Stores deployment and post-deployment validation checklists |
| `docs/diagrams` | Stores architecture and deployment diagrams |
| `docs/images` | Stores supporting documentation images |

## Conclusion

The CI/CD and deployment strategy defines how the Sales Analytics Modernization project is organized across Development and Production.

The project uses separate Fabric workspaces, one deployment pipeline, one stage-aware Variable Library, consistent Fabric item naming, per-environment connections, and GitHub-managed deployment artifacts.

The strategy promotes Fabric logic such as pipelines, notebooks, and stage-aware configuration, while keeping platform containers, internal objects, and data controlled per environment. Lakehouse and Warehouse items are created per environment, Lakehouse and Warehouse objects are created by scripts, notebooks, or pipelines, and data is loaded by environment-specific execution processes rather than promoted from Development to Production.
