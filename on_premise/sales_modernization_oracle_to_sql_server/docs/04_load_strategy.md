# Load Strategy

## Purpose

This document describes the load strategies used to load Sales data.

## Load Strategy Overview

The solution uses two main load strategies.

| Strategy / Pattern | Purpose |
|---|---|
| Full load | Loads the complete dataset |
| Batch period load | Loads a specific monthly business period based on `OrderDate` |

## Load Strategy by Target

### Sales_Operational

`ADVENTUREWORKS2022` is used as the source schema.

#### Source to Staging

| Data Category | Source Schema | Target Schema | Load Control Column | Load Strategy |
|---|---|---|---|---|
| Transactional | `ADVENTUREWORKS2022` | `staging` | `OrderDate` | Batch period load |
| Master / Core | `ADVENTUREWORKS2022` | `staging` | Not required | Full load |
| Reference / Lookup | `ADVENTUREWORKS2022` | `staging` | Not required | Full load |
| Bridge / Associative | `ADVENTUREWORKS2022` | `staging` | Not required | Full load |

#### Staging to Work

| Data Category | Source Schema | Target Schema | Load Control Column | Load Strategy |
|---|---|---|---|---|
| Transactional | `staging` | `work` | `OrderDate` | Batch period load |
| Master / Core | `staging` | `work` | Not required | Full load |
| Reference / Lookup | `staging` | `work` | Not required | Full load |

#### Work to Production

| Data Category | Source Schema | Target Schema | Load Control Column | Load Strategy |
|---|---|---|---|---|
| Transactional | `work` | `prod` | `OrderDate` | Batch period load |
| Master / Core | `work` | `prod` | Not required | Full load |
| Reference / Lookup | `work` | `prod` | Not required | Full load |

### Sales_Analytics

`Sales_Operational` is used as the source database for `Sales_Analytics`.

#### Production to Staging

| Data Category | Source Schema | Target Schema | Load Control Column | Load Strategy |
|---|---|---|---|---|
| Transactional | `prod` | `staging` | `OrderDate` | Batch period load |
| Master / Core | `prod` | `staging` | Not required | Full load |
| Reference / Lookup | `prod` | `staging` | Not required | Full load |

#### Staging to Work

| Data Category | Source Schema | Target Schema | Load Control Column | Load Strategy |
|---|---|---|---|---|
| Analytical Fact | `staging` | `work` | `OrderDate` | Batch period load |
| Analytical Dimension | `staging` | `work` | Not required | Full load |
| Generated Dimension | Not applicable | `work` | Not required | Full load |

#### Work to Final

| Data Category | Source Schema | Target Schema | Load Control Column | Load Strategy |
|---|---|---|---|---|
| Analytical Fact | `work` | `fact` | `OrderDate` | Batch period load |
| Analytical Dimension | `work` | `dim` | Not required | Full load |
| Generated Dimension | `work` | `dim` | Not required | Full load |

## Load Strategy Rules

| Rule | Description |
|---|---|
| Full loads apply to approved objects | Use full loads for objects that do not require period-based processing |
| Batch period loads use `OrderDate` | Transactional objects and analytical facts are loaded by monthly period derived from `OrderDate` |
| Each period must be processed once | A migration batch must not create duplicate records for the same business period |
| Reruns must be controlled | Reloaded objects or periods must be linked to execution metadata in `DataOps_Control` |
| Load behavior should be metadata-driven | Object-level load strategy and batch behavior should be configurable through `DataOps_Control` where practical |

## Rerun and Recovery Considerations

| Scenario | Expected Behavior |
|---|---|
| Reference / Lookup load failure | Rerun the affected full load |
| Master / Core load failure | Rerun the affected full load |
| Transactional period failure | Rerun the affected `OrderDate` month |
| Analytical dimension failure | Rerun the affected full load |
| Analytical fact failure | Reload the affected `OrderDate` month |
| Reconciliation failure | Keep the affected object or batch unaccepted until corrected or approved |
