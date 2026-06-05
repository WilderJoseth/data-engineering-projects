/*
    Script name
        15_create_control_transactional_reconciliation_objects.sql

    Purpose
        Creates control-schema table-valued functions used to calculate
        transactional data reconciliation results by ETL load process.

    Design rules
        - Each transactional load process has its own function.
        - ETL calls the process-specific function inside the process container.
        - Source reconciliation reads from staging tables.
        - Target reconciliation reads rows created by the current execution
          step because transactional loads use delete-and-reload logic.
        - Functions only return results; ETL publishes them to DataOps_Control.
*/

USE [Sales_Operational];
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_SalesOrder_reconciliation_results] (
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
        SELECT 'ROW_COUNT', 'TABLE=SalesOrderHeader', @normalized_side, @execution_step_id, NULL, COUNT_BIG(*)
        FROM [staging].[SalesOrderHeader]
        UNION ALL
        SELECT 'ROW_COUNT', 'TABLE=SalesOrderDetail', @normalized_side, @execution_step_id, NULL, COUNT_BIG(*)
        FROM [staging].[SalesOrderDetail];

    IF @normalized_side = 'TARGET'
        INSERT INTO @results
        SELECT 'ROW_COUNT', 'TABLE=SalesOrderHeader', @normalized_side, @execution_step_id, NULL, COUNT_BIG(*)
        FROM [prod].[SalesOrderHeader]
        WHERE [created_execution_step_id] = @execution_step_id
        UNION ALL
        SELECT 'ROW_COUNT', 'TABLE=SalesOrderDetail', @normalized_side, @execution_step_id, NULL, COUNT_BIG(*)
        FROM [prod].[SalesOrderDetail]
        WHERE [created_execution_step_id] = @execution_step_id;

    RETURN;
END;
GO
