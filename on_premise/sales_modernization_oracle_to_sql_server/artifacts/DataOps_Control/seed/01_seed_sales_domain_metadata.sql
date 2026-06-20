/*============================================================================
  DataOps_Control
  Seed Script: Sales Domain Metadata

  Purpose:
  - Loads sample metadata for the Oracle to SQL Server Migration - Sales Domain.
  - Supports testing table load, grouped table load, batch-oriented flows,
    process-level execution flags, process dependencies, and v2 process-action
    metadata.

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
    (2, 'Sales_Operational',  'SQL Server 2022', 'Target', 1),
    (3, 'Sales_Analytics',    'SQL Server 2022', 'Target', 1),
    (4, 'DataOps_Control',    'SQL Server 2022', 'Control', 1);
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
  - parent_process_id defines process hierarchy/grouping.
  - execution_required defines whether the process should be considered for
    execution by the orchestration layer.
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
    [parent_process_id],
    [execution_required]
)
VALUES
    -- Migration roots
    (1, 'Sales_Operational_Migration', 1, NULL, 1),
    (2, 'Sales_Analytics_Migration', 1, NULL, 1),

    -- Operational migration process groups
    (4, 'Reference Data Load', 1, 1, 1),
    (5, 'Master Data Load', 1, 1, 1),
    (6, 'Transactional Data Load', 1, 1, 1),

    -- Analytics migration process groups
    (8, 'Dimensions Data Load', 1, 2, 1),
    (9, 'Facts Data Load', 1, 2, 1),

    -- Reference data loads
    (10, 'AddressType Load', 1, 4, 1),
    (11, 'ProductCategory Load', 1, 4, 1),
    (12, 'SpecialOffer Load', 1, 4, 1),
    (13, 'ShipMethod Load', 1, 4, 1),
    (14, 'Geography Load', 1, 4, 1),
    (15, 'Currency Load', 1, 4, 1),

    -- Master data loads
    (16, 'CreditCard Load', 1, 5, 1),
    (17, 'Address Load', 1, 5, 1),
    (18, 'Product Load', 1, 5, 1),
    (19, 'SalesPerson Load', 1, 5, 1),
    (20, 'Customer Load', 1, 5, 1),

    -- Transactional data loads
    (21, 'Sales Load', 1, 6, 1),

    -- Dimension loads
    (22, 'DimCustomer Load', 1, 8, 1),
    (23, 'DimPaymentMethod Load', 1, 8, 1),
    (24, 'DimShipMethod Load', 1, 8, 1),
    (25, 'DimProduct Load', 1, 8, 1),
    (26, 'DimSalesTerritory Load', 1, 8, 1),
    (27, 'DimSalesPerson Load', 1, 8, 1),

    -- Fact loads
    (28, 'FactSales Load', 1, 9, 1);
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
    (5,  4), -- Master Data Load depends on Reference Data Load
    (6,  5), -- Transactional Data Load depends on Master Data Load

    -- Analytics process group sequence
    (9,  8), -- Facts Data Load depends on Dimensions Data Load

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
  - DataOps_Control is registered as a control database because framework
    runtime procedures are executable actions too.
  - parameter_template stores custom ETL placeholder tokens for runtime
    parameters, such as {1} or {1}, {2}. It does not store real parameter
    values and these tokens must be replaced by the orchestration layer.
  - Reconciliation result functions are registered as TABLE_VALUED_FUNCTION
    actions because they return a result set.
  - Load status code functions are registered as SCALAR_FUNCTION actions because
    they return a single SMALLINT value.
  - Cleanup actions are registered as STORED_PROCEDURE actions in the control
    schema and are intended to clean staging/work execution artifacts.
  - The action lookup function should generate command templates based on
    action_type.

  execution_database_id:
  - 2 = Sales_Operational
  - 3 = Sales_Analytics
  - 4 = DataOps_Control
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
    -- AddressType Load
    (1001, 10, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (1002, 10, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_AddressType_reconciliation_results', '{1}, {2}', 1),
    (1003, 10, 3, 'Validate work data', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_AddressType', '{1}', 1),
    (1004, 10, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_AddressType', '{1}', 1),
    (1005, 10, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_AddressType_reconciliation_results', '{1}, {2}', 1),
    (1006, 10, 6, 'Get load status code', 'SCALAR_FUNCTION', 2, 'control', 'ufn_get_AddressType_load_status_code', '{1}', 1),
    (1007, 10, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (1008, 10, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 2, 'control', 'usp_cleanup_AddressType', NULL, 1),

    -- ProductCategory Load
    (1101, 11, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (1102, 11, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_ProductCategory_reconciliation_results', '{1}, {2}', 1),
    (1103, 11, 3, 'Validate work data', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_ProductCategory', '{1}', 1),
    (1104, 11, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_ProductCategory', '{1}', 1),
    (1105, 11, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_ProductCategory_reconciliation_results', '{1}, {2}', 1),
    (1106, 11, 6, 'Get load status code', 'SCALAR_FUNCTION', 2, 'control', 'ufn_get_ProductCategory_load_status_code', '{1}', 1),
    (1107, 11, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (1108, 11, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 2, 'control', 'usp_cleanup_ProductCategory', NULL, 1),

    -- SpecialOffer Load
    (1201, 12, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (1202, 12, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_SpecialOffer_reconciliation_results', '{1}, {2}', 1),
    (1203, 12, 3, 'Validate work data', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_SpecialOffer', '{1}', 1),
    (1204, 12, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_SpecialOffer', '{1}', 1),
    (1205, 12, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_SpecialOffer_reconciliation_results', '{1}, {2}', 1),
    (1206, 12, 6, 'Get load status code', 'SCALAR_FUNCTION', 2, 'control', 'ufn_get_SpecialOffer_load_status_code', '{1}', 1),
    (1207, 12, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (1208, 12, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 2, 'control', 'usp_cleanup_SpecialOffer', NULL, 1),

    -- ShipMethod Load
    (1301, 13, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (1302, 13, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_ShipMethod_reconciliation_results', '{1}, {2}', 1),
    (1303, 13, 3, 'Validate work data', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_ShipMethod', '{1}', 1),
    (1304, 13, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_ShipMethod', '{1}', 1),
    (1305, 13, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_ShipMethod_reconciliation_results', '{1}, {2}', 1),
    (1306, 13, 6, 'Get load status code', 'SCALAR_FUNCTION', 2, 'control', 'ufn_get_ShipMethod_load_status_code', '{1}', 1),
    (1307, 13, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (1308, 13, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 2, 'control', 'usp_cleanup_ShipMethod', NULL, 1),

    -- Geography Load
    (1401, 14, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (1402, 14, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_Geography_reconciliation_results', '{1}, {2}', 1),
    (1403, 14, 3, 'Validate work data', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_Geography', '{1}', 1),
    (1404, 14, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_Geography', '{1}', 1),
    (1405, 14, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_Geography_reconciliation_results', '{1}, {2}', 1),
    (1406, 14, 6, 'Get load status code', 'SCALAR_FUNCTION', 2, 'control', 'ufn_get_Geography_load_status_code', '{1}', 1),
    (1407, 14, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (1408, 14, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 2, 'control', 'usp_cleanup_Geography', NULL, 1),

    -- Currency Load
    (1501, 15, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (1502, 15, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_Currency_reconciliation_results', '{1}, {2}', 1),
    (1503, 15, 3, 'Validate work data', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_Currency', '{1}', 1),
    (1504, 15, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_Currency', '{1}', 1),
    (1505, 15, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_Currency_reconciliation_results', '{1}, {2}', 1),
    (1506, 15, 6, 'Get load status code', 'SCALAR_FUNCTION', 2, 'control', 'ufn_get_Currency_load_status_code', '{1}', 1),
    (1507, 15, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (1508, 15, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 2, 'control', 'usp_cleanup_Currency', NULL, 1),

    -- CreditCard Load
    (1601, 16, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (1602, 16, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_CreditCard_reconciliation_results', '{1}, {2}', 1),
    (1603, 16, 3, 'Validate work data', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_CreditCard', '{1}', 1),
    (1604, 16, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_CreditCard', '{1}', 1),
    (1605, 16, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_CreditCard_reconciliation_results', '{1}, {2}', 1),
    (1606, 16, 6, 'Get load status code', 'SCALAR_FUNCTION', 2, 'control', 'ufn_get_CreditCard_load_status_code', '{1}', 1),
    (1607, 16, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (1608, 16, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 2, 'control', 'usp_cleanup_CreditCard', NULL, 1),

    -- Address Load
    (1701, 17, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (1702, 17, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_Address_reconciliation_results', '{1}, {2}', 1),
    (1703, 17, 3, 'Validate work data', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_Address', '{1}', 1),
    (1704, 17, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_Address', '{1}', 1),
    (1705, 17, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_Address_reconciliation_results', '{1}, {2}', 1),
    (1706, 17, 6, 'Get load status code', 'SCALAR_FUNCTION', 2, 'control', 'ufn_get_Address_load_status_code', '{1}', 1),
    (1707, 17, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (1708, 17, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 2, 'control', 'usp_cleanup_Address', NULL, 1),

    -- Product Load
    (1801, 18, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (1802, 18, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_Product_reconciliation_results', '{1}, {2}', 1),
    (1803, 18, 3, 'Validate work data', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_Product', '{1}', 1),
    (1804, 18, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_Product', '{1}', 1),
    (1805, 18, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_Product_reconciliation_results', '{1}, {2}', 1),
    (1806, 18, 6, 'Get load status code', 'SCALAR_FUNCTION', 2, 'control', 'ufn_get_Product_load_status_code', '{1}', 1),
    (1807, 18, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (1808, 18, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 2, 'control', 'usp_cleanup_Product', NULL, 1),

    -- SalesPerson Load
    (1901, 19, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (1902, 19, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_SalesPerson_reconciliation_results', '{1}, {2}', 1),
    (1903, 19, 3, 'Validate work data', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_SalesPerson', '{1}', 1),
    (1904, 19, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_SalesPerson', '{1}', 1),
    (1905, 19, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_SalesPerson_reconciliation_results', '{1}, {2}', 1),
    (1906, 19, 6, 'Get load status code', 'SCALAR_FUNCTION', 2, 'control', 'ufn_get_SalesPerson_load_status_code', '{1}', 1),
    (1907, 19, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (1908, 19, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 2, 'control', 'usp_cleanup_SalesPerson', NULL, 1),

    -- Customer Load
    (2001, 20, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (2002, 20, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_Customer_reconciliation_results', '{1}, {2}', 1),
    (2003, 20, 3, 'Validate work data', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_Customer', '{1}', 1),
    (2004, 20, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_Customer', '{1}', 1),
    (2005, 20, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_Customer_reconciliation_results', '{1}, {2}', 1),
    (2006, 20, 6, 'Get load status code', 'SCALAR_FUNCTION', 2, 'control', 'ufn_get_Customer_load_status_code', '{1}', 1),
    (2007, 20, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (2008, 20, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 2, 'control', 'usp_cleanup_Customer', NULL, 1),

    -- SalesOrder Load
    (2101, 21, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (2102, 21, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_SalesOrder_reconciliation_results', '{1}, {2}', 1),
    (2103, 21, 3, 'Validate work data', 'STORED_PROCEDURE', 2, 'work', 'usp_validate_SalesOrder', '{1}', 1),
    (2104, 21, 4, 'Load final table', 'STORED_PROCEDURE', 2, 'prod', 'usp_load_SalesOrder', '{1}', 1),
    (2105, 21, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 2, 'control', 'ufn_get_SalesOrder_reconciliation_results', '{1}, {2}', 1),
    (2106, 21, 6, 'Get load status code', 'SCALAR_FUNCTION', 2, 'control', 'ufn_get_SalesOrder_load_status_code', '{1}', 1),
    (2107, 21, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (2108, 21, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 2, 'control', 'usp_cleanup_SalesOrder', NULL, 1),

    -- DimCustomer Load
    (2201, 22, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (2202, 22, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 3, 'control', 'ufn_get_DimCustomer_reconciliation_results', '{1}, {2}', 1),
    (2203, 22, 3, 'Validate work data', 'STORED_PROCEDURE', 3, 'work', 'usp_validate_DimCustomer', '{1}', 1),
    (2204, 22, 4, 'Load final table', 'STORED_PROCEDURE', 3, 'dim', 'usp_load_DimCustomer', '{1}', 1),
    (2205, 22, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 3, 'control', 'ufn_get_DimCustomer_reconciliation_results', '{1}, {2}', 1),
    (2206, 22, 6, 'Get load status code', 'SCALAR_FUNCTION', 3, 'control', 'ufn_get_DimCustomer_load_status_code', '{1}', 1),
    (2207, 22, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (2208, 22, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 3, 'control', 'usp_cleanup_DimCustomer', NULL, 1),

    -- DimPaymentMethod Load
    (2301, 23, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (2302, 23, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 3, 'control', 'ufn_get_DimPaymentMethod_reconciliation_results', '{1}, {2}', 1),
    (2303, 23, 3, 'Validate work data', 'STORED_PROCEDURE', 3, 'work', 'usp_validate_DimPaymentMethod', '{1}', 1),
    (2304, 23, 4, 'Load final table', 'STORED_PROCEDURE', 3, 'dim', 'usp_load_DimPaymentMethod', '{1}', 1),
    (2305, 23, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 3, 'control', 'ufn_get_DimPaymentMethod_reconciliation_results', '{1}, {2}', 1),
    (2306, 23, 6, 'Get load status code', 'SCALAR_FUNCTION', 3, 'control', 'ufn_get_DimPaymentMethod_load_status_code', '{1}', 1),
    (2307, 23, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (2308, 23, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 3, 'control', 'usp_cleanup_DimPaymentMethod', NULL, 1),

    -- DimShipMethod Load
    (2401, 24, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (2402, 24, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 3, 'control', 'ufn_get_DimShipMethod_reconciliation_results', '{1}, {2}', 1),
    (2403, 24, 3, 'Validate work data', 'STORED_PROCEDURE', 3, 'work', 'usp_validate_DimShipMethod', '{1}', 1),
    (2404, 24, 4, 'Load final table', 'STORED_PROCEDURE', 3, 'dim', 'usp_load_DimShipMethod', '{1}', 1),
    (2405, 24, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 3, 'control', 'ufn_get_DimShipMethod_reconciliation_results', '{1}, {2}', 1),
    (2406, 24, 6, 'Get load status code', 'SCALAR_FUNCTION', 3, 'control', 'ufn_get_DimShipMethod_load_status_code', '{1}', 1),
    (2407, 24, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (2408, 24, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 3, 'control', 'usp_cleanup_DimShipMethod', NULL, 1),

    -- DimProduct Load
    (2501, 25, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (2502, 25, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 3, 'control', 'ufn_get_DimProduct_reconciliation_results', '{1}, {2}', 1),
    (2503, 25, 3, 'Validate work data', 'STORED_PROCEDURE', 3, 'work', 'usp_validate_DimProduct', '{1}', 1),
    (2504, 25, 4, 'Load final table', 'STORED_PROCEDURE', 3, 'dim', 'usp_load_DimProduct', '{1}', 1),
    (2505, 25, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 3, 'control', 'ufn_get_DimProduct_reconciliation_results', '{1}, {2}', 1),
    (2506, 25, 6, 'Get load status code', 'SCALAR_FUNCTION', 3, 'control', 'ufn_get_DimProduct_load_status_code', '{1}', 1),
    (2507, 25, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (2508, 25, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 3, 'control', 'usp_cleanup_DimProduct', NULL, 1),

    -- DimSalesTerritory Load
    (2601, 26, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (2602, 26, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 3, 'control', 'ufn_get_DimSalesTerritory_reconciliation_results', '{1}, {2}', 1),
    (2603, 26, 3, 'Validate work data', 'STORED_PROCEDURE', 3, 'work', 'usp_validate_DimSalesTerritory', '{1}', 1),
    (2604, 26, 4, 'Load final table', 'STORED_PROCEDURE', 3, 'dim', 'usp_load_DimSalesTerritory', '{1}', 1),
    (2605, 26, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 3, 'control', 'ufn_get_DimSalesTerritory_reconciliation_results', '{1}, {2}', 1),
    (2606, 26, 6, 'Get load status code', 'SCALAR_FUNCTION', 3, 'control', 'ufn_get_DimSalesTerritory_load_status_code', '{1}', 1),
    (2607, 26, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (2608, 26, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 3, 'control', 'usp_cleanup_DimSalesTerritory', NULL, 1),

    -- DimSalesPerson Load
    (2701, 27, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (2702, 27, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 3, 'control', 'ufn_get_DimSalesPerson_reconciliation_results', '{1}, {2}', 1),
    (2703, 27, 3, 'Validate work data', 'STORED_PROCEDURE', 3, 'work', 'usp_validate_DimSalesPerson', '{1}', 1),
    (2704, 27, 4, 'Load final table', 'STORED_PROCEDURE', 3, 'dim', 'usp_load_DimSalesPerson', '{1}', 1),
    (2705, 27, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 3, 'control', 'ufn_get_DimSalesPerson_reconciliation_results', '{1}, {2}', 1),
    (2706, 27, 6, 'Get load status code', 'SCALAR_FUNCTION', 3, 'control', 'ufn_get_DimSalesPerson_load_status_code', '{1}', 1),
    (2707, 27, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (2708, 27, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 3, 'control', 'usp_cleanup_DimSalesPerson', NULL, 1),

    -- FactSales Load
    (2801, 28, 1, 'Start execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_start_execution_step', '{1}, {2}', 1),
    (2802, 28, 2, 'Get initial reconciliation results', 'TABLE_VALUED_FUNCTION', 3, 'control', 'ufn_get_FactSales_reconciliation_results', '{1}, {2}', 1),
    (2803, 28, 3, 'Validate work data', 'STORED_PROCEDURE', 3, 'work', 'usp_validate_FactSales', '{1}', 1),
    (2804, 28, 4, 'Load final table', 'STORED_PROCEDURE', 3, 'fact', 'usp_load_FactSales', '{1}', 1),
    (2805, 28, 5, 'Get final reconciliation results', 'TABLE_VALUED_FUNCTION', 3, 'control', 'ufn_get_FactSales_reconciliation_results', '{1}, {2}', 1),
    (2806, 28, 6, 'Get load status code', 'SCALAR_FUNCTION', 3, 'control', 'ufn_get_FactSales_load_status_code', '{1}', 1),
    (2807, 28, 7, 'End execution step', 'STORED_PROCEDURE', 4, 'runtime', 'usp_end_execution_step', '{1}, {2}', 1),
    (2808, 28, 8, 'Cleanup staging and work tables', 'STORED_PROCEDURE', 3, 'control', 'usp_cleanup_FactSales', NULL, 1);

GO