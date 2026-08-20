/*
    Script: 00_evaluate_security_objects.sql
    Database: DataOps_Control

    Purpose:
        Report whether the ADF security configuration is ready.

    Flow:
        1. Validate the database context.
        2. Check the external ADF user and reusable role.
        3. Check role membership.

    Notes:
        - Read-only; run in [DataOps_Control].
        - Role permissions are managed by the shared DataOps_Control project.
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
        N'Reusable DataOps role',
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM sys.database_principals AS dp
                WHERE dp.[name] = N'role_dataops_operator'
                  AND dp.[type] = 'R'
            ) THEN N'READY'
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
                WHERE r.[name] = N'role_dataops_operator'
                  AND m.[name] = N'adf-hdi-dev-aue-001'
            ) THEN N'READY'
            ELSE N'MISSING'
        END
    )
) AS s([check_name], [status]);
GO
