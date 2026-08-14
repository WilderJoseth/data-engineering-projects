# SQL Server Target Setup

## Document Goal

This document describes how to create, secure, seed, validate, and reset the `Sales_Operational` and `Sales_Analytics` SQL Server target databases for local development and validation.

The SQL Server instance must already be running. Complete and validate `Sales_Operational` before setting up `Sales_Analytics`.

## Directory Structure

Each target uses the following structure.

```text
Sales_<Target>/
├── ddl/              Creates the database, schemas, and layer-specific tables
├── security/         Creates and validates the ETL login, user, role, and permissions
├── seed/             Populates and validates test data by layer
└── cleanup/
    ├── seed/         Removes seeded data in reverse dependency order
    ├── security/     Removes ETL security objects
    └── objects/      Drops database objects or the target database
```

## Setup Flow

1. Set up and validate `Sales_Operational`.
2. Set up and validate `Sales_Analytics`.
3. Run seed scripts only when local test data is required.
4. Use the cleanup scripts when a data reset or full rebuild is required.

The `00` scripts are validation queries. They can be rerun at any time and do not create objects or load data.

## Sales_Operational

`Sales_Operational` implements the `staging → work → prod` flow and is the required source for `Sales_Analytics`.

### Create Objects

Run the scripts in `artifacts/data_target/Sales_Operational/ddl`.

1. Run `01_create_database.sql`.
2. Run `02_create_schemas.sql`.
3. Run `03_create_staging_tables.sql`.
4. Run `04_create_work_tables.sql`.
5. Run `05_create_prod_tables.sql`.
6. Run `00_evaluate_created_objects.sql` to validate the created objects.

### Configure Security

Run the scripts in `artifacts/data_target/Sales_Operational/security`.

1. Run `01_create_etl_user.sql`.
2. Run `00_evaluate_security_objects.sql` to validate the login, user, role, and membership.

### Load and Validate Seed Data

Run the scripts in `artifacts/data_target/Sales_Operational/seed`.

1. Run `01_seed_staging.sql`.
2. Run `02_seed_work.sql`.
3. Run `03_seed_prod.sql`.
4. Run `00_validate_seed_data.sql` to confirm row counts by schema and table.

## Sales_Analytics

`Sales_Analytics` implements the `staging → work → dim/fact` flow. Its staging layer depends on data from `Sales_Operational.prod`.

Before continuing, confirm that `Sales_Operational` objects and required data are available.

### Create Objects

Run the scripts in `artifacts/data_target/Sales_Analytics/ddl`.

1. Run `01_create_database.sql`.
2. Run `02_create_schemas.sql`.
3. Run `03_create_staging_tables.sql`.
4. Run `04_create_work_tables.sql`.
5. Run `05_create_dim_tables.sql`.
6. Run `06_create_fact_tables.sql`.
7. Run `00_evaluate_created_objects.sql` to validate the created objects.

### Configure Security

Run the scripts in `artifacts/data_target/Sales_Analytics/security`.

1. Run `01_create_etl_user.sql`.
2. Run `00_evaluate_security_objects.sql` to validate the login, user, role, and membership.

### Load and Validate Seed Data

Run the scripts in `artifacts/data_target/Sales_Analytics/seed`.

1. Run `01_seed_staging.sql`.
2. Run `02_seed_work.sql`.
3. Run `03_seed_dim.sql`.
4. Run `04_seed_fact.sql`.
5. Run `00_validate_seed_data.sql` to confirm row counts by schema and table.

## Validation Criteria

- Both target databases and their expected schemas exist.
- DDL scripts run without errors.
- Object validation reports the expected objects as created.
- ETL security objects and role membership exist.
- Seed scripts run without key or constraint errors.
- Seed validation confirms populated tables in each layer.
- `Sales_Operational` is validated before `Sales_Analytics`.

## Rollback

Run cleanup only against the intended local or development database.

### Seed Data Cleanup

| Target | Execution Order |
|---|---|
| `Sales_Operational` | `01_cleanup_prod_data.sql` → `02_cleanup_work_data.sql` → `03_cleanup_staging_data.sql` |
| `Sales_Analytics` | `01_cleanup_fact_data.sql` → `02_cleanup_dim_data.sql` → `03_cleanup_work_data.sql` → `04_cleanup_staging_data.sql` |

These scripts remove seeded test data while retaining database objects.

### Security Cleanup

For either target, run the scripts in `cleanup/security` in this order.

1. Run `90_remove_role_membership.sql`.
2. Run `91_drop_database_user.sql`.
3. Run `92_drop_database_role.sql`.
4. Run `99_drop_login.sql`.

### Object Cleanup

For either target, run only the required scripts from `cleanup/objects`, in numerical order.

| Range | Result |
|---|---|
| `90_drop_views.sql` through `96_drop_tables.sql` | Removes target objects in dependency-safe order. |
| `97_drop_schemas.sql` | Removes the target schemas after their objects are dropped. |
| `99_drop_database.sql` | **Destructive:** drops the complete target database for a full local/development rebuild. |

When both targets require a full reset, clean up `Sales_Analytics` before `Sales_Operational` because analytics depends on the operational target.
