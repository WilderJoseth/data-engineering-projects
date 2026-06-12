# Concepts and Terminology Guide

## Document Goal

This guide is used to keep terminology consistent across the project documentation.

## Core Architecture Concepts

| Concept                    | Short Definition                                                      | Role in This Project                                                      | Example                                                                               |
| -------------------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Source platform            | Current platform where data comes from                                | On-premise SQL Server environment used by the current Sales platform      | SQL Server 2022 instance                                                              |
| Target analytical platform | Future analytical platform used for reporting modernization           | Cloud analytical platform that receives historical and new reporting data | Lakehouse, Warehouse, Semantic Model                                                  |
| Source component           | Existing database or system that provides data                        | Supplies historical or new data to the modernization process              | `Sales_Operational`, `Sales_Analytics`                                                |
| Target component           | Target asset used to store, process, expose, or control data          | Main components of the target architecture                                | `lh_sales_operational`, `wh_sales_analytics`, `sm_sales_analytics`, `DataOps_Control` |
| Data area                  | Logical responsibility inside the target platform                     | Describes what each area does                                             | Bronze, Silver, Staging, Gold, Power BI Semantic Model                                |
| Source of truth            | Trusted system or component for a specific responsibility             | Clarifies which component should be trusted                               | `Sales_Operational` for active transactions                                           |
| System of record           | Authoritative system for business transactions                        | Confirms operational processing stays on-premise                          | `Sales_Operational`                                                                   |
| Historical baseline        | Trusted historical reporting data used to initialize the target model | Provides existing reporting history                                       | `Sales_Analytics`                                                                     |
| Reporting source of truth  | Trusted source used by reporting consumers                            | Moves to the target analytical model after cutover                        | `wh_sales_analytics` and `sm_sales_analytics`                                         |

## Source Components

| Component           | Type                                   | Role                                | Important Notes                                                                     |
| ------------------- | -------------------------------------- | ----------------------------------- | ----------------------------------------------------------------------------------- |
| `Sales_Operational` | SQL Server database                    | Operational source of truth         | Remains on-premise and provides new transactional data for future reporting periods |
| `Sales_Analytics`   | SQL Server database                    | Current reporting source of truth   | Provides trusted historical reporting baseline before cutover                       |
| `DataOps_Control`   | Azure SQL Database / control framework | Execution and observability control | Tracks metadata, execution, validation, reconciliation, errors, and reruns          |

## Target Components

| Target Component        | Proposed Name          | Role                                                | Example Responsibility                                           |
| ----------------------- | ---------------------- | --------------------------------------------------- | ---------------------------------------------------------------- |
| Fabric Lakehouse        | `lh_sales_operational` | Stores and processes operational-source data        | Bronze and Silver operational data areas                         |
| Fabric Warehouse        | `wh_sales_analytics`   | Stores analytical reporting objects                 | Staging and Gold analytical data areas                           |
| Power BI Semantic Model | `sm_sales_analytics`   | Provides governed reporting consumption             | Business-facing reporting layer over Gold data                   |
| Azure SQL Database      | `DataOps_Control`      | Provides shared execution control and observability | Metadata, execution tracking, validation, reconciliation, reruns |

## Target Data Areas

| Data Area               | Location  | Short Definition                  | Role in This Project                                                     | Example                              |
| ----------------------- | --------- | --------------------------------- | ------------------------------------------------------------------------ | ------------------------------------ |
| Bronze                  | Lakehouse | Raw source-aligned data area      | Stores operational data as close to the source as practical              | `bronze.SalesOrderHeader`            |
| Silver                  | Lakehouse | Curated operational data area     | Standardizes, validates, and prepares Bronze data                        | `silver.Customer`                    |
| Staging                 | Warehouse | Temporary historical loading area | Supports historical loads from `Sales_Analytics` before Gold publication | `staging.FactSales`                  |
| Gold                    | Warehouse | Final analytical reporting area   | Stores reporting-ready facts and dimensions                              | `gold.FactSales`, `gold.DimCustomer` |
| Power BI Semantic Model | Power BI  | Governed reporting model          | Exposes measures, relationships, and business-facing reporting logic     | `sm_sales_analytics`                 |

## Layer, Schema, Area, and Object

| Term      | Use When                                                           | Avoid When                                           | Example                                            |
| --------- | ------------------------------------------------------------------ | ---------------------------------------------------- | -------------------------------------------------- |
| Layer     | Speaking conceptually about Medallion architecture                 | Referring to exact implementation objects            | Bronze layer, Silver layer, Gold layer             |
| Schema    | Referring to implementation grouping inside Lakehouse or Warehouse | Speaking generally about architecture responsibility | `bronze`, `silver`, `staging`, `gold`              |
| Data area | Referring to logical responsibilities across the target platform   | Referring only to physical database schema           | Bronze, Silver, Staging, Gold, Semantic Model      |
| Object    | Referring generally to tables, views, models, or other assets      | When the exact type matters                          | Gold objects, Bronze objects, target objects       |
| Component | Referring to a main platform asset                                 | Referring to individual tables                       | Fabric Lakehouse, Fabric Warehouse, Semantic Model |

