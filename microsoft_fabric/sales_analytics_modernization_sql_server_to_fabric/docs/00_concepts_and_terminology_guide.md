# Concepts and Terminology Guide

## Document Goal

This guide keeps terminology consistent across the **Sales Analytics Modernization: SQL Server to Microsoft Fabric** project.

## Architecture Term Levels

| Level | Meaning | Typical Terms | Example in This Project |
|---|---|---|---|
| High-level | Describes a system, platform, or major architecture boundary | Source platform, target analytics platform, reporting architecture | On-premise SQL Server 2022 environment; Microsoft Fabric-based analytics architecture |
| Mid-level | Describes major components inside a platform | Source database, Fabric Lakehouse, Fabric Warehouse, Semantic Model, Azure SQL Database | `Sales_Operational`, `Sales_Analytics`, `lh_sales_operational`, `wh_sales_analytics`, `sm_sales_analytics`, `DataOps_Control` |
| Low-level | Describes concrete implementation objects | Schema, table, view, stored procedure, pipeline, notebook, semantic model table | `bronze.SalesOrderHeader`, `silver.SalesOrderHeader`, `gold.FactSales`, `gold.DimCustomer` |
| Logical / conceptual | Describes the responsibility of data in the architecture | Bronze, Silver, Gold, historical baseline, reporting source of truth, operational system of record | `Sales_Analytics` as historical reporting baseline; Warehouse Gold as target reporting model |
| Physical / implementation | Describes where something is implemented | SQL Server schema, Fabric Warehouse schema, Lakehouse table, Power BI semantic model | `wh_sales_analytics.gold.FactSales` |

## Core Architecture Concepts

| Term | Level | Definition | Use It When | Avoid It When | Example in This Project | Recommended Wording |
|---|---|---|---|---|---|---|
| Source platform | High | The current technical environment where source data resides | Referring to the full current SQL Server environment | Referring to one database, table, or query | On-premise SQL Server 2022 | The source platform is the on-premise SQL Server 2022 environment. |
| Source component | Mid | A major source-side component inside the source platform | Grouping source databases or services | Referring to individual tables | `Sales_Operational`, `Sales_Analytics` | The source components are the operational and analytics SQL Server databases. |
| Source database | Mid | A database used as input to the modernization flow | Referring to `Sales_Operational` or `Sales_Analytics` specifically | Referring to the full platform | `Sales_Operational`, `Sales_Analytics` | The main source databases are `Sales_Operational` and `Sales_Analytics`. |
| Source object | Low | A table, view, or query read from a source database | Discussing ingestion mappings, dependencies, or reconciliation | Referring to the whole database or platform | `Sales_Operational.prod.SalesOrderHeader` | Source objects are mapped to target Lakehouse or Warehouse objects. |
| Data source | Generic / implementation | Any specific input used by a pipeline, notebook, or process | Referring to a specific table, view, query, file, or API used as input | Referring to the whole SQL Server platform when a more precise term exists | A query over `Sales_Analytics.fact.FactSales` | Use data source only for specific pipeline inputs. |
| Operational system of record | Conceptual | The authoritative system for creating, changing, and maintaining business transactions | Referring to operational business ownership | Referring to derived analytical or reporting data | `Sales_Operational` | `Sales_Operational` remains the operational system of record for active sales transactions. |
| Current reporting source of truth | Conceptual | The trusted reporting source before modernization | Referring to the existing reporting authority | Referring to operational transaction ownership | `Sales_Analytics` | `Sales_Analytics` is the current reporting source of truth. |
| Historical reporting baseline | Conceptual | Trusted historical reporting data used to initialize, validate, or reconcile the target model | Referring to migration/backfill and validation of historical reporting data | Referring to future incremental data | Historical data from `Sales_Analytics` | `Sales_Analytics` provides the historical reporting baseline. |
| Target reporting source of truth | Conceptual | The trusted reporting model after modernization and cutover | Referring to the future governed reporting authority | Referring to raw Bronze or intermediate Silver data | `wh_sales_analytics.gold` exposed through `sm_sales_analytics` | After cutover, the Warehouse Gold model exposed through the semantic model becomes the target reporting source of truth. |
| Target analytics platform | High | The complete target analytics architecture, including data preparation, analytical modeling, reporting consumption, and DataOps control | Referring to the whole destination architecture | Referring to a specific Lakehouse table, Warehouse table, or semantic model object | Fabric Lakehouse, Fabric Warehouse, Semantic Model, and DataOps Control database | The target analytics platform modernizes reporting and analytics using Microsoft Fabric and Azure SQL Database for DataOps control. |
| Target component | Mid | A named destination component in the target architecture | Referring to Lakehouse, Warehouse, Semantic Model, or Azure SQL DB | Referring to individual tables or views | `lh_sales_operational`, `wh_sales_analytics`, `sm_sales_analytics`, `DataOps_Control` | The target components are the Lakehouse, Warehouse, Semantic Model, and DataOps Control database. |
| Target object | Low | A concrete implementation object in a target component | Referring to tables, views, pipelines, notebooks, procedures, or semantic model entities | Referring to broad services such as Warehouse or Lakehouse | `wh_sales_analytics.gold.FactSales` | Target objects include Lakehouse tables, Warehouse tables, views, pipelines, notebooks, and semantic model objects. |
| Target data model | Logical / mid | The organized business-facing analytical structure used for reporting | Referring to the Gold model or semantic model design | Referring to raw Bronze or staging data | Gold star schema and semantic model | The target data model is the Gold analytical model exposed through the semantic model. |

