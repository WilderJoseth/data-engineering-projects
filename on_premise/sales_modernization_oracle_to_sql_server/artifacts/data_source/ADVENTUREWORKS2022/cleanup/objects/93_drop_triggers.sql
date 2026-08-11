-- WARNING:
-- This script is destructive and intended only for the local Oracle XE Docker environment.
-- Do not execute against shared, UAT, certification, or production databases.
-- =============================================================================
-- WARNING          : LOCAL/DEV DOCKER CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
-- Purpose          : Drop source-simulation triggers if any are present.
-- Execution order  : 93; run after 92_drop_functions.sql.
-- Connection user  : SYSTEM; CURRENT_SCHEMA is set to ADVENTUREWORKS2022.
-- Objects affected : All triggers owned by ADVENTUREWORKS2022.
-- Notes            : The current DDL creates no triggers; this script supports
--                    repeatable cleanup if local/dev triggers are added later.
-- =============================================================================

SET SERVEROUTPUT ON
ALTER SESSION SET CURRENT_SCHEMA = ADVENTUREWORKS2022;

PROMPT [93] Dropping ADVENTUREWORKS2022 triggers...

BEGIN
  FOR R IN (
    SELECT TRIGGER_NAME
    FROM ALL_TRIGGERS
    WHERE OWNER = 'ADVENTUREWORKS2022'
    ORDER BY TRIGGER_NAME
  ) LOOP
    EXECUTE IMMEDIATE
      'DROP TRIGGER ADVENTUREWORKS2022.' ||
      DBMS_ASSERT.ENQUOTE_NAME(R.TRIGGER_NAME, FALSE);
    DBMS_OUTPUT.PUT_LINE('Dropped trigger: ' || R.TRIGGER_NAME);
  END LOOP;
END;
/

PROMPT [93] Trigger cleanup complete.
