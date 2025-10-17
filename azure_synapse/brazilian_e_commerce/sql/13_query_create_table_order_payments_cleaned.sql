Use Sales;
GO;

CREATE VIEW dbo.vw_order_payments AS
SELECT
    order_id,
    TRY_CAST(payment_sequential AS INT) AS payment_sequential,
    payment_type,
    TRY_CAST(payment_installments AS INT) AS payment_installments,
    TRY_CAST(payment_value AS DECIMAL(10, 2)) AS payment_value
FROM dbo.order_payments_raw
GO;

CREATE EXTERNAL TABLE dbo.order_payments
    WITH (
        LOCATION = 'order_payments/',
        DATA_SOURCE = sales_cleaned_data,
        FILE_FORMAT = ParquetFormat
    )
AS
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM dbo.vw_order_payments
WHERE payment_sequential IS NOT NULL
AND payment_installments IS NOT NULL
AND payment_value IS NOT NULL
GO;

SELECT * FROM dbo.order_items;
GO;


