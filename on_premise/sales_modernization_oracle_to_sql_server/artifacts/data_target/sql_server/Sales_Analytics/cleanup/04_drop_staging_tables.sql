/*
    Script name
        04_drop_staging_tables.sql

    Purpose
        Safely drops all staging-schema tables from the Sales_Analytics database.

    Safety rules
        - Drops only tables in the staging schema.
        - Uses DROP TABLE IF EXISTS so the script can be re-run.
        - Runs inside a transaction with XACT_ABORT enabled.
*/

USE [Sales_Analytics];
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

DROP TABLE IF EXISTS [staging].[FactSales];
DROP TABLE IF EXISTS [staging].[DimShipMethod];
DROP TABLE IF EXISTS [staging].[DimPaymentMethod];
DROP TABLE IF EXISTS [staging].[DimProduct];
DROP TABLE IF EXISTS [staging].[DimSalesTerritory];
DROP TABLE IF EXISTS [staging].[DimSalesPerson];
DROP TABLE IF EXISTS [staging].[DimCustomer];

COMMIT TRANSACTION;
GO
