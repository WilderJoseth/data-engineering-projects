# Concepts and Terminology Guide

## Document Goal

This guide defines the main terms used across the Sales Analytics Modernization project.

Use this document to keep wording consistent across the numbered project documents.

## Core Platform Terms

| Term | Meaning | Use When |
|---|---|---|
| Source platform | Current on-premise SQL Server 2022 environment | Referring to the existing SQL Server environment as a whole |
| Source database | SQL Server database used as input to the modernization flow | Referring to `Sales_Operational` or `Sales_Analytics` |
| Source object | Table or view read from a source database | Referring to a specific source table such as `prod.SalesOrderHeader` |
| Target reporting platform | Target reporting architecture built with Fabric items and `DataOps_Control` | Referring to the full destination platform for reporting modernization |
| Target component | Main platform asset in the target reporting platform | Referring to the Lakehouse, Warehouse, semantic model, or control database |
| Target object | Table, view, notebook, pipeline, semantic model object, or script | Referring to implementation objects inside target components |
| Operational system of record | Authoritative system for active business transactions | Referring to `Sales_Operational` |
| Current reporting source of truth | Trusted reporting source before cutover | Referring to `Sales_Analytics` |
| Historical reporting baseline | Trusted historical reporting data used to initialize and validate the target model | Referring to historical data from `Sales_Analytics` |
| Target reporting source of truth | Reporting authority after cutover | Referring to Warehouse Gold exposed through the Power BI Semantic Model |

## Source Components

| Component | Type | Role |
|---|---|---|
| `Sales_Operational` | SQL Server database | Operational system of record; provides new transactional, master, and reference data |
| `Sales_Analytics` | SQL Server database | Current reporting source of truth; provides the historical reporting baseline |
| `DataOps_Control` | Azure SQL Database / control framework | Tracks metadata, executions, validation, reconciliation, errors, and reruns |

`DataOps_Control` supports the modernization flow. It is not a business source database and is not part of the reporting consumption layer.

## Target Components

| Component | Name | Role |
|---|---|---|
| Fabric Lakehouse | `lh_sales_operational` | Stores Bronze and Silver operational data |
| Fabric Warehouse | `wh_sales_analytics` | Stores Staging and Gold reporting data |
| Power BI Semantic Model | `sm_sales_analytics` | Provides governed reporting consumption over Gold objects |
| Fabric deployment pipeline | `dp_sales_reporting_modernization` | Promotes approved Fabric items from Development to Production |
| Variable Library | `vl_sales_reporting_modernization` | Stores stage-specific values used by pipelines and notebooks |
| Azure SQL Database | `DataOps_Control` | Provides execution control and observability |

## Data Areas

| Data Area | Component | Purpose | Reporting Access |
|---|---|---|---|
| Bronze | Lakehouse | Raw source-aligned operational data | No |
| Silver | Lakehouse | Curated and standardized operational data | No |
| Staging | Warehouse | Temporary historical loading area | No |
| Gold | Warehouse | Final reporting-ready facts and dimensions | Through semantic model |
| Semantic Model | Power BI | Governed business-facing reporting layer | Yes |

## Source Data Categories

| Data Category | Main Source | Meaning | Example |
|---|---|---|---|
| Reference / Lookup | `Sales_Operational` | Stable or low-change descriptive values | `Currency`, `ShipMethod`, `AddressType` |
| Master / Core | `Sales_Operational` | Business entities used by Sales processes | `Customer`, `Product`, `SalesPerson` |
| Transactional | `Sales_Operational` | Sales events and transaction records | `SalesOrderHeader`, `SalesOrderDetail` |
| Analytical Dimension | `Sales_Analytics` | Reporting-ready descriptive structure | `DimCustomer`, `DimProduct` |
| Analytical Fact | `Sales_Analytics` | Reporting-ready measurable business event | `FactSales` |

## Source Volume Terms

