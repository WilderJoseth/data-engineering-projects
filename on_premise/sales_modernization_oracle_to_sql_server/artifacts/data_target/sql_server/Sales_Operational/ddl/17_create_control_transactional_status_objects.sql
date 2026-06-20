/*
    Script name
        17_create_control_transactional_status_objects.sql

    Purpose
        Creates control functions that derive transactional process completion status.

    Scope
        Functions return a status code id based on transactional reconciliation and validation results.
*/

USE [Sales_Operational];
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_SalesOrder_load_status_code] (
    @execution_step_id BIGINT
)
RETURNS SMALLINT
AS
BEGIN
    DECLARE @has_reconciliation_mismatch BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM [control].[ufn_get_SalesOrder_reconciliation_results]('SOURCE', @execution_step_id) AS source_result
        INNER JOIN [control].[ufn_get_SalesOrder_reconciliation_results]('TARGET', @execution_step_id) AS target_result
            ON target_result.[metric_name] = source_result.[metric_name]
           AND target_result.[reconciliation_key] = source_result.[reconciliation_key]
        WHERE source_result.[metric_name] = 'ROW_COUNT'
          AND source_result.[metric_value_bigint] <> target_result.[metric_value_bigint]
    )
    BEGIN
        SET @has_reconciliation_mismatch = 1;
    END;

    DECLARE @status_code_id SMALLINT = [control].[ufn_get_status_code_from_reconciliation_results](@execution_step_id, @has_reconciliation_mismatch);

    RETURN @status_code_id;
END;
GO
