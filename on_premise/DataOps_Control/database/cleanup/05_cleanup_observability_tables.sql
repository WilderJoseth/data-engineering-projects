/*============================================================================
  DataOps_Control
  Cleanup Script: Observability Tables

  Purpose:
  - Drops observability tables created by
    database/ddl/06_create_observability_tables.sql.

  Important execution order:
  - Run this script before dropping runtime tables.
============================================================================*/

USE [DataOps_Control];
GO

DROP TABLE IF EXISTS [observability].[monitoring_results];
GO

DROP TABLE IF EXISTS [observability].[validation_results];
GO

DROP TABLE IF EXISTS [observability].[reconciliation_results];
GO

DROP TABLE IF EXISTS [observability].[error_logs];
GO
