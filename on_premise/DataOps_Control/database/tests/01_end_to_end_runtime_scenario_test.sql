USE [DataOps_Control];
GO

/*
    Script: 01_end_to_end_runtime_scenario_test.sql
    Database: DataOps_Control

    Purpose:
    - Runs an end-to-end runtime scenario against the deployed framework.
    - Creates isolated test metadata with a timestamped project name.
    - Validates execution plans, dependency evaluation, run/step lifecycle,
      watermark registration/commit, and review views.

    Notes:
    - This script creates test-owned metadata and runtime rows only.
    - It does not delete non-test data.
    - It uses THROW assertions so sqlcmd -b fails on any broken expectation.
*/

SET NOCOUNT ON;

DECLARE @status_pending SMALLINT = 1;
DECLARE @status_running SMALLINT = 2;
DECLARE @status_success SMALLINT = 3;
DECLARE @status_observed SMALLINT = 6;
DECLARE @status_ready SMALLINT = 7;

DECLARE @project_id SMALLINT;
DECLARE @database_id SMALLINT;
DECLARE @root_process_id INT;
DECLARE @reference_process_id INT;
DECLARE @product_category_process_id INT;
DECLARE @product_process_id INT;
DECLARE @sales_process_id INT;
DECLARE @table_id INT;
DECLARE @watermark_column_id INT;
DECLARE @metric_id INT;

DECLARE @execution_plan_id BIGINT;
DECLARE @execution_run_id BIGINT;
DECLARE @reference_plan_process_id BIGINT;
DECLARE @product_category_plan_process_id BIGINT;
DECLARE @product_plan_process_id BIGINT;
DECLARE @sales_plan_process_id BIGINT;
DECLARE @reference_step_id BIGINT;
DECLARE @product_category_step_id BIGINT;
DECLARE @product_step_id BIGINT;
DECLARE @sales_step_id BIGINT;
DECLARE @watermark_control_id BIGINT;
DECLARE @execution_watermark_id BIGINT;

DECLARE @project_name VARCHAR(100) =
    CONCAT('DataOps_E2E_Runtime_', FORMAT(SYSUTCDATETIME(), 'yyyyMMddHHmmss'));

DECLARE @ids TABLE ([id] BIGINT);

SELECT @project_id = CAST(ISNULL(MAX([id]), 0) + 1 AS SMALLINT)
FROM [metadata].[projects];

SELECT @database_id = CAST(ISNULL(MAX([id]), 0) + 1 AS SMALLINT)
FROM [metadata].[project_databases];

SELECT @root_process_id = ISNULL(MAX([id]), 0) + 1000
FROM [metadata].[project_processes];

SET @reference_process_id = @root_process_id + 1;
SET @product_category_process_id = @root_process_id + 2;
SET @product_process_id = @root_process_id + 3;
SET @sales_process_id = @root_process_id + 4;

SELECT @table_id = ISNULL(MAX([id]), 0) + 1000
FROM [metadata].[project_tables];

SELECT @watermark_column_id = ISNULL(MAX([id]), 0) + 1000
FROM [metadata].[project_columns];

SELECT @metric_id = ISNULL(MAX([id]), 0) + 1000
FROM [metadata].[project_process_monitoring_metrics];

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO [metadata].[projects] ([id], [name])
    VALUES (@project_id, @project_name);

    INSERT INTO [metadata].[project_databases]
    (
        [id],
        [name],
        [platform_type],
        [database_role],
        [project_id]
    )
    VALUES
    (
        @database_id,
        'SalesOperationalDb',
        'SQL_SERVER',
        'TARGET',
        @project_id
    );

    INSERT INTO [metadata].[project_processes]
    (
        [id],
        [name],
        [project_id],
        [parent_process_id],
        [execution_required]
    )
    VALUES
        (@root_process_id, 'Sales_Operational_Migration', @project_id, NULL, 0),
        (@reference_process_id, 'Reference Data Load', @project_id, @root_process_id, 1),
        (@product_category_process_id, 'ProductCategory Load', @project_id, @root_process_id, 1),
        (@product_process_id, 'Product Load', @project_id, @root_process_id, 1),
        (@sales_process_id, 'Sales Load', @project_id, @root_process_id, 1);

    INSERT INTO [metadata].[project_process_dependencies]
    (
        [project_process_id],
        [dependency_project_process_id]
    )
    VALUES
        (@product_process_id, @product_category_process_id),
        (@sales_process_id, @product_process_id);

    INSERT INTO [metadata].[project_tables]
    (
        [id],
        [schema_name],
        [name],
        [is_fact_table],
        [is_transactional_table],
        [batch_column_active],
        [execution_required],
        [database_id]
    )
    VALUES
    (
        @table_id,
        'dbo',
        'SalesOrder',
        1,
        1,
        0,
        1,
        @database_id
    );

    INSERT INTO [metadata].[project_columns]
    (
        [id],
        [position],
        [name],
        [type],
        [is_nullable],
        [is_watermark],
        [is_reconciliation_column],
        [table_id]
    )
    VALUES
    (
        @watermark_column_id,
        1,
        'ModifiedDate',
        'DATETIME2',
        0,
        1,
        0,
        @table_id
    );

    INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id])
    VALUES (@sales_process_id, @table_id);

    INSERT INTO [metadata].[project_process_monitoring_metrics]
    (
        [id],
        [project_process_id],
        [monitoring_metric_code_id],
        [min_value_bigint],
        [severity]
    )
    VALUES
    (
        @metric_id,
        @sales_process_id,
        5,
        0,
        'INFO'
    );

    INSERT INTO [runtime].[execution_watermark_controls]
    (
        [project_process_id],
        [table_id],
        [watermark_column_id],
        [last_committed_watermark_value],
        [lower_bound_operator],
        [upper_bound_operator],
        [upper_bound_strategy]
    )
    VALUES
    (
        @sales_process_id,
        @table_id,
        @watermark_column_id,
        '2026-01-01T00:00:00',
        '>',
        '<=',
        'STATIC_VALUE'
    );

    SET @watermark_control_id = CAST(SCOPE_IDENTITY() AS BIGINT);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    THROW;
