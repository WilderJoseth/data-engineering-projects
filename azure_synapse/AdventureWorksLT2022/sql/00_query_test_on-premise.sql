USE AdventureWorksLT2022;
GO;

-- CREATE SCHEMA stage;

SELECT * FROM SalesLT.Customer

SELECT DISTINCT Size FROM SalesLT.Product

SELECT DISTINCT RevisionNumber FROM SalesLT.SalesOrderHeader

sp_Help 'SalesLT.SalesOrderHeader'

---------------------------- Start Identify Missing Values ----------------------------
SELECT
	SUM(IIF(AddressLine2 IS NULL, 1, 0)) AS AddressLine2_missing
FROM SalesLT.Address
GO;

SELECT
	SUM(IIF(Title IS NULL, 1, 0)) AS Title_missing,
	SUM(IIF(MiddleName IS NULL, 1, 0)) AS MiddleName_missing,
	SUM(IIF(Suffix IS NULL, 1, 0)) AS Suffix_missing,
	SUM(IIF(CompanyName IS NULL, 1, 0)) AS CompanyName_missing,
	SUM(IIF(SalesPerson IS NULL, 1, 0)) AS SalesPerson_missing,
	SUM(IIF(EmailAddress IS NULL, 1, 0)) AS EmailAddress_missing,
	SUM(IIF(Phone IS NULL, 1, 0)) AS Phone_missing
FROM SalesLT.Customer
GO;

SELECT
	COUNT(1) AS total_rows,
	SUM(IIF(Color IS NULL, 1, 0)) AS Color_missing,
	SUM(IIF(Size IS NULL, 1, 0)) AS Size_missing,
	SUM(IIF(Weight IS NULL, 1, 0)) AS Weight_missing,
	SUM(IIF(ProductCategoryID IS NULL, 1, 0)) AS ProductCategoryID_missing,
	SUM(IIF(ProductModelID IS NULL, 1, 0)) AS ProductModelID_missing,
	SUM(IIF(SellEndDate IS NULL, 1, 0)) AS SellEndDate_missing,
	SUM(IIF(DiscontinuedDate IS NULL, 1, 0)) AS DiscontinuedDate_missing,
	SUM(IIF(ThumbNailPhoto IS NULL, 1, 0)) AS ThumbNailPhoto_missing,
	SUM(IIF(ThumbnailPhotoFileName IS NULL, 1, 0)) AS ThumbnailPhotoFileName_missing
FROM SalesLT.Product
GO;

SELECT
	SUM(IIF(ParentProductCategoryID IS NULL, 1, 0)) AS ParentProductCategoryID_missing
FROM SalesLT.ProductCategory
GO;

SELECT
	SUM(IIF(CatalogDescription IS NULL, 1, 0)) AS CatalogDescription_missing
FROM SalesLT.ProductModel
GO;

SELECT
	SUM(IIF(ShipDate IS NULL, 1, 0)) AS ShipDate_missing,
	SUM(IIF(PurchaseOrderNumber IS NULL, 1, 0)) AS PurchaseOrderNumber_missing,
	SUM(IIF(AccountNumber IS NULL, 1, 0)) AS AccountNumber_missing,
	SUM(IIF(ShipToAddressID IS NULL, 1, 0)) AS ShipToAddressID_missing,
	SUM(IIF(BillToAddressID IS NULL, 1, 0)) AS BillToAddressID_missing,
	SUM(IIF(CreditCardApprovalCode IS NULL, 1, 0)) AS CreditCardApprovalCode_missing,
	SUM(IIF(Comment IS NULL, 1, 0)) AS Comment_missing
FROM SalesLT.SalesOrderHeader
GO;
---------------------------- End Identify Missing Values ----------------------------

