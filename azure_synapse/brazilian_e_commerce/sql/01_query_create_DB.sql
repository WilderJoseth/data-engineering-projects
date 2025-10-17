CREATE DATABASE Sales
    COLLATE Latin1_General_100_BIN2_UTF8;
GO;

Use Sales;
GO;

CREATE EXTERNAL DATA SOURCE sales_raw_data WITH (
    LOCATION = 'https://datalakeuldp7bo.dfs.core.windows.net/files/sales/csv/'
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

CREATE EXTERNAL DATA SOURCE sales_cleaned_data WITH (
    LOCATION = 'https://datalakeuldp7bo.dfs.core.windows.net/files/sales/parquet/'
);
GO;

CREATE EXTERNAL FILE FORMAT ParquetFormat
    WITH (
            FORMAT_TYPE = PARQUET,
            DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
        );
GO;

