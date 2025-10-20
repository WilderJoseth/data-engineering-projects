CREATE DATABASE Olist_DB
    COLLATE Latin1_General_100_BIN2_UTF8;
GO;

Use Olist_DB;
GO;

CREATE SCHEMA raw;
GO;

CREATE SCHEMA stage;
GO;

CREATE SCHEMA dw;
GO;

CREATE EXTERNAL DATA SOURCE olist_raw_data WITH (
    LOCATION = 'https://datalakefyod36h.dfs.core.windows.net/files/Olist/csv/'
);
GO;

CREATE EXTERNAL FILE FORMAT CsvFormat
    WITH (
        FORMAT_TYPE = DELIMITEDTEXT,
        FORMAT_OPTIONS(
            FIELD_TERMINATOR = ',',
            STRING_DELIMITER = '"',
            FIRST_ROW = 2
        )
    );
GO;

CREATE EXTERNAL DATA SOURCE olist_cleaned_data WITH (
    LOCATION = 'https://datalakefyod36h.dfs.core.windows.net/files/Olist/parquet/'
);
GO;

CREATE EXTERNAL FILE FORMAT ParquetFormat
    WITH (
            FORMAT_TYPE = PARQUET,
            DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
        );
GO;

