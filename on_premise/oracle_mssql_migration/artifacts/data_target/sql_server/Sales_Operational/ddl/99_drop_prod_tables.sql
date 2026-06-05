/*
    Script name
        99_drop_prod_tables.sql

    Purpose
        Safely drops all prod-schema tables from the Sales_Operational database.

    Safety rules
        - Drops only tables in the prod schema.
        - Drops child tables before parent tables to respect foreign keys.
        - Uses DROP TABLE IF EXISTS so the script can be re-run.
        - Runs inside a transaction with XACT_ABORT enabled.

    Usage warning
        This script removes table definitions and all data in prod tables.
        Use only when resetting a development or test target environment.
*/

USE [Sales_Operational];
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

DROP TABLE IF EXISTS [prod].[SalesOrderDetail];
DROP TABLE IF EXISTS [prod].[SalesOrderHeader];

DROP TABLE IF EXISTS [prod].[Customer];
DROP TABLE IF EXISTS [prod].[Employee];
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
