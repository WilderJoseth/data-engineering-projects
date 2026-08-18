/*
    Script: 02_validate_permissions.sql
    Source: ADVENTUREWORKS2022

    Purpose:
        Provide detailed read-only validation of Oracle integration permissions.

    Flow:
        1. Display membership, system privileges, and expected SELECT grants.
        2. List missing SELECT grants and unexpected privileges.

    Notes:
        - Run as an account with DBA catalog visibility.
        - Unexpected results require review; this script makes no changes.
*/
SET PAGESIZE 500
SET LINESIZE 220

-- Validate configuration
SELECT grantee, granted_role, admin_option, default_role FROM dba_role_privs WHERE grantee = 'USER_HDI_ADF_READER';
SELECT grantee, privilege, admin_option FROM dba_sys_privs WHERE grantee IN ('USER_HDI_ADF_READER', 'ROLE_INTEGRATION_READER') ORDER BY grantee, privilege;
SELECT owner, table_name, privilege FROM dba_tab_privs WHERE grantee = 'ROLE_INTEGRATION_READER' AND owner = 'ADVENTUREWORKS2022' ORDER BY table_name, privilege;

-- Missing read permissions
SELECT o.object_name, o.object_type, 'MISSING SELECT' finding
FROM dba_objects o
WHERE o.owner = 'ADVENTUREWORKS2022' AND o.object_type IN ('TABLE', 'VIEW')
  AND NOT EXISTS (SELECT 1 FROM dba_tab_privs p WHERE p.owner = o.owner AND p.table_name = o.object_name AND p.grantee = 'ROLE_INTEGRATION_READER' AND p.privilege = 'SELECT')
ORDER BY o.object_type, o.object_name;

-- Unexpected permissions
SELECT 'DIRECT USER OBJECT GRANT' finding, owner, table_name object_name, privilege FROM dba_tab_privs WHERE grantee = 'USER_HDI_ADF_READER'
UNION ALL
SELECT 'ROLE NON-SELECT GRANT', owner, table_name, privilege FROM dba_tab_privs WHERE grantee = 'ROLE_INTEGRATION_READER' AND privilege <> 'SELECT'
UNION ALL
SELECT 'ROLE OUTSIDE SOURCE', owner, table_name, privilege FROM dba_tab_privs WHERE grantee = 'ROLE_INTEGRATION_READER' AND owner <> 'ADVENTUREWORKS2022'
ORDER BY finding, owner, object_name;
