/*
    Script name
        06_drop_database.sql

    Purpose
        Safely drops the Sales_Analytics database.

    Safety rules
        - Run only when the full analytical target database must be removed.
        - Switches to master before dropping the database.
        - Forces existing connections to close before the drop.
*/

USE [master];
GO

IF DB_ID(N'Sales_Analytics') IS NOT NULL
BEGIN
    ALTER DATABASE [Sales_Analytics] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [Sales_Analytics];
END;
GO
