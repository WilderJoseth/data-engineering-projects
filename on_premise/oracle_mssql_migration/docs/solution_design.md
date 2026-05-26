# Solution Design

## Purpose

This document describes the technical design for the Sales domain migration and modernization solution.

## Data Source in Scope

The operational migration scope includes the Sales order process and the supporting entities like Customer, Address, Product, and SalesPerson.

### Technical Details

- The database engine is `Oracle XE 21c`.
- Source schema is `ADVENTUREWORKS2022`.
- Each source table name includes the domain as a prefix, for example `SALES_SALESORDERHEADER`.
- All table names follow a `SCREAMING_SNAKE_CASE` pattern.
- No transformation logic is applied directly in Oracle.

### Data Model Diagram

The source model shows the selected Sales-domain tables included in the modernization scope.

![Sales Domain Source Data Model](img/data_model_source.png)

| Data role | Source table | Purpose in migration |
|---|---|---|
| Transactional | `SALES_SALESORDERHEADER` | Preserves the main Sales order event. |
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
| Reference / Lookup | `PERSON_COUNTRYREGION` | Supports country/region grouping for geography. |
| Reference / Lookup | `SALES_CURRENCYRATE` | Provides currency context for order amounts. |
| Reference / Lookup | `SALES_CURRENCY` | Provides currency context for order amounts. |
| Reference / Lookup | `SALES_SALESTERRITORY` | Groups customers, salespeople, and orders by commercial territory. |
| Reference / Lookup | `SALES_SPECIALOFFER` | Preserves promotion or discount context applied to Sales lines. |
| Reference / Lookup | `PRODUCTION_PRODUCTSUBCATEGORY` | Provides the product classification level. |
| Bridge / Associative | `PERSON_BUSINESSENTITYADDRESS` | Maps business entities to addresses and address types in the source model. |
| Bridge / Associative | `SALES_SPECIALOFFERPRODUCT` | Provides source product-offer relationships. |

## Target Databases

The target solution uses three databases. Each database represents a different logical responsibility in the target architecture:

| Database | Responsibility |
|---|---|
| `Sales_Operational` | Normalized operational database for the migrated Sales domain. |
| `Sales_Analytics` | Analytical database for reporting and historical analysis. Follows a star schema design to simplify reporting and analytical queries. |
| `DataOps_Control` | Reusable technical control database for metadata, execution tracking, validation, reconciliation, error logging, batch control, and rerun support. |

### Technical details

- The target database engine is `SQL Server 2022`.
- `Sales_Operational` and `Sales_Analytics` are designed to run on the same SQL Server environment because they belong to the same Sales migration solution.
- `DataOps_Control` is designed as a reusable control database and may be deployed on a separate SQL Server environment to support multiple projects.
- The database names use descriptive names with underscores to improve readability.

## Schema Organization

The schema names follow a `lower_case` pattern.

### Sales_Operational

| Schema | Purpose |
|---|---|
| `prod` | Final operational business tables. |
| `staging` | Raw data extracted from Oracle before validation and transformation. |
| `work` | Intermediate validated/transformed data used during loads. |
| `control` | Database-specific helper objects used by ETL and integration with `DataOps_Control`. |

### Sales_Analytics

| Schema | Purpose |
|---|---|
| `dim` | Analytical dimensions. |
| `fact` | Analytical fact tables. |
| `staging` | Data extracted from `Sales_Operational` before analytical validation and transformation. |
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
- Source `PRODUCTION_PRODUCTSUBCATEGORY` values are loaded into target `ProductCategory`, simplifying the product hierarchy to one classification level.
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
- `FactSales` foreign keys should resolve to valid dimension rows. Missing, invalid, or not applicable source values are handled through default dimension members, such as `Unknown`, `Not Applicable`, or `Invalid`, rather than using `NULL` foreign keys.

| Data role | Target table |
|---|---|
| Fact | `FactSales` |
| Dimension | `DimDate`, `DimCustomer`, `DimSalesPerson`, `DimSalesTerritory`, `DimProduct`, `DimPaymentMethod`, `DimShipMethod` |

