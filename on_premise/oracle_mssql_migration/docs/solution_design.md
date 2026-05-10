# Solution Design

## Purpose

This document describes the technical design for the Sales domain migration and modernization solution.

## Data Source in Scope

The operational migration scope includes the Sales order process and the supporting entities like Customer, Address, etc.

### Technical details

- The database engine is `Oracle XE 21c`.
- Source schema is `ADVENTUREWORKS2022`.
- Each source table name includes the domain as a prefix, for example `SALES_SALESORDERHEADER`.
- All table names follow a `UPPER_CASE` pattern.

### Data Model Diagram

The source model shows the selected tables that are part of Sales-domain scope modernization.

![Sales Domain Source Data Model](img/data_model_source.png)

| Data role | Source table | Purpose in migration |
|---|---|---|
| Transactional | `SALES_SALESORDERHEADER` | Preserves the main Sales order event and order-level business context. |
| Transactional | `SALES_SALESORDERDETAIL` | Preserves the products, quantities, prices, discounts, and line totals sold in each order. |
| Master / Core | `SALES_CUSTOMER` | Identifies the customer associated with each Sales order. |
| Master / Core | `PERSON_PERSON` | Provides person attributes used to enrich customers and salespeople. |
| Master / Core | `HUMANRESOURCES_EMPLOYEE` | Provides employee attributes required to build salesperson information. |
| Master / Core | `SALES_SALESPERSON` | Identifies the salesperson associated with each Sales order. |
| Master / Core | `PERSON_ADDRESS` | Preserves billing and shipping address context for Sales orders. |
| Master / Core | `PRODUCTION_PRODUCT` | Identifies the products sold in Sales order lines. |
| Master / Core | `SALES_CREDITCARD` | Preserves payment context when credit card information is present. |
| Master / Core | `PURCHASING_SHIPMETHOD` | Identifies the shipping method. |
| Reference / Lookup | `PERSON_ADDRESSTYPE` | Classifies the business purpose of addresses. |
| Reference / Lookup | `PERSON_STATEPROVINCE` | Supports regional geography for addresses and territory mapping. |
| Reference / Lookup | `PERSON_COUNTRYREGION` | Supports country/region grouping for geography and reporting. |
| Reference / Lookup | `SALES_CURRENCYRATE` | Provides currency context for order amounts. |
| Reference / Lookup | `SALES_CURRENCY` | Provides currency context for order amounts. |
| Reference / Lookup | `SALES_SALESTERRITORY` | Groups customers, salespeople, and orders by commercial territory. |
| Reference / Lookup | `SALES_SPECIALOFFER` | Preserves promotion or discount context applied to Sales lines. |
| Reference / Lookup | `PRODUCTION_PRODUCTSUBCATEGORY` | Provides the product classification level. |
| Bridge / Associative | `PERSON_BUSINESSENTITYADDRESS` | Maps business entities to addresses and address types in the source model. |
| Bridge / Associative | `SALES_SPECIALOFFERPRODUCT` | Provides source product-offer relationships used to validate Sales line context. |

## Target Databases

The target solution uses three databases:

| Database | Responsibility |
|---|---|
| `Sales_Operational` | Normalized operational database for the migrated Sales domain. |
| `Sales_Analytics` | Analytical database for reporting and historical analysis. Follows a star schema design to simplify reporting and analytical queries. |
| `DataOps_Control` | Reusable technical control database for metadata, execution tracking, validation, reconciliation, error logging, batch control, and rerun support. |

### Technical details

- The database engine is `SQL Server 2022`.
- The database names use descriptive names with underscores to improve readability.

## Schema Organization

The schema names follow a `lower_case` pattern.

### Sales_Operational

| Schema | Purpose |
|---|---|
| `prod` | Final operational business tables. |
| `staging` | Raw extracted data before validation and transformation. |
| `work` | Intermediate validated/transformed data used during loads. |
| `control` | Database-specific helper objects used by ETL and integration with `DataOps_Control`. |

