CREATE DATABASE Sales_Bronze
    COLLATE Latin1_General_100_BIN2_UTF8;
GO;

Use Sales_Bronze;
GO;

CREATE EXTERNAL DATA SOURCE sales_bronze_data WITH (
    LOCATION = 'https://datalake8v2eibh.dfs.core.windows.net/files/sales/'
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
