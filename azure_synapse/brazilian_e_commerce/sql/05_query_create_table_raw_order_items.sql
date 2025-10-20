Use Olist_DB;
GO;

CREATE EXTERNAL TABLE raw.order_items
(
    order_id NVARCHAR(50),
    order_item_id NVARCHAR(5),
    product_id NVARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date NVARCHAR(50),
    price NVARCHAR(20),
    freight_value NVARCHAR(20)
)
WITH
(
    DATA_SOURCE = olist_raw_data,
    LOCATION = '*order_items*.csv',
    FILE_FORMAT = CsvFormat
);
GO;

