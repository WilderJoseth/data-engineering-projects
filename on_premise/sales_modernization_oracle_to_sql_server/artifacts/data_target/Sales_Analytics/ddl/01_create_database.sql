/*
    Script name
        01_create_database.sql

    Purpose
        Creates the Sales_Analytics database used by the analytical migration
        pipeline.

    Scope
        Creates only the database and assigns database ownership to sa. Schemas
        are created by 02_create_schemas.sql.

    Precondition
        Sales_Analytics must not already exist. This local-development setup
        script intentionally does not drop or replace an existing database.
*/

CREATE DATABASE [Sales_Analytics];
GO

ALTER AUTHORIZATION ON DATABASE::[Sales_Analytics] TO [sa];
GO
