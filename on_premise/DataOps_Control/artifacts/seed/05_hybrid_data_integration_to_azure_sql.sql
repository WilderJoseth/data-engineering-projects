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
    (4, 'Hybrid Data Integration to Azure SQL');
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
    (14, 'Sales_Operational', 'SQL Server 2022', 'Source', 4),
    (15, 'ADVENTUREWORKS2022', 'Oracle XE 21c', 'Source', 4),
    (16, 'Enterprise_Operational', 'Azure SQL Database', 'Target', 4);
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
    (14, 16), -- Sales_Operational -> Enterprise_Operational
    (15, 16); -- ADVENTUREWORKS2022 -> Enterprise_Operational
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
    (60, 'Ingest Sales Operational Data', 4, NULL),
    (61, 'Ingest ADVENTUREWORKS2022 Operational Data', 4, NULL),

    (62,  'Load Bronze Data', 4, 60),
    (63,  'Load Silver Data', 4, 60),
    (64,  'Load Serving Data', 4, 60),
    (65,  'Load Bronze Data', 4, 61),
    (66,  'Load Silver Data', 4, 61),
    (67,  'Load Serving Data', 4, 61);
GO