| Term | Meaning |
|---|---|
| Estimated current rows | Approximate current row count for a source object |
| Estimated monthly growth | Expected row increase per month |
| Estimated current data size | Approximate table data size, excluding indexes |
| Estimated current index size | Approximate index storage size |
| Very high volume | Large tables that need controlled batch processing |

## Data Flow Terms

| Term | Meaning | Path |
|---|---|---|
| Historical reporting flow | Loads trusted historical reporting data before cutover | `Sales_Analytics` -> `wh_sales_analytics.staging` -> `wh_sales_analytics.gold` |
| New reporting data flow | Builds new reporting data from the operational source | `Sales_Operational` -> `lh_sales_operational.bronze` -> `lh_sales_operational.silver` -> `wh_sales_analytics.gold` |
| Coexistence support flow | Supports temporary comparison and transition before cutover | `Sales_Analytics` and `Sales_Operational`, controlled by period ownership |
| Reporting boundary period | Business period that separates historical ownership from new reporting ownership | History through one approved period; new data after that period |
| Period ownership | Rule that assigns one approved source to each reporting period | Prevents duplicate loading into Gold |

## Load Strategy Terms

| Term | Meaning | Typical Use |
|---|---|---|
| Full reload | Reloads a complete dataset | Historical dimensions and generated dimensions |
| Watermark incremental load | Loads new records with `created_at` and changed records with `updated_at` | Reference, lookup, and master data from `Sales_Operational` |
| Batch period reload | Reloads a monthly business period based on `OrderDate` | Transactional data and analytical facts |
| Append load | Adds extracted rows without updating existing target rows | Bronze tables |
| Upsert | Inserts new rows and updates matched rows | Silver and Gold dimensions |
| Match key | Key used to match source and target records during upsert | `SourceCustomerID`, `SourceProductID` |
| Refresh control column | Column used to drive a load strategy | `created_at`, `updated_at`, `OrderDate` |
| Rerun | Controlled reprocessing after failure or correction | Rerun by object or `OrderDate` month |

## Validation and Reconciliation Terms

| Term | Meaning |
|---|---|
| Validation | Checks data quality or business rules |
| Reconciliation | Compares source and target results |
| Validation code | Standard code that identifies a validation rule |
| Severity | Business impact level of a validation result: Error, Warning, or Info |
| Reconciliation grain | Level used for comparison, such as table or `OrderDate` month |
| `ROW_COUNT` | Reconciliation type that compares record counts |
| `SUM_TOTAL` | Reconciliation type that compares aggregated numeric measures |
| Accepted tolerance | Approved difference threshold for reconciliation |
| Unaccepted batch | Batch that should not be published or accepted until corrected or approved |

## Common Validation Codes

| Code | Severity | Use |
|---|---|---|
| `NOT_NULL` | Error | Required value check |
| `DUPLICATE` | Error | Business key or source key uniqueness check |
| `FK_CHECK` | Error | Referential integrity check |
| `DATA_TYPE` | Error | Expected data type check |
| `LENGTH_CHECK` | Error | Text length check |
| `DATE_RANGE` | Warning | Business or reporting date range check |
| `NEGATIVE_VALUE` | Warning | Suspicious negative numeric measure check |
| `RECON_WARNING` | Warning | Reconciliation issue within tolerance or requiring review |
| `INFO_CHECK` | Info | Non-blocking profiling or informational check |

## CI/CD and Deployment Terms

| Term | Meaning | Example |
|---|---|---|
| Environment | Deployment stage for Fabric workloads | Development, Production |
| Workspace | Fabric deployment boundary | `ws_sales_reporting_modernization_dev` |
| Deployment pipeline | Fabric promotion mechanism between environments | `dp_sales_reporting_modernization` |
| Workspace item | Fabric item deployed or managed in a workspace | Lakehouse, Warehouse, notebook, pipeline |
| Connection | Fabric-managed access definition for a source or target | `cn_sql_sales_operational_dev` |
| Variable Library | Fabric item that stores stage-specific values | `vl_sales_reporting_modernization` |
| Stage-specific value | Value that changes by environment | Connection id, item id, workspace id |
| Platform container | Environment-specific Fabric container created per workspace | Lakehouse, Warehouse |
| Deployment artifact | Repository-managed file used for deployment or validation | Setup script, notebook, checklist |

