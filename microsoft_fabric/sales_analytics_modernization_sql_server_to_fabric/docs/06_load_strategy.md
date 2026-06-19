# Load Strategy

## Document Goal

This document describes the load strategies used to refresh Sales data across the target reporting platform.

This document expands the load behavior section introduced in `02_solution_design.md`.

## Load Strategy Overview

The solution uses three main refresh strategies and one Bronze-specific write pattern.

| Strategy / Pattern | Purpose | Applies To |
|---|---|---|
| Full reload | Reloads the full dataset for controlled initialization or generated objects | Analytical dimensions from `Sales_Analytics`, generated dimensions such as `DimDate`, and approved small objects |
| Watermark incremental load | Loads new records using `created_at` and changed records using `updated_at` | Reference, lookup, and master tables from `Sales_Operational` |
| Batch period reload | Reloads a specific monthly business period based on `OrderDate` | Transactional objects from `Sales_Operational` and analytical facts from `Sales_Analytics` |
| Append load | Appends extracted records without updating existing target rows | Bronze tables only |

## Load Strategy by Source

### Sales_Operational

`Sales_Operational` provides new operational data for future reporting periods.

| Data Category | Source Table | Bronze Target Table | Silver Target Table | Gold Target Table | Match Key | Refresh Control Column | Load Strategy |
|---|---|---|---|---|---|---|---|
| Transactional | `SalesOrderHeader` | `SalesOrderHeader` | `SalesOrderHeader` | `FactSales` | Not required | `OrderDate` | Bronze append; Silver monthly batch reload; Gold monthly batch reload |
| Transactional | `SalesOrderDetail` | `SalesOrderDetail` | `SalesOrderDetail` | `FactSales` | Not required | Header `OrderDate` | Bronze append; Silver monthly batch reload; Gold monthly batch reload |
| Master / Core | `Customer` | `Customer` | `Customer` | `DimCustomer` | `SourceCustomerID` | `created_at`, `updated_at` | Bronze append; Silver upsert; Gold upsert |
| Master / Core | `SalesPerson` | `SalesPerson` | `SalesPerson` | `DimSalesPerson` | `SourceSalesPersonID` | `created_at`, `updated_at` | Bronze append; Silver upsert; Gold upsert |
| Master / Core | `Product`, `ProductCategory` | `Product`, `ProductCategory` | `Product`, `ProductCategory` | `DimProduct` | `SourceProductID` | `created_at`, `updated_at` | Bronze append; Silver upsert; Gold upsert |
| Master / Core | `CreditCard` | `CreditCard` | `CreditCard` | `DimPaymentMethod` | `SourceCreditCardID` | `created_at`, `updated_at` | Bronze append; Silver upsert; Gold upsert |
| Reference / Lookup | `CountryRegion`, `StateProvince`, `SalesTerritory` | `CountryRegion`, `StateProvince`, `SalesTerritory` | `CountryRegion`, `StateProvince`, `SalesTerritory` | `DimSalesTerritory` | `SourceCountryRegionCode` | `created_at`, `updated_at` | Bronze append; Silver upsert; Gold upsert |
| Reference / Lookup | `ShipMethod` | `ShipMethod` | `ShipMethod` | `DimShipMethod` | `SourceShipMethodID` | `created_at`, `updated_at` | Bronze append; Silver upsert; Gold upsert |

### Sales_Analytics

`Sales_Analytics` provides trusted historical reporting data used to initialize the target reporting model before cutover.

