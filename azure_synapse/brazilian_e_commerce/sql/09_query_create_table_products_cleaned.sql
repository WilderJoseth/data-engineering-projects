Use Sales;
GO;

CREATE VIEW dbo.vw_products AS
SELECT
    product_id,
    product_category_name,
    TRY_CAST(product_name_lenght AS INT) AS product_name_lenght,
    TRY_CAST(product_description_lenght AS INT) AS product_description_lenght,
    TRY_CAST(product_photos_qty AS INT) AS product_photos_qty,
    TRY_CAST(product_weight_g AS INT) AS product_weight_g,
    TRY_CAST(product_length_cm AS INT) AS product_length_cm,
    TRY_CAST(product_height_cm AS INT) AS product_height_cm,
    TRY_CAST(product_width_cm AS INT) AS product_width_cm
FROM dbo.products_raw
GO;

CREATE EXTERNAL TABLE dbo.products
    WITH (
        LOCATION = 'products/',
        DATA_SOURCE = sales_cleaned_data,
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
FROM dbo.vw_products
WHERE product_name_lenght IS NOT NULL
AND product_description_lenght IS NOT NULL
AND product_photos_qty IS NOT NULL
AND product_weight_g IS NOT NULL
AND product_length_cm IS NOT NULL
AND product_height_cm IS NOT NULL
AND product_width_cm IS NOT NULL
GO;

SELECT * FROM dbo.products;
GO;
