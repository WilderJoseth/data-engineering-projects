Use Sales;
GO;

CREATE VIEW dbo.vw_orders AS
SELECT
    order_id,
    customer_id,
    order_status,
    TRY_CAST(order_purchase_timestamp AS DATETIME) AS order_purchase_timestamp,
    TRY_CAST(order_approved_at AS DATETIME) AS order_approved_at,
    TRY_CAST(order_delivered_carrier_date AS DATETIME) AS order_delivered_carrier_date,
    TRY_CAST(order_delivered_customer_date AS DATETIME) AS order_delivered_customer_date,
    TRY_CAST(order_estimated AS DATETIME) AS order_estimated
FROM dbo.orders_raw
GO;

CREATE EXTERNAL TABLE dbo.orders
    WITH (
        LOCATION = 'orders/',
        DATA_SOURCE = sales_cleaned_data,
        FILE_FORMAT = ParquetFormat
    )
AS
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated
FROM dbo.vw_orders
WHERE order_purchase_timestamp IS NOT NULL
AND order_approved_at IS NOT NULL
AND order_delivered_carrier_date IS NOT NULL
AND order_delivered_customer_date IS NOT NULL
AND order_estimated IS NOT NULL
GO;

SELECT * FROM dbo.orders;
GO;