## Source Components

| Component | Type | Role | Important Notes |
|---|---|---|---|
| `Sales_Operational` | SQL Server database | Operational system of record | Remains on-premise and provides new transactional data for future reporting periods |
| `Sales_Analytics` | SQL Server database | Current reporting source of truth and historical reporting baseline | Provides trusted historical reporting data before cutover |
| `DataOps_Control` | Azure SQL Database / control framework | Execution and observability control | Tracks metadata, execution, validation, reconciliation, errors, and reruns |

> Note: `DataOps_Control` is listed here because it supports execution and observability across the modernization flow. It is not a business source database and it is not part of the reporting consumption model.

## Target Components

| Target Component | Proposed Name | Role | Example Responsibility |
|---|---|---|---|
| Fabric Lakehouse | `lh_sales_operational` | Stores and processes operational-source data | Bronze and Silver operational data areas |
| Fabric Warehouse | `wh_sales_analytics` | Stores analytical reporting objects | Staging and Gold analytical data areas |
| Power BI Semantic Model | `sm_sales_analytics` | Provides governed reporting consumption | Business-facing reporting layer over Gold data |
| Azure SQL Database | `DataOps_Control` | Provides shared execution control and observability | Metadata, execution tracking, validation, reconciliation, errors, and reruns |

## Target Data Areas

| Data Area | Location | Short Definition | Role in This Project | Example |
|---|---|---|---|---|
| Bronze | Lakehouse | Raw source-aligned data area | Stores operational data as close to the source as practical | `bronze.SalesOrderHeader` |
| Silver | Lakehouse | Curated operational data area | Standardizes, validates, and prepares Bronze data | `silver.SalesOrderHeader` |
| Staging | Warehouse | Temporary historical loading area | Supports historical loads from `Sales_Analytics` before Gold publication | `staging.FactSales` |
| Gold | Warehouse | Final analytical reporting area | Stores reporting-ready facts and dimensions | `gold.FactSales`, `gold.DimCustomer` |
| Power BI Semantic Model | Power BI | Governed reporting model | Exposes measures, relationships, and business-facing reporting logic | `sm_sales_analytics` |

## Layer, Schema, Data Area, Object, and Component

| Term | Level | Use When | Avoid When | Example |
|---|---|---|---|---|
| Layer | Logical | Speaking conceptually about Medallion architecture | Referring to exact implementation objects | Bronze layer, Silver layer, Gold layer |
| Data area | Logical / organizational | Referring to logical responsibilities across the target platform | Referring only to a physical database namespace | Bronze, Silver, Staging, Gold, Semantic Model |
| Schema | Physical / implementation | Referring to implementation grouping inside Lakehouse or Warehouse | Speaking generally about architecture responsibility | `bronze`, `silver`, `staging`, `gold` |
| Object | Low / physical | Referring generally to tables, views, procedures, pipelines, notebooks, or model entities | When the exact object type matters | Gold objects, Bronze objects, target objects |
| Component | Mid | Referring to a main platform asset | Referring to individual tables | Fabric Lakehouse, Fabric Warehouse, Semantic Model |

Recommended usage:

| Situation | Preferred Term |
|---|---|
| Explaining the architecture | Data area |
| Describing physical implementation | Schema |
| Listing main Fabric assets | Target component |
| Listing tables, views, procedures, notebooks, pipelines, or model entities | Object |
| Explaining Medallion concepts | Layer |

## Correct Use of Microsoft Fabric Terminology

Use **Microsoft Fabric** when referring to the overall analytics platform.

Use the specific component name when referring to storage, transformation, modeling, or consumption.

