# Target Data Model

## Document Goal

This document describes the Lakehouse, Warehouse, and semantic model objects that will support the Warehouse Gold model exposed through the Power BI semantic model as the target reporting source of truth.

## Target Data Model Overview

The target data model is organized by data area and modeling responsibility.

| Data Area | Target Component | Main Responsibility |
|---|---|---|
| Bronze | `lh_sales_operational` | Store raw source-aligned operational data |
| Silver | `lh_sales_operational` | Store curated and standardized operational data |
| Staging | `wh_sales_analytics` | Temporarily store historical analytical data before Gold publication |
| Gold | `wh_sales_analytics` | Store final reporting-ready facts and dimensions |
| Semantic Model | `sm_sales_analytics` | Provides the governed reporting consumption layer |

## Lakehouse Data Model

The Lakehouse stores operational-source data from `Sales_Operational`.

It is organized into the `bronze` and `silver` schemas.

| Schema | Purpose |
|---|---|
| `bronze` | Preserves raw source-aligned operational data |
| `silver` | Standardizes, curates, and validates operational data before analytical transformation |

### Bronze Tables

Bronze tables store raw source-aligned records from `Sales_Operational.prod`.

| Data Role          | Bronze Table              | Source Object                             | Purpose                                   |
| ------------------ | ------------------------- | ----------------------------------------- | ----------------------------------------- |
| Transactional      | `bronze.SalesOrderHeader` | `Sales_Operational.prod.SalesOrderHeader` | Stores raw sales order header records     |
| Transactional      | `bronze.SalesOrderDetail` | `Sales_Operational.prod.SalesOrderDetail` | Stores raw sales order line records       |
| Master / Core      | `bronze.Customer`         | `Sales_Operational.prod.Customer`         | Stores raw customer records               |
| Master / Core      | `bronze.SalesPerson`      | `Sales_Operational.prod.SalesPerson`      | Stores raw salesperson records            |
| Master / Core      | `bronze.Product`          | `Sales_Operational.prod.Product`          | Stores raw product records                |
| Master / Core      | `bronze.Address`          | `Sales_Operational.prod.Address`          | Stores raw address records                |
| Master / Core      | `bronze.CreditCard`       | `Sales_Operational.prod.CreditCard`       | Stores raw payment-related source records |
| Reference / Lookup | `bronze.AddressType`      | `Sales_Operational.prod.AddressType`      | Stores raw address type values            |
| Reference / Lookup | `bronze.CountryRegion`    | `Sales_Operational.prod.CountryRegion`    | Stores raw country or region values       |
| Reference / Lookup | `bronze.StateProvince`    | `Sales_Operational.prod.StateProvince`    | Stores raw state or province values       |
| Reference / Lookup | `bronze.SalesTerritory`   | `Sales_Operational.prod.SalesTerritory`   | Stores raw sales territory values         |
| Reference / Lookup | `bronze.Currency`         | `Sales_Operational.prod.Currency`         | Stores raw currency values                |
| Reference / Lookup | `bronze.CurrencyRate`     | `Sales_Operational.prod.CurrencyRate`     | Stores raw currency exchange rate values  |
| Reference / Lookup | `bronze.ShipMethod`       | `Sales_Operational.prod.ShipMethod`       | Stores raw shipping method values         |
| Reference / Lookup | `bronze.SpecialOffer`     | `Sales_Operational.prod.SpecialOffer`     | Stores raw promotion and discount values  |
| Reference / Lookup | `bronze.ProductCategory`  | `Sales_Operational.prod.ProductCategory`  | Stores raw product category values        |

#### Bronze Rules

| Rule                   | Description                                                                               |
| ---------------------- | ----------------------------------------------------------------------------------------- |
| Source alignment       | Bronze tables should preserve the structure of the operational source as much as possible |
| No business remodeling | Bronze should not implement dimensional modeling                                          |
| Traceability           | Bronze tables should include technical metadata for ingestion tracking                    |
| Consumption boundary   | Bronze is used by Silver processes, not by reporting consumers                            |

### Silver Tables

Silver tables store curated operational data from Bronze.

