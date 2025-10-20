Use Olist_DB;
GO;

CREATE EXTERNAL TABLE raw.customers
(
    customer_id VARCHAR(100),
    customer_unique_id VARCHAR(100),
    customer_zip_code_prefix VARCHAR(5),
    customer_city VARCHAR(50),
    customer_state VARCHAR(2)
)
WITH
(
    DATA_SOURCE = olist_raw_data,
    LOCATION = '*customers*.csv',
    FILE_FORMAT = CsvFormat
);
GO;
