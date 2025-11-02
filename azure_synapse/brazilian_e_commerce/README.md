# Data exploration using Serverless and Dedicated SQL endpoint

The goal of this project was to build a **data lakehouse structure** on Azure using **Serverless SQL Pool** for exploration, transformation, and reporting.
Additionality, the curated data was loaded into dedicated data warehouse base.

Technologies:

* Azure Data Lake Gen2
* Azure Synapse Serverless SQL Pool
* Azure Synapse Dedicated SQL Pool
* Pipelines
* Power BI

Link data: <https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce?resource=download>

## 1. Data Processing Design

The data was organized following a **medallion architecture**:

| Layer | Description | Example Path |
|--------|--------------|--------------|
| **Bronze** | Original CSV files | `/olist/bronze/*products*.csv` | |
| **Silver** | Cleaned and standardized data using Synapse **views** | `/olist/silver/products/*.parquet` |
| **Gold** | Final curated tables stored as **Parquet** files | `/olist/gold/Dim_Products/*.parquet` |
| **Dedicated** | Dedicated server where gold tables live | |

![Data Processing Design](docs/img/data_processing_design.png)

## 2. Workflow

Using pipelines, the data was extracted from cloud storage, stored in cloud and applied transformations.

In general, the pipeline has the following steps:

1. Truncate managed tables (dedicated pool).
2. Delete silver and gold files.
3. Run cleaning data pipelines (each entity).
	* Create external bronze tables.
	* Create silver views.
	* Materialize silver clean data.
4. Create data warehouse gold tables (serverless pool).
5. Load managed tables (dedicated pool).
6. Move bronze files to archive folder.

![Pipeline Inital Load](docs/img/pipeline_initial_load.png)

### 2.1. Create database

A layer database was created in order to perform sql operations over serverless pool by pipelines.

```sql
CREATE DATABASE Olist_DB
    COLLATE Latin1_General_100_BIN2_UTF8
GO;

USE Olist_DB
GO;

CREATE SCHEMA bronze
GO;

CREATE SCHEMA silver
GO;

CREATE SCHEMA gold
GO;

CREATE EXTERNAL DATA SOURCE bronze_data WITH (
    LOCATION = 'https://datalakexxxxxx.dfs.core.windows.net/olist/bronze/'
);
GO;

CREATE EXTERNAL DATA SOURCE silver_data WITH (
    LOCATION = 'https://datalakexxxxxx.dfs.core.windows.net/olist/silver/'
);
GO;

CREATE EXTERNAL DATA SOURCE gold_data WITH (
    LOCATION = 'https://datalakexxxxxx.dfs.core.windows.net/olist/gold/'
);
GO;

CREATE EXTERNAL FILE FORMAT CsvFormat
    WITH (
        FORMAT_TYPE = DELIMITEDTEXT,
        FORMAT_OPTIONS(
            FIELD_TERMINATOR = ',',
            STRING_DELIMITER = '"',
            FIRST_ROW = 2
        )
    );
GO;

CREATE EXTERNAL FILE FORMAT ParquetFormat
    WITH (
            FORMAT_TYPE = PARQUET,
            DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
        );
GO;
```

### 2.2. Create external Tables - Bronze Layer

Each external table points directly to each CSV file, which is located in Azure Data Lake.

```sql
-- Example
IF (SELECT OBJECT_ID('bronze.products', 'U')) IS NOT NULL
	DROP EXTERNAL TABLE bronze.products;

CREATE EXTERNAL TABLE bronze.products
(
	product_id VARCHAR(50),
	product_category_name NVARCHAR(50),
	product_name_lenght VARCHAR(10),
	product_description_lenght VARCHAR(10),
	product_photos_qty VARCHAR(10),
	product_weight_g VARCHAR(10),
	product_length_cm VARCHAR(10),
	product_height_cm VARCHAR(10),
	product_width_cm VARCHAR(10)
)
WITH
(
	DATA_SOURCE = bronze_data,
	LOCATION = '*products*.csv',
	FILE_FORMAT = CsvFormat
);
```

### 2.3. Data Cleaning and Transformation - Stage Layer

Created views to clean and standardize the data.

Steps:

1. Replaced missing values.
    * Numeric columns were filled with '0'.
    * Date columns were filled with '1900-01-01 00:00:00.000'.
    * String columns were filled with ''.
2. Trimmed spaces from string columns.
3. Removed duplicated values.
4. Validated data integrity.