### DataOps_Control Data Model

![DataOps_Control Data Model](img/data_model_DataOps_Control.png)

`DataOps_Control` is implemented as a separate reusable SQL Server control database. The current framework version is maintained in the `on_premise/DataOps_Control` project and is consumed by this migration through metadata, runtime, observability, and reference schemas.

The model is organized into four responsibility-based schemas:

| Schema | Main tables | Purpose |
|---|---|---|
| `metadata` | `projects`, `project_databases`, `project_database_mappings`, `project_processes`, `project_tables`, `project_table_mappings`, `project_process_tables`, `project_process_table_batches`, `project_columns`, `project_table_batches` | Defines project registration, database mappings, process hierarchy, table inventory, source-to-target mappings, process-to-table execution scope, column metadata, and batch definitions. |
| `runtime` | `execution_runs`, `execution_steps` | Tracks project-level execution runs and process-level execution steps. |
| `observability` | `error_logs`, `validation_results`, `reconciliation_results` | Stores technical errors, validation summaries, and reconciliation metrics generated during execution. |
| `reference` | `status_codes`, `validation_codes` | Stores controlled status and validation code values used by runtime and observability records. |

#### Technical details

- `metadata.project_processes` supports parent-child hierarchy for ETL projects, packages, grouped loads, table-level loads, and batch-oriented loads.
- `runtime.execution_runs` represents one execution of the registered migration project.
- `runtime.execution_steps` represents one executed process within a run and links back to `metadata.project_processes`.
- `metadata.project_table_mappings` records source-to-target lineage, including Oracle-to-operational and operational-to-analytics mappings.
- `metadata.project_process_tables` defines which controlled target table is handled by each process.
- `metadata.project_table_batches` defines reusable source batch slices. For this project, transactional batches are monthly ranges based on `SALES_SALESORDERHEADER.OrderDate`.
- `metadata.project_process_table_batches` assigns batch definitions to a process-table execution scope.
- `observability.reconciliation_results` stores comparable metrics such as `ROW_COUNT`, `TOTAL_DUE`, or `SALES_AMOUNT` with a `reconciliation_side` such as `SOURCE`, `STAGING`, `WORK`, `TARGET`, or `FINAL`.
- `observability.validation_results` stores summary-level findings using controlled validation codes such as `NOT_NULL`, `DUPLICATE`, `FK_CHECK`, `DATA_TYPE`, `LENGTH_CHECK`, `DATE_RANGE`, `NEGATIVE_VALUE`, `RECON_WARNING`, and `INFO_CHECK`.

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

### Key and Identifier Column Guidelines

- Final business tables should use a SQL Server-generated `IDENTITY` column as the surrogate key.
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

- All tables should have a primary key constraint.
- Final business tables should use the surrogate key as the primary key.
- Avoid composite primary keys in final business tables unless there is a clear design reason.
- Foreign keys should be defined where they support target integrity and do not conflict with the migration/reload strategy.
- The name of the primary key should follow `pk_[schema]_[table]_[column]`.
- The name of the foreign key should follow `fk_[schema]_[table]_[column]`.

## Stored Procedure Implementation Pattern

SQL Server stored procedures handle database-side validation, transformation, final loading, reconciliation, and status updates.

### Stored Procedure Naming

Names should follow the following structure: `usp_[action]_[TableName]`. Exceptions may apply.

Common stored procedure prefixes include:

| Prefix | Purpose | Example |
|---|---|---|
| `usp_cleanup_` | Clean staging/work objects | `usp_cleanup_tables` |
| `usp_load_` | Load data into tables | `usp_load_AddressType` |
| `usp_validate_` | Validate staged or working data | `usp_validate_AddressType` |
| `usp_reconcile_` | Register reconciliation checks | `usp_reconcile_AddressType` |
| `usp_register_` | Register execution, step, log, or result metadata | `usp_register_reconciliation_result` |

