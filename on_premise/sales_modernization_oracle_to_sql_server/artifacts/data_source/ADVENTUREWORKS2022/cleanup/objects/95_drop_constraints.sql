-- WARNING:
-- This script is destructive and intended only for the local Oracle XE Docker environment.
-- Do not execute against shared, UAT, certification, or production databases.
-- =============================================================================
-- WARNING          : LOCAL/DEV DOCKER CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
-- Purpose          : Drop source-table constraints in dependency-safe order.
-- Execution order  : 95; run after 94_drop_indexes.sql.
-- Connection user  : SYSTEM; CURRENT_SCHEMA is set to ADVENTUREWORKS2022.
-- Objects affected : Foreign-key, check, unique, and primary-key constraints on
--                    the Oracle-adapted AdventureWorks2022 source tables.
-- Notes            : Foreign keys are removed before referenced unique and
--                    primary keys. NOT NULL constraints are column properties
--                    and are left for table cleanup.
-- =============================================================================

SET SERVEROUTPUT ON
ALTER SESSION SET CURRENT_SCHEMA = ADVENTUREWORKS2022;

PROMPT [95] Dropping ADVENTUREWORKS2022 table constraints...

BEGIN
  FOR R IN (
    SELECT TABLE_NAME,
           CONSTRAINT_NAME,
           CONSTRAINT_TYPE
    FROM ALL_CONSTRAINTS
    WHERE OWNER = 'ADVENTUREWORKS2022'
      AND CONSTRAINT_TYPE IN ('R', 'C', 'U', 'P')
      AND GENERATED = 'USER NAME'
      AND (
        TABLE_NAME LIKE 'HUMANRESOURCES\_%' ESCAPE '\'
        OR TABLE_NAME LIKE 'PERSON\_%' ESCAPE '\'
        OR TABLE_NAME LIKE 'PRODUCTION\_%' ESCAPE '\'
        OR TABLE_NAME LIKE 'PURCHASING\_%' ESCAPE '\'
        OR TABLE_NAME LIKE 'SALES\_%' ESCAPE '\'
        OR TABLE_NAME LIKE 'DBO\_%' ESCAPE '\'
      )
    ORDER BY CASE CONSTRAINT_TYPE
               WHEN 'R' THEN 1
               WHEN 'C' THEN 2
               WHEN 'U' THEN 3
               WHEN 'P' THEN 4
             END,
             TABLE_NAME,
             CONSTRAINT_NAME
  ) LOOP
    EXECUTE IMMEDIATE
      'ALTER TABLE ADVENTUREWORKS2022.' ||
      DBMS_ASSERT.ENQUOTE_NAME(R.TABLE_NAME, FALSE) ||
      ' DROP CONSTRAINT ' ||
      DBMS_ASSERT.ENQUOTE_NAME(R.CONSTRAINT_NAME, FALSE);
    DBMS_OUTPUT.PUT_LINE(
      'Dropped constraint: ' || R.TABLE_NAME || '.' || R.CONSTRAINT_NAME
    );
  END LOOP;
END;
/

PROMPT [95] Constraint cleanup complete.
