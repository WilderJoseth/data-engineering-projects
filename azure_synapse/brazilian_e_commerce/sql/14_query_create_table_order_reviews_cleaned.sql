Use Sales;
GO;

CREATE VIEW dbo.vw_order_reviews AS
SELECT
    review_id,
    order_id,
    TRY_CAST(review_score AS INT) AS review_score,
    review_comment_title,
    review_comment_message,
    TRY_CAST(review_creation_date AS DATETIME) AS review_creation_date,
    TRY_CAST(review_answer_ti AS DATETIME) AS review_answer_ti
FROM dbo.order_reviews_raw
GO;

CREATE EXTERNAL TABLE dbo.order_reviews
    WITH (
        LOCATION = 'order_reviews/',
        DATA_SOURCE = sales_cleaned_data,
        FILE_FORMAT = ParquetFormat
    )
AS
SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_ti
FROM dbo.vw_order_reviews
WHERE review_score IS NOT NULL
AND review_creation_date IS NOT NULL
AND review_answer_ti IS NOT NULL
GO;

SELECT * FROM dbo.order_reviews;
GO;