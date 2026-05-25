/*
    Script: 10_create_views.sql
    Database: DataOps_Control

    Purpose:
    - Creates reporting and troubleshooting views for runtime and observability data.
*/

USE [DataOps_Control];
GO

CREATE OR ALTER VIEW [runtime].[vw_execution_run_summary]
AS
SELECT
    er.[id] AS [execution_run_id],
    er.[project_id],
    p.[name] AS [project_name],
    sc.[code] AS [status_code],
    er.[start_run_date],
    er.[end_run_date],
    DATEDIFF(SECOND, er.[start_run_date], er.[end_run_date]) AS [duration_seconds]
FROM [runtime].[execution_runs] er
INNER JOIN [metadata].[projects] p
    ON p.[id] = er.[project_id]
INNER JOIN [reference].[status_codes] sc
    ON sc.[id] = er.[status_code_id];
GO

CREATE OR ALTER VIEW [runtime].[vw_execution_step_summary]
AS
SELECT
    es.[id] AS [execution_step_id],
    es.[execution_run_id],
    er.[project_id],
    p.[name] AS [project_name],
    es.[project_process_id],
    pp.[name] AS [process_name],
    pp.[parent_process_id],
    parent_pp.[name] AS [parent_process_name],
    sc.[code] AS [status_code],
    es.[start_step_date],
    es.[end_step_date],
    DATEDIFF(SECOND, es.[start_step_date], es.[end_step_date]) AS [duration_seconds]
FROM [runtime].[execution_steps] es
INNER JOIN [runtime].[execution_runs] er
    ON er.[id] = es.[execution_run_id]
INNER JOIN [metadata].[projects] p
    ON p.[id] = er.[project_id]
INNER JOIN [metadata].[project_processes] pp
    ON pp.[id] = es.[project_process_id]
LEFT JOIN [metadata].[project_processes] parent_pp
    ON parent_pp.[id] = pp.[parent_process_id]
INNER JOIN [reference].[status_codes] sc
    ON sc.[id] = es.[status_code_id];
GO

CREATE OR ALTER VIEW [observability].[vw_execution_observability_summary]
AS
SELECT
    es.[id] AS [execution_step_id],
    es.[execution_run_id],
    er.[project_id],
    p.[name] AS [project_name],
    pp.[id] AS [project_process_id],
    pp.[name] AS [process_name],
    sc.[code] AS [step_status],
    COUNT(DISTINCT el.[id]) AS [error_count],
    COUNT(DISTINCT vr.[id]) AS [validation_result_count],
    COUNT(DISTINCT rr.[id]) AS [reconciliation_result_count]
FROM [runtime].[execution_steps] es
INNER JOIN [runtime].[execution_runs] er
    ON er.[id] = es.[execution_run_id]
INNER JOIN [metadata].[projects] p
    ON p.[id] = er.[project_id]
INNER JOIN [metadata].[project_processes] pp
    ON pp.[id] = es.[project_process_id]
INNER JOIN [reference].[status_codes] sc
    ON sc.[id] = es.[status_code_id]
LEFT JOIN [observability].[error_logs] el
    ON el.[execution_step_id] = es.[id]
LEFT JOIN [observability].[validation_results] vr
    ON vr.[execution_step_id] = es.[id]
LEFT JOIN [observability].[reconciliation_results] rr
    ON rr.[execution_step_id] = es.[id]
GROUP BY
    es.[id],
    es.[execution_run_id],
    er.[project_id],
    p.[name],
    pp.[id],
    pp.[name],
    sc.[code];
GO