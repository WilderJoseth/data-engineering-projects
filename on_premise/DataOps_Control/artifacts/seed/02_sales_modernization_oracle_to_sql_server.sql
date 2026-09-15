/*============================================================================
  DataOps_Control
  Seed Script: Sales Domain Metadata

  Purpose:
  - Loads sample metadata for the Oracle to SQL Server Migration - Sales Domain.
  - Supports testing object load, grouped object load, and batch-oriented flows.

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
    (1, 'ADVENTUREWORKS2022', 'ORACLE XE 21C', 'SOURCE', 1),
    (2, 'Sales_Operational', 'SQL SERVER 2022', 'TARGET', 1),
    (3, 'Sales_Analytics',   'SQL SERVER 2022', 'TARGET', 1);
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
    [name],
    [project_id],
    [parent_process_id],
    [load_strategy],
    [is_execution_required]
)
VALUES
    -- Migration roots
    (1,  'Sales_Operational Migration', 1, NULL, NULL, 1),
    (2,  'Sales_Analytics Migration',   1, NULL, NULL, 1),

    -- Operational migration packages
    (4,  'Reference Data Load',        1, 1, NULL, 1),
    (5,  'Master Data Load',           1, 1, NULL, 1),
    (6,  'Transactional Data Load',    1, 1, NULL, 1),

    -- Analytics migration packages
    (8,  'Dimensions Load',          1, 2, NULL, 1),
    (9,  'Facts Load',               1, 2, NULL, 1),

    -- Reference data loads
    (10, 'AddressType Load',      1, 4, 'FULL', 1),
    (11, 'ProductCategory Load',  1, 4, 'FULL', 1),
    (12, 'SpecialOffer Load',     1, 4, 'FULL', 1),
    (13, 'ShipMethod Load',       1, 4, 'FULL', 1),
    (14, 'Geography Load',        1, 4, NULL, 1),
    (15, 'Currency Load',         1, 4, 'FULL', 1),
    (68, 'Load CountryRegion',    1, 14, 'FULL', 1),
    (69, 'Load StateProvince',    1, 14, 'FULL', 1),
    (70, 'Load SalesTerritory',   1, 14, 'FULL', 1),

    -- Master data loads
    (16, 'CreditCard Load',   1, 5, 'FULL', 1),
    (17, 'Address Load',      1, 5, 'FULL', 1),
    (18, 'Product Load',      1, 5, 'FULL', 1),
    (19, 'SalesPerson Load',  1, 5, 'FULL', 1),
    (20, 'Customer Load',     1, 5, 'FULL', 1),

    -- Transactional data loads
    (21, 'Sales Load',        1, 6, 'BATCH', 1),

    -- Dimension loads
    (22, 'DimCustomer Load',        1, 8, 'FULL', 1),
    (23, 'DimPaymentMethod Load',   1, 8, 'FULL', 1),
    (24, 'DimShipMethod Load',      1, 8, 'FULL', 1),
    (25, 'DimProduct Load',         1, 8, 'FULL', 1),
    (26, 'DimSalesTerritory Load',  1, 8, 'FULL', 1),
    (27, 'DimSalesPerson Load',     1, 8, 'FULL', 1),
    (71, 'DimDate Load',            1, 8, 'FULL', 1),

    -- Fact loads
    (28, 'FactSales Load', 1, 9, 'FULL', 1);
GO

/*============================================================================
  5. Project Process Dependencies

  Notes:
  - Dependencies represent execution-order requirements between orchestration
    processes.
  - Parent/group dependencies are included only where they express a real
    migration-stage prerequisite.
============================================================================*/

