/* WARNING: LOCAL/DEV CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
   Purpose: Drop the Sales_Analytics ETL database user. Order: 91. */
USE [master];
GO
IF DB_ID(N'Sales_Analytics') IS NOT NULL
EXEC(N'USE [Sales_Analytics];
IF USER_ID(N''user_sales_analytics_etl'') IS NOT NULL
 DROP USER [user_sales_analytics_etl];');
GO
