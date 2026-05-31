/*============================================================================
  DataOps_Control
  Seed Script: Sales Domain Metadata

  Purpose:
  - Loads sample metadata for the Oracle to SQL Server Migration - Sales Domain.
  - Supports testing table load, grouped table load, batch-oriented flows,
    process dependencies, and v2 process-action metadata.

  Notes:
  - Metadata IDs are manually assigned to keep scripts predictable.
  - Process IDs 3 and 7 are intentionally not used in v2 because the previous
    intermediate package layer was redundant.
  - This script assumes a clean database or empty metadata tables.
============================================================================*/

USE [DataOps_Control];
GO

/*============================================================================
  1. Project
============================================================================*/

INSERT INTO [metadata].[projects]
(
    [id],
    [name]
)
VALUES
    (1, 'Oracle to SQL Server Migration - Sales Domain');
GO

/*============================================================================
  2. Project Databases
============================================================================*/

INSERT INTO [metadata].[project_databases]
(
    [id],
    [name],
    [platform_type],
    [database_role],
    [project_id]
)
VALUES
    (1, 'ADVENTUREWORKS2022', 'Oracle XE 21c', 'Source', 1),
    (2, 'Sales_Operational', 'SQL Server 2022', 'Target', 1),
    (3, 'Sales_Analytics',   'SQL Server 2022', 'Target', 1);
GO

/*============================================================================
  3. Project Database Mappings
============================================================================*/

INSERT INTO [metadata].[project_database_mappings]
(
    [database_source_id],
    [database_target_id]
)
VALUES
    (1, 2), -- Oracle source -> Sales_Operational
    (2, 3); -- Sales_Operational -> Sales_Analytics
GO

/*============================================================================
  4. Project Processes

  Notes:
  - parent_process_id defines hierarchy/grouping.
  - Sales_Operational_Migration and Sales_Analytics_Migration are root
    orchestration processes.
  - Required execution order is defined separately in
    metadata.project_process_dependencies.
============================================================================*/

INSERT INTO [metadata].[project_processes]
(
    [id],
    [name],
    [project_id],
    [parent_process_id]
)
VALUES
    -- Migration roots
    (1,  'Sales_Operational_Migration', 1, NULL),
    (2,  'Sales_Analytics_Migration',   1, NULL),

    -- Operational migration process groups
    (4,  'PKG_REFERENCE_DATA',        1, 1),
    (5,  'PKG_MASTER_DATA',           1, 1),
    (6,  'PKG_TRANSACTIONAL_DATA',    1, 1),

    -- Analytics migration process groups
    (8,  'PKG_DIMENSIONS',          1, 2),
    (9,  'PKG_FACTS',               1, 2),

    -- Reference data loads
    (10, 'AddressType Load',      1, 4),
    (11, 'ProductCategory Load',  1, 4),
    (12, 'SpecialOffer Load',     1, 4),
    (13, 'ShipMethod Load',       1, 4),
    (14, 'Geography Load',        1, 4),
    (15, 'Currency Load',         1, 4),

    -- Master data loads
    (16, 'CreditCard Load',   1, 5),
    (17, 'Address Load',      1, 5),
    (18, 'Product Load',      1, 5),
    (19, 'SalesPerson Load',  1, 5),
    (20, 'Customer Load',     1, 5),

    -- Transactional data loads
    (21, 'Sales Load',        1, 6),

    -- Dimension loads
    (22, 'DimCustomer Load',        1, 8),
    (23, 'DimPaymentMethod Load',   1, 8),
    (24, 'DimShipMethod Load',      1, 8),
    (25, 'DimProduct Load',         1, 8),
    (26, 'DimSalesTerritory Load',  1, 8),
    (27, 'DimSalesPerson Load',     1, 8),

    -- Fact loads
    (28, 'FactSales Load', 1, 9);
GO

