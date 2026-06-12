# Solution Design

## Purpose

This document defines the initial technical structure for the **Sales Platform Modernization: SQL Server to Microsoft Fabric** project.

The project modernizes the existing on-premise Sales analytical platform into Microsoft Fabric while keeping `Sales_Operational` active as the operational source of truth.

## Source Platform

The current on-premise platform contains two SQL Server databases used by the Sales domain.

### Source Databases

| Source database | Current role | Role in modernization |
|---|---|---|
| `Sales_Operational` | Curated operational Sales database. | Remains the operational source of truth and feeds Fabric through long-term incremental processing. |
| `Sales_Analytics` | Existing on-premise analytical/reporting database. | Used for historical backfill, temporary coexistence synchronization, reconciliation, and fallback during transition. |

### Technical Details

| Item | Description |
|---|---|
| Source platform | SQL Server |
| Version | SQL Server 2022 |
| Hosting model | On-premise |

### Source Platform Rules

- `Sales_Analytics` is not immediately decommissioned.
- Fabric should not modify on-premise source databases.

## Target Platform

The target platform uses Microsoft Fabric for analytical processing and Azure SQL Database for the shared control framework.

### Target Assets

| Target asset | Name | Purpose |
|---|---|---|
| Fabric Lakehouse | `lh_sales_operational` | Stores Bronze and Silver Delta tables for operational data ingestion and curation. |
| Fabric Warehouse | `wh_sales_analytics` | Stores analytical staging and Gold dimensional/reporting objects. |
| Power BI semantic model | `sm_sales_analytics` | Provides the reporting consumption layer for Power BI. |
| Azure SQL Database | `DataOps_Control` | Shared metadata-driven control framework for orchestration, execution tracking, validation, reconciliation, logging, batch control, and rerun support. |

### Technical Details

| Component | Technical detail |
|---|---|
| Lakehouse storage | Delta tables |
| Warehouse storage | Fabric Warehouse relational tables and views |
| Reporting layer | Power BI semantic model over Fabric Gold objects |
| Control framework | Azure SQL Database shared across projects |

### Target Platform Rules

- Bronze and Silver are implemented in the Lakehouse.
- Staging and Gold are implemented in the Warehouse.
- Power BI should consume the semantic model, not the raw Lakehouse or staging tables.
- `DataOps_Control` is a shared framework and should not be treated as a Sales-only database.

### Target Naming Conventions

| Object type | Convention | Example |
|---|---|---|
| Workspace | `ws_[domain]_[purpose]_[environment]` | `ws_sales_modernization_dev` |
| Lakehouse | `lh_[domain]_[purpose]` | `lh_sales_operational` |
| Warehouse | `wh_[domain]_[purpose]` | `wh_sales_analytics` |
| Semantic model | `sm_[domain]_[purpose]` | `sm_sales_analytics` |

## Schema Organization

Schemas are used to separate responsibilities inside Fabric assets.

### Lakehouse: lh_sales_operational

| Schema | Purpose |
|---|---|
| `bronze` | Stores raw source-aligned operational data extracted from `Sales_Operational`. |
| `silver` | Stores curated, standardized, and validated operational data inside Fabric. |

### Warehouse: wh_sales_analytics

| Schema | Purpose |
|---|---|
| `staging` | Temporarily stores analytical data extracted from `Sales_Analytics` for historical backfill and coexistence synchronization. |
| `gold` | Stores final dimensional and analytical reporting objects. |

## Target Tables

### Lakehouse: lh_sales_operational

#### Naming Conventions

| Object type | Convention | Example |
|---|---|---|
| Bronze table | `bronze.[entity_name]` | `bronze.SalesOrderHeader` |
| Silver table | `silver.[entity_name]` | `silver.SalesOrderHeader` |
| Table names | Source-aligned `PascalCase` | `SalesOrderDetail` |
| Business/source columns | Preserve source `PascalCase` | `SalesOrderID`, `CustomerID`, `OrderDate` |
| Technical columns | Descriptive `snake_case` | `ingestion_run_id`, `execution_step_id` |

#### Bronze Tables

