/*
    Script: 91_cleanup_schema_prod.sql
    Database: Enterprise_Operational

    Purpose:
        Remove the [prod] schema during rollback or environment cleanup.

    Flow:
        1. Check whether the [prod] schema exists.
        2. Drop the schema.

    Notes:
        - Run against [Enterprise_Operational].
        - The schema must be empty before it can be dropped.
*/

IF DB_NAME() <> N'Enterprise_Operational'
BEGIN
    ;THROW 50000,
        'This script must be executed against [Enterprise_Operational].',
        1;
END;

IF SCHEMA_ID(N'prod') IS NOT NULL
BEGIN
    DROP SCHEMA [prod];
END;
GO