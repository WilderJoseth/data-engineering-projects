/*
    Script: create_project_executor_user_template.sql
    Database: DataOps_Control

    Purpose:
    - Creates a SQL Server login and database user for a project/service account.
    - Adds the database user to the DataOps_Project_Executor role.
    - This script is intended as a model for granting a consuming project access
      to the DataOps_Control framework.

    Security model:
    - The login represents the project or service account.
    - The database user maps that login inside DataOps_Control.
    - The DataOps_Project_Executor role provides the required framework permissions.

    Notes:
    - Use a strong password in real environments.
    - For production, prefer a dedicated service account per project.
    - This script assumes the role DataOps_Project_Executor already exists.
*/

USE [master];
GO

/*==============================================================
    1. Create SQL Server login

    Test login:
    - login_test_executor

    Replace the password before using this in a real environment.
==============================================================*/

IF NOT EXISTS (
    SELECT 1
    FROM sys.server_principals
    WHERE [name] = 'login_test_executor'
)
BEGIN
    CREATE LOGIN [login_test_executor]
    WITH PASSWORD = 'Change_This_Strong_Password_123!';
END;
GO

/*==============================================================
    2. Create database user in DataOps_Control

    Test database user:
    - user_test_executor
==============================================================*/

USE [DataOps_Control];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE [name] = 'user_test_executor'
)
BEGIN
    CREATE USER [user_test_executor]
    FOR LOGIN [login_test_executor];
END;
GO

/*==============================================================
    3. Add database user to project executor role

    This grants the permissions defined for project execution:
    - Read metadata and reference data.
    - Execute runtime and observability procedures.
    - Insert validation, reconciliation, and monitoring evidence.
    - Log technical errors only through observability.usp_log_error.
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
    AND m.[name] = 'user_test_executor'
)
BEGIN
    ALTER ROLE [DataOps_Project_Executor]
    ADD MEMBER [user_test_executor];
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
AND m.[name] = 'user_test_executor';
GO
