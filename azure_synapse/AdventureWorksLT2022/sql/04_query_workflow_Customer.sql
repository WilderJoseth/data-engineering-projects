Use AdventureWorksLT2022_DB;
GO;

--------------------- Start bronze layer ---------------------
IF (SELECT OBJECT_ID('bronze.Customer', 'U')) IS NOT NULL
    DROP EXTERNAL TABLE bronze.Customer;

CREATE EXTERNAL TABLE bronze.Customer
(
    CustomerID INT NULL,
    NameStyle BIT NULL,
    Title NVARCHAR(8) NULL,
    FirstName NVARCHAR(50) NULL,
    MiddleName NVARCHAR(50) NULL,
    LastName NVARCHAR(50) NULL,
    Suffix NVARCHAR(10) NULL,
    CompanyName NVARCHAR(128) NULL,
    SalesPerson NVARCHAR(256) NULL,
    EmailAddress NVARCHAR(50) NULL,
    Phone NVARCHAR(25) NULL,
    PasswordHash VARCHAR(128) NULL,
    PasswordSalt VARCHAR(10) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL
)
WITH
(
    DATA_SOURCE = bronze_data,
    LOCATION = 'Customer/*.parquet',
    FILE_FORMAT = ParquetFormat
);
--------------------- End bronze layer ---------------------

--------------------- Start silver layer ---------------------
-- Cleaning
DROP VIEW IF EXISTS silver.vw_Customer_Clean;

CREATE VIEW silver.vw_Customer_Clean
AS
SELECT
	CustomerID,
	UPPER(TRIM(ISNULL(Title, ''))) AS Title,
	UPPER(TRIM(FirstName)) AS FirstName,
	UPPER(TRIM(ISNULL(MiddleName, ''))) AS MiddleName,
	UPPER(TRIM(LastName)) AS LastName,
	UPPER(TRIM(ISNULL(Suffix, ''))) AS Suffix,
	UPPER(TRIM(ISNULL(CompanyName, ''))) AS CompanyName,
	UPPER(TRIM(ISNULL(SalesPerson, ''))) AS SalesPerson,
	UPPER(TRIM(ISNULL(EmailAddress, ''))) AS EmailAddress,
	UPPER(TRIM(ISNULL(Phone, ''))) AS Phone
FROM bronze.Customer;

-- Materialization
IF (SELECT OBJECT_ID('silver.Customer', 'U')) IS NOT NULL
    DROP EXTERNAL TABLE silver.Customer;

CREATE EXTERNAL TABLE silver.Customer
    WITH (
        LOCATION = 'Customer/',
        DATA_SOURCE = silver_data,
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
FROM silver.vw_Customer_Clean;
--------------------- End silver layer ---------------------
