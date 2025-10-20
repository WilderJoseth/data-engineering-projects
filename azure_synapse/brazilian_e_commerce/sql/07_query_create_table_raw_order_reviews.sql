Use Olist_DB;
GO;

CREATE EXTERNAL TABLE raw.order_reviews
(
    review_id NVARCHAR(50),
    order_id NVARCHAR(50),
    review_score NVARCHAR(5),
    review_comment_title NVARCHAR(50),
    review_comment_message NVARCHAR(250),
    review_creation_date NVARCHAR(50),
    review_answer_timestamp NVARCHAR(50)
)
WITH
(
    DATA_SOURCE = olist_raw_data,
    LOCATION = '*order_reviews*.csv',
    FILE_FORMAT = CsvFormat
);
GO;

