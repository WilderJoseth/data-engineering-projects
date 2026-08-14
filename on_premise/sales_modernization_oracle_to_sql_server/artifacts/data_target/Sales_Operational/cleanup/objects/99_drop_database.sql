/* WARNING: LOCAL/DEV CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
   Purpose: Optionally remove Sales_Operational for a complete local reset.
   Order: 99, final optional step. Disconnects active sessions. Irreversible. */
USE [master];
GO
IF DB_ID(N'Sales_Operational') IS NOT NULL
BEGIN
    ALTER DATABASE [Sales_Operational] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [Sales_Operational];
END;
GO
