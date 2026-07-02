/*
    Script: 10_create_views.sql
    Database: DataOps_Control

    Purpose:
    - Creates lightweight review and troubleshooting views for the current
      DataOps_Control v2 metadata, runtime, and observability model.
    - Views should expose useful context without replacing orchestration logic,
      metadata validation logic, or project-specific business rules.

    Design notes:
    - Views are intentionally simple.
    - No recursive process tree logic is included.
    - No dependency resolution logic is included.
    - No executable command generation is included; use
      metadata.ufn_list_project_process_actions for that.
*/

USE [DataOps_Control];
GO

/*============================================================================
  View: metadata.vw_project_process_hierarchy

  Purpose:
  - Shows immediate parent/child process structure.
  - Helps review process hierarchy and execution scope.
  - Does not resolve recursive hierarchy paths.
============================================================================*/

CREATE OR ALTER VIEW [metadata].[vw_project_process_hierarchy]
AS
SELECT
    p.[id] AS [project_id],
    p.[name] AS [project_name],
    pp.[id] AS [project_process_id],
    pp.[name] AS [process_name],
    pp.[parent_process_id],
    parent_pp.[name] AS [parent_process_name],
    pp.[execution_required],
    pp.[is_active],
    CAST
    (
        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM [metadata].[project_processes] child_pp
                WHERE child_pp.[parent_process_id] = pp.[id]
                AND child_pp.[project_id] = pp.[project_id]
                AND child_pp.[is_active] = 1
            )
            THEN 1
            ELSE 0
        END AS BIT
    ) AS [has_child_processes]
FROM [metadata].[project_processes] pp
INNER JOIN [metadata].[projects] p ON p.[id] = pp.[project_id]
LEFT JOIN [metadata].[project_processes] parent_pp ON parent_pp.[id] = pp.[parent_process_id];
GO


/*============================================================================
  View: metadata.vw_project_process_dependency_summary

  Purpose:
  - Shows process dependencies with readable process names.
  - Helps review dependency metadata.
  - Does not detect circular dependencies or resolve execution order.
============================================================================*/

CREATE OR ALTER VIEW [metadata].[vw_project_process_dependency_summary]
AS
SELECT
    p.[id] AS [project_id],
    p.[name] AS [project_name],
    pp.[id] AS [project_process_id],
    pp.[name] AS [process_name],
    dpp.[id] AS [dependency_project_process_id],
    dpp.[name] AS [dependency_process_name],
    dp.[id] AS [dependency_project_id],
    dp.[name] AS [dependency_project_name],
    pp.[is_active] AS [process_is_active],
    dpp.[is_active] AS [dependency_is_active]
FROM [metadata].[project_process_dependencies] ppd
INNER JOIN [metadata].[project_processes] pp ON pp.[id] = ppd.[project_process_id]
INNER JOIN [metadata].[projects] p ON p.[id] = pp.[project_id]
INNER JOIN [metadata].[project_processes] dpp ON dpp.[id] = ppd.[dependency_project_process_id]
INNER JOIN [metadata].[projects] dp ON dp.[id] = dpp.[project_id];
GO


/*============================================================================
  View: metadata.vw_project_process_action_summary

  Purpose:
  - Shows configured process actions in execution order.
  - Helps review action metadata without generating executable SQL.
  - Keeps database object fields nullable because actions may represent
    non-database activities in future.
============================================================================*/

CREATE OR ALTER VIEW [metadata].[vw_project_process_action_summary]
AS
SELECT
    p.[id] AS [project_id],
    p.[name] AS [project_name],
    pp.[id] AS [project_process_id],
    pp.[name] AS [process_name],
    ppa.[position] AS [action_position],
    ppa.[action_name],
    ppa.[action_type],
    ppa.[execution_database_id],
    pd.[name] AS [execution_database_name],
    ppa.[schema_name],
    ppa.[object_name],
    ppa.[parameter_template],
    ppa.[is_required],
    ppa.[is_active]
FROM [metadata].[project_process_actions] ppa
INNER JOIN [metadata].[project_processes] pp ON pp.[id] = ppa.[project_process_id]
INNER JOIN [metadata].[projects] p ON p.[id] = pp.[project_id]
LEFT JOIN [metadata].[project_databases] pd ON pd.[id] = ppa.[execution_database_id];
GO


/*============================================================================
  View: metadata.vw_project_batch_execution_scope

  Purpose:
  - Shows process-table-batch execution scope in one place.
  - Helps review which batches are assigned to which process/table scope.
  - Does not decide whether a process should execute.
============================================================================*/

