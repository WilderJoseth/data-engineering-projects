/*
    Script: create_dataops_admin_user.sql
    Database: DataOps_Control

    Purpose:
    - Creates a SQL Server login and database user for a DataOps_Control administrator.
    - Adds the database user to the DataOps_Admin role.
    - This script is intended as a template for local testing or controlled admin onboarding.

    Security model:
    - The login represents a framework administrator or deployment account.
    - The database user maps that login inside DataOps_Control.
    - The DataOps_Admin role provides permissions to maintain framework metadata,
      reference data, runtime records, and observability records.

    Notes:
    - Use a strong password in real environments.
    - Do not use shared admin accounts in production.
    - This script assumes the DataOps_Admin role already exists.
*/

USE [master];
GO

/*==============================================================
    1. Create SQL Server login

    Test login:
    - login_dataops_admin

    Replace the password before using this in a real environment.
==============================================================*/

IF NOT EXISTS (
    SELECT 1
    FROM sys.server_principals
    WHERE [name] = 'login_dataops_admin'
)
BEGIN
    CREATE LOGIN [login_dataops_admin]
    WITH PASSWORD = 'Change_This_Strong_Password_123!';
END;
GO

/*==============================================================
    2. Create database user in DataOps_Control

    Test database user:
    - user_dataops_admin
==============================================================*/

USE [DataOps_Control];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE [name] = 'user_dataops_admin'
)
BEGIN
    CREATE USER [user_dataops_admin]
    FOR LOGIN [login_dataops_admin];
END;
GO

/*==============================================================
    3. Add database user to admin role

    This grants the permissions defined for framework administration:
    - Maintain metadata and reference data.
    - Read and maintain runtime and observability records.
    - Execute framework procedures.
==============================================================*/

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    INNER JOIN sys.database_principals r
        ON r.[principal_id] = drm.[role_principal_id]
    INNER JOIN sys.database_principals m
        ON m.[principal_id] = drm.[member_principal_id]
    WHERE r.[name] = 'DataOps_Admin'
      AND m.[name] = 'user_dataops_admin'
)
BEGIN
    ALTER ROLE [DataOps_Admin]
    ADD MEMBER [user_dataops_admin];
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
WHERE r.[name] = 'DataOps_Admin'
  AND m.[name] = 'user_dataops_admin';
GO