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
    (2, 'Sales Analytics Modernization: SQL Server to Microsoft Fabric');
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
    (4,  'Sales_Operational',     'SQL SERVER 2022',         'SOURCE', 2),
    (5,  'Sales_Analytics',       'SQL SERVER 2022',         'SOURCE', 2),
    (6,  'wh_sales_analytics',    'FABRIC WAREHOUSE',        'TARGET', 2),
    (17, 'lh_sales_operational',  'FABRIC LAKEHOUSE',        'TARGET', 2),
    (18, 'sm_sales_analytics',    'POWER BI SEMANTIC MODEL', 'TARGET', 2);
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
    (4, 17), -- Sales_Operational -> Fabric Lakehouse
    (17, 6), -- Fabric Lakehouse -> Fabric Warehouse
    (5, 6),  -- Sales_Analytics historical source -> Fabric Warehouse
    (6, 18); -- Fabric Warehouse -> Power BI semantic model
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
    -- Roots
    (29, 'Sales_Operational Ingestion', 2, NULL, NULL, 1),
    (30, 'Sales_Analytics Migration',   2, NULL, NULL, 1),

    -- Layer/category processes
    (72, 'Bronze Data Ingestion - Reference',       2, 29, 'INCREMENTAL', 1),
    (73, 'Silver Data Ingestion - Reference',       2, 29, 'INCREMENTAL', 1),
    (74, 'Gold Data Ingestion - Dimensional',       2, 29, 'INCREMENTAL', 1),
    (75, 'Bronze Data Ingestion - Master',          2, 29, 'INCREMENTAL', 1),
    (76, 'Silver Data Ingestion - Master',          2, 29, 'INCREMENTAL', 1),
    (78, 'Bronze Data Ingestion - Transactional',   2, 29, 'BATCH',       1),
    (79, 'Silver Data Ingestion - Transactional',   2, 29, 'BATCH',       1),
    (80, 'Gold Data Ingestion - Fact',              2, 29, 'BATCH',       1),
    (81, 'Staging Data Ingestion - Dimensional',    2, 30, 'FULL',        1),
    (82, 'Gold Data Ingestion - Dimensional',       2, 30, 'FULL',        1),
    (83, 'Staging Data Ingestion - Fact',           2, 30, 'FULL',        1),
    (84, 'Gold Data Ingestion - Fact',              2, 30, 'FULL',        1),
    (85, 'Semantic Model Publication',              2, NULL, NULL,        1),

    -- Bronze reference object loads
    (86, 'Load Bronze AddressType',      2, 72, 'INCREMENTAL', 1),
    (87, 'Load Bronze CountryRegion',    2, 72, 'INCREMENTAL', 1),
    (88, 'Load Bronze StateProvince',    2, 72, 'INCREMENTAL', 1),
    (89, 'Load Bronze SalesTerritory',   2, 72, 'INCREMENTAL', 1),
    (90, 'Load Bronze Currency',         2, 72, 'INCREMENTAL', 1),
    (91, 'Load Bronze CurrencyRate',     2, 72, 'INCREMENTAL', 1),
    (92, 'Load Bronze ShipMethod',       2, 72, 'INCREMENTAL', 1),
    (93, 'Load Bronze SpecialOffer',     2, 72, 'INCREMENTAL', 1),
    (94, 'Load Bronze ProductCategory',  2, 72, 'INCREMENTAL', 1),

    -- Silver reference object loads
    (95,  'Load Silver AddressType',     2, 73, 'INCREMENTAL', 1),
    (96,  'Load Silver CountryRegion',   2, 73, 'INCREMENTAL', 1),
    (97,  'Load Silver StateProvince',   2, 73, 'INCREMENTAL', 1),
    (98,  'Load Silver SalesTerritory',  2, 73, 'INCREMENTAL', 1),
    (99,  'Load Silver Currency',        2, 73, 'INCREMENTAL', 1),
    (100, 'Load Silver CurrencyRate',    2, 73, 'INCREMENTAL', 1),
    (101, 'Load Silver ShipMethod',      2, 73, 'INCREMENTAL', 1),
    (102, 'Load Silver SpecialOffer',    2, 73, 'INCREMENTAL', 1),
    (103, 'Load Silver ProductCategory', 2, 73, 'INCREMENTAL', 1),

    -- Gold reference-derived object loads
    (104, 'Load Gold DimShipMethod',     2, 74, 'INCREMENTAL', 1),
    (105, 'Load Gold DimSalesTerritory', 2, 74, 'INCREMENTAL', 1),
    (106, 'Load Gold DimDate',           2, 74, 'INCREMENTAL', 1),

    -- Bronze master object loads
    (107, 'Load Bronze Customer',    2, 75, 'INCREMENTAL', 1),
    (108, 'Load Bronze SalesPerson', 2, 75, 'INCREMENTAL', 1),
    (109, 'Load Bronze Product',     2, 75, 'INCREMENTAL', 1),
    (110, 'Load Bronze Address',     2, 75, 'INCREMENTAL', 1),
    (111, 'Load Bronze CreditCard',  2, 75, 'INCREMENTAL', 1),

    -- Silver master object loads
    (112, 'Load Silver Customer',    2, 76, 'INCREMENTAL', 1),
    (113, 'Load Silver SalesPerson', 2, 76, 'INCREMENTAL', 1),
    (114, 'Load Silver Product',     2, 76, 'INCREMENTAL', 1),
    (115, 'Load Silver Address',     2, 76, 'INCREMENTAL', 1),
    (116, 'Load Silver CreditCard',  2, 76, 'INCREMENTAL', 1),

    -- Gold master-derived object loads
    (117, 'Load Gold DimCustomer',      2, 74, 'INCREMENTAL', 1),
    (118, 'Load Gold DimProduct',       2, 74, 'INCREMENTAL', 1),
    (119, 'Load Gold DimSalesPerson',   2, 74, 'INCREMENTAL', 1),
    (120, 'Load Gold DimPaymentMethod', 2, 74, 'INCREMENTAL', 1),

    -- Transactional object loads
    (121, 'Load Bronze SalesOrderHeader', 2, 78, 'BATCH', 1),
    (122, 'Load Bronze SalesOrderDetail', 2, 78, 'BATCH', 1),
    (123, 'Load Silver SalesOrderHeader', 2, 79, 'BATCH', 1),
    (124, 'Load Silver SalesOrderDetail', 2, 79, 'BATCH', 1),
    (125, 'Load Gold FactSales',          2, 80, 'BATCH', 1),

    -- Historical dimensional migration object loads
    (126, 'Load Staging DimCustomer',       2, 81, 'FULL', 1),
    (127, 'Load Staging DimProduct',        2, 81, 'FULL', 1),
    (128, 'Load Staging DimSalesPerson',    2, 81, 'FULL', 1),
    (129, 'Load Staging DimSalesTerritory', 2, 81, 'FULL', 1),
    (130, 'Load Staging DimPaymentMethod',  2, 81, 'FULL', 1),
    (131, 'Load Staging DimShipMethod',     2, 81, 'FULL', 1),
    (132, 'Load Staging DimDate',           2, 81, 'FULL', 1),
    (133, 'Load Gold Historical DimCustomer',       2, 82, 'FULL', 1),
    (134, 'Load Gold Historical DimProduct',        2, 82, 'FULL', 1),
    (135, 'Load Gold Historical DimSalesPerson',    2, 82, 'FULL', 1),
    (136, 'Load Gold Historical DimSalesTerritory', 2, 82, 'FULL', 1),
    (137, 'Load Gold Historical DimPaymentMethod',  2, 82, 'FULL', 1),
    (138, 'Load Gold Historical DimShipMethod',     2, 82, 'FULL', 1),
    (139, 'Load Gold Historical DimDate',           2, 82, 'FULL', 1),

    -- Historical fact migration object loads
    (140, 'Load Staging FactSales',         2, 83, 'FULL', 1),
    (141, 'Load Gold Historical FactSales', 2, 84, 'FULL', 1);
