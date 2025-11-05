
CREATE SCHEMA OLIST_DB;

--------------- Stage_orders ---------------
IF (SELECT OBJECT_ID('OLIST_DB.Stage_orders', 'U')) IS NOT NULL
    DROP TABLE OLIST_DB.Stage_orders;

CREATE TABLE OLIST_DB.Stage_orders
(
    order_id VARCHAR(50) NOT NULL,
    customer_id VARCHAR(50) NOT NULL,
    order_status NVARCHAR(20) NOT NULL,
    order_purchase_timestamp DATE NOT NULL,
    order_approved_at DATE NOT NULL,
    order_delivered_carrier_date DATE NOT NULL,
    order_delivered_customer_date DATE NOT NULL,
    order_estimated_delivery_date DATE NOT NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);
--------------- Stage_orders ---------------

--------------- Stage_order_items ---------------
IF (SELECT OBJECT_ID('OLIST_DB.Stage_order_items', 'U')) IS NOT NULL
    DROP TABLE OLIST_DB.Stage_order_items;

CREATE TABLE OLIST_DB.Stage_order_items
(
    order_id VARCHAR(50) NOT NULL,
    order_item_id INT NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    seller_id VARCHAR(50) NOT NULL,
    shipping_limit_date DATE NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    freight_value DECIMAL(10, 2) NOT NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);
--------------- Stage_order_items ---------------

--------------- Stage_order_payments ---------------
IF (SELECT OBJECT_ID('OLIST_DB.Stage_order_payments', 'U')) IS NOT NULL
    DROP TABLE OLIST_DB.Stage_order_payments;

CREATE TABLE OLIST_DB.Stage_order_payments
(
    order_id VARCHAR(50) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type NVARCHAR(50) NOT NULL,
    payment_installments INT NOT NULL,
    payment_value DECIMAL(10, 2) NOT NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);
--------------- Stage_order_payments ---------------

--------------- Stage_order_reviews ---------------
IF (SELECT OBJECT_ID('OLIST_DB.Stage_order_reviews', 'U')) IS NOT NULL
    DROP TABLE OLIST_DB.Stage_order_reviews;

CREATE TABLE OLIST_DB.Stage_order_reviews
(
    review_id VARCHAR(50) NOT NULL,
    order_id VARCHAR(50) NOT NULL,
    review_score INT NOT NULL,
    review_comment_title NVARCHAR(50) NOT NULL,
    review_comment_message NVARCHAR(250) NOT NULL,
    review_creation_date DATE NOT NULL,
    review_answer_timestamp DATE NOT NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);
--------------- Stage_order_reviews ---------------

--------------- Stage_customers ---------------
IF (SELECT OBJECT_ID('OLIST_DB.Stage_customers', 'U')) IS NOT NULL
    DROP TABLE OLIST_DB.Stage_customers;

CREATE TABLE OLIST_DB.Stage_customers
(
    customer_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix VARCHAR(10) NOT NULL,
    customer_city NVARCHAR(50) NOT NULL,
    customer_state VARCHAR(80) NOT NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);
--------------- Stage_customers ---------------

--------------- Stage_products ---------------
IF (SELECT OBJECT_ID('OLIST_DB.Stage_products', 'U')) IS NOT NULL
    DROP TABLE OLIST_DB.Stage_products;

CREATE TABLE OLIST_DB.Stage_products
(
    product_id VARCHAR(50) NOT NULL,
    product_category_name NVARCHAR(50) NOT NULL,
    product_name_lenght INT NOT NULL,
    product_description_lenght INT NOT NULL,
    product_photos_qty INT NOT NULL,
    product_weight_g INT NOT NULL,
    product_length_cm INT NOT NULL,
    product_height_cm INT NOT NULL,
    product_width_cm INT NOT NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);
--------------- Stage_products ---------------

--------------- Stage_sellers ---------------
IF (SELECT OBJECT_ID('OLIST_DB.Stage_sellers', 'U')) IS NOT NULL
    DROP TABLE OLIST_DB.Stage_sellers;

CREATE TABLE OLIST_DB.Stage_sellers
(
    seller_id VARCHAR(50) NOT NULL,
    seller_zip_code_prefix VARCHAR(10) NOT NULL,
    seller_city NVARCHAR(50) NOT NULL,
    seller_state VARCHAR(80) NOT NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);
--------------- Stage_sellers ---------------

