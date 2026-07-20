/*
    Script name
        06_drop_schemas.sql

    Purpose
        Safely drops Sales_Operational schemas after their objects have been
        removed.

    Safety rules
        - Run after programmable-object and table cleanup scripts.
        - Uses DROP SCHEMA IF EXISTS so the script can be re-run.
        - Keeps dbo because it is a system-owned database schema.
*/

USE [Sales_Operational];
GO

DROP SCHEMA IF EXISTS [prod];
GO

DROP SCHEMA IF EXISTS [work];
GO

DROP SCHEMA IF EXISTS [staging];
GO

DROP SCHEMA IF EXISTS [control];
GO
