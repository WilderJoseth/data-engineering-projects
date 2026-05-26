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
|       |   `-- ddl/ # Final operational target objects
|       `-- Sales_Analytics/
|           `-- ddl/ # Final analytical target objects
`-- legacy_outdated/
    # Previous draft artifacts retained for reference only
```

## Execution Order

Create the Oracle source environment first:

```text
data_source/oracle/users/01_create_adventureworks2022_user.sql
data_source/oracle/ddl/01_create_adventureworks2022_schema_objects.sql
data_source/oracle/seed/01_seed_sales_domain_sample_data.sql
data_source/oracle/seed/02_generate_sales_transactional_volume.sql
```

Create the SQL Server operational target:

```text
data_target/sql_server/Sales_Operational/ddl/01_create_database_and_schemas.sql
data_target/sql_server/Sales_Operational/ddl/02_create_prod_tables.sql
```

Create the SQL Server analytical target:

```text
data_target/sql_server/Sales_Analytics/ddl/01_create_database_and_schemas.sql
data_target/sql_server/Sales_Analytics/ddl/02_create_final_tables.sql
```

## Scope Notes

- Current target scripts create final business tables only.
- Staging, work, local control objects, stored procedures, and SSIS packages are intentionally deferred.
- The first source seed script is a compact dependency-complete dataset.
- The second source seed script generates configurable high-volume transactional data for batch migration and performance testing.
- `legacy_outdated/` contains previous draft artifacts and should not be used as the implementation baseline.
