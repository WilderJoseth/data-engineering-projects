# Data Flow Strategy

## Document Goal

This document describes the source-to-target movement patterns, flow ownership, and how Sales-domain data is migrated into the operational and analytical target model.

## Data Flow Overview

The solution supports two main data flows: migrating the Sales domain to `Sales_Operational` and building reporting data in `Sales_Analytics` from curated operational data.

| Flow | Source | Purpose |
|---|---|---|
| Operational migration flow | `ADVENTUREWORKS2022` | Migrates Sales-domain data into the curated operational model |
| Analytical migration flow | `Sales_Operational.prod` | Builds reporting-ready facts and dimensions from curated operational data |

## Operational Migration Flow

The operational migration flow loads Sales-domain data from the Oracle source into the normalized `Sales_Operational` database.

This flow uses `staging` for source-aligned extraction, `work` for validation and transformation, and `prod` for the final operational model.

| Item | Description |
|---|---|
| Source platform | Oracle XE 21c |
| Source schema | `ADVENTUREWORKS2022` |
| Target database | `Sales_Operational` |
| Target schema | `prod` |
| Purpose | Migrates and curates Sales-domain data into the target operational model |
| Execution scope | Offline migration phase |

### Flow Pattern

```text
ADVENTUREWORKS2022
        |
        v
Sales_Operational.staging
        |
        v
Sales_Operational.work
        |
        v
Sales_Operational.prod
```

## Analytical Migration Flow

The analytical migration flow builds reporting-ready data in `Sales_Analytics` from curated operational data in `Sales_Operational.prod`.

This flow uses `staging` for extraction, `work` for dimensional transformation, and `dim` and `fact` for the analytical target model.

| Item | Description |
|---|---|
| Source database | `Sales_Operational` |
| Source schema | `prod` |
| Target database | `Sales_Analytics` |
| Target schemas | `dim`, `fact` |
| Purpose | Builds reporting-ready facts and dimensions from curated operational data |
| Execution scope | Analytical migration phase |

```text
Sales_Operational.prod
        |
        v
Sales_Analytics.staging
        |
        v
Sales_Analytics.work
        |
        v
Sales_Analytics.fact / Sales_Analytics.dim
```

## Flow Ownership Rules

| Rule | Description |
|---|---|
| Oracle remains the migration source | `ADVENTUREWORKS2022` provides the source data for the operational migration flow |
| `Sales_Operational.prod` is the curated operational source | `Sales_Analytics` is populated from curated operational data, not directly from Oracle |
| `Sales_Operational` owns the operational model | Operational entities are validated, transformed, and published in `Sales_Operational.prod` |
| `Sales_Analytics` owns the reporting model | Reporting-ready facts and dimensions are published in the `dim` and `fact` schemas |
| `staging` is not a consumption layer | Staging schemas preserve source-aligned data for loading and transformation |
| `work` is not a final consumption layer | Work schemas support validation, consolidation, and target-shaped transformations |

## Data Flow Control Requirements

Each flow should be controlled and observable through `DataOps_Control`.

| Control Requirement | Purpose |
|---|---|
| Execution registration | Tracks when each flow starts, runs, completes, or fails |
| Step tracking | Tracks extraction, staging, transformation, validation, and publication steps |
| Source identification | Identifies whether data came from `ADVENTUREWORKS2022` or `Sales_Operational.prod` |
| Batch identification | Tracks the applicable migration batch or reporting period |
| Validation status | Confirms whether data passed the required validation checks |
| Reconciliation status | Confirms whether source and target results match the expected values |
| Rerun support | Allows controlled reprocessing by flow, object, or batch |
