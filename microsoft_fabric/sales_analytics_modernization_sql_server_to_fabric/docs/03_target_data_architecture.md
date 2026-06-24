# Target Data Architecture

## Document Goal

This document describes the Lakehouse, Warehouse, and Power BI Semantic Model objects that support the target reporting platform.

## Target Data Architecture Overview

The target data architecture is organized by data area and modeling responsibility.

| Architecture Area | Target Component | Target Component Name | Main Responsibility |
|---|---|---|---|
| Bronze | Lakehouse | `lh_sales_operational` | Stores raw source-aligned operational data |
| Silver | Lakehouse | `lh_sales_operational` | Stores curated and standardized operational data |
| Staging | Warehouse | `wh_sales_analytics` | Temporarily stores historical analytical data before Gold publication |
| Gold | Warehouse | `wh_sales_analytics` | Stores final reporting-ready facts and dimensions |
| Semantic Model | Power BI Semantic Model | `sm_sales_analytics` | Provides the governed reporting consumption layer |

## Lakehouse

The Lakehouse is organized into the `bronze` and `silver` schemas.

| Schema | Purpose |
|---|---|
| `bronze` | Stores raw source-aligned operational data from `Sales_Operational` |
| `silver` | Standardizes, curates, and validates operational data before analytical transformation |

### Bronze Tables

Bronze tables store raw source-aligned records from `Sales_Operational`.

| Data Category      | Source Schema | Source Table       | Target Schema | Target Table       | Purpose                                   |
| ------------------ | ------------- | ------------------ | ------------- | ------------------ | ----------------------------------------- |
| Transactional      | `prod`        | `SalesOrderHeader` | `bronze`      | `SalesOrderHeader` | Stores raw sales order header records     |
| Transactional      | `prod`        | `SalesOrderDetail` | `bronze`      | `SalesOrderDetail` | Stores raw sales order line records       |
| Master / Core      | `prod`        | `Customer`         | `bronze`      | `Customer`         | Stores raw customer records               |
| Master / Core      | `prod`        | `SalesPerson`      | `bronze`      | `SalesPerson`      | Stores raw salesperson records            |
| Master / Core      | `prod`        | `Product`          | `bronze`      | `Product`          | Stores raw product records                |
| Master / Core      | `prod`        | `Address`          | `bronze`      | `Address`          | Stores raw address records                |
| Master / Core      | `prod`        | `CreditCard`       | `bronze`      | `CreditCard`       | Stores raw payment-related source records |
| Reference / Lookup | `prod`        | `AddressType`      | `bronze`      | `AddressType`      | Stores raw address type values            |
| Reference / Lookup | `prod`        | `CountryRegion`    | `bronze`      | `CountryRegion`    | Stores raw country or region values       |
| Reference / Lookup | `prod`        | `StateProvince`    | `bronze`      | `StateProvince`    | Stores raw state or province values       |
| Reference / Lookup | `prod`        | `SalesTerritory`   | `bronze`      | `SalesTerritory`   | Stores raw sales territory values         |
| Reference / Lookup | `prod`        | `Currency`         | `bronze`      | `Currency`         | Stores raw currency values                |
| Reference / Lookup | `prod`        | `CurrencyRate`     | `bronze`      | `CurrencyRate`     | Stores raw currency exchange rate values  |
| Reference / Lookup | `prod`        | `ShipMethod`       | `bronze`      | `ShipMethod`       | Stores raw shipping method values         |
| Reference / Lookup | `prod`        | `SpecialOffer`     | `bronze`      | `SpecialOffer`     | Stores raw promotion and discount values  |
| Reference / Lookup | `prod`        | `ProductCategory`  | `bronze`      | `ProductCategory`  | Stores raw product category values        |

#### Bronze Rules

| Rule                   | Description                                                                               |
| ---------------------- | ----------------------------------------------------------------------------------------- |
| Source alignment       | Bronze tables should preserve the structure of the operational source as much as possible |
| No business remodeling | Bronze should not implement dimensional modeling                                          |
| Traceability           | Bronze tables should include technical metadata for ingestion tracking                    |
| Consumption boundary   | Bronze is used by Silver processes, not by reporting consumers                            |

