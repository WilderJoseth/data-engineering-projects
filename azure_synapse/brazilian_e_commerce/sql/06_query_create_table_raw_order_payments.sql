Use Olist_DB;
GO;

CREATE EXTERNAL TABLE raw.order_payments
(
    order_id NVARCHAR(50),
    payment_sequential NVARCHAR(5),
    payment_type NVARCHAR(50),
    payment_installments NVARCHAR(5),
    payment_value NVARCHAR(20)
)
WITH
(
    DATA_SOURCE = olist_raw_data,
    LOCATION = '*order_payments*.csv',
    FILE_FORMAT = CsvFormat
);
GO;

