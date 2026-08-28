USE [DataOps_Control];
GO

/*============================================================================
  94. Drop Runtime Tables
============================================================================*/

DROP TABLE IF EXISTS [runtime].[execution_watermarks];
GO

DROP TABLE IF EXISTS [runtime].[execution_steps];
GO

DROP TABLE IF EXISTS [runtime].[execution_runs];
GO

DROP TABLE IF EXISTS [runtime].[execution_watermark_controls];
GO

DROP TABLE IF EXISTS [runtime].[execution_plan_processes];
GO

DROP TABLE IF EXISTS [runtime].[execution_plans];
GO
