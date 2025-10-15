Use Sales_Bronze;
GO;

CREATE EXTERNAL TABLE dbo.products
(
    product_id VARCHAR(100),
    product_category_name VARCHAR(100),
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
    DATA_SOURCE = sales_bronze_data,
    LOCATION = 'csv/*products*.csv',
    FILE_FORMAT = CsvFormat
);
GO