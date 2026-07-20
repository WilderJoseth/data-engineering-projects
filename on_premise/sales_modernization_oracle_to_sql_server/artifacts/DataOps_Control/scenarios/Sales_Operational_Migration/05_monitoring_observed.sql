/*============================================================================
  DataOps_Control Runtime Scenario
  Process: Sales_Operational_Migration / Sales Load
  Scenario: Warning metric outside range produces Observed status
============================================================================*/

USE [DataOps_Control];
GO

DECLARE @project_id SMALLINT = 1;
DECLARE @project_process_id INT = 21; -- Sales Load
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
    ppm.[max_value_bigint] + 1,
    NULL,
    0
FROM [metadata].[project_process_monitoring_metrics] ppm
INNER JOIN [reference].[monitoring_metric_codes] mmc
    ON mmc.[id] = ppm.[monitoring_metric_code_id]
WHERE ppm.[project_process_id] = @project_process_id
AND mmc.[code] = 'DURATION_SECONDS';

EXEC [runtime].[usp_end_execution_step]
    @p_execution_step_id = @execution_step_id,
    @p_status_code_id = 6; -- Observed

EXEC [runtime].[usp_end_execution_run]
    @p_execution_run_id = @execution_run_id;
GO