---------------------------- Start Fixing Missing Values and First Transformations ----------------------------
CREATE VIEW stage.vw_Address_first_transformation
AS
SELECT
	AddressID,
	UPPER(TRIM(AddressLine1)) AS AddressLine1,
	UPPER(TRIM(ISNULL(AddressLine2, ''))) AS AddressLine2,
	UPPER(TRIM(City)) AS City,
	UPPER(TRIM(StateProvince)) AS StateProvince,
	UPPER(TRIM(CountryRegion)) AS CountryRegion,
	UPPER(TRIM(PostalCode)) AS PostalCode
FROM SalesLT.Address
GO;

CREATE VIEW stage.vw_Customer_first_transformation
AS
SELECT
	CustomerID,
	NameStyle,
	UPPER(TRIM(ISNULL(Title, ''))) AS Title,
	UPPER(TRIM(FirstName)) AS FirstName,
	UPPER(TRIM(ISNULL(MiddleName, ''))) AS MiddleName,
	UPPER(TRIM(LastName)) AS LastName,
	UPPER(TRIM(ISNULL(Suffix, ''))) AS Suffix,
	UPPER(TRIM(ISNULL(CompanyName, ''))) AS CompanyName,
	UPPER(TRIM(ISNULL(SalesPerson, ''))) AS SalesPerson,
	UPPER(TRIM(ISNULL(EmailAddress, ''))) AS EmailAddress,
	UPPER(TRIM(ISNULL(Phone, ''))) AS Phone
FROM SalesLT.Customer
GO;

CREATE VIEW stage.vw_CustomerAddress_first_transformation
AS
SELECT
	CustomerID,
	AddressID,
	UPPER(TRIM(AddressType)) AS AddressType
FROM SalesLT.CustomerAddress
GO;

CREATE VIEW stage.vw_Product_first_transformation
AS
SELECT
	ProductID,
	UPPER(TRIM(Name)) AS Name,
	UPPER(TRIM(ProductNumber)) AS ProductNumber,
	UPPER(TRIM(ISNULL(Color, ''))) AS Color,
	StandardCost,
	ListPrice,
	UPPER(TRIM(ISNULL(Size, ''))) AS Size,
	ISNULL(Weight, 0) AS Weight,
	ISNULL(ProductCategoryID, 0) AS ProductCategoryID, -- CREATE A CATEGORY
	ISNULL(ProductModelID, 0) AS ProductModelID, -- CREATE A CATEGORY
	SellStartDate,
	ISNULL(SellEndDate, CONVERT(DATETIME, '1900-01-01')) AS SellEndDate,
	ISNULL(DiscontinuedDate, CONVERT(DATETIME, '1900-01-01')) AS DiscontinuedDate,
	UPPER(TRIM(ISNULL(ThumbnailPhotoFileName, ''))) AS ThumbnailPhotoFileName
FROM SalesLT.Product
GO;

CREATE VIEW stage.vw_ProductCategory_first_transformation
AS
SELECT
	ProductCategoryID,
	ISNULL(ParentProductCategoryID, 0) AS ParentProductCategoryID,
	UPPER(TRIM(Name)) AS Name
FROM SalesLT.ProductCategory
GO;

CREATE VIEW stage.vw_ProductDescription_first_transformation
AS
SELECT
	ProductDescriptionID,
	UPPER(TRIM(Description)) AS Description
FROM SalesLT.ProductDescription
GO;

CREATE VIEW stage.vw_ProductModel_first_transformation
AS
SELECT
	ProductModelID,
	UPPER(TRIM(Name)) AS Name,
	ISNULL(CatalogDescription, '') AS CatalogDescription
FROM SalesLT.ProductModel
GO;

CREATE VIEW stage.vw_ProductModelProductDescription_first_transformation
AS
SELECT
	ProductModelID,
	ProductDescriptionID,
	UPPER(TRIM(Culture)) AS Culture
FROM SalesLT.ProductModelProductDescription
GO;

CREATE VIEW stage.vw_SalesOrderDetail_first_transformation
AS
SELECT
	SalesOrderID,
	SalesOrderDetailID,
	OrderQty,
	ProductID,
	UnitPrice,
	UnitPriceDiscount,
	LineTotal
FROM SalesLT.SalesOrderDetail
GO;

