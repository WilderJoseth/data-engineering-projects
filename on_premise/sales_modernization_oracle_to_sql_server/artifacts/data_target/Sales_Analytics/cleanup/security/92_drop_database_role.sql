/* WARNING: LOCAL/DEV CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
   Purpose: Drop the Sales_Analytics ETL database role and its grants. Order: 92. */
USE [master];
GO
IF DB_ID(N'Sales_Analytics') IS NOT NULL
EXEC(N'USE [Sales_Analytics];
IF DATABASE_PRINCIPAL_ID(N''Sales_Analytics_ETL_Executor'') IS NOT NULL
 DROP ROLE [Sales_Analytics_ETL_Executor];');
GO
