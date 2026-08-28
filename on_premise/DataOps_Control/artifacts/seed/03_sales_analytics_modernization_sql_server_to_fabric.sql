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
    (4, 'Sales_Operational', 'SQL Server 2022', 'Source', 2),
    (5, 'Sales_Analytics', 'SQL Server 2022', 'Source', 2),
    (6, 'wh_sales_analytics', 'Fabric Warehouse', 'Target', 2);
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
    (4, 6),
    (5, 6);
GO


/*============================================================================
  4. Project Processes
============================================================================*/

INSERT INTO [metadata].[project_processes]
(
    [id],
    [name],
    [project_id],
    [parent_process_id]
)
VALUES
    -- Roots
    (29, 'Ingest Sales Operational Data', 2, NULL),
    (30, 'Migrate Sales Analytics Data', 2, NULL),

    (31,  'Load Bronze Data', 2, 29),
    (32,  'Load Silver Data', 2, 29),
    (33,  'Load Gold Data', 2, 29),
    (34,  'Load Staging Data', 2, 30),
    (35,  'Load Gold Data', 2, 30);
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
    (42, 'prod', 'AddressType', 0, 0, 0, 4),
    (43, 'prod', 'SalesOrderHeader', 0, 1, 1, 4),

    (44, 'dim', 'DimCustomer', 0, 0, 0, 5),
    (45, 'fact', 'FactSales', 1, 0, 1, 5);
GO
