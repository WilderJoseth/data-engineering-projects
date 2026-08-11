-- WARNING:
-- This script is destructive and intended only for the local Oracle XE Docker environment.
-- Do not execute against shared, UAT, certification, or production databases.
-- =============================================================================
-- WARNING          : LOCAL/DEV DOCKER CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
-- Purpose          : Drop standalone source-simulation functions.
-- Execution order  : 92; run after 91_drop_procedures.sql.
-- Connection user  : SYSTEM; CURRENT_SCHEMA is set to ADVENTUREWORKS2022.
-- Objects affected : Standalone functions owned by ADVENTUREWORKS2022.
-- Notes            : Idempotent when no standalone functions exist.
-- =============================================================================

SET SERVEROUTPUT ON
ALTER SESSION SET CURRENT_SCHEMA = ADVENTUREWORKS2022;

PROMPT [92] Dropping ADVENTUREWORKS2022 functions...

BEGIN
  FOR R IN (
    SELECT OBJECT_NAME
    FROM ALL_OBJECTS
    WHERE OWNER = 'ADVENTUREWORKS2022'
      AND OBJECT_TYPE = 'FUNCTION'
    ORDER BY OBJECT_NAME
  ) LOOP
    EXECUTE IMMEDIATE
      'DROP FUNCTION ADVENTUREWORKS2022.' ||
      DBMS_ASSERT.ENQUOTE_NAME(R.OBJECT_NAME, FALSE);
    DBMS_OUTPUT.PUT_LINE('Dropped function: ' || R.OBJECT_NAME);
  END LOOP;
END;
/

PROMPT [92] Function cleanup complete.
