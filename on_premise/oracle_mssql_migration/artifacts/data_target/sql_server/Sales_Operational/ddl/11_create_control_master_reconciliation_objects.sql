/*
    Script name
        11_create_control_master_reconciliation_objects.sql

    Purpose
        Creates control-schema table-valued functions used to calculate master
        data reconciliation results by ETL load process.

    Design rules
        - Each master load process has its own function.
        - ETL calls the process-specific function inside the process container.
        - Source reconciliation reads from staging tables.
        - Target reconciliation reads rows created or updated by the current
          execution step.
        - Functions only return results; ETL publishes them to DataOps_Control.
*/

USE [Sales_Operational];
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_CreditCard_reconciliation_results] (
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
        SELECT 'ROW_COUNT', 'TABLE=CreditCard', @normalized_side, @execution_step_id, NULL, COUNT_BIG(*)
        FROM [staging].[CreditCard];

    IF @normalized_side = 'TARGET'
        INSERT INTO @results
        SELECT 'ROW_COUNT', 'TABLE=CreditCard', @normalized_side, @execution_step_id, NULL, SUM([row_count])
        FROM (
            SELECT COUNT_BIG(*) AS [row_count]
            FROM [prod].[CreditCard]
            WHERE [created_execution_step_id] = @execution_step_id
            UNION ALL
            SELECT COUNT_BIG(*) AS [row_count]
            FROM [prod].[CreditCard]
            WHERE [last_updated_execution_step_id] = @execution_step_id
        ) AS target_counts;

    RETURN;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_Address_reconciliation_results] (
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
        SELECT 'ROW_COUNT', 'TABLE=Address', @normalized_side, @execution_step_id, NULL, COUNT_BIG(*)
        FROM [staging].[Address];

    IF @normalized_side = 'TARGET'
        INSERT INTO @results
        SELECT 'ROW_COUNT', 'TABLE=Address', @normalized_side, @execution_step_id, NULL, SUM([row_count])
        FROM (
            SELECT COUNT_BIG(*) AS [row_count]
            FROM [prod].[Address]
            WHERE [created_execution_step_id] = @execution_step_id
            UNION ALL
            SELECT COUNT_BIG(*) AS [row_count]
            FROM [prod].[Address]
            WHERE [last_updated_execution_step_id] = @execution_step_id
        ) AS target_counts;

    RETURN;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_Product_reconciliation_results] (
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
        SELECT 'ROW_COUNT', 'TABLE=Product', @normalized_side, @execution_step_id, NULL, COUNT_BIG(*)
        FROM [staging].[Product];

    IF @normalized_side = 'TARGET'
        INSERT INTO @results
        SELECT 'ROW_COUNT', 'TABLE=Product', @normalized_side, @execution_step_id, NULL, SUM([row_count])
        FROM (
            SELECT COUNT_BIG(*) AS [row_count]
            FROM [prod].[Product]
            WHERE [created_execution_step_id] = @execution_step_id
            UNION ALL
            SELECT COUNT_BIG(*) AS [row_count]
            FROM [prod].[Product]
            WHERE [last_updated_execution_step_id] = @execution_step_id
        ) AS target_counts;

    RETURN;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_SalesPerson_reconciliation_results] (
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
        SELECT 'ROW_COUNT', 'TABLE=SalesPerson', @normalized_side, @execution_step_id, NULL, COUNT_BIG(*)
        FROM [staging].[SalesPerson];

    IF @normalized_side = 'TARGET'
        INSERT INTO @results
        SELECT 'ROW_COUNT', 'TABLE=SalesPerson', @normalized_side, @execution_step_id, NULL, SUM([row_count])
        FROM (
            SELECT COUNT_BIG(*) AS [row_count]
            FROM [prod].[SalesPerson]
            WHERE [created_execution_step_id] = @execution_step_id
            UNION ALL
            SELECT COUNT_BIG(*) AS [row_count]
            FROM [prod].[SalesPerson]
            WHERE [last_updated_execution_step_id] = @execution_step_id
        ) AS target_counts;

    RETURN;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_Customer_reconciliation_results] (
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
        SELECT 'ROW_COUNT', 'TABLE=Customer', @normalized_side, @execution_step_id, NULL, COUNT_BIG(*)
        FROM [staging].[Customer];

    IF @normalized_side = 'TARGET'
        INSERT INTO @results
        SELECT 'ROW_COUNT', 'TABLE=Customer', @normalized_side, @execution_step_id, NULL, SUM([row_count])
        FROM (
            SELECT COUNT_BIG(*) AS [row_count]
            FROM [prod].[Customer]
            WHERE [created_execution_step_id] = @execution_step_id
            UNION ALL
            SELECT COUNT_BIG(*) AS [row_count]
            FROM [prod].[Customer]
            WHERE [last_updated_execution_step_id] = @execution_step_id
        ) AS target_counts;

    RETURN;
END;
GO