### Sales_Analytics

| Schema | Purpose |
|---|---|
| `dim` | Analytical dimensions. |
| `fact` | Analytical fact tables. |
| `staging` | Raw extracted data before validation and transformation. |
| `work` | Intermediate dimensional/fact processing. |
| `control` | Database-specific helper objects used by ETL and integration with `DataOps_Control`. |

## Target Data Models

### Sales_Operational Data Model

The `Sales_Operational` model is a normalized target model for the Sales domain.

![Sales_Operational Data Model](img/data_model_Sales_Operational.png)

Key design decisions:

- `SalesPerson` consolidates source `HUMANRESOURCES_EMPLOYEE`, `PERSON_PERSON`, and `SALES_SALESPERSON` data.
- `Customer` consolidates source `PERSON_PERSON` and `SALES_CUSTOMER` data.
- `PERSON_BUSINESSENTITYADDRESS` is removed; address classification is handled directly through `AddressType` and `Address`.
- `SALES_SPECIALOFFERPRODUCT` is removed; the applied offer is stored at `SalesOrderDetail` level.
- Source `PRODUCTION_PRODUCTSUBCATEGORY` values are loaded into target `ProductCategory`, creating one product classification level.
- `SalesOrderHeader` includes separate billing and shipping address relationships.

| Data role | Target table |
|---|---|
| Transactional | `SalesOrderHeader`, `SalesOrderDetail` |
| Master / Core | `Customer`, `SalesPerson`, `Address`, `Product`, `CreditCard` |
| Reference / Lookup | `CountryRegion`, `StateProvince`, `SalesTerritory`, `AddressType`, `ShipMethod`, `Currency`, `CurrencyRate`, `SpecialOffer`, `ProductCategory` |

### Sales_Analytics Data Model

The `Sales_Analytics` model is a star schema.

![Sales_Analytics Data Model](img/data_model_Sales_Analytics.png)

Key design decisions:

- `Sales_Analytics` is loaded from `Sales_Operational.prod` to avoid duplicating Oracle cleansing and validation logic and focuses on business-friendly reporting.
- `SalesOrderHeader` and `SalesOrderDetail` are combined into `FactSales`.
- The grain of `FactSales` is one Sales order detail line.
- Product category attributes are denormalized into `DimProduct`.
- Country/region attributes are denormalized into `DimSalesTerritory`.
- `CreditCard` is transformed into `DimPaymentMethod` to avoid exposing unnecessary card-level details.
- `CurrencyRate` is not modeled as a dimension; analytical sales measures are standardized to USD.
- `SpecialOffer` and detailed `Address` are not modeled.
- `DimDate` supports order, due, and ship date analysis through role-playing date keys.

| Data role | Target table |
|---|---|
| Fact | `FactSales` |
| Dimension | `DimDate`, `DimCustomer`, `DimSalesPerson`, `DimSalesTerritory`, `DimProduct`, `DimPaymentMethod`, `DimShipMethod` |

### DataOps_Control Data Model

![DataOps_Control Data Model](img/data_model_DataOps_Control.png)

The model is organized into three logical groups:

| Group | Tables | Purpose |
|---|---|---|
| Project metadata | `projects`, `project_processes`, `project_databases`, `project_tables`, `project_columns`, `project_table_batches` | Defines projects, process hierarchy, databases, tables, columns, and table-level load metadata. |
| Execution tracking | `execution_runs`, `execution_steps` | Tracks full runs, hierarchical execution steps, and batch-level execution for large tables. |
| Observability | `error_logs`, `validation_results`, `reconciliation_results` | Stores technical errors, validation outcomes, and reconciliation checks. |

#### Technical details

