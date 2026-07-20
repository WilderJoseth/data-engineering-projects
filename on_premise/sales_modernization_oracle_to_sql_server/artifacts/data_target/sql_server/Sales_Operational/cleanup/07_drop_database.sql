/*
    Script name
        07_drop_database.sql

    Purpose
        Safely drops the Sales_Operational database.

    Safety rules
        - Run only when the full operational target database must be removed.
        - Switches to master before dropping the database.
        - Forces existing connections to close before the drop.
*/

USE [master];
GO

IF DB_ID(N'Sales_Operational') IS NOT NULL
BEGIN
    ALTER DATABASE [Sales_Operational] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [Sales_Operational];
END;
GO
