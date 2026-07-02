/*============================================================================
  DataOps_Control
  Cleanup Script: Metadata Tables

  Purpose:
  - Drops metadata tables created by database/ddl/04_create_metadata_tables.sql.

  Important execution order:
  - Run this script after runtime and observability tables.
  - Run this script before reference tables.
============================================================================*/

USE [DataOps_Control];
GO

DROP TABLE IF EXISTS [metadata].[project_process_monitoring_metrics];
GO

DROP TABLE IF EXISTS [metadata].[project_process_dependencies];
GO

DROP TABLE IF EXISTS [metadata].[project_process_actions];
GO

DROP TABLE IF EXISTS [metadata].[project_columns];
GO

DROP TABLE IF EXISTS [metadata].[project_process_table_batches];
GO

DROP TABLE IF EXISTS [metadata].[project_table_batches];
GO

DROP TABLE IF EXISTS [metadata].[project_process_tables];
GO

DROP TABLE IF EXISTS [metadata].[project_table_mappings];
GO

DROP TABLE IF EXISTS [metadata].[project_tables];
GO

DROP TABLE IF EXISTS [metadata].[project_processes];
GO

DROP TABLE IF EXISTS [metadata].[project_database_mappings];
GO

DROP TABLE IF EXISTS [metadata].[project_databases];
GO

DROP TABLE IF EXISTS [metadata].[projects];
GO

DROP TABLE IF EXISTS [metadata].[project_notifications];
GO
