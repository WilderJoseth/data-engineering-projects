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
    (14, 'Sales_Operational', 'SQL SERVER 2022', 'SOURCE', 4),
    (15, 'ADVENTUREWORKS2022', 'ORACLE XE 21C', 'SOURCE', 4),
    (16, 'Enterprise_Operational', 'AZURE SQL DATABASE', 'TARGET', 4);
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
    [parent_process_id],
    [load_strategy],
    [is_execution_required]
)
VALUES
    -- Roots
    (59, 'Sales_Operational Ingestion', 4, NULL, NULL, 1),
    (60, 'ADVENTUREWORKS2022 Operational Ingestion', 4, NULL, NULL, 1),

    -- Layer/category processes
    (142, 'Bronze Data Ingestion - Reference', 4, 59, 'INCREMENTAL', 1),
    (143, 'Silver Data Ingestion - Reference', 4, 59, 'INCREMENTAL', 1),
    (144, 'Gold Data Ingestion - Reference', 4, 59, 'INCREMENTAL', 1),
    (145, 'Bronze Data Ingestion - Master', 4, 59, 'INCREMENTAL', 1),
    (146, 'Silver Data Ingestion - Master', 4, 59, 'INCREMENTAL', 1),
    (147, 'Gold Data Ingestion - Master', 4, 59, 'INCREMENTAL', 1),
    (148, 'Bronze Data Ingestion - Transactional', 4, 59, 'BATCH', 1),
    (149, 'Silver Data Ingestion - Transactional', 4, 59, 'BATCH', 1),
    (150, 'Gold Data Ingestion - Transactional', 4, 59, 'BATCH', 1),

    (151, 'Bronze Data Ingestion - Reference', 4, 60, 'INCREMENTAL', 1),
    (152, 'Silver Data Ingestion - Reference', 4, 60, 'INCREMENTAL', 1),
    (153, 'Gold Data Ingestion - Reference', 4, 60, 'INCREMENTAL', 1),
    (154, 'Bronze Data Ingestion - Master', 4, 60, 'INCREMENTAL', 1),
    (155, 'Silver Data Ingestion - Master', 4, 60, 'INCREMENTAL', 1),
    (156, 'Gold Data Ingestion - Master', 4, 60, 'INCREMENTAL', 1),
    (157, 'Bronze Data Ingestion - Transactional', 4, 60, 'BATCH', 1),
    (158, 'Silver Data Ingestion - Transactional', 4, 60, 'BATCH', 1),
    (159, 'Gold Data Ingestion - Transactional', 4, 60, 'BATCH', 1);
GO