- `project_processes` and `execution_steps` support self-relations to represent hierarchies such as ETL project, package, subprocess, table load, and child execution steps.
- `project_tables` can store table-level control metadata such as `load_type`, `batch_enabled`, `batch_column_name`, `rerun_required`, `last_load_status`, and `last_successful_run_id`.
- `project_table_batches` supports large transactional tables split by period or key range. For this project, transactional batches use monthly `yyyyMM` periods based on `SalesOrderHeader.OrderDate`.

## Table Implementation Standards

### Table Naming

- Business tables should use `PascalCase`, for example `prod.SalesOrderHeader`.
- Staging/work tables should use `PascalCase`, for example `staging.SalesOrderHeader`.
- Control tables should use `snake_case`, for example `control.reconciliation_results`.

### Data Type Mapping Guidelines

Oracle source types should be mapped to SQL Server target types based on business meaning, precision, and expected usage.

| Oracle source type | SQL Server target type | Mapping rule |
|---|---|---|
| `NUMBER(p, 0)` | `INT` or `BIGINT` | Use for whole-number identifiers, counters, etc. |
| `NUMBER(p, s)` | `DECIMAL(p, s)` | Use for monetary values, rates, percentages, etc. |
| `VARCHAR2(n)` | `VARCHAR(n)` or `NVARCHAR(n)` | Use for text attributes. Use `NVARCHAR` when Unicode support is required. |
| `CHAR(n)` | `CHAR(n)` | Use for fixed or short code values when length is stable. |
| `DATE` | `DATE` or `DATETIME2` | Use `DATE` for date-only attributes. Use `DATETIME2` when time values must be preserved. |
| `TIMESTAMP` | `DATETIME2` | Use when datetime precision is required. |

### Key and Identifier Guidelines

- All business tables should have a `surrogate key`, which should be SQL Server-generated like `IDENTITY`.
- Surrogate keys should use the suffix `Key`, for example `CustomerKey`, `ProductKey`, or `SalesOrderHeaderKey`.
- Source business keys should be preserved with a `Source` prefix, for example `SourceCustomerID`, `SourceProductID`, or `SourceSalesOrderID`. They are needed for:
  - Source-to-target traceability
  - Reconciliation
  - Rerun logic
  - Historical audit
  - Integration with other source-derived objects

### Audit Columns

Final business tables may include audit/technical columns when required.

| Column | Purpose | Type | Allow nulls | Default value |
|---|---|---|---|---|
| `created_at` | When the record was inserted. | DATETIME2 | No | SYSUTCDATETIME() |
| `created_by` | User or process that inserted the record. | VARCHAR(50) | No | USER_NAME() |
| `updated_at` | When the record was last updated. | DATETIME2 | Yes | |
| `updated_by` | User or process that last updated the record. | VARCHAR(50) | Yes | |
| `created_run_id` | Execution run that inserted the record. | INT | No | |
| `is_active` | Indicates whether the record is active in the target model. | BIT | No | 1 |

### Constraint Rules

- All tables should have a primary key.
- Avoid composite primary keys in final business tables unless there is a clear design reason.
- Foreign keys should be defined where they support target integrity and do not conflict with the migration/reload strategy.
- The name of the primary key should follow `pk_[schema]_[table]_[column]`.
- The name of the foreign key should follow `fk_[schema]_[table]_[column]`.

## Stored Procedure Implementation Pattern

SQL Server stored procedures handle database-side validation, transformation, final loading, reconciliation, and status updates.

### Stored Procedure Naming

Names should follow the following structure: `usp_[action]_[TableName]`. Exceptions may apply.

The common stored procedures are the following:

| Prefix | Purpose | Example |
|---|---|---|
| `usp_cleanup_` | Clean staging/work objects | `usp_cleanup_tables` |
| `usp_load_` | Load data into tables | `usp_load_AddressType` |
| `usp_validate_` | Validate staged or working data | `usp_validate_AddressType` |
| `usp_reconcile_` | Register reconciliation checks | `usp_reconcile_AddressType` |
| `usp_register_` | Register execution, step, log, or result metadata | `usp_register_reconciliation_result` |