GO

/*============================================================================
  5. Project Process Dependencies
============================================================================*/

INSERT INTO [metadata].[project_process_dependencies]
(
    [project_process_id],
    [dependency_project_process_id]
)
VALUES
    -- Root/category dependencies
    (30, 29),
    (73, 72), (74, 73),
    (76, 75), (74, 76),
    (79, 78), (80, 79),
    (82, 81),
    (84, 83),
    (85, 80), (85, 82), (85, 84),

    -- Silver reference depends on matching Bronze reference
    (95, 86), (96, 87), (97, 88), (98, 89), (99, 90),
    (100, 91), (101, 92), (102, 93), (103, 94),

    -- Silver master depends on matching Bronze master
    (112, 107), (113, 108), (114, 109), (115, 110), (116, 111),

    -- Silver transactional depends on matching Bronze transactional
    (123, 121), (124, 122),

    -- Gold reference-derived dependencies
    (104, 101), -- DimShipMethod depends on Silver ShipMethod
    (105, 96),  -- DimSalesTerritory depends on Silver CountryRegion
    (105, 97),  -- DimSalesTerritory depends on Silver StateProvince
    (105, 98),  -- DimSalesTerritory depends on Silver SalesTerritory

    -- Gold master-derived dependencies
    (117, 112), -- DimCustomer depends on Silver Customer
    (118, 103), -- DimProduct depends on Silver ProductCategory
    (118, 114), -- DimProduct depends on Silver Product
    (119, 113), -- DimSalesPerson depends on Silver SalesPerson
    (120, 116), -- DimPaymentMethod depends on Silver CreditCard

    -- Gold transactional dependencies
    (125, 123), (125, 124), (125, 104), (125, 105), (125, 106),
    (125, 117), (125, 118), (125, 119), (125, 120),

    -- Historical migration dependencies
    (133, 126), (134, 127), (135, 128), (136, 129),
    (137, 130), (138, 131), (139, 132),
    (141, 140), (141, 133), (141, 134), (141, 135),
    (141, 136), (141, 137), (141, 138), (141, 139),

    -- Semantic model publication dependencies are represented at the root
    -- Semantic Model Publication process level.
    (85, 125), (85, 133), (85, 134), (85, 135),
    (85, 136), (85, 137), (85, 138), (85, 139),
    (85, 141);
