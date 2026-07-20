/*
    Script name
        05_drop_control_tables.sql

    Purpose
        Safely drops all control-schema tables from the Sales_Operational database.

    Safety rules
        - Drops only tables in the control schema.
        - Run after programmable objects are dropped.
        - Uses DROP TABLE IF EXISTS so the script can be re-run.
        - Runs inside a transaction with XACT_ABORT enabled.
*/

USE [Sales_Operational];
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

DROP TABLE IF EXISTS [control].[validation_results];
DROP TABLE IF EXISTS [control].[reconciliation_results];
DROP TABLE IF EXISTS [control].[validation_codes];
DROP TABLE IF EXISTS [control].[status_codes];

COMMIT TRANSACTION;
GO