### Silver Tables

Silver tables store curated operational data from Bronze.

| Data Category      | Source Schema | Source Table       | Target Schema | Target Table       | Purpose                                                 |
| ------------------ | ------------- | ------------------ | ------------- | ------------------ | ------------------------------------------------------- |
| Transactional      | `bronze`      | `SalesOrderHeader` | `silver`      | `SalesOrderHeader` | Stores curated sales order header records               |
| Transactional      | `bronze`      | `SalesOrderDetail` | `silver`      | `SalesOrderDetail` | Stores curated sales order line records                 |
| Master / Core      | `bronze`      | `Customer`         | `silver`      | `Customer`         | Stores curated customer records                         |
| Master / Core      | `bronze`      | `SalesPerson`      | `silver`      | `SalesPerson`      | Stores curated salesperson records                      |
| Master / Core      | `bronze`      | `Product`          | `silver`      | `Product`          | Stores curated product records                          |
| Master / Core      | `bronze`      | `Address`          | `silver`      | `Address`          | Stores curated address records                          |
| Master / Core      | `bronze`      | `CreditCard`       | `silver`      | `CreditCard`       | Stores curated reporting-safe payment source attributes |
| Reference / Lookup | `bronze`      | `AddressType`      | `silver`      | `AddressType`      | Stores curated address type values                      |
| Reference / Lookup | `bronze`      | `CountryRegion`    | `silver`      | `CountryRegion`    | Stores curated country or region values                 |
| Reference / Lookup | `bronze`      | `StateProvince`    | `silver`      | `StateProvince`    | Stores curated state or province values                 |
| Reference / Lookup | `bronze`      | `SalesTerritory`   | `silver`      | `SalesTerritory`   | Stores curated sales territory values                   |
| Reference / Lookup | `bronze`      | `Currency`         | `silver`      | `Currency`         | Stores curated currency values                          |
| Reference / Lookup | `bronze`      | `CurrencyRate`     | `silver`      | `CurrencyRate`     | Stores curated currency exchange rate values            |
| Reference / Lookup | `bronze`      | `ShipMethod`       | `silver`      | `ShipMethod`       | Stores curated shipping method values                   |
| Reference / Lookup | `bronze`      | `SpecialOffer`     | `silver`      | `SpecialOffer`     | Stores curated promotion and discount values            |
| Reference / Lookup | `bronze`      | `ProductCategory`  | `silver`      | `ProductCategory`  | Stores curated product category values                  |

#### Silver Rules

| Rule                   | Description                                                        |
| ---------------------- | ------------------------------------------------------------------ |
| Standardization        | Silver applies consistent data types, naming, and formatting       |
| Data quality           | Silver removes or flags invalid, duplicated, or incomplete records |
| Business readiness     | Silver prepares operational data for analytical transformation     |
| No reporting ownership | Silver is not the final reporting layer                            |

## Warehouse

The Warehouse is organized into the `staging` and `gold` schemas.

| Schema | Purpose |
|---|---|
| `staging` | Temporarily stores historical reporting data from `Sales_Analytics` before publishing to Gold |
| `gold` | Stores final reporting-ready dimensional and fact objects |

### Staging Tables

Staging tables temporarily store historical analytical data from `Sales_Analytics`.

| Data Category        | Source Schema | Source Table        | Target Schema | Target Table        | Purpose                                                     |
| -------------------- | ------------- | ------------------- | ------------- | ------------------- | ----------------------------------------------------------- |
| Analytical Fact      | `fact`        | `FactSales`         | `staging`     | `FactSales`         | Stores historical sales fact data before Gold publication   |
| Analytical Dimension | `dim`         | `DimCustomer`       | `staging`     | `DimCustomer`       | Stores historical customer dimension attributes             |
| Analytical Dimension | `dim`         | `DimProduct`        | `staging`     | `DimProduct`        | Stores historical product and category dimension attributes |
| Analytical Dimension | `dim`         | `DimSalesPerson`    | `staging`     | `DimSalesPerson`    | Stores historical salesperson dimension attributes          |
| Analytical Dimension | `dim`         | `DimSalesTerritory` | `staging`     | `DimSalesTerritory` | Stores historical territory dimension attributes            |
| Analytical Dimension | `dim`         | `DimPaymentMethod`  | `staging`     | `DimPaymentMethod`  | Stores historical payment method dimension attributes       |
| Analytical Dimension | `dim`         | `DimShipMethod`     | `staging`     | `DimShipMethod`     | Stores historical ship method dimension attributes          |
| Analytical Dimension | `dim`         | `DimDate`           | `staging`     | `DimDate`           | Stores historical date dimension attributes                 |