Recommended usage:

| Situation                          | Preferred Term   |
| ---------------------------------- | ---------------- |
| Explaining the architecture        | Data area        |
| Describing physical implementation | Schema           |
| Listing main Fabric assets         | Target component |
| Listing tables/views/models        | Object           |
| Explaining Medallion concepts      | Layer            |

## Source Data Categories

| Data Category         | Short Definition                                   | Main Source         | Expected Volume | Example                                 |
| --------------------- | -------------------------------------------------- | ------------------- | --------------- | --------------------------------------- |
| Reference / Lookup    | Stable or low-change descriptive values            | `Sales_Operational` | Low             | `Currency`, `ShipMethod`, `AddressType` |
| Master / Core         | Main business entities used across Sales processes | `Sales_Operational` | Medium          | `Customer`, `Product`, `SalesPerson`    |
| Transactional         | Sales business events and transaction records      | `Sales_Operational` | High            | `SalesOrderHeader`, `SalesOrderDetail`  |
| Analytical Dimensions | Reporting-ready descriptive structures             | `Sales_Analytics`   | Medium          | `DimCustomer`, `DimProduct`             |
| Analytical Facts      | Reporting-ready measurable business events         | `Sales_Analytics`   | Very high       | `FactSales`                             |

## Data Flow Concepts

| Concept                   | Short Definition                                                  | Role in This Project                                             | Example                                            |
| ------------------------- | ----------------------------------------------------------------- | ---------------------------------------------------------------- | -------------------------------------------------- |
| Data flow                 | Movement path from source to target                               | Explains how data travels through the architecture               | Source → target data area                          |
| Historical reporting flow | Loads trusted historical reporting data                           | Initializes the target analytical model                          | `Sales_Analytics` → `staging` → `gold`             |
| New reporting data flow   | Builds new reporting data from operational source                 | Long-term flow for future reporting periods                      | `Sales_Operational` → `bronze` → `silver` → `gold` |
| Coexistence support flow  | Temporary flow during transition                                  | Supports comparison and controlled reporting cutover             | Existing reporting and target reporting coexist    |
| Reporting boundary period | Business period separating historical and new reporting ownership | Prevents duplicate period loading                                | History through 2025-12, new data from 2026-01     |
| Period ownership          | Rule defining which source owns a reporting period                | Prevents the same period from being loaded from multiple sources | One period, one approved source                    |

## Load Strategy Concepts

| Concept                    | Short Definition                                    | Role in This Project                                | Example                                       |
| -------------------------- | --------------------------------------------------- | --------------------------------------------------- | --------------------------------------------- |
| Load strategy              | Rule for refreshing a data object                   | Defines how source and target objects are processed | Full reload, incremental, batch period reload |
| Full reload                | Reloads the complete dataset                        | Used for small or controlled objects                | Reload `Currency`                             |
| Watermark incremental load | Loads records changed since last successful load    | Used for objects with reliable change tracking      | `ModifiedDate > last_watermark`               |
| Batch period reload        | Reloads a specific business period                  | Used for facts and transactional data               | Reload `FactSales` for `202501`               |
| Watermark column           | Column used to detect new or changed records        | Required for incremental loads                      | `ModifiedDate`, `CreatedDate`, `rowversion`   |
| Batch period               | Business period used for grouped loading            | Supports controlled reruns and reconciliation       | `batch_period_yyyymm`                         |
| Backfill                   | Initial load of historical data                     | Initializes the target analytical model             | Load historical `FactSales`                   |
| Rerun                      | Controlled reprocessing after failure or correction | Supports recovery                                   | Rerun a failed reporting period               |

## Validation, Reconciliation, and Control

| Concept            | Short Definition                                   | Role in This Project                  | Example                                        |
| ------------------ | -------------------------------------------------- | ------------------------------------- | ---------------------------------------------- |
| Validation         | Checks data quality or business rules              | Confirms loaded data is acceptable    | Required fields, valid dates, duplicate checks |
| Reconciliation     | Compares source and target results                 | Confirms completeness and consistency | Source count equals target count               |
| Execution tracking | Records process execution status                   | Supports observability                | Pipeline started, completed, failed            |
| Error logging      | Captures technical failures                        | Supports troubleshooting              | Extraction failure, transformation error       |
| Rerun support      | Allows safe reprocessing                           | Supports recovery                     | Rerun by object or batch period                |
| Observability      | Ability to monitor execution health                | Helps operate the solution reliably   | Execution dashboard, logs, control tables      |
| Control framework  | Shared structure for metadata and runtime tracking | Centralizes operational control       | `DataOps_Control`                              |

