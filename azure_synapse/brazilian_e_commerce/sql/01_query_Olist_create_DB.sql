CREATE DATABASE Olist_DB
    COLLATE Latin1_General_100_BIN2_UTF8
GO;

USE Olist_DB
GO;

CREATE SCHEMA bronze
GO;

CREATE SCHEMA silver
GO;

CREATE EXTERNAL DATA SOURCE bronze_data WITH (
    LOCATION = 'https://datalake20251021.dfs.core.windows.net/olist/bronze/'
);
GO;

CREATE EXTERNAL DATA SOURCE silver_data WITH (
    LOCATION = 'https://datalake20251021.dfs.core.windows.net/olist/silver/'
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

CREATE EXTERNAL FILE FORMAT ParquetFormat
    WITH (
            FORMAT_TYPE = PARQUET,
            DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
        );
GO;