## Security and Access Terms

| Term | Meaning |
|---|---|
| Authentication method | Method used by a connection to authenticate |
| Basic authentication | Username/password authentication for on-premise SQL Server sources |
| OAuth 2.0 | Fabric-managed authentication for Fabric items |
| Workspace identity | Managed identity used by the Fabric workspace |
| On-premise data gateway | Gateway used by Fabric to reach on-premise SQL Server |
| Read-only source user | SQL user that can read but not modify source data |
| Least privilege | Grant only the access required for a process |
| Secret handling | Rules for keeping credentials out of artifacts |
| Sensitive data | Data that must be restricted, masked, excluded, or limited |
| Reporting-safe attribute | Attribute approved for Gold or semantic model reporting |

## Sensitive Data Handling

| Data Area | Recommended Handling |
|---|---|
| Credit card data | Do not expose full card values; use reporting-safe payment attributes or last four digits only if required |
| Customer email | Mask or exclude unless required |
| Customer phone | Mask or exclude unless required |
| Customer address | Prefer city, state/province, country, or territory |
| Customer name | Expose only if required for reporting |
| Salesperson / employee attributes | Expose only business reporting attributes |

## Naming Patterns

| Object Type | Pattern | Example |
|---|---|---|
| Development workspace | `ws_[domain]_[purpose]_dev` | `ws_sales_reporting_modernization_dev` |
| Production workspace | `ws_[domain]_[purpose]_prod` | `ws_sales_reporting_modernization_prod` |
| Lakehouse | `lh_[domain]_[purpose]` | `lh_sales_operational` |
| Warehouse | `wh_[domain]_[purpose]` | `wh_sales_analytics` |
| Semantic model | `sm_[domain]_[purpose]` | `sm_sales_analytics` |
| Deployment pipeline | `dp_[domain]_[purpose]` | `dp_sales_reporting_modernization` |
| Variable Library | `vl_[domain]_[purpose]` | `vl_sales_reporting_modernization` |
| Connection | `cn_[technology]_[asset]_[environment]` | `cn_sql_sales_operational_dev` |
| Source key | `Source[Entity]ID` | `SourceCustomerID` |
| Batch period column | `batch_period_yyyymm` | `202601` |

## Preferred Wording

| Avoid | Use |
|---|---|
| Operational source of truth | Operational system of record |
| Fabric is the reporting source of truth | Warehouse Gold exposed through the Power BI Semantic Model is the target reporting source of truth |
| Reports connect to Fabric | Reports consume the Power BI Semantic Model |
| Fabric stores Bronze and Silver | The Fabric Lakehouse stores Bronze and Silver |
| Fabric stores Gold | The Fabric Warehouse stores Gold |
| Gold is directly consumed by reports | Reports consume the semantic model over Gold objects |
| SQL Server is migrated to Fabric | Sales reporting is modernized from SQL Server to Microsoft Fabric |

## Project Mental Model

| Area | Responsibility |
|---|---|
| `Sales_Operational` | Operational system of record and source for new reporting data |
| `Sales_Analytics` | Current reporting source of truth and historical reporting baseline |
| `lh_sales_operational.bronze` | Raw operational landing area |
| `lh_sales_operational.silver` | Curated operational preparation area |
| `wh_sales_analytics.staging` | Temporary historical loading area |
| `wh_sales_analytics.gold` | Final analytical facts and dimensions |
| `sm_sales_analytics` | Governed reporting consumption layer |
| `DataOps_Control` | Metadata, execution tracking, validation, reconciliation, error logging, and rerun control |
