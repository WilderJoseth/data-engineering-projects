/*============================================================================
  DataOps_Control
  Cleanup Script: Reference Data

  Important execution order:
  - Run this script only after all metadata cleanup scripts have completed.
  - For v2, metadata.project_process_actions must be cleaned before deleting
    reference values if those metadata rows still depend on seeded project data.
  - This script intentionally removes only reference schema values.

  Purpose:
  - Removes reference data from reference.status_codes
    and reference.validation_codes.
============================================================================*/

USE [DataOps_Control];
GO

/*============================================================================
  1. Status Codes
============================================================================*/
DELETE FROM [reference].[status_codes];
GO

/*============================================================================
  2. Validation Codes
============================================================================*/
DELETE FROM [reference].[validation_codes];
GO
