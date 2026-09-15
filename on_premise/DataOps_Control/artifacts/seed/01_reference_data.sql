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
    (1, 'PENDING',   'Execution is registered but has not started yet.', 1),
    (2, 'RUNNING',   'Execution is currently in progress.', 1),
    (3, 'SUCCESS',   'Execution completed successfully without control issues.', 1),
    (4, 'FAILED',    'Execution failed due to a technical error.', 1),
    (5, 'SKIPPED',   'Execution was intentionally skipped.', 1),
    (6, 'OBSERVED',  'Execution completed technically, but validation or reconciliation results require review.', 1),
    (7, 'READY',     'Execution is ready to start because prerequisite conditions are satisfied.', 1),
    (8, 'BLOCKED',   'Execution cannot start or continue because one or more dependencies are blocked or failed.', 1),
    (9, 'CANCELLED', 'Execution was cancelled before completion.', 1);
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
    (1, 'NOT_NULL',       'Required column contains null values.', 'ERROR', 1),
    (2, 'DUPLICATE',      'Duplicate records were found based on expected key columns.', 'ERROR', 1),
    (3, 'FK_CHECK',       'Referenced value does not exist in the expected parent or lookup table.', 'ERROR', 1),
    (4, 'DATA_TYPE',      'Value does not match the expected data type or conversion rule.', 'ERROR', 1),
    (5, 'LENGTH_CHECK',   'Text value exceeds the expected length.', 'ERROR', 1),
    (6, 'DATE_RANGE',     'Date value is outside the expected range.', 'WARNING', 1),
    (7, 'NEGATIVE_VALUE', 'Numeric value is negative where it may require review.', 'WARNING', 1),
    (8, 'RECON_WARNING',  'Validation passed with reconciliation or tolerance warning.', 'WARNING', 1),
    (9, 'INFO_CHECK',     'Informational validation result.', 'INFO', 1);
GO
