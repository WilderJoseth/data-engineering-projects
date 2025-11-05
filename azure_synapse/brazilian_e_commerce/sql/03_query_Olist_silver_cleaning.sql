USE Olist_DB
GO;

--------------- orders ---------------
SELECT
	SUM(IIF(order_id IS NULL, 1, 0)) AS order_id_missing,
	SUM(IIF(customer_id IS NULL, 1, 0)) AS customer_id_missing,
	SUM(IIF(order_status IS NULL, 1, 0)) AS order_status_missing
FROM bronze.orders;

SELECT
	order_Status,
	SUM(IIF(order_purchase_timestamp IS NULL, 1, 0)) AS order_purchase_timestamp_missing,
	SUM(IIF(order_approved_at IS NULL, 1, 0)) AS order_approved_at_missing,
	SUM(IIF(order_delivered_carrier_date IS NULL, 1, 0)) AS order_delivered_carrier_date_missing,
	SUM(IIF(order_delivered_customer_date IS NULL, 1, 0)) AS order_delivered_customer_date_missing,
	SUM(IIF(order_estimated_delivery_date IS NULL, 1, 0)) AS order_estimated_delivery_date_missing
FROM bronze.orders
GROUP BY order_Status;

DROP VIEW IF EXISTS silver.vw_orders_trim;

CREATE VIEW silver.vw_orders_trim
AS
SELECT
	order_id,
	ISNULL(customer_id, 'UNKNOWN') AS customer_id,
	UPPER(TRIM(ISNULL(order_status, 'UNKNOWN'))) AS order_status,
	ISNULL(order_purchase_timestamp, '1900-01-01 00:00:00.000') AS order_purchase_timestamp,
	order_approved_at,
	order_delivered_carrier_date,
	order_delivered_customer_date,
	order_estimated_delivery_date
FROM bronze.orders
WHERE order_id IS NOT NULL;

DROP VIEW IF EXISTS silver.vw_orders_clean;

CREATE VIEW silver.vw_orders_clean
AS
SELECT
	order_id,
	customer_id,
	order_status,
	order_purchase_timestamp,
	ISNULL(order_approved_at, '1900-01-01 00:00:00.000') AS order_approved_at,
	ISNULL(order_delivered_carrier_date, '1900-01-01 00:00:00.000') AS order_delivered_carrier_date,
	ISNULL(order_delivered_customer_date, '1900-01-01 00:00:00.000') AS order_delivered_customer_date,
	order_estimated_delivery_date
FROM silver.vw_orders_trim
WHERE order_status IN ('CREATED', 'PROCESSING', 'APPROVED', 'INVOICED', 'UNAVAILABLE', 'CANCELED')
UNION ALL
SELECT
	order_id,
	customer_id,
	order_status,
	order_purchase_timestamp,
	ISNULL(order_approved_at, order_approved_at) AS order_approved_at,
	ISNULL(order_delivered_carrier_date, order_delivered_carrier_date) AS order_delivered_carrier_date,
	ISNULL(order_delivered_customer_date, '1900-01-01 00:00:00.000') AS order_delivered_customer_date,
	order_estimated_delivery_date
FROM silver.vw_orders_trim
WHERE order_status = 'SHIPPED'
UNION ALL
SELECT
	order_id,
	customer_id,
	order_status,
	order_purchase_timestamp,
	ISNULL(order_approved_at, order_purchase_timestamp) AS order_approved_at,
	ISNULL(order_delivered_carrier_date, order_purchase_timestamp) AS order_delivered_carrier_date,
	ISNULL(order_delivered_customer_date, order_purchase_timestamp) AS order_delivered_customer_date,
	order_estimated_delivery_date
