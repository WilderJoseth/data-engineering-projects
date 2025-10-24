Use AdventureWorksLT2022_DB;
GO;

DROP VIEW IF EXISTS silver.vw_ProductCategory_Clean;

CREATE VIEW silver.vw_ProductCategory_Clean
AS
SELECT
	ProductCategoryID,
	ISNULL(ParentProductCategoryID, 0) AS ParentProductCategoryID,
	UPPER(TRIM(Name)) AS Name
FROM bronze.ProductCategory;