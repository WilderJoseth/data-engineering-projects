/*
    Script name
        01_create_adventureworks2022_user.sql

    Purpose
        Creates the Oracle schema user used by the migration project source
        database. In Oracle, the user owns the schema objects.

    Execution
        Run as SYS, SYSTEM, or another privileged account before executing the
        DDL scripts in ../ddl.

    Security note
        Replace the placeholder password before local execution. Do not commit
        real credentials to source control.
*/

CREATE USER ADVENTUREWORKS2022
    IDENTIFIED BY "XXXXXXXX"
    DEFAULT TABLESPACE USERS
    QUOTA 500M ON USERS;

GRANT CREATE SESSION TO ADVENTUREWORKS2022;
GRANT CREATE TABLE TO ADVENTUREWORKS2022;
GRANT CREATE VIEW TO ADVENTUREWORKS2022;
GRANT CREATE PROCEDURE TO ADVENTUREWORKS2022;
GRANT CREATE SEQUENCE TO ADVENTUREWORKS2022;
GRANT CREATE TRIGGER TO ADVENTUREWORKS2022;
