USE [DataOps_Control];
GO

/*============================================================================
  92. Drop Stored Procedures
============================================================================*/

DROP PROCEDURE IF EXISTS [observability].[usp_capture_execution_step_bigint_monitoring_results];
GO

DROP PROCEDURE IF EXISTS [observability].[usp_log_error];
GO

DROP PROCEDURE IF EXISTS [runtime].[usp_end_execution_run];
GO

DROP PROCEDURE IF EXISTS [runtime].[usp_register_skipped_child_execution_steps];
GO

DROP PROCEDURE IF EXISTS [runtime].[usp_end_parent_execution_step];
GO

DROP PROCEDURE IF EXISTS [runtime].[usp_end_execution_step];
GO

DROP PROCEDURE IF EXISTS [runtime].[usp_start_execution_step];
GO

DROP PROCEDURE IF EXISTS [runtime].[usp_start_execution_run];
GO

DROP PROCEDURE IF EXISTS [runtime].[usp_commit_execution_watermark];
GO

DROP PROCEDURE IF EXISTS [runtime].[usp_register_execution_watermark];
GO

DROP PROCEDURE IF EXISTS [runtime].[usp_close_execution_plan];
GO

DROP PROCEDURE IF EXISTS [runtime].[usp_evaluate_execution_plan_dependencies];
GO

DROP PROCEDURE IF EXISTS [runtime].[usp_add_execution_plan_process];
GO

DROP PROCEDURE IF EXISTS [runtime].[usp_create_execution_plan];
GO
