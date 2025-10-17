Use Sales;
GO;

CREATE EXTERNAL TABLE dbo.order_reviews_raw
(
    review_id VARCHAR(100),
    order_id VARCHAR(100),
    review_score VARCHAR(5),
    review_comment_title VARCHAR(200),
    review_comment_message VARCHAR(200),
    review_creation_date VARCHAR(50),
    review_answer_ti VARCHAR(50)
)
WITH
(
    DATA_SOURCE = sales_raw_data,
    LOCATION = '*order_reviews*.csv',
    FILE_FORMAT = CsvFormat
);
GO;

SELECT TOP 5 * FROM dbo.order_reviews_raw;
GO;
