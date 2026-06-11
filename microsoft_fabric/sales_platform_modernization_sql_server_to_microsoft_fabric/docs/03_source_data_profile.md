# Source Data Profile

## Document Goal

Document the source data used by the Sales Platform Modernization project.

This document explains the source databases, their roles, source object categories, and how each source contributes to the Fabric migration.

## Source Platform Overview

The current Sales platform runs on an on-premise SQL Server 2022 instance.

The source platform contains two databases with different responsibilities:

| Source Database | Current Responsibility | Data Model | Fabric Modernization Role |
|---|---|---|---|
| `Sales_Operational` | Supports active on-premise Sales operations | Normalized model | Long-term source for new data ingestion into Fabric |
| `Sales_Analytics` | Provides trusted analytical reporting data | Star schema | Historical baseline used to seed Fabric reporting objects |

## Source Data Categories

The source data is grouped by business and processing role.

| Data Category         | Description                                                      | Main Source         |
| --------------------- | ---------------------------------------------------------------- | ------------------- |
| Reference / Lookup    | Stable or low-change descriptive values                          | `Sales_Operational` |
| Master / Core         | Business entities used across Sales processes                    | `Sales_Operational` |
| Transactional         | Sales orders, sales order lines, and related transaction records | `Sales_Operational` |
| Analytical Dimensions | Reporting-ready descriptive structures                           | `Sales_Analytics`   |
| Analytical Facts      | Reporting-ready measurable business events                       | `Sales_Analytics`   |

This classification helps define how each source object should be ingested, validated, reconciled, and transformed in Fabric.

## Sales_Operational

`Sales_Operational` provides normalized operational data. It remains the operational source of truth and provides new transactional data for future reporting periods.

### Source Objects

The database contains internal processing schemas such as `staging`, `work`, and `prod`. For Fabric ingestion, the expected source objects are the final curated tables in the `prod` schema.

| Schema | Data Role | Source Object | Purpose |
|---|---|---|---|
| `prod` | Transactional | `SalesOrderHeader` | Stores sales order header records |
| `prod` | Transactional | `SalesOrderDetail` | Stores sales order line records |
| `prod` | Master / Core | `Customer` | Stores customer records |
| `prod` | Master / Core | `SalesPerson` | Stores salesperson records |
| `prod` | Master / Core | `Product` | Stores product records |
| `prod` | Master / Core | `Address` | Stores address records |
| `prod` | Master / Core | `CreditCard` | Stores payment-related source records |
| `prod` | Reference / Lookup | `AddressType` | Stores address type values |
| `prod` | Reference / Lookup | `CountryRegion` | Stores country or region values |
| `prod` | Reference / Lookup | `StateProvince` | Stores state or province values |
| `prod` | Reference / Lookup | `SalesTerritory` | Stores sales territory values |
| `prod` | Reference / Lookup | `Currency` | Stores currency values |
| `prod` | Reference / Lookup | `CurrencyRate` | Stores currency exchange rate values |
| `prod` | Reference / Lookup | `ShipMethod` | Stores shipping method values |
| `prod` | Reference / Lookup | `SpecialOffer` | Stores promotion and discount values |
| `prod` | Reference / Lookup | `ProductCategory` | Stores product category values |

### Usage in Fabric

| Usage                | Description                                                                       |
| -------------------- | --------------------------------------------------------------------------------- |
| New data ingestion   | Provides new transactional and master data to Fabric                              |
| Bronze source        | Source records are landed in the Lakehouse Bronze layer                           |
| Silver curation      | Bronze records are standardized, typed, deduplicated, and validated               |
| Gold transformation  | Curated operational data is transformed into reporting-ready facts and dimensions |
| Long-term processing | Becomes the long-term source for new Fabric reporting periods                     |

## Sales_Analytics

`Sales_Analytics` provides the existing reporting model. It is used as the historical baseline for Fabric.

### Source Objects

The database contains internal processing schemas such as `staging`, `work`, `dim` and `fact`. For Fabric ingestion, the expected source objects are the final curated tables in the `dim` and `fact` schemas.

