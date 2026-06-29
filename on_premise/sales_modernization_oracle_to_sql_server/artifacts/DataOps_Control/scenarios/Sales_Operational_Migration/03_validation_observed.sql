/*============================================================================
  DataOps_Control Runtime Scenario
  Process: Sales_Operational_Migration / Sales Load
  Scenario: Validation warning produces Observed status
============================================================================*/

USE [DataOps_Control];
GO

DECLARE @project_id SMALLINT = 1;
DECLARE @project_process_id INT = 21; -- Sales Load
DECLARE @execution_run_id INT;
DECLARE @execution_step_id BIGINT;
DECLARE @validation_code_id SMALLINT;

DECLARE @run_result TABLE ([execution_run_id] INT);
DECLARE @step_result TABLE ([execution_step_id] BIGINT);

SELECT @validation_code_id = [id]
FROM [reference].[validation_codes]
WHERE [code] = 'DATE_RANGE';

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

INSERT INTO [observability].[validation_results]
(
    [details],
    [affected_row_count],
    [execution_step_id],
    [validation_code_id]
)
VALUES
(
    'Simulated validation warning: Sales orders contain dates that require review.',
    3,
    @execution_step_id,
    @validation_code_id
);

EXEC [runtime].[usp_end_execution_step]
    @p_execution_step_id = @execution_step_id,
    @p_status_code_id = 6; -- Observed

EXEC [runtime].[usp_end_execution_run]
    @p_execution_run_id = @execution_run_id;
GO