CREATE VIEW stage.vw_SalesOrderHeader_first_transformation
AS
SELECT
	SalesOrderID,
	RevisionNumber,
	OrderDate,
	DueDate,
	ISNULL(ShipDate, CONVERT(DATETIME, '1900-01-01')) AS ShipDate,
	Status,
	OnlineOrderFlag,
	UPPER(TRIM(SalesOrderNumber)) AS SalesOrderNumber,
	UPPER(TRIM(ISNULL(PurchaseOrderNumber, ''))) AS PurchaseOrderNumber,
	UPPER(TRIM(ISNULL(AccountNumber, ''))) AS AccountNumber,
	CustomerID,
	ISNULL(ShipToAddressID, 0) AS ShipToAddressID,
	ISNULL(BillToAddressID, 0) AS BillToAddressID,
	UPPER(TRIM(ShipMethod)) AS ShipMethod,
	UPPER(TRIM(ISNULL(CreditCardApprovalCode, ''))) AS CreditCardApprovalCode,
	SubTotal,
	TaxAmt,
	Freight,
	TotalDue,
	UPPER(TRIM(ISNULL(Comment, ''))) AS Comment
FROM SalesLT.SalesOrderHeader
GO;
---------------------------- End Fixing Missing Values and First Transformations ----------------------------

---------------------------- Start Identifyng Duplicated Values ----------------------------
SELECT
	COUNT(*) AS count_duplicated,
	AddressID,
	AddressLine1,
	AddressLine2,
	City,
	StateProvince,
	CountryRegion,
	PostalCode
FROM stage.vw_Address_first_transformation
GROUP BY
	AddressID,
	AddressLine1,
	AddressLine2,
	City,
	StateProvince,
	CountryRegion,
	PostalCode
HAVING COUNT(*) > 1;

SELECT
	COUNT(*) AS count_duplicated,
	CustomerID,
	NameStyle,
	Title,
	FirstName,
	MiddleName,
	LastName,
	Suffix,
	CompanyName,
	SalesPerson,
	EmailAddress,
	Phone
FROM stage.vw_Customer_first_transformation
GROUP BY
	CustomerID,
	NameStyle,
	Title,
	FirstName,
	MiddleName,
	LastName,
	Suffix,
	CompanyName,
	SalesPerson,
	EmailAddress,
	Phone
HAVING COUNT(*) > 1;

SELECT
	COUNT(*) AS count_duplicated,
	CustomerID,
	AddressID,
	AddressType
FROM stage.vw_CustomerAddress_first_transformation
GROUP BY
	CustomerID,
	AddressID,
	AddressType
HAVING COUNT(*) > 1;

SELECT
	COUNT(*) AS count_duplicated,
	ProductID,
	Name,
	ProductNumber,
	Color,
	StandardCost,
	ListPrice,
	Size,
	Weight,
	ProductCategoryID,
	ProductModelID,
	SellStartDate,
	SellEndDate,
	DiscontinuedDate,
	ThumbnailPhotoFileName
FROM stage.vw_Product_first_transformation
GROUP BY
	ProductID,
	Name,
	ProductNumber,
	Color,
	StandardCost,
	ListPrice,
	Size,
	Weight,
	ProductCategoryID,
	ProductModelID,
	SellStartDate,
	SellEndDate,
	DiscontinuedDate,
	ThumbnailPhotoFileName
HAVING COUNT(*) > 1;

SELECT
	COUNT(*) AS count_duplicated,
	ProductCategoryID,
	ParentProductCategoryID,
	Name
FROM stage.vw_ProductCategory_first_transformation
GROUP BY
	ProductCategoryID,
	ParentProductCategoryID,
	Name
HAVING COUNT(*) > 1;

SELECT
	COUNT(*) AS count_duplicated,
	ProductDescriptionID,
	Description
FROM stage.vw_ProductDescription_first_transformation
GROUP BY
	ProductDescriptionID,
	Description
HAVING COUNT(*) > 1;