CREATE OR ALTER VIEW [metadata].[vw_project_batch_execution_scope]
AS
SELECT
    p.[id] AS [project_id],
    p.[name] AS [project_name],
    pp.[id] AS [project_process_id],
    pp.[name] AS [process_name],
    controlled_t.[id] AS [controlled_table_id],
    controlled_db.[name] AS [controlled_database_name],
    controlled_t.[schema_name] AS [controlled_schema_name],
    controlled_t.[name] AS [controlled_table_name],
    b.[id] AS [batch_id],
    b.[position] AS [batch_position],
    source_t.[id] AS [batch_source_table_id],
    source_db.[name] AS [batch_source_database_name],
    source_t.[schema_name] AS [batch_source_schema_name],
    source_t.[name] AS [batch_source_table_name],
    b.[batch_column_name],
    b.[batch_column_type],
    b.[batch_value],
    b.[batch_start_value],
    b.[batch_end_value],
    b.[execution_required] AS [batch_execution_required],
    b.[is_active] AS [batch_is_active]
FROM [metadata].[project_process_table_batches] pptb
INNER JOIN [metadata].[project_processes] pp ON pp.[id] = pptb.[process_id]
INNER JOIN [metadata].[projects] p ON p.[id] = pp.[project_id]
INNER JOIN [metadata].[project_tables] controlled_t ON controlled_t.[id] = pptb.[table_id]
INNER JOIN [metadata].[project_databases] controlled_db ON controlled_db.[id] = controlled_t.[database_id]
INNER JOIN [metadata].[project_table_batches] b ON b.[id] = pptb.[batch_id]
INNER JOIN [metadata].[project_tables] source_t ON source_t.[id] = b.[batch_source_table_id]
INNER JOIN [metadata].[project_databases] source_db ON source_db.[id] = source_t.[database_id];
GO


/*============================================================================
  View: metadata.vw_project_table_lineage_summary

  Purpose:
  - Shows source-to-target table lineage.
  - Helps review table mappings without showing column-level metadata.
============================================================================*/

CREATE OR ALTER VIEW [metadata].[vw_project_table_lineage_summary]
AS
SELECT
    source_db.[project_id],
    p.[name] AS [project_name],
    source_db.[id] AS [source_database_id],
    source_db.[name] AS [source_database_name],
    source_t.[id] AS [source_table_id],
    source_t.[schema_name] AS [source_schema_name],
    source_t.[name] AS [source_table_name],
    target_db.[id] AS [target_database_id],
    target_db.[name] AS [target_database_name],
    target_t.[id] AS [target_table_id],
    target_t.[schema_name] AS [target_schema_name],
    target_t.[name] AS [target_table_name]
FROM [metadata].[project_table_mappings] ptm
INNER JOIN [metadata].[project_tables] source_t ON source_t.[id] = ptm.[table_source_id]
INNER JOIN [metadata].[project_databases] source_db ON source_db.[id] = source_t.[database_id]
INNER JOIN [metadata].[projects] p ON p.[id] = source_db.[project_id]
INNER JOIN [metadata].[project_tables] target_t ON target_t.[id] = ptm.[table_target_id]
INNER JOIN [metadata].[project_databases] target_db
    ON target_db.[id] = target_t.[database_id];
GO


/*============================================================================
  View: metadata.vw_project_process_monitoring_metric_summary

  Purpose:
  - Shows monitoring thresholds configured for each process.
  - Helps review process monitoring metadata before runtime execution.
============================================================================*/

CREATE OR ALTER VIEW [metadata].[vw_project_process_monitoring_metric_summary]
AS
SELECT
    p.[id] AS [project_id],
    p.[name] AS [project_name],
    pp.[id] AS [project_process_id],
    pp.[name] AS [process_name],
    ppm.[id] AS [project_process_monitoring_metric_id],
    mmc.[code] AS [metric_code],
    mmc.[description] AS [metric_description],
    mmc.[metric_source],
    mmc.[metric_value_type],
    mmc.[metric_unit],
    ppm.[min_value_bigint],
    ppm.[max_value_bigint],
    ppm.[min_value_decimal],
    ppm.[max_value_decimal],
    ppm.[severity],
    ppm.[is_active]
FROM [metadata].[project_process_monitoring_metrics] ppm
INNER JOIN [metadata].[project_processes] pp ON pp.[id] = ppm.[project_process_id]
INNER JOIN [metadata].[projects] p ON p.[id] = pp.[project_id]
INNER JOIN [reference].[monitoring_metric_codes] mmc ON mmc.[id] = ppm.[monitoring_metric_code_id];
GO


