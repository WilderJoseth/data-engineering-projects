# Microsoft Fabric DEV Resource Configuration

## 1. Environment Overview

| Setting | Value | Evidence |
| --- | --- | --- |
| Workspace | `ws_fabric_enterprise_knowledge_platform_dev` | User-confirmed and named in the repository artifact path |
| Capacity | Fabric Trial | User-confirmed |
| Purpose | Development and validation of knowledge ingestion and processing | Pipeline and notebook exports |

## 2. Resource Inventory

| Resource | Purpose and scope | Evidence |
| --- | --- | --- |
| `lh_knowledge_platform` | `bronze` for raw inputs, `silver` for standardized data, `work` for staging | User-confirmed and supported by Lakehouse setup notebooks |
| `wh_knowledge_platform` | `gold` for Gold knowledge and `config` for project-specific configuration. Both schemas exist and are empty. | User-confirmed |
| `lh_knowledge_retrieval` | Reserved for persisted chunks and embeddings. The Lakehouse is empty. Tables and processing components are pending implementation. | User-confirmed |
| Pipelines | 11 ZIP exports covering main orchestration, SQL Server and GitHub Bronze ingestion, Silver standardization, and legacy Gold integration | [Pipeline exports](../artifacts/workspace/ws_fabric_enterprise_knowledge_platform_dev/pipelines) |
| Notebooks | 12 exports covering shared validation, work setup, Bronze setup and file registration, Silver setup and processing, and legacy Lakehouse Gold | [Notebook exports](../artifacts/workspace/ws_fabric_enterprise_knowledge_platform_dev/notebooks) |

## 3. Connectivity and Security

| Area | User-confirmed setup | Repository verification |
| --- | --- | --- |
| SQL Server sources | `Sales_Operational` and `Sales_Analytics` are on separate instances behind the On-premises Data Gateway. Both databases are considered accessible based on previous tests. | The exported Copy activity incorrectly routes `Sales_Analytics` through `cn_sql_sales_operational`. Correcting and validating the Analytics pipeline binding is a separate implementation task. |
| Azure SQL `DataOps_Control` | Workspace Identity | Exports reference `cn_sql_dataops_control_on_premise` for control calls. This parameter name does not establish the endpoint or authentication mode. |
| GitHub | Web/Web v2 connections | Exports reference `cn_github_api` and `cn_github_raw`. |
| Credentials and access | Azure Key Vault for credentials. One workspace Admin. | Vault bindings and workspace grants are outside the checked-in exports. |

SQL binding evidence is in the Bronze exports `01_pl_sqlserver_metadata_ingestion.zip`, `02_pl_sqlserver_database_metadata_ingestion.zip`, and `03_pl_sqlserver_metadata_object_ingestion.zip`.

## 4. Version Control

DEV artifacts are manually exported and synchronized with GitHub. Native Fabric–GitHub integration is disabled. Review the checked-in ZIP and notebook exports when recreating the workspace, and record the commit used.

## 5. Environment Recreation

1. Create the workspace and three data items from the inventory. Assign Trial capacity, provision Workspace Identity, and assign the workspace Admin.
2. Create and test both gateway-backed SQL Server connections against their respective databases. Set up Azure SQL access for Workspace Identity, the GitHub connections, Key Vault access, and the connection used to invoke child pipelines.
3. Create the empty `gold` and `config` schemas in `wh_knowledge_platform`. Leave `lh_knowledge_retrieval` empty. Gold and Retrieval processing are outside recreation scope.
4. Import the notebooks and run the Bronze, Silver, and work setup notebooks against `lh_knowledge_platform`.
5. Import the pipeline packages and remap workspace, item, notebook, and connection references to target IDs. Supply credentials through approved Key Vault bindings. Smoke-test Azure SQL control calls, GitHub access, and child pipeline invocation. Compare intended activity states with the exports before an orchestration test.

## 6. Remaining Dependencies

| Readiness item | Required evidence or input |
| --- | --- |
| Recreation inputs | Obtain target gateway and SQL endpoint mappings, Azure SQL endpoint and Workspace Identity grants, GitHub connection settings, Key Vault secret references and permissions, and the target Admin assignment through approved channels. |
| Azure SQL project configuration | Obtain project-specific lookup definitions and configuration rows consumed by the pipelines. |
| SharePoint | Deferred and outside current DEV readiness. |
