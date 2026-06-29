/*============================================================================
  DataOps_Control Runtime Scenario
  Process: Sales_Analytics_Migration / FactSales Load
  Scenario: SSIS technical failure
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

EXEC [observability].[usp_log_error]
    @p_execution_step_id = @execution_step_id,
    @p_error_source = 'SSIS.Sales_Analytics_Migration.PKG_FACT_DATA',
    @p_details = 'Simulated SSIS package failure while loading FactSales.';

EXEC [runtime].[usp_end_execution_step]
    @p_execution_step_id = @execution_step_id,
    @p_status_code_id = 4; -- Failed

EXEC [runtime].[usp_end_execution_run]
    @p_execution_run_id = @execution_run_id;
GO
