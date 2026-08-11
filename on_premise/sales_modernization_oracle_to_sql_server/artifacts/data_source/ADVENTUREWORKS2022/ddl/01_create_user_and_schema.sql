-- =============================================================================
-- Purpose          : Create the ADVENTUREWORKS2022 schema owner for the
--                    Oracle XE 21c source simulation.
-- Execution order  : 01 of 07.
-- Connection user  : SYSTEM, or another local account with CREATE USER and
--                    GRANT privileges.
-- Objects affected : User/schema ADVENTUREWORKS2022 and its object privileges.
-- Notes            : Intended for an Oracle XE 21c Docker environment. Supply
--                    a local, non-production password when prompted.
-- =============================================================================

-- Schema owner
ACCEPT AW_PASSWORD CHAR PROMPT 'Password for ADVENTUREWORKS2022: ' HIDE

CREATE USER ADVENTUREWORKS2022 IDENTIFIED BY "OraclePwd_123"
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  QUOTA UNLIMITED ON USERS;

-- Minimum privileges required by the remaining source setup scripts
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE,
      CREATE SEQUENCE, CREATE TRIGGER TO ADVENTUREWORKS2022;

-- Remain connected as SYSTEM. Scripts 02 through 07 explicitly set
-- CURRENT_SCHEMA to ADVENTUREWORKS2022 before creating source objects.
