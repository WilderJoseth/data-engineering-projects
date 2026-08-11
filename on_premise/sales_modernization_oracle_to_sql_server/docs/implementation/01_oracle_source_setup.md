# Oracle Source Setup

## Document Goal

This document describes the local Oracle XE 21c Docker source environment, the `ADVENTUREWORKS2022` schema setup, the execution flow for object creation and seed loading, and the rollback and reset options used during local development.

## Directory Structure

```text
ADVENTUREWORKS2022/
├── ddl/              Creates the schema, tables, sequences, constraints, indexes, and views
├── seed/             Populates synthetic source data and validation scenarios
└── cleanup/
    ├── seed/         Removes seeded data and resets sequences while retaining schema objects
    └── objects/      Drops source objects to support a full rebuild
```

## Setup Flow

### Docker Container

Recommended image `gvenzl/oracle-xe:21-slim-faststart`.

Pull the image.

```bash
docker pull gvenzl/oracle-xe:21-slim-faststart
```

Create a persistent Docker volume.

```bash
docker volume create oracle-xe-sales-migration-data
```

Start the Oracle XE container.

```cmd
docker run -d ^
  --name oracle-xe-sales-migration ^
  -p 1521:1521 ^
  -p 5500:5500 ^
  -e ORACLE_PASSWORD=OraclePwd_123 ^
  -v oracle-xe-sales-migration-data:/opt/oracle/oradata ^
  --shm-size=2g ^
  gvenzl/oracle-xe:21-slim-faststart
```

### Oracle Connection

Create a connection for DB setup.

```text
Connection Type: Basic
Hostname: localhost
Port: 1521
Service name: XEPDB1
Username: SYSTEM
Password: <password configured>
Role: default
```

Create a connection for project testing.

```text
Connection Type: Basic
Hostname: localhost
Port: 1521
Service name: XEPDB1
Username: ADVENTUREWORKS2022
Password: <password configured>
Role: default
```

### Project Scripts

Create objects by running scripts located in `ddl`.

1. Run `01_create_user_and_schema.sql`.
2. Run `02_create_tables.sql`.
3. Run `03_create_constraints.sql`.
4. Run `04_create_indexes.sql`.
5. Run `05_create_functions.sql`.
6. Run `06_create_procedures.sql`.
7. Run `07_create_views.sql`.

Validate objects by running scripts located in `ddl`.

1. Run `00_evaluate_created_objects.sql`.

Load data by running scripts located in `seed`.

1. Run `01_seed_reference_data.sql`.
2. Run `02_seed_person_hr_data.sql`.
3. Run `03_seed_production_data.sql`.
4. Run `04_seed_purchasing_data.sql`.
5. Run `05_seed_sales_data.sql`.
6. Run `06_seed_validation_scenarios.sql`.

Validate data by running scripts located in `seed`.

1. Run `00_validate_seed_data.sql`.

## Rollback

### Project Scripts

Delete data by running scripts located in `cleanup/seed`.

1. Run `01_cleanup_transactional_data.sql`.
2. Run `02_cleanup_bridge_data.sql`.
3. Run `03_cleanup_master_data.sql`.
4. Run `04_cleanup_reference_data.sql`.
5. Run `05_reset_sequences.sql`.

Drop objects by running scripts located in `cleanup/objects`.

1. Run `90_drop_views.sql`.
2. Run `91_drop_procedures.sql`.
3. Run `92_drop_functions.sql`.
4. Run `93_drop_triggers.sql`.
5. Run `94_drop_indexes.sql`.
6. Run `95_drop_constraints.sql`.
7. Run `96_drop_tables.sql`.
8. Run `99_drop_user_and_schema.sql`.