/*============================================================================
  4A. Project Process Dependencies

  Purpose:
  - Defines required execution dependencies between registered processes.
  - Supports same-parent, parent-level, and cross-parent dependency scenarios.

  Relationship direction:
  - project_process_id = process that depends on another process.
  - dependency_project_process_id = process that must complete first.

  Notes:
  - parent_process_id defines hierarchy/grouping only.
  - Dependencies define required execution order.
  - This table intentionally does not use position/display order.
  - Sales_Operational_Migration and Sales_Analytics_Migration are root
    orchestration processes; the previous intermediate package layer was removed
    because it was redundant.
============================================================================*/

INSERT INTO [metadata].[project_process_dependencies]
(
    [project_process_id],
    [dependency_project_process_id]
)
VALUES
    /*========================================================================
      Root and parent/group-level dependencies
    ========================================================================*/

    -- Analytics migration depends on completed operational migration.
    (2,  1), -- Sales_Analytics_Migration depends on Sales_Operational_Migration

    -- Operational process group sequence
    (5,  4), -- PKG_MASTER_DATA depends on PKG_REFERENCE_DATA
    (6,  5), -- PKG_TRANSACTIONAL_DATA depends on PKG_MASTER_DATA

    -- Analytics process group sequence
    (9,  8), -- PKG_FACTS depends on PKG_DIMENSIONS

    /*========================================================================
      Cross-parent and child-process dependencies
    ========================================================================*/

    -- Master data dependencies on reference data
    (17, 14), -- Address Load depends on Geography Load
    (18, 11), -- Product Load depends on ProductCategory Load
    (19, 14), -- SalesPerson Load depends on Geography Load
    (20, 14), -- Customer Load depends on Geography Load

    -- Transactional data dependencies
    (21, 12), -- Sales Load depends on SpecialOffer Load
    (21, 13), -- Sales Load depends on ShipMethod Load
    (21, 15), -- Sales Load depends on Currency Load
    (21, 16), -- Sales Load depends on CreditCard Load
    (21, 17), -- Sales Load depends on Address Load
    (21, 19), -- Sales Load depends on SalesPerson Load
    (21, 20), -- Sales Load depends on Customer Load

    -- Dimension dependencies
    (22, 20), -- DimCustomer Load depends on Customer Load
    (23, 16), -- DimPaymentMethod Load depends on CreditCard Load
    (24, 13), -- DimShipMethod Load depends on ShipMethod Load
    (25, 11), -- DimProduct Load depends on ProductCategory Load
    (25, 18), -- DimProduct Load depends on Product Load
    (26, 14), -- DimSalesTerritory Load depends on Geography Load
    (27, 19), -- DimSalesPerson Load depends on SalesPerson Load

    -- Fact dependencies
    (28, 21), -- FactSales Load depends on Sales Load
    (28, 22), -- FactSales Load depends on DimCustomer Load
    (28, 23), -- FactSales Load depends on DimPaymentMethod Load
    (28, 24), -- FactSales Load depends on DimShipMethod Load
    (28, 25), -- FactSales Load depends on DimProduct Load
    (28, 26), -- FactSales Load depends on DimSalesTerritory Load
    (28, 27); -- FactSales Load depends on DimSalesPerson Load
GO

/*============================================================================
  5. Project Tables

  Notes:
  - Source tables belong to the Oracle source database.
  - Operational target tables belong to Sales_Operational.
  - Analytical target tables belong to Sales_Analytics.
============================================================================*/

