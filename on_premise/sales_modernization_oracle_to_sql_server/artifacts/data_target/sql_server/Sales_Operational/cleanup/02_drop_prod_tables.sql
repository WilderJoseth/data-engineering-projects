/*
    Script name
        02_drop_prod_tables.sql

    Purpose
        Safely drops all prod-schema tables from the Sales_Operational database.

    Safety rules
        - Drops only tables in the prod schema.
        - Orders child tables before parent tables to satisfy foreign keys.
        - Uses DROP TABLE IF EXISTS so the script can be re-run.
        - Runs inside a transaction with XACT_ABORT enabled.
*/

USE [Sales_Operational];
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

DROP TABLE IF EXISTS [prod].[SalesOrderDetail];
DROP TABLE IF EXISTS [prod].[SalesOrderHeader];

DROP TABLE IF EXISTS [prod].[Customer];
DROP TABLE IF EXISTS [prod].[SalesPerson];
DROP TABLE IF EXISTS [prod].[Product];
DROP TABLE IF EXISTS [prod].[Address];
DROP TABLE IF EXISTS [prod].[CreditCard];

DROP TABLE IF EXISTS [prod].[CurrencyRate];
DROP TABLE IF EXISTS [prod].[Currency];

DROP TABLE IF EXISTS [prod].[StateProvince];
DROP TABLE IF EXISTS [prod].[SalesTerritory];
DROP TABLE IF EXISTS [prod].[CountryRegion];

DROP TABLE IF EXISTS [prod].[SpecialOffer];
DROP TABLE IF EXISTS [prod].[ShipMethod];
DROP TABLE IF EXISTS [prod].[ProductCategory];
DROP TABLE IF EXISTS [prod].[AddressType];

COMMIT TRANSACTION;
GO
