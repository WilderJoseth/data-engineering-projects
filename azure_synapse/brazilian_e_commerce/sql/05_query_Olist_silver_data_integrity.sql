USE Olist_DB
GO;

--------------- orders ---------------
SELECT
    order_id,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM silver.vw_orders_clean
WHERE TRY_CAST(order_purchase_timestamp AS DATETIME) IS NULL
OR TRY_CAST(order_approved_at AS DATETIME) IS NULL
OR TRY_CAST(order_delivered_carrier_date AS DATETIME) IS NULL
OR TRY_CAST(order_delivered_customer_date AS DATETIME) IS NULL
OR TRY_CAST(order_estimated_delivery_date AS DATETIME) IS NULL;
--------------- orders ---------------

--------------- order_items ---------------
SELECT
    order_id,
    order_item_id,
    shipping_limit_date,
    price,
    freight_value
FROM silver.vw_order_items_clean
WHERE TRY_CAST(order_item_id AS INT) IS NULL
OR TRY_CAST(shipping_limit_date AS DATETIME) IS NULL
OR TRY_CAST(price AS DECIMAL(10, 2)) IS NULL
OR TRY_CAST(freight_value AS DECIMAL(10, 2)) IS NULL;
--------------- order_items ---------------

--------------- order_payments ---------------
SELECT
    order_id,
    payment_sequential,
    payment_installments,
    payment_value
FROM silver.vw_order_payments_clean
WHERE TRY_CAST(payment_sequential AS INT) IS NULL
OR TRY_CAST(payment_installments AS INT) IS NULL
OR TRY_CAST(payment_value AS DECIMAL(10, 2)) IS NULL;
--------------- order_payments ---------------

--------------- order_reviews ---------------
SELECT
    review_id,
    review_score,
    review_creation_date,
    review_answer_timestamp
FROM silver.vw_order_reviews_clean
WHERE TRY_CAST(review_score AS INT) IS NULL
OR TRY_CAST(review_creation_date AS DATETIME) IS NULL
OR TRY_CAST(review_answer_timestamp AS DATETIME) IS NULL;

--------------- order_reviews ---------------

--------------- products ---------------
SELECT
    product_id,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM silver.vw_products_clean
WHERE TRY_CAST(product_name_lenght AS INT) IS NULL
OR TRY_CAST(product_description_lenght AS INT) IS NULL
OR TRY_CAST(product_photos_qty AS INT) IS NULL
OR TRY_CAST(product_weight_g AS INT) IS NULL
OR TRY_CAST(product_length_cm AS INT) IS NULL
OR TRY_CAST(product_height_cm AS INT) IS NULL
OR TRY_CAST(product_width_cm AS INT) IS NULL;
--------------- products ---------------