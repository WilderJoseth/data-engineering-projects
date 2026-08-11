-- WARNING:
-- This script is destructive and intended only for the local Oracle XE Docker environment.
-- Do not execute against shared, UAT, certification, or production databases.
-- =============================================================================
-- WARNING          : LOCAL/DEV DOCKER CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
-- Purpose          : Drop the explicitly managed secondary source indexes.
-- Execution order  : 94; run after 93_drop_triggers.sql.
-- Connection user  : SYSTEM; CURRENT_SCHEMA is set to ADVENTUREWORKS2022.
-- Objects affected : Secondary indexes named IX_AW_01 through IX_AW_20.
-- Notes            : Constraint-backed indexes are intentionally excluded and
--                    remain under constraint/table lifecycle management.
-- =============================================================================

SET SERVEROUTPUT ON
ALTER SESSION SET CURRENT_SCHEMA = ADVENTUREWORKS2022;

PROMPT [94] Dropping managed ADVENTUREWORKS2022 secondary indexes...

BEGIN
  FOR R IN (
    SELECT INDEX_NAME
    FROM ALL_INDEXES
    WHERE OWNER = 'ADVENTUREWORKS2022'
      AND REGEXP_LIKE(INDEX_NAME, '^IX_AW_(0[1-9]|1[0-9]|20)$')
    ORDER BY INDEX_NAME
  ) LOOP
    EXECUTE IMMEDIATE
      'DROP INDEX ADVENTUREWORKS2022.' ||
      DBMS_ASSERT.ENQUOTE_NAME(R.INDEX_NAME, FALSE);
    DBMS_OUTPUT.PUT_LINE('Dropped index: ' || R.INDEX_NAME);
  END LOOP;
END;
/

PROMPT [94] Secondary-index cleanup complete.
