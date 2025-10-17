Use Sales;
GO;

CREATE EXTERNAL TABLE dbo.sellers_raw
(
    seller_id VARCHAR(100),
    seller_zip_code_prefix VARCHAR(5),
    seller_city VARCHAR(50),
    seller_state VARCHAR(2)
)
WITH
(
    DATA_SOURCE = sales_raw_data,
    LOCATION = '*sellers*.csv',
    FILE_FORMAT = CsvFormat
);
GO;

SELECT TOP 5 * FROM dbo.sellers_raw;
GO;
