/*
    Script: 00_evaluate_security_objects.sql
    Database: Enterprise_Operational

    Purpose:
        Report whether the Azure SQL integration security configuration is ready.

    Flow:
        1. Check the ADF managed identity user and its external principal type.
        2. Check the reusable role, membership, and required [prod] permissions.

    Notes:
        - Read-only; run in [Enterprise_Operational].
        - The database user represents the ADF managed identity.
        - The required target schema is [prod].
*/
IF DB_NAME() <> N'Enterprise_Operational'
BEGIN
    ;THROW 50000,
        'This script must be executed against [Enterprise_Operational].',
        1;
END;

-- Validate security objects
SELECT [check_name], [status]
FROM (VALUES
    (
        N'Database user',
        CASE
            WHEN USER_ID(N'adf-hdi-dev-aue-001') IS NOT NULL THEN N'READY'
            ELSE N'MISSING'
        END
    ),
    (
        N'External Microsoft Entra principal',
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM sys.database_principals AS dp
                WHERE dp.[name] = N'adf-hdi-dev-aue-001'
                  AND dp.[type] = 'E'
                  AND dp.[authentication_type_desc] = N'EXTERNAL'
            ) THEN N'READY'
            ELSE N'MISSING'
        END
    ),
    (
        N'Reusable integration role',
        CASE
            WHEN DATABASE_PRINCIPAL_ID(N'role_integration_operator') IS NOT NULL THEN N'READY'
            ELSE N'MISSING'
        END
    ),
    (
        N'Role membership',
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM sys.database_role_members AS drm
                INNER JOIN sys.database_principals AS r
                    ON r.[principal_id] = drm.[role_principal_id]
                INNER JOIN sys.database_principals AS m
                    ON m.[principal_id] = drm.[member_principal_id]
                WHERE r.[name] = N'role_integration_operator'
                  AND m.[name] = N'adf-hdi-dev-aue-001'
            ) THEN N'READY'
            ELSE N'MISSING'
        END
    ),
    (
        N'SELECT on [prod] schema',
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM sys.database_permissions AS p
                INNER JOIN sys.database_principals AS r
                    ON r.[principal_id] = p.[grantee_principal_id]
                WHERE r.[name] = N'role_integration_operator'
                  AND p.[class] = 3
                  AND p.[major_id] = SCHEMA_ID(N'prod')
                  AND p.[permission_name] = N'SELECT'
                  AND p.[state] IN ('G', 'W')
            ) THEN N'READY'
            ELSE N'MISSING'
        END
    ),
    (
        N'INSERT on [prod] schema',
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM sys.database_permissions AS p
                INNER JOIN sys.database_principals AS r
                    ON r.[principal_id] = p.[grantee_principal_id]
                WHERE r.[name] = N'role_integration_operator'
                  AND p.[class] = 3
                  AND p.[major_id] = SCHEMA_ID(N'prod')
                  AND p.[permission_name] = N'INSERT'
                  AND p.[state] IN ('G', 'W')
            ) THEN N'READY'
            ELSE N'MISSING'
        END
    ),
    (
        N'UPDATE on [prod] schema',
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM sys.database_permissions AS p
                INNER JOIN sys.database_principals AS r
                    ON r.[principal_id] = p.[grantee_principal_id]
                WHERE r.[name] = N'role_integration_operator'
                  AND p.[class] = 3
                  AND p.[major_id] = SCHEMA_ID(N'prod')
                  AND p.[permission_name] = N'UPDATE'
                  AND p.[state] IN ('G', 'W')
            ) THEN N'READY'
            ELSE N'MISSING'
        END
    ),
    (
        N'DELETE on [prod] schema',
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM sys.database_permissions AS p
                INNER JOIN sys.database_principals AS r
                    ON r.[principal_id] = p.[grantee_principal_id]
                WHERE r.[name] = N'role_integration_operator'
                  AND p.[class] = 3
                  AND p.[major_id] = SCHEMA_ID(N'prod')
                  AND p.[permission_name] = N'DELETE'
                  AND p.[state] IN ('G', 'W')
            ) THEN N'READY'
            ELSE N'MISSING'
        END
    ),
    (
        N'EXECUTE on [prod] schema',
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM sys.database_permissions AS p
                INNER JOIN sys.database_principals AS r
                    ON r.[principal_id] = p.[grantee_principal_id]
                WHERE r.[name] = N'role_integration_operator'
                  AND p.[class] = 3
                  AND p.[major_id] = SCHEMA_ID(N'prod')
                  AND p.[permission_name] = N'EXECUTE'
                  AND p.[state] IN ('G', 'W')
            ) THEN N'READY'
            ELSE N'MISSING'
        END
    )
) AS s([check_name], [status]);
GO
