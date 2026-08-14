/* WARNING: LOCAL/DEV CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
   Purpose: Remove the ETL user from its role. Order: 90. */
USE [master];
GO
IF DB_ID(N'Sales_Operational') IS NOT NULL
EXEC(N'USE [Sales_Operational];
IF DATABASE_PRINCIPAL_ID(N''Sales_Operational_ETL_Executor'') IS NOT NULL
 AND USER_ID(N''user_sales_operational_etl'') IS NOT NULL
 AND IS_ROLEMEMBER(N''Sales_Operational_ETL_Executor'',N''user_sales_operational_etl'')=1
 ALTER ROLE [Sales_Operational_ETL_Executor] DROP MEMBER [user_sales_operational_etl];');
GO