GO

/*============================================================================
  6. Project Objects
============================================================================*/

INSERT INTO [metadata].[project_objects]
(
    [id],
    [schema_name],
    [name],
    [database_id]
)
VALUES
    -- Sales_Operational source objects
    (104, 'prod', 'SalesOrderHeader', 4),
    (105, 'prod', 'SalesOrderDetail', 4),
    (106, 'prod', 'Customer', 4),
    (107, 'prod', 'SalesPerson', 4),
    (108, 'prod', 'Product', 4),
    (109, 'prod', 'Address', 4),
    (110, 'prod', 'CreditCard', 4),
    (111, 'prod', 'AddressType', 4),
    (112, 'prod', 'CountryRegion', 4),
    (113, 'prod', 'StateProvince', 4),
    (114, 'prod', 'SalesTerritory', 4),
    (115, 'prod', 'Currency', 4),
    (116, 'prod', 'CurrencyRate', 4),
    (117, 'prod', 'ShipMethod', 4),
    (118, 'prod', 'SpecialOffer', 4),
    (119, 'prod', 'ProductCategory', 4),

    -- Sales_Analytics historical source objects
    (120, 'fact', 'FactSales', 5),
    (121, 'dim',  'DimCustomer', 5),
    (122, 'dim',  'DimProduct', 5),
    (123, 'dim',  'DimSalesPerson', 5),
    (124, 'dim',  'DimSalesTerritory', 5),
    (125, 'dim',  'DimPaymentMethod', 5),
    (126, 'dim',  'DimShipMethod', 5),
    (127, 'dim',  'DimDate', 5),

    -- Fabric Lakehouse Bronze objects
    (128, 'bronze', 'SalesOrderHeader', 17),
    (129, 'bronze', 'SalesOrderDetail', 17),
    (130, 'bronze', 'Customer', 17),
    (131, 'bronze', 'SalesPerson', 17),
    (132, 'bronze', 'Product', 17),
    (133, 'bronze', 'Address', 17),
    (134, 'bronze', 'CreditCard', 17),
    (135, 'bronze', 'AddressType', 17),
    (136, 'bronze', 'CountryRegion', 17),
    (137, 'bronze', 'StateProvince', 17),
    (138, 'bronze', 'SalesTerritory', 17),
    (139, 'bronze', 'Currency', 17),
    (140, 'bronze', 'CurrencyRate', 17),
    (141, 'bronze', 'ShipMethod', 17),
    (142, 'bronze', 'SpecialOffer', 17),
    (143, 'bronze', 'ProductCategory', 17),

    -- Fabric Lakehouse Silver objects
    (144, 'silver', 'SalesOrderHeader', 17),
    (145, 'silver', 'SalesOrderDetail', 17),
    (146, 'silver', 'Customer', 17),
    (147, 'silver', 'SalesPerson', 17),
    (148, 'silver', 'Product', 17),
    (149, 'silver', 'Address', 17),
    (150, 'silver', 'CreditCard', 17),
    (151, 'silver', 'AddressType', 17),
    (152, 'silver', 'CountryRegion', 17),
    (153, 'silver', 'StateProvince', 17),
    (154, 'silver', 'SalesTerritory', 17),
    (155, 'silver', 'Currency', 17),
    (156, 'silver', 'CurrencyRate', 17),
    (157, 'silver', 'ShipMethod', 17),
    (158, 'silver', 'SpecialOffer', 17),
    (159, 'silver', 'ProductCategory', 17),

    -- Fabric Warehouse Staging objects
    (160, 'staging', 'FactSales', 6),
    (161, 'staging', 'DimCustomer', 6),
    (162, 'staging', 'DimProduct', 6),
    (163, 'staging', 'DimSalesPerson', 6),
    (164, 'staging', 'DimSalesTerritory', 6),
    (165, 'staging', 'DimPaymentMethod', 6),
    (166, 'staging', 'DimShipMethod', 6),
    (167, 'staging', 'DimDate', 6),

    -- Fabric Warehouse Gold objects
    (168, 'gold', 'FactSales', 6),
    (169, 'gold', 'DimCustomer', 6),
    (170, 'gold', 'DimProduct', 6),
    (171, 'gold', 'DimSalesPerson', 6),
    (172, 'gold', 'DimSalesTerritory', 6),
    (173, 'gold', 'DimPaymentMethod', 6),
    (174, 'gold', 'DimShipMethod', 6),
    (175, 'gold', 'DimDate', 6),

    -- Semantic model object
    (176, 'semantic', 'sm_sales_analytics', 18);
