Use Sales;
GO;

CREATE EXTERNAL TABLE dbo.order_items_raw
(
    order_id VARCHAR(100),
    order_item_id VARCHAR(5),
    product_id VARCHAR(100),
    seller_id VARCHAR(100),
    shipping_limit_date VARCHAR(50),
    price VARCHAR(20),
    freight_value VARCHAR(20)
)
WITH
(
    DATA_SOURCE = sales_raw_data,
    LOCATION = '*order_items*.csv',
    FILE_FORMAT = CsvFormat
);
GO;

SELECT TOP 5 * FROM dbo.order_items_raw;
GO;
