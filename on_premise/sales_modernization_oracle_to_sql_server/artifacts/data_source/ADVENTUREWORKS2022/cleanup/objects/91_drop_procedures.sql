-- WARNING:
-- This script is destructive and intended only for the local Oracle XE Docker environment.
-- Do not execute against shared, UAT, certification, or production databases.
-- =============================================================================
-- WARNING          : LOCAL/DEV DOCKER CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
-- Purpose          : Drop standalone source-simulation procedures.
-- Execution order  : 91; run after 90_drop_views.sql.
-- Connection user  : SYSTEM; CURRENT_SCHEMA is set to ADVENTUREWORKS2022.
-- Objects affected : Standalone procedures owned by ADVENTUREWORKS2022.
-- Notes            : Idempotent when no standalone procedures exist.
-- =============================================================================

SET SERVEROUTPUT ON
ALTER SESSION SET CURRENT_SCHEMA = ADVENTUREWORKS2022;

PROMPT [91] Dropping ADVENTUREWORKS2022 procedures...

BEGIN
  FOR R IN (
    SELECT OBJECT_NAME
    FROM ALL_OBJECTS
    WHERE OWNER = 'ADVENTUREWORKS2022'
      AND OBJECT_TYPE = 'PROCEDURE'
    ORDER BY OBJECT_NAME
  ) LOOP
    EXECUTE IMMEDIATE
      'DROP PROCEDURE ADVENTUREWORKS2022.' ||
      DBMS_ASSERT.ENQUOTE_NAME(R.OBJECT_NAME, FALSE);
    DBMS_OUTPUT.PUT_LINE('Dropped procedure: ' || R.OBJECT_NAME);
  END LOOP;
END;
/

PROMPT [91] Procedure cleanup complete.