| Data Role          | Silver Table              | Source Table              | Purpose                                         |
| ------------------ | ------------------------- | ------------------------- | ----------------------------------------------- |
| Transactional      | `silver.SalesOrderHeader` | `bronze.SalesOrderHeader` | Stores standardized sales order header records  |
| Transactional      | `silver.SalesOrderDetail` | `bronze.SalesOrderDetail` | Stores standardized sales order line records    |
| Master / Core      | `silver.Customer`         | `bronze.Customer`         | Stores standardized customer records            |
| Master / Core      | `silver.SalesPerson`      | `bronze.SalesPerson`      | Stores standardized salesperson records         |
| Master / Core      | `silver.Product`          | `bronze.Product`          | Stores standardized product records             |
| Master / Core      | `silver.Address`          | `bronze.Address`          | Stores standardized address records             |
| Master / Core      | `silver.CreditCard`       | `bronze.CreditCard`       | Stores reporting-safe payment source attributes |
| Reference / Lookup | `silver.AddressType`      | `bronze.AddressType`      | Stores validated address type values            |
| Reference / Lookup | `silver.CountryRegion`    | `bronze.CountryRegion`    | Stores validated country or region values       |
| Reference / Lookup | `silver.StateProvince`    | `bronze.StateProvince`    | Stores validated state or province values       |
| Reference / Lookup | `silver.SalesTerritory`   | `bronze.SalesTerritory`   | Stores validated sales territory values         |
| Reference / Lookup | `silver.Currency`         | `bronze.Currency`         | Stores validated currency values                |
| Reference / Lookup | `silver.CurrencyRate`     | `bronze.CurrencyRate`     | Stores validated currency exchange rate values  |
| Reference / Lookup | `silver.ShipMethod`       | `bronze.ShipMethod`       | Stores validated shipping method values         |
| Reference / Lookup | `silver.SpecialOffer`     | `bronze.SpecialOffer`     | Stores validated promotion and discount values  |
| Reference / Lookup | `silver.ProductCategory`  | `bronze.ProductCategory`  | Stores validated product category values        |

#### Silver Rules

| Rule                   | Description                                                        |
| ---------------------- | ------------------------------------------------------------------ |
| Standardization        | Silver applies consistent data types, naming, and formatting       |
| Data quality           | Silver removes or flags invalid, duplicated, or incomplete records |
| Business readiness     | Silver prepares operational data for analytical transformation     |
| No reporting ownership | Silver is not the final reporting layer                            |

## Warehouse Data Model

The Warehouse contains the `staging` and `gold` schemas.

| Schema | Purpose |
|---|---|
| `staging` | Temporarily stores historical reporting data from `Sales_Analytics` before publishing to Gold |
| `gold` | Stores final reporting-ready dimensional and fact objects |

### Staging Tables

Staging tables temporarily store historical analytical data from `Sales_Analytics`.

| Data Role         | Staging Table               | Source Object                           | Purpose                                                   |
| ----------------- | --------------------------- | --------------------------------------- | --------------------------------------------------------- |
| Fact staging      | `staging.FactSales`         | `Sales_Analytics.fact.FactSales`        | Stores historical sales fact data before Gold publication |
| Dimension staging | `staging.DimCustomer`       | `Sales_Analytics.dim.DimCustomer`       | Stores historical customer dimension data                 |
| Dimension staging | `staging.DimProduct`        | `Sales_Analytics.dim.DimProduct`        | Stores historical product dimension data                  |
| Dimension staging | `staging.DimSalesPerson`    | `Sales_Analytics.dim.DimSalesPerson`    | Stores historical salesperson dimension data              |
| Dimension staging | `staging.DimSalesTerritory` | `Sales_Analytics.dim.DimSalesTerritory` | Stores historical territory dimension data                |
| Dimension staging | `staging.DimPaymentMethod`  | `Sales_Analytics.dim.DimPaymentMethod`  | Stores historical payment method dimension data           |
| Dimension staging | `staging.DimShipMethod`     | `Sales_Analytics.dim.DimShipMethod`     | Stores historical ship method dimension data              |
| Dimension staging | `staging.DimDate`           | `Sales_Analytics.dim.DimDate`  or generated calendar | Stores historical date dimension data                     |

#### Staging Rules

| Rule                        | Description                                                             |
| --------------------------- | ----------------------------------------------------------------------- |
| Historical source alignment | Staging should preserve the analytical structure from `Sales_Analytics` |
| Temporary ownership         | Staging is not the final reporting layer                                |
| Reconciliation support      | Staging supports source-to-target comparison before Gold publication    |

### Gold Dimensions

Gold dimensions store final reporting-ready descriptive entities.

| Gold Dimension           | Main Inputs                                                                                          | Purpose                                                   |
| ------------------------ | ---------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| `gold.DimDate`           | `staging.DimDate`                                                                                    | Supports date-based reporting                             |
| `gold.DimCustomer`       | `staging.DimCustomer`, `silver.Customer`                                                             | Stores final customer reporting attributes                |
| `gold.DimProduct`        | `staging.DimProduct`, `silver.Product`, `silver.ProductCategory`                                     | Stores final product and category reporting attributes    |
| `gold.DimSalesPerson`    | `staging.DimSalesPerson`, `silver.SalesPerson`                                                       | Stores final salesperson reporting attributes             |
| `gold.DimSalesTerritory` | `staging.DimSalesTerritory`, `silver.SalesTerritory`, `silver.CountryRegion`, `silver.StateProvince` | Stores final territory and geography reporting attributes |
| `gold.DimPaymentMethod`  | `staging.DimPaymentMethod`, `silver.CreditCard`                                                      | Stores reporting-safe payment method attributes           |
| `gold.DimShipMethod`     | `staging.DimShipMethod`, `silver.ShipMethod`                                                         | Stores final shipping method reporting attributes         |

