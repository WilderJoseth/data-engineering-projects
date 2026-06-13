# Data Flow Strategy

## Document Goal

This document explains source-to-target movement patterns, flow responsibilities, and how historical and new reporting data are processed into the target analytical model.

## Data Flow Overview

The solution supports three main data flows because the target analytics platform must combine historical reporting data with new reporting data derived from the operational source.

| Flow                      | Source                                    | Path                                                                                                            | Purpose                                               |
| ------------------------- | ----------------------------------------- | --------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| Historical reporting flow | `Sales_Analytics`                         | `Sales_Analytics` -> `wh_sales_analytics.staging` -> `wh_sales_analytics.gold`                                    | Load the trusted historical reporting baseline    |
| New reporting data flow   | `Sales_Operational`                       | `Sales_Operational` -> `lh_sales_operational.bronze` -> `lh_sales_operational.silver` -> `wh_sales_analytics.gold` | Build new reporting data from the operational source  |
| Coexistence support flow  | `Sales_Analytics` and `Sales_Operational` | Controlled by reporting-period ownership                                                                        | Support transition before target reporting cutover |

The high-level movement pattern is:

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
sm_sales_analytics


New reporting data
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
sm_sales_analytics
```

## Historical Reporting Flow

The historical reporting flow loads trusted historical reporting data from `Sales_Analytics` into the Fabric Warehouse staging area.

This flow uses the Warehouse path because `Sales_Analytics` already contains reporting-ready facts and dimensions.

| Item                | Description                                      |
| ------------------- | ------------------------------------------------ |
| Source database     | `Sales_Analytics`                                |
| Source schemas      | `fact`, `dim`                                    |
| Target staging area | `wh_sales_analytics.staging`                     |
| Final target        | `wh_sales_analytics.gold`                        |
| Purpose             | Initialize the Warehouse Gold model with historical reporting data |
| Duration            | Initial migration phase                          |

### Flow Pattern

```text
Sales_Analytics.fact / Sales_Analytics.dim
        |
        v
wh_sales_analytics.staging
        |
        v
wh_sales_analytics.gold
```

### Flow Responsibilities

| Responsibility                         | Description                                                                              |
| -------------------------------------- | ---------------------------------------------------------------------------------------- |
| Preserve historical reporting baseline | Load trusted analytical history already used by the business                             |
| Maintain analytical structure          | Keep historical fact and dimension meaning aligned with existing reporting               |
| Support reconciliation                 | Allow comparison between `Sales_Analytics` and target objects                            |
| Prepare for reporting cutover          | Ensure Warehouse Gold contains the required historical baseline before reporting ownership moves |

## New Reporting Data Flow

The new reporting data flow loads new transactional data from `Sales_Operational` and transforms it into reporting-ready structures in the target analytics platform.

This flow uses the Lakehouse path first because `Sales_Operational` is a normalized operational source. Data must be landed, curated, and prepared before becoming analytical reporting data.

| Item            | Description                                          |
| --------------- | ---------------------------------------------------- |
| Source database | `Sales_Operational`                                  |
| Source schema   | `prod`                                               |
| Raw target      | `lh_sales_operational.bronze`                        |
| Curated target  | `lh_sales_operational.silver`                        |
| Final target    | `wh_sales_analytics.gold`                            |
| Purpose         | Build new reporting data from the operational source |
| Duration        | Long-term target-state flow                          |

### Flow Pattern

```text
Sales_Operational.prod
        |
        v
lh_sales_operational.bronze
        |
        v
lh_sales_operational.silver
        |
        v
