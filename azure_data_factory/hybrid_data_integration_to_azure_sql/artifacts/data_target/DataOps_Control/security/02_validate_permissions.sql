/*
    Script: 02_validate_permissions.sql
    Database: DataOps_Control

    Purpose:
        Provide detailed read-only validation of ADF access to DataOps_Control.

    Flow:
        1. Validate the database context and external ADF user.
        2. Display role membership and permissions inherited through the role.
        3. Report unexpected direct permissions on the ADF user.

    Notes:
        - Read-only; role permissions are owned by the DataOps_Control project.
        - The connection-level CONNECT permission is not treated as business access.
*/

-- Validate database context
IF DB_NAME() <> N'DataOps_Control'
BEGIN
    ;THROW 50000,
        'This script must be executed against [DataOps_Control].',
        1;
END;

-- Validate configuration
SELECT
    s.[check_name],
    s.[status]
FROM (VALUES
    (
        N'Database user',
        CASE WHEN USER_ID(N'adf-hdi-dev-aue-001') IS NOT NULL
            THEN N'READY' ELSE N'MISSING' END
    ),
    (
        N'External Microsoft Entra principal',
        CASE WHEN EXISTS (
            SELECT 1
            FROM sys.database_principals AS dp
            WHERE dp.[name] = N'adf-hdi-dev-aue-001'
              AND dp.[type] = 'E'
              AND dp.[authentication_type_desc] = N'EXTERNAL'
        ) THEN N'READY' ELSE N'MISSING' END
    ),
    (
        N'Reusable DataOps role',
        CASE WHEN EXISTS (
            SELECT 1
            FROM sys.database_principals AS dp
            WHERE dp.[name] = N'role_dataops_operator'
              AND dp.[type] = 'R'
        ) THEN N'READY' ELSE N'MISSING' END
    ),
    (
        N'Role membership',
        CASE WHEN EXISTS (
            SELECT 1
            FROM sys.database_role_members AS drm
            INNER JOIN sys.database_principals AS r
                ON r.[principal_id] = drm.[role_principal_id]
            INNER JOIN sys.database_principals AS m
                ON m.[principal_id] = drm.[member_principal_id]
            WHERE r.[name] = N'role_dataops_operator'
              AND m.[name] = N'adf-hdi-dev-aue-001'
        ) THEN N'READY' ELSE N'MISSING' END
    )
) AS s([check_name], [status]);

-- Validate ADF external user
SELECT
    dp.[name] AS [user_name],
    dp.[type_desc],
    dp.[authentication_type_desc],
    CASE
        WHEN dp.[type] = 'E'
         AND dp.[authentication_type_desc] = N'EXTERNAL' THEN N'EXPECTED'
        ELSE N'UNEXPECTED PRINCIPAL TYPE'
    END AS [principal_validation],
    dp.[sid]
FROM sys.database_principals AS dp
WHERE dp.[name] = N'adf-hdi-dev-aue-001';

-- Validate role membership
SELECT
    r.[name] AS [role_name],
    m.[name] AS [member_name],
    CASE
        WHEN r.[name] = N'role_dataops_operator' THEN N'EXPECTED'
        ELSE N'REVIEW'
    END AS [membership_validation]
FROM sys.database_role_members AS drm
INNER JOIN sys.database_principals AS r
    ON r.[principal_id] = drm.[role_principal_id]
INNER JOIN sys.database_principals AS m
    ON m.[principal_id] = drm.[member_principal_id]
WHERE m.[name] = N'adf-hdi-dev-aue-001';

-- Validate permissions inherited through role
SELECT
    r.[name] AS [role_name],
    p.[state_desc],
    p.[permission_name],
    p.[class_desc],
    CASE
        WHEN p.[class] = 3 THEN SCHEMA_NAME(p.[major_id])
        WHEN p.[class] = 1 THEN OBJECT_SCHEMA_NAME(p.[major_id])
            + N'.' + OBJECT_NAME(p.[major_id])
        ELSE DB_NAME()
    END AS [securable]
FROM sys.database_permissions AS p
INNER JOIN sys.database_principals AS r
    ON r.[principal_id] = p.[grantee_principal_id]
WHERE r.[name] = N'role_dataops_operator'
ORDER BY
    p.[class_desc],
    [securable],
    p.[permission_name];

-- Validate direct permissions
SELECT
    N'UNEXPECTED DIRECT PERMISSION' AS [finding],
    dp.[name] AS [grantee],
    p.[state_desc],
    p.[permission_name],
    p.[class_desc],
    CASE
        WHEN p.[class] = 3 THEN SCHEMA_NAME(p.[major_id])
        WHEN p.[class] = 1 THEN OBJECT_SCHEMA_NAME(p.[major_id])
            + N'.' + OBJECT_NAME(p.[major_id])
        ELSE DB_NAME()
    END AS [securable]
FROM sys.database_permissions AS p
INNER JOIN sys.database_principals AS dp
    ON dp.[principal_id] = p.[grantee_principal_id]
WHERE dp.[name] = N'adf-hdi-dev-aue-001'
  AND NOT (
      p.[class] = 0
      AND p.[permission_name] = N'CONNECT'
      AND p.[state] IN ('G', 'W')
  )
ORDER BY
    p.[class_desc],
    [securable],
    p.[permission_name];
GO