| Data Category | Source Table | Staging Target Table | Gold Target Table | Match Key | Refresh Control Column | Load Strategy |
|---|---|---|---|---|---|---|
| Analytical Fact | `FactSales` | `FactSales` | `FactSales` | Not required | `OrderDate` | Staging monthly batch reload; Gold monthly batch reload |
| Analytical Dimension | `DimCustomer` | `DimCustomer` | `DimCustomer` | `SourceCustomerID` | Not required | Staging full reload; Gold full reload |
| Analytical Dimension | `DimProduct` | `DimProduct` | `DimProduct` | `SourceProductID` | Not required | Staging full reload; Gold full reload |
| Analytical Dimension | `DimSalesPerson` | `DimSalesPerson` | `DimSalesPerson` | `SourceSalesPersonID` | Not required | Staging full reload; Gold full reload |
| Analytical Dimension | `DimSalesTerritory` | `DimSalesTerritory` | `DimSalesTerritory` | `SourceSalesTerritoryID` | Not required | Staging full reload; Gold full reload |
| Analytical Dimension | `DimPaymentMethod` | `DimPaymentMethod` | `DimPaymentMethod` | `SourcePaymentMethodID` | Not required | Staging full reload; Gold full reload |
| Analytical Dimension | `DimShipMethod` | `DimShipMethod` | `DimShipMethod` | `SourceShipMethodID` | Not required | Staging full reload; Gold full reload |
| Analytical Dimension | `DimDate` | `DimDate` | `DimDate` | `DateKey` | Not required | Staging full reload; Gold generated refresh or full reload |

## Load Strategy Rules

| Rule | Description |
|---|---|
| Full reload is limited to historical dimensional tables and generated dimensions | Use full reload for analytical dimensions loaded from `Sales_Analytics` during historical initialization before cutover, and for generated dimensions such as `DimDate` |
| Watermark loads require reliable tracking columns | Use `created_at` for new records and `updated_at` for changed records |
| Batch period reload uses `OrderDate` by month | Transactional and fact processing must derive `batch_period_yyyymm` from `OrderDate` |
| Bronze is append-based | Bronze preserves source-aligned records and execution traceability |
| Silver is curated by data category | Silver uses upsert or batch reload depending on the operational data category |
| Gold is loaded by analytical object type | Dimensions use upsert to preserve surrogate key stability; facts use monthly batch period reload |
| Gold must avoid duplicate period ownership | The same reporting period must not be loaded from both historical and new sources |
| Reruns must be traceable | Reloaded objects or periods must be linked to execution metadata |
| Load strategy should be metadata-driven where possible | Object-level load behavior should be configurable through `DataOps_Control` |

## Rerun and Recovery Considerations

| Scenario | Expected Behavior |
|---|---|
| Reference / lookup load failure | Rerun from the last successful watermark or approved recovery point |
| Master / core load failure | Rerun from the last successful watermark or approved recovery point |
| Transactional period failure | Rerun the affected `OrderDate` month |
| Historical analytical dimension failure | Rerun the full affected dimension |
| Historical analytical fact failure | Reload the affected historical `OrderDate` month |
| Gold dimension failure | Reprocess the affected dimension through upsert |
| Gold fact failure | Delete and reload the affected `OrderDate` month |
| Reconciliation failure | Keep the affected batch unaccepted until corrected or approved |

Reruns should not create duplicate records in Silver or Gold.

## Conclusion

The load strategy defines how each source object is refreshed across the target reporting platform.

Reference, lookup, master, and core objects from `Sales_Operational` use watermark incremental loading based on `created_at` and `updated_at`, with upsert processing in Silver and Gold. Transactional data from `Sales_Operational` uses monthly batch period reloads based on `OrderDate`.

Historical analytical dimensions from `Sales_Analytics` are loaded using full reload during historical initialization before cutover. Historical analytical facts from `Sales_Analytics` use monthly batch reloads based on `OrderDate`.

Bronze uses append-based ingestion to preserve traceability. Silver applies curated loading by operational data category. Gold uses upsert for dimensions and monthly delete-and-reload processing for facts.

This strategy allows the target reporting platform to initialize trusted historical reporting data from `Sales_Analytics` and continue loading new reporting data from `Sales_Operational` while maintaining traceability, recoverability, and reporting-period control.
