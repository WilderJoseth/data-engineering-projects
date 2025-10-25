Use AdventureWorksLT2022_DB;
GO;

--------------------- Start bronze layer ---------------------
IF (SELECT OBJECT_ID('bronze.Product', 'U')) IS NOT NULL
    DROP EXTERNAL TABLE bronze.Product;

CREATE EXTERNAL TABLE bronze.Product
(
    ProductID INT NULL,
    Name NVARCHAR(50) NULL,
    ProductNumber NVARCHAR(25) NULL,
    Color NVARCHAR(15) NULL,
    StandardCost MONEY NULL,
    ListPrice MONEY NULL,
    Size NVARCHAR(5) NULL,
    Weight DECIMAL(8, 2) NULL,
    ProductCategoryID INT NULL,
    ProductModelID INT NULL,
    SellStartDate DATETIME NULL,
    SellEndDate DATETIME NULL,
    DiscontinuedDate DATETIME NULL,
    ThumbNailPhoto VARBINARY(MAX) NULL,
    ThumbnailPhotoFileName NVARCHAR(50) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL
)
WITH
(
    DATA_SOURCE = bronze_data,
    LOCATION = 'Product/*.parquet',
    FILE_FORMAT = ParquetFormat
);
--------------------- End bronze layer ---------------------

--------------------- Start silver layer ---------------------
-- Cleaning
DROP VIEW IF EXISTS silver.vw_Product_Clean;

CREATE VIEW silver.vw_Product_Clean
AS
SELECT
	ProductID,
	UPPER(TRIM(Name)) AS Name,
	UPPER(TRIM(ProductNumber)) AS ProductNumber,
	UPPER(TRIM(ISNULL(Color, 'N/A'))) AS Color,
	CAST(StandardCost AS DECIMAL(10, 4)) AS StandardCost,
	CAST(ListPrice AS DECIMAL(10, 4)) AS ListPrice,
	UPPER(TRIM(ISNULL(Size, 'N/A'))) AS Size,
	ISNULL(ProductCategoryID, 0) AS ProductCategoryID,
	ISNULL(ProductModelID, 0) AS ProductModelID,
	CAST(SellStartDate AS DATE) AS SellStartDate,
	CAST(ISNULL(SellEndDate, CAST('1900-01-01' AS DATETIME)) AS DATE) AS SellEndDate
FROM bronze.Product;

-- Materialization
IF (SELECT OBJECT_ID('silver.Product', 'U')) IS NOT NULL
    DROP EXTERNAL TABLE silver.Product;

CREATE EXTERNAL TABLE silver.Product
    WITH (
        LOCATION = 'Product/',
        DATA_SOURCE = silver_data,
        FILE_FORMAT = ParquetFormat
    )
AS
SELECT
	ProductID,
	Name,
	ProductNumber,
	Color,
	StandardCost,
	ListPrice,
	Size,
	ProductCategoryID,
	ProductModelID,
	SellStartDate,
	SellEndDate
FROM silver.vw_Product_Clean;
--------------------- End silver layer ---------------------
