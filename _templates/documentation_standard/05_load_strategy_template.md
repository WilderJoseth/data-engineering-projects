# Load Strategy

## Document Goal

This document describes the load strategies used to refresh <Business Domain> data across the target reporting platform.

## Load Strategy Overview

The solution uses <Number> main refresh strategies and <Number> write patterns.

| Strategy / Pattern | Purpose | Applies To |
|---|---|---|
| Full reload | Reloads the full dataset for controlled initialization or generated objects | <Applicable Objects> |
| Watermark incremental load | Loads new records using <Created Column> and changed records using <Updated Column> | <Applicable Objects> |
| Batch period reload | Reloads a specific business period based on <Date Column> | <Applicable Objects> |
| Append load | Appends extracted records without updating existing target rows | <Applicable Objects> |
| <Load Pattern> | <Purpose> | <Applicable Objects> |

## Load Strategy by Source

### <Source System>

<Source System> provides <Data Scope> for <Reporting Scope>.

| Data Category | Source Table | Raw Target Table | Curated Target Table | Reporting Target Table | Match Key | Refresh Control Column | Load Strategy |
|---|---|---|---|---|---|---|---|
| <Data Category> | <Table Name> | <Table Name> | <Table Name> | <Table Name> | <Match Key> | <Column Name> | <Load Pattern> |
| <Data Category> | <Table Name> | <Table Name> | <Table Name> | <Table Name> | <Match Key> | <Column Name> | <Load Pattern> |

### <Source System>

<Source System> provides trusted historical reporting data used to initialize the target reporting platform before cutover.

| Data Category | Source Table | Staging Target Table | Reporting Target Table | Match Key | Refresh Control Column | Load Strategy |
|---|---|---|---|---|---|---|
| <Data Category> | <Table Name> | <Table Name> | <Table Name> | <Match Key> | <Column Name> | <Load Pattern> |
| <Data Category> | <Table Name> | <Table Name> | <Table Name> | <Match Key> | <Column Name> | <Load Pattern> |

## Load Strategy Rules

| Rule | Description |
|---|---|
| Full reload is limited to approved objects | Use full reload for objects that can be safely reloaded in full |
| Watermark loads require reliable tracking columns | Use <Created Column> for new records and <Updated Column> for changed records |
| Batch period reload uses <Date Column> by period | Transactional and fact processing must derive <Batch Column> from <Date Column> |
| Raw storage is append-based | Raw storage preserves source-aligned records and execution traceability |
| Curated data is loaded by data category | Curated objects use upsert or batch reload depending on the source data category |
| Reporting data is loaded by analytical object type | Dimensions use <Load Pattern>; facts use <Load Pattern> |
| Reporting data must avoid duplicate period ownership | The same reporting period must not be loaded from more than one source |
| Reruns must be traceable | Reloaded objects or periods must be linked to execution metadata |
| Load strategy should be metadata-driven where possible | Object-level load behavior should be configurable through <Control Platform> |

## Rerun and Recovery Considerations

| Scenario | Expected Behavior |
|---|---|
| Reference / lookup load failure | Rerun from the last successful watermark or approved recovery point |
| Master / core load failure | Rerun from the last successful watermark or approved recovery point |
| Transactional period failure | Rerun the affected business period |
| Historical dimension failure | Rerun the full affected dimension |
| Historical fact failure | Reload the affected historical business period |
| Reporting dimension failure | Reprocess the affected dimension using <Load Pattern> |
| Reporting fact failure | Delete and reload the affected business period |
| Reconciliation failure | Keep the affected batch unaccepted until corrected or approved |

Reruns should not create duplicate records in curated or reporting layers.