END CATCH;

DELETE FROM @ids;
INSERT INTO @ids
EXEC [runtime].[usp_create_execution_plan]
    @p_project_id = @project_id,
    @p_plan_type = 'FULL',
    @p_plan_name = 'E2E Sales Operational Runtime Test',
    @p_root_project_process_id = @root_process_id,
    @p_scope_description = 'Functional end-to-end runtime scenario test';
SELECT @execution_plan_id = [id] FROM @ids;

DELETE FROM @ids;
INSERT INTO @ids
EXEC [runtime].[usp_add_execution_plan_process]
    @p_execution_plan_id = @execution_plan_id,
    @p_project_process_id = @reference_process_id;
SELECT @reference_plan_process_id = [id] FROM @ids;

DELETE FROM @ids;
INSERT INTO @ids
EXEC [runtime].[usp_add_execution_plan_process]
    @p_execution_plan_id = @execution_plan_id,
    @p_project_process_id = @product_category_process_id;
SELECT @product_category_plan_process_id = [id] FROM @ids;

DELETE FROM @ids;
INSERT INTO @ids
EXEC [runtime].[usp_add_execution_plan_process]
    @p_execution_plan_id = @execution_plan_id,
    @p_project_process_id = @product_process_id;
SELECT @product_plan_process_id = [id] FROM @ids;

DELETE FROM @ids;
INSERT INTO @ids
EXEC [runtime].[usp_add_execution_plan_process]
    @p_execution_plan_id = @execution_plan_id,
    @p_project_process_id = @sales_process_id;
SELECT @sales_plan_process_id = [id] FROM @ids;

EXEC [runtime].[usp_evaluate_execution_plan_dependencies]
    @p_execution_plan_id = @execution_plan_id;

IF NOT EXISTS
(
    SELECT 1
    FROM [runtime].[execution_plan_processes]
    WHERE [id] = @product_category_plan_process_id
    AND [status_code_id] = @status_ready
)
BEGIN
    ;THROW 51001, 'ProductCategory Load should be READY after initial dependency evaluation.', 1;
END;

IF NOT EXISTS
(
    SELECT 1
    FROM [runtime].[execution_plan_processes]
    WHERE [id] = @product_plan_process_id
    AND [status_code_id] = @status_pending
)
BEGIN
    ;THROW 51002, 'Product Load should remain PENDING until ProductCategory Load succeeds.', 1;
END;

IF NOT EXISTS
(
    SELECT 1
    FROM [runtime].[execution_plan_processes]
    WHERE [id] = @sales_plan_process_id
    AND [status_code_id] = @status_pending
)
BEGIN
    ;THROW 51003, 'Sales Load should remain PENDING until Product Load succeeds.', 1;
END;

DELETE FROM @ids;
INSERT INTO @ids
EXEC [runtime].[usp_start_execution_run]
    @p_project_id = @project_id,
    @p_execution_plan_id = @execution_plan_id;
SELECT @execution_run_id = [id] FROM @ids;

DELETE FROM @ids;
INSERT INTO @ids
EXEC [runtime].[usp_start_execution_step]
    @p_execution_run_id = @execution_run_id,
    @p_project_process_id = @reference_process_id,
    @p_execution_plan_process_id = @reference_plan_process_id;
