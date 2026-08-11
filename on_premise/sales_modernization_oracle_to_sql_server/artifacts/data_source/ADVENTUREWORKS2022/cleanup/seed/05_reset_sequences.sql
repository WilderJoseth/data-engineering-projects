-- WARNING:
-- This script is destructive and intended only for the local Oracle XE Docker environment.
-- Do not execute against shared, UAT, certification, or production databases.
-- =============================================================================
-- Purpose          : Resynchronize Oracle identity columns after seed cleanup.
-- Execution order  : 05 of 05; run only after cleanup scripts 01 through 04.
-- Connection user  : SYSTEM; CURRENT_SCHEMA is set to ADVENTUREWORKS2022.
-- Objects affected : Identity columns exposed by ALL_TAB_IDENTITY_COLS.
-- Notes            : Oracle prohibits direct ALTER SEQUENCE on system-generated
--                    identity sequences. START WITH LIMIT VALUE is the supported
--                    identity-column resynchronization mechanism.
-- =============================================================================

SET SERVEROUTPUT ON
ALTER SESSION SET CURRENT_SCHEMA = ADVENTUREWORKS2022;

DECLARE
  V_ROW_COUNT NUMBER;
BEGIN
  FOR R IN (
    SELECT TABLE_NAME, COLUMN_NAME, GENERATION_TYPE
    FROM ALL_TAB_IDENTITY_COLS
    WHERE OWNER = 'ADVENTUREWORKS2022'
    ORDER BY TABLE_NAME
  ) LOOP
    EXECUTE IMMEDIATE
      'SELECT COUNT(*) FROM ADVENTUREWORKS2022.' ||
      DBMS_ASSERT.ENQUOTE_NAME(R.TABLE_NAME, FALSE)
      INTO V_ROW_COUNT;

    IF V_ROW_COUNT = 0 THEN
      EXECUTE IMMEDIATE
        'ALTER TABLE ADVENTUREWORKS2022.' ||
        DBMS_ASSERT.ENQUOTE_NAME(R.TABLE_NAME, FALSE) ||
        ' MODIFY ' || DBMS_ASSERT.ENQUOTE_NAME(R.COLUMN_NAME, FALSE) ||
        ' GENERATED ' || R.GENERATION_TYPE ||
        ' AS IDENTITY (START WITH LIMIT VALUE)';
      DBMS_OUTPUT.PUT_LINE('Resynchronized identity for: ' || R.TABLE_NAME);
    ELSE
      DBMS_OUTPUT.PUT_LINE(
        'Skipped nonempty table: ' || R.TABLE_NAME ||
        ' (' || V_ROW_COUNT || ' rows)'
      );
    END IF;
  END LOOP;
END;
/

PROMPT [05] Identity-sequence reset complete.
