/*
    Script name
        01_create_database_and_schemas.sql

    Purpose
        Creates the Sales_Analytics database and the schemas required by the
        analytical migration pipeline.

    Scope
        Creates staging, work, dim, and fact schemas. Local control objects are
        intentionally deferred to a later implementation step.
*/

CREATE DATABASE [Sales_Analytics];
GO

ALTER AUTHORIZATION ON DATABASE::[Sales_Analytics] TO [sa];
GO

USE [Sales_Analytics];
GO

CREATE SCHEMA [control] AUTHORIZATION [dbo];
GO

CREATE SCHEMA [staging] AUTHORIZATION [dbo];
GO

CREATE SCHEMA [work] AUTHORIZATION [dbo];
GO

CREATE SCHEMA [dim] AUTHORIZATION [dbo];
GO

CREATE SCHEMA [fact] AUTHORIZATION [dbo];
GO