SELECT @reference_step_id = [id] FROM @ids;

EXEC [runtime].[usp_end_execution_step]
    @p_execution_step_id = @reference_step_id,
    @p_status_code_id = @status_success;

DELETE FROM @ids;
INSERT INTO @ids
EXEC [runtime].[usp_start_execution_step]
    @p_execution_run_id = @execution_run_id,
    @p_project_process_id = @product_category_process_id,
    @p_execution_plan_process_id = @product_category_plan_process_id;
SELECT @product_category_step_id = [id] FROM @ids;

IF NOT EXISTS
(
    SELECT 1
    FROM [runtime].[execution_plan_processes]
    WHERE [id] = @product_category_plan_process_id
    AND [status_code_id] = @status_running
)
BEGIN
    ;THROW 51004, 'ProductCategory Load plan process should be RUNNING after step start.', 1;
END;

EXEC [runtime].[usp_end_execution_step]
    @p_execution_step_id = @product_category_step_id,
    @p_status_code_id = @status_success;

IF NOT EXISTS
(
    SELECT 1
    FROM [runtime].[execution_plan_processes]
    WHERE [id] = @product_plan_process_id
    AND [status_code_id] = @status_ready
)
BEGIN
    ;THROW 51005, 'Product Load should become READY after ProductCategory Load succeeds.', 1;
END;

DELETE FROM @ids;
INSERT INTO @ids
EXEC [runtime].[usp_start_execution_step]
    @p_execution_run_id = @execution_run_id,
    @p_project_process_id = @product_process_id,
    @p_execution_plan_process_id = @product_plan_process_id;
SELECT @product_step_id = [id] FROM @ids;

EXEC [runtime].[usp_end_execution_step]
    @p_execution_step_id = @product_step_id,
    @p_status_code_id = @status_success;

IF NOT EXISTS
(
    SELECT 1
    FROM [runtime].[execution_plan_processes]
    WHERE [id] = @sales_plan_process_id
    AND [status_code_id] = @status_ready
)
BEGIN
    ;THROW 51006, 'Sales Load should become READY after Product Load succeeds.', 1;
END;

DELETE FROM @ids;
INSERT INTO @ids
EXEC [runtime].[usp_start_execution_step]
    @p_execution_run_id = @execution_run_id,
    @p_project_process_id = @sales_process_id,
    @p_execution_plan_process_id = @sales_plan_process_id;
SELECT @sales_step_id = [id] FROM @ids;

DELETE FROM @ids;
INSERT INTO @ids
EXEC [runtime].[usp_register_execution_watermark]
    @p_execution_step_id = @sales_step_id,
    @p_execution_watermark_control_id = @watermark_control_id,
    @p_extraction_upper_bound_value = '2026-07-14T00:00:00';
SELECT @execution_watermark_id = [id] FROM @ids;

EXEC [runtime].[usp_end_execution_step]
    @p_execution_step_id = @sales_step_id,
    @p_status_code_id = @status_success;

EXEC [runtime].[usp_commit_execution_watermark]
    @p_execution_watermark_id = @execution_watermark_id,
    @p_status_code_id = @status_success,
    @p_candidate_watermark_value = '2026-07-14T00:00:00',
    @p_committed_watermark_value = '2026-07-14T00:00:00',
    @p_allow_observed_commit = 0;

IF NOT EXISTS
(
    SELECT 1
    FROM [runtime].[execution_watermarks]
    WHERE [id] = @execution_watermark_id
    AND [status_code_id] = @status_success
    AND [committed_watermark_value] = '2026-07-14T00:00:00'
)
BEGIN
    ;THROW 51007, 'Execution watermark history was not committed as expected.', 1;
END;

IF NOT EXISTS
(
    SELECT 1
    FROM [runtime].[execution_watermark_controls]
    WHERE [id] = @watermark_control_id
    AND [last_committed_watermark_value] = '2026-07-14T00:00:00'
)
BEGIN
    ;THROW 51008, 'Watermark control committed value was not updated as expected.', 1;
END;

EXEC [runtime].[usp_end_execution_run]
    @p_execution_run_id = @execution_run_id;

EXEC [runtime].[usp_close_execution_plan]
    @p_execution_plan_id = @execution_plan_id,
    @p_cancel = 0;

IF NOT EXISTS
(
    SELECT 1
    FROM [runtime].[execution_runs]
    WHERE [id] = @execution_run_id
    AND [status_code_id] = @status_success
    AND [end_run_date] IS NOT NULL
)
BEGIN
    ;THROW 51009, 'Execution run should close as SUCCESS.', 1;
END;

