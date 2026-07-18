/*============================================================================
  DataOps_Control
  Seed Script: Sales Domain Metadata

  Purpose:
  - Loads sample metadata for the Oracle to SQL Server Migration - Sales Domain.
  - Supports testing table load, grouped table load, and batch-oriented flows.

  Notes:
  - Metadata IDs are manually assigned to keep scripts predictable.
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
============================================================================*/

INSERT INTO [metadata].[project_processes]
(
    [id],
    [position],
    [name],
    [project_id],
    [parent_process_id]
)
VALUES
    -- Migration roots
    (1,  1, 'Sales_Operational_Migration', 1, NULL),
    (2,  2, 'Sales_Analytics_Migration',   1, NULL),

    -- Operational migration packages
    (3,  1, 'PKG_OPERATIONAL_MIGRATION', 1, 1),
    (4,  1, 'PKG_REFERENCE_DATA',        1, 3),
    (5,  2, 'PKG_MASTER_DATA',           1, 3),
    (6,  3, 'PKG_TRANSACTIONAL_DATA',    1, 3),

    -- Analytics migration packages
    (7,  1, 'PKG_ANALYTICS_MIGRATION', 1, 2),
    (8,  1, 'PKG_DIMENSIONS',          1, 7),
    (9,  2, 'PKG_FACTS',               1, 7),

    -- Reference data loads
    (10, 1, 'AddressType Load',      1, 4),
    (11, 2, 'ProductCategory Load',  1, 4),
    (12, 3, 'SpecialOffer Load',     1, 4),
    (13, 4, 'ShipMethod Load',       1, 4),
    (14, 5, 'Geography Load',        1, 4),
    (15, 6, 'Currency Load',         1, 4),

    -- Master data loads
    (16, 1, 'CreditCard Load',   1, 5),
    (17, 2, 'Address Load',      1, 5),
    (18, 3, 'Product Load',      1, 5),
    (19, 4, 'SalesPerson Load',  1, 5),
    (20, 5, 'Customer Load',     1, 5),

    -- Transactional data loads
    (21, 1, 'Sales Load',        1, 6),

    -- Dimension loads
    (22, 1, 'DimCustomer Load',        1, 8),
    (23, 2, 'DimPaymentMethod Load',   1, 8),
    (24, 3, 'DimShipMethod Load',      1, 8),
    (25, 4, 'DimProduct Load',         1, 8),
    (26, 5, 'DimSalesTerritory Load',  1, 8),
    (27, 6, 'DimSalesPerson Load',     1, 8),

    -- Fact loads
    (28, 1, 'FactSales Load', 1, 9);
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
