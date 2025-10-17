Use Sales;
GO;

CREATE EXTERNAL TABLE dbo.sellers
    WITH (
        LOCATION = 'sellers/',
        DATA_SOURCE = sales_cleaned_data,
        FILE_FORMAT = ParquetFormat
    )
AS
SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM dbo.sellers_raw;
GO;

SELECT * FROM dbo.sellers;
GO;