INSERT INTO [metadata].[project_process_dependencies]
(
    [project_process_id],
    [dependency_project_process_id]
)
VALUES
    -- Migration-level dependencies
    (2,  1), -- Sales_Analytics Migration depends on Sales_Operational Migration

    -- Operational migration package dependencies
    (5,  4), -- Master Data Load depends on Reference Data Load
    (6,  4), -- Transactional Data Load depends on Reference Data Load
    (6,  5), -- Transactional Data Load depends on Master Data Load

    -- Analytics migration package dependencies
    (8,  4), -- Dimensions Load depends on Reference Data Load
    (8,  5), -- Dimensions Load depends on Master Data Load
    (9,  8), -- Facts Load depends on Dimensions Load

    -- Operational executable dependencies
    (18, 11), -- Product Load depends on ProductCategory Load
    (21, 17), -- Sales Load depends on Address Load
    (21, 18), -- Sales Load depends on Product Load
    (21, 19), -- Sales Load depends on SalesPerson Load
    (21, 20), -- Sales Load depends on Customer Load

    -- Analytics dimension dependencies
    (22, 20), -- DimCustomer Load depends on Customer Load
    (23, 16), -- DimPaymentMethod Load depends on CreditCard Load
    (24, 13), -- DimShipMethod Load depends on ShipMethod Load
    (25, 11), -- DimProduct Load depends on ProductCategory Load
    (25, 18), -- DimProduct Load depends on Product Load
    (26, 14), -- DimSalesTerritory Load depends on Geography Load
    (27, 19), -- DimSalesPerson Load depends on SalesPerson Load

    -- Analytics fact dependencies
    (28, 21), -- FactSales Load depends on Sales Load
    (28, 22), -- FactSales Load depends on DimCustomer Load
    (28, 23), -- FactSales Load depends on DimPaymentMethod Load
    (28, 24), -- FactSales Load depends on DimShipMethod Load
    (28, 25), -- FactSales Load depends on DimProduct Load
    (28, 26), -- FactSales Load depends on DimSalesTerritory Load
    (28, 27), -- FactSales Load depends on DimSalesPerson Load
    (28, 71); -- FactSales Load depends on DimDate Load
GO

/*============================================================================
  6. Project Objects

  Notes:
  - Source objects belong to the Oracle source database.
  - Operational target objects belong to Sales_Operational.
  - Analytical target objects belong to Sales_Analytics.
============================================================================*/

