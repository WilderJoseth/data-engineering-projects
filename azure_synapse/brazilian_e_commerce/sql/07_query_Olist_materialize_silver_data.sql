USE Olist_DB
GO;

--------------- orders ---------------
CREATE PROCEDURE silver.usp_load_orders
AS
BEGIN
    IF (SELECT OBJECT_ID('silver.orders', 'U')) IS NOT NULL
        DROP EXTERNAL TABLE silver.orders;

    CREATE EXTERNAL TABLE silver.orders
        WITH (
            LOCATION = 'orders/',
            DATA_SOURCE = silver_data,
            FILE_FORMAT = ParquetFormat
        )
    AS
    SELECT
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date
    FROM silver.vw_orders_final;
END;
--------------- orders ---------------

--------------- order_items ---------------
CREATE PROCEDURE silver.usp_load_order_items
AS
BEGIN
    IF (SELECT OBJECT_ID('silver.order_items', 'U')) IS NOT NULL
        DROP EXTERNAL TABLE silver.order_items;

    CREATE EXTERNAL TABLE silver.order_items
        WITH (
            LOCATION = 'order_items/',
            DATA_SOURCE = silver_data,
            FILE_FORMAT = ParquetFormat
        )
    AS
    SELECT
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date,
        price,
        freight_value
    FROM silver.vw_order_items_final;
END;
--------------- order_items ---------------

--------------- order_payments ---------------
CREATE PROCEDURE silver.usp_load_order_payments
AS
BEGIN
    IF (SELECT OBJECT_ID('silver.order_payments', 'U')) IS NOT NULL
        DROP EXTERNAL TABLE silver.order_payments;

    CREATE EXTERNAL TABLE silver.order_payments
        WITH (
            LOCATION = 'order_payments/',
            DATA_SOURCE = silver_data,
            FILE_FORMAT = ParquetFormat
        )
    AS
    SELECT
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value
    FROM silver.vw_order_payments_final;
END;
--------------- order_payments ---------------

--------------- order_reviews ---------------
CREATE PROCEDURE silver.usp_load_order_reviews
AS
BEGIN
    IF (SELECT OBJECT_ID('silver.order_reviews', 'U')) IS NOT NULL
        DROP EXTERNAL TABLE silver.order_reviews;

    CREATE EXTERNAL TABLE silver.order_reviews
        WITH (
            LOCATION = 'order_reviews/',
            DATA_SOURCE = silver_data,
            FILE_FORMAT = ParquetFormat
        )
    AS
    SELECT
        review_id,
        order_id,
        review_score,
        review_comment_title,
        review_comment_message,
        review_creation_date,
        review_answer_timestamp
    FROM silver.vw_order_reviews_final;
END;
--------------- order_reviews ---------------

--------------- customers ---------------
CREATE PROCEDURE silver.usp_load_customers
AS
BEGIN
    IF (SELECT OBJECT_ID('silver.customers', 'U')) IS NOT NULL
        DROP EXTERNAL TABLE silver.customers;

    CREATE EXTERNAL TABLE silver.customers
        WITH (
            LOCATION = 'customers/',
            DATA_SOURCE = silver_data,
            FILE_FORMAT = ParquetFormat
        )
    AS
    SELECT
        customer_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state
    FROM silver.vw_customers_final;
END;
--------------- customers ---------------

--------------- products ---------------
CREATE PROCEDURE silver.usp_load_products
AS
BEGIN
    IF (SELECT OBJECT_ID('silver.products', 'U')) IS NOT NULL
        DROP EXTERNAL TABLE silver.products;

    CREATE EXTERNAL TABLE silver.products
        WITH (
            LOCATION = 'products/',
            DATA_SOURCE = silver_data,
            FILE_FORMAT = ParquetFormat
        )
    AS
    SELECT
        product_id,
        product_category_name,
        product_name_lenght,
        product_description_lenght,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm
    FROM silver.vw_products_final;
END;
--------------- products ---------------

--------------- sellers ---------------
CREATE PROCEDURE silver.usp_load_sellers
AS
BEGIN
    IF (SELECT OBJECT_ID('silver.sellers', 'U')) IS NOT NULL
        DROP EXTERNAL TABLE silver.sellers;

    CREATE EXTERNAL TABLE silver.sellers
        WITH (
            LOCATION = 'sellers/',
            DATA_SOURCE = silver_data,
            FILE_FORMAT = ParquetFormat
        )
    AS
    SELECT
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state
    FROM silver.vw_sellers_final;
END;
--------------- sellers ---------------

SELECT TOP 5 * FROM silver.order_items;

