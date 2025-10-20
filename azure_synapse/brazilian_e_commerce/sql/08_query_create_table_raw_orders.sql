Use Olist_DB;
GO;

CREATE EXTERNAL TABLE raw.orders
(
    order_id NVARCHAR(50),
    customer_id NVARCHAR(50),
    order_status NVARCHAR(20),
    order_purchase_timestamp NVARCHAR(50),
    order_approved_at NVARCHAR(50),
    order_delivered_carrier_date NVARCHAR(50),
    order_delivered_customer_date NVARCHAR(50),
    order_estimated_delivery_date NVARCHAR(50)
)
WITH
(
    DATA_SOURCE = olist_raw_data,
    LOCATION = '*orders*.csv',
    FILE_FORMAT = CsvFormat
);
GO;