| Data role | Bronze object | Source database | Source table | Purpose |
|---|---|---|---|---|
| Transactional | `bronze.SalesOrderHeader` | `Sales_Operational` | `SalesOrderHeader` | Stores raw sales order header records. |
| Transactional | `bronze.SalesOrderDetail` | `Sales_Operational` | `SalesOrderDetail` | Stores raw sales order line records. |
| Master / Core | `bronze.Customer` | `Sales_Operational` | `Customer` | Stores raw customer records. |
| Master / Core | `bronze.SalesPerson` | `Sales_Operational` | `SalesPerson` | Stores raw salesperson records. |
| Master / Core | `bronze.Product` | `Sales_Operational` | `Product` | Stores raw product records. |
| Master / Core | `bronze.Address` | `Sales_Operational` | `Address` | Stores raw address records. |
| Master / Core | `bronze.CreditCard` | `Sales_Operational` | `CreditCard` | Stores raw payment-related source records. |
| Reference / Lookup | `bronze.AddressType` | `Sales_Operational` | `AddressType` | Stores raw address type values. |
| Reference / Lookup | `bronze.CountryRegion` | `Sales_Operational` | `CountryRegion` | Stores raw country/region values. |
| Reference / Lookup | `bronze.StateProvince` | `Sales_Operational` | `StateProvince` | Stores raw state/province values. |
| Reference / Lookup | `bronze.SalesTerritory` | `Sales_Operational` | `SalesTerritory` | Stores raw sales territory values. |
| Reference / Lookup | `bronze.Currency` | `Sales_Operational` | `Currency` | Stores raw currency values. |
| Reference / Lookup | `bronze.CurrencyRate` | `Sales_Operational` | `CurrencyRate` | Stores raw currency rate values. |
| Reference / Lookup | `bronze.ShipMethod` | `Sales_Operational` | `ShipMethod` | Stores raw shipping method values. |
| Reference / Lookup | `bronze.SpecialOffer` | `Sales_Operational` | `SpecialOffer` | Stores raw promotion and discount values. |
| Reference / Lookup | `bronze.ProductCategory` | `Sales_Operational` | `ProductCategory` | Stores raw product category values. |

#### Silver Tables

| Data role | Silver object | Source object | Purpose |
|---|---|---|---|
| Transactional | `silver.SalesOrderHeader` | `bronze.SalesOrderHeader` | Stores curated and validated sales order header records. |
| Transactional | `silver.SalesOrderDetail` | `bronze.SalesOrderDetail` | Stores curated and validated sales order line records. |
| Master / Core | `silver.Customer` | `bronze.Customer` | Stores standardized customer records. |
| Master / Core | `silver.SalesPerson` | `bronze.SalesPerson` | Stores standardized salesperson records. |
| Master / Core | `silver.Product` | `bronze.Product` | Stores standardized product records. |
| Master / Core | `silver.Address` | `bronze.Address` | Stores standardized address records. |
| Master / Core | `silver.CreditCard` | `bronze.CreditCard` | Stores reporting-safe payment source attributes. |
| Reference / Lookup | `silver.AddressType` | `bronze.AddressType` | Stores validated address type values. |
| Reference / Lookup | `silver.CountryRegion` | `bronze.CountryRegion` | Stores validated country/region values. |
| Reference / Lookup | `silver.StateProvince` | `bronze.StateProvince` | Stores validated state/province values. |
| Reference / Lookup | `silver.SalesTerritory` | `bronze.SalesTerritory` | Stores validated sales territory values. |
| Reference / Lookup | `silver.Currency` | `bronze.Currency` | Stores validated currency values. |
| Reference / Lookup | `silver.CurrencyRate` | `bronze.CurrencyRate` | Stores validated currency rate values. |
| Reference / Lookup | `silver.ShipMethod` | `bronze.ShipMethod` | Stores validated shipping method values. |
| Reference / Lookup | `silver.SpecialOffer` | `bronze.SpecialOffer` | Stores validated promotion and discount values. |
| Reference / Lookup | `silver.ProductCategory` | `bronze.ProductCategory` | Stores validated product category values. |

### Warehouse: wh_sales_analytics

#### Naming Conventions

