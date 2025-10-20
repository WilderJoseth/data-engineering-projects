Use Olist_DB;
GO;

CREATE EXTERNAL TABLE raw.products
(
    product_id NVARCHAR(50),
    product_category_name NVARCHAR(50),
    product_name_lenght NVARCHAR(10),
    product_description_lenght NVARCHAR(10),
    product_photos_qty NVARCHAR(10),
    product_weight_g NVARCHAR(10),
    product_length_cm NVARCHAR(10),
    product_height_cm NVARCHAR(10),
    product_width_cm NVARCHAR(10)
)
WITH
(
    DATA_SOURCE = olist_raw_data,
    LOCATION = '*products*.csv',
    FILE_FORMAT = CsvFormat
);
GO;
