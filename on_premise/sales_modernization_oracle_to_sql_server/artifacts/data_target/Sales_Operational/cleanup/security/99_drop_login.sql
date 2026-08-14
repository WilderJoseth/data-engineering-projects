/* WARNING: LOCAL/DEV CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
   Purpose: Drop the server-level Sales_Operational ETL login. Order: 99.
   Assumption: This target-specific login is not mapped into another database. */
USE [master];
GO
IF SUSER_ID(N'login_sales_operational_etl') IS NOT NULL
    DROP LOGIN [login_sales_operational_etl];
GO