| Object type | Convention | Example |
|---|---|---|
| Staging table | `staging.[analytical_object_name]` | `staging.FactSales` |
| Gold dimension table | `gold.Dim[entity_name]` | `gold.DimCustomer` |
| Gold fact table | `gold.Fact[business_process]` | `gold.FactSales` |
| Surrogate key | `[entity_name]Key` | `CustomerKey` |
| Source key | Source business key name where possible | `SourceCustomerID` |

#### Staging Objects

| Data role | Staging object | Source database | Source object | Purpose |
|---|---|---|---|---|
| Fact staging | `staging.FactSales` | `Sales_Analytics` | `FactSales` | Stores analytical fact data for historical backfill and coexistence synchronization. |
| Dimension staging | `staging.DimCustomer` | `Sales_Analytics` | `DimCustomer` | Stores analytical customer dimension data for backfill and comparison. |
| Dimension staging | `staging.DimProduct` | `Sales_Analytics` | `DimProduct` | Stores analytical product dimension data for backfill and comparison. |
| Dimension staging | `staging.DimSalesPerson` | `Sales_Analytics` | `DimSalesPerson` | Stores analytical salesperson dimension data for backfill and comparison. |
| Dimension staging | `staging.DimSalesTerritory` | `Sales_Analytics` | `DimSalesTerritory` | Stores analytical sales territory dimension data for backfill and comparison. |
| Dimension staging | `staging.DimPaymentMethod` | `Sales_Analytics` | `DimPaymentMethod` | Stores analytical payment method dimension data for backfill and comparison. |
| Dimension staging | `staging.DimShipMethod` | `Sales_Analytics` | `DimShipMethod` | Stores analytical ship method dimension data for backfill and comparison. |
| Dimension staging | `staging.DimDate` | `Sales_Analytics` or generated calendar | `DimDate` | Stores date dimension data or supports generated calendar alignment. |

#### Gold Objects

| Data role | Gold object | Source object / input | Purpose |
|---|---|---|---|
| Fact | `gold.FactSales` | `silver.SalesOrderHeader`, `silver.SalesOrderDetail`, `staging.FactSales` | Stores final sales transaction facts at sales order detail grain. |
| Dimension | `gold.DimDate` | `staging.DimDate` | Supports date-based reporting for order date, due date, and ship date. |
| Dimension | `gold.DimCustomer` | `silver.Customer`, `staging.DimCustomer` | Stores final reporting-ready customer dimension. |
| Dimension | `gold.DimProduct` | `silver.Product`, `silver.ProductCategory`, `staging.DimProduct` | Stores final reporting-ready product dimension with category attributes. |
| Dimension | `gold.DimSalesPerson` | `silver.SalesPerson`, `staging.DimSalesPerson` | Stores final reporting-ready salesperson dimension. |
| Dimension | `gold.DimSalesTerritory` | `silver.SalesTerritory`, `silver.CountryRegion`, `silver.StateProvince`, `staging.DimSalesTerritory` | Stores final reporting-ready geography and territory dimension. |
| Dimension | `gold.DimPaymentMethod` | `silver.CreditCard`, `staging.DimPaymentMethod` | Stores reporting-safe payment method attributes. |
| Dimension | `gold.DimShipMethod` | `silver.ShipMethod`, `staging.DimShipMethod` | Stores final reporting-ready shipping method dimension. |

## Data Flow Strategy

The solution supports three controlled data flows because the modernization is designed as a hybrid transition, not an immediate replacement of the on-premise analytical platform.

### Data Flow Summary

| Flow | Source | Purpose | Duration |
|---|---|---|---|
| Historical backfill | `Sales_Analytics` | Loads previous analytical history into Fabric before reporting cutover. | Initial migration phase |
| Coexistence synchronization | `Sales_Analytics` | Keeps Fabric aligned while `Sales_Analytics` is still active during the transition period. | Temporary coexistence phase |
| Operational incremental load | `Sales_Operational` | Supports long-term analytical processing from the operational source of truth. | Long-term target state |

### Historical Backfill Flow