```sql
-- Example
DROP VIEW IF EXISTS silver.vw_order_items_clean;

CREATE VIEW silver.vw_order_items_clean
AS
SELECT
	order_id,
	order_item_id,
	product_id,
	seller_id,
	shipping_limit_date,
	price_date,
	freight_value_date
FROM bronze.order_items;

-------------------- Final view --------------------
DROP VIEW IF EXISTS silver.vw_order_items_final;

CREATE VIEW silver.vw_order_items_final
AS
SELECT DISTINCT
    order_id,
    CAST(order_item_id AS INT) AS order_item_id,
    product_id,
    seller_id,
    CAST(shipping_limit_date AS DATE) AS shipping_limit_date,
    CAST(price AS DECIMAL(10, 2)) AS price,
    CAST(freight_value AS DECIMAL(10, 2)) AS freight_value
FROM silver.vw_order_items_clean
WHERE TRY_CAST(order_item_id AS INT) IS NOT NULL
AND TRY_CAST(shipping_limit_date AS DATE) IS NOT NULL
AND TRY_CAST(price AS DECIMAL(10, 2)) IS NOT NULL
AND TRY_CAST(freight_value AS DECIMAL(10, 2)) IS NOT NULL;
```

### 2.4. Curated data - Silver Layer

The data was materialized into Parquet files.

```sql
IF (SELECT OBJECT_ID('silver.order_items', 'U')) IS NOT NULL
	DROP EXTERNAL TABLE silver.order_items;

CREATE EXTERNAL TABLE silver.order_items
	WITH (
		LOCATION = 'order_items/',
		DATA_SOURCE = silver_data,
		FILE_FORMAT = ParquetFormat
	)
AS
SELECT
	order_id,
	order_item_id,
	product_id,
	seller_id,
	shipping_limit_date,
	price,
	freight_value
FROM silver.vw_order_items_final;
```

### 2.5. Create table for start schema - Gold Layer

For analysis, denormalization was applied.

```sql
-- Example
IF (SELECT OBJECT_ID('gold.Fact_Orders', 'U')) IS NOT NULL
	DROP EXTERNAL TABLE gold.Fact_Orders;

CREATE EXTERNAL TABLE gold.Fact_Orders
	WITH (
		LOCATION = 'Fact_Orders/',
		DATA_SOURCE = gold_data,
		FILE_FORMAT = ParquetFormat
	)
AS
SELECT
	d.order_id,
	d.order_item_id,
	o.customer_id,
	o.order_status,
	o.order_purchase_timestamp,
	o.order_approved_at,
	o.order_delivered_carrier_date,
	o.order_delivered_customer_date,
	o.order_estimated_delivery_date,
	d.product_id,
	d.seller_id,
	d.shipping_limit_date,
	d.price,
	d.freight_value,
	r.review_score,
	r.review_comment_title,
	p.payment_sequential,
	p.payment_type,
	p.payment_installments,
	p.payment_value
FROM silver.order_items d
INNER JOIN silver.orders o ON o.order_id = d.order_id
INNER JOIN silver.order_reviews r ON r.order_id = o.order_id
INNER JOIN silver.order_payments p ON p.order_id = o.order_id;
```

### 2.6. Create table for start schema - Dedicated Pool

```sql
-- Example
IF (SELECT OBJECT_ID('OLIST_DB.Fact_Orders', 'U')) IS NOT NULL
    DROP TABLE OLIST_DB.Fact_Orders;

CREATE TABLE OLIST_DB.Fact_Orders
(
    order_id_alternate VARCHAR(50) NOT NULL,
    order_item_id INT NOT NULL,
    customer_id VARCHAR(50) NOT NULL,
    order_status NVARCHAR(20) NOT NULL,
    order_purchase_timestamp DATE NOT NULL,
    order_approved_at DATE NOT NULL,
    order_delivered_carrier_date DATE NOT NULL,
    order_delivered_customer_date DATE NOT NULL,
    order_estimated_delivery_date DATE NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    seller_id VARCHAR(50) NOT NULL,
    shipping_limit_date DATE NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    freight_value DECIMAL(10, 2) NOT NULL,
    review_score INT NOT NULL,
    review_comment_title NVARCHAR(50) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type NVARCHAR(50) NOT NULL,
    payment_installments INT NOT NULL,
    payment_value DECIMAL(10, 2) NOT NULL
)
WITH
(
    DISTRIBUTION = HASH(order_id_alternate),
    CLUSTERED COLUMNSTORE INDEX
);
```
