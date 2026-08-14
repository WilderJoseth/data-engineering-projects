/* WARNING: LOCAL/DEV CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
   Purpose: Optionally remove Sales_Analytics for a complete local reset.
   Order: 99, final optional step. Disconnects active sessions. Irreversible. */
USE [master];
GO
IF DB_ID(N'Sales_Analytics') IS NOT NULL
BEGIN
    ALTER DATABASE [Sales_Analytics] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [Sales_Analytics];
END;
GO
