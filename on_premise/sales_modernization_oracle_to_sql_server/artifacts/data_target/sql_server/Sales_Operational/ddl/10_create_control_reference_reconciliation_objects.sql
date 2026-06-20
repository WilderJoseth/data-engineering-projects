/*
    Script name
        10_create_control_reference_reconciliation_objects.sql

    Purpose
        Creates control-schema table-valued functions used to calculate
        reference data reconciliation results by ETL load process.

    Design rules
        - Each reference load process has its own function.
        - ETL calls the process-specific function inside the process container.
        - Source reconciliation reads from staging tables.
        - Target reconciliation reads rows created or updated by the current
          execution step.
        - Functions only return results; ETL publishes them to DataOps_Control.
*/

USE [Sales_Operational];
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_AddressType_reconciliation_results] (
    @reconciliation_side VARCHAR(20),
    @execution_step_id INT
)
RETURNS @results TABLE (
    [metric_name] VARCHAR(50) NOT NULL,
    [reconciliation_key] VARCHAR(100) NOT NULL,
    [reconciliation_side] VARCHAR(20) NOT NULL,
    [execution_step_id] INT NOT NULL,
    [metric_value_decimal] DECIMAL(20,4) NULL,
    [metric_value_bigint] BIGINT NULL
)
AS
BEGIN
    DECLARE @normalized_side VARCHAR(20) = UPPER(TRIM(@reconciliation_side));

    IF @normalized_side = 'SOURCE'
        INSERT INTO @results
        SELECT 'ROW_COUNT', 'TABLE=AddressType', @normalized_side, @execution_step_id, NULL, COUNT_BIG(*)
        FROM [staging].[AddressType];

    IF @normalized_side = 'TARGET'
        INSERT INTO @results
        SELECT 'ROW_COUNT', 'TABLE=AddressType', @normalized_side, @execution_step_id, NULL, SUM([row_count])
        FROM (
            SELECT COUNT_BIG(*) AS [row_count]
            FROM [prod].[AddressType]
            WHERE [created_execution_step_id] = @execution_step_id
            UNION ALL
            SELECT COUNT_BIG(*) AS [row_count]
            FROM [prod].[AddressType]
            WHERE [last_updated_execution_step_id] = @execution_step_id
        ) AS target_counts;

    RETURN;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_ProductCategory_reconciliation_results] (
    @reconciliation_side VARCHAR(20),
    @execution_step_id INT
)
RETURNS @results TABLE (
    [metric_name] VARCHAR(50) NOT NULL,
    [reconciliation_key] VARCHAR(100) NOT NULL,
    [reconciliation_side] VARCHAR(20) NOT NULL,
    [execution_step_id] INT NOT NULL,
    [metric_value_decimal] DECIMAL(20,4) NULL,
    [metric_value_bigint] BIGINT NULL
)
AS
BEGIN
    DECLARE @normalized_side VARCHAR(20) = UPPER(TRIM(@reconciliation_side));

    IF @normalized_side = 'SOURCE'
        INSERT INTO @results
        SELECT 'ROW_COUNT', 'TABLE=ProductCategory', @normalized_side, @execution_step_id, NULL, COUNT_BIG(*)
        FROM [staging].[ProductCategory];

    IF @normalized_side = 'TARGET'
        INSERT INTO @results
        SELECT 'ROW_COUNT', 'TABLE=ProductCategory', @normalized_side, @execution_step_id, NULL, SUM([row_count])
        FROM (
            SELECT COUNT_BIG(*) AS [row_count]
            FROM [prod].[ProductCategory]
            WHERE [created_execution_step_id] = @execution_step_id
            UNION ALL
            SELECT COUNT_BIG(*) AS [row_count]
            FROM [prod].[ProductCategory]
            WHERE [last_updated_execution_step_id] = @execution_step_id
        ) AS target_counts;

    RETURN;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_ShipMethod_reconciliation_results] (
    @reconciliation_side VARCHAR(20),
    @execution_step_id INT
)
RETURNS @results TABLE (
    [metric_name] VARCHAR(50) NOT NULL,
    [reconciliation_key] VARCHAR(100) NOT NULL,
    [reconciliation_side] VARCHAR(20) NOT NULL,
    [execution_step_id] INT NOT NULL,
    [metric_value_decimal] DECIMAL(20,4) NULL,
    [metric_value_bigint] BIGINT NULL
)
AS
BEGIN
    DECLARE @normalized_side VARCHAR(20) = UPPER(TRIM(@reconciliation_side));

    IF @normalized_side = 'SOURCE'
        INSERT INTO @results
        SELECT 'ROW_COUNT', 'TABLE=ShipMethod', @normalized_side, @execution_step_id, NULL, COUNT_BIG(*)
        FROM [staging].[ShipMethod];

    IF @normalized_side = 'TARGET'
        INSERT INTO @results
        SELECT 'ROW_COUNT', 'TABLE=ShipMethod', @normalized_side, @execution_step_id, NULL, SUM([row_count])
        FROM (
            SELECT COUNT_BIG(*) AS [row_count]
            FROM [prod].[ShipMethod]
            WHERE [created_execution_step_id] = @execution_step_id
            UNION ALL
            SELECT COUNT_BIG(*) AS [row_count]
            FROM [prod].[ShipMethod]
            WHERE [last_updated_execution_step_id] = @execution_step_id
        ) AS target_counts;

    RETURN;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_SpecialOffer_reconciliation_results] (
    @reconciliation_side VARCHAR(20),
    @execution_step_id INT
)
RETURNS @results TABLE (
    [metric_name] VARCHAR(50) NOT NULL,
    [reconciliation_key] VARCHAR(100) NOT NULL,
    [reconciliation_side] VARCHAR(20) NOT NULL,
    [execution_step_id] INT NOT NULL,
    [metric_value_decimal] DECIMAL(20,4) NULL,
    [metric_value_bigint] BIGINT NULL
)
AS
BEGIN
    DECLARE @normalized_side VARCHAR(20) = UPPER(TRIM(@reconciliation_side));

    IF @normalized_side = 'SOURCE'
        INSERT INTO @results
        SELECT 'ROW_COUNT', 'TABLE=SpecialOffer', @normalized_side, @execution_step_id, NULL, COUNT_BIG(*)
        FROM [staging].[SpecialOffer];

    IF @normalized_side = 'TARGET'
        INSERT INTO @results
        SELECT 'ROW_COUNT', 'TABLE=SpecialOffer', @normalized_side, @execution_step_id, NULL, SUM([row_count])
        FROM (
            SELECT COUNT_BIG(*) AS [row_count]
            FROM [prod].[SpecialOffer]
            WHERE [created_execution_step_id] = @execution_step_id
            UNION ALL
            SELECT COUNT_BIG(*) AS [row_count]
            FROM [prod].[SpecialOffer]
            WHERE [last_updated_execution_step_id] = @execution_step_id
        ) AS target_counts;

    RETURN;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_Geography_reconciliation_results] (
    @reconciliation_side VARCHAR(20),
    @execution_step_id INT
)
RETURNS @results TABLE (
    [metric_name] VARCHAR(50) NOT NULL,
    [reconciliation_key] VARCHAR(100) NOT NULL,
    [reconciliation_side] VARCHAR(20) NOT NULL,
    [execution_step_id] INT NOT NULL,
    [metric_value_decimal] DECIMAL(20,4) NULL,
    [metric_value_bigint] BIGINT NULL
)
AS
BEGIN
    DECLARE @normalized_side VARCHAR(20) = UPPER(TRIM(@reconciliation_side));

    IF @normalized_side = 'SOURCE'
        INSERT INTO @results
        SELECT 'ROW_COUNT', 'TABLE=CountryRegion', @normalized_side, @execution_step_id, NULL, COUNT_BIG(*) FROM [staging].[CountryRegion]
        UNION ALL
        SELECT 'ROW_COUNT', 'TABLE=SalesTerritory', @normalized_side, @execution_step_id, NULL, COUNT_BIG(*) FROM [staging].[SalesTerritory]
        UNION ALL
        SELECT 'ROW_COUNT', 'TABLE=StateProvince', @normalized_side, @execution_step_id, NULL, COUNT_BIG(*) FROM [staging].[StateProvince];

    IF @normalized_side = 'TARGET'
        INSERT INTO @results
        SELECT 'ROW_COUNT', 'TABLE=CountryRegion', @normalized_side, @execution_step_id, NULL, SUM([row_count])
        FROM (
            SELECT COUNT_BIG(*) AS [row_count] FROM [prod].[CountryRegion] WHERE [created_execution_step_id] = @execution_step_id
            UNION ALL
            SELECT COUNT_BIG(*) AS [row_count] FROM [prod].[CountryRegion] WHERE [last_updated_execution_step_id] = @execution_step_id
        ) AS target_counts
        UNION ALL
        SELECT 'ROW_COUNT', 'TABLE=SalesTerritory', @normalized_side, @execution_step_id, NULL, SUM([row_count])
        FROM (
            SELECT COUNT_BIG(*) AS [row_count] FROM [prod].[SalesTerritory] WHERE [created_execution_step_id] = @execution_step_id
            UNION ALL
            SELECT COUNT_BIG(*) AS [row_count] FROM [prod].[SalesTerritory] WHERE [last_updated_execution_step_id] = @execution_step_id
        ) AS target_counts
        UNION ALL
        SELECT 'ROW_COUNT', 'TABLE=StateProvince', @normalized_side, @execution_step_id, NULL, SUM([row_count])
        FROM (
            SELECT COUNT_BIG(*) AS [row_count] FROM [prod].[StateProvince] WHERE [created_execution_step_id] = @execution_step_id
            UNION ALL
            SELECT COUNT_BIG(*) AS [row_count] FROM [prod].[StateProvince] WHERE [last_updated_execution_step_id] = @execution_step_id
        ) AS target_counts;

    RETURN;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_Currency_reconciliation_results] (
    @reconciliation_side VARCHAR(20),
    @execution_step_id INT
)
RETURNS @results TABLE (
    [metric_name] VARCHAR(50) NOT NULL,
    [reconciliation_key] VARCHAR(100) NOT NULL,
    [reconciliation_side] VARCHAR(20) NOT NULL,
    [execution_step_id] INT NOT NULL,
    [metric_value_decimal] DECIMAL(20,4) NULL,
    [metric_value_bigint] BIGINT NULL
)
AS
BEGIN
    DECLARE @normalized_side VARCHAR(20) = UPPER(TRIM(@reconciliation_side));

    IF @normalized_side = 'SOURCE'
        INSERT INTO @results
        SELECT 'ROW_COUNT', 'TABLE=Currency', @normalized_side, @execution_step_id, NULL, COUNT_BIG(*) FROM [staging].[Currency]
        UNION ALL
        SELECT 'ROW_COUNT', 'TABLE=CurrencyRate', @normalized_side, @execution_step_id, NULL, COUNT_BIG(*) FROM [staging].[CurrencyRate];

    IF @normalized_side = 'TARGET'
        INSERT INTO @results
        SELECT 'ROW_COUNT', 'TABLE=Currency', @normalized_side, @execution_step_id, NULL, SUM([row_count])
        FROM (
            SELECT COUNT_BIG(*) AS [row_count] FROM [prod].[Currency] WHERE [created_execution_step_id] = @execution_step_id
            UNION ALL
            SELECT COUNT_BIG(*) AS [row_count] FROM [prod].[Currency] WHERE [last_updated_execution_step_id] = @execution_step_id
        ) AS target_counts
        UNION ALL
        SELECT 'ROW_COUNT', 'TABLE=CurrencyRate', @normalized_side, @execution_step_id, NULL, SUM([row_count])
        FROM (
            SELECT COUNT_BIG(*) AS [row_count] FROM [prod].[CurrencyRate] WHERE [created_execution_step_id] = @execution_step_id
            UNION ALL
            SELECT COUNT_BIG(*) AS [row_count] FROM [prod].[CurrencyRate] WHERE [last_updated_execution_step_id] = @execution_step_id
        ) AS target_counts;

    RETURN;
END;
GO

