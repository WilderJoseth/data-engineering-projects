Use AdventureWorksLT2022_DB;
GO;

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
