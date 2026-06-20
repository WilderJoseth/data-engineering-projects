/*
    Script name
        02_create_schemas.sql

    Purpose
        Creates the schemas required by the Sales_Analytics analytical
        migration pipeline.

    Scope
        Creates control, staging, work, dim, and fact schemas inside the
        Sales_Analytics database. Local control tables and procedures are
        intentionally deferred to a later implementation step.
*/

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
