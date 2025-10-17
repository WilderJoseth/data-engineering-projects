Use Sales;
GO;

CREATE EXTERNAL TABLE dbo.order_payments_raw
(
    order_id VARCHAR(100),
    payment_sequential VARCHAR(5),
    payment_type VARCHAR(50),
    payment_installments VARCHAR(5),
    payment_value VARCHAR(20)
)
WITH
(
    DATA_SOURCE = sales_raw_data,
    LOCATION = '*order_payments*.csv',
    FILE_FORMAT = CsvFormat
);
GO;

SELECT TOP 5 * FROM dbo.order_payments_raw;
GO;
