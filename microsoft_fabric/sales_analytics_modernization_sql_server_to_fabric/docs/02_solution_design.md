# Solution Design

## Document Goal

This document explains the main platform components, architectural responsibilities, and design decisions required to build the Warehouse Gold model exposed through the Power BI semantic model as the target reporting source of truth.

## High-Level Architecture

```text
Historical reporting data
Sales_Analytics
      |
      v
wh_sales_analytics.staging
      |
      v
wh_sales_analytics.gold
      |
      v
Power BI Semantic Model


New transactional data
Sales_Operational
      |
      v
lh_sales_operational.bronze
      |
      v
lh_sales_operational.silver
      |
      v
wh_sales_analytics.gold
      |
      v
Power BI Semantic Model
```

## Source Platform Components

The current on-premise platform contains two SQL Server 2022 databases.

| Source Component | Purpose |
|---|---|
| `Sales_Operational` | Provides new transactional data to build future reporting data in the target analytics platform |
| `Sales_Analytics` | Provides the historical reporting baseline for the target analytics platform before reporting cutover |

## Target Analytics Platform Components

| Target Component | Proposed Name | Purpose |
|---|---|---|
| Fabric Lakehouse | `lh_sales_operational` | Provides storage and processing for Bronze and Silver operational data areas |
| Fabric Warehouse | `wh_sales_analytics` | Provides storage and processing for Staging and Gold analytical data areas |
| Power BI Semantic Model | `sm_sales_analytics` | Provides the governed reporting consumption layer over Gold data |
| Azure SQL Database | `DataOps_Control` | Provides shared execution control and observability for the data flows |

## Target Data Area Responsibilities

| Data Area | Location | Responsibility |
|---|---|---|
| Bronze | Lakehouse | Stores raw source-aligned data from `Sales_Operational` |
| Silver | Lakehouse | Stores curated and standardized data from Bronze objects |
| Staging | Warehouse | Temporarily stores historical reporting data from `Sales_Analytics` |
| Gold | Warehouse | Stores final reporting-ready dimensional and fact objects |
| Semantic Model | Power BI | Provides the governed reporting consumption layer |

## Reporting Data Ownership

This section defines which component is authoritative for each reporting data responsibility.

| Ownership Area | Owner | Responsibility |
|---|---|---|
| Operational transactions | `Sales_Operational` | Remains the operational system of record for active Sales transactions |
| Historical reporting baseline | `Sales_Analytics` | Provides trusted historical reporting data before reporting cutover |
| Target analytical model | `wh_sales_analytics` | Stores the final analytical objects built from historical and new reporting data |
| Reporting consumption | `sm_sales_analytics` | Provides the governed reporting layer for Power BI consumers |

## Control and Observability

The solution uses `DataOps_Control` as a shared control framework for execution tracking and observability.

| Control Area | Purpose |
|---|---|
| Metadata management | Defines source objects, target objects, processes, and batches |
| Execution tracking | Tracks pipeline, notebook, and data processing executions |
| Validation and reconciliation | Stores control results used to confirm data quality and source-to-target consistency |
| Error logging | Captures technical failures for troubleshooting |
| Rerun support | Supports controlled recovery by process, object, or batch period |

`DataOps_Control` is reusable and is not treated as a Sales-only database.

## Main Design Decisions

| Decision | Rationale |
|---|---|
| Keep `Sales_Operational` on-premise | Operational processes continue to run locally |
| Use `Sales_Analytics` as the historical baseline | Historical reporting data already exists and is trusted |
| Use `wh_sales_analytics` as the target analytical model | Final reporting-ready data is stored in the Fabric Warehouse |
| Use Lakehouse for Bronze and Silver | Operational data requires source-aligned landing and curated preparation before analytical modeling |
| Use Warehouse for Staging and Gold | Historical and final reporting objects require relational analytical structures |
| Use Power BI Semantic Model for consumption | Reports should consume governed business-facing objects |
| Use `DataOps_Control` for execution control | Controlled migration requires execution tracking, validation, reconciliation, and rerun support |
| Define a reporting boundary period | Prevent the same reporting period from being loaded from both historical and new sources |

## Naming Conventions

| Object Type       | Convention                            | Example                                 |
| ----------------- | ------------------------------------- | --------------------------------------- |
| Lakehouse         | `lh_[domain]_[purpose]`               | `lh_sales_operational`                  |
| Warehouse         | `wh_[domain]_[purpose]`               | `wh_sales_analytics`                    |
| Semantic model    | `sm_[domain]_[purpose]`               | `sm_sales_analytics`                    |

## Architecture Rules

- Power BI reports must consume the governed semantic model, not Bronze, Silver, or Staging objects directly.
- Bronze objects should preserve source-aligned operational data from `Sales_Operational`.
- Silver objects should standardize, validate, and prepare operational data for analytical modeling.
- Gold objects should contain the final reporting-ready dimensional and fact model.
- Historical data from `Sales_Analytics` and new data from `Sales_Operational` must align under one consistent analytical model.
- Data should not be treated as trusted until validation and reconciliation are completed or accepted.
- The same reporting period must not be loaded into Gold from more than one approved source.
