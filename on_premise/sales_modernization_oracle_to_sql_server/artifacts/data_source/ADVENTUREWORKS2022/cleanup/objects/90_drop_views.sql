-- WARNING:
-- This script is destructive and intended only for the local Oracle XE Docker environment.
-- Do not execute against shared, UAT, certification, or production databases.
-- =============================================================================
-- WARNING          : LOCAL/DEV DOCKER CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
-- Purpose          : Drop the source-simulation views before dependent objects.
-- Execution order  : 90; first object-cleanup script.
-- Connection user  : SYSTEM; CURRENT_SCHEMA is set to ADVENTUREWORKS2022.
-- Objects affected : All views owned by ADVENTUREWORKS2022.
-- Notes            : Idempotent when no views exist. Base tables are unchanged.
-- =============================================================================

SET SERVEROUTPUT ON
ALTER SESSION SET CURRENT_SCHEMA = ADVENTUREWORKS2022;

PROMPT [90] Dropping ADVENTUREWORKS2022 views...

BEGIN
  FOR R IN (
    SELECT VIEW_NAME
    FROM ALL_VIEWS
    WHERE OWNER = 'ADVENTUREWORKS2022'
    ORDER BY VIEW_NAME
  ) LOOP
    EXECUTE IMMEDIATE
      'DROP VIEW ADVENTUREWORKS2022.' ||
      DBMS_ASSERT.ENQUOTE_NAME(R.VIEW_NAME, FALSE);
    DBMS_OUTPUT.PUT_LINE('Dropped view: ' || R.VIEW_NAME);
  END LOOP;
END;
/

PROMPT [90] View cleanup complete.
