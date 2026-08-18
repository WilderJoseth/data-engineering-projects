/*
    Script: 00_evaluate_security_objects.sql
    Source: Sales_Operational

    Purpose:
        Report whether the SQL Server read-only integration configuration is ready.

    Flow:
        1. Check the login, database user, reusable role, and membership.
        2. Check the role's SELECT permission on the required schema.

    Notes:
        - Read-only; run with access to server and database catalogs.
        - The required source schema is [prod].
*/
USE [Sales_Operational];
GO

SELECT [check_name], [status]
FROM (VALUES
    (N'Server login', CASE WHEN SUSER_ID(N'login_hdi_adf_reader') IS NOT NULL THEN N'READY' ELSE N'MISSING' END),
    (N'Database user', CASE WHEN USER_ID(N'user_hdi_adf_reader') IS NOT NULL THEN N'READY' ELSE N'MISSING' END),
    (N'Reusable integration role', CASE WHEN DATABASE_PRINCIPAL_ID(N'role_integration_reader') IS NOT NULL THEN N'READY' ELSE N'MISSING' END),
    (N'Role membership', CASE WHEN EXISTS (
        SELECT 1 FROM sys.database_role_members drm
        JOIN sys.database_principals r ON r.[principal_id] = drm.[role_principal_id]
        JOIN sys.database_principals m ON m.[principal_id] = drm.[member_principal_id]
        WHERE r.[name] = N'role_integration_reader' AND m.[name] = N'user_hdi_adf_reader'
    ) THEN N'READY' ELSE N'MISSING' END),
    (N'SELECT on [prod] schema', CASE WHEN EXISTS (
        SELECT 1 FROM sys.database_permissions p
        JOIN sys.database_principals r ON r.[principal_id] = p.[grantee_principal_id]
        WHERE r.[name] = N'role_integration_reader' AND p.[class] = 3
          AND p.[major_id] = SCHEMA_ID(N'prod') AND p.[permission_name] = N'SELECT' AND p.[state] IN ('G', 'W')
    ) THEN N'READY' ELSE N'MISSING' END)
) s([check_name], [status]);
GO
