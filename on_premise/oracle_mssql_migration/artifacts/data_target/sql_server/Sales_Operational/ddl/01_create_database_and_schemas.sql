/*
    Script name
        01_create_database_and_schemas.sql

    Purpose
        Creates the Sales_Operational database and the final business schema
        required by the first implementation phase.

    Scope
        Only the prod schema is created here. Staging, work, and local control
        schemas are intentionally deferred.
*/

CREATE DATABASE [Sales_Operational];
GO

USE [Sales_Operational];
GO

CREATE SCHEMA [prod];
GO
