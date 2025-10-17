Use Sales;
GO;

CREATE VIEW dbo.vw_order_items AS
SELECT
    order_id,
    TRY_CAST(order_item_id AS INT) AS order_item_id,
    product_id,
    seller_id,
    TRY_CAST(shipping_limit_date AS DATETIME) AS shipping_limit_date,
    TRY_CAST(price AS DECIMAL(10, 2)) AS price,
    TRY_CAST(freight_value AS DECIMAL(10, 2)) AS freight_value
FROM dbo.order_items_raw
GO;

CREATE EXTERNAL TABLE dbo.order_items
    WITH (
        LOCATION = 'order_items/',
        DATA_SOURCE = sales_cleaned_data,
        FILE_FORMAT = ParquetFormat
    )
AS
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
FROM dbo.vw_order_items
WHERE order_item_id IS NOT NULL
AND shipping_limit_date IS NOT NULL
AND price IS NOT NULL
AND freight_value IS NOT NULL
GO;

SELECT * FROM dbo.order_items;
GO;