#### Staging Rules

| Rule                        | Description                                                             |
| --------------------------- | ----------------------------------------------------------------------- |
| Historical source alignment | Staging should preserve the analytical structure from `Sales_Analytics` |
| Temporary ownership         | Staging is not the final reporting layer                                |
| Reconciliation support      | Staging supports source-to-target comparison before Gold publication    |

### Gold Tables

Gold tables store final reporting-ready data.

| Data Category        | Source Inputs                                                                                        | Target Schema | Target Table        | Purpose                                                |
| -------------------- | ---------------------------------------------------------------------------------------------------- | ------------- | ------------------- | ------------------------------------------------------ |
| Analytical Fact      | `staging.FactSales`, `silver.SalesOrderHeader`, `silver.SalesOrderDetail`                            | `gold`        | `FactSales`         | Stores final sales transaction measures for reporting  |
| Analytical Dimension | `staging.DimCustomer`, `silver.Customer`                                                             | `gold`        | `DimCustomer`       | Stores final customer dimension attributes             |
| Analytical Dimension | `staging.DimProduct`, `silver.Product`, `silver.ProductCategory`                                     | `gold`        | `DimProduct`        | Stores final product and category dimension attributes |
| Analytical Dimension | `staging.DimSalesPerson`, `silver.SalesPerson`                                                       | `gold`        | `DimSalesPerson`    | Stores final salesperson dimension attributes          |
| Analytical Dimension | `staging.DimSalesTerritory`, `silver.SalesTerritory`, `silver.CountryRegion`, `silver.StateProvince` | `gold`        | `DimSalesTerritory` | Stores final territory dimension attributes            |
| Analytical Dimension | `staging.DimPaymentMethod`, `silver.CreditCard`                                                      | `gold`        | `DimPaymentMethod`  | Stores final payment method dimension attributes       |
| Analytical Dimension | `staging.DimShipMethod`, `silver.ShipMethod`                                                         | `gold`        | `DimShipMethod`     | Stores final ship method dimension attributes          |
| Analytical Dimension | `staging.DimDate` or generated calendar                                                              | `gold`        | `DimDate`           | Supports date-based reporting and analysis             |

#### Gold Dimension Rules

| Rule | Description |
|---|---|
| Historical alignment | Gold dimensions must support historical dimension records loaded from `Sales_Analytics` |
| Future alignment | Gold dimensions must support new dimension records derived from `Sales_Operational` |
| Surrogate keys | Gold dimensions should use analytical surrogate keys for stable fact relationships |
| Source traceability | Gold dimensions should retain source identifiers where useful for reconciliation and troubleshooting |
| Reporting readiness | Gold dimensions should expose business-friendly attributes for reporting |

#### Gold Fact Rules

| Rule | Description |
|---|---|
| Historical alignment | Gold facts must support historical fact records loaded from `Sales_Analytics` |
| Future alignment | Gold facts must support new fact records derived from `Sales_Operational` |
| Period ownership | The same reporting period must not be loaded from both historical and new sources |
| Measure consistency | Gold fact amounts, quantities, discounts, taxes, freight, and totals must remain consistent across historical and new periods |
| Reporting grain | Each `gold.FactSales` row represents one sales order line item |

## Power BI Semantic Model

The Power BI Semantic Model provides the governed reporting consumption layer over Gold objects.

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
| `execution_step_id` | Identifies the execution step responsible for loading or updating the record |
| `loaded_at` | Identifies when the record was inserted into the target table |
| `loaded_by` | Identifies the user or process that inserted the record into the target table |
| `updated_at` | Identifies when the record was last updated in the target table |
| `updated_by` | Identifies the user or process that last updated the record in the target table |
