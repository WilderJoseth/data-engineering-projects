CREATE DATABASE AdventureWorksLT2022_DB
    COLLATE Latin1_General_100_BIN2_UTF8;
GO;

Use AdventureWorksLT2022_DB;
GO;

CREATE SCHEMA bronze;
GO;

CREATE SCHEMA silver;
GO;

CREATE SCHEMA gold;
GO;

CREATE EXTERNAL DATA SOURCE bronze_data WITH (
    LOCATION = 'https://datalake20251021.dfs.core.windows.net/adventureworkslt2022/bronze/'
);
GO;

CREATE EXTERNAL DATA SOURCE silver_data WITH (
    LOCATION = 'https://datalake20251021.dfs.core.windows.net/adventureworkslt2022/silver/'
);
GO;

CREATE EXTERNAL DATA SOURCE gold_data WITH (
    LOCATION = 'https://datalake20251021.dfs.core.windows.net/adventureworkslt2022/gold/'
);
GO;


CREATE EXTERNAL FILE FORMAT ParquetFormat
    WITH (
            FORMAT_TYPE = PARQUET,
            DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
        );
GO;