#### Dimension Rules

| Rule                 | Description                                                                 |
| -------------------- | --------------------------------------------------------------------------- |
| Historical alignment | Dimensions must support historical records loaded from `Sales_Analytics`    |
| Future alignment     | Dimensions must support new records derived from `Sales_Operational`        |
| Surrogate keys       | Gold dimensions should use analytical surrogate keys                        |
| Source traceability  | Dimensions should retain source identifiers where useful for reconciliation |
| Reporting readiness  | Dimensions should expose business-friendly attributes for reporting         |

### Gold Facts

Gold facts store final reporting-ready business events and measures.

| Gold Fact        | Main Inputs                                                               | Purpose                                               |
| ---------------- | ------------------------------------------------------------------------- | ----------------------------------------------------- |
| `gold.FactSales` | `staging.FactSales`, `silver.SalesOrderHeader`, `silver.SalesOrderDetail` | Stores final sales transaction measures for reporting |

#### Fact Rules

| Rule                 | Description                                                                                                               |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| Defined grain        | `gold.FactSales` is stored at sales order line grain                                                                      |
| Historical alignment | Historical fact records are initialized from `Sales_Analytics.fact.FactSales`                                             |
| Future processing    | New fact records are derived from `Sales_Operational` through Bronze and Silver                                           |
| Measure consistency  | Sales amounts, quantities, discounts, taxes, freight, and totals must remain consistent across historical and new periods |

## Semantic Model Scope

The semantic model provides the governed reporting layer for Power BI.

| Semantic Model | Source | Purpose |
|---|---|---|
| `sm_sales_analytics` | `wh_sales_analytics.gold` | Provides governed reporting consumption over Gold facts and dimensions |

### Semantic Model Rules

| Rule | Description |
|---|---|
| Reporting access | Reports should consume the semantic model instead of directly querying Bronze, Silver, Staging, or Gold objects |
| Business definitions | Measures, relationships, and business terms should be defined consistently for reporting |
| Gold dependency | The semantic model should depend on Gold objects as the trusted analytical layer |
| Consumer focus | Technical ingestion, staging, and transformation structures should be hidden from report users |

## Target Object Naming

| Object Type      | Convention                          | Example                   |
| ---------------- | ----------------------------------- | ------------------------- |
| Bronze table     | `bronze.[SourceEntityName]`         | `bronze.SalesOrderHeader` |
| Silver table     | `silver.[SourceEntityName]`         | `silver.SalesOrderHeader` |
| Staging table    | `staging.[AnalyticalObjectName]`    | `staging.FactSales`       |
| Gold dimension   | `gold.Dim[EntityName]`              | `gold.DimCustomer`        |
| Gold fact        | `gold.Fact[BusinessProcess]`        | `gold.FactSales`          |
| Surrogate key    | `[EntityName]Key`                   | `CustomerKey`             |
| Source key       | `Source[EntityName]ID` where useful | `SourceCustomerID`        |
| Technical column | `snake_case`                        | `execution_run_id`        |

## Technical Metadata Columns

Target tables should include technical metadata columns where required for traceability.

| Column                | Purpose                                                                                |
| --------------------- | -------------------------------------------------------------------------------------- |
| `execution_run_id`    | Identifies the execution run that loaded or transformed the record                     |
| `execution_step_id`   | Identifies the execution step responsible for the record                               |
| `source_database`     | Identifies whether the record originated from `Sales_Operational` or `Sales_Analytics` |
| `source_schema`       | Identifies the source schema                                                           |
| `source_object`       | Identifies the source object                                                           |
| `batch_period_yyyymm` | Identifies the business reporting period when applicable                               |
| `ingestion_datetime`  | Stores when the record was ingested into the target analytics platform                 |
| `load_datetime`       | Stores when the record was loaded into the target object                               |

## Modeling Assumptions

| Assumption                                      | Description                                                                                           |
| ----------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| Historical and new data must align              | Gold must combine historical records from `Sales_Analytics` with new records from `Sales_Operational` |
| Gold is the trusted analytical layer            | Reporting consumers should use Gold through the semantic model                                        |
| Bronze and Silver support operational ingestion | They are not reporting consumption layers                                                             |
| Staging supports historical baseline loading    | It is not a permanent reporting layer                                                                 |
| Source object inventory may evolve              | Target objects may be refined during implementation                                                   |
| Column-level mappings are not finalized         | Detailed mappings can be added later as metadata or mapping documents                                 |

## Conclusion

The target data model separates operational ingestion, historical staging, analytical modeling, and reporting consumption.

`lh_sales_operational` stores Bronze and Silver operational data objects from `Sales_Operational`. `wh_sales_analytics` stores Staging objects used for historical loads and Gold objects used for final reporting-ready facts and dimensions. `sm_sales_analytics` provides the governed reporting layer for Power BI.

The main modeling challenge is to align historical reporting data from `Sales_Analytics` with new reporting data derived from `Sales_Operational` under a consistent Gold analytical model.