| Schema   | Data Role | Source Object       | Purpose                                                        |
| -------- | --------- | ------------------- | -------------------------------------------------------------- |
| `fact`   | Fact      | `FactSales`         | Stores historical Sales transaction facts                      |
| `dim`    | Dimension | `DimCustomer`       | Stores historical reporting customer attributes                |
| `dim`    | Dimension | `DimProduct`        | Stores historical reporting product attributes                 |
| `dim`    | Dimension | `DimSalesPerson`    | Stores historical reporting salesperson attributes             |
| `dim`    | Dimension | `DimSalesTerritory` | Stores historical reporting geography and territory attributes |
| `dim`    | Dimension | `DimPaymentMethod`  | Stores historical payment method attributes                    |
| `dim`    | Dimension | `DimShipMethod`     | Stores historical shipping method attributes                   |
| `dim`    | Dimension | `DimDate`           | Supports date-based reporting                                  |

### Usage in Fabric

| Usage                    | Description                                                                       |
| ------------------------ | --------------------------------------------------------------------------------- |
| Historical baseline      | Provides existing historical reporting data to seed Fabric                        |
| Warehouse staging source | Historical analytical objects are loaded into Fabric Warehouse staging            |
| Gold initialization      | Historical data is published into Fabric Gold after validation and reconciliation |
| Reconciliation baseline  | Used to compare historical source data against Fabric target data                 |
| Temporary fallback       | May be used during transition if reporting cutover is not complete                |

## Historical Data Context

`Sales_Analytics` already contains historical reporting data in a star schema.

This historical data is valuable because it represents the trusted reporting baseline used by the business before Fabric modernization.

| Historical Consideration | Description                                                                                   |
| ------------------------ | --------------------------------------------------------------------------------------------- |
| Historical source        | `Sales_Analytics`                                                                             |
| Historical model         | Star schema                                                                                   |
| Historical facts         | `FactSales`                                                                                   |
| Historical dimensions    | Customer, Product, Salesperson, Territory, Payment Method, Ship Method, Date                  |
| Target use               | Seed Fabric with trusted reporting history                                                    |
| Key risk                 | Avoid reloading the same reporting period from both `Sales_Analytics` and `Sales_Operational` |

A reporting boundary period must be defined so Fabric can clearly separate historical reporting data from new reporting data.

## Source Assumptions

| Assumption                                 | Notes                                                                                                |
| ------------------------------------------ | ---------------------------------------------------------------------------------------------------- |
| `Sales_Operational` remains active         | On-premise operations continue after Fabric implementation starts                                    |
| `Sales_Analytics` is trusted               | Historical reporting data is treated as the baseline for Fabric                                      |
| Source databases are read-only for Fabric  | Fabric should not modify the on-premise source databases                                             |
| Historical and new data need alignment     | Fabric Gold must align historical data from `Sales_Analytics` with new data from `Sales_Operational` |
| Source object inventory may evolve         | Table lists may be refined during implementation                                                     |
| Data volumes require controlled processing | Large historical and transactional objects may require batch-based processing                        |

## Source Profiling Checklist

The following details should be collected during detailed source analysis or implementation.

| Profiling Item          | Purpose                                                          |
| ----------------------- | ---------------------------------------------------------------- |
| Row counts by table     | Estimate load volume and processing effort                       |
| Historical date range   | Define backfill scope                                            |
| Business keys           | Support deduplication, joins, and reconciliation                 |
| Primary keys            | Support source integrity checks                                  |
| Foreign keys            | Support relationship validation                                  |
| Date columns            | Support reporting period logic and batch reloads                 |
| Change tracking columns | Support watermark incremental loads                              |
| Nullable columns        | Identify data quality risks                                      |
| Duplicate patterns      | Identify cleansing and validation needs                          |
| Large table candidates  | Identify tables that may require partitioned or batch processing |

## Conclusion

The current source environment provides a strong baseline for Fabric modernization.

`Sales_Operational` remains the operational source of truth and provides new transactional data to Fabric. `Sales_Analytics` provides the trusted historical reporting baseline used to initialize the Fabric analytical model.

The main source design challenge is to align historical reporting data from `Sales_Analytics` with new reporting data derived from `Sales_Operational`, while maintaining traceability, validation, reconciliation, and clear reporting-period ownership.
