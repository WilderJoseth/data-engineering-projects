# Source Data Profile

## Document Goal

This document explains the source databases, their roles, source object categories, and how each source contributes to the Fabric migration.

## Source Platform Overview

The current Sales platform runs on an on-premise SQL Server 2022 instance.

The source platform contains two databases with different responsibilities:

| Source Database | Current Responsibility | Data Model | Modernization Role |
|---|---|---|---|
| `Sales_Operational` | Supports active on-premise Sales operations | Normalized model | Provides new transactional data for future reporting periods |
| `Sales_Analytics` | Provides trusted analytical reporting data | Star schema | Provides the historical reporting baseline before reporting cutover |

## Source Data Categories

The source data is grouped by business and analytical role.

| Data Category | Description | Main Source | Expected Data Volume | Estimated Row Count |
|---|---|---|---|---|
| Reference / Lookup | Stable or low-change descriptive values | `Sales_Operational` | Low | 100 - 10,000 rows |
| Master / Core | Business entities used across Sales processes | `Sales_Operational` | Medium | 10,000 - 1 million rows |
| Transactional | Sales orders, sales order lines, and related transaction records | `Sales_Operational` | High | 1 million - 20 million rows |
| Analytical Dimensions | Reporting-ready descriptive structures | `Sales_Analytics` | Medium | 10,000 - 2 million rows |
| Analytical Facts | Reporting-ready measurable business events | `Sales_Analytics` | Very high | 10 million - 100 million rows |

This classification helps identify which source objects are small and stable, which objects change over time, and which objects may require controlled batch processing during migration.

## Sales_Operational Source Tables

`Sales_Operational` provides normalized operational data and remains the operational source of truth.

The database includes internal processing schemas such as `staging`, `work`, and `prod`. For Fabric ingestion, only final curated tables from the `prod` schema are expected to be used as source tables.

| Schema | Data Role | Source Table | Expected Volume | Purpose |
|---|---|---|---|---|
| `prod` | Transactional | `SalesOrderHeader` | High | Stores sales order header records |
| `prod` | Transactional | `SalesOrderDetail` | High | Stores sales order line records |
| `prod` | Master / Core | `Customer` | Medium | Stores customer records |
| `prod` | Master / Core | `SalesPerson` | Medium | Stores salesperson records |
| `prod` | Master / Core | `Product` | Medium | Stores product records |
| `prod` | Master / Core | `Address` | Medium | Stores address records |
| `prod` | Master / Core | `CreditCard` | Medium | Stores payment-related source records |
| `prod` | Reference / Lookup | `AddressType` | Low | Stores address type values |
| `prod` | Reference / Lookup | `CountryRegion` | Low | Stores country or region values |
| `prod` | Reference / Lookup | `StateProvince` | Low | Stores state or province values |
| `prod` | Reference / Lookup | `SalesTerritory` | Low | Stores sales territory values |
| `prod` | Reference / Lookup | `Currency` | Low | Stores currency values |
| `prod` | Reference / Lookup | `CurrencyRate` | Medium | Stores currency exchange rate values |
| `prod` | Reference / Lookup | `ShipMethod` | Low | Stores shipping method values |
| `prod` | Reference / Lookup | `SpecialOffer` | Low | Stores promotion and discount values |
| `prod` | Reference / Lookup | `ProductCategory` | Low | Stores product category values |

## Sales_Analytics Source Tables

`Sales_Analytics` provides the existing trusted reporting model and is used as the historical reporting baseline.

The database includes internal processing schemas such as `staging`, `work`, `dim`, and `fact`. For Fabric ingestion, only final curated tables from the `dim` and `fact` schemas are expected to be used as source tables.

| Schema | Data Role | Source Table | Expected Volume | Purpose |
|---|---|---|---|---|
| `fact` | Fact | `FactSales` | Very high | Stores historical Sales transaction facts |
| `dim` | Dimension | `DimCustomer` | Medium | Stores historical reporting customer attributes |
| `dim` | Dimension | `DimProduct` | Medium | Stores historical reporting product attributes |
| `dim` | Dimension | `DimSalesPerson` | Medium | Stores historical reporting salesperson attributes |
| `dim` | Dimension | `DimSalesTerritory` | Low | Stores historical reporting geography and territory attributes |
| `dim` | Dimension | `DimPaymentMethod` | Low | Stores historical payment method attributes |
| `dim` | Dimension | `DimShipMethod` | Low | Stores historical shipping method attributes |
| `dim` | Dimension | `DimDate` | Low | Supports date-based reporting |

## Source Assumptions

| Assumption | Notes |
|---|---|
| `Sales_Operational` remains active | On-premise operations continue after the modernization starts |
| `Sales_Analytics` is trusted | Historical reporting data is treated as the baseline for the target analytical model |
| Source databases are read-only | The modernization process should not modify the on-premise source databases |
| Historical and new data need alignment | The target analytical model must align historical data from `Sales_Analytics` with new data from `Sales_Operational` |
| Source object inventory may evolve | Source table lists may be refined during implementation |
| Data volumes require controlled processing | Large historical and transactional objects may require batch-based processing |

## Source Profiling Checklist

The following items must be confirmed before implementation so load strategy, validation, reconciliation, and batching rules can be finalized.

| Profiling Item | Purpose |
|---|---|
| Row counts by table | Estimate load volume and processing effort |
| Historical date range | Define backfill scope |
| Business keys | Support deduplication, joins, and reconciliation |
| Primary keys | Support source integrity checks |
| Foreign keys | Support relationship validation |
| Date columns | Support reporting period logic and batch reloads |
| Change tracking columns | Support watermark incremental loads |
| Nullable columns | Identify data quality risks |
| Duplicate patterns | Identify cleansing and validation needs |
| Large table candidates | Identify tables that may require partitioned or batch processing |

## Conclusion

The current source environment provides a strong baseline for the Sales reporting modernization.

`Sales_Operational` remains the active operational source of truth and provides new transactional data for future reporting periods. `Sales_Analytics` provides the trusted historical reporting baseline through its existing fact and dimension tables.

The main source profiling challenge is to confirm row counts, historical ranges, business keys, date columns, change tracking columns, and large-table candidates before implementation.
