Use AdventureWorksLT2022_DB;
GO;

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
