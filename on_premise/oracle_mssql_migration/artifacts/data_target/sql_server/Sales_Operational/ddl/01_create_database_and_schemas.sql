/*
    Script name
        01_create_database_and_schemas.sql

    Purpose
        Creates the Sales_Operational database and the schemas required by the
        migration pipeline.

    Security note
        The database owner is explicitly set to [sa] for local development so
        EXECUTE AS OWNER procedures do not depend on a local Windows account.
*/

CREATE DATABASE [Sales_Operational];
GO

ALTER AUTHORIZATION ON DATABASE::[Sales_Operational] TO [sa];
GO

USE [Sales_Operational];
GO

CREATE SCHEMA [prod];
GO

CREATE SCHEMA [staging];
GO

CREATE SCHEMA [work];
GO

CREATE SCHEMA [control];
GO

CREATE SCHEMA [control] AUTHORIZATION [dbo];
GO

CREATE SCHEMA [staging] AUTHORIZATION [dbo];
GO

CREATE SCHEMA [work] AUTHORIZATION [dbo];
GO

CREATE SCHEMA [prod] AUTHORIZATION [dbo];
GO
