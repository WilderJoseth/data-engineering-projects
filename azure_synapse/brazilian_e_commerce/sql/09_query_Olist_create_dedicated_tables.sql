
CREATE SCHEMA OLIST_DB;

--------------- Fact_Orders ---------------
IF (SELECT OBJECT_ID('OLIST_DB.Fact_Orders', 'U')) IS NOT NULL
    DROP TABLE OLIST_DB.Fact_Orders;

CREATE TABLE OLIST_DB.Fact_Orders
(
    order_id_alternate VARCHAR(50) NOT NULL,
    order_item_id INT NOT NULL,
    customer_id VARCHAR(50) NOT NULL,
    order_status NVARCHAR(20) NOT NULL,
    order_purchase_timestamp DATE NOT NULL,
    order_approved_at DATE NOT NULL,
    order_delivered_carrier_date DATE NOT NULL,
    order_delivered_customer_date DATE NOT NULL,
    order_estimated_delivery_date DATE NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    seller_id VARCHAR(50) NOT NULL,
    shipping_limit_date DATE NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    freight_value DECIMAL(10, 2) NOT NULL,
    review_score INT NOT NULL,
    review_comment_title NVARCHAR(50) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type NVARCHAR(50) NOT NULL,
    payment_installments INT NOT NULL,
    payment_value DECIMAL(10, 2) NOT NULL
)
WITH
(
    DISTRIBUTION = HASH(order_id_alternate),
    CLUSTERED COLUMNSTORE INDEX
);
--------------- Fact_Orders ---------------

--------------- Dim_Customers ---------------
IF (SELECT OBJECT_ID('OLIST_DB.Dim_Customers', 'U')) IS NOT NULL
    DROP TABLE OLIST_DB.Dim_Customers;

CREATE TABLE OLIST_DB.Dim_Customers
(
    customer_id_surrogate INT IDENTITY NOT NULL,
    customer_id_alternate VARCHAR(50) NOT NULL,
    customer_zip_code_prefix VARCHAR(10) NOT NULL,
    customer_city NVARCHAR(50) NOT NULL,
    customer_state VARCHAR(80) NOT NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);
--------------- Dim_Customers ---------------

--------------- Dim_Products ---------------
IF (SELECT OBJECT_ID('OLIST_DB.Dim_Products', 'U')) IS NOT NULL
    DROP TABLE OLIST_DB.Dim_Products;

CREATE TABLE OLIST_DB.Dim_Products
(
    product_id_surrogate INT IDENTITY NOT NULL,
    product_id_alternate VARCHAR(50) NOT NULL,
    product_category_name NVARCHAR(50) NOT NULL,
    product_weight_g INT NOT NULL,
    product_height_cm INT NOT NULL,
    product_width_cm INT NOT NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);
--------------- Dim_Products ---------------

--------------- Dim_Sellers ---------------
IF (SELECT OBJECT_ID('OLIST_DB.Dim_Sellers', 'U')) IS NOT NULL
    DROP TABLE OLIST_DB.Dim_Sellers;

CREATE TABLE OLIST_DB.Dim_Sellers
(
    seller_id_surrogate INT IDENTITY NOT NULL,
    seller_id_alternate VARCHAR(50) NOT NULL,
    seller_zip_code_prefix VARCHAR(10) NOT NULL,
    seller_city NVARCHAR(50) NOT NULL,
    seller_state VARCHAR(80) NOT NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);
--------------- Dim_Sellers ---------------

--------------- Dim_Date ---------------
IF (SELECT OBJECT_ID('OLIST_DB.Dim_Date', 'U')) IS NOT NULL
    DROP TABLE OLIST_DB.Dim_Date;

CREATE TABLE OLIST_DB.Dim_Date
( 
    date_id INT NOT NULL,
    date_id_alternate DATE NOT NULL,
    day_of_month INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name NVARCHAR(15) NOT NULL,
    month_of_year INT NOT NULL,
    month_name NVARCHAR(15) NOT NULL,
    calendar_quarter INT NOT NULL,
    calendar_year INT NOT NULL
)
WITH
(
    DISTRIBUTION = REPLICATE,
    CLUSTERED COLUMNSTORE INDEX
);
--------------- Dim_Date ---------------