| Item | Description |
|---|---|
| Source | `Sales_Analytics` |
| Target staging area | `wh_sales_analytics.staging` |
| Final target | `wh_sales_analytics.gold` |
| Main purpose | Load historical analytical data that already exists in the on-premise reporting database. |
| Example objects | `FactSales`, `DimCustomer`, `DimProduct`, `DimSalesTerritory`, `DimDate` |
| Control requirement | Register execution, validate counts and totals, reconcile against the source, and only then publish to Gold. |

#### Flow Pattern

```text
Sales_Analytics
    -> wh_sales_analytics.staging
    -> validation and reconciliation
    -> wh_sales_analytics.gold
```

### Coexistence Synchronization Flow

| Item | Description |
|---|---|
| Source | `Sales_Analytics` |
| Target staging area | `wh_sales_analytics.staging` |
| Final target | `wh_sales_analytics.gold` |
| Main purpose | Synchronize new analytical records if `Sales_Analytics` continues receiving data before shutdown. |
| Example objects | `FactSales` and related dimensions |
| Control requirement | Separate coexistence loads from historical backfill using metadata such as load strategy, batch period, and execution run. |

#### Flow Pattern

```text
Sales_Analytics
    -> wh_sales_analytics.staging
    -> duplicate and cutover boundary checks
    -> validation and reconciliation
    -> wh_sales_analytics.gold
```

### Operational Incremental Load Flow

| Item | Description |
|---|---|
| Source | `Sales_Operational` |
| Raw target | `lh_sales_operational.bronze` |
| Curated target | `lh_sales_operational.silver` |
| Final analytical target | `wh_sales_analytics.gold` |
| Main purpose | Support the long-term Fabric analytical model from the operational source of truth. |
| Example objects | `SalesOrderHeader`, `SalesOrderDetail`, `Customer`, `Product`, `SalesTerritory` |
| Control requirement | Register ingestion, transformation, validation, reconciliation, and rerun status in `DataOps_Control`. |

#### Flow Pattern

```text
Sales_Operational
    -> lh_sales_operational.bronze
    -> lh_sales_operational.silver
    -> wh_sales_analytics.gold
```

### Data Flow Rules

- `Sales_Operational` remains the operational source of truth.
- `Sales_Analytics` is used only for historical backfill, coexistence synchronization, reconciliation, and fallback during the transition.
- `Sales_Analytics` should not remain a permanent source after the operational cutover is accepted.
- Data from `Sales_Operational` must land in Bronze before being curated in Silver.
- Data from `Sales_Analytics` must land in Warehouse staging before being merged or loaded into Gold.
- Power BI should consume Gold through the semantic model, not staging or raw Lakehouse tables.
- Each flow must be registered and tracked through `DataOps_Control`.
- Validation and reconciliation should be completed before Gold data is considered trusted.
- A cutover boundary must prevent the same reporting period from being loaded into Gold from both `Sales_Analytics` and `Sales_Operational`.

## Cutover Strategy

The cutover strategy defines which source is responsible for loading each reporting period into `wh_sales_analytics.gold`.

The main objective is to prevent the same analytical period from being loaded from both `Sales_Analytics` and `Sales_Operational`.

### Cutover Rule

Only one source can own a reporting period in Gold at a time.

| Period / phase | Gold owner source | Load path |
|---|---|---|
| Historical periods before Fabric implementation | `Sales_Analytics` | `Sales_Analytics` → `wh_sales_analytics.staging` → `wh_sales_analytics.gold` |
| Coexistence period before operational cutover | `Sales_Analytics` | `Sales_Analytics` → `wh_sales_analytics.staging` → `wh_sales_analytics.gold` |
| Periods after operational cutover | `Sales_Operational` | `Sales_Operational` → `lh_sales_operational.bronze` → `lh_sales_operational.silver` → `wh_sales_analytics.gold` |

### Cutover Metadata

Each Gold load should be tracked with metadata that identifies the source and phase of the load.

| Metadata item | Purpose |
|---|---|
| `source_database` | Identifies whether the data came from `Sales_Analytics` or `Sales_Operational`. |
| `load_strategy` | Identifies whether the load is `historical_backfill`, `coexistence_sync`, or `operational_incremental`. |
| `batch_period_yyyymm` | Identifies the reporting period being loaded. |
| `execution_run_id` | Links the load to the execution registered in `DataOps_Control`. |

