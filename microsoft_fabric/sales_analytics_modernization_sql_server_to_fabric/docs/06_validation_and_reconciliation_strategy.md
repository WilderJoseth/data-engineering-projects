# Validation and Reconciliation Strategy

## Document Goal

This document defines the initial validation and reconciliation strategy used to confirm that Sales data is loaded correctly across the target reporting platform.

This document expands the validation and reconciliation strategy section introduced in `02_solution_design.md`.

## Validation Principles

| Principle | Description |
|---|---|
| Avoid redundant checks | Do not validate rules that are already guaranteed by table constraints unless validation occurs before the constrained load step |
| Reconcile at the right grain | Use table-level reconciliation for small or dimensional objects and batch-level reconciliation for transactional or fact data |
| Keep checks traceable | Validation and reconciliation results should be linked to the execution step that produced the data |
| Separate warning from failure | Not every issue should stop the pipeline; severity should reflect business impact |

## Validation Codes

The following validation codes are available from `DataOps_Control`.

| Validation Code | Severity | Recommended Use |
|---|---|---|
| `NOT_NULL` | Error | Use when a column is technically nullable but required by business rules, or when validating before a constrained target load |
| `DUPLICATE` | Error | Use when a business key or source key must be unique in the target object |
| `FK_CHECK` | Error | Use when referential integrity must be checked before publication or when physical constraints are not enforced |
| `DATA_TYPE` | Error | Use when raw or source-aligned values may not match the expected target data type |
| `LENGTH_CHECK` | Error | Use when source text values may exceed expected target lengths |
| `DATE_RANGE` | Warning | Use for business dates that must fall within expected operational or reporting ranges |
| `NEGATIVE_VALUE` | Warning | Use for numeric measures where negative values are suspicious and require review |
| `RECON_WARNING` | Warning | Use when reconciliation passes within an accepted tolerance or requires review |
| `INFO_CHECK` | Info | Use for non-blocking profiling or informational checks |

## Reconciliation Types

The reconciliation strategy uses two reconciliation types.

| Reconciliation Type | Description | Applies To |
|---|---|---|
| `ROW_COUNT` | Compares the number of records between source and target for a table, object, or batch | Reference, master, transactional, dimension, and fact tables |
| `SUM_TOTAL` | Compares aggregated numeric business values between source and target for a batch period | Transactional and fact tables |

## Reconciliation by Source

### Sales_Operational

`Sales_Operational` provides new operational data after cutover. Reconciliation should focus on confirming that operational source data is correctly represented in Bronze, Silver, and Gold.

| Data Category | Source Table | Bronze Target Table | Silver Target Table | Gold Target Table | Reconciliation Type | Reconciliation Grain |
|---|---|---|---|---|---|---|
| Transactional | `SalesOrderHeader` | `SalesOrderHeader` | `SalesOrderHeader` | `FactSales` | `ROW_COUNT`, `SUM_TOTAL` | `OrderDate` month |
| Transactional | `SalesOrderDetail` | `SalesOrderDetail` | `SalesOrderDetail` | `FactSales` | `ROW_COUNT`, `SUM_TOTAL` | Header `OrderDate` month |
| Master / Core | `Customer` | `Customer` | `Customer` | `DimCustomer` | `ROW_COUNT` | Table |
| Master / Core | `SalesPerson` | `SalesPerson` | `SalesPerson` | `DimSalesPerson` | `ROW_COUNT` | Table |
| Master / Core | `Product`, `ProductCategory` | `Product`, `ProductCategory` | `Product`, `ProductCategory` | `DimProduct` | `ROW_COUNT` | Table |
| Master / Core | `CreditCard` | `CreditCard` | `CreditCard` | `DimPaymentMethod` | `ROW_COUNT` | Table |
| Reference / Lookup | `CountryRegion`, `StateProvince`, `SalesTerritory` | `CountryRegion`, `StateProvince`, `SalesTerritory` | `CountryRegion`, `StateProvince`, `SalesTerritory` | `DimSalesTerritory` | `ROW_COUNT` | Table |
| Reference / Lookup | `ShipMethod` | `ShipMethod` | `ShipMethod` | `DimShipMethod` | `ROW_COUNT` | Table |

### Sales_Analytics

`Sales_Analytics` provides trusted historical reporting data before cutover. Reconciliation should confirm that historical dimensions and facts are loaded correctly into Staging and Gold.

| Data Category | Source Table | Staging Target Table | Gold Target Table | Reconciliation Type | Reconciliation Grain |
|---|---|---|---|---|---|
| Analytical Fact | `FactSales` | `FactSales` | `FactSales` | `ROW_COUNT`, `SUM_TOTAL` | `OrderDate` month |
| Analytical Dimension | `DimCustomer` | `DimCustomer` | `DimCustomer` | `ROW_COUNT` | Table |
| Analytical Dimension | `DimProduct` | `DimProduct` | `DimProduct` | `ROW_COUNT` | Table |
| Analytical Dimension | `DimSalesPerson` | `DimSalesPerson` | `DimSalesPerson` | `ROW_COUNT` | Table |
| Analytical Dimension | `DimSalesTerritory` | `DimSalesTerritory` | `DimSalesTerritory` | `ROW_COUNT` | Table |
| Analytical Dimension | `DimPaymentMethod` | `DimPaymentMethod` | `DimPaymentMethod` | `ROW_COUNT` | Table |
| Analytical Dimension | `DimShipMethod` | `DimShipMethod` | `DimShipMethod` | `ROW_COUNT` | Table |
| Analytical Dimension | `DimDate` | `DimDate` | `DimDate` | `ROW_COUNT` | Table |

## Suggested SUM_TOTAL Measures

`SUM_TOTAL` reconciliation should be limited to numeric business measures that help prove financial or sales consistency.

| Table Type | Table | Suggested Measures |
|---|---|---|
| Operational transaction header | `SalesOrderHeader` | `SubTotal`, `TaxAmt`, `Freight`, `TotalDue` |
| Operational transaction detail | `SalesOrderDetail` | `OrderQty`, `UnitPrice`, `UnitPriceDiscount`, `LineTotal` |
| Analytical fact | `FactSales` | `OrderQty`, `UnitPrice`, `UnitPriceDiscount`, `LineTotal`, `SubTotal`, `TaxAmt`, `Freight`, `TotalDue`, `SalesAmountUSD` |

## Assumptions and Constraints

| Type | Statement | Description |
|---|---|---|
| Assumption | `ROW_COUNT` is the default reconciliation metric | Row count reconciliation applies to all source categories unless explicitly excluded |
| Assumption | `SUM_TOTAL` applies only to transactional and fact data | Business totals are reconciled only where numeric measures exist and add value |
| Requirement | Fact reconciliation is batch-based | Transactional and fact reconciliation must support `OrderDate` month-level comparison |

## Conclusion

The validation and reconciliation strategy defines a practical first set of checks for the Sales reporting modernization.

`ROW_COUNT` reconciliation is used across reference, master, transactional, dimension, and fact tables to confirm load completeness. `SUM_TOTAL` reconciliation is used for transactional and fact tables to confirm business totals by batch period.

The strategy avoids redundant checks that are already enforced by table constraints and focuses on validations that support completeness, consistency, reporting confidence, and controlled rerun behavior.
