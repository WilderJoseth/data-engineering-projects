Use Olist_DB;
GO;

---------------------------- Start Identify Missing Values ----------------------------
--------------- raw.orders ---------------
SELECT
	SUM(IIF(order_id IS NULL, 1, 0)) AS order_id_missing,
	SUM(IIF(customer_id IS NULL, 1, 0)) AS customer_id_missing,
	SUM(IIF(order_status IS NULL, 1, 0)) AS order_status_missing
FROM raw.orders;
GO;

SELECT
	order_status,
	SUM(IIF(order_purchase_timestamp IS NULL, 1, 0)) AS order_purchase_timestamp_missing,
	SUM(IIF(order_approved_at IS NULL, 1, 0)) AS order_approved_at_missing,
	SUM(IIF(order_delivered_carrier_date IS NULL, 1, 0)) AS order_delivered_carrier_date_missing,
	SUM(IIF(order_delivered_customer_date IS NULL, 1, 0)) AS order_delivered_customer_date_missing,
	SUM(IIF(order_estimated_delivery_date IS NULL, 1, 0)) AS order_estimated_delivery_date_missing
FROM raw.orders
GROUP BY order_status;
GO;
--------------- raw.orders ---------------

--------------- raw.order_items ---------------
SELECT
	SUM(IIF(order_id IS NULL, 1, 0)) AS order_id_missing,
	SUM(IIF(order_item_id IS NULL, 1, 0)) AS order_item_id_missing,
	SUM(IIF(product_id IS NULL, 1, 0)) AS product_id_missing,
	SUM(IIF(seller_id IS NULL, 1, 0)) AS seller_id_missing,
	SUM(IIF(shipping_limit_date IS NULL, 1, 0)) AS shipping_limit_date_missing,
	SUM(IIF(price IS NULL, 1, 0)) AS price_date_missing,
	SUM(IIF(freight_value IS NULL, 1, 0)) AS freight_value_date_missing
FROM raw.order_items;
GO;
--------------- raw.order_items ---------------

--------------- raw.order_payments ---------------
SELECT
	SUM(IIF(order_id IS NULL, 1, 0)) AS order_id_missing,
	SUM(IIF(payment_sequential IS NULL, 1, 0)) AS payment_sequential_missing,
	SUM(IIF(payment_type IS NULL, 1, 0)) AS payment_type_missing,
	SUM(IIF(payment_installments IS NULL, 1, 0)) AS payment_installments_missing,
	SUM(IIF(payment_value IS NULL, 1, 0)) AS payment_value_missing
FROM raw.order_payments;
GO;
--------------- raw.order_payments ---------------

--------------- raw.order_reviews ---------------
SELECT
	SUM(IIF(review_id IS NULL, 1, 0)) AS review_id_missing,
	SUM(IIF(order_id IS NULL, 1, 0)) AS order_id_missing,
	SUM(IIF(review_score IS NULL, 1, 0)) AS review_score_missing,
	SUM(IIF(review_comment_title IS NULL, 1, 0)) AS review_comment_title_missing,
	SUM(IIF(review_comment_message IS NULL, 1, 0)) AS review_comment_message_missing,
	SUM(IIF(review_creation_date IS NULL, 1, 0)) AS review_creation_date_missing,
	SUM(IIF(review_answer_timestamp IS NULL, 1, 0)) AS review_answer_timestamp_missing
FROM raw.order_reviews;
GO;
--------------- raw.order_reviews ---------------

--------------- raw.products ---------------
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
FROM raw.products;
GO;
--------------- raw.products ---------------

--------------- raw.sellers ---------------
SELECT
	SUM(IIF(seller_id IS NULL, 1, 0)) AS seller_id_missing,
	SUM(IIF(seller_zip_code_prefix IS NULL, 1, 0)) AS seller_zip_code_prefix_missing,
	SUM(IIF(seller_city IS NULL, 1, 0)) AS seller_city_missing,
	SUM(IIF(seller_state IS NULL, 1, 0)) AS seller_state_missing
FROM raw.sellers;
GO;
--------------- raw.sellers ---------------
---------------------------- End Identify Missing Values ----------------------------

---------------------------- Start View Missing Values ----------------------------
--------------- raw.orders ---------------
-- View for trimming and making capital letter string columns
CREATE VIEW stage.vw_orders_trim
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
FROM raw.orders;
GO;

-- View for filling missing values
CREATE VIEW stage.vw_orders_no_missing_values
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
FROM stage.vw_orders_trim
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
FROM stage.vw_orders_trim
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
FROM stage.vw_orders_trim
WHERE order_status = 'DELIVERED';
GO;
--------------- raw.orders ---------------

--------------- raw.order_payments ---------------
-- View for trimming and making capital letter string columns
CREATE VIEW stage.vw_order_payments_no_missing_values
AS
SELECT
	order_id,
	payment_sequential,
	UPPER(TRIM(payment_type)) AS payment_type,
	payment_installments,
	payment_value
FROM raw.order_payments;
GO;
--------------- raw.order_payments ---------------

--------------- raw.order_reviews ---------------
-- View for trimming and making capital letter string columns
-- View for filling missing values
CREATE VIEW stage.vw_order_reviews_no_missing_values
AS
SELECT
	review_id,
	order_id,
	review_score,
	UPPER(TRIM(ISNULL(review_comment_title, ''))) AS review_comment_title,
	UPPER(TRIM(ISNULL(review_comment_message, ''))) AS review_comment_message,
	review_creation_date,
	review_answer_timestamp
FROM raw.order_reviews;
GO;
--------------- raw.order_reviews ---------------

--------------- raw.customers ---------------
-- View for trimming and making capital letter string columns
CREATE VIEW stage.vw_customers_no_missing_values
AS
SELECT
	customer_id,
	customer_unique_id,
	customer_zip_code_prefix,
	UPPER(TRIM(customer_city)) AS customer_city,
	UPPER(TRIM(customer_state)) AS customer_state
FROM raw.customers;
GO;
--------------- raw.customers ---------------

--------------- raw.products ---------------
-- View for trimming and making capital letter string columns
-- View for filling missing values
-- Create 'UNKNOWN' category
CREATE VIEW stage.vw_products_no_missing_values
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
FROM raw.products;
GO;
--------------- raw.products ---------------

--------------- raw.sellers ---------------
-- View for trimming and making capital letter string columns
CREATE VIEW stage.vw_sellers_no_missing_values
AS
SELECT
	seller_id,
	seller_zip_code_prefix,
	UPPER(TRIM(seller_city)) AS seller_city,
	UPPER(TRIM(seller_state)) AS seller_state
FROM raw.sellers;
GO;
--------------- raw.sellers ---------------
---------------------------- End View Missing Values ----------------------------


