/*
    Script: 01_create_security_objects.sql
    Database: DataOps_Control

    Purpose:
        Create the DEV ADF external user and assign its existing DataOps role.

    Flow:
        1. Validate the database context.
        2. Create the ADF external user if missing.
        3. Validate the reusable role and add missing membership.
        4. Return a concise verification result.

    Notes:
        - [role_dataops_operator] must already exist; its definition and grants are not modified.
        - The ADF managed-identity user name is environment-specific.
*/

-- Validate database context
IF DB_NAME() <> N'DataOps_Control'
BEGIN
    ;THROW 50000,
        'This script must be executed against [DataOps_Control].',
        1;
END;

-- Create ADF external user
IF USER_ID(N'adf-hdi-dev-aue-001') IS NULL
BEGIN
    CREATE USER [adf-hdi-dev-aue-001]
        FROM EXTERNAL PROVIDER;
END;

-- Validate reusable role
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals AS dp
    WHERE dp.[name] = N'role_dataops_operator'
      AND dp.[type] = 'R'
)
BEGIN
    ;THROW 50001,
        'Required role [role_dataops_operator] does not exist in [DataOps_Control].',
        1;
END;

-- Add role membership
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members AS drm
    INNER JOIN sys.database_principals AS r
        ON r.[principal_id] = drm.[role_principal_id]
    INNER JOIN sys.database_principals AS m
        ON m.[principal_id] = drm.[member_principal_id]
    WHERE r.[name] = N'role_dataops_operator'
      AND m.[name] = N'adf-hdi-dev-aue-001'
)
BEGIN
    ALTER ROLE [role_dataops_operator]
        ADD MEMBER [adf-hdi-dev-aue-001];
END;
GO

-- Validate configuration
SELECT
    N'adf-hdi-dev-aue-001' AS [user_name],
    N'role_dataops_operator' AS [role_name],
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
    END AS [status];
GO
