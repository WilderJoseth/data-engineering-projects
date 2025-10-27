USE CATALOG training_catalog;
USE SCHEMA market_segmentation_insurance_db;

CREATE OR REPLACE TABLE silver_data AS
SELECT * FROM data_cleaned_view;