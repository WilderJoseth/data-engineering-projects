/*
    Script: 01_create_security_objects.sql
    Source: ADVENTUREWORKS2022

    Purpose:
        Configure least-privilege Oracle access for the integration identity.

    Flow:
        1. Create the user and reusable integration role when missing.
        2. Grant connection privilege and role membership.
        3. Grant the role SELECT on current source tables and views.

    Notes:
        - Run in SQL*Plus or SQLcl as an appropriately privileged account.
        - Replace the placeholder password before execution; never commit a real password.
        - A failure stops the script before dependent grants are attempted.
*/
WHENEVER SQLERROR EXIT SQL.SQLCODE

-- Create Oracle user
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM dba_users WHERE username = 'USER_HDI_ADF_READER';
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE
            'CREATE USER USER_HDI_ADF_READER IDENTIFIED BY "OraclePwd_123!"';
    END IF;
END;
/

-- Create integration role
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM dba_roles WHERE role = 'ROLE_INTEGRATION_READER';
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE ROLE ROLE_INTEGRATION_READER';
    END IF;
END;
/

-- Grant connection and membership
GRANT CREATE SESSION TO USER_HDI_ADF_READER;
GRANT ROLE_INTEGRATION_READER TO USER_HDI_ADF_READER;

-- Grant read permissions
BEGIN
    FOR obj IN (SELECT object_name FROM dba_objects WHERE owner = 'ADVENTUREWORKS2022' AND object_type IN ('TABLE', 'VIEW')) LOOP
        EXECUTE IMMEDIATE 'GRANT SELECT ON ADVENTUREWORKS2022.' || DBMS_ASSERT.ENQUOTE_NAME(obj.object_name, FALSE) || ' TO ROLE_INTEGRATION_READER';
    END LOOP;
END;
/
WHENEVER SQLERROR CONTINUE NONE
