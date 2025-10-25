Use AdventureWorksLT2022_DB;
GO;

--------------------- Start bronze layer ---------------------
IF (SELECT OBJECT_ID('bronze.SalesOrderHeader', 'U')) IS NOT NULL
    DROP EXTERNAL TABLE bronze.SalesOrderHeader;

CREATE EXTERNAL TABLE bronze.SalesOrderHeader
(
    SalesOrderID INT NULL,
    RevisionNumber TINYINT NULL,
    OrderDate DATETIME NULL,
    DueDate DATETIME NULL,
    ShipDate DATETIME NULL,
    Status TINYINT NULL,
    OnlineOrderFlag BIT NULL,
    SalesOrderNumber NVARCHAR(25) NULL,
    PurchaseOrderNumber NVARCHAR(25) NULL,
    AccountNumber NVARCHAR(15) NULL,
    CustomerID INT NULL,
    ShipToAddressID INT NULL,
    BillToAddressID INT NULL,
    ShipMethod NVARCHAR(50) NULL,
    CreditCardApprovalCode VARCHAR(25) NULL,
    SubTotal MONEY NULL,
    TaxAmt MONEY NULL,
    Freight MONEY NULL,
    TotalDue MONEY NULL,
    Comment NVARCHAR(MAX) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL
)
WITH
(
    DATA_SOURCE = bronze_data,
    LOCATION = 'SalesOrderHeader/*.parquet',
    FILE_FORMAT = ParquetFormat
);
--------------------- End bronze layer ---------------------

--------------------- Start silver layer ---------------------
-- Cleaning
DROP VIEW IF EXISTS silver.vw_SalesOrderHeader_Clean;

CREATE VIEW silver.vw_SalesOrderHeader_Clean
AS
SELECT
	SalesOrderID,
	CAST(OrderDate AS DATE) AS OrderDate,
	CAST(DueDate AS DATE) AS DueDate,
	CAST(ISNULL(ShipDate, CONVERT(DATETIME, '1900-01-01')) AS DATE) AS ShipDate,
	IIF(OnlineOrderFlag = 'TRUE', 'YES', 'NO') AS OnlineOrderFlag,
	UPPER(TRIM(SalesOrderNumber)) AS SalesOrderNumber,
	UPPER(TRIM(ISNULL(PurchaseOrderNumber, ''))) AS PurchaseOrderNumber,
	UPPER(TRIM(ISNULL(AccountNumber, ''))) AS AccountNumber,
	CustomerID,
	ISNULL(ShipToAddressID, 0) AS ShipToAddressID,
	ISNULL(BillToAddressID, 0) AS BillToAddressID,
	UPPER(TRIM(ShipMethod)) AS ShipMethod,
	UPPER(TRIM(ISNULL(CreditCardApprovalCode, ''))) AS CreditCardApprovalCode,
	CAST(SubTotal AS DECIMAL(12, 4)) AS SubTotal,
	CAST(TaxAmt AS DECIMAL(12, 4)) AS TaxAmt,
	CAST(Freight AS DECIMAL(12, 4)) AS Freight,
	CAST(TotalDue AS DECIMAL(12, 4)) AS TotalDue
FROM bronze.SalesOrderHeader;

-- Materialization
IF (SELECT OBJECT_ID('silver.SalesOrderHeader', 'U')) IS NOT NULL
    DROP EXTERNAL TABLE silver.SalesOrderHeader;

CREATE EXTERNAL TABLE silver.SalesOrderHeader
    WITH (
        LOCATION = 'SalesOrderHeader/',
        DATA_SOURCE = silver_data,
        FILE_FORMAT = ParquetFormat
    )
AS
SELECT
	SalesOrderID,
	OrderDate,
	DueDate,
	ShipDate,
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
	TotalDue
FROM silver.vw_SalesOrderHeader_Clean;
--------------------- End silver layer ---------------------
