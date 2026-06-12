# Load Strategy

## Document Goal

Define how Sales data should be refreshed in Microsoft Fabric.

This document explains the load strategies used by the project and how they apply to source data categories, Fabric schemas, and reporting objects.

## Load Strategy Overview

The solution uses three load strategies:

| Load Strategy              | Purpose                                                                     |
| -------------------------- | --------------------------------------------------------------------------- |
| Full reload                | Reload the full dataset for small or controlled objects                     |
| Watermark incremental load | Load only new or changed records based on a reliable change tracking column |
| Batch period reload        | Reload a specific business period, usually based on `batch_period_yyyymm`   |

The selected strategy depends on the source object, data role, data volume, change pattern, and recovery requirement.

## Load Strategy Types

### Full Reload

Full reload replaces or reloads the full target dataset.

| Item            | Description                                                         |
| --------------- | ------------------------------------------------------------------- |
| Best for        | Small reference tables, lookup tables, or controlled full refreshes |
| Main benefit    | Simple and reliable                                                 |
| Main limitation | Not suitable for large transactional history                        |
| Example objects | `Currency`, `ShipMethod`, `AddressType`, `ProductCategory`          |

### Watermark Incremental Load

Watermark incremental load extracts records that changed after the last successful load.

| Item            | Description                                                            |
| --------------- | ---------------------------------------------------------------------- |
| Best for        | Master/core entities and objects with reliable change tracking columns |
| Main benefit    | Reduces data movement and processing time                              |
| Main limitation | Requires a trusted watermark column                                    |
| Example objects | `Customer`, `Product`, `SalesPerson`, `Address`                        |

Common watermark candidates:

| Watermark Type      | Example                                    |
| ------------------- | ------------------------------------------ |
| Modified date       | `ModifiedDate`                             |
| Created date        | `CreatedDate`                              |
| Row version         | `rowversion` or equivalent tracking column |
| Source audit column | Source-controlled change timestamp         |

### Batch Period Reload

Batch period reload replaces or reloads a specific business period.

| Item            | Description                                                        |
| --------------- | ------------------------------------------------------------------ |
| Best for        | Transactional tables, fact tables, and period-based reconciliation |
| Main benefit    | Supports controlled recovery and rerun by period                   |
| Main limitation | Requires a reliable business date or period column                 |
| Example objects | `SalesOrderHeader`, `SalesOrderDetail`, `FactSales`                |

Common batch period candidates:

| Period Type      | Example                            |
| ---------------- | ---------------------------------- |
| Monthly period   | `batch_period_yyyymm`              |
| Order period     | Derived from `OrderDate`           |
| Posting period   | Derived from business posting date |
| Reporting period | Approved reporting calendar period |

## Load Strategy by Data Category

| Data Category         | Preferred Strategy                        | Reason                                                                                |
| --------------------- | ----------------------------------------- | ------------------------------------------------------------------------------------- |
| Reference / Lookup    | Full reload                               | Small and low-change objects are easier to refresh completely                         |
| Master / Core         | Watermark incremental load                | Business entities may change over time and should avoid full reload when volume grows |
| Transactional         | Batch period reload                       | Sales transactions need controlled recovery and reconciliation by reporting period    |
| Analytical Dimensions | Full reload or watermark incremental load | Depends on dimension size and change tracking availability                            |
| Analytical Facts      | Batch period reload                       | Historical facts should support period-based backfill, reconciliation, and rerun      |

## Load Strategy by Source

### Sales_Operational

`Sales_Operational` provides new operational data to Fabric.

| Data Role          | Source Objects                                                                               | Target Path                     | Preferred Strategy         |
| ------------------ | -------------------------------------------------------------------------------------------- | ------------------------------- | -------------------------- |
| Reference / Lookup | `AddressType`, `CountryRegion`, `StateProvince`, `Currency`, `ShipMethod`, `ProductCategory` | `prod` → Bronze → Silver        | Full reload                |
| Master / Core      | `Customer`, `Product`, `SalesPerson`, `Address`, `CreditCard`                                | `prod` → Bronze → Silver        | Watermark incremental load |
| Transactional      | `SalesOrderHeader`, `SalesOrderDetail`                                                       | `prod` → Bronze → Silver → Gold | Batch period reload        |

### Sales_Analytics

`Sales_Analytics` provides historical reporting data to initialize Fabric.

| Data Role             | Source Objects                                                                                                     | Target Path                       | Preferred Strategy                        |
| --------------------- | ------------------------------------------------------------------------------------------------------------------ | --------------------------------- | ----------------------------------------- |
| Analytical Dimensions | `DimCustomer`, `DimProduct`, `DimSalesPerson`, `DimSalesTerritory`, `DimPaymentMethod`, `DimShipMethod`, `DimDate` | `dim` → Warehouse staging → Gold  | Full reload or watermark incremental load |
| Analytical Facts      | `FactSales`                                                                                                        | `fact` → Warehouse staging → Gold | Batch period reload                       |

