USE [DataOps_Control];
GO

/*============================================================================
  95. Drop Metadata Tables
============================================================================*/

DROP TABLE IF EXISTS [metadata].[project_notifications];
GO

DROP TABLE IF EXISTS [metadata].[project_process_monitoring_metrics];
GO

DROP TABLE IF EXISTS [metadata].[project_process_dependencies];
GO

DROP TABLE IF EXISTS [metadata].[project_process_actions];
GO

DROP TABLE IF EXISTS [metadata].[project_object_columns];
GO

DROP TABLE IF EXISTS [metadata].[project_process_object_batches];
GO

DROP TABLE IF EXISTS [metadata].[project_object_batches];
GO

DROP TABLE IF EXISTS [metadata].[project_process_objects];
GO

DROP TABLE IF EXISTS [metadata].[project_object_mappings];
GO

DROP TABLE IF EXISTS [metadata].[project_database_mappings];
GO

DROP TABLE IF EXISTS [metadata].[project_objects];
GO

DROP TABLE IF EXISTS [metadata].[project_processes];
GO

DROP TABLE IF EXISTS [metadata].[project_databases];
GO

DROP TABLE IF EXISTS [metadata].[projects];
GO
