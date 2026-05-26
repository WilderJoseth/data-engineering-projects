/*
    Script name
        01_create_database_and_schemas.sql

    Purpose
        Creates the Sales_Analytics database and final analytical schemas.

    Scope
        Only dim and fact schemas are created here. Staging, work, and local
        control schemas are intentionally deferred.
*/

CREATE DATABASE [Sales_Analytics];
GO

USE [Sales_Analytics];
GO

CREATE SCHEMA [dim];
GO

CREATE SCHEMA [fact];
GO
