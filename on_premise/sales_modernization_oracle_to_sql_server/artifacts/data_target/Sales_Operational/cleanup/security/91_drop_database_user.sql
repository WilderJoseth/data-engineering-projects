/* WARNING: LOCAL/DEV CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
   Purpose: Drop the Sales_Operational ETL database user. Order: 91. */
USE [master];
GO
IF DB_ID(N'Sales_Operational') IS NOT NULL
EXEC(N'USE [Sales_Operational];
IF USER_ID(N''user_sales_operational_etl'') IS NOT NULL
 DROP USER [user_sales_operational_etl];');
GO