wh_sales_analytics.gold
```

### Flow Responsibilities

| Responsibility              | Description                                                                               |
| --------------------------- | ----------------------------------------------------------------------------------------- |
| Land source-aligned records | Bronze stores raw operational data from `Sales_Operational.prod`                          |
| Curate operational data     | Silver standardizes, validates, deduplicates, and prepares data for analytical processing |
| Build reporting structures  | Gold transforms curated operational data into reporting-ready facts and dimensions        |
| Preserve traceability       | Records should include technical metadata for execution and source tracking               |
| Support future reporting    | Gold becomes the trusted analytical layer for new reporting periods                       |

## Coexistence Support Flow

Coexistence support is required while the organization transitions from on-premise reporting to target reporting through the Power BI semantic model.

During this phase, `Sales_Analytics` may still be available as the existing reporting baseline, while the target analytics platform is being loaded, reconciled, tested, and prepared for reporting cutover.

| Coexistence Need      | Description                                                                                 |
| --------------------- | ------------------------------------------------------------------------------------------- |
| Historical comparison | Compare Warehouse Gold historical results against `Sales_Analytics`                         |
| Reporting validation  | Confirm Warehouse Gold and semantic model outputs match the accepted business baseline      |
| Temporary fallback    | Keep `Sales_Analytics` available until target reporting through the Power BI semantic model is accepted |
| Period control        | Avoid loading the same reporting period from both `Sales_Analytics` and `Sales_Operational` |

Coexistence should be temporary. After cutover, the Warehouse Gold model exposed through the Power BI semantic model should become the target reporting source of truth.

## Flow Ownership Rules

| Rule                                                     | Description                                                                 |
| -------------------------------------------------------- | --------------------------------------------------------------------------- |
| `Sales_Operational` remains the operational system of record | Fabric does not replace on-premise transactional processing              |
| `Sales_Analytics` provides historical reporting baseline | Historical data is loaded from the trusted analytical source                |
| `Sales_Operational` provides new operational data        | New reporting periods are derived from operational data through the target analytics platform |
| Semantic model owns reporting consumption                | Reports should consume the governed Power BI semantic model over Gold objects |
| One period, one owner source                             | A reporting period should be loaded from only one approved source           |
| Staging is not a reporting layer                         | Warehouse staging supports historical loading and reconciliation only       |
| Bronze and Silver are not reporting layers               | Lakehouse schemas support ingestion and curation before analytical modeling |

## Data Flow Control Requirements

Each flow should be controlled and observable through `DataOps_Control`.

| Control Requirement    | Purpose                                                                  |
| ---------------------- | ------------------------------------------------------------------------ |
| Execution registration | Track when each flow starts, runs, completes, or fails                   |
| Step tracking          | Track source extraction, staging, transformation, and publication steps  |
| Source identification  | Identify whether data came from `Sales_Operational` or `Sales_Analytics` |
| Batch identification   | Track reporting period or batch scope where applicable                   |
| Validation status      | Confirm whether data passed required quality checks                      |
| Reconciliation status  | Confirm whether source and target results match expected values          |
| Rerun support          | Allow controlled reprocessing by flow, object, or reporting period       |

## Data Flow Assumptions

| Assumption                                            | Description                                                                                               |
| ----------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| Source databases are read-only for the target analytics platform | The target analytics platform extracts data but does not update source databases             |
| `Sales_Analytics` is trusted for historical reporting | Historical data is treated as the baseline for target analytics platform initialization                   |
| `Sales_Operational` remains active                    | New data continues to be produced by the on-premise operational system                                    |
| Historical data is already reporting-shaped           | Historical data can use the Warehouse staging-to-Gold path                                                |
| New data requires operational curation                | New data follows the Lakehouse Bronze-to-Silver path before Gold                                          |
| Gold requires a reporting boundary                    | Historical and new reporting data must not overlap incorrectly                                            |
| Data flow details may evolve                          | Exact pipeline and notebook implementation may be refined later                                           |
| Load strategy is defined separately                   | Full reload, watermark incremental, and batch period reload rules are documented in `06_load_strategy.md` |

## Conclusion

The data flow strategy separates historical reporting flow, new reporting data flow, and coexistence support.

`Sales_Analytics` seeds the target analytics platform with trusted historical reporting data through Warehouse staging and Gold. `Sales_Operational` provides new operational data that is landed in Bronze, curated in Silver, and transformed into Gold. `wh_sales_analytics.gold` becomes the trusted analytical layer exposed for reporting through `sm_sales_analytics`.

The main data flow challenge is to align historical and new reporting data while maintaining traceability, controlled execution, reconciliation, and clear reporting-period ownership.