### Validation Procedure Pattern

1. Read staged records for the current table or batch.
2. Apply required data-quality rules.
3. Write validation errors or warnings to `control.validation_results`, in order to send them to `DataOps_Control`.
4. Mark valid records for loading into `work`.

### Final Load Procedure Pattern

Final load procedures should use the strategy appropriate to the load type.

| Load type | Final load strategy |
|---|---|
| Reference / master | `MERGE` or UPSERT using source business keys. |
| Transactional | Controlled delete and reload by batch period. |
| Dimension | `MERGE` or UPSERT for Type 1 dimensions unless otherwise defined. |
| Fact | Controlled delete and reload by batch period. |

### Reconciliation Procedure Pattern

Reconciliation procedures should register results in `control.reconciliation_results`, in order to send them to `DataOps_Control`.

Common reconciliation checks include:

- Source-to-staging row counts.
- Work-to-final row counts.
- Financial totals for transactional and fact loads.

## SSIS Implementation Guidelines

### ETL and Data Movement

Data movement is implemented through two controlled flows:

| Flow | Pattern |
|---|---|
| Operational migration | `Oracle source -> Sales_Operational.staging -> Sales_Operational.work -> Sales_Operational.prod` |
| Analytical loading | `Sales_Operational.prod -> Sales_Analytics.staging -> Sales_Analytics.work -> Sales_Analytics.dim / Sales_Analytics.fact` |

### Load Rules

- Data is not loaded directly from Oracle into final business tables.
- Reference and master data are loaded before transactional data.
- Large transactional tables use batch-based processing by `SalesOrderHeader.OrderDate` period in `yyyyMM` format.
- Analytical loading uses `Sales_Operational.prod` as the curated source.
- Execution status, validation results, reconciliation results, errors, and batch checkpoints are registered in `DataOps_Control`.
- `staging` and `work` tables are managed through controlled cleanup rules.

### Project Parameters

Common project-level parameters may include:

| Parameter | Purpose |
|---|---|
| `project_id` | Identifies the registered project in `DataOps_Control`. |
| `[db_name]_initialcatalog` | Identifies name of the database. |
| `[db_name]_server` | Identifies the name of the server. |
| `[db_name]_username` | Identifies the name of the user. |
| `[db_name]_password` | Identifies the user password. |

### Package Parameters

Common package-level parameters may include:

| Parameter | Purpose |
|---|---|
| `execution_run_id` | Identifies the current execution run. |
| `execution_step_id` | Identifies the current execution step. |
| `project_table_id` | Identifies the table being processed. |
| `batch_period_YYYYMM` | Identifies the current batch period when batching is used. |
| `rerun_required` | Indicates whether the object is being reprocessed. |

### Connection Managers

- Oracle source connection
- `Sales_Operational` target connection
- `Sales_Analytics` target connection
- `DataOps_Control` connection

Connection values should be environment-configurable and should not be hardcoded inside package logic.

### Event Handlers

SSIS `OnError` event handlers should register unexpected technical failures in `DataOps_Control.error_logs`.

## ETL Implementation Projects

The migration is implemented through two Integration Services projects:

| Project | Responsibility |
|---|---|
| `Sales_Operational_Migration` | Migrates validated Sales-domain data from Oracle into `Sales_Operational`. |
| `Sales_Analytics_Migration` | Builds the analytical model in `Sales_Analytics` using `Sales_Operational.prod` as the curated source. |

This separation keeps operational and analytical responsibilities independent.

### Common ETL Controls

All migration packages follow the same staged processing concept:

```text
source -> staging -> work -> final target tables
```

Common controls include:

