# Source Data Profile

## Document Goal

This document describes the source databases, their roles, source object categories, estimated data volumes, growth assumptions, and how each source contributes to the target reporting platform.

## Source Platform Overview

The current Sales platform runs on an on-premise SQL Server 2022 instance, and it contains two business databases with different responsibilities:

| Source Database | Current Responsibility | Data Model | Modernization Role |
|---|---|---|---|
| `Sales_Operational` | Supports active on-premise Sales operations | Normalized model | Provides new transactional and master data for future reporting periods after cutover |
| `Sales_Analytics` | Provides trusted analytical reporting data | Star schema | Provides the historical reporting baseline before reporting cutover |

## Source Data Categories

The source data is grouped by business and analytical role.

| Data Category | Description | Source Database | Expected Data Volume | Estimated Row Count |
|---|---|---|---|---|
| Reference / Lookup | Stable or low-change descriptive values | `Sales_Operational` | Low | 10 to 302,500 rows |
| Master / Core | Business entities | `Sales_Operational` | Medium to high | 5,000 to 31,475,000 rows |
| Transactional | Sales orders and sales order lines | `Sales_Operational` | Very high | 252,500,000 to 1,262,500,000 rows |
| Analytical Dimensions | Reporting-ready descriptive structures | `Sales_Analytics` | Low to high | 20 to 25,250,000 rows |
| Analytical Facts | Reporting-ready measurable business events | `Sales_Analytics` | Very high | 1,262,500,000 rows |

## Source Volume Summary

| Source Database | Rows | Data Size | Index Size |
|---|---:|---:|---:|
| `Sales_Operational` | 1,590,939,000 | 209.03 – 322.25 GB | 85.96 – 208.01 GB |
| `Sales_Analytics` | 1,306,659,117 | 196.99 – 281.68 GB | 93.47 – 189.53 GB |
| **Total** | **2,897,598,117** | **406.02 – 603.94 GB** | **179.43 – 397.54 GB** |

## Sales_Operational Source Tables

For target ingestion, only final persisted business tables from the `prod` schema are included in the `Sales_Operational` source inventory.

| Data Category | Source Schema | Source Table | Estimated Monthly Growth | Estimated Current Rows | Estimated Current Data Size | Estimated Current Index Size |
|---|---|---|---:|---:|---:|---:|
| Transactional | `prod` | `SalesOrderDetail` | 7,500,000 rows/month | 1,262,500,000 | 138.88 – 195.69 GB | 50.50 – 113.62 GB |
| Transactional | `prod` | `SalesOrderHeader` | 1,500,000 rows/month | 252,500,000 | 56.81 – 94.69 GB | 28.40 – 75.75 GB |
| Master / Core | `prod` | `Customer` | 150,000 rows/month | 25,250,000 | 2.52 – 5.05 GB | 1.26 – 3.79 GB |
| Master / Core | `prod` | `Address` | 185,000 rows/month | 31,475,000 | 8.81 – 22.66 GB | 5.04 – 12.59 GB |
| Master / Core | `prod` | `CreditCard` | 110,000 rows/month | 18,850,000 | 1.89 – 3.77 GB | 0.76 – 2.26 GB |
| Master / Core | `prod` | `Product` | Static / very low | 50,000 | 0.05 – 0.15 GB | < 0.05 GB |
| Master / Core | `prod` | `SalesPerson` | Static / very low | 5,000 | < 0.01 GB | < 0.01 GB |
| Reference / Lookup | `prod` | `CurrencyRate` | 1,500 rows/month | 302,500 | 0.06 – 0.18 GB | < 0.01 GB |
| Reference / Lookup | `prod` | `SpecialOffer` | Static / very low | 5,000 | 0.01 – 0.03 GB | < 0.01 GB |
| Reference / Lookup | `prod` | `ProductCategory` | Static / very low | 500 | < 0.01 GB | < 0.01 GB |
| Reference / Lookup | `prod` | `StateProvince` | Static / very low | 500 | < 0.01 GB | < 0.01 GB |
| Reference / Lookup | `prod` | `CountryRegion` | Static / very low | 250 | < 0.01 GB | < 0.01 GB |
| Reference / Lookup | `prod` | `Currency` | Static / very low | 200 | < 0.01 GB | < 0.01 GB |
| Reference / Lookup | `prod` | `ShipMethod` | Static / very low | 20 | < 0.01 GB | < 0.01 GB |
| Reference / Lookup | `prod` | `SalesTerritory` | Static / very low | 20 | < 0.01 GB | < 0.01 GB |
| Reference / Lookup | `prod` | `AddressType` | Static / very low | 10 | < 0.01 GB | < 0.01 GB |

## Sales_Analytics Source Tables

For target ingestion, only final persisted reporting tables from the `dim` and `fact` schemas are included in the `Sales_Analytics` source inventory.

| Data Category | Source Schema | Source Table | Estimated Monthly Growth | Estimated Current Rows | Estimated Current Data Size | Estimated Current Index Size |
|---|---|---|---:|---:|---:|---:|
| Analytical Fact | `fact` | `FactSales` | 7,500,000 rows/month | 1,262,500,000 | 189.38 – 265.12 GB | 88.38 – 176.75 GB |
| Analytical Dimension | `dim` | `DimCustomer` | 150,000 rows/month | 25,250,000 | 5.05 – 10.10 GB | 3.79 – 8.84 GB |
| Analytical Dimension | `dim` | `DimPaymentMethod` | 110,000 rows/month | 18,850,000 | 2.51 – 6.28 GB | 1.26 – 3.77 GB |
| Analytical Dimension | `dim` | `DimProduct` | Static / very low | 50,000 | 0.05 – 0.15 GB | < 0.01 GB |
| Analytical Dimension | `dim` | `DimSalesPerson` | Static / very low | 5,000 | < 0.01 GB | < 0.01 GB |
| Analytical Dimension | `dim` | `DimDate` | Static / very low | 4,077 | < 0.01 GB | < 0.01 GB |
| Analytical Dimension | `dim` | `DimSalesTerritory` | Static / very low | 20 | < 0.01 GB | < 0.01 GB |
| Analytical Dimension | `dim` | `DimShipMethod` | Static / very low | 20 | < 0.01 GB | < 0.01 GB |