INSERT INTO [metadata].[project_objects]
(
    [id],
    [schema_name],
    [name],
    [database_id]
)
VALUES
    -- Oracle source reference / lookup tables
    (1,  'ADVENTUREWORKS2022', 'PERSON_ADDRESSTYPE',            1),
    (2,  'ADVENTUREWORKS2022', 'PRODUCTION_PRODUCTSUBCATEGORY', 1),
    (3,  'ADVENTUREWORKS2022', 'SALES_SPECIALOFFER',            1),
    (4,  'ADVENTUREWORKS2022', 'PURCHASING_SHIPMETHOD',         1),
    (5,  'ADVENTUREWORKS2022', 'PERSON_COUNTRYREGION',          1),
    (6,  'ADVENTUREWORKS2022', 'PERSON_STATEPROVINCE',          1),
    (7,  'ADVENTUREWORKS2022', 'SALES_SALESTERRITORY',          1),
    (8,  'ADVENTUREWORKS2022', 'SALES_CURRENCY',                1),
    (9,  'ADVENTUREWORKS2022', 'SALES_CURRENCYRATE',            1),

    -- Oracle source master / core tables
    (10, 'ADVENTUREWORKS2022', 'SALES_CREDITCARD',        1),
    (11, 'ADVENTUREWORKS2022', 'PERSON_ADDRESS',          1),
    (12, 'ADVENTUREWORKS2022', 'PRODUCTION_PRODUCT',      1),
    (13, 'ADVENTUREWORKS2022', 'PERSON_PERSON',           1),
    (14, 'ADVENTUREWORKS2022', 'SALES_SALESPERSON',       1),
    (15, 'ADVENTUREWORKS2022', 'HUMANRESOURCES_EMPLOYEE', 1),
    (16, 'ADVENTUREWORKS2022', 'SALES_CUSTOMER',          1),

    -- Oracle source transactional tables
    (17, 'ADVENTUREWORKS2022', 'SALES_SALESORDERHEADER', 1),
    (18, 'ADVENTUREWORKS2022', 'SALES_SALESORDERDETAIL', 1),
    (92, 'ADVENTUREWORKS2022', 'PERSON_BUSINESSENTITYADDRESS', 1),
    (93, 'ADVENTUREWORKS2022', 'SALES_SPECIALOFFERPRODUCT',    1),

    -- Sales_Operational reference / lookup target objects
    (19, 'prod', 'AddressType',     2),
    (20, 'prod', 'ProductCategory', 2),
    (21, 'prod', 'SpecialOffer',    2),
    (22, 'prod', 'ShipMethod',      2),
    (23, 'prod', 'CountryRegion',   2),
    (24, 'prod', 'StateProvince',   2),
    (25, 'prod', 'SalesTerritory',  2),
    (26, 'prod', 'Currency',        2),
    (27, 'prod', 'CurrencyRate',    2),

    -- Sales_Operational master / core target objects
    (28, 'prod', 'CreditCard',  2),
    (29, 'prod', 'Address',     2),
    (30, 'prod', 'Product',     2),
    (31, 'prod', 'SalesPerson', 2),
    (32, 'prod', 'Customer',    2),

    -- Sales_Operational transactional target objects
    (33, 'prod', 'SalesOrderHeader', 2),
    (34, 'prod', 'SalesOrderDetail', 2),

    -- Sales_Analytics dimension objects
    (35, 'dim', 'DimCustomer',       3),
    (36, 'dim', 'DimPaymentMethod',  3),
    (37, 'dim', 'DimShipMethod',     3),
    (38, 'dim', 'DimProduct',        3),
    (39, 'dim', 'DimSalesTerritory', 3),
    (40, 'dim', 'DimSalesPerson',    3),
    (102, 'dim', 'DimDate',          3),

    -- Sales_Analytics fact object
    (41, 'fact', 'FactSales', 3),

    -- Sales_Operational staging/work objects
    (46, 'staging', 'AddressType',       2),
    (47, 'work',    'AddressType',       2),
    (48, 'staging', 'ProductSubCategory', 2),
    (49, 'work',    'ProductCategory',   2),
    (50, 'staging', 'SpecialOffer',      2),
    (51, 'work',    'SpecialOffer',      2),
    (52, 'staging', 'ShipMethod',        2),
    (53, 'work',    'ShipMethod',        2),
    (54, 'staging', 'CountryRegion',     2),
    (55, 'work',    'CountryRegion',     2),
    (56, 'staging', 'StateProvince',     2),
    (57, 'work',    'StateProvince',     2),
    (58, 'staging', 'SalesTerritory',    2),
    (59, 'work',    'SalesTerritory',    2),
    (60, 'staging', 'Currency',          2),
    (61, 'work',    'Currency',          2),
    (62, 'staging', 'CurrencyRate',      2),
    (63, 'work',    'CurrencyRate',      2),
    (64, 'staging', 'CreditCard',        2),
    (65, 'work',    'CreditCard',        2),
    (66, 'staging', 'Address',           2),
    (67, 'work',    'Address',           2),
    (68, 'staging', 'Product',           2),
    (69, 'work',    'Product',           2),
    (70, 'staging', 'SalesPerson',       2),
    (71, 'work',    'SalesPerson',       2),
    (72, 'staging', 'Customer',          2),
    (73, 'work',    'Customer',          2),
    (74, 'staging', 'SalesOrderHeader',  2),
    (75, 'work',    'SalesOrderHeader',  2),
    (76, 'staging', 'SalesOrderDetail',  2),
    (77, 'work',    'SalesOrderDetail',  2),
    (94, 'staging', 'Person',                2),
    (95, 'staging', 'Employee',              2),
    (96, 'staging', 'BusinessEntityAddress', 2),
    (97, 'staging', 'SpecialOfferProduct',   2),

    -- Sales_Analytics staging/work objects
    (78, 'staging', 'Customer',          3),
    (79, 'work',    'DimCustomer',       3),
    (80, 'staging', 'CreditCard',        3),
    (81, 'work',    'DimPaymentMethod',  3),
    (82, 'staging', 'ShipMethod',        3),
    (83, 'work',    'DimShipMethod',     3),
    (84, 'staging', 'Product',           3),
    (85, 'work',    'DimProduct',        3),
    (86, 'staging', 'SalesTerritory',    3),
    (87, 'work',    'DimSalesTerritory', 3),
    (88, 'staging', 'SalesPerson',       3),
    (89, 'work',    'DimSalesPerson',    3),
    (90, 'staging', 'SalesOrderHeader',  3),
    (91, 'work',    'FactSales',         3),
    (98, 'staging', 'CountryRegion',     3),
    (99, 'staging', 'StateProvince',     3),
    (100, 'staging', 'SalesOrderDetail', 3),
    (101, 'work',    'DimDate',          3),
    (103, 'staging', 'ProductCategory',  3);
GO

/*============================================================================
  7. Source-to-Target Object Mappings

  Notes:
  - These mappings represent lineage and data movement.
  - Some target objects can be produced from multiple source objects.
============================================================================*/

