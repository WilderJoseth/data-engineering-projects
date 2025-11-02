USE Olist_DB;

--------------- orders ---------------
DROP VIEW IF EXISTS silver.vw_orders_final;

CREATE VIEW silver.vw_orders_final
AS
SELECT DISTINCT
    order_id,
    customer_id,
    order_status,
    CAST(order_purchase_timestamp AS DATE) AS order_purchase_timestamp,
    YEAR(order_purchase_timestamp) AS year,
    MONTH(order_purchase_timestamp) AS month,
    CAST(order_approved_at AS DATE) AS order_approved_at,
    CAST(order_delivered_carrier_date AS DATE) AS order_delivered_carrier_date,
    CAST(order_delivered_customer_date AS DATE) AS order_delivered_customer_date,
    CAST(order_estimated_delivery_date AS DATE) AS order_estimated_delivery_date
FROM silver.vw_orders_clean
WHERE TRY_CAST(order_purchase_timestamp AS DATE) IS NOT NULL
AND TRY_CAST(order_approved_at AS DATE) IS NOT NULL
AND TRY_CAST(order_delivered_carrier_date AS DATE) IS NOT NULL
AND TRY_CAST(order_delivered_customer_date AS DATE) IS NOT NULL
AND TRY_CAST(order_estimated_delivery_date AS DATE) IS NOT NULL;
--------------- orders ---------------

--------------- order_items ---------------
DROP VIEW IF EXISTS silver.vw_order_items_final;

CREATE VIEW silver.vw_order_items_final
AS
SELECT DISTINCT
    order_id,
    CAST(order_item_id AS INT) AS order_item_id,
    product_id,
    seller_id,
    CAST(shipping_limit_date AS DATE) AS shipping_limit_date,
    CAST(price AS DECIMAL(10, 2)) AS price,
    CAST(freight_value AS DECIMAL(10, 2)) AS freight_value
FROM silver.vw_order_items_clean
WHERE TRY_CAST(order_item_id AS INT) IS NOT NULL
AND TRY_CAST(shipping_limit_date AS DATE) IS NOT NULL
AND TRY_CAST(price AS DECIMAL(10, 2)) IS NOT NULL
AND TRY_CAST(freight_value AS DECIMAL(10, 2)) IS NOT NULL;
--------------- order_items ---------------

--------------- order_payments ---------------
DROP VIEW IF EXISTS silver.vw_order_payments_final;

CREATE VIEW silver.vw_order_payments_final
AS
SELECT DISTINCT
    order_id,
    CAST(payment_sequential AS INT) AS payment_sequential,
    payment_type,
    CAST(payment_installments AS INT) AS payment_installments,
    CAST(payment_value AS DECIMAL(10, 2)) AS payment_value
FROM silver.vw_order_payments_clean
WHERE TRY_CAST(payment_sequential AS INT) IS NOT NULL
AND TRY_CAST(payment_installments AS INT) IS NOT NULL
AND TRY_CAST(payment_value AS DECIMAL(10, 2)) IS NOT NULL;
--------------- order_payments ---------------

--------------- order_reviews ---------------
DROP VIEW IF EXISTS silver.vw_order_reviews_final;

CREATE VIEW silver.vw_order_reviews_final
AS
SELECT DISTINCT
    review_id,
    order_id,
    CAST(review_score AS INT) AS review_score,
    review_comment_title,
    review_comment_message,
    CAST(review_creation_date AS DATE) AS review_creation_date,
    CAST(review_answer_timestamp AS DATE) AS review_answer_timestamp
FROM silver.vw_order_reviews_clean
WHERE TRY_CAST(review_score AS INT) IS NOT NULL
AND TRY_CAST(review_creation_date AS DATE) IS NOT NULL
AND TRY_CAST(review_answer_timestamp AS DATE) IS NOT NULL;
--------------- order_reviews ---------------

--------------- customers ---------------
DROP VIEW IF EXISTS silver.vw_customers_final;

CREATE VIEW silver.vw_customers_final
AS
SELECT DISTINCT
	customer_id,
	customer_zip_code_prefix,
	customer_city,
	customer_state
FROM silver.vw_customers_clean;
--------------- customers ---------------

--------------- products ---------------
DROP VIEW IF EXISTS silver.vw_products_final;

CREATE VIEW silver.vw_products_final
AS
SELECT DISTINCT
    product_id,
    product_category_name,
    CAST(product_name_lenght AS INT) product_name_lenght,
    CAST(product_description_lenght AS INT) product_description_lenght,
    CAST(product_photos_qty AS INT) product_photos_qty,
    CAST(product_weight_g AS INT) product_weight_g,
    CAST(product_length_cm AS INT) product_length_cm,
    CAST(product_height_cm AS INT) product_height_cm,
    CAST(product_width_cm AS INT) product_width_cm
FROM silver.vw_products_clean
WHERE TRY_CAST(product_name_lenght AS INT) IS NOT NULL
AND TRY_CAST(product_description_lenght AS INT) IS NOT NULL
AND TRY_CAST(product_photos_qty AS INT) IS NOT NULL
AND TRY_CAST(product_weight_g AS INT) IS NOT NULL
AND TRY_CAST(product_length_cm AS INT) IS NOT NULL
AND TRY_CAST(product_height_cm AS INT) IS NOT NULL
AND TRY_CAST(product_width_cm AS INT) IS NOT NULL;
--------------- products ---------------

--------------- sellers ---------------
DROP VIEW IF EXISTS silver.vw_sellers_final;

CREATE VIEW silver.vw_sellers_final
AS
SELECT DISTINCT
	seller_id,
	seller_zip_code_prefix,
	seller_city,
	seller_state
FROM silver.vw_sellers_clean;
--------------- sellers ---------------
