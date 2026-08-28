USE [DataOps_Control];
GO

/*============================================================================
  90. Drop Views
============================================================================*/

DROP VIEW IF EXISTS [observability].[vw_reconciliation_result_summary];
GO

DROP VIEW IF EXISTS [observability].[vw_monitoring_result_summary];
GO

DROP VIEW IF EXISTS [observability].[vw_execution_observability_summary];
GO

DROP VIEW IF EXISTS [runtime].[vw_execution_watermark_summary];
GO

DROP VIEW IF EXISTS [runtime].[vw_execution_plan_process_summary];
GO

DROP VIEW IF EXISTS [runtime].[vw_execution_plan_summary];
GO

DROP VIEW IF EXISTS [runtime].[vw_execution_step_summary];
GO

DROP VIEW IF EXISTS [runtime].[vw_execution_run_summary];
GO

DROP VIEW IF EXISTS [metadata].[vw_project_process_monitoring_metric_summary];
GO

DROP VIEW IF EXISTS [metadata].[vw_project_table_lineage_summary];
GO

DROP VIEW IF EXISTS [metadata].[vw_project_batch_execution_scope];
GO

DROP VIEW IF EXISTS [metadata].[vw_project_process_action_summary];
GO

DROP VIEW IF EXISTS [metadata].[vw_project_process_dependency_summary];
GO

DROP VIEW IF EXISTS [metadata].[vw_project_process_hierarchy];
GO