### Final Load Procedure Pattern

Final load procedures should use the strategy appropriate to the load type.

| Load type | Final load strategy |
|---|---|
| Reference / master | `MERGE` or UPSERT using source business keys. |
| Transactional | Controlled delete and reload by batch period. |
| Dimension | `MERGE` or UPSERT for Type 1 dimensions unless otherwise defined. |
| Fact | Controlled delete and reload by batch period. |

### Reconciliation Procedure Pattern

Project-specific reconciliation procedures should register comparable metrics in `DataOps_Control.observability.reconciliation_results`. The control framework stores the evidence; the migration-specific procedure decides which metrics are meaningful and whether the execution step should end as `Success`, `Observed`, or `Failed`.

Common reconciliation checks include:

- Source-to-staging row counts.
- Work-to-final row counts.
- Financial totals for transactional and fact loads.
- Batch-level row counts and amount totals using a `reconciliation_key` such as `BATCH=2011-05`.

## SSIS Implementation Guidelines

### ETL and Data Movement

Data movement is implemented through two controlled flows:

| Flow | Pattern |
|---|---|
| Operational migration | `Oracle source -> Sales_Operational.staging -> Sales_Operational.work -> Sales_Operational.prod` |
| Analytical migration | `Sales_Operational.prod -> Sales_Analytics.staging -> Sales_Analytics.work -> Sales_Analytics.dim / Sales_Analytics.fact` |

### Load Rules

- Data is not loaded directly from Oracle into final business tables.
- Reference and master data are loaded before transactional data.
- Large transactional tables use batch-based processing by `SalesOrderHeader.OrderDate` period in `yyyyMM` format.
- Analytical loading uses `Sales_Operational.prod` as the curated source.
- Execution status is registered in `DataOps_Control.runtime`.
- Validation results, reconciliation results, and technical errors are published to `DataOps_Control.observability`.
- Table scope, batch scope, and source-to-target lineage are resolved from `DataOps_Control.metadata`.
- `staging`, `work`, and `control` tables are managed through controlled cleanup rules.

#### Common Table-Level Load Pattern

This pattern applies to reference, master, and dimension loads where records are processed at table level and final tables are loaded using `MERGE` or UPSERT logic.

1. Register the project run or package start with `DataOps_Control.runtime.usp_start_execution_run` when needed.
2. Register the process or table load start with `DataOps_Control.runtime.usp_start_execution_step`.
3. Identify active child processes and controlled tables using `DataOps_Control.metadata.ufn_list_project_process_tables`.
4. Clean the related `staging`, `work`, and local `control` tables.
5. Extract source data into `staging`.
6. Validate staged data using SQL Server stored procedures.
7. Publish validation summaries to `DataOps_Control.observability.validation_results`.
8. Load valid records into `work`.
9. Load final records using `MERGE` or UPSERT logic.
10. Publish reconciliation metrics to `DataOps_Control.observability.reconciliation_results`.
11. Decide the final process status based on technical errors, validation results, and reconciliation outcomes.
12. End the process step with `DataOps_Control.runtime.usp_end_execution_step`.

#### Common Batch-Level Load Pattern

This pattern applies to transactional and fact loads where data is processed by reloadable business periods instead of by full table.

1. Register the process or batch load start with `DataOps_Control.runtime.usp_start_execution_step`.
2. Identify active child processes, controlled target tables, source batch tables, and batch slices using `DataOps_Control.metadata.ufn_list_project_process_table_batches`.
3. Validate required reference and master data dependencies before processing the batch.
4. Clean the related `staging`, `work` and `control` tables.
5. Extract source data for the current batch into `staging`.
6. Validate staged data using SQL Server stored procedures.
7. Publish validation summaries to `DataOps_Control.observability.validation_results`.
9. Load valid records into `work`.
10. Delete existing final records for the current batch period.
11. Load final records for the current batch period.
12. Publish batch-scoped reconciliation metrics to `DataOps_Control.observability.reconciliation_results`.
13. Decide the final process status based on technical errors, validation results, and reconciliation outcomes.
14. End the process step with `DataOps_Control.runtime.usp_end_execution_step`.

