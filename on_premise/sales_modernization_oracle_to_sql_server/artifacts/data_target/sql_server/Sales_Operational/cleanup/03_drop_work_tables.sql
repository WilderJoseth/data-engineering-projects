/*
    Script name
        03_drop_work_tables.sql

    Purpose
        Safely drops all work-schema tables from the Sales_Operational database.

    Safety rules
        - Drops only tables in the work schema.
        - Uses DROP TABLE IF EXISTS so the script can be re-run.
        - Runs inside a transaction with XACT_ABORT enabled.
*/

USE [Sales_Operational];
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

DROP TABLE IF EXISTS [work].[SalesOrderDetail];
DROP TABLE IF EXISTS [work].[SalesOrderHeader];
DROP TABLE IF EXISTS [work].[Customer];
DROP TABLE IF EXISTS [work].[SalesPerson];
DROP TABLE IF EXISTS [work].[Product];
DROP TABLE IF EXISTS [work].[Address];
DROP TABLE IF EXISTS [work].[CreditCard];
DROP TABLE IF EXISTS [work].[CurrencyRate];
DROP TABLE IF EXISTS [work].[Currency];
DROP TABLE IF EXISTS [work].[StateProvince];
DROP TABLE IF EXISTS [work].[SalesTerritory];
DROP TABLE IF EXISTS [work].[CountryRegion];
DROP TABLE IF EXISTS [work].[SpecialOffer];
DROP TABLE IF EXISTS [work].[ShipMethod];
DROP TABLE IF EXISTS [work].[ProductCategory];
DROP TABLE IF EXISTS [work].[AddressType];

COMMIT TRANSACTION;
GO
