Use Sales;
GO;

CREATE EXTERNAL TABLE dbo.customers_raw
(
    customer_id VARCHAR(100),
    customer_unique_id VARCHAR(100),
    customer_zip_code_prefix VARCHAR(5),
    customer_city VARCHAR(50),
    customer_state VARCHAR(2)
)
WITH
(
    DATA_SOURCE = sales_raw_data,
    LOCATION = '*customers*.csv',
    FILE_FORMAT = CsvFormat
);
GO;

SELECT TOP 5 * FROM dbo.customers_raw;
GO;
