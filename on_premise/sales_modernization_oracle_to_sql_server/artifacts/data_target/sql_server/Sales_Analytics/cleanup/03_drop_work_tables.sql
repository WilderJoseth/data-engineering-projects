/*
    Script name
        03_drop_work_tables.sql

    Purpose
        Safely drops all work-schema tables from the Sales_Analytics database.

    Safety rules
        - Drops only tables in the work schema.
        - Uses DROP TABLE IF EXISTS so the script can be re-run.
        - Runs inside a transaction with XACT_ABORT enabled.
*/

USE [Sales_Analytics];
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

DROP TABLE IF EXISTS [work].[FactSales];
DROP TABLE IF EXISTS [work].[DimShipMethod];
DROP TABLE IF EXISTS [work].[DimPaymentMethod];
DROP TABLE IF EXISTS [work].[DimProduct];
DROP TABLE IF EXISTS [work].[DimSalesTerritory];
DROP TABLE IF EXISTS [work].[DimSalesPerson];
DROP TABLE IF EXISTS [work].[DimCustomer];

COMMIT TRANSACTION;
GO
