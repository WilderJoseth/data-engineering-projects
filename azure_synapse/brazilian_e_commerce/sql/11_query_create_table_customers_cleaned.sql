Use Sales;
GO;

CREATE EXTERNAL TABLE dbo.customers
    WITH (
        LOCATION = 'customers/',
        DATA_SOURCE = sales_cleaned_data,
        FILE_FORMAT = ParquetFormat
    )
AS
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM dbo.customers_raw;
GO;

SELECT * FROM dbo.customers;
GO;
