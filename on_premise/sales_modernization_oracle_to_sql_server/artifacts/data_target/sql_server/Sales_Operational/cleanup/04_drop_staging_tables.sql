/*
    Script name
        04_drop_staging_tables.sql

    Purpose
        Safely drops all staging-schema tables from the Sales_Operational database.

    Safety rules
        - Drops only tables in the staging schema.
        - Uses DROP TABLE IF EXISTS so the script can be re-run.
        - Runs inside a transaction with XACT_ABORT enabled.
*/

USE [Sales_Operational];
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

DROP TABLE IF EXISTS [staging].[SalesOrderDetail];
DROP TABLE IF EXISTS [staging].[SalesOrderHeader];
DROP TABLE IF EXISTS [staging].[Customer];
DROP TABLE IF EXISTS [staging].[SalesPerson];
DROP TABLE IF EXISTS [staging].[Employee];
DROP TABLE IF EXISTS [staging].[Person];
DROP TABLE IF EXISTS [staging].[Product];
DROP TABLE IF EXISTS [staging].[Address];
DROP TABLE IF EXISTS [staging].[CreditCard];
DROP TABLE IF EXISTS [staging].[CurrencyRate];
DROP TABLE IF EXISTS [staging].[Currency];
DROP TABLE IF EXISTS [staging].[StateProvince];
DROP TABLE IF EXISTS [staging].[SalesTerritory];
DROP TABLE IF EXISTS [staging].[CountryRegion];
DROP TABLE IF EXISTS [staging].[SpecialOffer];
DROP TABLE IF EXISTS [staging].[ShipMethod];
DROP TABLE IF EXISTS [staging].[ProductCategory];
DROP TABLE IF EXISTS [staging].[AddressType];

COMMIT TRANSACTION;
GO
