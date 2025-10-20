Use Olist_DB;
GO;

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
HAVING COUNT(*) > 1;
GO;

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
HAVING COUNT(*) > 1;
GO;

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
HAVING COUNT(*) > 1;
GO;

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
HAVING COUNT(*) > 1;
GO;

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
HAVING COUNT(*) > 1;
GO;

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
HAVING COUNT(*) > 1;
GO;

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
HAVING COUNT(*) > 1;
GO;