GO

/*============================================================================
  7. Source-to-Target Object Mappings
============================================================================*/

INSERT INTO [metadata].[project_object_mappings]
(
    [object_source_id],
    [object_target_id]
)
VALUES
    -- Sales_Operational -> Bronze
    (104, 128), (105, 129), (106, 130), (107, 131),
    (108, 132), (109, 133), (110, 134), (111, 135),
    (112, 136), (113, 137), (114, 138), (115, 139),
    (116, 140), (117, 141), (118, 142), (119, 143),

    -- Bronze -> Silver
    (128, 144), (129, 145), (130, 146), (131, 147),
    (132, 148), (133, 149), (134, 150), (135, 151),
    (136, 152), (137, 153), (138, 154), (139, 155),
    (140, 156), (141, 157), (142, 158), (143, 159),

    -- Historical Sales_Analytics -> Warehouse Staging
    (120, 160), (121, 161), (122, 162), (123, 163),
    (124, 164), (125, 165), (126, 166), (127, 167),

    -- Staging/Silver -> Gold
    (160, 168), (144, 168), (145, 168), -- FactSales
    (161, 169), (146, 169), -- DimCustomer
    (162, 170), (148, 170), (159, 170), -- DimProduct
    (163, 171), (147, 171), -- DimSalesPerson
    (164, 172), (154, 172), (152, 172), (153, 172), -- DimSalesTerritory
    (165, 173), (150, 173), -- DimPaymentMethod
    (166, 174), (157, 174), -- DimShipMethod
    (167, 175), -- DimDate

    -- Gold -> Semantic model
    (168, 176), (169, 176), (170, 176), (171, 176),
    (172, 176), (173, 176), (174, 176), (175, 176);
