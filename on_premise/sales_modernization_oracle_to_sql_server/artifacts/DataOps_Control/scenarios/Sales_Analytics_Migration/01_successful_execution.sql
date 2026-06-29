/*============================================================================
  DataOps_Control Runtime Scenario
  Process: Sales_Analytics_Migration / FactSales Load
  Scenario: Successful execution
============================================================================*/

USE [DataOps_Control];
GO

DECLARE @project_id SMALLINT = 1;
DECLARE @project_process_id INT = 28; -- FactSales Load
DECLARE @execution_run_id INT;
DECLARE @execution_step_id BIGINT;

DECLARE @run_result TABLE ([execution_run_id] INT);
DECLARE @step_result TABLE ([execution_step_id] BIGINT);

INSERT INTO @run_result
EXEC [runtime].[usp_start_execution_run] @p_project_id = @project_id;

SELECT @execution_run_id = [execution_run_id]
FROM @run_result;

INSERT INTO @step_result
EXEC [runtime].[usp_start_execution_step]
    @p_execution_run_id = @execution_run_id,
    @p_project_process_id = @project_process_id;

SELECT @execution_step_id = [execution_step_id]
FROM @step_result;

INSERT INTO [observability].[reconciliation_results]
(
    [metric_name],
    [reconciliation_key],
    [reconciliation_side],
    [metric_value_bigint],
    [execution_step_id]
)
VALUES
    ('ROW_COUNT', 'FactSales', 'SOURCE', 1000, @execution_step_id),
    ('ROW_COUNT', 'FactSales', 'TARGET', 1000, @execution_step_id);

INSERT INTO [observability].[monitoring_results]
(
    [execution_step_id],
    [project_process_monitoring_metric_id],
    [actual_value_bigint],
    [actual_value_decimal],
    [is_within_expected_range]
)
SELECT
    @execution_step_id,
    ppm.[id],
    CASE mmc.[code]
        WHEN 'DURATION_SECONDS' THEN 120
        WHEN 'ROW_COUNT' THEN 1000
    END,
    NULL,
    1
FROM [metadata].[project_process_monitoring_metrics] ppm
INNER JOIN [reference].[monitoring_metric_codes] mmc
    ON mmc.[id] = ppm.[monitoring_metric_code_id]
WHERE ppm.[project_process_id] = @project_process_id
AND mmc.[code] IN ('DURATION_SECONDS', 'ROW_COUNT');

EXEC [runtime].[usp_end_execution_step]
    @p_execution_step_id = @execution_step_id,
    @p_status_code_id = 3; -- Success

EXEC [runtime].[usp_end_execution_run]
    @p_execution_run_id = @execution_run_id;
GO
