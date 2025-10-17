Use Sales;
GO;

CREATE EXTERNAL TABLE dbo.orders_raw
(
    order_id VARCHAR(100),
    customer_id VARCHAR(100),
    order_status VARCHAR(20),
    order_purchase_timestamp VARCHAR(50),
    order_approved_at VARCHAR(50),
    order_delivered_carrier_date VARCHAR(50),
    order_delivered_customer_date VARCHAR(50),
    order_estimated VARCHAR(50)
)
WITH
(
    DATA_SOURCE = sales_raw_data,
    LOCATION = '*orders*.csv',
    FILE_FORMAT = CsvFormat
);
GO;

SELECT TOP 5 * FROM dbo.orders_raw;
GO;
