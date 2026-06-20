
USE [master];
GO

/*==============================================================
    1. Create SQL Server login

    Test login:
    - login_sales_analytics_executor

    Replace the password before using this in a real environment.
==============================================================*/

IF NOT EXISTS (
    SELECT 1
    FROM sys.server_principals
    WHERE [name] = 'login_sales_analytics_executor'
)
BEGIN
    CREATE LOGIN [login_sales_analytics_executor]
    WITH PASSWORD = 'Change_This_Strong_Password_123!';
END;
GO

/*==============================================================
    2. Create database user in DataOps_Control

    Test database user:
    - user_sales_analytics_executor
==============================================================*/

USE [DataOps_Control];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE [name] = 'user_sales_analytics_executor'
)
BEGIN
    CREATE USER [user_sales_analytics_executor]
    FOR LOGIN [login_sales_analytics_executor];
END;
GO

/*==============================================================
    3. Add database user to project executor role

    This grants the permissions defined for project execution:
    - Read metadata and reference data.
    - Execute runtime and observability procedures.
    - Insert validation and reconciliation evidence.
    - Read runtime and observability history.
==============================================================*/

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    INNER JOIN sys.database_principals r
        ON r.[principal_id] = drm.[role_principal_id]
    INNER JOIN sys.database_principals m
        ON m.[principal_id] = drm.[member_principal_id]
    WHERE r.[name] = 'DataOps_Project_Executor'
    AND m.[name] = 'user_sales_analytics_executor'
)
BEGIN
    ALTER ROLE [DataOps_Project_Executor]
    ADD MEMBER [user_sales_analytics_executor];
END;
GO

/*==============================================================
    4. Verification
==============================================================*/

SELECT
    r.[name] AS [role_name],
    m.[name] AS [member_name]
FROM sys.database_role_members drm
INNER JOIN sys.database_principals r
    ON r.[principal_id] = drm.[role_principal_id]
INNER JOIN sys.database_principals m
    ON m.[principal_id] = drm.[member_principal_id]
WHERE r.[name] = 'DataOps_Project_Executor'
AND m.[name] = 'user_sales_analytics_executor';
GO