
CREATE PROCEDURE OLIST_DB.usp_clean_production_tables
AS
BEGIN
    TRUNCATE TABLE OLIST_DB.Dim_Customers;
    TRUNCATE TABLE OLIST_DB.Dim_Products;
    TRUNCATE TABLE OLIST_DB.Dim_Sellers;
    TRUNCATE TABLE OLIST_DB.Dim_Date;
    TRUNCATE TABLE OLIST_DB.Fact_Orders;
END;

CREATE PROCEDURE OLIST_DB.usp_load_Dim_Customers
AS
BEGIN
    INSERT INTO OLIST_DB.Dim_Customers (
        customer_id_alternate,
        customer_zip_code_prefix,
        customer_city,
        customer_state
    )
    SELECT
        s.customer_id,
        s.customer_zip_code_prefix,
        s.customer_city,
        s.customer_state
    FROM OLIST_DB.Stage_customers s
    WHERE NOT EXISTS (SELECT 1 FROM OLIST_DB.Dim_Customers d WHERE d.customer_id_alternate = s.customer_id);

    UPDATE d SET
        d.customer_zip_code_prefix = s.customer_zip_code_prefix,
        d.customer_city = s.customer_city,
        d.customer_state = s.customer_state
    FROM OLIST_DB.Dim_Customers d
    INNER JOIN OLIST_DB.Stage_customers s ON s.customer_id = d.customer_id_alternate
    WHERE d.customer_zip_code_prefix <> s.customer_zip_code_prefix OR
    d.customer_city <> s.customer_city OR
    d.customer_state <> s.customer_state;
END;

CREATE PROCEDURE OLIST_DB.usp_load_Dim_Products
AS
BEGIN
    INSERT INTO OLIST_DB.Dim_Products (
        product_id_alternate,
        product_category_name,
        product_weight_g,
        product_height_cm,
        product_width_cm
    )
    SELECT
        s.product_id,
        s.product_category_name,
        s.product_weight_g,
        s.product_height_cm,
        s.product_width_cm
    FROM OLIST_DB.Stage_products s
    WHERE NOT EXISTS (SELECT 1 FROM OLIST_DB.Dim_Products d WHERE d.product_id_alternate = s.product_id);

    UPDATE d SET
        d.product_category_name = s.product_category_name,
        d.product_weight_g = s.product_weight_g,
        d.product_height_cm = s.product_height_cm,
        d.product_width_cm = s.product_width_cm
    FROM OLIST_DB.Dim_Products d
    INNER JOIN OLIST_DB.Stage_products s ON s.product_id = d.product_id_alternate
    WHERE d.product_category_name <> s.product_category_name OR
    d.product_weight_g <> s.product_weight_g OR
    d.product_height_cm <> s.product_height_cm OR
    d.product_width_cm <> s.product_width_cm;
END;

CREATE PROCEDURE OLIST_DB.usp_load_Dim_Sellers
AS
BEGIN
    INSERT INTO OLIST_DB.Dim_Sellers (
        seller_id_alternate,
        seller_zip_code_prefix,
        seller_city,
        seller_state
    )
    SELECT
        s.seller_id,
        s.seller_zip_code_prefix,
        s.seller_city,
        s.seller_state
    FROM OLIST_DB.Stage_sellers s
    WHERE NOT EXISTS (SELECT 1 FROM OLIST_DB.Dim_Sellers d WHERE d.seller_id_alternate = s.seller_id);

    UPDATE d SET
        d.seller_zip_code_prefix = s.seller_zip_code_prefix,
        d.seller_city = s.seller_city,
        d.seller_state = s.seller_state
    FROM OLIST_DB.Dim_Sellers d
    INNER JOIN OLIST_DB.Stage_sellers s ON s.seller_id = d.seller_id_alternate
    WHERE d.seller_zip_code_prefix <> s.seller_zip_code_prefix OR
    d.seller_city <> s.seller_city OR
    d.seller_state <> s.seller_state;
END;

