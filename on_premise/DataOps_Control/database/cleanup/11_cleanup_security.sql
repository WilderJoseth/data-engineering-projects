/*============================================================================
  DataOps_Control
  Cleanup Script: Security

  Purpose:
  - Drops database roles created by database/ddl/09_create_security.sql.

  Notes:
  - Roles must have no members before they can be dropped.
============================================================================*/

USE [DataOps_Control];
GO

DECLARE @drop_role_members_sql NVARCHAR(MAX) = N'';

SELECT
    @drop_role_members_sql = @drop_role_members_sql
        + N'ALTER ROLE '
        + QUOTENAME(role_principal.[name])
        + N' DROP MEMBER '
        + QUOTENAME(member_principal.[name])
        + N';' + CHAR(13) + CHAR(10)
FROM sys.database_role_members role_members
INNER JOIN sys.database_principals role_principal
    ON role_principal.[principal_id] = role_members.[role_principal_id]
INNER JOIN sys.database_principals member_principal
    ON member_principal.[principal_id] = role_members.[member_principal_id]
WHERE role_principal.[name] IN
(
    'DataOps_Admin',
    'DataOps_Project_Executor'
);

IF @drop_role_members_sql <> N''
BEGIN
    EXEC sys.sp_executesql @drop_role_members_sql;
END;
GO

DROP ROLE IF EXISTS [DataOps_Project_Executor];
GO

DROP ROLE IF EXISTS [DataOps_Admin];
GO
