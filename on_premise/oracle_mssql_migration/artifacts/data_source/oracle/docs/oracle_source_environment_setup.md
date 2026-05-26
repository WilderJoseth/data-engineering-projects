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
|   |-- 01_seed_sales_domain_sample_data.sql
|   `-- 02_generate_sales_transactional_volume.sql
`-- docs/
    `-- oracle_source_environment_setup.md
```

## Prerequisites

- Docker running locally.
- Oracle XE container available and healthy.
- SQL*Plus, SQLcl, or another Oracle SQL client that can connect to the container.
- Privileged Oracle account for user creation, usually `SYS` or `SYSTEM`.

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
3. seed/01_seed_sales_domain_sample_data.sql
4. seed/02_generate_sales_transactional_volume.sql
```

## Example Docker Flow

Start your Oracle XE container using your preferred image and port mapping. A typical local setup exposes the listener on port `1521`.

Example connection targets:

```text
Host: localhost
Port: 1521
Service name: XEPDB1
Privileged user: SYS or SYSTEM
Schema user: ADVENTUREWORKS2022
```

Run the user script with a privileged account:

```bash
sqlplus sys/<sys_password>@//localhost:1521/XEPDB1 as sysdba @artifacts/data_source/oracle/users/01_create_adventureworks2022_user.sql
```

Run the schema DDL:

```bash
sqlplus sys/<sys_password>@//localhost:1521/XEPDB1 as sysdba @artifacts/data_source/oracle/ddl/01_create_adventureworks2022_schema_objects.sql
```

Run the sample seed data:

```bash
sqlplus sys/<sys_password>@//localhost:1521/XEPDB1 as sysdba @artifacts/data_source/oracle/seed/01_seed_sales_domain_sample_data.sql
```

Run the transactional volume seed data:

```bash
sqlplus sys/<sys_password>@//localhost:1521/XEPDB1 as sysdba @artifacts/data_source/oracle/seed/02_generate_sales_transactional_volume.sql
```

You can also run the DDL and seed scripts as `ADVENTUREWORKS2022` after the user has been created because all objects are fully qualified with the target schema.

## Transactional Volume Generation

The transactional volume script is designed to prove that the migration can process large transactional datasets and support batch-based loading.

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

The script uses deterministic ID ranges and cleans only those generated ranges before regenerating data. The compact baseline seed rows are not deleted.

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
- The seed script is intentionally small. It is designed to validate relationships and migration logic, not to simulate production volume.
- The transactional volume script is intentionally larger and should be scaled based on Docker memory, CPU, and storage capacity.
- The source model includes many AdventureWorks objects, but the migration scope uses only the Sales domain and selected supporting entities.
