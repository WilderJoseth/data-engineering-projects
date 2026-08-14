/* Purpose: Read-only status check for Sales_Analytics ETL security objects.
   Order: 00; run from master before creation and after creation/cleanup. */
USE [master];
GO
CREATE TABLE #SecurityStatus (
    ObjectName NVARCHAR(256), ObjectType VARCHAR(30), ExistsFlag BIT
);
INSERT #SecurityStatus
SELECT N'login_sales_analytics_etl', 'SERVER LOGIN',
       CASE WHEN SUSER_ID(N'login_sales_analytics_etl') IS NULL THEN 0 ELSE 1 END;

IF DB_ID(N'Sales_Analytics') IS NOT NULL
BEGIN
    EXEC(N'USE [Sales_Analytics];
      INSERT #SecurityStatus
      SELECT N''user_sales_analytics_etl'', ''DATABASE USER'',
        CASE WHEN USER_ID(N''user_sales_analytics_etl'') IS NULL THEN 0 ELSE 1 END
      UNION ALL SELECT N''Sales_Analytics_ETL_Executor'', ''DATABASE ROLE'',
        CASE WHEN DATABASE_PRINCIPAL_ID(N''Sales_Analytics_ETL_Executor'') IS NULL THEN 0 ELSE 1 END
      UNION ALL SELECT N''Sales_Analytics_ETL_Executor -> user_sales_analytics_etl'', ''ROLE MEMBERSHIP'',
        CASE WHEN EXISTS (
          SELECT 1 FROM sys.database_role_members drm
          JOIN sys.database_principals r ON r.principal_id=drm.role_principal_id
          JOIN sys.database_principals m ON m.principal_id=drm.member_principal_id
          WHERE r.name=N''Sales_Analytics_ETL_Executor''
            AND m.name=N''user_sales_analytics_etl'') THEN 1 ELSE 0 END;');
END
ELSE
BEGIN
    INSERT #SecurityStatus VALUES
      (N'user_sales_analytics_etl','DATABASE USER',0),
      (N'Sales_Analytics_ETL_Executor','DATABASE ROLE',0),
      (N'Sales_Analytics_ETL_Executor -> user_sales_analytics_etl','ROLE MEMBERSHIP',0);
END;
SELECT ObjectName, ObjectType,
       CASE ExistsFlag WHEN 1 THEN 'YES' ELSE 'NO' END AS CreatedOrNot
FROM #SecurityStatus ORDER BY ObjectType, ObjectName;
DROP TABLE #SecurityStatus;
GO
