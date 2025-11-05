
CREATE PROCEDURE OLIST_DB.usp_clean_staging_tables
AS
BEGIN
    TRUNCATE TABLE OLIST_DB.Stage_orders;
    TRUNCATE TABLE OLIST_DB.Stage_order_items;
    TRUNCATE TABLE OLIST_DB.Stage_order_reviews;
    TRUNCATE TABLE OLIST_DB.Stage_order_payments;
    TRUNCATE TABLE OLIST_DB.Stage_customers;
    TRUNCATE TABLE OLIST_DB.Stage_products;
    TRUNCATE TABLE OLIST_DB.Stage_sellers;
END;

CREATE PROCEDURE OLIST_DB.usp_load_Stage_orders
AS
BEGIN
    COPY INTO OLIST_DB.Stage_orders (
        order_id, 
        customer_id, 
        order_status, 
        order_purchase_timestamp, 
        order_approved_at, 
        order_delivered_carrier_date,
        order_delivered_customer_date, 
        order_estimated_delivery_date
    )
    FROM 'https://datalake20251021.dfs.core.windows.net/olist/silver/orders/*.parquet'
    WITH
    (
        FILE_TYPE = 'PARQUET',
        MAXERRORS = 0,
        IDENTITY_INSERT = 'OFF'
    );
END;

CREATE PROCEDURE OLIST_DB.usp_load_Stage_order_items
AS
BEGIN
    COPY INTO OLIST_DB.Stage_order_items (
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date,
        price,
        freight_value
    )
    FROM 'https://datalake20251021.dfs.core.windows.net/olist/silver/order_items/*.parquet'
    WITH
    (
        FILE_TYPE = 'PARQUET',
        MAXERRORS = 0,
        IDENTITY_INSERT = 'OFF'
    );
END;

CREATE PROCEDURE OLIST_DB.usp_load_Stage_order_payments
AS
BEGIN
    COPY INTO OLIST_DB.Stage_order_payments (
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value
    )
    FROM 'https://datalake20251021.dfs.core.windows.net/olist/silver/order_payments/*.parquet'
    WITH
    (
        FILE_TYPE = 'PARQUET',
        MAXERRORS = 0,
        IDENTITY_INSERT = 'OFF'
    );
END;

CREATE PROCEDURE OLIST_DB.usp_load_Stage_order_reviews
AS
BEGIN
    COPY INTO OLIST_DB.Stage_order_reviews (
        review_id,
        order_id,
        review_score,
        review_comment_title,
        review_comment_message,
        review_creation_date,
        review_answer_timestamp
    )
    FROM 'https://datalake20251021.dfs.core.windows.net/olist/silver/order_reviews/*.parquet'
    WITH
    (
        FILE_TYPE = 'PARQUET',
        MAXERRORS = 0,
        IDENTITY_INSERT = 'OFF'
    );
END;

CREATE PROCEDURE OLIST_DB.usp_load_Stage_customers
AS
BEGIN
    COPY INTO OLIST_DB.Stage_customers (
        customer_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state
    )
    FROM 'https://datalake20251021.dfs.core.windows.net/olist/silver/customers/*.parquet'
    WITH
    (
        FILE_TYPE = 'PARQUET',
        MAXERRORS = 0,
        IDENTITY_INSERT = 'OFF'
    );
END;

CREATE PROCEDURE OLIST_DB.usp_load_Stage_products
AS
BEGIN
    COPY INTO OLIST_DB.Stage_products (
        product_id,
        product_category_name,
        product_name_lenght,
        product_description_lenght,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm
    )
    FROM 'https://datalake20251021.dfs.core.windows.net/olist/silver/products/*.parquet'
    WITH
    (
        FILE_TYPE = 'PARQUET',
        MAXERRORS = 0,
        IDENTITY_INSERT = 'OFF'
    );
END;

CREATE PROCEDURE OLIST_DB.usp_load_Stage_sellers
AS
BEGIN
    COPY INTO OLIST_DB.Stage_sellers (
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state
    )
    FROM 'https://datalake20251021.dfs.core.windows.net/olist/silver/sellers/*.parquet'
    WITH
    (
        FILE_TYPE = 'PARQUET',
        MAXERRORS = 0,
        IDENTITY_INSERT = 'OFF'
    );
END;

