USE [DataOps_Control];
GO

/*============================================================================
  93. Drop Observability Tables
============================================================================*/

DROP TABLE IF EXISTS [observability].[monitoring_results];
GO

DROP TABLE IF EXISTS [observability].[validation_results];
GO

DROP TABLE IF EXISTS [observability].[reconciliation_results];
GO

DROP TABLE IF EXISTS [observability].[error_logs];
GO
