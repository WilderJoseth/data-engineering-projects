/*
    Script: 90_cleanup_security_objects.sql
    Database: Enterprise_Operational

    Purpose:
        Remove only the DEV ADF managed-identity database user.

    Flow:
        1. Remove the ADF user from the integration role.
        2. Drop the database user.

    Notes:
        - Destructive; use only for rollback or environment cleanup.
        - This script does not modify the ADF managed identity in Azure.
        - [role_integration_operator] is reusable and is never removed.
*/
IF DB_NAME() <> N'Enterprise_Operational'
BEGIN
    ;THROW 50000,
        'This script must be executed against [Enterprise_Operational].',
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
    WHERE r.[name] = N'role_integration_operator'
      AND m.[name] = N'adf-hdi-dev-aue-001'
)
    ALTER ROLE [role_integration_operator] DROP MEMBER [adf-hdi-dev-aue-001];
GO

-- Drop database user
IF USER_ID(N'adf-hdi-dev-aue-001') IS NOT NULL
    DROP USER [adf-hdi-dev-aue-001];
GO
