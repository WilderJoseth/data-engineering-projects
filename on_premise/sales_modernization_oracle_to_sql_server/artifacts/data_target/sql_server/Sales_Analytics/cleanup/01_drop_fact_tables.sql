/*
    Script name
        01_drop_fact_tables.sql

    Purpose
        Safely drops all fact-schema tables from the Sales_Analytics database.

    Safety rules
        - Drops only tables in the fact schema.
        - Uses DROP TABLE IF EXISTS so the script can be re-run.
        - Runs inside a transaction with XACT_ABORT enabled.
*/

USE [Sales_Analytics];
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

DROP TABLE IF EXISTS [fact].[FactSales];

COMMIT TRANSACTION;
GO