- Execution and step registration in `DataOps_Control`.
- Configuration-driven execution.
- Staging/work cleanup.
- Validation through SQL Server stored procedures.
- Reconciliation before marking loads as successful.
- Idempotent final loads using `MERGE` or UPSERT where appropriate, for example: master or dimension tables.
- Table-level or batch-level rerun support.
- Technical error handling through SSIS `OnError` event handlers.

### Common Table-Level Load Pattern

1. Register table load start in `DataOps_Control`.
2. Extract data into `staging`.
3. Validate staged data and load valid records into `work`.
4. Register validation and reconciliation results.
5. Load final records using `MERGE` or UPSERT logic.
6. Update table-level status in `DataOps_Control`.

### Sales_Operational_Migration

| Package | Purpose |
|---|---|
| `PKG_OPERATIONAL_MIGRATION` | Orchestrates reference, master, and transactional packages. |
| `PKG_REFERENCE_DATA` | Loads reference data. |
| `PKG_MASTER_DATA` | Loads master/core entities. |
| `PKG_TRANSACTIONAL_DATA` | Loads Sales transactions by batch. |

#### Reference Data Load Flow

| Group | Load container | Target table | Source table | Dependency | Execution behavior |
|---|---|---|---|---|---|
| Group 1 | `AddressType Load` | `AddressType` | `PERSON_ADDRESSTYPE` | None | Independent table load; can run in parallel |
| Group 1 | `ProductCategory Load` | `ProductCategory` | `PRODUCTION_PRODUCTSUBCATEGORY` | None | Independent table load; can run in parallel |
| Group 1 | `SpecialOffer Load` | `SpecialOffer` | `SALES_SPECIALOFFER` | None | Independent table load; can run in parallel |
| Group 1 | `ShipMethod Load` | `ShipMethod` | `PURCHASING_SHIPMETHOD` | None | Independent table load; can run in parallel |
| Group 2 | `Geography Load` | `CountryRegion` | `PERSON_COUNTRYREGION` | None | Extracted to staging with the geography group; validated and loaded first by stored procedure sequence |
| Group 2 | `Geography Load` | `StateProvince` | `PERSON_STATEPROVINCE` | `CountryRegion` | Extracted to staging with the geography group; validated and loaded second after `CountryRegion` |
| Group 2 | `Geography Load` | `SalesTerritory` | `SALES_SALESTERRITORY` | `CountryRegion`, `StateProvince` | Extracted to staging with the geography group; validated and loaded third after geography parent records |
| Group 2 | `Currency Load` | `Currency` | `SALES_CURRENCY` | None | Extracted to staging with the currency group; validated and loaded first by stored procedure sequence |
| Group 2 | `Currency Load` | `CurrencyRate` | `SALES_CURRENCYRATE` | `Currency` | Extracted to staging with the currency group; validated and loaded second after `Currency` |

Reference validation focuses on controlled values, required codes and descriptions, duplicate business keys, valid parent references, code formats, numeric ranges, and effective date ranges.

For grouped reference containers, related source tables can be extracted into staging in parallel. Parent-child dependencies are enforced later by SQL Server stored procedures during validation, work-table loading, and final loading.

Reference Data Load Flow example showing representative containers from Group 1 and Group 2.

![Reference Data Load Flow](img/reference_data_load_flow.jpg)

#### Master Data Load Flow

| Group | Load container | Target table | Source table | Dependency | Execution behavior |
|---|---|---|---|---|---|
| Group 1 | `CreditCard Load` | `CreditCard` | `SALES_CREDITCARD` | None | Independent table load; can run in parallel |
| Group 1 | `Address Load` | `Address` | `PERSON_ADDRESS` | `StateProvince`, `AddressType` | Independent table load; can run in parallel after required reference data is available |
| Group 1 | `Person Load` | `Person` | `PERSON_PERSON` | None | Independent table load; can run in parallel |
| Group 1 | `Product Load` | `Product` | `PRODUCTION_PRODUCT` | `ProductCategory` | Independent table load; can run in parallel after required reference data is available |
| Group 2 | `SalesPerson Load` | `SalesPerson` | `SALES_SALESPERSON`, `HUMANRESOURCES_EMPLOYEE` | `Person`, `SalesTerritory` | Uses previously loaded `Person` data and extracted salesperson-related source data; validated and loaded after parent master and reference data |
| Group 2 | `Customer Load` | `Customer` | `SALES_CUSTOMER` | `Person`, `SalesTerritory` | Uses previously loaded `Person` data and extracted customer source data; validated and loaded after parent master and reference data |

