USE Olist_DB
GO

-- 1900-01-01 00:00:00.000
SELECT CONVERT(DATETIME, '1900-01-01')

SELECT MAX(LEN(seller_zip_code_prefix)), MAX(LEN(seller_state)) FROM bronze.sellers

SELECT * FROM bronze.sellers

---------------------------- Start Identify Missing Values ----------------------------
SELECT
	SUM(IIF(order_id IS NULL, 1, 0)) AS order_id_missing,
	SUM(IIF(customer_id IS NULL, 1, 0)) AS customer_id_missing,
	SUM(IIF(order_status IS NULL, 1, 0)) AS order_status_missing
FROM bronze.orders

SELECT
	order_Status,
	SUM(IIF(order_purchase_timestamp IS NULL, 1, 0)) AS order_purchase_timestamp_missing,
	SUM(IIF(order_approved_at IS NULL, 1, 0)) AS order_approved_at_missing,
	SUM(IIF(order_delivered_carrier_date IS NULL, 1, 0)) AS order_delivered_carrier_date_missing,
	SUM(IIF(order_delivered_customer_date IS NULL, 1, 0)) AS order_delivered_customer_date_missing,
	SUM(IIF(order_estimated_delivery_date IS NULL, 1, 0)) AS order_estimated_delivery_date_missing
FROM bronze.orders
GROUP BY order_Status

CREATE VIEW silver.vw_orders_trim
AS
SELECT
	order_id,
	customer_id,
	UPPER(TRIM(order_status)) AS order_status,
	order_purchase_timestamp,
	order_approved_at,
	order_delivered_carrier_date,
	order_delivered_customer_date,
	order_estimated_delivery_date
FROM bronze.orders

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
WHERE order_Status IN ('CREATED', 'PROCESSING', 'APPROVED', 'INVOICED', 'UNAVAILABLE', 'CANCELED')
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
WHERE order_Status = 'SHIPPED'
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
WHERE order_Status = 'DELIVERED'


SELECT
	SUM(IIF(order_id IS NULL, 1, 0)) AS order_id_missing,
	SUM(IIF(order_item_id IS NULL, 1, 0)) AS order_item_id_missing,
	SUM(IIF(product_id IS NULL, 1, 0)) AS product_id_missing,
	SUM(IIF(seller_id IS NULL, 1, 0)) AS seller_id_missing,
	SUM(IIF(shipping_limit_date IS NULL, 1, 0)) AS shipping_limit_date_missing,
	SUM(IIF(price IS NULL, 1, 0)) AS price_date_missing,
	SUM(IIF(freight_value IS NULL, 1, 0)) AS freight_value_date_missing
FROM bronze.order_items

SELECT
	SUM(IIF(order_id IS NULL, 1, 0)) AS order_id_missing,
	SUM(IIF(payment_sequential IS NULL, 1, 0)) AS payment_sequential_missing,
	SUM(IIF(payment_type IS NULL, 1, 0)) AS payment_type_missing,
	SUM(IIF(payment_installments IS NULL, 1, 0)) AS payment_installments_missing,
	SUM(IIF(payment_value IS NULL, 1, 0)) AS payment_value_missing
FROM bronze.order_payments

CREATE VIEW silver.vw_order_payments_no_missing_values
AS
SELECT
	order_id,
	payment_sequential,
	UPPER(TRIM(payment_type)) AS payment_type,
	payment_installments,
	payment_value
FROM bronze.order_payments


SELECT
	SUM(IIF(review_id IS NULL, 1, 0)) AS review_id_missing,
	SUM(IIF(order_id IS NULL, 1, 0)) AS order_id_missing,
	SUM(IIF(review_score IS NULL, 1, 0)) AS review_score_missing,
	SUM(IIF(review_comment_title IS NULL, 1, 0)) AS review_comment_title_missing,
	SUM(IIF(review_comment_message IS NULL, 1, 0)) AS review_comment_message_missing,
	SUM(IIF(review_creation_date IS NULL, 1, 0)) AS review_creation_date_missing,
	SUM(IIF(review_answer_timestamp IS NULL, 1, 0)) AS review_answer_timestamp_missing
FROM bronze.order_reviews

CREATE VIEW silver.vw_order_reviews_no_missing_values
AS
SELECT
	review_id,
	order_id,
	review_score,
	UPPER(TRIM(ISNULL(review_comment_title, ''))) AS review_comment_title,
	UPPER(TRIM(ISNULL(review_comment_message, ''))) AS review_comment_message,
	review_creation_date,
	review_answer_timestamp