### Database Communication Strategy

- Database communication is handled through SSIS data flows, connection managers, and staging tables.
- The solution does not rely on linked servers or direct cross-database querying. This keeps each database responsible for its own processing stages and avoids hidden dependencies between final business tables.

### Project Parameters

Common project-level parameters may include:

| Parameter | Purpose |
|---|---|
| `p_project_id` | Identifies the registered project in `DataOps_Control`. |
| `p_[db_name]_database` | Identifies the database name. |
| `p_[db_name]_server` | Identifies the server name. |
| `p_[db_name]_username` | Identifies the database user or service account. |
| `p_[db_name]_password` | Identifies the database password or secret reference. |

### Package Parameters

Common package-level parameters may include:

| Parameter | Purpose |
|---|---|
| `p_execution_run_id` | Identifies the current execution run. |
| `p_execution_step_id` | Identifies the current execution step. |
| `p_project_process_id` | Identifies the registered process being executed. |
| `p_project_table_id` | Identifies the controlled table being processed. |
| `p_batch_id` | Identifies the `DataOps_Control.metadata.project_table_batches` record being processed. |
| `p_batch_value` | Identifies the current batch value, such as `2011-05`, when batching is used. |

### Package Variables

Common variables may include:

| Variable | Purpose |
|---|---|
| `v_source_row_count` | Stores the number of rows extracted from the source or staging layer. |
| `v_target_row_count` | Stores the number of rows loaded into the target table. |
| `v_package_start_time` | Stores the package execution start time. |
| `v_package_end_time` | Stores the package execution end time. |

### Connection Managers

| Connection | Connection manager type | Purpose |
|---|---|---|
| Oracle source connection | Oracle Connection Manager / Oracle provider | Extracts Sales-domain source data from Oracle. |
| `Sales_Operational` target connection | OLE DB | Loads staging/work/final operational tables and executes SQL Server stored procedures. |
| `Sales_Analytics` target connection | OLE DB | Loads staging/work/dimension/fact tables and executes SQL Server stored procedures. |
| `DataOps_Control` connection | OLE DB | Registers execution metadata, validation results, reconciliation results, errors, and status updates. |

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

### Sales_Operational_Migration

| Package | Purpose |
|---|---|
| `PKG_OPERATIONAL_MIGRATION` | Orchestrates reference, master, and transactional packages. |
| `PKG_REFERENCE_DATA` | Loads reference data. |
| `PKG_MASTER_DATA` | Loads master/core entities. |
| `PKG_TRANSACTIONAL_DATA` | Loads Sales transactions by batch. |

#### Reference Data Load Flow

Reference data is loaded using the common table-level load pattern. Independent reference tables can be loaded separately, while related parent-child tables are handled through grouped load containers and controlled stored procedure sequences.

| Load container | Target table | Source table | Dependency | Execution behavior |
|---|---|---|---|---|
| `AddressType Load` | `AddressType` | `PERSON_ADDRESSTYPE` | None | Independent table load; can run in parallel. |
| `ProductCategory Load` | `ProductCategory` | `PRODUCTION_PRODUCTSUBCATEGORY` | None | Independent table load; can run in parallel. |
| `SpecialOffer Load` | `SpecialOffer` | `SALES_SPECIALOFFER` | None | Independent table load; can run in parallel. |
| `ShipMethod Load` | `ShipMethod` | `PURCHASING_SHIPMETHOD` | None | Independent table load; can run in parallel. |
| `Geography Load` | `CountryRegion` | `PERSON_COUNTRYREGION` | None | Loaded first within the geography sequence. |
| `Geography Load` | `SalesTerritory` | `SALES_SALESTERRITORY` | `CountryRegion` | Loaded after `CountryRegion`. |
| `Geography Load` | `StateProvince` | `PERSON_STATEPROVINCE` | `CountryRegion`, `SalesTerritory` | Loaded after `CountryRegion` and `StateProvince`. |
| `Currency Load` | `Currency` | `SALES_CURRENCY` | None | Loaded first within the currency sequence. |
| `Currency Load` | `CurrencyRate` | `SALES_CURRENCYRATE` | `Currency` | Loaded after `Currency`. |

