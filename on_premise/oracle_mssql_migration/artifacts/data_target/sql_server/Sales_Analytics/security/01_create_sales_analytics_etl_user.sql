/*
    Script name
        01_create_sales_analytics_etl_user.sql

    Database
        Sales_Analytics

    Purpose
        Creates the SQL Server login, database user, and ETL execution role used
        by the Sales_Analytics migration process.

    Security model
        - The login represents the ETL/service account.
        - The database user maps the login inside Sales_Analytics.
        - The database role owns the required ETL permissions.
        - Permissions are granted to the role, not directly to the user.

    Authentication note
        This local portfolio implementation uses SQL Server Authentication to keep
        the environment self-contained and reproducible.

        In a production enterprise deployment, Windows Authentication through
        Active Directory service accounts or groups would normally be preferred.

    Important
        Replace the placeholder password before local execution.
        Do not commit real credentials to source control.
*/

USE [master];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.server_principals
    WHERE [name] = N'login_sales_analytics_etl'
)
BEGIN
    CREATE LOGIN [login_sales_analytics_etl]
    WITH PASSWORD = 'Change_This_Strong_Password_123!';
END;
GO

USE [Sales_Analytics];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE [name] = N'user_sales_analytics_etl'
)
BEGIN
    CREATE USER [user_sales_analytics_etl]
    FOR LOGIN [login_sales_analytics_etl];
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE [name] = N'Sales_Analytics_ETL_Executor'
      AND [type] = 'R'
)
BEGIN
    CREATE ROLE [Sales_Analytics_ETL_Executor];
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    INNER JOIN sys.database_principals r
        ON r.[principal_id] = drm.[role_principal_id]
    INNER JOIN sys.database_principals m
        ON m.[principal_id] = drm.[member_principal_id]
    WHERE r.[name] = N'Sales_Analytics_ETL_Executor'
      AND m.[name] = N'user_sales_analytics_etl'
)
BEGIN
    ALTER ROLE [Sales_Analytics_ETL_Executor]
    ADD MEMBER [user_sales_analytics_etl];
END;
GO

/*
    Permissions

    Current implementation stage:
        - staging and work tables are directly loaded and cleaned by ETL.
        - dim and fact tables may be loaded directly until stored procedures are added.

    Future improvement:
        - When stored procedures are implemented, reduce direct write access to
          dim/fact and grant EXECUTE on controlled load procedures instead.
*/

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[staging]
TO [Sales_Analytics_ETL_Executor];
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[work]
TO [Sales_Analytics_ETL_Executor];
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[dim]
TO [Sales_Analytics_ETL_Executor];
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[fact]
TO [Sales_Analytics_ETL_Executor];
GO

/* Verification */

SELECT
    r.[name] AS [role_name],
    m.[name] AS [member_name]
FROM sys.database_role_members drm
INNER JOIN sys.database_principals r
    ON r.[principal_id] = drm.[role_principal_id]
INNER JOIN sys.database_principals m
    ON m.[principal_id] = drm.[member_principal_id]
WHERE r.[name] = N'Sales_Analytics_ETL_Executor'
  AND m.[name] = N'user_sales_analytics_etl';
GO