INSERT INTO [metadata].[project_tables]
(
    [id],
    [schema_name],
    [name],
    [is_fact_table],
    [is_transactional_table],
    [batch_column_active],
    [database_id]
)
VALUES
    -- Oracle source reference / lookup tables
    (1,  'ADVENTUREWORKS2022', 'PERSON_ADDRESSTYPE',              0, 0, 0, 1),
    (2,  'ADVENTUREWORKS2022', 'PRODUCTION_PRODUCTSUBCATEGORY',   0, 0, 0, 1),
    (3,  'ADVENTUREWORKS2022', 'SALES_SPECIALOFFER',              0, 0, 0, 1),
    (4,  'ADVENTUREWORKS2022', 'PURCHASING_SHIPMETHOD',           0, 0, 0, 1),
    (5,  'ADVENTUREWORKS2022', 'PERSON_COUNTRYREGION',            0, 0, 0, 1),
    (6,  'ADVENTUREWORKS2022', 'PERSON_STATEPROVINCE',            0, 0, 0, 1),
    (7,  'ADVENTUREWORKS2022', 'SALES_SALESTERRITORY',            0, 0, 0, 1),
    (8,  'ADVENTUREWORKS2022', 'SALES_CURRENCY',                  0, 0, 0, 1),
    (9,  'ADVENTUREWORKS2022', 'SALES_CURRENCYRATE',              0, 0, 0, 1),

    -- Oracle source master / core tables
    (10, 'ADVENTUREWORKS2022', 'SALES_CREDITCARD',                0, 0, 0, 1),
    (11, 'ADVENTUREWORKS2022', 'PERSON_ADDRESS',                  0, 0, 0, 1),
    (12, 'ADVENTUREWORKS2022', 'PRODUCTION_PRODUCT',              0, 0, 0, 1),
    (13, 'ADVENTUREWORKS2022', 'PERSON_PERSON',                   0, 0, 0, 1),
    (14, 'ADVENTUREWORKS2022', 'SALES_SALESPERSON',               0, 0, 0, 1),
    (15, 'ADVENTUREWORKS2022', 'HUMANRESOURCES_EMPLOYEE',         0, 0, 0, 1),
    (16, 'ADVENTUREWORKS2022', 'SALES_CUSTOMER',                  0, 0, 0, 1),

    -- Oracle source transactional tables
    (17, 'ADVENTUREWORKS2022', 'SALES_SALESORDERHEADER',          0, 1, 0, 1),
    (18, 'ADVENTUREWORKS2022', 'SALES_SALESORDERDETAIL',          0, 1, 0, 1),

    -- Sales_Operational reference / lookup target tables
    (19, 'prod', 'AddressType',       0, 0, 0, 2),
    (20, 'prod', 'ProductCategory',   0, 0, 0, 2),
    (21, 'prod', 'SpecialOffer',      0, 0, 0, 2),
    (22, 'prod', 'ShipMethod',        0, 0, 0, 2),
    (23, 'prod', 'CountryRegion',     0, 0, 0, 2),
    (24, 'prod', 'StateProvince',     0, 0, 0, 2),
    (25, 'prod', 'SalesTerritory',    0, 0, 0, 2),
    (26, 'prod', 'Currency',          0, 0, 0, 2),
    (27, 'prod', 'CurrencyRate',      0, 0, 0, 2),

    -- Sales_Operational master / core target tables
    (28, 'prod', 'CreditCard',        0, 0, 0, 2),
    (29, 'prod', 'Address',           0, 0, 0, 2),
    (30, 'prod', 'Product',           0, 0, 0, 2),
    (31, 'prod', 'SalesPerson',       0, 0, 0, 2),
    (32, 'prod', 'Customer',          0, 0, 0, 2),

    -- Sales_Operational transactional target tables
    (33, 'prod', 'SalesOrderHeader',  0, 1, 1, 2),
    (34, 'prod', 'SalesOrderDetail',  0, 1, 1, 2),

    -- Sales_Analytics dimension tables
    (35, 'dim', 'DimCustomer',        0, 0, 0, 3),
    (36, 'dim', 'DimPaymentMethod',   0, 0, 0, 3),
    (37, 'dim', 'DimShipMethod',      0, 0, 0, 3),
    (38, 'dim', 'DimProduct',         0, 0, 0, 3),
    (39, 'dim', 'DimSalesTerritory',  0, 0, 0, 3),
    (40, 'dim', 'DimSalesPerson',     0, 0, 0, 3),

    -- Sales_Analytics fact table
    (41, 'fact', 'FactSales',         1, 0, 1, 3);
GO

/*============================================================================
  6. Source-to-Target Table Mappings

  Notes:
  - These mappings represent lineage and data movement.
  - Some target tables can be produced from multiple source tables.
============================================================================*/