FROM silver.vw_orders_trim
WHERE order_status = 'DELIVERED'
UNION ALL
SELECT
	order_id,
	customer_id,
	order_status,
	order_purchase_timestamp,
	ISNULL(order_approved_at, order_purchase_timestamp) AS order_approved_at,
	ISNULL(order_delivered_carrier_date, order_purchase_timestamp) AS order_delivered_carrier_date,
	ISNULL(order_delivered_customer_date, order_purchase_timestamp) AS order_delivered_customer_date,
	order_estimated_delivery_date
FROM silver.vw_orders_trim
WHERE order_status = 'UNKNOWN';
--------------- orders ---------------

--------------- order_items ---------------
SELECT
	SUM(IIF(order_id IS NULL, 1, 0)) AS order_id_missing,
	SUM(IIF(order_item_id IS NULL, 1, 0)) AS order_item_id_missing,
	SUM(IIF(product_id IS NULL, 1, 0)) AS product_id_missing,
	SUM(IIF(seller_id IS NULL, 1, 0)) AS seller_id_missing,
	SUM(IIF(shipping_limit_date IS NULL, 1, 0)) AS shipping_limit_date_missing,
	SUM(IIF(price IS NULL, 1, 0)) AS price_date_missing,
	SUM(IIF(freight_value IS NULL, 1, 0)) AS freight_value_date_missing
FROM bronze.order_items;

DROP VIEW IF EXISTS silver.vw_order_items_clean;

CREATE VIEW silver.vw_order_items_clean
AS
SELECT
	order_id,
	order_item_id,
	ISNULL(product_id, 'UNKNOWN') AS product_id,
	ISNULL(seller_id, 'UNKNOWN') AS seller_id,
	ISNULL(shipping_limit_date, '1900-01-01 00:00:00.000') AS shipping_limit_date,
	ISNULL(price, '0') AS price,
	ISNULL(freight_value, '0') AS freight_value
FROM bronze.order_items
WHERE order_id IS NOT NULL
AND order_item_id IS NOT NULL;
--------------- order_items ---------------

--------------- order_payments ---------------
SELECT
	SUM(IIF(order_id IS NULL, 1, 0)) AS order_id_missing,
	SUM(IIF(payment_sequential IS NULL, 1, 0)) AS payment_sequential_missing,
	SUM(IIF(payment_type IS NULL, 1, 0)) AS payment_type_missing,
	SUM(IIF(payment_installments IS NULL, 1, 0)) AS payment_installments_missing,
	SUM(IIF(payment_value IS NULL, 1, 0)) AS payment_value_missing
FROM bronze.order_payments;

DROP VIEW IF EXISTS silver.vw_order_payments_clean;

CREATE VIEW silver.vw_order_payments_clean
AS
SELECT
	order_id,
	ISNULL(payment_sequential, '0') AS payment_sequential,
	UPPER(TRIM(payment_type)) AS payment_type,
	ISNULL(payment_installments, '0') AS payment_installments,
	ISNULL(payment_value, '0') AS payment_value
FROM bronze.order_payments
WHERE order_id IS NOT NULL;
--------------- order_payments ---------------

--------------- order_reviews ---------------
SELECT
	SUM(IIF(review_id IS NULL, 1, 0)) AS review_id_missing,
	SUM(IIF(order_id IS NULL, 1, 0)) AS order_id_missing,
	SUM(IIF(review_score IS NULL, 1, 0)) AS review_score_missing,
	SUM(IIF(review_comment_title IS NULL, 1, 0)) AS review_comment_title_missing,
	SUM(IIF(review_comment_message IS NULL, 1, 0)) AS review_comment_message_missing,
	SUM(IIF(review_creation_date IS NULL, 1, 0)) AS review_creation_date_missing,
	SUM(IIF(review_answer_timestamp IS NULL, 1, 0)) AS review_answer_timestamp_missing
FROM bronze.order_reviews;

DROP VIEW IF EXISTS silver.vw_order_reviews_clean;

