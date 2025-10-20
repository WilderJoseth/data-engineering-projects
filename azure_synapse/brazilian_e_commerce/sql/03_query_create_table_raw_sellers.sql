Use Olist_DB;
GO;

CREATE EXTERNAL TABLE raw.sellers
(
    seller_id NVARCHAR(50),
    seller_zip_code_prefix NVARCHAR(5),
    seller_city NVARCHAR(50),
    seller_state NVARCHAR(2)
)
WITH
(
    DATA_SOURCE = olist_raw_data,
    LOCATION = '*sellers*.csv',
    FILE_FORMAT = CsvFormat
);
GO;