The following diagram shows the reference data load flow.

![Reference Data Load Flow](img/data_processing_Sales_Operational_reference_data.png)

#### Master Data Load Flow

Master data is loaded using the common table-level load pattern. Independent master tables can be loaded once their required reference data is available.

| Load container | Target table | Source table | Dependency | Execution behavior |
|---|---|---|---|---|
| `CreditCard Load` | `CreditCard` | `SALES_CREDITCARD` | None | Independent table load; can run in parallel. |
| `Address Load` | `Address` | `PERSON_ADDRESS` | `StateProvince`, `AddressType` | Loaded after required reference data is available. |
| `Product Load` | `Product` | `PRODUCTION_PRODUCT` | `ProductCategory` | Loaded after required reference data is available. |
| `SalesPerson Load` | `SalesPerson` | `PERSON_PERSON`, `SALES_SALESPERSON`, `HUMANRESOURCES_EMPLOYEE` | `SalesTerritory` | Loaded after parent master and reference data. |
| `Customer Load` | `Customer` | `PERSON_PERSON`, `SALES_CUSTOMER` | `SalesTerritory` | Loaded after parent master and reference data. |

The following diagram shows the master data load flow.

![Master Data Load Flow](img/data_processing_Sales_Operational_master_data.png)

#### Transactional Data Load Flow

Transactional data is loaded after reference and master data because sales transactions depend on previously loaded customers, salespeople, addresses, products, payment methods, shipping methods, currencies, territories, and promotions.

Transactional processing uses the common batch-level load pattern. Batches are defined by `yyyyMM` period using `SalesOrderHeader.OrderDate` as the batch driver.

Each batch includes:

- `SalesOrderHeader` records where `OrderDate` belongs to the selected period.
- Related `SalesOrderDetail` records for those headers.

Header and detail records are extracted and processed together within the same batch because the batch period is defined at header level and detail rows depend on the related order header.

| Load container | Target table | Source table | Dependency | Execution behavior |
|---|---|---|---|---|
| `Sales Load` | `SalesOrderHeader`, `SalesOrderDetail` | `SALES_SALESORDERHEADER`, `SALES_SALESORDERDETAIL` | `Customer`, `SalesPerson`, `Address`, `Product`, `CreditCard`, `CurrencyRate`, `ShipMethod`, `SalesTerritory`, `SpecialOffer` | Processed together within each `yyyyMM` batch; final load uses delete-and-reload logic for the selected period. |

The following diagram shows the transactional data load flow.

![Transactional Data Load Flow](img/data_processing_Sales_Operational_transactional_data.png)

### Sales_Analytics_Migration

| Package | Purpose |
|---|---|
| `PKG_ANALYTICS_MIGRATION` | Orchestrates analytical loads. |
| `PKG_DIMENSIONS` | Loads analytical dimensions. |
| `PKG_FACTS` | Loads analytical fact tables. |

#### Dimension Data Load Flow

Dimension tables are loaded from `Sales_Operational.prod` into `Sales_Analytics.dim` using the common table-level load pattern. Most dimensions can be loaded independently because they are built from curated operational tables and do not depend on fact data.

| Target table | Source tables | Mapping rule |
|---|---|---|
| `DimCustomer` | `Customer` | Builds a reporting customer dimension and excludes sensitive or unnecessary operational attributes. |
| `DimPaymentMethod` | `CreditCard` | Converts payment-related data into a reporting-safe payment method dimension. |
| `DimShipMethod` | `ShipMethod` | Maps shipping method attributes for reporting by fulfillment method. |
| `DimProduct` | `Product`, `ProductCategory` | Denormalizes product category attributes into the product dimension. |
| `DimSalesTerritory` | `CountryRegion`, `SalesTerritory` | Denormalizes country/region attributes into the sales territory dimension. |
| `DimSalesPerson` | `SalesPerson` | Builds the salesperson reporting dimension from curated operational salesperson data. |