CREATE PROCEDURE OLIST_DB.usp_load_Dim_Date
AS
BEGIN
    DECLARE @start_date DATE = '2025-01-01'
    DECLARE @end_date DATE = '2025-01-10'
    
    --SELECT @start_date = MIN(order_purchase_timestamp), @end_date = MAX(order_purchase_timestamp) FROM OLIST_DB.Stage_orders;

    WHILE @start_date <= @end_date
    BEGIN
        INSERT INTO OLIST_DB.Dim_Date
        (
            date_id,
            date_id_alternate,
            day_of_month,
            day_of_week,
            day_name,
            month_of_year,
            month_name,
            calendar_quarter,
            calendar_year
        )
        SELECT
            CONVERT(INT, CONVERT(NVARCHAR(8), @start_date, 112)) AS date_id,
            @start_date AS date_id_alternate,
            DAY(@start_date) AS day_of_month,
            DATEPART(DW, @start_date) AS day_of_week,
            DATENAME(DW, @start_date) AS day_name,
            MONTH(@start_date) AS month_of_year,
            DATENAME(MM, @start_date) AS month_name,
            DATEPART(QQ, @start_date) AS calendar_quarter,
            YEAR(@start_date) AS calendar_year;

        SET @start_date = DATEADD(DD, 1, @start_date);
    END
END;

CREATE PROCEDURE OLIST_DB.usp_load_Fact_Orders
AS
BEGIN
    INSERT INTO OLIST_DB.Fact_Orders (
        order_id_alternate,
        customer_id_surrogate,
        product_id_surrogate,
        seller_id_surrogate,
        order_item_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        shipping_limit_date,
        price,
        freight_value,
        review_score,
        review_comment_title,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value
    )
    SELECT
        d.order_id,
        c.customer_id_surrogate,
        pr.product_id_surrogate,
        s.seller_id_surrogate,
        d.order_item_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        d.shipping_limit_date,
        --(SELECT date_id FROM OLIST_DB.Dim_Date WHERE date_id_alternate = o.order_purchase_timestamp) AS order_purchase_timestamp_id,
        --(SELECT date_id FROM OLIST_DB.Dim_Date WHERE date_id_alternate = o.order_approved_at) AS order_approved_at_id,
        --(SELECT date_id FROM OLIST_DB.Dim_Date WHERE date_id_alternate = o.order_delivered_carrier_date) AS order_delivered_carrier_date_id,
        --(SELECT date_id FROM OLIST_DB.Dim_Date WHERE date_id_alternate = o.order_delivered_customer_date) AS order_delivered_customer_date_id,
        --(SELECT date_id FROM OLIST_DB.Dim_Date WHERE date_id_alternate = o.order_estimated_delivery_date) AS order_estimated_delivery_date_id,
        --(SELECT date_id FROM OLIST_DB.Dim_Date WHERE date_id_alternate = d.shipping_limit_date) AS shipping_limit_date_id,
        d.price,
        d.freight_value,
        r.review_score,
        r.review_comment_title,
        p.payment_sequential,
        p.payment_type,
        p.payment_installments,
        p.payment_value
    FROM OLIST_DB.Stage_order_items d
    INNER JOIN OLIST_DB.Stage_orders o ON o.order_id = d.order_id
    INNER JOIN OLIST_DB.Stage_order_reviews r ON r.order_id = o.order_id
    INNER JOIN OLIST_DB.Stage_order_payments p ON p.order_id = o.order_id
    INNER JOIN OLIST_DB.Dim_Customers c ON c.customer_id_alternate = o.customer_id
    INNER JOIN OLIST_DB.Dim_Products pr ON pr.product_id_alternate = d.product_id
    INNER JOIN OLIST_DB.Dim_Sellers s ON s.seller_id_alternate = d.seller_id;
END;

SELECT TOP 5 * FROM OLIST_DB.Fact_Orders;

SELECT TOP 5 * FROM OLIST_DB.Dim_Customers;

SELECT TOP 5 * FROM OLIST_DB.Dim_Products;

SELECT TOP 5 * FROM OLIST_DB.Dim_Sellers;