## Load Strategy by Fabric Schema

| Fabric Asset           | Schema    | Typical Strategy                                           | Notes                                                         |
| ---------------------- | --------- | ---------------------------------------------------------- | ------------------------------------------------------------- |
| `lh_sales_operational` | `bronze`  | Full reload, watermark incremental, or batch period reload | Strategy depends on source object category                    |
| `lh_sales_operational` | `silver`  | Same strategy as Bronze or controlled merge                | Silver should preserve traceability from Bronze               |
| `wh_sales_analytics`   | `staging` | Full reload or batch period reload                         | Used for historical analytical loads from `Sales_Analytics`   |
| `wh_sales_analytics`   | `gold`    | Batch period reload or controlled merge                    | Gold must preserve period ownership and reporting consistency |

## Historical Reporting Load Strategy

Historical reporting data comes from `Sales_Analytics`.

| Object Type           | Strategy                                  | Reason                                                                            |
| --------------------- | ----------------------------------------- | --------------------------------------------------------------------------------- |
| Historical dimensions | Full reload or watermark incremental load | Dimensions are already reporting-shaped and may be manageable as complete reloads |
| Historical facts      | Batch period reload                       | Fact history may be large and should support controlled period-based loading      |
| Date dimension        | Full reload or generated calendar         | Calendar data should be consistent across historical and new reporting periods    |

Historical fact loads should support reload by reporting period.

Example:

```text
FactSales for 2022-01
FactSales for 2022-02
FactSales for 2022-03
```

This allows historical data to be loaded, reconciled, and rerun in controlled batches.

## New Reporting Data Load Strategy

New reporting data comes from `Sales_Operational`.

| Object Type        | Strategy                   | Reason                                                                            |
| ------------------ | -------------------------- | --------------------------------------------------------------------------------- |
| Reference / Lookup | Full reload                | Low-change objects are simple to refresh completely                               |
| Master / Core      | Watermark incremental load | Entity changes should be captured without reloading full history                  |
| Transactional      | Batch period reload        | Sales transactions should support recovery and reconciliation by reporting period |
| Gold dimensions    | Controlled merge           | New and historical dimension records must align under one model                   |
| Gold facts         | Batch period reload        | New reporting facts should be loaded by approved reporting period                 |

New transactional loads should be based on a reliable business date, such as `OrderDate`, and assigned to a reporting period.

## Load Strategy Rules

| Rule                                                 | Description                                                                         |
| ---------------------------------------------------- | ----------------------------------------------------------------------------------- |
| Full reload is limited to controlled objects         | Use full reload for small or low-change objects, not large fact history             |
| Watermark loads require a reliable tracking column   | Do not use watermark incremental load without a trusted change column               |
| Batch period reload is preferred for facts           | Transactional and fact data should support period-based recovery                    |
| Gold must avoid duplicate period ownership           | The same reporting period should not be loaded from both historical and new sources |
| Reruns must be traceable                             | Reloaded objects or periods must be linked to execution metadata                    |
| Load strategy must be metadata-driven where possible | Object-level load behavior should be configurable through control metadata          |

## Rerun and Recovery Considerations

| Scenario                     | Expected Behavior                                               |
| ---------------------------- | --------------------------------------------------------------- |
| Reference load failure       | Rerun full object reload                                        |
| Master/core load failure     | Rerun from last successful watermark or approved recovery point |
| Transactional period failure | Rerun the affected reporting period                             |
| Historical fact failure      | Reload the affected historical period from `Sales_Analytics`    |
| Gold publication failure     | Reprocess affected Gold object or reporting period              |
| Reconciliation failure       | Keep the affected batch unaccepted until corrected or approved  |

Reruns should not create duplicate records in Silver or Gold.

## Load Strategy Assumptions

| Assumption                                         | Description                                                         |
| -------------------------------------------------- | ------------------------------------------------------------------- |
| Source databases are read-only for Fabric          | Fabric extracts data but does not update source databases           |
| Reference tables are manageable as full reloads    | These objects are expected to be small or low-change                |
| Master/core tables have change tracking candidates | Watermark columns should be confirmed during source profiling       |
| Fact and transactional data support period logic   | Period reloads depend on reliable business date columns             |
| Historical fact data may be large                  | `FactSales` should support period-based loading and rerun           |
| Detailed column mappings are not finalized         | Specific keys, watermarks, and date columns will be confirmed later |

## Conclusion

The load strategy separates refresh behavior from data flow design.

Reference data is generally loaded using full reloads. Master and core entities use watermark incremental loads when reliable change tracking exists. Transactional and fact data use batch period reloads to support reconciliation, recovery, and controlled reruns.

This strategy allows Fabric to load trusted historical reporting data from `Sales_Analytics` and new reporting data from `Sales_Operational` while maintaining traceability, recoverability, and reporting-period control.