## Reporting and Consumption

| Concept                     | Short Definition                         | Role in This Project                                          | Example                                             |
| --------------------------- | ---------------------------------------- | ------------------------------------------------------------- | --------------------------------------------------- |
| Reporting consumption layer | Layer used by reports and business users | Power BI semantic model                                       | `sm_sales_analytics`                                |
| Governed reporting          | Reporting based on certified definitions | Prevents inconsistent metrics                                 | Standard `Total Sales` measure                      |
| Business-facing model       | Model expressed in business terms        | Hides technical ingestion details                             | Customer, Product, Sales Amount                     |
| Semantic model              | Power BI model over analytical data      | Defines measures, relationships, hierarchies, and security    | `sm_sales_analytics`                                |
| Direct Gold access          | Reports query Gold tables directly       | Technically possible but not preferred for governed reporting | Report connects directly to `gold.FactSales`        |
| Gold dependency             | Semantic model depends on Gold objects   | Keeps reporting based on trusted analytical objects           | `sm_sales_analytics` over `wh_sales_analytics.gold` |

Recommended reporting rule:

Reports should consume the governed Power BI Semantic Model instead of directly querying Bronze, Silver, Staging, or Gold objects.

## Storage and Format Concepts

| Concept                         | Short Definition                       | Role in This Project               | Example                          |
| ------------------------------- | -------------------------------------- | ---------------------------------- | -------------------------------- |
| OneLake                         | Fabric unified data lake               | Foundation for Fabric data storage | Lakehouse data stored in OneLake |
| Delta Lake                      | Table format over Parquet              | Used for Lakehouse tables          | Bronze and Silver Delta tables   |
| Parquet                         | Columnar file format                   | Efficient analytical storage       | Delta tables use Parquet files   |
| Open analytical storage         | Data stored in open analytical formats | Supports broader analytical use    | Delta/Parquet                    |
| Relational analytical structure | SQL-style structure for analytics      | Used by Warehouse and Gold model   | Fact and dimension tables        |

## Preferred Terminology

| Use This Term              | Meaning                               | Avoid This When                                             |
| -------------------------- | ------------------------------------- | ----------------------------------------------------------- |
| Microsoft Fabric           | Overall Microsoft analytics platform  | You mean a specific Lakehouse, Warehouse, or semantic model |
| Target analytical platform | General target architecture           | You know the specific target component                      |
| Fabric Lakehouse           | Lakehouse target component            | You mean the Warehouse or semantic model                    |
| Fabric Warehouse           | Warehouse target component            | You mean the Lakehouse or semantic model                    |
| Power BI Semantic Model    | Reporting consumption component       | You mean Gold tables                                        |
| Gold objects               | Final analytical facts and dimensions | You mean semantic model measures                            |
| Source component           | Current source database/system        | You mean target component                                   |
| Target component           | Target platform asset                 | You mean individual table                                   |
| Data area                  | Logical responsibility                | You mean exact physical schema                              |
| Schema                     | Physical implementation grouping      | You mean conceptual data responsibility                     |

## Project Mental Model

```text
Current source platform
  Sales_Operational
    - active operational source of truth
    - provides new transactional data

  Sales_Analytics
    - trusted reporting source of truth today
    - provides historical reporting baseline

Target analytical platform
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

## Quick Consistency Rules

| Rule                                                                                      | Explanation                                                                                     |
| ----------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| Do not use “Fabric” when a specific component is meant                                    | Use `lh_sales_operational`, `wh_sales_analytics`, or `sm_sales_analytics` when possible         |
| Use “target analytical platform” for the overall target architecture                      | This is more precise than saying Fabric every time                                              |
| Use “schema” for `bronze`, `silver`, `staging`, and `gold` when discussing implementation | These are physical/logical groupings inside Lakehouse or Warehouse                              |
| Use “data area” when discussing responsibilities                                          | Good for architecture explanations                                                              |
| Use “Power BI Semantic Model” when referring to the reporting model component             | Avoid calling it a table or schema                                                              |
| Use “Gold” for final analytical objects                                                   | Use “semantic model” for reporting consumption                                                  |
| Keep source profiling separate from target modeling                                       | `03_source_data_profile.md` describes sources; `04_target_data_model.md` describes targets      |
| Keep load strategy separate from data flow                                                | `05_data_flow_strategy.md` describes movement; `06_load_strategy.md` describes refresh behavior |
