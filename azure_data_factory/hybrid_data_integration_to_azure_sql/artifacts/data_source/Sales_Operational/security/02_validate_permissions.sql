/*
    Script: 02_validate_permissions.sql
    Source: Sales_Operational

    Purpose:
        Provide detailed read-only validation of SQL Server integration permissions.

    Flow:
        1. Display login mapping, membership, and effective role permissions.
        2. List missing and unexpected permissions.

    Notes:
        - Run with access to server and database catalogs.
        - Unexpected results require review; this script makes no changes.
*/

USE [Sales_Operational];
GO

-- Validate configuration
SELECT
    sp.[name] AS [login_name],
    dp.[name] AS [user_name],
    dp.[authentication_type_desc]
FROM sys.database_principals AS dp
LEFT JOIN sys.server_principals AS sp
    ON sp.[sid] = dp.[sid]
WHERE dp.[name] = N'user_hdi_adf_reader';

SELECT
    r.[name] AS [role_name],
    m.[name] AS [member_name]
FROM sys.database_role_members AS drm
INNER JOIN sys.database_principals AS r
    ON r.[principal_id] = drm.[role_principal_id]
INNER JOIN sys.database_principals AS m
    ON m.[principal_id] = drm.[member_principal_id]
WHERE r.[name] = N'role_integration_reader'
  AND m.[name] = N'user_hdi_adf_reader';

SELECT
    r.[name] AS [grantee],
    p.[state_desc],
    p.[permission_name],
    p.[class_desc],
    CASE
        WHEN p.[class] = 3 THEN SCHEMA_NAME(p.[major_id])
        ELSE OBJECT_NAME(p.[major_id])
    END AS [securable]
FROM sys.database_permissions AS p
INNER JOIN sys.database_principals AS r
    ON r.[principal_id] = p.[grantee_principal_id]
WHERE r.[name] IN (
    N'role_integration_reader',
    N'user_hdi_adf_reader'
)
ORDER BY
    r.[name],
    p.[permission_name];

-- Missing read permission
SELECT
    N'MISSING SELECT ON SCHEMA::[prod]' AS [finding]
WHERE NOT EXISTS (
    SELECT 1
    FROM sys.database_permissions AS p
    INNER JOIN sys.database_principals AS r
        ON r.[principal_id] = p.[grantee_principal_id]
    WHERE r.[name] = N'role_integration_reader'
      AND p.[class] = 3
      AND p.[major_id] = SCHEMA_ID(N'prod')
      AND p.[permission_name] = N'SELECT'
      AND p.[state] IN ('G', 'W')
);

-- Unexpected permissions
SELECT
    N'UNEXPECTED PERMISSION' AS [finding],
    r.[name] AS [grantee],
    p.[state_desc],
    p.[permission_name],
    p.[class_desc]
FROM sys.database_permissions AS p
INNER JOIN sys.database_principals AS r
    ON r.[principal_id] = p.[grantee_principal_id]
WHERE
    (
        r.[name] = N'user_hdi_adf_reader'
        AND NOT (
            p.[class] = 0
            AND p.[permission_name] = N'CONNECT'
            AND p.[state] IN ('G', 'W')
        )
    )
    OR
    (
        r.[name] = N'role_integration_reader'
        AND NOT (
            p.[class] = 3
            AND p.[major_id] = SCHEMA_ID(N'prod')
            AND p.[permission_name] = N'SELECT'
            AND p.[state] IN ('G', 'W')
        )
    );
GO