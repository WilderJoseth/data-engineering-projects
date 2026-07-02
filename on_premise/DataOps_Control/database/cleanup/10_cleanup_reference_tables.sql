/*============================================================================
  DataOps_Control
  Cleanup Script: Reference Tables

  Purpose:
  - Drops reference tables created by database/ddl/03_create_reference_tables.sql.

  Important execution order:
  - Run this script after metadata, runtime, and observability tables.
============================================================================*/

USE [DataOps_Control];
GO

DROP TABLE IF EXISTS [reference].[monitoring_metric_codes];
GO

DROP TABLE IF EXISTS [reference].[validation_codes];
GO

DROP TABLE IF EXISTS [reference].[status_codes];
GO