INSERT INTO [metadata].[project_object_mappings]
(
    [object_source_id],
    [object_target_id]
)
VALUES
    -- Oracle -> Sales_Operational reference / lookup lineage
    (1,  46), (46, 47), (47, 19), -- PERSON_ADDRESSTYPE            -> staging/work/prod AddressType
    (2,  48), (48, 49), (49, 20), -- PRODUCTION_PRODUCTSUBCATEGORY -> staging ProductSubCategory -> work/prod ProductCategory
    (3,  50), (50, 51), (51, 21), -- SALES_SPECIALOFFER            -> staging/work/prod SpecialOffer
    (4,  52), (52, 53), (53, 22), -- PURCHASING_SHIPMETHOD         -> staging/work/prod ShipMethod
    (5,  54), (54, 55), (55, 23), -- PERSON_COUNTRYREGION          -> staging/work/prod CountryRegion
    (6,  56), (56, 57), (57, 24), -- PERSON_STATEPROVINCE          -> staging/work/prod StateProvince
    (7,  58), (58, 59), (59, 25), -- SALES_SALESTERRITORY          -> staging/work/prod SalesTerritory
    (8,  60), (60, 61), (61, 26), -- SALES_CURRENCY                -> staging/work/prod Currency
    (9,  62), (62, 63), (63, 27), -- SALES_CURRENCYRATE            -> staging/work/prod CurrencyRate

    -- Oracle -> Sales_Operational master / core lineage
    (10, 64), (64, 65), (65, 28), -- SALES_CREDITCARD        -> staging/work/prod CreditCard
    (11, 66), (66, 67), (67, 29), -- PERSON_ADDRESS          -> staging/work/prod Address
    (12, 68), (68, 69), (69, 30), -- PRODUCTION_PRODUCT      -> staging/work/prod Product
    (14, 70), (15, 95), (70, 71), (95, 71), (71, 31), -- SalesPerson/Employee multi-source lineage
    (16, 72), (13, 94), (72, 73), (94, 73), (73, 32), -- Customer/Person multi-source lineage
    (92, 96), -- Bridge source staged for transformation support
    (93, 97), -- Bridge source staged for transformation support

    -- Oracle -> Sales_Operational transactional lineage
    (17, 74), (74, 75), (75, 33), -- SALES_SALESORDERHEADER -> staging/work/prod SalesOrderHeader
    (18, 76), (76, 77), (77, 34), -- SALES_SALESORDERDETAIL -> staging/work/prod SalesOrderDetail

    -- Sales_Operational -> Sales_Analytics dimension lineage
    (32, 78), (78, 79), (79, 35), -- Customer        -> staging/work/dim DimCustomer
    (28, 80), (80, 81), (81, 36), -- CreditCard      -> staging/work/dim DimPaymentMethod
    (22, 82), (82, 83), (83, 37), -- ShipMethod      -> staging/work/dim DimShipMethod
    (30, 84), (20, 103), (84, 85), (103, 85), (85, 38), -- Product/ProductCategory -> staging/work/dim DimProduct
    (25, 86), (23, 98), (24, 99), (86, 87), (98, 87), (99, 87), (87, 39), -- SalesTerritory/CountryRegion/StateProvince -> staging/work/dim DimSalesTerritory
    (31, 88), (88, 89), (89, 40), -- SalesPerson -> staging/work/dim DimSalesPerson
    (101, 102), -- Internally generated date values -> dim DimDate

    -- Sales_Operational -> Sales_Analytics fact lineage
    (33, 90), (34, 100), (90, 91), (100, 91), (91, 41); -- Sales orders -> staging/work/fact FactSales
GO

/*============================================================================
  8. Process-to-Object Execution Scope

  Notes:
  - This mapping defines which controlled object is handled by each process.
  - Grouped processes can map to more than one object when the group is executed
    as one orchestration container.
============================================================================*/

