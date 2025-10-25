Use AdventureWorksLT2022_DB;
GO;

--------------------- Start bronze layer ---------------------
IF (SELECT OBJECT_ID('bronze.ProductCategory', 'U')) IS NOT NULL
    DROP EXTERNAL TABLE bronze.ProductCategory;

CREATE EXTERNAL TABLE bronze.ProductCategory
(
    ProductCategoryID INT NULL,
    ParentProductCategoryID INT NULL,
    Name NVARCHAR(50) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL
)
WITH
(
    DATA_SOURCE = bronze_data,
    LOCATION = 'ProductCategory/*.parquet',
    FILE_FORMAT = ParquetFormat
);
--------------------- End bronze layer ---------------------

--------------------- Start silver layer ---------------------
-- Cleaning
DROP VIEW IF EXISTS silver.vw_ProductCategory_Clean;

CREATE VIEW silver.vw_ProductCategory_Clean
AS
SELECT
	ProductCategoryID,
	UPPER(TRIM(Name)) AS Name
FROM bronze.ProductCategory;

-- Materialization
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
	Name
FROM silver.vw_ProductCategory_Clean;
--------------------- End silver layer ---------------------
