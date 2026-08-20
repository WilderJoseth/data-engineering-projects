/*
    Script: 02_validate_permissions.sql
    Database: Enterprise_Operational

    Purpose:
        Provide detailed read-only validation of Azure SQL integration permissions.

    Flow:
        1. Display the ADF managed identity database principal.
        2. Display role membership and effective role permissions.
        3. List missing and unexpected permissions.

    Notes:
        - Run in [Enterprise_Operational].
        - Unexpected results require review; this script makes no changes.
*/
IF DB_NAME() <> N'Enterprise_Operational'
BEGIN
    ;THROW 50000,
        'This script must be executed against [Enterprise_Operational].',
        1;
END;

-- Validate database user
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
    m.[name] AS [member_name]
FROM sys.database_role_members AS drm
INNER JOIN sys.database_principals AS r
    ON r.[principal_id] = drm.[role_principal_id]
INNER JOIN sys.database_principals AS m
    ON m.[principal_id] = drm.[member_principal_id]
WHERE r.[name] = N'role_integration_operator'
  AND m.[name] = N'adf-hdi-dev-aue-001';

-- Validate granted permissions
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
    N'role_integration_operator',
    N'adf-hdi-dev-aue-001'
)
ORDER BY
    r.[name],
    p.[permission_name];

-- Missing required permissions
SELECT
    N'MISSING PERMISSION' AS [finding],
    required.[permission_name],
    N'prod' AS [securable]
FROM (VALUES
    (N'SELECT'),
    (N'INSERT'),
    (N'UPDATE'),
    (N'DELETE'),
    (N'EXECUTE')
) AS required([permission_name])
WHERE NOT EXISTS (
    SELECT 1
    FROM sys.database_permissions AS p
    INNER JOIN sys.database_principals AS r
        ON r.[principal_id] = p.[grantee_principal_id]
    WHERE r.[name] = N'role_integration_operator'
      AND p.[class] = 3
      AND p.[major_id] = SCHEMA_ID(N'prod')
      AND p.[permission_name] = required.[permission_name]
      AND p.[state] IN ('G', 'W')
);

-- Unexpected permissions
SELECT
    N'UNEXPECTED PERMISSION' AS [finding],
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
WHERE
    (
        r.[name] = N'adf-hdi-dev-aue-001'
        AND NOT (
            p.[class] = 0
            AND p.[permission_name] = N'CONNECT'
            AND p.[state] IN ('G', 'W')
        )
    )
    OR
    (
        r.[name] = N'role_integration_operator'
        AND NOT (
            p.[class] = 3
            AND p.[major_id] = SCHEMA_ID(N'prod')
            AND p.[permission_name] IN (N'SELECT', N'INSERT', N'UPDATE', N'DELETE', N'EXECUTE')
            AND p.[state] IN ('G', 'W')
        )
    );
GO
