Use Olist_DB;
GO;

CREATE EXTERNAL TABLE dw.fact_orders
    WITH (
        LOCATION = 'orders/',
        DATA_SOURCE = olist_cleaned_data,
        FILE_FORMAT = ParquetFormat
    )
AS
SELECT
    CAST(o.order_id AS VARCHAR(50)) AS order_id,
    CAST(o.customer_id AS VARCHAR(50)) AS customer_id,
    CAST(o.order_status AS VARCHAR(20)) AS order_status,
    CAST(o.order_purchase_timestamp AS DATETIME) AS order_purchase_timestamp,
    CAST(o.order_approved_at AS DATETIME) AS order_approved_at,
    CAST(o.order_delivered_carrier_date AS DATETIME) AS order_delivered_carrier_date,
    CAST(o.order_delivered_customer_date AS DATETIME) AS order_delivered_customer_date,
    CAST(o.order_estimated_delivery_date AS DATETIME) AS order_estimated_delivery_date,
    CAST(i.order_item_id AS INT) AS order_item_id,
    CAST(i.product_id AS VARCHAR(50)) AS product_id,
    CAST(i.seller_id AS VARCHAR(50)) AS seller_id,
    CAST(i.shipping_limit_date AS DATETIME) AS shipping_limit_date,
    CAST(i.price AS DECIMAL(10, 2)) AS price,
    CAST(i.freight_value AS DECIMAL(10, 2)) AS freight_value,
    CAST(p.payment_sequential AS INT) AS payment_sequential,
    CAST(p.payment_type AS VARCHAR(20)) AS payment_type,
    CAST(p.payment_installments AS INT) AS payment_installments,
    CAST(p.payment_value AS DECIMAL(10, 2)) AS payment_value,
    CAST(r.review_score AS INT) AS review_score,
    r.review_comment_message
FROM stage.vw_orders_no_missing_values o
INNER JOIN raw.order_items i ON o.order_id = i.order_id
INNER JOIN stage.vw_order_payments_no_missing_values p ON p.order_id = o.order_id
INNER JOIN stage.vw_order_reviews_no_missing_values r ON r.order_id = o.order_id;
GO;

CREATE EXTERNAL TABLE dw.dim_customers
    WITH (
        LOCATION = 'customers/',
        DATA_SOURCE = olist_cleaned_data,
        FILE_FORMAT = ParquetFormat
    )
AS
SELECT
	CAST(customer_id AS VARCHAR(50)) AS customer_id,
	CAST(customer_unique_id AS VARCHAR(50)) AS customer_unique_id,
	CAST(customer_zip_code_prefix AS CHAR(5)) AS customer_zip_code_prefix,
	customer_city,
	CAST(customer_state AS CHAR(2)) AS customer_state
FROM stage.vw_customers_no_missing_values;
GO;

CREATE EXTERNAL TABLE dw.dim_products
    WITH (
        LOCATION = 'products/',
        DATA_SOURCE = olist_cleaned_data,
        FILE_FORMAT = ParquetFormat
    )
AS
SELECT
	CAST(product_id AS VARCHAR(50)) AS product_id,
	product_category_name,
	CAST(product_weight_g AS INT) AS product_weight_g,
	CAST(product_height_cm AS INT) AS product_height_cm,
	CAST(product_width_cm AS INT) AS product_width_cm
FROM stage.vw_products_no_missing_values;
GO;

CREATE EXTERNAL TABLE dw.dim_sellers
    WITH (
        LOCATION = 'sellers/',
        DATA_SOURCE = olist_cleaned_data,
        FILE_FORMAT = ParquetFormat
    )
AS
SELECT
    CAST(seller_id AS VARCHAR(50)) AS seller_id,
	CAST(seller_zip_code_prefix AS CHAR(2)) AS seller_zip_code_prefix,
	seller_city,
	CAST(seller_state AS CHAR(2)) AS seller_state
FROM stage.vw_sellers_no_missing_values;
GO;



