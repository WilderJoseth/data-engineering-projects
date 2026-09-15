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
    (7, 'Sales_Operational', 'SQL SERVER 2022', 'SOURCE', 3),
    (8, 'Sales_Analytics', 'SQL SERVER 2022', 'SOURCE', 3),
    (9, 'DataOps_Control', 'SQL SERVER 2022', 'SOURCE', 3),
    (10, 'Sales Domain Migration Oracle to SQL Server', 'GITHUB', 'SOURCE', 3),
    (11, 'DataOps_Control Migration-Driven Control Framework', 'GITHUB', 'SOURCE', 3),
    (12, 'Sales Knowledge Portal', 'SHAREPOINT', 'SOURCE', 3),
    (13, 'lh_knowledge_platform', 'FABRIC WAREHOUSE', 'TARGET', 3);
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
    [parent_process_id],
    [load_strategy],
    [is_execution_required]
)
VALUES
    (36, 'Knowledge Source Ingestion', 3, NULL, 'INCREMENTAL', 1),
    (37, 'Ingest Sales_Operational Metadata', 3, 36, 'INCREMENTAL', 1),
    (38, 'Ingest Sales_Analytics Metadata', 3, 36, 'INCREMENTAL', 1),
    (39, 'Ingest DataOps_Control Metadata', 3, 36, 'INCREMENTAL', 1),
    (40, 'Ingest Sales Domain Migration Content', 3, 36, 'INCREMENTAL', 1),
    (41, 'Ingest DataOps_Control Content', 3, 36, 'INCREMENTAL', 1),
    (42, 'Ingest Sales Knowledge Portal Content', 3, 36, 'INCREMENTAL', 1),

    (43, 'Knowledge Standardization', 3, NULL, 'INCREMENTAL', 1),
    (44, 'Metadata Standardization', 3, 43, 'INCREMENTAL', 1),
    (45, 'Standardize Sales_Operational Metadata', 3, 44, 'INCREMENTAL', 1),
    (46, 'Standardize Sales_Analytics Metadata', 3, 44, 'INCREMENTAL', 1),
    (47, 'Standardize DataOps_Control Metadata', 3, 44, 'INCREMENTAL', 1),
    (48, 'Knowledge Extraction', 3, 43, 'INCREMENTAL', 1),
    (49, 'Extract Sales Domain Migration Knowledge', 3, 48, 'INCREMENTAL', 1),
    (50, 'Extract DataOps_Control Knowledge', 3, 48, 'INCREMENTAL', 1),
    (51, 'Extract Sales Knowledge Portal Knowledge', 3, 48, 'INCREMENTAL', 1),

    (52, 'Knowledge Integration', 3, NULL, 'INCREMENTAL', 1),
    (53, 'Integrate Knowledge', 3, 52, 'INCREMENTAL', 1),

    (54, 'Retrieval Preparation', 3, NULL, 'INCREMENTAL', 1),
    (55, 'Generate Knowledge Chunks', 3, 54, 'INCREMENTAL', 1),
    (56, 'Generate Knowledge Embeddings', 3, 54, 'INCREMENTAL', 1),

    (57, 'Search Index Publication', 3, NULL, 'INCREMENTAL', 1),
    (58, 'Publish Sales Domain Search Index', 3, 57, 'INCREMENTAL', 1);
GO
