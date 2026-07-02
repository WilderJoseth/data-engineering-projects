/*============================================================================
  DataOps_Control
  Cleanup Script: Functions

  Purpose:
  - Drops framework functions created by database/ddl/08_create_functions.sql.

  Important execution order:
  - Run this script after dropping dependent views.
============================================================================*/

USE [DataOps_Control];
GO

DROP FUNCTION IF EXISTS [metadata].[ufn_list_project_process_actions];
GO

DROP FUNCTION IF EXISTS [metadata].[ufn_list_project_process_table_batches];
GO

DROP FUNCTION IF EXISTS [metadata].[ufn_list_project_process_children];
GO