CREATE VIEW silver.vw_order_reviews_clean
AS
SELECT
	review_id,
	order_id,
	ISNULL(review_score, '0') AS review_score,
	UPPER(TRIM(ISNULL(review_comment_title, ''))) AS review_comment_title,
	UPPER(TRIM(ISNULL(review_comment_message, ''))) AS review_comment_message,
	ISNULL(review_creation_date, '1900-01-01 00:00:00.000') AS review_creation_date,
	ISNULL(review_answer_timestamp, '1900-01-01 00:00:00.000') AS review_answer_timestamp
FROM bronze.order_reviews
WHERE review_id IS NOT NULL
AND order_id IS NOT NULL;
--------------- order_reviews ---------------

--------------- customers ---------------
DROP VIEW IF EXISTS silver.vw_customers_clean;

CREATE VIEW silver.vw_customers_clean
AS
SELECT
	customer_id,
	ISNULL(customer_zip_code_prefix, '00000') AS customer_zip_code_prefix,
	UPPER(TRIM(ISNULL(customer_city, ''))) AS customer_city,
	UPPER(TRIM(ISNULL(customer_state, ''))) AS customer_state
FROM bronze.customers
WHERE customer_id IS NOT NULL;
--------------- customers ---------------

--------------- products ---------------
SELECT
	SUM(IIF(product_id IS NULL, 1, 0)) AS product_id_missing,
	SUM(IIF(product_category_name IS NULL, 1, 0)) AS product_category_name_missing,
	SUM(IIF(product_name_lenght IS NULL, 1, 0)) AS product_name_lenght_missing,
	SUM(IIF(product_description_lenght IS NULL, 1, 0)) AS product_description_lenght_missing,
	SUM(IIF(product_photos_qty IS NULL, 1, 0)) AS product_photos_qty_missing,
	SUM(IIF(product_weight_g IS NULL, 1, 0)) AS product_weight_g_missing,
	SUM(IIF(product_length_cm IS NULL, 1, 0)) AS product_length_cm_missing,
	SUM(IIF(product_height_cm IS NULL, 1, 0)) AS product_height_cm_missing,
	SUM(IIF(product_width_cm IS NULL, 1, 0)) AS product_width_cm_missing
FROM bronze.products;

DROP VIEW IF EXISTS silver.vw_products_clean;

CREATE VIEW silver.vw_products_clean
AS
SELECT
	product_id,
	UPPER(TRIM(ISNULL(product_category_name, 'UNKNOWN'))) AS product_category_name,
	ISNULL(product_name_lenght, '0') AS product_name_lenght,
	ISNULL(product_description_lenght, '0') AS product_description_lenght,
	ISNULL(product_photos_qty, '0') AS product_photos_qty,
	ISNULL(product_weight_g, '0') AS product_weight_g,
	ISNULL(product_length_cm, '0') AS product_length_cm,
	ISNULL(product_height_cm, '0') AS product_height_cm,
	ISNULL(product_width_cm, '0') AS product_width_cm
FROM bronze.products
WHERE product_id IS NOT NULL;
--------------- products ---------------

--------------- sellers ---------------
SELECT
	SUM(IIF(seller_id IS NULL, 1, 0)) AS seller_id_missing,
	SUM(IIF(seller_zip_code_prefix IS NULL, 1, 0)) AS seller_zip_code_prefix_missing,
	SUM(IIF(seller_city IS NULL, 1, 0)) AS seller_city_missing,
	SUM(IIF(seller_state IS NULL, 1, 0)) AS seller_state_missing
FROM bronze.sellers;

DROP VIEW IF EXISTS silver.vw_sellers_clean;

CREATE VIEW silver.vw_sellers_clean
AS
SELECT
	seller_id,
	ISNULL(seller_zip_code_prefix, '00000') AS seller_zip_code_prefix,
	UPPER(TRIM(ISNULL(seller_city, ''))) AS seller_city,
	UPPER(TRIM(ISNULL(seller_state, ''))) AS seller_state
FROM bronze.sellers
WHERE seller_id IS NOT NULL;
--------------- sellers ---------------

