/*============================================================================
  DataOps_Control
  Seed Script: Reference Data

  Purpose:
  - Loads controlled framework reference values.
  - These values are used by runtime and observability tables.

  Notes:
  - Reference IDs are manually assigned and treated as framework constants.
  - This script assumes a clean database or empty reference tables.
============================================================================*/

USE [DataOps_Control];
GO

/*============================================================================
  1. Status Codes
============================================================================*/

INSERT INTO [reference].[status_codes]
(
    [id],
    [code],
    [description],
    [is_active]
)
VALUES
    (1, 'Pending',       'Execution is registered but has not started yet.', 1),
    (2, 'Running',       'Execution is currently in progress.', 1),
    (3, 'Success',       'Execution completed successfully without control issues.', 1),
    (4, 'Failed',        'Execution failed due to a technical error.', 1),
    (5, 'Skipped',       'Execution was intentionally skipped.', 1),
    (6, 'Observed',      'Execution completed technically, but validation or reconciliation results require review.', 1);
GO

/*============================================================================
  2. Validation Codes
============================================================================*/

INSERT INTO [reference].[validation_codes]
(
    [id],
    [code],
    [description],
    [severity],
    [is_active]
)
VALUES
    (1, 'NOT_NULL',       'Required column contains null values.', 'Error', 1),
    (2, 'DUPLICATE',      'Duplicate records were found based on expected key columns.', 'Error', 1),
    (3, 'FK_CHECK',       'Referenced value does not exist in the expected parent or lookup table.', 'Error', 1),
    (4, 'DATA_TYPE',      'Value does not match the expected data type or conversion rule.', 'Error', 1),
    (5, 'LENGTH_CHECK',   'Text value exceeds the expected length.', 'Error', 1),
    (6, 'DATE_RANGE',     'Date value is outside the expected range.', 'Warning', 1),
    (7, 'NEGATIVE_VALUE', 'Numeric value is negative where it may require review.', 'Warning', 1),
    (8, 'RECON_WARNING',  'Validation passed with reconciliation or tolerance warning.', 'Warning', 1),
    (9, 'INFO_CHECK',     'Informational validation result.', 'Info', 1);
GO