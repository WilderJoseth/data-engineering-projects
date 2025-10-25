Use AdventureWorksLT2022_DB;
GO;

--------------------- Start bronze layer ---------------------
IF (SELECT OBJECT_ID('bronze.Address', 'U')) IS NOT NULL
    DROP EXTERNAL TABLE bronze.Address;

CREATE EXTERNAL TABLE bronze.Address
(
    AddressID INT NULL,
    AddressLine1 NVARCHAR(60) NULL,
    AddressLine2 NVARCHAR(60) NULL,
    City NVARCHAR(30) NULL,
    StateProvince NVARCHAR(50) NULL,
    CountryRegion NVARCHAR(50) NULL,
    PostalCode NVARCHAR(15) NULL,
    rowguid UNIQUEIDENTIFIER NULL,
    ModifiedDate DATETIME NULL
)
WITH
(
    DATA_SOURCE = bronze_data,
    LOCATION = 'Address/*.parquet',
    FILE_FORMAT = ParquetFormat
);
--------------------- End bronze layer ---------------------

--------------------- Start silver layer ---------------------
-- Cleaning
DROP VIEW IF EXISTS silver.vw_Address_Clean;

CREATE VIEW silver.vw_Address_Clean
AS
SELECT
	AddressID,
	UPPER(TRIM(AddressLine1)) AS AddressLine1,
	UPPER(TRIM(ISNULL(AddressLine2, ''))) AS AddressLine2,
	UPPER(TRIM(City)) AS City,
	UPPER(TRIM(StateProvince)) AS StateProvince,
	UPPER(TRIM(CountryRegion)) AS CountryRegion,
	UPPER(TRIM(PostalCode)) AS PostalCode
FROM bronze.Address;

-- Materialization
IF (SELECT OBJECT_ID('silver.Address', 'U')) IS NOT NULL
    DROP EXTERNAL TABLE silver.Address;

CREATE EXTERNAL TABLE silver.Address
    WITH (
        LOCATION = 'Address/',
        DATA_SOURCE = silver_data,
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
FROM silver.vw_Address_Clean;
--------------------- End silver layer ---------------------
