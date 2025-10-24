# Data exploration using Serverless SQL endpoint

The goal of this project was to build a **data lakehouse structure** on Azure using **Serverless SQL Pool** for exploration, transformation, and reporting.

Technologies:

* MSSQL On-Premise
* Pipelines
* Azure Data Lake Gen2
* Azure Synapse Serverless SQL Pool
* Power BI

## 1. Data Lake Design

The data was organized following a **three-layer architecture**:

| Layer | Description | Example Path |
|--------|--------------|--------------|
| **Bronze** | Raw data in parquet files | `/adventureworkslt2022/bronze/Product/*.parquet` | |
| **Silver** | Cleaned and standardized data using Synapse **views** | `/adventureworkslt2022/bronze/Product/*.parquet` |
| **Gold** | Final curated tables stored as **Parquet** files | `/adventureworkslt2022/silver/Product/*.parquet` |

![Data Lake Design](docs/img/data_lake_design.png)

## 2. Workflow

Using pipelines, the data was extracted from on-premise, stored in cloud and applied transformations.

In general, the pipeline has the following steps:

1. Delete previous files.
2. Copy data from on-premise to cloud.
3. Create external bronze tables.
4. Create silver views.
5. Materialized clean data.

![Pipeline per table](docs/img/pipeline_per_table.png)

### 2.1. Create database

```sql
CREATE DATABASE AdventureWorksLT2022_DB
    COLLATE Latin1_General_100_BIN2_UTF8;
GO;

------------------ Start create schemas ------------------
-- Schema for raw data
CREATE SCHEMA bronze;
GO;

-- Schema for cleaning, transforming and enriching data
CREATE SCHEMA silver;
GO;

-- Schema for curated data and data warehousing exploration
CREATE SCHEMA gold;
GO;
------------------ End create schemas ------------------

------------------ Start external data object ------------------
-- Path for raw data
CREATE EXTERNAL DATA SOURCE bronze_data WITH (
    LOCATION = 'https://xxxxxxxxxxxxxxx.dfs.core.windows.net/files/Olist/csv/'
);
GO;

-- Path for curated and cleaned data
CREATE EXTERNAL DATA SOURCE silver_data WITH (
    LOCATION = 'https://xxxxxxxxxxxxxxx.dfs.core.windows.net/files/Olist/parquet/'
);
GO;
------------------ End external data object ------------------

------------------ Start external file format object ------------------
-- Format for curated data
CREATE EXTERNAL FILE FORMAT ParquetFormat
    WITH (
            FORMAT_TYPE = PARQUET,
            DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
        );
GO;
------------------ End external file format object ------------------
```

### 2.2. Bronze Layer – External Tables

Each external table points directly to each parquet file, which is located in Azure Data Lake.

```sql
-- Example
IF (SELECT OBJECT_ID('bronze.ProductCategory', 'U')) IS NOT NULL
    DROP EXTERNAL TABLE bronze.ProductCategory;

CREATE EXTERNAL TABLE bronze.ProductCategory
(
    ProductCategoryID INT,
    ParentProductCategoryID INT,
    Name NVARCHAR(50),
    rowguid UNIQUEIDENTIFIER,
    ModifiedDate DATETIME
)
WITH
(
    DATA_SOURCE = bronze_data,
    LOCATION = 'ProductCategory/*.parquet',
    FILE_FORMAT = ParquetFormat
);
```

### 2.3. Stage Layer – Data Cleaning and Transformation

Created views to clean and standardize the data.

Steps:

1. Replaced missing values.
    * Numeric columns were filled with '0'.
    * Date columns were filled with '1900-01-01 00:00:00.000'.
    * String columns were filled with ''.
2. Trimmed spaces from string columns.
3. Transform money columns to decimal.

```sql
-- Example
DROP VIEW IF EXISTS silver.vw_ProductCategory_Clean;

CREATE VIEW silver.vw_ProductCategory_Clean
AS
SELECT
	ProductCategoryID,
	ISNULL(ParentProductCategoryID, 0) AS ParentProductCategoryID,
	UPPER(TRIM(Name)) AS Name
FROM bronze.ProductCategory;
```

### 2.4. Silver Layer - Curated data

The data was materialized into Parquet files.

```sql
-- Example
IF (SELECT OBJECT_ID('silver.ProductCategory', 'U')) IS NOT NULL
    DROP EXTERNAL TABLE silver.ProductCategory;

CREATE EXTERNAL TABLE silver.ProductCategory
    WITH (
        LOCATION = 'ProductCategory/',
        DATA_SOURCE = silver_data,
        FILE_FORMAT = ParquetFormat
    )
AS
SELECT
	ProductCategoryID,
	ParentProductCategoryID,
	Name
FROM silver.vw_ProductCategory_Clean;
```

### 2.5. Lake Database