### Cutover Controls

Before loading a period into Gold:

- Check whether the period already exists in Gold.
- Check which source currently owns the period.
- Do not load the same period from a different source unless it is an approved reprocessing or cutover correction.
- Reconcile the period before marking it as accepted.
- After operational cutover, disable coexistence synchronization from `Sales_Analytics`.

### Acceptance Criteria

A reporting period can be considered cut over when:

- Gold records are loaded from the approved owner source.
- Validation and reconciliation checks are successful or accepted.
- Power BI results match the agreed business baseline.
- The period is no longer expected to be updated from the previous source.

## Load Strategy

The load strategy defines how data is refreshed in Fabric.

This section separates load strategies from data flow scenarios. Historical backfill, coexistence synchronization, and operational incremental processing are flow scenarios. They may use different load strategies depending on the source object, data volume, change pattern, and recovery requirement.

### Load Strategy Types

| Load strategy | Description | Best for |
|---|---|---|
| Full reload | Replaces or reloads the full target dataset. | Small reference tables or controlled one-time loads. |
| Watermark incremental load | Loads records changed after the last successful watermark. | Master/core entities and analytical objects with reliable change tracking columns. |
| Batch period reload | Reloads a specific business period, usually based on `batch_period_yyyymm`. | Transactional and fact data that must support reconciliation and rerun by period. |

### Load Strategy by Data Role

| Data role | Preferred load strategy | Example objects |
|---|---|---|
| Reference / Lookup | Full reload | `Currency`, `ShipMethod`, `AddressType`, `ProductCategory` |
| Master / Core | Watermark incremental load | `Customer`, `Product`, `SalesPerson`, `Address` |
| Transactional | Batch period reload | `SalesOrderHeader`, `SalesOrderDetail` |
| Analytical dimensions | Full reload or watermark incremental load | `DimCustomer`, `DimProduct`, `DimSalesTerritory` |
| Analytical facts | Batch period reload or watermark incremental load | `FactSales` |

### Load Strategy by Data Flow

| Data flow | Load strategy options | Notes |
|---|---|---|
| Historical backfill from `Sales_Analytics` | Full reload or batch period reload | Batch period reload is preferred for large historical fact tables. |
| Coexistence synchronization from `Sales_Analytics` | Watermark incremental load or batch period reload | Depends on whether reliable change columns exist in `Sales_Analytics`. |
| Operational processing from `Sales_Operational` | Full reload, watermark incremental load, or batch period reload | Strategy depends on the data role and table behavior. |

### Load Strategy Rules

- Full reload should be used only when the data volume is small or the reload scope is controlled.
- Watermark incremental load requires a reliable change tracking column.
- Batch period reload should be used for transactional and fact data where recovery by business period is required.

## Validation Strategy

The validation strategy defines the checks required before data is promoted across Fabric layers.

Validation focuses on record-level and dataset-level quality rules. Reconciliation is handled separately and focuses on comparing counts, totals, and business metrics between source and target.

### Validation Points

| Validation point | Purpose |
|---|---|
| Source to Bronze | Confirms that extracted data can be landed and tracked. |
| Bronze to Silver | Confirms that records are clean, typed, deduplicated, and business-valid. |
| Staging to Gold | Confirms that historical or coexistence analytical data is acceptable before publishing to Gold. |
| Silver to Gold | Confirms that curated operational data can support dimensional modeling and reporting. |

### Common Validation Rules

| Validation rule | Applies to | Purpose |
|---|---|---|
| Required key validation | Bronze, Silver, Gold | Ensures business keys and foreign keys are present. |
| Data type validation | Bronze, Silver | Ensures values can be safely converted to target data types. |
| Duplicate validation | Silver, Gold | Prevents duplicate business keys or duplicate fact rows. |
| Date validation | Silver, Gold | Ensures business dates are valid and within expected ranges. |
| Reference validation | Silver, Gold | Ensures related master/reference records exist. |
| Amount validation | Silver, Gold | Ensures financial values are valid for reporting. |
| Cutover ownership validation | Staging, Gold | Prevents the same period from being loaded from multiple sources. |
