# Artifacts

This directory contains implementation artifacts for the Oracle-to-SQL Server Sales-domain migration.

## Current Structure

```text
artifacts/
|-- data_source/
|   `-- oracle/
|       |-- users/   # Oracle schema user creation
|       |-- ddl/     # Oracle source schema objects
|       |-- seed/    # Oracle source sample data
|       `-- docs/    # Source setup documentation
|-- data_target/
|   `-- sql_server/
|       |-- Sales_Operational/
|       |   `-- ddl/ # Operational target schemas, final, staging, and work objects
|       `-- Sales_Analytics/
|           `-- ddl/ # Analytical target schemas, final, staging, and work objects
`-- legacy_outdated/
    # Previous draft artifacts retained for reference only
```

## Execution Order

Create the Oracle source environment first:

```text
data_source/oracle/users/01_create_adventureworks2022_user.sql
data_source/oracle/ddl/01_create_adventureworks2022_schema_objects.sql
data_source/oracle/seed/01_seed_adventureworks2022_sales_domain.sql
```

Create the SQL Server operational target:

```text
data_target/sql_server/Sales_Operational/ddl/01_create_database_and_schemas.sql
data_target/sql_server/Sales_Operational/ddl/02_create_prod_tables.sql
data_target/sql_server/Sales_Operational/ddl/03_create_staging_tables.sql
data_target/sql_server/Sales_Operational/ddl/04_create_work_tables.sql
data_target/sql_server/Sales_Operational/ddl/05_create_control_tables.sql
data_target/sql_server/Sales_Operational/ddl/06_create_work_stored_procedures.sql
```

Create the SQL Server analytical target:

```text
data_target/sql_server/Sales_Analytics/ddl/01_create_database_and_schemas.sql
data_target/sql_server/Sales_Analytics/ddl/02_create_final_tables.sql
data_target/sql_server/Sales_Analytics/ddl/03_create_staging_tables.sql
data_target/sql_server/Sales_Analytics/ddl/04_create_work_tables.sql
```

## Scope Notes

- Final target tables include the standard audit columns defined in the solution design.
- Staging and work tables intentionally exclude audit columns because they store temporary ETL data.
- Local control objects, stored procedures, and SSIS packages are intentionally deferred.
- The source seed script is a self-contained Sales-domain dataset with configurable high-volume transactional data.
- `legacy_outdated/` contains previous draft artifacts and should not be used as the implementation baseline.