IF NOT EXISTS
(
    SELECT 1
    FROM [runtime].[execution_plans]
    WHERE [id] = @execution_plan_id
    AND [status_code_id] = @status_success
    AND [end_plan_date] IS NOT NULL
)
BEGIN
    ;THROW 51010, 'Execution plan should close as SUCCESS.', 1;
END;

IF EXISTS
(
    SELECT 1
    FROM [reference].[status_codes]
    WHERE [code] IN ('WAITING', 'REQUIRES_RERUN')
)
BEGIN
    ;THROW 51011, 'WAITING or REQUIRES_RERUN should not exist in the current status model.', 1;
END;

IF NOT EXISTS
(
    SELECT 1
    FROM [runtime].[vw_execution_plan_summary]
    WHERE [execution_plan_id] = @execution_plan_id
)
BEGIN
    ;THROW 51012, 'runtime.vw_execution_plan_summary did not return the test plan.', 1;
END;

IF NOT EXISTS
(
    SELECT 1
    FROM [runtime].[vw_execution_plan_process_summary]
    WHERE [execution_plan_id] = @execution_plan_id
)
BEGIN
    ;THROW 51013, 'runtime.vw_execution_plan_process_summary did not return the test plan processes.', 1;
END;

IF NOT EXISTS
(
    SELECT 1
    FROM [runtime].[vw_execution_run_summary]
    WHERE [execution_run_id] = @execution_run_id
)
BEGIN
    ;THROW 51014, 'runtime.vw_execution_run_summary did not return the test run.', 1;
END;

IF NOT EXISTS
(
    SELECT 1
    FROM [runtime].[vw_execution_step_summary]
    WHERE [execution_run_id] = @execution_run_id
)
BEGIN
    ;THROW 51015, 'runtime.vw_execution_step_summary did not return the test steps.', 1;
END;

IF NOT EXISTS
(
    SELECT 1
    FROM [runtime].[vw_execution_watermark_summary]
    WHERE [execution_watermark_control_id] = @watermark_control_id
    AND [execution_watermark_id] = @execution_watermark_id
)
BEGIN
    ;THROW 51016, 'runtime.vw_execution_watermark_summary did not return the test watermark.', 1;
END;

IF NOT EXISTS
(
    SELECT 1
    FROM [observability].[vw_execution_observability_summary]
    WHERE [execution_run_id] = @execution_run_id
)
BEGIN
    ;THROW 51017, 'observability.vw_execution_observability_summary did not return the test execution steps.', 1;
END;

SELECT
    'TEST_CONTEXT' AS [result_type],
    @project_name AS [project_name],
    @project_id AS [project_id],
    @execution_plan_id AS [execution_plan_id],
    @execution_run_id AS [execution_run_id],
    @watermark_control_id AS [watermark_control_id],
    @execution_watermark_id AS [execution_watermark_id];

SELECT
    'PLAN_PROCESS_STATUS' AS [result_type],
    pp.[name] AS [process_name],
    sc.[code] AS [status_code],
    epp.[dependency_evaluation_details]
FROM [runtime].[execution_plan_processes] epp
INNER JOIN [metadata].[project_processes] pp
    ON pp.[id] = epp.[project_process_id]
INNER JOIN [reference].[status_codes] sc
    ON sc.[id] = epp.[status_code_id]
WHERE epp.[execution_plan_id] = @execution_plan_id
ORDER BY pp.[name];

SELECT
    'STEP_STATUS' AS [result_type],
    pp.[name] AS [process_name],
    sc.[code] AS [status_code],
    es.[start_step_date],
    es.[end_step_date]
FROM [runtime].[execution_steps] es
INNER JOIN [metadata].[project_processes] pp
    ON pp.[id] = es.[project_process_id]
INNER JOIN [reference].[status_codes] sc
    ON sc.[id] = es.[status_code_id]
WHERE es.[execution_run_id] = @execution_run_id
ORDER BY es.[id];

SELECT
    'WATERMARK_STATUS' AS [result_type],
    ewc.[last_committed_watermark_value],
    ew.[previous_committed_watermark_value],
    ew.[extraction_upper_bound_value],
    ew.[candidate_watermark_value],
    ew.[committed_watermark_value],
    sc.[code] AS [status_code]
FROM [runtime].[execution_watermark_controls] ewc
INNER JOIN [runtime].[execution_watermarks] ew
    ON ew.[execution_watermark_control_id] = ewc.[id]
INNER JOIN [reference].[status_codes] sc
    ON sc.[id] = ew.[status_code_id]
WHERE ewc.[id] = @watermark_control_id;

SELECT 'TEST_RESULT' AS [result_type], 'PASS' AS [result_value];
GO
