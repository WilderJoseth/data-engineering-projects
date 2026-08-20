/*
    Script: 01_create_security_objects.sql
    Database: Enterprise_Operational

    Purpose:
        Configure least-privilege Azure SQL access for the ADF
        system-assigned managed identity.

    Flow:
        1. Validate the target database.
        2. Create the database user mapped to the ADF managed identity.
        3. Create the integration role.
        4. Add the integration user to the role.
        5. Grant required permissions on the [prod] schema.

    Notes:
        - Run against [Enterprise_Operational] as a Microsoft Entra principal
          authorized to create external users.
        - The ADF managed-identity user name is environment-specific.
*/

IF DB_NAME() <> N'Enterprise_Operational'
BEGIN
    ;THROW 50000,
        'This script must be executed against [Enterprise_Operational].',
        1;
END;
GO

-- Create database user
IF USER_ID(N'adf-hdi-dev-aue-001') IS NULL
BEGIN
    CREATE USER [adf-hdi-dev-aue-001]
        FROM EXTERNAL PROVIDER;
END;
GO

-- Create integration role
IF DATABASE_PRINCIPAL_ID(N'role_integration_operator') IS NULL
BEGIN
    CREATE ROLE [role_integration_operator];
END;
GO

-- Add user to role
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members AS drm
    INNER JOIN sys.database_principals AS r
        ON r.[principal_id] = drm.[role_principal_id]
    INNER JOIN sys.database_principals AS m
        ON m.[principal_id] = drm.[member_principal_id]
    WHERE r.[name] = N'role_integration_operator'
      AND m.[name] = N'adf-hdi-dev-aue-001'
)
BEGIN
    ALTER ROLE [role_integration_operator]
        ADD MEMBER [adf-hdi-dev-aue-001];
END;
GO

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE
ON SCHEMA::[prod]
TO [role_integration_operator];
GO
