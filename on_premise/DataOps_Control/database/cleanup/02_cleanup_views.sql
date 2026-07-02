/*============================================================================
  DataOps_Control
  Cleanup Script: Views

  Purpose:
  - Drops framework views created by database/ddl/10_create_views.sql.

  Important execution order:
  - Run this script before dropping functions and tables.
============================================================================*/

USE [DataOps_Control];
GO

DROP VIEW IF EXISTS [observability].[vw_monitoring_result_summary];
GO

DROP VIEW IF EXISTS [observability].[vw_execution_observability_summary];
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