GO

/*============================================================================
  8. Process-to-Object Execution Scope
============================================================================*/

INSERT INTO [metadata].[project_process_objects]
(
    [process_id],
    [object_id],
    [write_strategy]
)
VALUES
    -- Bronze reference object loads
    (86, 135, 'UPSERT'), (87, 136, 'UPSERT'), (88, 137, 'UPSERT'),
    (89, 138, 'UPSERT'), (90, 139, 'UPSERT'), (91, 140, 'UPSERT'),
    (92, 141, 'UPSERT'), (93, 142, 'UPSERT'), (94, 143, 'UPSERT'),

    -- Silver reference object loads
    (95, 151, 'UPSERT'), (96, 152, 'UPSERT'), (97, 153, 'UPSERT'),
    (98, 154, 'UPSERT'), (99, 155, 'UPSERT'), (100, 156, 'UPSERT'),
    (101, 157, 'UPSERT'), (102, 158, 'UPSERT'), (103, 159, 'UPSERT'),

    -- Gold reference-derived object loads
    (104, 174, 'MERGE'), (105, 172, 'MERGE'), (106, 175, 'MERGE'),

    -- Bronze master object loads
    (107, 130, 'UPSERT'), (108, 131, 'UPSERT'), (109, 132, 'UPSERT'),
    (110, 133, 'UPSERT'), (111, 134, 'UPSERT'),

    -- Silver master object loads
    (112, 146, 'UPSERT'), (113, 147, 'UPSERT'), (114, 148, 'UPSERT'),
    (115, 149, 'UPSERT'), (116, 150, 'UPSERT'),

    -- Gold master-derived object loads
    (117, 169, 'MERGE'), (118, 170, 'MERGE'),
    (119, 171, 'MERGE'), (120, 173, 'MERGE'),

    -- Transactional object loads
    (121, 128, 'OVERWRITE'), (122, 129, 'OVERWRITE'),
    (123, 144, 'OVERWRITE'), (124, 145, 'OVERWRITE'),
    (125, 168, 'MERGE'),

    -- Historical dimensional migration object loads
    (126, 161, 'TRUNCATE_INSERT'), (127, 162, 'TRUNCATE_INSERT'),
    (128, 163, 'TRUNCATE_INSERT'), (129, 164, 'TRUNCATE_INSERT'),
    (130, 165, 'TRUNCATE_INSERT'), (131, 166, 'TRUNCATE_INSERT'),
    (132, 167, 'TRUNCATE_INSERT'),
    (133, 169, 'MERGE'), (134, 170, 'MERGE'), (135, 171, 'MERGE'),
    (136, 172, 'MERGE'), (137, 173, 'MERGE'), (138, 174, 'MERGE'),
    (139, 175, 'MERGE'),

    -- Historical fact migration object loads
    (140, 160, 'TRUNCATE_INSERT'),
    (141, 168, 'MERGE'),

    -- Semantic model publication
    (85, 176, NULL);
GO
