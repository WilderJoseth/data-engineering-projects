-- WARNING:
-- This script is destructive and intended only for the local Oracle XE Docker environment.
-- Do not execute against shared, UAT, certification, or production databases.
-- =============================================================================
-- WARNING          : LOCAL/DEV DOCKER CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
-- Purpose          : Drop all Oracle-adapted AdventureWorks2022 source tables.
-- Execution order  : 96; run after 95_drop_constraints.sql.
-- Connection user  : SYSTEM; CURRENT_SCHEMA is set to ADVENTUREWORKS2022.
-- Objects affected : HUMANRESOURCES_, PERSON_, PRODUCTION_, PURCHASING_,
--                    SALES_, and DBO_-prefixed source tables and their data.
-- Notes            : DROP TABLE ... CASCADE CONSTRAINTS PURGE is destructive
--                    and irreversible. PURGE avoids recycle-bin name conflicts
--                    when the DDL scripts are executed again in local Docker.
-- =============================================================================

SET SERVEROUTPUT ON
ALTER SESSION SET CURRENT_SCHEMA = ADVENTUREWORKS2022;

PROMPT [96] Dropping ADVENTUREWORKS2022 source tables and all stored data...

BEGIN
  FOR R IN (
    SELECT TABLE_NAME
    FROM ALL_TABLES
    WHERE OWNER = 'ADVENTUREWORKS2022'
      AND (TABLE_NAME LIKE 'HUMANRESOURCES\_%' ESCAPE '\'
       OR TABLE_NAME LIKE 'PERSON\_%' ESCAPE '\'
       OR TABLE_NAME LIKE 'PRODUCTION\_%' ESCAPE '\'
       OR TABLE_NAME LIKE 'PURCHASING\_%' ESCAPE '\'
       OR TABLE_NAME LIKE 'SALES\_%' ESCAPE '\'
       OR TABLE_NAME LIKE 'DBO\_%' ESCAPE '\')
    ORDER BY TABLE_NAME
  ) LOOP
    EXECUTE IMMEDIATE
      'DROP TABLE ADVENTUREWORKS2022.' ||
      DBMS_ASSERT.ENQUOTE_NAME(R.TABLE_NAME, FALSE) ||
      ' CASCADE CONSTRAINTS PURGE';
    DBMS_OUTPUT.PUT_LINE('Dropped table: ' || R.TABLE_NAME);
  END LOOP;
END;
/

PROMPT [96] Table cleanup complete.
