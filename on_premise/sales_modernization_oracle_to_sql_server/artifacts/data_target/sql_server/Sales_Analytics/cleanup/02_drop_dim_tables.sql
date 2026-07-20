/*
    Script name
        02_drop_dim_tables.sql

    Purpose
        Safely drops all dim-schema tables from the Sales_Analytics database.

    Safety rules
        - Drops only tables in the dim schema.
        - Run after fact tables are dropped because facts reference dimensions.
        - Uses DROP TABLE IF EXISTS so the script can be re-run.
        - Runs inside a transaction with XACT_ABORT enabled.
*/

USE [Sales_Analytics];
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

DROP TABLE IF EXISTS [dim].[DimShipMethod];
DROP TABLE IF EXISTS [dim].[DimPaymentMethod];
DROP TABLE IF EXISTS [dim].[DimProduct];
DROP TABLE IF EXISTS [dim].[DimSalesTerritory];
DROP TABLE IF EXISTS [dim].[DimSalesPerson];
DROP TABLE IF EXISTS [dim].[DimCustomer];
DROP TABLE IF EXISTS [dim].[DimDate];

COMMIT TRANSACTION;
GO
