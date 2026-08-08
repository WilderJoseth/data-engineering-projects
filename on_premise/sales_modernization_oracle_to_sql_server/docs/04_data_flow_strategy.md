# Data Flow Strategy

## Document Goal

This document describes the source-to-target movement patterns, flow ownership, and how Sales-domain data is migrated into the operational and analytical target model.

## Data Flow Overview

The solution supports two main data flows.

| Flow | Source | Target | Purpose |
|---|---|---|---|
| Operational migration flow | `ADVENTUREWORKS2022` | `Sales_Operational` | Migrates Sales-domain data into the curated operational model |
| Analytical migration flow | `Sales_Operational` | `Sales_Analytics` | Builds reporting-ready facts and dimensions from curated operational data |

## Operational Migration Flow

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

## Data Flow Control Requirements

Each flow should be controlled and observable through `DataOps_Control`.

| Control Requirement | Purpose |
|---|---|
| Execution registration | Tracks when each flow starts, runs, completes, or fails |
| Step tracking | Tracks extraction, staging, transformation, validation, and publication steps |
| Source identification | Identifies whether data came from `ADVENTUREWORKS2022` or `Sales_Operational` |
| Batch identification | Tracks the applicable migration batch or reporting period |
| Validation status | Confirms whether data passed the required validation checks |
| Reconciliation status | Confirms whether source and target results match the expected values |
| Rerun support | Allows controlled reprocessing by flow, object, or batch |
