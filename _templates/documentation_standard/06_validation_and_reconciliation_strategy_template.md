# Validation and Reconciliation Strategy

## Document Goal

This document defines the initial validation and reconciliation strategy used to confirm that <Business Domain> data is loaded correctly across the target reporting platform.

## Validation Principles

| Principle | Description |
|---|---|
| Avoid redundant checks | Do not validate rules that are already guaranteed by table constraints unless validation occurs before the constrained load step |
| Reconcile at the right grain | Use table-level reconciliation for small or dimensional objects and batch-level reconciliation for transactional or fact data |
| Keep checks traceable | Validation and reconciliation results should be linked to the execution step that produced the data |
| Separate warnings from failures | Not every issue should stop the pipeline; severity should reflect business impact |

## Validation Codes

The following validation codes are defined in <Control Platform>.

| Validation Code | Severity | Recommended Use |
|---|---|---|
| <Validation Rule> | Error | <Recommended Use> |
| <Validation Rule> | Error | <Recommended Use> |
| <Validation Rule> | Warning | <Recommended Use> |
| <Validation Rule> | Info | <Recommended Use> |

## Reconciliation Types

The reconciliation strategy uses <Number> reconciliation types.

| Reconciliation Type | Description | Applies To |
|---|---|---|
| <Reconciliation Type> | Compares <Metric> between source and target | <Applicable Objects> |
| <Reconciliation Type> | Compares aggregated business values between source and target for a batch period | <Applicable Objects> |

## Reconciliation by Source

### <Source System>

<Source System> provides <Data Scope>. Reconciliation should focus on confirming that source data is correctly represented in the target layers.

| Data Category | Source Table | Raw Target Table | Curated Target Table | Reporting Target Table | Reconciliation Type | Reconciliation Grain |
|---|---|---|---|---|---|---|
| <Data Category> | <Table Name> | <Table Name> | <Table Name> | <Table Name> | <Reconciliation Type> | <Grain> |
| <Data Category> | <Table Name> | <Table Name> | <Table Name> | <Table Name> | <Reconciliation Type> | <Grain> |

### <Source System>

<Source System> provides trusted historical reporting data before cutover. Reconciliation should confirm that historical data is loaded correctly into staging and reporting layers.

| Data Category | Source Table | Staging Target Table | Reporting Target Table | Reconciliation Type | Reconciliation Grain |
|---|---|---|---|---|---|
| <Data Category> | <Table Name> | <Table Name> | <Table Name> | <Reconciliation Type> | <Grain> |
| <Data Category> | <Table Name> | <Table Name> | <Table Name> | <Reconciliation Type> | <Grain> |

## Suggested Reconciliation Measures

<Reconciliation Type> reconciliation should be limited to numeric business measures that help prove business consistency.

| Table Type | Table | Suggested Measures |
|---|---|---|
| <Table Type> | <Table Name> | <Measure Name>, <Measure Name> |
| <Table Type> | <Table Name> | <Measure Name>, <Measure Name> |

## Assumptions and Constraints

| Type | Statement | Description |
|---|---|---|
| Assumption | <Assumption> | <Description> |
| Requirement | <Requirement> | <Description> |
| Constraint | <Constraint> | <Description> |