INSERT INTO [metadata].[project_table_mappings]
(
    [table_source_id],
    [table_target_id]
)
VALUES
    -- Oracle -> Sales_Operational reference / lookup mappings
    (1,  19), -- PERSON_ADDRESSTYPE            -> AddressType
    (2,  20), -- PRODUCTION_PRODUCTSUBCATEGORY -> ProductCategory
    (3,  21), -- SALES_SPECIALOFFER            -> SpecialOffer
    (4,  22), -- PURCHASING_SHIPMETHOD         -> ShipMethod
    (5,  23), -- PERSON_COUNTRYREGION          -> CountryRegion
    (6,  24), -- PERSON_STATEPROVINCE          -> StateProvince
    (7,  25), -- SALES_SALESTERRITORY          -> SalesTerritory
    (8,  26), -- SALES_CURRENCY                -> Currency
    (9,  27), -- SALES_CURRENCYRATE            -> CurrencyRate

    -- Oracle -> Sales_Operational master / core mappings
    (10, 28), -- SALES_CREDITCARD        -> CreditCard
    (11, 29), -- PERSON_ADDRESS          -> Address
    (12, 30), -- PRODUCTION_PRODUCT      -> Product
    (13, 31), -- PERSON_PERSON           -> SalesPerson
    (14, 31), -- SALES_SALESPERSON       -> SalesPerson
    (15, 31), -- HUMANRESOURCES_EMPLOYEE -> SalesPerson
    (16, 32), -- SALES_CUSTOMER          -> Customer
    (13, 32), -- PERSON_PERSON           -> Customer

    -- Oracle -> Sales_Operational transactional mappings
    (17, 33), -- SALES_SALESORDERHEADER -> SalesOrderHeader
    (18, 34), -- SALES_SALESORDERDETAIL -> SalesOrderDetail

    -- Sales_Operational -> Sales_Analytics dimension mappings
    (32, 35), -- Customer        -> DimCustomer
    (28, 36), -- CreditCard      -> DimPaymentMethod
    (22, 37), -- ShipMethod      -> DimShipMethod
    (30, 38), -- Product         -> DimProduct
    (20, 38), -- ProductCategory -> DimProduct
    (23, 39), -- CountryRegion   -> DimSalesTerritory
    (25, 39), -- SalesTerritory  -> DimSalesTerritory
    (31, 40), -- SalesPerson     -> DimSalesPerson

    -- Sales_Operational -> Sales_Analytics fact mappings
    (33, 41), -- SalesOrderHeader -> FactSales
    (34, 41); -- SalesOrderDetail -> FactSales
GO

/*============================================================================
  7. Process-to-Table Execution Scope

  Notes:
  - This mapping defines which controlled table is handled by each process.
  - Grouped processes can map to more than one table when the group is executed
    as one orchestration container.
============================================================================*/

INSERT INTO [metadata].[project_process_tables]
(
    [process_id],
    [table_id]
)
VALUES
    -- Reference data process scope
    (10, 19), -- AddressType Load     -> AddressType
    (11, 20), -- ProductCategory Load -> ProductCategory
    (12, 21), -- SpecialOffer Load    -> SpecialOffer
    (13, 22), -- ShipMethod Load      -> ShipMethod
    (14, 23), -- Geography Load       -> CountryRegion
    (14, 24), -- Geography Load       -> StateProvince
    (14, 25), -- Geography Load       -> SalesTerritory
    (15, 26), -- Currency Load        -> Currency
    (15, 27), -- Currency Load        -> CurrencyRate

    -- Master data process scope
    (16, 28), -- CreditCard Load  -> CreditCard
    (17, 29), -- Address Load     -> Address
    (18, 30), -- Product Load     -> Product
    (19, 31), -- SalesPerson Load -> SalesPerson
    (20, 32), -- Customer Load    -> Customer

    -- Transactional process scope
    -- This first version tests the batch flow only for SalesOrderHeader.
    (21, 33), -- Sales Load -> SalesOrderHeader

    -- Analytics dimension process scope
    (22, 35), -- DimCustomer Load       -> DimCustomer
    (23, 36), -- DimPaymentMethod Load  -> DimPaymentMethod
    (24, 37), -- DimShipMethod Load     -> DimShipMethod
    (25, 38), -- DimProduct Load        -> DimProduct
    (26, 39), -- DimSalesTerritory Load -> DimSalesTerritory
    (27, 40), -- DimSalesPerson Load    -> DimSalesPerson

    -- Analytics fact process scope
    (28, 41); -- FactSales Load -> FactSales
