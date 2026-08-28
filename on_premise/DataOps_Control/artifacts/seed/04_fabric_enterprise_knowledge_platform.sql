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
    (3, 'Fabric Enterprise Knowledge Platform');
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
    (7, 'Sales_Operational', 'SQL Server 2022', 'Source', 3),
    (8, 'Sales_Analytics', 'SQL Server 2022', 'Source', 3),
    (9, 'DataOps_Control', 'SQL Server 2022', 'Source', 3),
    (10, 'Sales Domain Migration Oracle to SQL Server', 'GitHub', 'Source', 3),
    (11, 'DataOps_Control Migration-Driven Control Framework', 'GitHub', 'Source', 3),
    (12, 'Sales Knowledge Portal', 'SharePoint', 'Source', 3),
    (13, 'wh_knowledge_platform', 'Fabric Warehouse', 'Target', 3);
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
    (7, 13),
    (8, 13),
    (9, 13),
    (10, 13),
    (11, 13),
    (12, 13);
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
    (36, 'Ingest Sales Operational Data', 3, NULL),
    (37, 'Ingest Sales Analytics Data', 3, NULL),
    (38, 'Ingest DataOps Control Data', 3, NULL),
    (39, 'Ingest Sales Domain Migration GitHub', 3, NULL),
    (40, 'Ingest DataOps Control GitHub', 3, NULL),
    (41, 'Ingest Sales Knowledge SharePoint', 3, NULL),

    (42,  'Load Bronze Data', 3, 36),
    (43,  'Load Silver Data', 3, 36),
    (44,  'Load Gold Data', 3, 36),
    (45,  'Load Bronze Data', 3, 37),
    (46,  'Load Silver Data', 3, 37),
    (47,  'Load Gold Data', 3, 37),
    (48,  'Load Bronze Data', 3, 38),
    (49,  'Load Silver Data', 3, 38),
    (50,  'Load Gold Data', 3, 38),
    (51,  'Load Bronze Data', 3, 39),
    (52,  'Load Silver Data', 3, 39),
    (53,  'Load Gold Data', 3, 39),
    (54,  'Load Bronze Data', 3, 40),
    (55,  'Load Silver Data', 3, 40),
    (56,  'Load Gold Data', 3, 40),
    (57,  'Load Bronze Data', 3, 41),
    (58,  'Load Silver Data', 3, 41),
    (59,  'Load Gold Data', 3, 41);
GO
