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
|       |   |-- ddl/  # Operational target schemas, tables, and stored procedures
|       |   `-- seed/ # Operational target staging test data
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
data_target/sql_server/Sales_Operational/ddl/06_create_work_reference_stored_procedures.sql
data_target/sql_server/Sales_Operational/ddl/07_create_work_master_stored_procedures.sql
data_target/sql_server/Sales_Operational/ddl/08_create_prod_reference_stored_procedures.sql
data_target/sql_server/Sales_Operational/ddl/09_create_prod_master_stored_procedures.sql
data_target/sql_server/Sales_Operational/ddl/10_create_control_reference_reconciliation_objects.sql
data_target/sql_server/Sales_Operational/ddl/11_create_control_master_reconciliation_objects.sql
data_target/sql_server/Sales_Operational/ddl/12_create_control_process_status_objects.sql
```

Optional operational prod-table reset script:

```text
data_target/sql_server/Sales_Operational/ddl/99_drop_prod_tables.sql
```

Load operational staging test data for reference and master validation tests:

```text
data_target/sql_server/Sales_Operational/seed/01_seed_reference_master_staging_test_data.sql
```

When testing master validation procedures, execute the reference validation and
reference prod load first. Master tables such as `Address`, `Product`,
`SalesPerson`, and `Customer` validate dependencies against prod reference
tables.

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
- Local control objects support reconciliation and validation results that can be published to DataOps_Control.
- Stored procedures are split by load area: reference data and master data.
- The source seed script is a self-contained Sales-domain dataset with configurable high-volume transactional data.
- `legacy_outdated/` contains previous draft artifacts and should not be used as the implementation baseline.
