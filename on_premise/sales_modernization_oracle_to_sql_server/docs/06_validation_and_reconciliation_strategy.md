# Validation and Reconciliation Strategy

## Document Goal

This document defines the validation and reconciliation strategy used to confirm that Sales-domain data is migrated correctly into the final operational and analytical target models.

## Validation Principles

| Principle | Description |
|---|---|
| Avoid redundant checks | Do not repeat validations already guaranteed by enforced target constraints unless they are required before the constrained load |
| Validate before publication | Apply technical and business-rule validations before data is published to the final target schemas |
| Reconcile against final targets | Compare source data with `Sales_Operational.prod` or the final `Sales_Analytics` `dim` and `fact` schemas |
| Reconcile at the appropriate grain | Use full-object reconciliation for non-transactional data and monthly reconciliation for transactional and fact data |
| Keep results traceable | Link validation and reconciliation results to the corresponding object, batch, and execution in `DataOps_Control` |
| Separate warnings from failures | Assign severity according to whether an issue should block acceptance of the object or batch |

## Validation Codes

The following validation codes are available through `DataOps_Control`.

| Validation Code | Severity | Recommended Use |
|---|---|---|
| `NOT_NULL` | Error | Validates mandatory business values before publication |
| `DUPLICATE` | Error | Validates uniqueness of source keys or business keys |
| `FK_CHECK` | Error | Validates required relationships before publication |
| `DATA_TYPE` | Error | Confirms that source values are compatible with target data types |
| `LENGTH_CHECK` | Error | Detects source text values that exceed target column lengths |
| `DATE_RANGE` | Warning | Identifies dates outside the expected migration range |
| `NEGATIVE_VALUE` | Warning | Identifies suspicious negative business measures |
| `RECON_WARNING` | Warning | Records reconciliation differences within an approved tolerance |
| `INFO_CHECK` | Info | Records non-blocking profiling or informational results |

## Reconciliation Types

| Reconciliation Type | Description | Applies To |
|---|---|---|
| `ROW_COUNT` | Compares the number of records between the source and final target | All data categories |
| `SUM_TOTAL` | Compares aggregated numeric business measures between the source and final target | Transactional data and analytical facts |

## Reconciliation by Target

### Sales_Operational

Reconciliation compares Oracle source data with the final operational objects published in `Sales_Operational.prod`.

| Data Category | Source Schema | Target Schema | Reconciliation Type | Reconciliation Grain |
|---|---|---|---|---|
| Transactional | `ADVENTUREWORKS2022` | `prod` | `ROW_COUNT`, `SUM_TOTAL` | `OrderDate` month |
| Master / Core | `ADVENTUREWORKS2022` | `prod` | `ROW_COUNT` | Object |
| Reference / Lookup | `ADVENTUREWORKS2022` | `prod` | `ROW_COUNT` | Object |

### Sales_Analytics

Reconciliation compares curated operational data with the final analytical objects published in `Sales_Analytics.dim` and `Sales_Analytics.fact`.

| Data Category | Source Schema | Target Schema | Reconciliation Type | Reconciliation Grain |
|---|---|---|---|---|
| Analytical Fact | `prod` | `fact` | `ROW_COUNT`, `SUM_TOTAL` | `OrderDate` month |
| Analytical Dimension | `prod` | `dim` | `ROW_COUNT` | Object |

## Suggested SUM_TOTAL Measures

`SUM_TOTAL` should be limited to numeric measures that help prove sales and financial consistency.

| Data Category | Suggested Measures |
|---|---|
| Operational transaction header | `SubTotal`, `TaxAmt`, `Freight`, `TotalDue` |
| Operational transaction detail | `OrderQty`, `UnitPrice`, `UnitPriceDiscount`, `LineTotal` |
| Analytical fact | Measures derived from the corresponding operational transaction totals |

## Assumptions and Constraints

| Type | Statement | Description |
|---|---|---|
| Assumption | `ROW_COUNT` is the default reconciliation metric | It applies to every migrated object unless explicitly excluded |
| Assumption | `SUM_TOTAL` applies only where meaningful numeric measures exist | It is used for transactional data and analytical facts |
| Requirement | Transactional reconciliation is batch-based | Transactions and facts are reconciled by `OrderDate` month |
| Requirement | Reconciliation results remain object-level | Although the strategy is documented by data category, each result identifies the specific source and target object |
| Requirement | Only final targets require reconciliation | `staging` and `work` receive validation checks but are not separate reconciliation acceptance points |
