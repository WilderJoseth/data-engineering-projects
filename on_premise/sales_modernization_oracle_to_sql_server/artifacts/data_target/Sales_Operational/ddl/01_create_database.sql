/*
    Script name
        01_create_database.sql

    Purpose
        Creates the Sales_Operational database used by the operational migration pipeline.

    Scope
        Database creation only. Schemas are created by 02_create_schemas.sql.

    Precondition
        Sales_Operational must not already exist. This local-development setup
        script intentionally does not drop or replace an existing database.
*/

CREATE DATABASE [Sales_Operational];
GO

ALTER AUTHORIZATION ON DATABASE::[Sales_Operational] TO [sa];
GO
