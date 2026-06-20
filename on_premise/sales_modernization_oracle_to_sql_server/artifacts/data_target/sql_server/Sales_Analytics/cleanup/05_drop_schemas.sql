/*
    Script name
        05_drop_schemas.sql

    Purpose
        Safely drops Sales_Analytics schemas after their objects have been
        removed.

    Safety rules
        - Run after table cleanup scripts.
        - Uses DROP SCHEMA IF EXISTS so the script can be re-run.
        - Keeps dbo because it is a system-owned database schema.
*/

USE [Sales_Analytics];
GO

DROP SCHEMA IF EXISTS [fact];
GO

DROP SCHEMA IF EXISTS [dim];
GO

DROP SCHEMA IF EXISTS [work];
GO

DROP SCHEMA IF EXISTS [staging];
GO

DROP SCHEMA IF EXISTS [control];
GO
