Use AdventureWorksLT2022_DB;
GO;

--------------------- Start bronze layer ---------------------
IF (SELECT OBJECT_ID('bronze.ProductModel', 'U')) IS NOT NULL
    DROP EXTERNAL TABLE bronze.ProductModel;

CREATE EXTERNAL TABLE bronze.ProductModel
(
    ProductModelID INT NULL,
    Name NVARCHAR(50) NULL,
    CatalogDescription NVARCHAR(MAX) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL
)
WITH
(
    DATA_SOURCE = bronze_data,
    LOCATION = 'ProductModel/*.parquet',
    FILE_FORMAT = ParquetFormat
);
--------------------- End bronze layer ---------------------

--------------------- Start silver layer ---------------------
-- Cleaning
DROP VIEW IF EXISTS silver.vw_ProductModel_Clean;

CREATE VIEW silver.vw_ProductModel_Clean
AS
SELECT
	ProductModelID,
	UPPER(TRIM(Name)) AS Name
FROM bronze.ProductModel;

-- Materialization
IF (SELECT OBJECT_ID('silver.ProductModel', 'U')) IS NOT NULL
    DROP EXTERNAL TABLE silver.ProductModel;

CREATE EXTERNAL TABLE silver.ProductModel
    WITH (
        LOCATION = 'ProductModel/',
        DATA_SOURCE = silver_data,
        FILE_FORMAT = ParquetFormat
    )
AS
SELECT
	ProductModelID,
	Name
FROM silver.vw_ProductModel_Clean;
--------------------- End silver layer ---------------------
