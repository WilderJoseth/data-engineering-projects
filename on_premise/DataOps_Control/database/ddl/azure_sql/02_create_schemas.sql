/*
    Azure SQL Database version of 02_create_schemas.sql
    Target database: DataOps_Control
    Run this script while connected to the DataOps_Control Azure SQL database.
*/

USE [DataOps_Control];
GO

/*============================================================================
  2. Schemas
============================================================================*/

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE [name] = 'metadata')
BEGIN
    EXEC('CREATE SCHEMA [metadata]');
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE [name] = 'runtime')
BEGIN
    EXEC('CREATE SCHEMA [runtime]');
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE [name] = 'observability')
BEGIN
    EXEC('CREATE SCHEMA [observability]');
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE [name] = 'reference')
BEGIN
    EXEC('CREATE SCHEMA [reference]');
END;
GO