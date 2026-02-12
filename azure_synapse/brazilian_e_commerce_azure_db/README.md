# Data Engineering Project - Synapse / Azure SQL end-to-end scenario

This project implements an end-to-end data engineering pipeline using **Synapse** to ingest, curate, and serve Brazilian E-Commerce data following the **Medallion Architecture (Bronze/Silver/Gold)**.

Link data: <https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce>

## 1. Business Scenario

A ecommerce company wants to understand demand patterns, revenue drivers. For that reason, data arrives daily as CSV, which extracts information from the ecommerce application.

The goal is:
* **Standardize ingestion** and ensure **reproducible and idempotent** loads.
* Build curated and enriched tables for **BI and analytics**.
* Produce reporting assets to support decisions.

## 2. Architecture

This architecture is designed for a business that receives **daily batch extracts** from an operational application and needs a reliable path from raw data to BI-ready insights. It balances **auditability, operational reliability, scalability, and analytics performance**.

![Data Processing Design](docs/img/data_processing_design.png)

1. **Ecommerce App** generates daily CSV files.
2. Files are dropped into **ADLS Gen2** in a landing path.
3. On arrival, a **Synapse Data Pipeline** is triggered.
4. Synapse uses a **Copy Task** to load data into a Azure SQL database.
5. A single **Azure SQL database** contains three schemas:
   - `bronze` (raw, as received)
   - `silver` (cleaned, conformed)
   - `gold` (enriched, analytics-ready)
6. Gold data is loaded into a Lakehouse in Synapse.

## 3. Architecture decisions

### 3.1. Batch processing

The ecommerce app produces **daily CSV drops** (not continuous streaming). Using ADLS Gen2 as the landing zone and event-based triggering in Synapse aligns with a batch ingestion pattern:

* Partition data by process like: payments, orders, etc.
* Clear operational boundaries per process (reprocess a single process if needed).

This matches the source reality.

### 3.2. Landing zone

Keeping a dedicated **ADLS landing zone** provides a clean boundary between:

* Upstream producer responsibilities (drop files).
* Downstream data engineering responsibilities (validate, transform, serve).

This removes coupling between the pipeline and the producer proving a clear separation of concerns.

### 3.3. Bronze layer - SQL tables

Bronze is implemented as **SQL tables** to make raw data queryable with ACID reliability.

This provides two important guarantees:

* **Audit trail / reproducibility**: archived files preserve exactly what arrived and when.
* **Operational safety**: tables support safe reruns, schema evolution handling, and consistent downstream reads.

### 3.4. Silver layer - SQL tables

Taxi data can contain errors. Silver is the “trust boundary” where:

* Types are standardized (timestamps, numeric fields).
* Data quality rules are applied consistently.

This enforces data quality for trustworthy analytics.

### 3.5. Gold layer

Gold is tailored to how the business consumes data:

* Pre-aggregations reduce the need for expensive ad hoc calculations.
* Store data in OLAP format.

### 3.6. Event-triggered pipelines

Running the pipeline automatically when a file arrives:

* Improves data freshness for reporting.
* Prevents “someone forgot to run the job” failures.
* Creates a consistent operational pattern for future datasets.

### 3.7. SQL database with schemas

Using one Database with three schemas (`bronze`, `silver`, `gold`) provides:

* Clear structure without managing many items.
* Straightforward access control by schema/table.

### 3.8. Reporting with Direct Lake

With Gold in Delta tables, the project can use **Direct Lake** for Power BI:

* Low-latency BI experience without heavy import refresh cycles.
* A single curated semantic model that multiple reports can reuse.

### 3.10. SQL for data tranformations

SQL is used for Bronze/Silver/Gold processing because the transformations are mostly relational.

