/*
    Script name
        01_create_database.sql

    Purpose
        Creates the Sales_Analytics database used by the analytical migration
        pipeline.

    Scope
        Creates only the database and assigns database ownership to sa. Schemas
        are created by 02_create_schemas.sql.
*/

CREATE DATABASE [Sales_Analytics];
GO

ALTER AUTHORIZATION ON DATABASE::[Sales_Analytics] TO [sa];
GO