Master validation focuses on entity completeness, duplicate source identifiers, parent reference existence, and source-to-target key mapping.

Independent master tables can be extracted and loaded in parallel once their required reference data is available. Dependent master entities such as `SalesPerson` and `Customer` are loaded afterward because they rely on previously loaded `Person` data and supporting reference values such as `SalesTerritory`.

Master Data Load Flow example showing independent and dependent master table loads.

![Master Data Load Flow](img/master_data_load_flow.jpg)

#### Transactional Data Load Flow

Transactional data is loaded after reference and master data because Sales transactions depend on previously loaded customer, salesperson, address, product, payment, shipping, currency, territory, and promotion data.

Transactional processing is executed by `yyyyMM` period using `SalesOrderHeader.OrderDate` as the batch driver.

Each batch includes:

- `SalesOrderHeader` records where `OrderDate` belongs to the selected period.
- Related `SalesOrderDetail` records for those headers.

In this design, header and detail records are extracted and processed together within the same batch because the batch period is defined at header level and detail rows depend on the related order header.

| Group | Load container | Target table | Source table | Dependency | Execution behavior |
|---|---|---|---|---|---|
| Group 1 | `Sales Load` | `SalesOrderHeader`, `SalesOrderDetail` | `SALES_SALESORDERHEADER` join `SALES_SALESORDERDETAIL` | `Customer`, `SalesPerson`, `Address`, `Product`, `CreditCard`, `CurrencyRate`, `ShipMethod`, `SalesTerritory`, `SpecialOffer` | Extracted and processed together within each `yyyyMM` batch; validation and final load preserve header-detail dependency |

Transactional validation focuses on parent relationships, duplicate transaction keys, date consistency, positive quantities and amounts, and amount calculation checks.

Reconciliation is performed at batch level using row counts, business keys, orphan checks, and financial totals.

Transactional Data Load Flow example.

<img src="img/transactional_data_load_flow.jpg" alt="Transactional Data Load Flow" height="1200"/>

### Sales_Analytics_Migration

| Package | Purpose |
|---|---|
| `PKG_ANALYTICS_MIGRATION` | Orchestrates analytical loads. |
| `PKG_DIMENSIONS` | Loads analytical dimensions. |
| `PKG_FACTS` | Loads analytical fact tables. |

#### Dimension Data Load Flow

Dimension tables are loaded from `Sales_Operational.prod` into `Sales_Analytics.dim`.

| Target table | Source table(s) from `Sales_Operational.prod` | Mapping rule | Execution behavior |
|---|---|---|---|
| `DimCustomer` | `Customer` | Builds a reporting customer dimension and excludes sensitive or unnecessary operational attributes. | Can run in parallel |
| `DimPaymentMethod` | `CreditCard` | Converts payment-related data into a reporting-safe payment method dimension. | Can run in parallel |
| `DimShipMethod` | `ShipMethod` | Maps shipping method attributes for reporting by fulfillment method. | Can run in parallel |
| `DimProduct` | `Product`, `ProductCategory` | Denormalizes product category attributes into the product dimension. | Can run in parallel |
| `DimSalesTerritory` | `CountryRegion`, `SalesTerritory` | Denormalizes country/region attributes into the sales territory dimension. | Can run in parallel |
| `DimSalesPerson` | `SalesPerson` | Builds the salesperson reporting dimension from curated operational salesperson data. | Can run in parallel |

