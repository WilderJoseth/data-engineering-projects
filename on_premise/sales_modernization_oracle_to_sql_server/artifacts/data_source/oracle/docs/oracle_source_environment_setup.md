# Oracle Source Environment Setup

## Purpose

This guide explains how to create the Oracle source environment used by the Sales-domain migration project.

The source database is an Oracle XE 21c-compatible adaptation of AdventureWorks2022. It is used as a simulated legacy Oracle system for extraction, validation, and migration development.

## Directory Structure

```text
artifacts/data_source/oracle/
|-- users/
|   `-- 01_create_adventureworks2022_user.sql
|-- ddl/
|   `-- 01_create_adventureworks2022_schema_objects.sql
|-- seed/
|   `-- 01_seed_adventureworks2022_sales_domain.sql
`-- docs/
    `-- oracle_source_environment_setup.md
```

## Prerequisites

- Docker running locally.
- Oracle XE container available and healthy.
- SQL*Plus, SQLcl, or another Oracle SQL client that can connect to the container.
- Privileged Oracle account for user creation, usually `SYS` or `SYSTEM`.

## Recommended Docker Image

Use `gvenzl/oracle-xe:21-slim-faststart`.

Reasoning:

- The project source profile is Oracle XE 21c.
- The `slim` flavor keeps the image lighter than the regular or full image.
- The `faststart` flavor starts faster because the database is already expanded in the image.
- It exposes the standard Oracle listener port `1521`, which can be used from SQL Developer.

`gvenzl/oracle-free` is a good newer option for Oracle Database Free 23ai, but this project should stay on `gvenzl/oracle-xe` unless the source profile is intentionally upgraded from Oracle XE 21c.

## Expected Database User

The migration source schema is:

```text
ADVENTUREWORKS2022
```

The user creation script contains a placeholder password:

```sql
IDENTIFIED BY "XXXXXXXX"
```

Replace it before running locally. Do not commit real passwords.

## Execution Order

Run the scripts in this order:

```text
1. users/01_create_adventureworks2022_user.sql
2. ddl/01_create_adventureworks2022_schema_objects.sql
3. seed/01_seed_adventureworks2022_sales_domain.sql
```

The seed script is self-contained for the migration scope. It loads the required Sales-domain reference, master, and transactional data and generates configurable high-volume sales orders.

## Example Docker Flow

### 1. Pull the image

```bash
docker pull gvenzl/oracle-xe:21-slim-faststart
```

### 2. Create a persistent Docker volume

Use a named volume so the database files survive container restarts and container replacement.

```bash
docker volume create oracle-xe-sales-migration-data
```

### 3. Start the Oracle XE container

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

PowerShell also accepts the same command with backticks:

```powershell
docker run -d `
  --name oracle-xe-sales-migration `
  -p 1521:1521 `
  -p 5500:5500 `
  -e ORACLE_PASSWORD=OraclePwd_123 `
  -v oracle-xe-sales-migration-data:/opt/oracle/oradata `
  --shm-size=2g `
  gvenzl/oracle-xe:21-slim-faststart
```

For larger transactional-volume tests, increase shared memory if Docker has enough resources:

```powershell
--shm-size=4g
```

### 4. Wait until the database is ready

Follow the container logs:

```bash
docker logs -f oracle-xe-sales-migration
```

In another terminal, you can run the image health check:

```bash
docker exec oracle-xe-sales-migration healthcheck.sh
```

Continue only after the database is healthy.

### 5. Confirm the container is running

```bash
docker ps --filter "name=oracle-xe-sales-migration"
```

Example connection targets:

```text
Host: localhost
Port: 1521
Service name: XEPDB1
Privileged user: SYSTEM
Privileged password: OraclePwd_123
Schema user: ADVENTUREWORKS2022
```

## SQL Developer Connection

Create a SQL Developer connection with these values:

```text
Connection Type: Basic
Hostname: localhost
Port: 1521
Service name: XEPDB1
Username: SYSTEM
Password: OraclePwd_123
Role: default
```

After running the user script, you can create a second SQL Developer connection:

```text
Connection Type: Basic
Hostname: localhost
Port: 1521
Service name: XEPDB1
Username: ADVENTUREWORKS2022
Password: <password configured in 01_create_adventureworks2022_user.sql>
Role: default
```

Use the `SYSTEM` connection for user creation. Use the `ADVENTUREWORKS2022` connection for inspecting source objects and running exploratory queries.

## Run The Project Scripts

### Option A: Run From SQL Developer

Open each script in SQL Developer and execute them in order:

```text
1. users/01_create_adventureworks2022_user.sql
2. ddl/01_create_adventureworks2022_schema_objects.sql
3. seed/01_seed_adventureworks2022_sales_domain.sql
```

Use the `SYSTEM` connection for all three scripts, or use `SYSTEM` for the user script and `ADVENTUREWORKS2022` for the remaining scripts.

