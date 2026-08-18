/*
    Script: 90_cleanup_security_objects.sql
    Source: ADVENTUREWORKS2022

    Purpose:
        Remove only the project-specific Oracle integration identity.

    Flow:
        1. Drop USER_HDI_ADF_READER when it exists.

    Notes:
        - Idempotent; CASCADE removes grants owned by the user.
        - ROLE_INTEGRATION_READER is reusable and is never removed.
*/
-- Drop Oracle user
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM dba_users WHERE username = 'USER_HDI_ADF_READER';
    IF v_count > 0 THEN
        EXECUTE IMMEDIATE 'DROP USER USER_HDI_ADF_READER CASCADE';
    END IF;
END;
/
