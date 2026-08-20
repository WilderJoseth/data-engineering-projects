/*
    Script: 90_cleanup_security_objects.sql
    Database: DataOps_Control

    Purpose:
        Remove only the project-specific DEV ADF database identity.

    Flow:
        1. Validate the database context.
        2. Remove existing membership in the reusable DataOps role.
        3. Drop the ADF external user if it exists.

    Notes:
        - Idempotent; no DataOps_Control business objects are modified.
        - [role_dataops_operator] is shared; its definition and grants are preserved.
*/

-- Validate database context
IF DB_NAME() <> N'DataOps_Control'
BEGIN
    ;THROW 50000,
        'This script must be executed against [DataOps_Control].',
        1;
END;

-- Remove role membership
IF EXISTS (
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
        DROP MEMBER [adf-hdi-dev-aue-001];
END;

-- Drop ADF external user
IF USER_ID(N'adf-hdi-dev-aue-001') IS NOT NULL
BEGIN
    DROP USER [adf-hdi-dev-aue-001];
END;
GO
