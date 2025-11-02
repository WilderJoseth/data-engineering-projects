USE Olist_DB
GO;

--------------- Fact_Orders ---------------
CREATE PROCEDURE gold.usp_load_Fact_Orders
AS
BEGIN
    IF (SELECT OBJECT_ID('gold.Fact_Orders', 'U')) IS NOT NULL
        DROP EXTERNAL TABLE gold.Fact_Orders;

    CREATE EXTERNAL TABLE gold.Fact_Orders
        WITH (
            LOCATION = 'Fact_Orders/',
            DATA_SOURCE = gold_data,
            FILE_FORMAT = ParquetFormat
        )
    AS
    SELECT
        d.order_id,
        d.order_item_id,
        o.customer_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        d.product_id,
        d.seller_id,
        d.shipping_limit_date,
        d.price,
        d.freight_value,
        r.review_score,
        r.review_comment_title,
        p.payment_sequential,
        p.payment_type,
        p.payment_installments,
        p.payment_value
    FROM silver.order_items d
    INNER JOIN silver.orders o ON o.order_id = d.order_id
    INNER JOIN silver.order_reviews r ON r.order_id = o.order_id
    INNER JOIN silver.order_payments p ON p.order_id = o.order_id;
END;
--------------- fact_orders ---------------

--------------- Dim_Customers ---------------
CREATE PROCEDURE gold.usp_load_Dim_Customers
AS
BEGIN
    IF (SELECT OBJECT_ID('gold.Dim_Customers', 'U')) IS NOT NULL
        DROP EXTERNAL TABLE gold.Dim_Customers;

    CREATE EXTERNAL TABLE gold.Dim_Customers
        WITH (
            LOCATION = 'Dim_Customers/',
            DATA_SOURCE = gold_data,
            FILE_FORMAT = ParquetFormat
        )
    AS
    SELECT
        customer_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state
    FROM silver.customers;
END;
--------------- Dim_Customers ---------------

--------------- Dim_Products ---------------
CREATE PROCEDURE gold.usp_load_Dim_Products
AS
BEGIN
    IF (SELECT OBJECT_ID('gold.Dim_Products', 'U')) IS NOT NULL
        DROP EXTERNAL TABLE gold.Dim_Products;

    CREATE EXTERNAL TABLE gold.Dim_Products
        WITH (
            LOCATION = 'Dim_Products/',
            DATA_SOURCE = gold_data,
            FILE_FORMAT = ParquetFormat
        )
    AS
    SELECT
        product_id,
        product_category_name,
        product_weight_g,
        product_height_cm,
        product_width_cm
    FROM silver.products;
END;
--------------- Dim_Products ---------------

--------------- Dim_Sellers ---------------
CREATE PROCEDURE gold.usp_load_Dim_Sellers
AS
BEGIN
    IF (SELECT OBJECT_ID('gold.Dim_Sellers', 'U')) IS NOT NULL
        DROP EXTERNAL TABLE gold.Dim_Sellers;

    CREATE EXTERNAL TABLE gold.Dim_Sellers
        WITH (
            LOCATION = 'Dim_Sellers/',
            DATA_SOURCE = gold_data,
            FILE_FORMAT = ParquetFormat
        )
    AS
    SELECT
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state
    FROM silver.sellers;
END;
--------------- Dim_Sellers ---------------