GO

/*============================================================================
  8. Batch Metadata

  Purpose:
  - Defines sample batch slices for batch-based transactional processing.
  - Batch definitions reference the source table used for filtering.
  - The process-table batch execution scope is defined separately in
    metadata.project_process_table_batches.

  Example:
  - Batch source table: ADVENTUREWORKS2022.SALES_SALESORDERHEADER
  - Batch column: OrderDate
  - Controlled target table in this first batch-flow test:
      - Sales_Operational.prod.SalesOrderHeader
============================================================================*/

-- Mark the source transactional table as batch-enabled because the batch filter
-- is applied against this source table.
UPDATE [metadata].[project_tables]
SET [batch_column_active] = 1
WHERE [id] = 17; -- SALES_SALESORDERHEADER

INSERT INTO [metadata].[project_table_batches]
(
    [id],
    [position],
    [batch_column_name],
    [batch_value],
    [batch_start_value],
    [batch_end_value],
    [batch_column_type],
    [execution_required],
    [batch_source_table_id]
)
VALUES
    (1, 1, 'OrderDate', '2011-05', '2011-05-01 00:00:00', '2011-05-31 23:59:59', 'DATETIME', 1, 17),
    (2, 2, 'OrderDate', '2011-06', '2011-06-01 00:00:00', '2011-06-30 23:59:59', 'DATETIME', 1, 17),
    (3, 3, 'OrderDate', '2011-07', '2011-07-01 00:00:00', '2011-07-31 23:59:59', 'DATETIME', 0, 17),
    (4, 4, 'OrderDate', '2011-08', '2011-08-01 00:00:00', '2011-08-31 23:59:59', 'DATETIME', 0, 17),
    (5, 5, 'OrderDate', '2011-09', '2011-09-01 00:00:00', '2011-09-30 23:59:59', 'DATETIME', 0, 17);
GO

/*============================================================================
  9. Process-Table Batch Execution Scope

  Purpose:
  - Assigns batch definitions to a valid process-table execution scope.
  - Supports batch-oriented orchestration using the same pattern as
    metadata.project_process_tables.

  Notes:
  - The first batch-flow implementation tests Sales Load for SalesOrderHeader only.
  - The batch filter is based on SALES_SALESORDERHEADER.OrderDate.
  - SalesOrderDetail is intentionally not assigned to the batch scope in this
    version to keep the initial batch-flow test focused and unambiguous.
  - metadata.project_table_batches.execution_required determines which assigned
    batches currently require execution.
============================================================================*/

INSERT INTO [metadata].[project_process_table_batches]
(
    [process_id],
    [table_id],
    [batch_id]
)
VALUES
    -- Sales Load -> SalesOrderHeader, controlled by SALES_SALESORDERHEADER monthly batches
    (21, 33, 1),
    (21, 33, 2),
    (21, 33, 3),
    (21, 33, 4),
    (21, 33, 5);
GO
/*============================================================================
  10. Process Actions

  Purpose:
  - Defines ordered executable actions for each registered process.
  - Supports the v2 process-based orchestration pattern:
      parent process -> child process loop -> ordered process actions.

  Notes:
  - metadata.project_process_tables remains the source of truth for the
    controlled table scope of each process.
  - metadata.project_process_actions defines the technical actions executed
    inside the process.
  - execution_database_id identifies where the executable object is located.
  - parameter_template stores a lightweight placeholder pattern for runtime
    parameters. It does not store real parameter values.
  - The executable objects listed here are metadata examples used to test
    action lookup. They do not need to exist unless an ETL pipeline attempts
    to execute them dynamically.

  execution_database_id:
  - 2 = Sales_Operational
  - 3 = Sales_Analytics
============================================================================*/