SELECT
	COUNT(*) AS count_duplicated,
	ProductModelID,
	Name
FROM stage.vw_ProductModel_first_transformation
GROUP BY
	ProductModelID,
	Name
HAVING COUNT(*) > 1;

SELECT
	COUNT(*) AS count_duplicated,
	ProductModelID,
	ProductDescriptionID,
	Culture
FROM stage.vw_ProductModelProductDescription_first_transformation
GROUP BY
	ProductModelID,
	ProductDescriptionID,
	Culture
HAVING COUNT(*) > 1;

SELECT
	COUNT(*) AS count_duplicated,
	SalesOrderID,
	SalesOrderDetailID,
	OrderQty,
	ProductID,
	UnitPrice,
	UnitPriceDiscount,
	LineTotal
FROM stage.vw_SalesOrderDetail_first_transformation
GROUP BY
	SalesOrderID,
	SalesOrderDetailID,
	OrderQty,
	ProductID,
	UnitPrice,
	UnitPriceDiscount,
	LineTotal
HAVING COUNT(*) > 1;

SELECT
	COUNT(*) AS count_duplicated,
	SalesOrderID,
	RevisionNumber,
	OrderDate,
	DueDate,
	ShipDate,
	Status,
	OnlineOrderFlag,
	SalesOrderNumber,
	PurchaseOrderNumber,
	AccountNumber,
	CustomerID,
	ShipToAddressID,
	BillToAddressID,
	ShipMethod,
	CreditCardApprovalCode,
	SubTotal,
	TaxAmt,
	Freight,
	TotalDue,
	Comment
FROM stage.vw_SalesOrderHeader_first_transformation
GROUP BY
	SalesOrderID,
	RevisionNumber,
	OrderDate,
	DueDate,
	ShipDate,
	Status,
	OnlineOrderFlag,
	SalesOrderNumber,
	PurchaseOrderNumber,
	AccountNumber,
	CustomerID,
	ShipToAddressID,
	BillToAddressID,
	ShipMethod,
	CreditCardApprovalCode,
	SubTotal,
	TaxAmt,
	Freight,
	TotalDue,
	Comment
HAVING COUNT(*) > 1;
---------------------------- End Identifyng Duplicated Values ----------------------------

-- 2008-06-01 00:00:00.000
-- 2008-06-13 00:00:00.000
SELECT MAX(OrderDate), MAX(DueDate), MAX(ShipDate)
FROM stage.vw_SalesOrderHeader_first_transformation

-- 1900-01-01 00:00:00.000 / 2002-06-01 00:00:00.000
SELECT MIN(SellStartDate), MIN(SellEndDate)
FROM stage.vw_product_first_transformation

DECLARE @dates_table TABLE (DateKey DATE)
DECLARE @start_date DATE, @end_date DATE
SET @start_date = CAST('2002-06-01' AS DATE)
SET @end_date = CAST('2008-06-13' AS DATE)

INSERT @dates_table VALUES (CAST('1900-01-01 00:00:00.000' AS DATE))
WHILE @start_date <= @end_date
BEGIN
	INSERT @dates_table VALUES (@start_date)
	SET @start_date = DATEADD(DAY, 1, @start_date);
END

SELECT
	CONVERT(INT, CONVERT(NVARCHAR(8), DateKey, 112)) AS DateKey,
	DateKey AS FullDate,
	YEAR(DateKey) AS CalendarYear,
	DATEPART(QUARTER, DateKey) AS CalendarQuarter,
	MONTH(DateKey) AS CalendarMonth,
	DAY(DateKey) AS CalendarDay,
	DATEPART(WEEKDAY, DateKey) AS DayOfWeek,
	UPPER(DATENAME(WEEKDAY, DateKey)) AS DayName,
	UPPER(DATENAME(MONTH, DateKey)) AS MonthName,
	'Q' + CAST(DATEPART(QUARTER, DateKey) AS NVARCHAR(1)) AS QuarterName,
	DATEPART(WEEK, DateKey) AS WeekOfYear
FROM @dates_table


