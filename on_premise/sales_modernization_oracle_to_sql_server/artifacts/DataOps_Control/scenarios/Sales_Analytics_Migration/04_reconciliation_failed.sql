/*============================================================================
  DataOps_Control Runtime Scenario
  Process: Sales_Analytics_Migration / FactSales Load
  Scenario: Reconciliation mismatch produces Failed status
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
    ('ROW_COUNT', 'FactSales', 'TARGET', 995, @execution_step_id);

EXEC [runtime].[usp_end_execution_step]
    @p_execution_step_id = @execution_step_id,
    @p_status_code_id = 4; -- Failed

EXEC [runtime].[usp_end_execution_run]
    @p_execution_run_id = @execution_run_id;
GO
