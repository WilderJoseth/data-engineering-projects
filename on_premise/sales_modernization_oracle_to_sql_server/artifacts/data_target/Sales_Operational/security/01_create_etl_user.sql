/*
    Script name
        01_create_etl_user.sql

    Database
        Sales_Operational

    Purpose
        Creates the SQL Server login, database user, and ETL execution role used
        by the Sales_Operational migration process.

    Security model
        - The login represents the ETL/service account.
        - The database user maps the login inside Sales_Operational.
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
    WHERE [name] = N'login_sales_operational_etl'
)
BEGIN
    CREATE LOGIN [login_sales_operational_etl]
    WITH PASSWORD = 'SQLServerPwd_123';
END;
GO

USE [Sales_Operational];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE [name] = N'user_sales_operational_etl'
)
BEGIN
    CREATE USER [user_sales_operational_etl]
    FOR LOGIN [login_sales_operational_etl];
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE [name] = N'Sales_Operational_ETL_Executor'
      AND [type] = 'R'
)
BEGIN
    CREATE ROLE [Sales_Operational_ETL_Executor];
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    INNER JOIN sys.database_principals r
        ON r.[principal_id] = drm.[role_principal_id]
    INNER JOIN sys.database_principals m
        ON m.[principal_id] = drm.[member_principal_id]
    WHERE r.[name] = N'Sales_Operational_ETL_Executor'
      AND m.[name] = N'user_sales_operational_etl'
)
BEGIN
    ALTER ROLE [Sales_Operational_ETL_Executor]
    ADD MEMBER [user_sales_operational_etl];
END;
GO

/*
    Permissions

    Current implementation stage:
        - staging and work tables are directly loaded and cleaned by ETL.
        - prod tables may be loaded directly until stored procedures are added.

    Future improvement:
        - When stored procedures are implemented, reduce direct write access to
          prod and grant EXECUTE on controlled load procedures instead.
*/

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[staging]
TO [Sales_Operational_ETL_Executor];
GO

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::[work]
TO [Sales_Operational_ETL_Executor];
GO

GRANT SELECT, EXECUTE ON SCHEMA::[control]
TO [Sales_Operational_ETL_Executor];
GO

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::[prod]
TO [Sales_Operational_ETL_Executor];
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
WHERE r.[name] = N'Sales_Operational_ETL_Executor'
  AND m.[name] = N'user_sales_operational_etl';
GO