| Instead of | Use |
|---|---|
| Data is stored in Fabric | Data is stored in the Fabric Lakehouse or Fabric Warehouse |
| Reports connect to Fabric | Reports consume data through the Power BI semantic model |
| Fabric contains Gold tables | The Fabric Warehouse contains the Gold analytical tables |
| SQL Server is migrated to Fabric | Reporting and analytics are modernized from SQL Server to Microsoft Fabric |
| Fabric stores Bronze and Silver | The Fabric Lakehouse stores Bronze and Silver operational data areas |
| Fabric stores the reporting model | The Fabric Warehouse stores the Gold analytical model |

Recommended wording:

> Microsoft Fabric is the core target analytics platform.  
> The Fabric Lakehouse `lh_sales_operational` stores Bronze and Silver operational data areas.  
> The Fabric Warehouse `wh_sales_analytics` stores staging and Gold analytical data areas.  
> The Power BI semantic model `sm_sales_analytics` provides governed reporting consumption.

## Source Data Categories

| Data Category | Short Definition | Main Source | Expected Volume | Example |
|---|---|---|---|---|
| Reference / Lookup | Stable or low-change descriptive values | `Sales_Operational` | Low | `Currency`, `ShipMethod`, `AddressType` |
| Master / Core | Main business entities used across Sales processes | `Sales_Operational` | Medium | `Customer`, `Product`, `SalesPerson` |
| Transactional | Sales business events and transaction records | `Sales_Operational` | High | `SalesOrderHeader`, `SalesOrderDetail` |
| Analytical Dimensions | Reporting-ready descriptive structures | `Sales_Analytics` | Medium | `DimCustomer`, `DimProduct` |
| Analytical Facts | Reporting-ready measurable business events | `Sales_Analytics` | Very high | `FactSales` |

## Data Flow Concepts

| Concept | Short Definition | Role in This Project | Example |
|---|---|---|---|
| Data flow | Movement path from source to target | Explains how data travels through the architecture | Source -> target data area |
| Historical reporting flow | Loads trusted historical reporting data | Initializes the target analytical model | `Sales_Analytics` -> `staging` -> `gold` |
| New reporting data flow | Builds new reporting data from the operational source | Long-term flow for future reporting periods | `Sales_Operational` -> `bronze` -> `silver` -> `gold` |
| Coexistence support flow | Temporary flow during transition | Supports comparison and controlled reporting cutover | Existing reporting and target reporting coexist |
| Reporting boundary period | Business period separating historical and new reporting ownership | Prevents duplicate period loading | History through `2025-12`; new data from `2026-01` |
| Period ownership | Rule defining which source owns a reporting period | Prevents the same period from being loaded from multiple sources | One period, one approved source |

Historical reporting data flow:

```text
Sales_Analytics
  -> wh_sales_analytics.staging
  -> wh_sales_analytics.gold
  -> sm_sales_analytics
```

Recommended description:

> Historical reporting data is loaded from the current reporting source of truth, `Sales_Analytics`, into the Fabric Warehouse staging area. It is then published into the Warehouse Gold model and exposed through the Power BI semantic model.

New reporting data flow:

```text
Sales_Operational
  -> lh_sales_operational.bronze
  -> lh_sales_operational.silver
  -> wh_sales_analytics.gold
  -> sm_sales_analytics
```

Recommended description:

> New reporting data is extracted from the operational system of record, `Sales_Operational`, into the Fabric Lakehouse Bronze area. It is then cleaned and conformed in the Silver area, curated into the Fabric Warehouse Gold model, and exposed through the Power BI semantic model.

## Load Strategy Concepts

| Concept | Short Definition | Role in This Project | Example |
|---|---|---|---|
| Load strategy | Rule for refreshing a data object | Defines how source and target objects are processed | Full reload, watermark incremental load, batch period reload |
| Full reload | Reloads the complete dataset | Used for small or controlled objects | Reload `Currency` |
| Watermark incremental load | Loads records changed since the last successful load | Used for objects with reliable change tracking | `ModifiedDate > last_watermark` |
| Batch period reload | Reloads a specific business period | Used for facts and transactional data | Reload `FactSales` for `202501` |
| Watermark column | Column used to detect new or changed records | Required for incremental loads | `ModifiedDate`, `CreatedDate`, `rowversion` |
| Batch period | Business period used for grouped loading | Supports controlled reruns and reconciliation | `batch_period_yyyymm` |
| Backfill | Initial historical loading activity | Initializes the target analytical model | Load historical `FactSales` |
| Rerun | Controlled reprocessing after failure or correction | Supports recovery | Rerun a failed reporting period |

