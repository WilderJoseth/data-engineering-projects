/*============================================================================
  DataOps_Control
  Cleanup Script: Reference Data

  Important execution order:
  - Run this script only after 01_cleanup_sales_domain_metadata.sql.

  Purpose:
  - Removes reference data from reference.status_codes
    or reference.validation_codes.
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
