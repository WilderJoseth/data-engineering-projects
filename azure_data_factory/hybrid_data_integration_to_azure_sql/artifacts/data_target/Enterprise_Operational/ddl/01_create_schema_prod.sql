/*
    Script: 01_create_schema_prod.sql
    Database: Enterprise_Operational

    Purpose:
        Create the [prod] schema used by the Azure SQL serving layer.

    Flow:
        1. Check whether the [prod] schema exists.
        2. Create the schema when missing.

    Notes:
        - Run against [Enterprise_Operational].
        - The script is idempotent.
*/
IF DB_NAME() <> N'Enterprise_Operational'
BEGIN
    ;THROW 50000,
        'This script must be executed against [Enterprise_Operational].',
        1;
END;

IF SCHEMA_ID(N'prod') IS NULL
BEGIN
    EXEC(N'CREATE SCHEMA [prod] AUTHORIZATION [dbo];');
END;
GO