INSERT INTO [metadata].[project_process_objects]
(
    [process_id],
    [object_id],
    [write_strategy]
)
VALUES
    -- Reference data process scope
    (10, 46, 'TRUNCATE_INSERT'), (10, 47, 'TRUNCATE_INSERT'), (10, 19, 'TRUNCATE_INSERT'), -- AddressType Load
    (11, 48, 'TRUNCATE_INSERT'), (11, 49, 'TRUNCATE_INSERT'), (11, 20, 'TRUNCATE_INSERT'), -- ProductCategory Load
    (12, 50, 'TRUNCATE_INSERT'), (12, 51, 'TRUNCATE_INSERT'), (12, 21, 'TRUNCATE_INSERT'), (12, 97, 'TRUNCATE_INSERT'), -- SpecialOffer Load
    (13, 52, 'TRUNCATE_INSERT'), (13, 53, 'TRUNCATE_INSERT'), (13, 22, 'TRUNCATE_INSERT'), -- ShipMethod Load
    (68, 54, 'TRUNCATE_INSERT'), (68, 55, 'TRUNCATE_INSERT'), (68, 23, 'TRUNCATE_INSERT'), -- Load CountryRegion
    (69, 56, 'TRUNCATE_INSERT'), (69, 57, 'TRUNCATE_INSERT'), (69, 24, 'TRUNCATE_INSERT'), -- Load StateProvince
    (70, 58, 'TRUNCATE_INSERT'), (70, 59, 'TRUNCATE_INSERT'), (70, 25, 'TRUNCATE_INSERT'), -- Load SalesTerritory
    (15, 60, 'TRUNCATE_INSERT'), (15, 61, 'TRUNCATE_INSERT'), (15, 26, 'TRUNCATE_INSERT'), -- Currency
    (15, 62, 'TRUNCATE_INSERT'), (15, 63, 'TRUNCATE_INSERT'), (15, 27, 'TRUNCATE_INSERT'), -- CurrencyRate

    -- Master data process scope
    (16, 64, 'TRUNCATE_INSERT'), (16, 65, 'TRUNCATE_INSERT'), (16, 28, 'TRUNCATE_INSERT'), -- CreditCard Load
    (17, 66, 'TRUNCATE_INSERT'), (17, 67, 'TRUNCATE_INSERT'), (17, 29, 'TRUNCATE_INSERT'), (17, 96, 'TRUNCATE_INSERT'), -- Address Load
    (18, 68, 'TRUNCATE_INSERT'), (18, 69, 'TRUNCATE_INSERT'), (18, 30, 'TRUNCATE_INSERT'), -- Product Load
    (19, 70, 'TRUNCATE_INSERT'), (19, 95, 'TRUNCATE_INSERT'), (19, 71, 'TRUNCATE_INSERT'), (19, 31, 'TRUNCATE_INSERT'), -- SalesPerson Load
    (20, 72, 'TRUNCATE_INSERT'), (20, 94, 'TRUNCATE_INSERT'), (20, 73, 'TRUNCATE_INSERT'), (20, 32, 'TRUNCATE_INSERT'), -- Customer Load

    -- Transactional process scope
    -- Batch scope remains focused on SalesOrderHeader, but the process controls
    -- both sales order objects for lineage visibility.
    (21, 74, 'OVERWRITE'), (21, 75, 'OVERWRITE'), (21, 33, 'OVERWRITE'), -- SalesOrderHeader
    (21, 76, 'OVERWRITE'), (21, 77, 'OVERWRITE'), (21, 34, 'OVERWRITE'), -- SalesOrderDetail

    -- Analytics dimension process scope
    (22, 78, 'TRUNCATE_INSERT'), (22, 79, 'TRUNCATE_INSERT'), (22, 35, 'TRUNCATE_INSERT'), -- DimCustomer Load
    (23, 80, 'TRUNCATE_INSERT'), (23, 81, 'TRUNCATE_INSERT'), (23, 36, 'TRUNCATE_INSERT'), -- DimPaymentMethod Load
    (24, 82, 'TRUNCATE_INSERT'), (24, 83, 'TRUNCATE_INSERT'), (24, 37, 'TRUNCATE_INSERT'), -- DimShipMethod Load
    (25, 84, 'TRUNCATE_INSERT'), (25, 103, 'TRUNCATE_INSERT'), (25, 85, 'TRUNCATE_INSERT'), (25, 38, 'TRUNCATE_INSERT'), -- DimProduct Load
    (26, 86, 'TRUNCATE_INSERT'), (26, 98, 'TRUNCATE_INSERT'), (26, 99, 'TRUNCATE_INSERT'), (26, 87, 'TRUNCATE_INSERT'), (26, 39, 'TRUNCATE_INSERT'), -- DimSalesTerritory Load
    (27, 88, 'TRUNCATE_INSERT'), (27, 89, 'TRUNCATE_INSERT'), (27, 40, 'TRUNCATE_INSERT'), -- DimSalesPerson Load
    (71, 101, 'TRUNCATE_INSERT'), (71, 102, 'TRUNCATE_INSERT'), -- DimDate Load

    -- Analytics fact process scope
    (28, 90, 'TRUNCATE_INSERT'), (28, 100, 'TRUNCATE_INSERT'), (28, 91, 'TRUNCATE_INSERT'), (28, 41, 'TRUNCATE_INSERT'); -- FactSales Load
GO