> Backfill is an activity, not a separate load strategy. A backfill may use full reload, batch period reload, or another controlled loading approach depending on the object and data volume.

## Validation, Reconciliation, and Control Concepts

| Concept | Short Definition | Role in This Project | Example |
|---|---|---|---|
| Validation | Checks data quality or business rules | Confirms loaded data is acceptable | Required fields, valid dates, duplicate checks |
| Reconciliation | Compares source and target results | Confirms completeness and consistency | Source count equals target count |
| Execution tracking | Records process execution status | Supports observability | Pipeline started, completed, failed |
| Error logging | Captures technical failures | Supports troubleshooting | Extraction failure, transformation error |
| Rerun support | Allows safe reprocessing | Supports recovery | Rerun by object or batch period |
| Observability | Ability to monitor execution health | Helps operate the solution reliably | Execution dashboard, logs, control tables |
| Control framework | Shared structure for metadata and runtime tracking | Centralizes operational control | `DataOps_Control` |

## Reporting and Consumption Concepts

| Concept | Short Definition | Role in This Project | Example |
|---|---|---|---|
| Reporting consumption layer | Layer used by reports and business users | Power BI semantic model | `sm_sales_analytics` |
| Governed reporting | Reporting based on certified definitions | Prevents inconsistent metrics | Standard `Total Sales` measure |
| Business-facing model | Model expressed in business terms | Hides technical ingestion details | Customer, Product, Sales Amount |
| Semantic model | Power BI model over analytical data | Defines measures, relationships, hierarchies, and security | `sm_sales_analytics` |
| Direct Gold access | Reports query Gold tables directly | Technically possible but not preferred for governed reporting | Report connects directly to `gold.FactSales` |
| Gold dependency | Semantic model depends on Gold objects | Keeps reporting based on trusted analytical objects | `sm_sales_analytics` over `wh_sales_analytics.gold` |

Recommended reporting rule:

> Reports should consume the governed Power BI Semantic Model instead of directly querying Bronze, Silver, Staging, or Gold objects.

## Storage and Format Concepts

| Concept | Short Definition | Role in This Project | Example |
|---|---|---|---|
| OneLake | Fabric unified data lake | Foundation for Fabric data storage | Lakehouse data stored in OneLake |
| Delta Lake | Table format over Parquet | Used for Lakehouse tables | Bronze and Silver Delta tables |
| Parquet | Columnar file format | Efficient analytical storage | Delta tables use Parquet files |
| Open analytical storage | Data stored in open analytical formats | Supports broader analytical use | Delta/Parquet |
| Relational analytical structure | SQL-style structure for analytics | Used by Warehouse and Gold model | Fact and dimension tables |

## Preferred Terms

| Use This Term | Meaning | Avoid This When |
|---|---|---|
| Microsoft Fabric | Overall Microsoft analytics platform | You mean a specific Lakehouse, Warehouse, or semantic model |
| Target analytics platform | General target architecture | You know the specific target component |
| Fabric Lakehouse | Lakehouse target component | You mean the Warehouse or semantic model |
| Fabric Warehouse | Warehouse target component | You mean the Lakehouse or semantic model |
| Power BI Semantic Model | Reporting consumption component | You mean Gold tables |
| Gold objects | Final analytical facts and dimensions | You mean semantic model measures |
| Source platform | Current SQL Server environment | You mean a specific source database or source object |
| Source database | Existing SQL Server database used as input | You mean a specific table, view, or query |
| Source object | Table, view, or query read from a source database | You mean the full source platform |
| Target component | Target platform asset | You mean individual table |
| Target object | Table, view, procedure, pipeline, notebook, or model entity | You mean a Lakehouse, Warehouse, or semantic model as a whole |
| Data area | Logical responsibility | You mean exact physical schema |
| Schema | Physical implementation grouping | You mean conceptual data responsibility |
| Operational system of record | Operational authority for transactions | You mean a reporting database |
| Current reporting source of truth | Existing reporting authority before modernization | You mean the target model after cutover |
| Target reporting source of truth | Future reporting authority after cutover | You mean the current SQL Server reporting database |

## Project Mental Model

```text
Current source platform
  Sales_Operational
    - operational system of record
    - provides new transactional data

  Sales_Analytics
    - current reporting source of truth
    - provides historical reporting baseline

Target analytics platform
  lh_sales_operational
    bronze = raw operational data
    silver = curated operational data

  wh_sales_analytics
    staging = temporary historical loading area
    gold = final analytical model

  sm_sales_analytics
    semantic model = governed reporting layer

Control
  DataOps_Control
    metadata
    execution tracking
    validation
    reconciliation
    errors
    reruns
```