Disable autocommit in SQL Developer before testing the seed script if you want to manually run `ROLLBACK` after a failure.

### Option B: Run From SQL*Plus On The Host

Run the user script with a privileged account:

```bash
sqlplus system/OraclePwd_123@//localhost:1521/XEPDB1 @artifacts/data_source/oracle/users/01_create_adventureworks2022_user.sql
```

Run the schema DDL:

```bash
sqlplus system/OraclePwd_123@//localhost:1521/XEPDB1 @artifacts/data_source/oracle/ddl/01_create_adventureworks2022_schema_objects.sql
```

Run the seed data:

```bash
sqlplus system/OraclePwd_123@//localhost:1521/XEPDB1 @artifacts/data_source/oracle/seed/01_seed_adventureworks2022_sales_domain.sql
```

### Option C: Copy Scripts Into The Container And Run There

Copy the Oracle source artifact folder into the running container:

```bash
docker cp artifacts/data_source/oracle oracle-xe-sales-migration:/tmp/oracle_source
```

Open a shell inside the container:

```bash
docker exec -it oracle-xe-sales-migration bash
```

Run the scripts from inside the container:

```bash
sqlplus system/OraclePwd_123@//localhost:1521/XEPDB1 @/tmp/oracle_source/users/01_create_adventureworks2022_user.sql
sqlplus system/OraclePwd_123@//localhost:1521/XEPDB1 @/tmp/oracle_source/ddl/01_create_adventureworks2022_schema_objects.sql
sqlplus system/OraclePwd_123@//localhost:1521/XEPDB1 @/tmp/oracle_source/seed/01_seed_adventureworks2022_sales_domain.sql
```

You can run the DDL and seed scripts as `ADVENTUREWORKS2022` after the user has been created because all objects are fully qualified with the target schema.

## Container Operations

Stop the container:

```bash
docker stop oracle-xe-sales-migration
```

Start it again:

```bash
docker start oracle-xe-sales-migration
```

Remove the container but keep the database volume:

```bash
docker rm -f oracle-xe-sales-migration
```

Remove the database volume only when you intentionally want to delete the Oracle data files:

```bash
docker volume rm oracle-xe-sales-migration-data
```

## Transactional Volume Generation

The seed script is designed to prove that the migration can process large transactional datasets and support batch-based loading.

Default generated volume:

```text
5,000 customers
100,000 sales order headers
500,000 sales order details
```

The script uses SQL*Plus substitution variables:

```sql
DEFINE customer_count = 5000;
DEFINE order_count = 100000;
DEFINE details_per_order = 5;
```

To generate a larger dataset, edit those values before running the script. For example:

```sql
DEFINE customer_count = 20000;
DEFINE order_count = 1000000;
DEFINE details_per_order = 5;
```

That configuration generates:

```text
20,000 customers
1,000,000 sales order headers
5,000,000 sales order details
```

The script uses deterministic ID ranges and cleans only those ranges before regenerating data. It contains a single `COMMIT` at the end. If execution fails before that point, run `ROLLBACK` in the same session.

## Validation Queries

Confirm that the expected tables exist:

```sql
SELECT COUNT(*) AS table_count
FROM all_tables
WHERE owner = 'ADVENTUREWORKS2022';
```

Expected result:

```text
68
```

Confirm that foreign keys were created:

```sql
SELECT COUNT(*) AS foreign_key_count
FROM all_constraints
WHERE owner = 'ADVENTUREWORKS2022'
  AND constraint_type = 'R';
```

Expected result:

```text
90
```

Confirm that the sample Sales order is available:

```sql
SELECT
    h.salesorderid,
    h.orderdate,
    h.customerid,
    d.salesorderdetailid,
    d.productid,
    d.orderqty,
    d.unitprice
FROM adventureworks2022.sales_salesorderheader h
INNER JOIN adventureworks2022.sales_salesorderdetail d
    ON d.salesorderid = h.salesorderid
ORDER BY h.salesorderid, d.salesorderdetailid;
```

Confirm the generated transactional volume:

```sql
SELECT COUNT(*) AS generated_order_count
FROM adventureworks2022.sales_salesorderheader
WHERE salesorderid >= 4000000;

SELECT COUNT(*) AS generated_order_detail_count
FROM adventureworks2022.sales_salesorderdetail
WHERE salesorderid >= 4000000;
```

## Notes

- The DDL script is not idempotent. Recreate the schema before rerunning from scratch.
- The seed script is intentionally focused on the Sales-domain migration scope, not every table in the broader AdventureWorks source model.
- The transactional volume should be scaled based on Docker memory, CPU, and storage capacity.
- The source model includes many AdventureWorks objects, but the migration scope uses only the Sales domain and selected supporting entities.

## References

- `gvenzl/oracle-xe` Docker image: https://hub.docker.com/r/gvenzl/oracle-xe
- `gvenzl/oracle-free` Docker image: https://hub.docker.com/r/gvenzl/oracle-free
