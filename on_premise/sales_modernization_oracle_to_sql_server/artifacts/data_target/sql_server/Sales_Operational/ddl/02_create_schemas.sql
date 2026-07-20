/*
    Script name
        02_create_schemas.sql

    Purpose
        Creates the schemas required by the Sales_Operational migration pipeline.

    Scope
        Schema creation only. Tables and programmable objects are created by later scripts.
*/

USE [Sales_Operational];
GO

CREATE SCHEMA [control] AUTHORIZATION [dbo];
GO

CREATE SCHEMA [staging] AUTHORIZATION [dbo];
GO

CREATE SCHEMA [work] AUTHORIZATION [dbo];
GO

CREATE SCHEMA [prod] AUTHORIZATION [dbo];
GO
