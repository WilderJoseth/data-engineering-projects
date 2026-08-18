/*
    Script: 01_create_security_objects.sql
    Source: Sales_Operational

    Purpose:
        Configure least-privilege SQL Server access for the integration identity.

    Flow:
        1. Create the server login, database user, and reusable role when missing.
        2. Add the user to the role.
        3. Grant the role SELECT on the required source schema.

    Notes:
        - Replace the placeholder password before execution; never commit a real password.
*/
USE [master];
GO

-- Create server login
IF SUSER_ID(N'login_hdi_adf_reader') IS NULL
BEGIN
    CREATE LOGIN [login_hdi_adf_reader]
    WITH PASSWORD = 'SQLServerPwd_123!';
END;
GO

USE [Sales_Operational];
GO
-- Create database user
IF USER_ID(N'user_hdi_adf_reader') IS NULL
    CREATE USER [user_hdi_adf_reader] FOR LOGIN [login_hdi_adf_reader];
GO

-- Create integration role
IF DATABASE_PRINCIPAL_ID(N'role_integration_reader') IS NULL
    CREATE ROLE [role_integration_reader];
GO

-- Add role membership
IF NOT EXISTS (
    SELECT 1 FROM sys.database_role_members drm
    JOIN sys.database_principals r ON r.[principal_id] = drm.[role_principal_id]
    JOIN sys.database_principals m ON m.[principal_id] = drm.[member_principal_id]
    WHERE r.[name] = N'role_integration_reader' AND m.[name] = N'user_hdi_adf_reader'
)
    ALTER ROLE [role_integration_reader] ADD MEMBER [user_hdi_adf_reader];
GO

-- Grant read permissions
GRANT SELECT ON SCHEMA::[prod] TO [role_integration_reader];
GO
