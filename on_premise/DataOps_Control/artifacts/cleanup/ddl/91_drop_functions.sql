USE [DataOps_Control];
GO

/*============================================================================
  91. Drop Functions
============================================================================*/

DROP FUNCTION IF EXISTS [metadata].[ufn_list_project_process_actions];
GO

DROP FUNCTION IF EXISTS [metadata].[ufn_list_project_process_table_batches];
GO

DROP FUNCTION IF EXISTS [metadata].[ufn_list_project_process_children];
GO
