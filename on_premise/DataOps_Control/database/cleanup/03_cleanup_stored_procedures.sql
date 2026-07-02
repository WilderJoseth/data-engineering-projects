/*============================================================================
  DataOps_Control
  Cleanup Script: Stored Procedures

  Purpose:
  - Drops framework stored procedures created by
    database/ddl/07_create_stored_procedures.sql.
============================================================================*/

USE [DataOps_Control];
GO

DROP PROCEDURE IF EXISTS [observability].[usp_log_error];
GO

DROP PROCEDURE IF EXISTS [runtime].[usp_end_execution_run];
GO

DROP PROCEDURE IF EXISTS [runtime].[usp_end_execution_step];
GO

DROP PROCEDURE IF EXISTS [runtime].[usp_start_execution_step];
GO

DROP PROCEDURE IF EXISTS [runtime].[usp_end_parent_execution_step];
GO

DROP PROCEDURE IF EXISTS [runtime].[usp_register_skipped_child_execution_steps];
GO

DROP PROCEDURE IF EXISTS [runtime].[usp_start_execution_run];
GO

DROP PROCEDURE IF EXISTS [observability].[usp_capture_execution_step_bigint_monitoring_results];
GO