FROM bronze.order_reviews

CREATE VIEW silver.vw_customers_no_missing_values
AS
SELECT
	customer_id,
	customer_unique_id,
	customer_zip_code_prefix,
	UPPER(TRIM(customer_city)) AS customer_city,
	UPPER(TRIM(customer_state)) AS customer_state
FROM bronze.customers

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
FROM bronze.products

CREATE VIEW silver.vw_products_no_missing_values
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

SELECT
	SUM(IIF(seller_id IS NULL, 1, 0)) AS seller_id_missing,
	SUM(IIF(seller_zip_code_prefix IS NULL, 1, 0)) AS seller_zip_code_prefix_missing,
	SUM(IIF(seller_city IS NULL, 1, 0)) AS seller_city_missing,
	SUM(IIF(seller_state IS NULL, 1, 0)) AS seller_state_missing
FROM bronze.sellers

CREATE VIEW silver.vw_sellers_no_missing_values
AS
SELECT
	seller_id,
	seller_zip_code_prefix,
	UPPER(TRIM(seller_city)) AS seller_city,
	UPPER(TRIM(seller_state)) AS seller_state
FROM bronze.sellers
---------------------------- End Identify Missing Values ----------------------------

---------------------------- Start Duplicated Values ----------------------------
SELECT
	COUNT(*) AS count_duplicated,
	order_id,
	customer_id,
	order_status,
	order_purchase_timestamp,
	order_approved_at,
	order_delivered_carrier_date,
	order_delivered_customer_date,
	order_estimated_delivery_date
FROM stage.vw_orders_no_missing_values
GROUP BY
	order_id,
	customer_id,
	order_status,
	order_purchase_timestamp,
	order_approved_at,
	order_delivered_carrier_date,
	order_delivered_customer_date,
	order_estimated_delivery_date
HAVING COUNT(*) > 1

SELECT
	COUNT(*) AS count_duplicated,
	order_id,
	order_item_id,
	product_id,
	seller_id,
	shipping_limit_date,
	price,
	freight_value
FROM raw.order_items
GROUP BY
	order_id,
	order_item_id,
	product_id,
	seller_id,
	shipping_limit_date,
	price,
	freight_value
HAVING COUNT(*) > 1

SELECT
	COUNT(*) AS count_duplicated,
	order_id,
	payment_sequential,
	payment_type,
	payment_installments,
	payment_value
FROM raw.order_payments
GROUP BY
	order_id,
	payment_sequential,
	payment_type,
	payment_installments,
	payment_value
HAVING COUNT(*) > 1

SELECT
	COUNT(*) AS count_duplicated,
	review_id,
	order_id,
	review_score,
	review_comment_title,
	review_comment_message,
	review_creation_date,
	review_answer_timestamp
FROM stage.vw_order_reviews_no_missing_values
GROUP BY
	review_id,
	order_id,
	review_score,
	review_comment_title,
	review_comment_message,
	review_creation_date,
	review_answer_timestamp
HAVING COUNT(*) > 1

SELECT
	COUNT(*) AS count_duplicated,
	customer_id,
	customer_unique_id,
	customer_zip_code_prefix,
	customer_city,
	customer_state
FROM raw.customers
GROUP BY
	customer_id,
	customer_unique_id,
	customer_zip_code_prefix,
	customer_city,
	customer_state
HAVING COUNT(*) > 1

SELECT
	COUNT(*) AS count_duplicated,
	product_id,
	product_category_name,
	product_name_lenght,
	product_description_lenght,
	product_photos_qty,
	product_weight_g,
	product_length_cm,
	product_height_cm,
	product_width_cm
FROM stage.vw_products_no_missing_values
GROUP BY
	product_id,
	product_category_name,
	product_name_lenght,
	product_description_lenght,
	product_photos_qty,
	product_weight_g,
	product_length_cm,
	product_height_cm,
	product_width_cm
HAVING COUNT(*) > 1

SELECT
	COUNT(*) AS count_duplicated,
	seller_id,
	seller_zip_code_prefix,
	seller_city,
	seller_state
FROM raw.sellers
GROUP BY
	seller_id,
	seller_zip_code_prefix,
	seller_city,
	seller_state
HAVING COUNT(*) > 1
---------------------------- End Duplicated Values ----------------------------

