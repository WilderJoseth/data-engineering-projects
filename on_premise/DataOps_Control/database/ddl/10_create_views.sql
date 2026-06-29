/*
    Script: 10_create_views.sql
    Database: DataOps_Control

    Purpose:
    - Creates reporting and troubleshooting views for runtime and observability data.
    - These views simplify common monitoring queries by joining runtime,
      metadata, reference, and observability tables.
    - They are intended for review, troubleshooting, demos, and lightweight reporting.
*/

USE [DataOps_Control];
GO

/*============================================================================
    View: runtime.vw_execution_run_summary

    Purpose:
    - Provides one row per project execution run.
    - Shows the project name, run status, start/end dates, and duration.
    - Useful for quickly reviewing whether a project run completed successfully,
      failed, or requires observation.

    Main use cases:
    - Review recent project executions.
    - Check final run status.
    - Compare run durations.
============================================================================*/

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

/*============================================================================
    View: runtime.vw_execution_step_summary

    Purpose:
    - Provides one row per process execution step.
    - Shows the project, process, parent process, step status, start/end dates,
      and duration.
    - Useful for identifying which specific process failed, was observed,
      or took longer than expected.

    Main use cases:
    - Review process-level execution history.
    - Troubleshoot failed or observed steps.
    - Understand execution flow using parent-child process relationships.
============================================================================*/

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

/*============================================================================
    View: observability.vw_execution_observability_summary

    Purpose:
    - Provides one row per execution step with aggregated observability counts.
    - Counts technical errors, validation results, and reconciliation results
      linked to each step.
    - Useful for quickly identifying which execution steps produced evidence
      that may require review.

    Main use cases:
    - Check whether a step generated errors.
    - Check whether validation or reconciliation records were published.
    - Support operational review after a project execution run.
============================================================================*/

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

CREATE VIEW [observability].[vw_monitoring_results]
AS
SELECT
    mr.[id] AS [monitoring_result_id],
    mr.[execution_step_id],
    er.[id] AS [execution_run_id],
    p.[name] AS [project_name],
    pp.[name] AS [project_process_name],
    mmc.[code] AS [metric_code],
    mmc.[description] AS [metric_description],
    mmc.[metric_source],
    mmc.[metric_unit],
    CASE
        WHEN mmc.[metric_value_type] = 'BIGINT'
            THEN CONVERT(VARCHAR(100), mr.[actual_value_bigint])
        WHEN mmc.[metric_value_type] = 'DECIMAL'
            THEN CONVERT(VARCHAR(100), mr.[actual_value_decimal])
        ELSE COALESCE(
            CONVERT(VARCHAR(100), mr.[actual_value_bigint]),
            CONVERT(VARCHAR(100), mr.[actual_value_decimal])
        )
    END AS [actual_value],
    CASE
        WHEN mmc.[metric_value_type] = 'BIGINT'
            THEN CONCAT(
                COALESCE(CONVERT(VARCHAR(100), ppm.[min_value_bigint]), 'NULL'),
                ' - ',
                COALESCE(CONVERT(VARCHAR(100), ppm.[max_value_bigint]), 'NULL')
            )
        WHEN mmc.[metric_value_type] = 'DECIMAL'
            THEN CONCAT(
                COALESCE(CONVERT(VARCHAR(100), ppm.[min_value_decimal]), 'NULL'),
                ' - ',
                COALESCE(CONVERT(VARCHAR(100), ppm.[max_value_decimal]), 'NULL')
            )
        ELSE NULL
    END AS [expected_range],
    ppm.[severity],
    mr.[is_within_expected_range],
    CASE
        WHEN mr.[is_within_expected_range] = 1 THEN 'OK'
        ELSE 'Observed'
    END AS [monitoring_status],
    mr.[created_at]
FROM [observability].[monitoring_results] AS mr
INNER JOIN [runtime].[execution_steps] AS es
    ON es.[id] = mr.[execution_step_id]
INNER JOIN [runtime].[execution_runs] AS er
    ON er.[id] = es.[execution_run_id]
INNER JOIN [metadata].[projects] AS p
    ON p.[id] = er.[project_id]
INNER JOIN [metadata].[project_processes] AS pp
    ON pp.[id] = es.[project_process_id]
INNER JOIN [metadata].[project_process_monitoring_metrics] AS ppm
    ON ppm.[id] = mr.[project_process_monitoring_metric_id]
INNER JOIN [reference].[monitoring_metric_codes] AS mmc
    ON mmc.[id] = ppm.[monitoring_metric_code_id];
GO

