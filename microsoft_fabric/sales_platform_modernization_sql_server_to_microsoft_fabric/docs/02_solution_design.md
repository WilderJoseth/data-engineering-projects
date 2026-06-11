# Solution Design

## Document Goal

Define the target technical architecture for the Sales Platform Modernization project.

This document explains the main platform components, architectural responsibilities, and design decisions required to build Microsoft Fabric as the new unified reporting source of truth.

## High-Level Architecture

```text
Historical reporting data
Sales_Analytics
      |
      v
Fabric Warehouse Staging
      |
      v
Fabric Gold Model
      |
      v
Power BI Semantic Model


New transactional data
Sales_Operational
      |
      v
Fabric Lakehouse Bronze
      |
      v
Fabric Lakehouse Silver
      |
      v
Fabric Gold Model
      |
      v
Power BI Semantic Model
```

## Source Platform Components

The current on-premise platform contains two SQL Server 2022 databases.

| Source Component    | Purpose                                                                         |
| ------------------- | ------------------------------------------------------------------------------- |
| `Sales_Operational` | Long-term source for new transactional data used to build future reporting data |
| `Sales_Analytics`   | Historical reporting baseline used to seed Fabric before reporting cutover      |

## Target Platform Components

| Target Component        | Proposed Name                               | Purpose                                                                      |
| ----------------------- | ------------------------------------------- | ---------------------------------------------------------------------------- |
| Fabric Workspace        | `ws_sales_analytics_modernization_dev`      | Development workspace for the Sales modernization assets                     |
| Fabric Lakehouse        | `lh_sales_operational`                      | Stores Bronze and Silver Delta tables for operational ingestion and curation |
| Fabric Warehouse        | `wh_sales_analytics`                        | Stores staging and Gold analytical reporting objects                         |
| Power BI Semantic Model | `sm_sales_analytics`                        | Provides the reporting consumption layer                                     |
| Azure SQL Database      | `DataOps_Control`                           | Shared control framework for execution tracking and observability            |

## Fabric Layer Responsibilities

| Layer          | Location  | Responsibility                                                     |
| -------------- | --------- | ------------------------------------------------------------------ |
| Bronze         | Lakehouse | Store raw source-aligned data from `Sales_Operational`             |
| Silver         | Lakehouse | Store curated and standardized operational data                    |
| Staging        | Warehouse | Temporarily store historical reporting data from `Sales_Analytics` |
| Gold           | Warehouse | Store final reporting-ready dimensional and fact objects           |
| Semantic Model | Power BI  | Provide business-facing reporting layer                            |

## Data Ownership Model

| Data Period                  | Source                  | Target Ownership                                                   |
| ---------------------------- | ----------------------- | ------------------------------------------------------------------ |
| Historical reporting periods | `Sales_Analytics`       | Loaded into Fabric as the historical reporting baseline            |
| New reporting periods        | `Sales_Operational`     | Processed in Fabric from operational data                          |
| Post-cutover reporting       | `wh_sales_analytics`    | Fabric Warehouse becomes the unified reporting source of truth     |

## Control and Observability

The solution uses `DataOps_Control` as a shared execution control framework.

| Responsibility          | Purpose                                                                 |
| ----------------------- | ----------------------------------------------------------------------- |
| Metadata management     | Define projects, source objects, target objects, processes, and batches |
| Execution tracking      | Track pipeline, notebook, and data processing runs                      |
| Validation tracking     | Store validation results by execution step                              |
| Reconciliation tracking | Store source-to-target comparison results                               |
| Error logging           | Capture technical failures and troubleshooting details                  |
| Rerun support           | Support recovery by process, table, or batch period                     |

`DataOps_Control` is not a Sales-only database. It is a reusable control framework that can support multiple projects.

## Main Design Decisions

| Decision | Rationale |
|---|---|
| Keep `Sales_Operational` on-premise | Operational processes continue to run locally |
| Use `Sales_Analytics` for historical baseline | Historical reporting data already exists and is trusted |
| Use `wh_sales_analytics` as the analytical source of truth | Reporting ownership moves to a cloud analytical platform |
| Use Lakehouse for Bronze and Silver | Operational data needs raw and curated Delta-based storage |
| Use Warehouse for Staging and Gold | Historical and final reporting objects require relational analytical structures |
| Use Power BI semantic model for consumption | Reports should consume governed business-facing objects |
| Use `DataOps_Control` for execution control | Migration and synchronization require traceability, validation, reconciliation, and rerun support |
| Define a reporting boundary period | Prevent the same reporting period from being loaded from both historical and new sources |

## Naming Conventions

| Object Type       | Convention                            | Example                                 |
| ----------------- | ------------------------------------- | --------------------------------------- |
| Workspace         | `ws_[domain]_[purpose]_[environment]` | `ws_sales_analytics_modernization_dev`  |
| Lakehouse         | `lh_[domain]_[purpose]`               | `lh_sales_operational`                  |
| Warehouse         | `wh_[domain]_[purpose]`               | `wh_sales_analytics`                    |
| Semantic model    | `sm_[domain]_[purpose]`               | `sm_sales_analytics`                    |

## Architecture Rules

* Power BI should consume the semantic model, not Bronze, Silver, or staging tables directly.
* Bronze should preserve source-aligned operational data.
* Silver should apply standardization, typing, deduplication, and business validation.
* Warehouse staging should support historical loads from `Sales_Analytics`.
* Gold should contain the final reporting-ready model.
* Historical and new reporting data must be aligned under one consistent analytical model.
* Validation and reconciliation must be completed before data is treated as trusted.
* The solution must prevent duplicate ownership of the same reporting period.

## Related Documents

| Document                                   | Purpose                                                                             |
| ------------------------------------------ | ----------------------------------------------------------------------------------- |
| `01_current_state_assessment.md`           | Explains current environment, modernization drivers, risks, and design implications |
| `03_source_data_profile.md`                | Documents source databases, source tables, data roles, and historical context       |
| `04_target_data_model.md`                  | Defines target objects, tables, grains, and modeling decisions                      |
| `05_data_flow_strategy.md`                 | Explains historical, coexistence, and operational data flows                        |
| `06_load_strategy.md`                      | Defines full reload, watermark incremental, and batch period reload rules           |
| `07_validation_reconciliation_strategy.md` | Defines validation and reconciliation approach                                      |
| `08_cutover_strategy.md`                   | Defines reporting ownership transition and cutover rules                            |
| `09_implementation_plan.md`                | Defines implementation phases                                                       |
| `10_operational_runbook.md`                | Defines operational execution, monitoring, troubleshooting, and rerun procedures    |