/*============================================================================
  View: runtime.vw_execution_run_summary

  Purpose:
  - Provides one row per project execution run.
  - Shows run status, dates, and duration.
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
    DATEDIFF(SECOND, er.[start_run_date], er.[end_run_date]) AS [duration_seconds],
    er.[created_by]
FROM [runtime].[execution_runs] er
INNER JOIN [metadata].[projects] p ON p.[id] = er.[project_id]
INNER JOIN [reference].[status_codes] sc ON sc.[id] = er.[status_code_id];
GO


/*============================================================================
  View: runtime.vw_execution_step_summary

  Purpose:
  - Provides one row per process execution step.
  - Shows process context, step status, dates, and duration.
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
    DATEDIFF(SECOND, es.[start_step_date], es.[end_step_date]) AS [duration_seconds],
    es.[created_by]
FROM [runtime].[execution_steps] es
INNER JOIN [runtime].[execution_runs] er ON er.[id] = es.[execution_run_id]
INNER JOIN [metadata].[projects] p ON p.[id] = er.[project_id]
INNER JOIN [metadata].[project_processes] pp ON pp.[id] = es.[project_process_id]
LEFT JOIN [metadata].[project_processes] parent_pp ON parent_pp.[id] = pp.[parent_process_id]
INNER JOIN [reference].[status_codes] sc ON sc.[id] = es.[status_code_id];
GO


/*============================================================================
  View: observability.vw_execution_observability_summary

  Purpose:
  - Provides one row per execution step with observability record counts.
  - Includes errors, validation results, reconciliation results, and monitoring
    results.
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
    COUNT(DISTINCT rr.[id]) AS [reconciliation_result_count],
    COUNT(DISTINCT mr.[id]) AS [monitoring_result_count]
FROM [runtime].[execution_steps] es
INNER JOIN [runtime].[execution_runs] er ON er.[id] = es.[execution_run_id]
INNER JOIN [metadata].[projects] p ON p.[id] = er.[project_id]
INNER JOIN [metadata].[project_processes] pp ON pp.[id] = es.[project_process_id]
INNER JOIN [reference].[status_codes] sc ON sc.[id] = es.[status_code_id]
LEFT JOIN [observability].[error_logs] el ON el.[execution_step_id] = es.[id]
LEFT JOIN [observability].[validation_results] vr ON vr.[execution_step_id] = es.[id]
LEFT JOIN [observability].[reconciliation_results] rr ON rr.[execution_step_id] = es.[id]
LEFT JOIN [observability].[monitoring_results] mr ON mr.[execution_step_id] = es.[id]
GROUP BY
    es.[id],
    es.[execution_run_id],
    er.[project_id],
    p.[name],
    pp.[id],
    pp.[name],
    sc.[code];
GO


/*============================================================================
  View: observability.vw_monitoring_result_summary

  Purpose:
  - Shows monitoring results with process context, metric metadata, actual values,
    configured thresholds, and evaluation result.
  - Keeps numeric values in their native columns instead of formatting them as
    strings.
============================================================================*/

CREATE OR ALTER VIEW [observability].[vw_monitoring_result_summary]
AS
SELECT
    mr.[id] AS [monitoring_result_id],
    mr.[execution_step_id],
    er.[id] AS [execution_run_id],
    er.[project_id],
    p.[name] AS [project_name],
    pp.[id] AS [project_process_id],
    pp.[name] AS [process_name],
    ppm.[id] AS [project_process_monitoring_metric_id],
    mmc.[code] AS [metric_code],
    mmc.[description] AS [metric_description],
    mmc.[metric_source],
    mmc.[metric_value_type],
    mmc.[metric_unit],
    mr.[actual_value_bigint],
    mr.[actual_value_decimal],
    ppm.[min_value_bigint],
    ppm.[max_value_bigint],
    ppm.[min_value_decimal],
    ppm.[max_value_decimal],
    ppm.[severity],
    mr.[is_within_expected_range],
    mr.[created_at],
    mr.[created_by]
FROM [observability].[monitoring_results] mr
INNER JOIN [runtime].[execution_steps] es ON es.[id] = mr.[execution_step_id]
INNER JOIN [runtime].[execution_runs] er ON er.[id] = es.[execution_run_id]
INNER JOIN [metadata].[projects] p ON p.[id] = er.[project_id]
INNER JOIN [metadata].[project_processes] pp ON pp.[id] = es.[project_process_id]
INNER JOIN [metadata].[project_process_monitoring_metrics] ppm ON ppm.[id] = mr.[project_process_monitoring_metric_id]
INNER JOIN [reference].[monitoring_metric_codes] mmc ON mmc.[id] = ppm.[monitoring_metric_code_id];
GO

CREATE OR ALTER VIEW [observability].[vw_reconciliation_result_summary]
AS
SELECT
    rr.[id] AS [reconciliation_result_id],
    rr.[execution_step_id],
    es.[execution_run_id],
    er.[project_id],
    p.[name] AS [project_name],
    es.[project_process_id],
    pp.[name] AS [process_name],
    rr.[metric_name],
    rr.[reconciliation_key],
    rr.[reconciliation_side],
    rr.[metric_value_bigint],
    rr.[metric_value_decimal],
    rr.[created_at],
    rr.[created_by]
FROM [observability].[reconciliation_results] rr
INNER JOIN [runtime].[execution_steps] es ON es.[id] = rr.[execution_step_id]
INNER JOIN [runtime].[execution_runs] er ON er.[id] = es.[execution_run_id]
INNER JOIN [metadata].[projects] p ON p.[id] = er.[project_id]
INNER JOIN [metadata].[project_processes] pp ON pp.[id] = es.[project_process_id];
GO
