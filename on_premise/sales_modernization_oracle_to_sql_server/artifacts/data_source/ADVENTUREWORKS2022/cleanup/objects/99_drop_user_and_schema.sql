-- WARNING:
-- This script is destructive and intended only for the local Oracle XE Docker environment.
-- Do not execute against shared, UAT, certification, or production databases.
-- =============================================================================
-- WARNING          : LOCAL/DEV DOCKER CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
-- Purpose          : Remove the ADVENTUREWORKS2022 user/schema after optional
--                    object-level cleanup, enabling a clean DDL rebuild.
-- Execution order  : 99; final and optional full-reset script.
-- Connection user  : SYSTEM, or another local administrative account with
--                    DROP USER privilege. Do not connect as ADVENTUREWORKS2022.
-- Objects affected : User/schema ADVENTUREWORKS2022 and any remaining objects
--                    or data owned by that user.
-- Notes            : DROP USER ... CASCADE is destructive and irreversible.
--                    Disconnect all ADVENTUREWORKS2022 sessions first. The
--                    existence check makes repeated local runs safe.
-- =============================================================================

SET SERVEROUTPUT ON

PROMPT [99] Dropping the ADVENTUREWORKS2022 local/dev user and schema...

DECLARE
  V_USER_COUNT PLS_INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO V_USER_COUNT
  FROM ALL_USERS
  WHERE USERNAME = 'ADVENTUREWORKS2022';

  IF V_USER_COUNT = 1 THEN
    EXECUTE IMMEDIATE 'DROP USER ADVENTUREWORKS2022 CASCADE';
    DBMS_OUTPUT.PUT_LINE(
      'ADVENTUREWORKS2022 and all remaining owned objects were removed.'
    );
  ELSE
    DBMS_OUTPUT.PUT_LINE(
      'ADVENTUREWORKS2022 does not exist; no cleanup action was required.'
    );
  END IF;
END;
/

PROMPT [99] Full reset complete. Re-run ddl/01_create_user_and_schema.sql.