Dimension validation focuses on unique business keys, required descriptive attributes, unknown/default member handling, and source-to-dimension key traceability.

Dimension Data Load Flow example.

![Dimension Data Load Flow](img/dim_data_load_flow.jpg)

#### Fact Data Load Flow

Fact tables are loaded after dimensions because `FactSales` depends on dimension surrogate keys from `DimCustomer`, `DimSalesPerson`, `DimProduct`, `DimSalesTerritory`, `DimPaymentMethod`, `DimShipMethod`, and `DimDate`.

`FactSales` is loaded by `yyyyMM` sales period to support batch-level execution, reconciliation, and reruns.

| Target table | Source table(s) from `Sales_Operational.prod` | Mapping rule | Execution behavior |
|---|---|---|---|
| `FactSales` | `SalesOrderHeader`, `SalesOrderDetail` | Combines header and detail data into a line-grain fact table. | Loaded by sales period; resolves dimension surrogate keys and validates measures before final load |

The fact load resolves dimension keys, loads sales line measures, converts analytical amounts to USD when required, and preserves source identifiers for traceability.

Fact validation focuses on missing dimension keys, duplicate fact business keys, date consistency, positive quantities and amounts, and line amount calculation checks.

Fact reconciliation is performed at batch level using row counts, business keys, orphan checks, and financial totals.

Fact Data Load Flow example.

<img src="img/fact_data_load_flow.jpg" alt="Fact Data Load Flow" height="1200"/>

## Rerun and Recovery Strategy

Rerun behavior is defined by table or batch (transactional/fact) and depends on the data type:

| Load type | Rerun strategy |
|---|---|
| Reference / Master | Table-level rerun using `MERGE` or UPSERT with source business keys. |
| Transactional | Batch-level delete and reload by `yyyyMM` period. |
| Analytical | Dimension/fact rerun from curated `Sales_Operational.prod`. |

### Standard Status Values

| Status | Meaning |
|---|---|
| `Pending` | Object is waiting to run. |
| `Running` | Object is currently executing. |
| `Success` | Object completed successfully. |
| `Failed` | Object failed due to technical or validation issue. |
| `Skipped` | Object was intentionally skipped. |
| `RerunRequired` | Object is marked for reprocessing. |

### Table-Level Rerun Rules

Table-level reruns are used for reference, master, and dimension loads.

A table may be included in a rerun when:

- It is active.
- It requires loading.
- The previous load failed.
- It is explicitly marked as rerun required.
- A parent dependency was reprocessed.

### Batch-Level Rerun Rules

Batch-level reruns are used for large transactional and fact loads.

A batch may be included in a rerun when:

- The batch failed.
- Reconciliation failed.
- The batch is explicitly marked as rerun required.
- The batch belongs to a selected recovery period.

## Assumptions and Scope Boundaries

- Migration is executed during an offline migration window.
- The target design modernizes the Sales domain instead of copying the source schema one-to-one.
- Analytical Sales amounts are standardized to USD.
- Continuous synchronization is out of scope.

## Security, Users, and Roles

Security separates business access, ETL execution, and administrative responsibilities.

### Design Rules

- Access follows the principle of least privilege.
- Business users do not have direct write access to technical schemas.
- ETL execution accounts use only the permissions required for extraction, processing, and loading.
- Access to `DataOps_Control` is limited to operational and technical roles.
- Technical schemas such as `staging`, `work`, and `control` are restricted to ETL and support processes.

### Role Categories

- Application access
- ETL execution
- Read-only reporting access
- Operational support
- Database administration

## Implementation Tooling

| Component | Tool |
|---|---|
| Source platform | Oracle XE 21c |
| Target platform | SQL Server 2022 |
| ETL tool | SQL Server Integration Services, SSIS |
| Development environment | Visual Studio 2026 |
| Target-side processing | Transact-SQL stored procedures |
| Job scheduling | SQL Server Agent |
