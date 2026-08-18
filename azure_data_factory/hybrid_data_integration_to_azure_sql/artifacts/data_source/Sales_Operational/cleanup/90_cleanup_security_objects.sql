/*
    Script: 90_cleanup_security_objects.sql
    Source: Sales_Operational

    Purpose:
        Remove only the project-specific SQL Server integration identity.

    Flow:
        1. Remove role membership and drop the database user when present.
        2. Drop the server login when present.

    Notes:
        - Idempotent; run with database and server security privileges.
        - [role_integration_reader] is reusable and is never removed.
*/
USE [Sales_Operational];
GO

-- Remove role membership
IF IS_ROLEMEMBER(N'role_integration_reader', N'user_hdi_adf_reader') = 1
    ALTER ROLE [role_integration_reader] DROP MEMBER [user_hdi_adf_reader];
GO

-- Drop database user
IF USER_ID(N'user_hdi_adf_reader') IS NOT NULL
    DROP USER [user_hdi_adf_reader];
GO

USE [master];
GO
-- Drop server login
IF SUSER_ID(N'login_hdi_adf_reader') IS NOT NULL
    DROP LOGIN [login_hdi_adf_reader];
GO
