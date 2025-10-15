Use Sales_Bronze;
GO;

CREATE EXTERNAL TABLE dbo.sellers
(
    seller_id VARCHAR(100),
    seller_zip_code_prefix VARCHAR(5),
    seller_city VARCHAR(50),
    seller_state VARCHAR(2)
)
WITH
(
    DATA_SOURCE = sales_bronze_data,
    LOCATION = 'csv/*sellers*.csv',
    FILE_FORMAT = CsvFormat
);
GO
