Use AdventureWorksLT2022_DB;
GO;

------------------ Start Fact_Orders ------------------
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
    d.SalesOrderDetailID,
    h.OrderDate,
    h.DueDate,
    h.ShipDate,
    h.OnlineOrderFlag,
    h.SalesOrderNumber,
    h.PurchaseOrderNumber,
    h.AccountNumber,
    h.CustomerID,
    h.ShipToAddressID,
    h.BillToAddressID,
    h.ShipMethod,
    h.CreditCardApprovalCode,
    d.OrderQty,
    d.ProductID,
    d.UnitPrice,
    d.UnitPriceDiscount,
    d.LineTotal,
    h.SubTotal,
    h.TaxAmt,
    h.Freight,
    h.TotalDue
FROM silver.SalesOrderDetail d
INNER JOIN silver.SalesOrderHeader h ON h.SalesOrderID = d.SalesOrderID
------------------ End Fact_Orders ------------------

------------------ Start Dim_Products ------------------
IF (SELECT OBJECT_ID('gold.Dim_Products', 'U')) IS NOT NULL
    DROP EXTERNAL TABLE gold.Dim_Products;

CREATE EXTERNAL TABLE gold.Dim_Products
    WITH (
        LOCATION = 'Dim_Products/',
        DATA_SOURCE = gold_data,
        FILE_FORMAT = ParquetFormat
    )
AS
SELECT
    p.ProductID,
    p.Name,
    p.ProductNumber,
    c.Name AS CategoryName,
    m.Name AS ModelName,
    p.Color,
    p.StandardCost,
    p.ListPrice,
    p.Size,
    p.SellStartDate,
    p.SellEndDate
FROM silver.Product p
INNER JOIN silver.ProductCategory c ON c.ProductCategoryID = p.ProductCategoryID
INNER JOIN silver.ProductModel m ON m.ProductModelID = p.ProductModelID;
------------------ End Dim_Products ------------------

------------------ Start Dim_Address ------------------
IF (SELECT OBJECT_ID('gold.Dim_Address', 'U')) IS NOT NULL
    DROP EXTERNAL TABLE gold.Dim_Address;

CREATE EXTERNAL TABLE gold.Dim_Address
    WITH (
        LOCATION = 'Dim_Address/',
        DATA_SOURCE = gold_data,
        FILE_FORMAT = ParquetFormat
    )
AS
SELECT
	AddressID,
	AddressLine1,
	AddressLine2,
	City,
	StateProvince,
	CountryRegion,
	PostalCode
FROM silver.Address;
------------------ End Dim_Address ------------------

------------------ Start Dim_Customer ------------------
IF (SELECT OBJECT_ID('gold.Dim_Customer', 'U')) IS NOT NULL
    DROP EXTERNAL TABLE gold.Dim_Customer;

CREATE EXTERNAL TABLE gold.Dim_Customer
    WITH (
        LOCATION = 'Dim_Customer/',
        DATA_SOURCE = gold_data,
        FILE_FORMAT = ParquetFormat
    )
AS
SELECT
	CustomerID,
	Title,
	FirstName,
	MiddleName,
	LastName,
	Suffix,
	CompanyName,
	SalesPerson,
	EmailAddress,
	Phone
FROM silver.Customer;
------------------ End Dim_Customer ------------------













