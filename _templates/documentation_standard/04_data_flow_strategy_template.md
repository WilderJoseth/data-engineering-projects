# Data Flow Strategy

## Document Goal

This document describes source-to-target movement patterns, flow responsibilities, and how historical and new reporting data are processed into the target reporting platform.

## Data Flow Overview

The solution supports <Number> main data flows because the target reporting platform must combine <Historical Data Scope> with <New Data Scope>.

| Flow | Source | Purpose |
|---|---|---|
| <Data Flow Name> | <Source System> | <Purpose> |
| <Data Flow Name> | <Source System> | <Purpose> |
| <Data Flow Name> | <Source System> | <Purpose> |

## <Data Flow Name>

The <Data Flow Name> loads <Data Scope> from <Source System> into the target reporting platform.

This flow uses the <Target Component> path because <Reason>.

| Item | Description |
|---|---|
| Source system | <Source System> |
| Source schemas | <Schema Name> |
| Target staging area | <Target Component>.<Schema Name> |
| Final target | <Target Component>.<Schema Name> |
| Purpose | <Purpose> |
| Duration | <Initial migration/Long-term target state/Temporary coexistence> |

### Flow Pattern

```text
<Source System>.<Schema Name>
        |
        v
<Target Component>.<Schema Name>
        |
        v
<Target Component>.<Schema Name>
```

### Flow Responsibilities

| Responsibility | Description |
|---|---|
| <Responsibility> | <Description> |
| <Responsibility> | <Description> |
| Support reconciliation | Allow comparison between source and target objects |
| Prepare for reporting cutover | Ensure the target reporting platform contains the required baseline before reporting ownership is transferred |

## <Data Flow Name>

The <Data Flow Name> loads <Data Scope> from <Source System> and transforms it into reporting-ready structures in the target reporting platform.

| Item | Description |
|---|---|
| Source system | <Source System> |
| Source schema | <Schema Name> |
| Raw target | <Target Component>.<Schema Name> |
| Curated target | <Target Component>.<Schema Name> |
| Final target | <Target Component>.<Schema Name> |
| Purpose | <Purpose> |
| Duration | <Long-term target-state flow> |

### Flow Pattern

```text
<Source System>.<Schema Name>
        |
        v
<Target Component>.<Schema Name>
        |
        v
<Target Component>.<Schema Name>
        |
        v
<Target Component>.<Schema Name>
```

### Flow Responsibilities

| Responsibility | Description |
|---|---|
| Land source-aligned records | <Description> |
| Curate source data | <Description> |
| Build reporting structures | <Description> |
| Preserve traceability | Records should include technical metadata for execution and source tracking |
| Support future reporting | <Reporting Layer> becomes the trusted reporting data layer for new reporting periods |

## Coexistence Support Flow

Coexistence support is required while the organization transitions from the current reporting platform to the target reporting platform.

| Coexistence Need | Description |
|---|---|
| Historical comparison | Compare target historical results against <Source System> |
| Reporting validation | Confirm target results match the accepted business baseline |
| Temporary fallback | Keep <Source System> available until target reporting is accepted |
| Period control | Avoid loading the same reporting period from more than one approved source |

Coexistence should be temporary. After cutover, the target reporting platform should become the reporting source of truth.

## Flow Ownership Rules

| Rule | Description |
|---|---|
| <Source System> remains the operational system of record | The modernization scope does not replace operational processing |
| <Source System> provides historical reporting baseline | Historical data is loaded from the trusted analytical source |
| <Source System> provides new operational data | New reporting periods are derived from operational data through the target reporting platform |
| <Consumption Layer> owns reporting consumption | Reports should consume the governed reporting layer |
| One period, one owner source | A reporting period should be loaded from only one approved source |

## Data Flow Control Requirements

Each flow should be controlled and observable through <Control Platform>.

| Control Requirement | Purpose |
|---|---|
| Execution registration | Track when each flow starts, runs, completes, or fails |
| Step tracking | Track source extraction, landing, curation, transformation, and publication steps |
| Source identification | Identify where data came from |
| Batch identification | Track reporting period or batch scope where applicable |
| Validation status | Confirm whether data passed required quality checks |
| Reconciliation status | Confirm whether source and target results match expected values |
| Rerun support | Allow controlled reprocessing by flow, object, or reporting period |
