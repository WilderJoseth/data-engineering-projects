Use AdventureWorksLT2022_DB;
GO;

--------------------- Start bronze layer ---------------------
IF (SELECT OBJECT_ID('bronze.SalesOrderDetail', 'U')) IS NOT NULL
    DROP EXTERNAL TABLE bronze.SalesOrderDetail;

CREATE EXTERNAL TABLE bronze.SalesOrderDetail
(
    SalesOrderID INT NULL,
    SalesOrderDetailID INT NULL,
    OrderQty SMALLINT NULL,
    ProductID INT NULL,
    UnitPrice MONEY NULL,
    UnitPriceDiscount MONEY NULL,
    LineTotal NUMERIC(38, 6) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL
)
WITH
(
    DATA_SOURCE = bronze_data,
    LOCATION = 'SalesOrderDetail/*.parquet',
    FILE_FORMAT = ParquetFormat
);
--------------------- End bronze layer ---------------------

--------------------- Start silver layer ---------------------
-- Cleaning
DROP VIEW IF EXISTS silver.vw_SalesOrderDetail_Clean;

CREATE VIEW silver.vw_SalesOrderDetail_Clean
AS
SELECT
	SalesOrderID,
	SalesOrderDetailID,
	OrderQty,
	ProductID,
	CAST(UnitPrice AS DECIMAL(8, 4)) AS UnitPrice,
	CAST(UnitPriceDiscount AS DECIMAL(8, 4)) AS UnitPriceDiscount,
	CAST(LineTotal AS DECIMAL(38, 6)) AS LineTotal
FROM bronze.SalesOrderDetail;

-- Materialization
IF (SELECT OBJECT_ID('silver.SalesOrderDetail', 'U')) IS NOT NULL
    DROP EXTERNAL TABLE silver.SalesOrderDetail;

CREATE EXTERNAL TABLE silver.SalesOrderDetail
    WITH (
        LOCATION = 'SalesOrderDetail/',
        DATA_SOURCE = silver_data,
        FILE_FORMAT = ParquetFormat
    )
AS
SELECT
	SalesOrderID,
	SalesOrderDetailID,
	OrderQty,
	ProductID,
	UnitPrice,
	UnitPriceDiscount,
	LineTotal
FROM silver.vw_SalesOrderDetail_Clean;
--------------------- End silver layer ---------------------
