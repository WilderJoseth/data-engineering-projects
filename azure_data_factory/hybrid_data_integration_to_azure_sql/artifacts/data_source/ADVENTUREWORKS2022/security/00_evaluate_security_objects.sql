/*
    Script: 00_evaluate_security_objects.sql
    Source: ADVENTUREWORKS2022

    Purpose:
        Report whether the Oracle read-only integration configuration is ready.

    Flow:
        1. Check the user, reusable role, connection privilege, and membership.
        2. Check SELECT coverage for source tables and views.

    Notes:
        - Read-only; run as an account with DBA catalog visibility.
        - READY means every current table/view has a role grant.
*/
SET PAGESIZE 100
SET LINESIZE 200
COLUMN check_name FORMAT A45
COLUMN status FORMAT A12

SELECT 'Oracle user' check_name, CASE WHEN EXISTS (SELECT 1 FROM dba_users WHERE username = 'USER_HDI_ADF_READER') THEN 'READY' ELSE 'MISSING' END status FROM dual
UNION ALL
SELECT 'Reusable integration role', CASE WHEN EXISTS (SELECT 1 FROM dba_roles WHERE role = 'ROLE_INTEGRATION_READER') THEN 'READY' ELSE 'MISSING' END FROM dual
UNION ALL
SELECT 'CREATE SESSION privilege', CASE WHEN EXISTS (SELECT 1 FROM dba_sys_privs WHERE grantee = 'USER_HDI_ADF_READER' AND privilege = 'CREATE SESSION') THEN 'READY' ELSE 'MISSING' END FROM dual
UNION ALL
SELECT 'Role membership', CASE WHEN EXISTS (SELECT 1 FROM dba_role_privs WHERE grantee = 'USER_HDI_ADF_READER' AND granted_role = 'ROLE_INTEGRATION_READER') THEN 'READY' ELSE 'MISSING' END FROM dual
UNION ALL
SELECT 'SELECT on all tables/views', CASE WHEN NOT EXISTS (
    SELECT 1 FROM dba_objects o WHERE o.owner = 'ADVENTUREWORKS2022' AND o.object_type IN ('TABLE', 'VIEW')
    AND NOT EXISTS (SELECT 1 FROM dba_tab_privs p WHERE p.owner = o.owner AND p.table_name = o.object_name AND p.grantee = 'ROLE_INTEGRATION_READER' AND p.privilege = 'SELECT')
) THEN 'READY' ELSE 'MISSING' END FROM dual;