---------------------------- Start Validate Data Integrity ----------------------------
SELECT * 
FROM stage.vw_orders_no_missing_values
WHERE TRY_CAST(order_purchase_timestamp AS DATETIME) IS NULL
OR TRY_CAST(order_approved_at AS DATETIME) IS NULL
OR TRY_CAST(order_delivered_carrier_date AS DATETIME) IS NULL
OR TRY_CAST(order_delivered_customer_date AS DATETIME) IS NULL
OR TRY_CAST(order_estimated_delivery_date AS DATETIME) IS NULL

SELECT * 
FROM raw.order_items
WHERE TRY_CAST(order_item_id AS INT) IS NULL
OR TRY_CAST(shipping_limit_date AS DATETIME) IS NULL
OR TRY_CAST(price AS DECIMAL(10, 2)) IS NULL
OR TRY_CAST(freight_value AS DECIMAL(10, 2)) IS NULL

SELECT *
FROM stage.vw_order_payments_no_missing_values
WHERE TRY_CAST(payment_sequential AS INT) IS NULL
OR TRY_CAST(payment_installments AS INT) IS NULL
OR TRY_CAST(payment_value AS DECIMAL(10, 2)) IS NULL

SELECT *
FROM stage.vw_order_reviews_no_missing_values
WHERE TRY_CAST(review_score AS INT) IS NULL
OR TRY_CAST(review_creation_date AS DATETIME) IS NULL
OR TRY_CAST(review_answer_timestamp AS DATETIME) IS NULL

SELECT *
FROM stage.vw_customers_no_missing_values

SELECT *
FROM stage.vw_products_no_missing_values
WHERE TRY_CAST(product_name_lenght AS INT) IS NULL
OR TRY_CAST(product_description_lenght AS INT) IS NULL
OR TRY_CAST(product_photos_qty AS INT) IS NULL
OR TRY_CAST(product_weight_g AS INT) IS NULL
OR TRY_CAST(product_length_cm AS INT) IS NULL
OR TRY_CAST(product_height_cm AS INT) IS NULL
OR TRY_CAST(product_width_cm AS INT) IS NULL

SELECT *
FROM stage.vw_sellers_no_missing_values
---------------------------- End Validate Data Integrity ----------------------------

---------------------------- Start create start schema ----------------------------
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    CAST(o.order_purchase_timestamp AS DATETIME) AS order_purchase_timestamp,
    CAST(o.order_approved_at AS DATETIME) AS order_approved_at,
    CAST(o.order_delivered_carrier_date AS DATETIME) AS order_delivered_carrier_date,
    CAST(o.order_delivered_customer_date AS DATETIME) AS order_delivered_customer_date,
    CAST(o.order_estimated_delivery_date AS DATETIME) AS order_estimated_delivery_date,
    CAST(i.order_item_id AS INT) AS order_item_id,
    i.product_id,
    i.seller_id,
    CAST(i.shipping_limit_date AS DATETIME) AS shipping_limit_date,
    CAST(i.price AS DECIMAL(10, 2)) AS price,
    CAST(i.freight_value AS DECIMAL(10, 2)) AS freight_value,
    CAST(p.payment_sequential AS INT) AS payment_sequential,
    p.payment_type,
    CAST(p.payment_installments AS INT) AS payment_installments,
    CAST(p.payment_value AS DECIMAL(10, 2)) AS payment_value,
    CAST(r.review_score AS INT) AS review_score,
    r.review_comment_message
FROM stage.vw_orders_no_missing_values o
INNER JOIN raw.order_items i ON o.order_id = i.order_id
INNER JOIN stage.vw_order_payments_no_missing_values p ON p.order_id = o.order_id
INNER JOIN stage.vw_order_reviews_no_missing_values r ON r.order_id = o.order_id

SELECT
	customer_id,
	customer_unique_id,
	customer_zip_code_prefix,
	customer_city,
	customer_state
FROM stage.vw_customers_no_missing_values

SELECT
	product_id,
	product_category_name,
	CAST(product_weight_g AS INT) AS product_weight_g,
	CAST(product_height_cm AS INT) AS product_height_cm,
	CAST(product_width_cm AS INT) AS product_width_cm
FROM stage.vw_products_no_missing_values

SELECT *
FROM stage.vw_sellers_no_missing_values

SELECT MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)
FROM stage.vw_orders_no_missing_values

---------------------------- End create start schema ----------------------------

SELECT * FROM master.dbo.spt_values v
WHERE v.type = 'P' AND v.number <= DATEDIFF(DAY, '2020-01-01', '2030-12-31')