The following diagram shows the dimension data load flow.

![Dimension Data Load Flow](img/data_processing_Sales_Analytics_dim_data.png)

#### Fact Data Load Flow

Fact tables are loaded after dimensions because `FactSales` depends on dimension surrogate keys from `DimCustomer`, `DimSalesPerson`, `DimProduct`, `DimSalesTerritory`, `DimPaymentMethod`, `DimShipMethod`, and `DimDate`.

`FactSales` uses the common batch-level load pattern and is loaded by `yyyyMM` sales period to support batch-level execution, reconciliation, and reruns.

| Target table | Source tables | Mapping rule |
|---|---|---|
| `FactSales` | `SalesOrderHeader`, `SalesOrderDetail` | Combines header and detail data into a line-grain fact table. |

The following diagram shows the fact data load flow.

![Fact Data Load Flow](img/data_processing_Sales_Analytics_fact_data.png)

## Rerun and Recovery Strategy

Rerun and recovery behavior is metadata-driven. The framework uses `DataOps_Control` to identify which tables or batches are active, failed, incomplete, or explicitly marked for reprocessing.

### Standard Status Values

| Status | Meaning |
|---|---|
| `Pending` | Execution is registered but has not started. |
| `Running` | Execution is currently in progress. |
| `Success` | Execution completed and expected control checks passed. |
| `Observed` | Execution completed technically, but validation or reconciliation results require review. |
| `Failed` | Execution failed due to a technical error. |
| `Skipped` | Execution was intentionally skipped. |

### Table-Level Rerun Rules

A table may be included in a rerun when:

- It is active.
- Its execution metadata marks it as requiring execution.
- The previous process step failed or ended as observed.
- A parent dependency was reprocessed.
- The table is included in a selected recovery scope.

### Batch-Level Rerun Rules

A batch may be included in a rerun when:

- Its batch metadata marks it as requiring execution.
- Its previous process step failed or ended as observed.
- Reconciliation results require review or correction.
- The batch belongs to a selected recovery period.

## Assumptions and Scope Boundaries

- Migration is executed during an offline migration window.
- The target design modernizes the Sales domain instead of copying the source schema one-to-one.
- Analytical sales amounts are standardized to USD.
- Continuous synchronization is out of scope.

## Security, Users, and Roles

Security separates business access, ETL execution, operational support, and database administration responsibilities. Access follows the principle of least privilege.

### Design Rules

- Business users do not have direct write access to technical schemas.
- Technical schemas such as `staging`, `work`, and `control` are restricted to ETL and support processes.
- ETL execution accounts use only the permissions required for extraction, processing, loading, and publishing execution results.
- Access to `DataOps_Control` is limited to operational and technical roles.
- Administrative privileges are separated from normal ETL execution.

### Role Categories

| Role category | Access scope |
|---|---|
| Application access | Limited access to final operational tables when required by downstream applications. |
| ETL execution | Read/write access to `staging`, `work`, `control`, and required final target tables; execution rights on ETL stored procedures. |
| Read-only reporting access | Read access to `Sales_Analytics.dim` and `Sales_Analytics.fact`. |
| Operational support | Read access to execution logs, validation results, reconciliation results, and error details in `DataOps_Control`. |
| Database administration | Administrative access for deployment, maintenance, security management, and troubleshooting. |

## Implementation Tooling

| Component | Tool |
|---|---|
| Source platform | Oracle XE 21c |
| Target platform | SQL Server 2022 |
| ETL tool | SQL Server Integration Services, SSIS |
| Development environment | Visual Studio 2026 |
| Target-side processing | Transact-SQL stored procedures |
| Job scheduling | SQL Server Agent |
