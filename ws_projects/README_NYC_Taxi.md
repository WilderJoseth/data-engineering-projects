# Data Engineering Project - Lakehouse end-to-end scenario

This project implements an end-to-end data engineering pipeline using **Microsoft Fabric** to ingest, curate, and serve NYC taxi trip data following the **Medallion Architecture (Bronze/Silver/Gold)**.

Link data: <https://www.kaggle.com/datasets/marcbrandner/tlc-trip-record-data-yellow-taxi>

## 1. Business Scenario

A taxi company wants to understand demand patterns, revenue drivers, and operational bottlenecks across time and geography. For that reason, data arrives monthly as Parquet, which extracts information from the taxi application.

The goal is:
* **Standardize ingestion** and ensure **reproducible and idempotent** loads.
* Maintain **raw history** and an **archived landing trail**.
* Build curated and enriched tables for **BI and analytics**.
* Produce reporting assets to support decisions like fleet allocation, pricing, and staffing.

## 2. Architecture

This architecture is designed for a business that receives **monthly batch extracts** from an operational application and needs a reliable path from raw data to BI-ready insights. It balances **auditability, operational reliability, scalability, and analytics performance**.

![Data Processing Design](docs/img/data_processing_design_NYC_Taxi.png)

1. **Taxi App** generates monthly Parquet trip files.
2. Files are dropped into **ADLS Gen2** in a landing path (partitioned by month).
3. On arrival, a **Fabric Data Pipeline** is triggered.
4. Fabric uses a **OneLake Shortcut** to access the ADLS landing zone.
5. A single **Fabric Lakehouse** contains three schemas:
   - `bronze` (raw, as received)
      - Move data to archived path (ADLS Gen2)
   - `silver` (cleaned, conformed)
   - `gold` (enriched, analytics-ready)
6. Access to gold data through **Semantic Model**.

## 3. Architecture decisions

### 3.1. Batch processing

The taxi app produces **monthly Parquet drops** (not continuous streaming). Using ADLS Gen2 as the landing zone and event-based triggering in Fabric aligns with a batch ingestion pattern:

* Partition data by time (`year=YYYY/month=MM`).
* Clear operational boundaries per month (reprocess a single month if needed).

This matches the source reality.

### 3.2. Landing zone

Keeping a dedicated **ADLS landing zone** provides a clean boundary between:

* Upstream producer responsibilities (drop files).
* Downstream data engineering responsibilities (validate, transform, serve).

This removes coupling between the pipeline and the producer proving a clear separation of concerns.

### 3.3. OneLake Shortcut

Using a **OneLake Shortcut** to ADLS allows Fabric to access landing data without copying it into OneLake first. This is valuable because it:

* Avoids unnecessary storage duplication.
* Enables faster initial ingestion setup.
* Preserves the “single source of truth” in ADLS while still enabling Fabric processing.

### 3.4. Bronze Delta tables + file archiving

Bronze is implemented as **Delta tables** to make raw data queryable with ACID reliability, while also archiving source files after successful ingestion.

This provides two important guarantees:

* **Audit trail / reproducibility**: archived files preserve exactly what arrived and when.
* **Operational safety**: Delta tables support safe reruns, schema evolution handling, and consistent downstream reads.

### 3.5. Silver layer

Taxi data can contain errors (negative fares, impossible timestamps, zero distance trips, duplicates). Silver is the “trust boundary” where:

* Types are standardized (timestamps, numeric fields).
* Data quality rules are applied consistently.

This enforces data quality for trustworthy analytics.

### 3.6. Gold layer

Gold is tailored to how the business consumes data:

* Pre-aggregations reduce the need for expensive ad hoc calculations

### 3.7. Event-triggered pipelines

Running the pipeline automatically when a file arrives:

* Improves data freshness for reporting.
* Prevents “someone forgot to run the job” failures.
* Creates a consistent operational pattern for future datasets.

### 3.8. Lakehouse with schemas

Using one Lakehouse with three schemas (`bronze`, `silver`, `gold`) provides:

* Clear structure without managing many Fabric items.
* Straightforward access control by schema/table.

### 3.9. Reporting with Direct Lake

With Gold in Delta tables, the project can use **Direct Lake** for Power BI:

* Low-latency BI experience without heavy import refresh cycles.
* A single curated semantic model that multiple reports can reuse.

### 3.10. Spark - Notebooks

Spark in Fabric is used for Bronze/Silver/Gold processing because the workload is transformation-heavy (cleansing, deduplication, conformance, enrichment, and aggregations). Spark integrates natively with Lakehouse Delta tables, enabling efficient partitioned writes, schema evolution, and reliable upsert/overwrite patterns to support idempotent reruns and backfills.

