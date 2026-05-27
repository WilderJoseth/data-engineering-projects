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

USE [Sales_Analytics];
GO

CREATE SCHEMA [dim];
GO

CREATE SCHEMA [fact];
GO

CREATE SCHEMA [staging];
GO

CREATE SCHEMA [work];
GO
