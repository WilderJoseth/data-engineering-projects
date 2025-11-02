USE Olist_DB
GO;

----------------- products -----------------
CREATE PROCEDURE bronze.usp_load_products
AS
BEGIN
    IF (SELECT OBJECT_ID('bronze.products', 'U')) IS NOT NULL
        DROP EXTERNAL TABLE bronze.products;

    CREATE EXTERNAL TABLE bronze.products
    (
        product_id VARCHAR(50),
        product_category_name NVARCHAR(50),
        product_name_lenght VARCHAR(10),
        product_description_lenght VARCHAR(10),
        product_photos_qty VARCHAR(10),
        product_weight_g VARCHAR(10),
        product_length_cm VARCHAR(10),
        product_height_cm VARCHAR(10),
        product_width_cm VARCHAR(10)
    )
    WITH
    (
        DATA_SOURCE = bronze_data,
        LOCATION = '*products*.csv',
        FILE_FORMAT = CsvFormat
    );
END;
----------------- products -----------------

----------------- sellers -----------------
CREATE PROCEDURE bronze.usp_load_sellers
AS
BEGIN
    IF (SELECT OBJECT_ID('bronze.sellers', 'U')) IS NOT NULL
        DROP EXTERNAL TABLE bronze.sellers;

    CREATE EXTERNAL TABLE bronze.sellers
    (
        seller_id VARCHAR(50),
        seller_zip_code_prefix VARCHAR(10),
        seller_city NVARCHAR(50),
        seller_state VARCHAR(10)
    )
    WITH
    (
        DATA_SOURCE = bronze_data,
        LOCATION = '*sellers*.csv',
        FILE_FORMAT = CsvFormat
    );
END;
----------------- sellers -----------------

----------------- customers -----------------
CREATE PROCEDURE bronze.usp_load_customers
AS
BEGIN
    IF (SELECT OBJECT_ID('bronze.customers', 'U')) IS NOT NULL
        DROP EXTERNAL TABLE bronze.customers;

    CREATE EXTERNAL TABLE bronze.customers
    (
        customer_id VARCHAR(50),
        customer_unique_id VARCHAR(50),
        customer_zip_code_prefix VARCHAR(10),
        customer_city NVARCHAR(50),
        customer_state VARCHAR(10)
    )
    WITH
    (
        DATA_SOURCE = bronze_data,
        LOCATION = '*customers*.csv',
        FILE_FORMAT = CsvFormat
    );
END;
----------------- customers -----------------

----------------- order_items -----------------
CREATE PROCEDURE bronze.usp_load_order_items
AS
BEGIN
    IF (SELECT OBJECT_ID('bronze.order_items', 'U')) IS NOT NULL
        DROP EXTERNAL TABLE bronze.order_items;

    CREATE EXTERNAL TABLE bronze.order_items
    (
        order_id VARCHAR(50),
        order_item_id VARCHAR(10),
        product_id VARCHAR(50),
        seller_id VARCHAR(50),
        shipping_limit_date VARCHAR(20),
        price VARCHAR(10),
        freight_value VARCHAR(10)
    )
    WITH
    (
        DATA_SOURCE = bronze_data,
        LOCATION = '*order_items*.csv',
        FILE_FORMAT = CsvFormat
    );
END;
----------------- order_items -----------------

----------------- order_payments -----------------
CREATE PROCEDURE bronze.usp_load_order_payments
AS
BEGIN
    IF (SELECT OBJECT_ID('bronze.order_payments', 'U')) IS NOT NULL
        DROP EXTERNAL TABLE bronze.order_payments;

    CREATE EXTERNAL TABLE bronze.order_payments
    (
        order_id VARCHAR(50),
        payment_sequential VARCHAR(10),
        payment_type NVARCHAR(50),
        payment_installments VARCHAR(10),
        payment_value VARCHAR(10)
    )
    WITH
    (
        DATA_SOURCE = bronze_data,
        LOCATION = '*order_payments*.csv',
        FILE_FORMAT = CsvFormat
    );
END;
----------------- order_payments -----------------

----------------- order_reviews -----------------
CREATE PROCEDURE bronze.usp_load_order_reviews
AS
BEGIN
    IF (SELECT OBJECT_ID('bronze.order_reviews', 'U')) IS NOT NULL
        DROP EXTERNAL TABLE bronze.order_reviews;

    CREATE EXTERNAL TABLE bronze.order_reviews
    (
        review_id VARCHAR(50),
        order_id VARCHAR(50),
        review_score VARCHAR(10),
        review_comment_title NVARCHAR(50),
        review_comment_message NVARCHAR(250),
        review_creation_date VARCHAR(20),
        review_answer_timestamp VARCHAR(20)
    )
    WITH
    (
        DATA_SOURCE = bronze_data,
        LOCATION = '*order_reviews*.csv',
        FILE_FORMAT = CsvFormat
    );
END;
----------------- order_reviews -----------------

----------------- orders -----------------
CREATE PROCEDURE bronze.usp_load_orders
AS
BEGIN
    IF (SELECT OBJECT_ID('bronze.orders', 'U')) IS NOT NULL
        DROP EXTERNAL TABLE bronze.orders;

    CREATE EXTERNAL TABLE bronze.orders
    (
        order_id VARCHAR(50),
        customer_id VARCHAR(50),
        order_status NVARCHAR(20),
        order_purchase_timestamp VARCHAR(20),
        order_approved_at VARCHAR(20),
        order_delivered_carrier_date VARCHAR(20),
        order_delivered_customer_date VARCHAR(20),
        order_estimated_delivery_date VARCHAR(20)
    )
    WITH
    (
        DATA_SOURCE = bronze_data,
        LOCATION = '*orders*.csv',
        FILE_FORMAT = CsvFormat
    );
END;
----------------- orders -----------------

