/*============================================================================
  DataOps_Control
  Cleanup Script: Runtime Tables

  Purpose:
  - Drops runtime tables created by database/ddl/05_create_runtime_tables.sql.

  Important execution order:
  - Run this script after dropping observability tables and before dropping
    metadata or reference tables.
============================================================================*/

USE [DataOps_Control];
GO

DROP TABLE IF EXISTS [runtime].[execution_steps];
GO

DROP TABLE IF EXISTS [runtime].[execution_runs];
GO