INSERT INTO [metadata].[project_process_actions]
(
    [id],
    [project_process_id],
    [position],
    [action_name],
    [action_type],
    [execution_database_id],
    [schema_name],
    [object_name],
    [parameter_template],
    [is_required]
)
VALUES
    /*========================================================================
      Reference Data Loads - Sales_Operational
    ========================================================================*/

    -- AddressType Load -> AddressType
    (1001, 10, 1, 'Load staging table', 'STORED_PROCEDURE', 2, 'staging', 'usp_load_address_type_staging', '?, ?', 1),
    (1002, 10, 2, 'Validate and load work table', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_load_address_type_work', '?, ?', 1),
    (1003, 10, 3, 'Register reconciliation results', 'STORED_PROCEDURE', 2, 'control', 'usp_reconcile_address_type', '?, ?', 1),
    (1004, 10, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_address_type', '?, ?', 1),

    -- ProductCategory Load -> ProductCategory
    (1011, 11, 1, 'Load staging table', 'STORED_PROCEDURE', 2, 'staging', 'usp_load_product_category_staging', '?, ?', 1),
    (1012, 11, 2, 'Validate and load work table', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_load_product_category_work', '?, ?', 1),
    (1013, 11, 3, 'Register reconciliation results', 'STORED_PROCEDURE', 2, 'control', 'usp_reconcile_product_category', '?, ?', 1),
    (1014, 11, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_product_category', '?, ?', 1),

    -- SpecialOffer Load -> SpecialOffer
    (1021, 12, 1, 'Load staging table', 'STORED_PROCEDURE', 2, 'staging', 'usp_load_special_offer_staging', '?, ?', 1),
    (1022, 12, 2, 'Validate and load work table', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_load_special_offer_work', '?, ?', 1),
    (1023, 12, 3, 'Register reconciliation results', 'STORED_PROCEDURE', 2, 'control', 'usp_reconcile_special_offer', '?, ?', 1),
    (1024, 12, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_special_offer', '?, ?', 1),

    -- ShipMethod Load -> ShipMethod
    (1031, 13, 1, 'Load staging table', 'STORED_PROCEDURE', 2, 'staging', 'usp_load_ship_method_staging', '?, ?', 1),
    (1032, 13, 2, 'Validate and load work table', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_load_ship_method_work', '?, ?', 1),
    (1033, 13, 3, 'Register reconciliation results', 'STORED_PROCEDURE', 2, 'control', 'usp_reconcile_ship_method', '?, ?', 1),
    (1034, 13, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_ship_method', '?, ?', 1),

    -- Geography Load -> CountryRegion, StateProvince, SalesTerritory
    -- Grouped process: one process step, multiple internal ordered actions.
    (1041, 14, 1, 'Load CountryRegion', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_country_region', '?, ?', 1),
    (1042, 14, 2, 'Load StateProvince', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_state_province', '?, ?', 1),
    (1043, 14, 3, 'Load SalesTerritory', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_sales_territory', '?, ?', 1),
    (1044, 14, 4, 'Register geography reconciliation', 'STORED_PROCEDURE', 2, 'control', 'usp_reconcile_geography', '?, ?', 1),

    -- Currency Load -> Currency, CurrencyRate
    -- Grouped process: one process step, multiple internal ordered actions.
    (1051, 15, 1, 'Load Currency', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_currency', '?, ?', 1),
    (1052, 15, 2, 'Load CurrencyRate', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_currency_rate', '?, ?', 1),
    (1053, 15, 3, 'Register currency reconciliation', 'STORED_PROCEDURE', 2, 'control', 'usp_reconcile_currency', '?, ?', 1),

    /*========================================================================
      Master Data Loads - Sales_Operational
    ========================================================================*/

    -- CreditCard Load -> CreditCard
    (1061, 16, 1, 'Load staging table', 'STORED_PROCEDURE', 2, 'staging', 'usp_load_credit_card_staging', '?, ?', 1),
    (1062, 16, 2, 'Validate and load work table', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_load_credit_card_work', '?, ?', 1),
    (1063, 16, 3, 'Register reconciliation results', 'STORED_PROCEDURE', 2, 'control', 'usp_reconcile_credit_card', '?, ?', 1),
    (1064, 16, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_credit_card', '?, ?', 1),

    -- Address Load -> Address
    (1071, 17, 1, 'Load staging table', 'STORED_PROCEDURE', 2, 'staging', 'usp_load_address_staging', '?, ?', 1),
    (1072, 17, 2, 'Validate and load work table', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_load_address_work', '?, ?', 1),
    (1073, 17, 3, 'Register reconciliation results', 'STORED_PROCEDURE', 2, 'control', 'usp_reconcile_address', '?, ?', 1),
    (1074, 17, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_address', '?, ?', 1),

    -- Product Load -> Product
    (1081, 18, 1, 'Load staging table', 'STORED_PROCEDURE', 2, 'staging', 'usp_load_product_staging', '?, ?', 1),
    (1082, 18, 2, 'Validate and load work table', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_load_product_work', '?, ?', 1),
    (1083, 18, 3, 'Register reconciliation results', 'STORED_PROCEDURE', 2, 'control', 'usp_reconcile_product', '?, ?', 1),
    (1084, 18, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_product', '?, ?', 1),

    -- SalesPerson Load -> SalesPerson
    (1091, 19, 1, 'Load staging tables', 'STORED_PROCEDURE', 2, 'staging', 'usp_load_sales_person_staging', '?, ?', 1),
    (1092, 19, 2, 'Validate and load work table', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_load_sales_person_work', '?, ?', 1),
    (1093, 19, 3, 'Register reconciliation results', 'STORED_PROCEDURE', 2, 'control', 'usp_reconcile_sales_person', '?, ?', 1),
    (1094, 19, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_sales_person', '?, ?', 1),

    -- Customer Load -> Customer
    (1101, 20, 1, 'Load staging tables', 'STORED_PROCEDURE', 2, 'staging', 'usp_load_customer_staging', '?, ?', 1),
    (1102, 20, 2, 'Validate and load work table', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_load_customer_work', '?, ?', 1),
    (1103, 20, 3, 'Register reconciliation results', 'STORED_PROCEDURE', 2, 'control', 'usp_reconcile_customer', '?, ?', 1),
    (1104, 20, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_customer', '?, ?', 1),

    /*========================================================================
      Transactional Data Loads - Sales_Operational
    ========================================================================*/

    -- Sales Load -> SalesOrderHeader
    -- Batch-specific filtering remains resolved through project_process_table_batches.
    (1111, 21, 1, 'Load batch staging table', 'STORED_PROCEDURE', 2, 'staging', 'usp_load_sales_order_header_batch_staging', '?, ?, ?', 1),
    (1112, 21, 2, 'Validate and load batch work table', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_load_sales_order_header_batch_work', '?, ?, ?', 1),
    (1113, 21, 3, 'Register batch reconciliation results', 'STORED_PROCEDURE', 2, 'control', 'usp_reconcile_sales_order_header_batch', '?, ?, ?', 1),
    (1114, 21, 4, 'Load batch final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_sales_order_header_batch', '?, ?, ?', 1),

    /*========================================================================
      Dimension Loads - Sales_Analytics
    ========================================================================*/

    -- DimCustomer Load -> DimCustomer
    (1121, 22, 1, 'Load dimension staging table', 'STORED_PROCEDURE', 3, 'staging', 'usp_load_dim_customer_staging', '?, ?', 1),
    (1122, 22, 2, 'Validate and load dimension work table', 'STORED_PROCEDURE', 3, 'work', 'usp_validate_load_dim_customer_work', '?, ?', 1),
    (1123, 22, 3, 'Register dimension reconciliation', 'STORED_PROCEDURE', 3, 'control', 'usp_reconcile_dim_customer', '?, ?', 1),
    (1124, 22, 4, 'Load dimension table', 'STORED_PROCEDURE', 3, 'dim', 'usp_load_dim_customer', '?, ?', 1),

    -- DimPaymentMethod Load -> DimPaymentMethod
    (1131, 23, 1, 'Load dimension staging table', 'STORED_PROCEDURE', 3, 'staging', 'usp_load_dim_payment_method_staging', '?, ?', 1),
    (1132, 23, 2, 'Validate and load dimension work table', 'STORED_PROCEDURE', 3, 'work', 'usp_validate_load_dim_payment_method_work', '?, ?', 1),
    (1133, 23, 3, 'Register dimension reconciliation', 'STORED_PROCEDURE', 3, 'control', 'usp_reconcile_dim_payment_method', '?, ?', 1),
    (1134, 23, 4, 'Load dimension table', 'STORED_PROCEDURE', 3, 'dim', 'usp_load_dim_payment_method', '?, ?', 1),

    -- DimShipMethod Load -> DimShipMethod
    (1141, 24, 1, 'Load dimension staging table', 'STORED_PROCEDURE', 3, 'staging', 'usp_load_dim_ship_method_staging', '?, ?', 1),
    (1142, 24, 2, 'Validate and load dimension work table', 'STORED_PROCEDURE', 3, 'work', 'usp_validate_load_dim_ship_method_work', '?, ?', 1),
    (1143, 24, 3, 'Register dimension reconciliation', 'STORED_PROCEDURE', 3, 'control', 'usp_reconcile_dim_ship_method', '?, ?', 1),
    (1144, 24, 4, 'Load dimension table', 'STORED_PROCEDURE', 3, 'dim', 'usp_load_dim_ship_method', '?, ?', 1),

    -- DimProduct Load -> DimProduct
    (1151, 25, 1, 'Load dimension staging table', 'STORED_PROCEDURE', 3, 'staging', 'usp_load_dim_product_staging', '?, ?', 1),
    (1152, 25, 2, 'Validate and load dimension work table', 'STORED_PROCEDURE', 3, 'work', 'usp_validate_load_dim_product_work', '?, ?', 1),
    (1153, 25, 3, 'Register dimension reconciliation', 'STORED_PROCEDURE', 3, 'control', 'usp_reconcile_dim_product', '?, ?', 1),
    (1154, 25, 4, 'Load dimension table', 'STORED_PROCEDURE', 3, 'dim', 'usp_load_dim_product', '?, ?', 1),

    -- DimSalesTerritory Load -> DimSalesTerritory
    (1161, 26, 1, 'Load dimension staging table', 'STORED_PROCEDURE', 3, 'staging', 'usp_load_dim_sales_territory_staging', '?, ?', 1),
    (1162, 26, 2, 'Validate and load dimension work table', 'STORED_PROCEDURE', 3, 'work', 'usp_validate_load_dim_sales_territory_work', '?, ?', 1),
    (1163, 26, 3, 'Register dimension reconciliation', 'STORED_PROCEDURE', 3, 'control', 'usp_reconcile_dim_sales_territory', '?, ?', 1),
    (1164, 26, 4, 'Load dimension table', 'STORED_PROCEDURE', 3, 'dim', 'usp_load_dim_sales_territory', '?, ?', 1),

    -- DimSalesPerson Load -> DimSalesPerson
    (1171, 27, 1, 'Load dimension staging table', 'STORED_PROCEDURE', 3, 'staging', 'usp_load_dim_sales_person_staging', '?, ?', 1),
    (1172, 27, 2, 'Validate and load dimension work table', 'STORED_PROCEDURE', 3, 'work', 'usp_validate_load_dim_sales_person_work', '?, ?', 1),
    (1173, 27, 3, 'Register dimension reconciliation', 'STORED_PROCEDURE', 3, 'control', 'usp_reconcile_dim_sales_person', '?, ?', 1),
    (1174, 27, 4, 'Load dimension table', 'STORED_PROCEDURE', 3, 'dim', 'usp_load_dim_sales_person', '?, ?', 1),

    /*========================================================================
      Fact Loads - Sales_Analytics
    ========================================================================*/

    -- FactSales Load -> FactSales
    (1181, 28, 1, 'Load fact staging table', 'STORED_PROCEDURE', 3, 'staging', 'usp_load_fact_sales_staging', '?, ?', 1),
    (1182, 28, 2, 'Validate and load fact work table', 'STORED_PROCEDURE', 3, 'work', 'usp_validate_load_fact_sales_work', '?, ?', 1),
    (1183, 28, 3, 'Register fact reconciliation', 'STORED_PROCEDURE', 3, 'control', 'usp_reconcile_fact_sales', '?, ?', 1),
    (1184, 28, 4, 'Load fact table', 'STORED_PROCEDURE', 3, 'fact', 'usp_load_fact_sales', '?, ?', 1);
GO

