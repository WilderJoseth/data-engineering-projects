USE [DataOps_Control];
GO

/*
    Script: 02_failure_recovery_runtime_scenario_test.sql
    Database: DataOps_Control

    Purpose:
    - Runs failure, blocking, recovery, observed, skipped, cancellation, and
      watermark non-commit scenario coverage against the deployed framework.

    Notes:
    - Creates isolated timestamped test metadata.
    - Does not delete non-test data.
    - Uses THROW assertions so sqlcmd -b fails on any broken expectation.
*/

SET NOCOUNT ON;

DECLARE @status_pending SMALLINT = 1;
DECLARE @status_running SMALLINT = 2;
DECLARE @status_success SMALLINT = 3;
DECLARE @status_failed SMALLINT = 4;
DECLARE @status_skipped SMALLINT = 5;
DECLARE @status_observed SMALLINT = 6;
DECLARE @status_ready SMALLINT = 7;
DECLARE @status_blocked SMALLINT = 8;
DECLARE @status_cancelled SMALLINT = 9;

DECLARE @project_id SMALLINT;
DECLARE @database_id SMALLINT;
DECLARE @product_category_process_id INT;
DECLARE @product_process_id INT;
DECLARE @sales_process_id INT;
DECLARE @optional_audit_process_id INT;
DECLARE @category_table_id INT;
DECLARE @category_watermark_column_id INT;
DECLARE @metric_id INT;
DECLARE @failure_watermark_control_id BIGINT;

DECLARE @failure_plan_id BIGINT;
DECLARE @failure_run_id BIGINT;
DECLARE @failure_category_epp_id BIGINT;
DECLARE @failure_product_epp_id BIGINT;
DECLARE @failure_sales_epp_id BIGINT;
DECLARE @failure_optional_epp_id BIGINT;
DECLARE @failure_category_step_id BIGINT;
DECLARE @failure_execution_watermark_id BIGINT;

DECLARE @recovery_plan_id BIGINT;
DECLARE @recovery_run_id BIGINT;
DECLARE @recovery_category_epp_id BIGINT;
DECLARE @recovery_product_epp_id BIGINT;
DECLARE @recovery_sales_epp_id BIGINT;
DECLARE @recovery_optional_epp_id BIGINT;
DECLARE @recovery_category_step_id BIGINT;
DECLARE @recovery_product_step_id BIGINT;
DECLARE @recovery_sales_step_id BIGINT;
DECLARE @recovery_optional_step_id BIGINT;

DECLARE @cancel_plan_id BIGINT;
DECLARE @cancel_process_epp_id BIGINT;

DECLARE @sales_status_after_failure SMALLINT;
DECLARE @sales_status_after_failure_code VARCHAR(15);

DECLARE @project_name VARCHAR(100) =
    CONCAT('DataOps_Failure_Recovery_', FORMAT(SYSUTCDATETIME(), 'yyyyMMddHHmmss'));

DECLARE @ids TABLE ([id] BIGINT);

SELECT @project_id = CAST(ISNULL(MAX([id]), 0) + 1 AS SMALLINT)
FROM [metadata].[projects];

SELECT @database_id = CAST(ISNULL(MAX([id]), 0) + 1 AS SMALLINT)
FROM [metadata].[project_databases];

SELECT @product_category_process_id = ISNULL(MAX([id]), 0) + 1000
FROM [metadata].[project_processes];

SET @product_process_id = @product_category_process_id + 1;
SET @sales_process_id = @product_category_process_id + 2;
SET @optional_audit_process_id = @product_category_process_id + 3;

SELECT @category_table_id = ISNULL(MAX([id]), 0) + 1000
FROM [metadata].[project_tables];

SELECT @category_watermark_column_id = ISNULL(MAX([id]), 0) + 1000
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
        'FailureRecoveryDb',
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
        (@product_category_process_id, 'ProductCategory Load', @project_id, NULL, 1),
        (@product_process_id, 'Product Load', @project_id, NULL, 1),
        (@sales_process_id, 'Sales Load', @project_id, NULL, 1),
        (@optional_audit_process_id, 'Optional Audit Load', @project_id, NULL, 0);

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
        [execution_required],
        [database_id]
    )
    VALUES
    (
        @category_table_id,
        'dbo',
        'ProductCategory',
        0,
        1,
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
        @category_watermark_column_id,
        1,
        'ModifiedDate',
        'DATETIME2',
        0,
        1,
        0,
        @category_table_id
    );

    INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id])
    VALUES (@product_category_process_id, @category_table_id);

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
        'WARNING'
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
        @product_category_process_id,
        @category_table_id,
        @category_watermark_column_id,
        '2026-01-01T00:00:00',
        '>',
        '<=',
        'STATIC_VALUE'
    );

    SET @failure_watermark_control_id = CAST(SCOPE_IDENTITY() AS BIGINT);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    THROW;
END CATCH;

/* Failure plan */
DELETE FROM @ids;
INSERT INTO @ids
EXEC [runtime].[usp_create_execution_plan]
    @p_project_id = @project_id,
    @p_plan_type = 'FULL',
    @p_plan_name = 'Failure path plan',
    @p_scope_description = 'Failure and blocking functional test';
SELECT @failure_plan_id = [id] FROM @ids;

DELETE FROM @ids;
INSERT INTO @ids EXEC [runtime].[usp_add_execution_plan_process] @failure_plan_id, @product_category_process_id;
SELECT @failure_category_epp_id = [id] FROM @ids;

DELETE FROM @ids;
INSERT INTO @ids EXEC [runtime].[usp_add_execution_plan_process] @failure_plan_id, @product_process_id;
SELECT @failure_product_epp_id = [id] FROM @ids;

DELETE FROM @ids;
INSERT INTO @ids EXEC [runtime].[usp_add_execution_plan_process] @failure_plan_id, @sales_process_id;
SELECT @failure_sales_epp_id = [id] FROM @ids;

DELETE FROM @ids;
INSERT INTO @ids EXEC [runtime].[usp_add_execution_plan_process] @failure_plan_id, @optional_audit_process_id;
SELECT @failure_optional_epp_id = [id] FROM @ids;

EXEC [runtime].[usp_evaluate_execution_plan_dependencies] @failure_plan_id;

IF NOT EXISTS (SELECT 1 FROM [runtime].[execution_plan_processes] WHERE [id] = @failure_category_epp_id AND [status_code_id] = @status_ready)
BEGIN
    ;THROW 52001, 'Failure plan ProductCategory Load should initially be READY.', 1;
END;
IF NOT EXISTS (SELECT 1 FROM [runtime].[execution_plan_processes] WHERE [id] = @failure_product_epp_id AND [status_code_id] = @status_pending)
BEGIN
    ;THROW 52002, 'Failure plan Product Load should initially be PENDING.', 1;
END;
IF NOT EXISTS (SELECT 1 FROM [runtime].[execution_plan_processes] WHERE [id] = @failure_sales_epp_id AND [status_code_id] = @status_pending)
BEGIN
    ;THROW 52003, 'Failure plan Sales Load should initially be PENDING.', 1;
END;
IF NOT EXISTS (SELECT 1 FROM [runtime].[execution_plan_processes] WHERE [id] = @failure_optional_epp_id AND [status_code_id] = @status_ready)
BEGIN
    ;THROW 52004, 'Failure plan Optional Audit Load should initially be READY.', 1;
END;

DELETE FROM @ids;
INSERT INTO @ids
EXEC [runtime].[usp_start_execution_run]
    @p_project_id = @project_id,
    @p_execution_plan_id = @failure_plan_id;
SELECT @failure_run_id = [id] FROM @ids;

DELETE FROM @ids;
INSERT INTO @ids
EXEC [runtime].[usp_start_execution_step]
    @p_execution_run_id = @failure_run_id,
    @p_project_process_id = @product_category_process_id,
    @p_execution_plan_process_id = @failure_category_epp_id;
SELECT @failure_category_step_id = [id] FROM @ids;

DELETE FROM @ids;
INSERT INTO @ids
EXEC [runtime].[usp_register_execution_watermark]
    @p_execution_step_id = @failure_category_step_id,
    @p_execution_watermark_control_id = @failure_watermark_control_id,
    @p_extraction_upper_bound_value = '2026-07-14T00:00:00';
SELECT @failure_execution_watermark_id = [id] FROM @ids;

EXEC [runtime].[usp_end_execution_step]
    @p_execution_step_id = @failure_category_step_id,
    @p_status_code_id = @status_failed;

EXEC [runtime].[usp_commit_execution_watermark]
    @p_execution_watermark_id = @failure_execution_watermark_id,
    @p_status_code_id = @status_failed,
    @p_candidate_watermark_value = '2026-07-14T00:00:00',
    @p_committed_watermark_value = '2026-07-14T00:00:00',
    @p_allow_observed_commit = 0;

EXEC [runtime].[usp_evaluate_execution_plan_dependencies] @failure_plan_id;

IF NOT EXISTS (SELECT 1 FROM [runtime].[execution_plan_processes] WHERE [id] = @failure_category_epp_id AND [status_code_id] = @status_failed)
BEGIN
    ;THROW 52005, 'ProductCategory Load should be FAILED in the failure plan.', 1;
END;
IF NOT EXISTS (SELECT 1 FROM [runtime].[execution_plan_processes] WHERE [id] = @failure_product_epp_id AND [status_code_id] = @status_blocked)
BEGIN
    ;THROW 52006, 'Product Load should be BLOCKED after ProductCategory Load fails.', 1;
END;

SELECT
    @sales_status_after_failure = epp.[status_code_id],
    @sales_status_after_failure_code = sc.[code]
FROM [runtime].[execution_plan_processes] epp
INNER JOIN [reference].[status_codes] sc
    ON sc.[id] = epp.[status_code_id]
WHERE epp.[id] = @failure_sales_epp_id;

IF @sales_status_after_failure NOT IN (@status_pending, @status_blocked)
BEGIN
    ;THROW 52007, 'Sales Load should be PENDING or BLOCKED after upstream failure, according to current SQL behavior.', 1;
END;

IF NOT EXISTS
(
    SELECT 1
    FROM [runtime].[execution_watermarks] ew
    INNER JOIN [runtime].[execution_watermark_controls] ewc
        ON ewc.[id] = ew.[execution_watermark_control_id]
    WHERE ew.[id] = @failure_execution_watermark_id
    AND ew.[status_code_id] = @status_failed
    AND ewc.[last_committed_watermark_value] = '2026-01-01T00:00:00'
)
BEGIN
    ;THROW 52008, 'Failed watermark finalization should update history status without advancing the control value.', 1;
END;

EXEC [runtime].[usp_end_execution_run] @failure_run_id;
EXEC [runtime].[usp_close_execution_plan] @failure_plan_id, 0;

IF NOT EXISTS (SELECT 1 FROM [runtime].[execution_runs] WHERE [id] = @failure_run_id AND [status_code_id] = @status_failed AND [end_run_date] IS NOT NULL)
BEGIN
    ;THROW 52009, 'Failure run should close as FAILED.', 1;
END;
IF NOT EXISTS (SELECT 1 FROM [runtime].[execution_plans] WHERE [id] = @failure_plan_id AND [status_code_id] = @status_failed AND [end_plan_date] IS NOT NULL)
BEGIN
    ;THROW 52010, 'Failure plan should close as FAILED.', 1;
END;

/* Recovery plan with observed and skipped behavior */
DELETE FROM @ids;
INSERT INTO @ids
EXEC [runtime].[usp_create_execution_plan]
    @p_project_id = @project_id,
    @p_plan_type = 'RECOVERY',
    @p_plan_name = 'Recovery path plan',
    @p_scope_description = 'Recovery, observed, and skipped functional test';
SELECT @recovery_plan_id = [id] FROM @ids;

DELETE FROM @ids;
INSERT INTO @ids EXEC [runtime].[usp_add_execution_plan_process] @recovery_plan_id, @product_category_process_id;
SELECT @recovery_category_epp_id = [id] FROM @ids;

DELETE FROM @ids;
INSERT INTO @ids EXEC [runtime].[usp_add_execution_plan_process] @recovery_plan_id, @product_process_id;
SELECT @recovery_product_epp_id = [id] FROM @ids;

DELETE FROM @ids;
INSERT INTO @ids EXEC [runtime].[usp_add_execution_plan_process] @recovery_plan_id, @sales_process_id;
SELECT @recovery_sales_epp_id = [id] FROM @ids;

DELETE FROM @ids;
INSERT INTO @ids EXEC [runtime].[usp_add_execution_plan_process] @recovery_plan_id, @optional_audit_process_id;
SELECT @recovery_optional_epp_id = [id] FROM @ids;

EXEC [runtime].[usp_evaluate_execution_plan_dependencies] @recovery_plan_id;

DELETE FROM @ids;
INSERT INTO @ids
EXEC [runtime].[usp_start_execution_run]
    @p_project_id = @project_id,
    @p_execution_plan_id = @recovery_plan_id;
SELECT @recovery_run_id = [id] FROM @ids;

DELETE FROM @ids;
INSERT INTO @ids EXEC [runtime].[usp_start_execution_step] @recovery_run_id, @optional_audit_process_id, @recovery_optional_epp_id;
SELECT @recovery_optional_step_id = [id] FROM @ids;
EXEC [runtime].[usp_end_execution_step] @recovery_optional_step_id, @status_skipped;

DELETE FROM @ids;
INSERT INTO @ids EXEC [runtime].[usp_start_execution_step] @recovery_run_id, @product_category_process_id, @recovery_category_epp_id;
SELECT @recovery_category_step_id = [id] FROM @ids;
EXEC [runtime].[usp_end_execution_step] @recovery_category_step_id, @status_success;

IF NOT EXISTS (SELECT 1 FROM [runtime].[execution_plan_processes] WHERE [id] = @recovery_product_epp_id AND [status_code_id] = @status_ready)
BEGIN
    ;THROW 52011, 'Recovery Product Load should become READY after ProductCategory Load succeeds.', 1;
END;

DELETE FROM @ids;
INSERT INTO @ids EXEC [runtime].[usp_start_execution_step] @recovery_run_id, @product_process_id, @recovery_product_epp_id;
SELECT @recovery_product_step_id = [id] FROM @ids;
EXEC [runtime].[usp_end_execution_step] @recovery_product_step_id, @status_success;

IF NOT EXISTS (SELECT 1 FROM [runtime].[execution_plan_processes] WHERE [id] = @recovery_sales_epp_id AND [status_code_id] = @status_ready)
BEGIN
    ;THROW 52012, 'Recovery Sales Load should become READY after Product Load succeeds.', 1;
END;

DELETE FROM @ids;
INSERT INTO @ids EXEC [runtime].[usp_start_execution_step] @recovery_run_id, @sales_process_id, @recovery_sales_epp_id;
SELECT @recovery_sales_step_id = [id] FROM @ids;

INSERT INTO [observability].[validation_results]
(
    [details],
    [affected_row_count],
    [execution_step_id],
    [validation_code_id]
)
VALUES
(
    'E2E warning evidence for observed recovery outcome.',
    1,
    @recovery_sales_step_id,
    6
);

EXEC [runtime].[usp_end_execution_step] @recovery_sales_step_id, @status_observed;

EXEC [runtime].[usp_end_execution_run] @recovery_run_id;
EXEC [runtime].[usp_close_execution_plan] @recovery_plan_id, 0;

IF NOT EXISTS (SELECT 1 FROM [runtime].[execution_steps] WHERE [id] = @recovery_optional_step_id AND [status_code_id] = @status_skipped)
BEGIN
    ;THROW 52013, 'Optional Audit Load step should be SKIPPED.', 1;
END;
IF NOT EXISTS (SELECT 1 FROM [runtime].[execution_plan_processes] WHERE [id] = @recovery_optional_epp_id AND [status_code_id] = @status_skipped)
BEGIN
    ;THROW 52014, 'Optional Audit Load plan process should be SKIPPED.', 1;
END;
IF NOT EXISTS (SELECT 1 FROM [runtime].[execution_runs] WHERE [id] = @recovery_run_id AND [status_code_id] = @status_observed AND [end_run_date] IS NOT NULL)
BEGIN
    ;THROW 52015, 'Recovery run should close as OBSERVED.', 1;
END;
IF NOT EXISTS (SELECT 1 FROM [runtime].[execution_plans] WHERE [id] = @recovery_plan_id AND [status_code_id] = @status_observed AND [end_plan_date] IS NOT NULL)
BEGIN
    ;THROW 52016, 'Recovery plan should close as OBSERVED.', 1;
END;

/* Cancellation plan */
DELETE FROM @ids;
INSERT INTO @ids
EXEC [runtime].[usp_create_execution_plan]
    @p_project_id = @project_id,
    @p_plan_type = 'MANUAL',
    @p_plan_name = 'Cancellation path plan',
    @p_scope_description = 'Cancellation functional test';
SELECT @cancel_plan_id = [id] FROM @ids;

DELETE FROM @ids;
INSERT INTO @ids EXEC [runtime].[usp_add_execution_plan_process] @cancel_plan_id, @optional_audit_process_id;
SELECT @cancel_process_epp_id = [id] FROM @ids;

EXEC [runtime].[usp_evaluate_execution_plan_dependencies] @cancel_plan_id;
EXEC [runtime].[usp_close_execution_plan] @cancel_plan_id, 1;

IF NOT EXISTS (SELECT 1 FROM [runtime].[execution_plans] WHERE [id] = @cancel_plan_id AND [status_code_id] = @status_cancelled AND [end_plan_date] IS NOT NULL)
BEGIN
    ;THROW 52017, 'Cancelled plan should close as CANCELLED.', 1;
END;
IF NOT EXISTS (SELECT 1 FROM [runtime].[execution_plan_processes] WHERE [id] = @cancel_process_epp_id AND [status_code_id] = @status_cancelled)
BEGIN
    ;THROW 52018, 'Remaining non-final plan process should be CANCELLED.', 1;
END;
IF EXISTS (SELECT 1 FROM [runtime].[execution_plan_processes] WHERE [execution_plan_id] = @cancel_plan_id AND [status_code_id] = @status_running)
BEGIN
    ;THROW 52019, 'Cancellation test should not leave RUNNING plan processes.', 1;
END;

IF EXISTS (SELECT 1 FROM [reference].[status_codes] WHERE [code] IN ('WAITING', 'REQUIRES_RERUN'))
BEGIN
    ;THROW 52020, 'WAITING or REQUIRES_RERUN should not exist in the current status model.', 1;
END;

IF NOT EXISTS (SELECT 1 FROM [runtime].[vw_execution_plan_summary] WHERE [execution_plan_id] IN (@failure_plan_id, @recovery_plan_id, @cancel_plan_id))
BEGIN
    ;THROW 52021, 'runtime.vw_execution_plan_summary did not return scenario plans.', 1;
END;
IF NOT EXISTS (SELECT 1 FROM [runtime].[vw_execution_plan_process_summary] WHERE [execution_plan_id] IN (@failure_plan_id, @recovery_plan_id, @cancel_plan_id))
BEGIN
    ;THROW 52022, 'runtime.vw_execution_plan_process_summary did not return scenario plan processes.', 1;
END;
IF NOT EXISTS (SELECT 1 FROM [runtime].[vw_execution_run_summary] WHERE [execution_run_id] IN (@failure_run_id, @recovery_run_id))
BEGIN
    ;THROW 52023, 'runtime.vw_execution_run_summary did not return scenario runs.', 1;
END;
IF NOT EXISTS (SELECT 1 FROM [runtime].[vw_execution_step_summary] WHERE [execution_run_id] IN (@failure_run_id, @recovery_run_id))
BEGIN
    ;THROW 52024, 'runtime.vw_execution_step_summary did not return scenario steps.', 1;
END;
IF NOT EXISTS (SELECT 1 FROM [runtime].[vw_execution_watermark_summary] WHERE [execution_watermark_id] = @failure_execution_watermark_id)
BEGIN
    ;THROW 52025, 'runtime.vw_execution_watermark_summary did not return failed watermark history.', 1;
END;
IF NOT EXISTS (SELECT 1 FROM [observability].[vw_execution_observability_summary] WHERE [execution_run_id] IN (@failure_run_id, @recovery_run_id))
BEGIN
    ;THROW 52026, 'observability.vw_execution_observability_summary did not return scenario runs.', 1;
END;

SELECT
    'TEST_CONTEXT' AS [result_type],
    @project_name AS [project_name],
    @project_id AS [project_id],
    @failure_plan_id AS [failure_plan_id],
    @recovery_plan_id AS [recovery_plan_id],
    @cancel_plan_id AS [cancel_plan_id],
    @failure_run_id AS [failure_run_id],
    @recovery_run_id AS [recovery_run_id],
    @sales_status_after_failure_code AS [sales_status_after_failure];

SELECT
    'PLAN_STATUS' AS [result_type],
    ep.[id] AS [execution_plan_id],
    ep.[plan_type],
    ep.[plan_name],
    sc.[code] AS [status_code]
FROM [runtime].[execution_plans] ep
INNER JOIN [reference].[status_codes] sc
    ON sc.[id] = ep.[status_code_id]
WHERE ep.[id] IN (@failure_plan_id, @recovery_plan_id, @cancel_plan_id)
ORDER BY ep.[id];

SELECT
    'RUN_STATUS' AS [result_type],
    er.[id] AS [execution_run_id],
    er.[execution_plan_id],
    sc.[code] AS [status_code]
FROM [runtime].[execution_runs] er
INNER JOIN [reference].[status_codes] sc
    ON sc.[id] = er.[status_code_id]
WHERE er.[id] IN (@failure_run_id, @recovery_run_id)
ORDER BY er.[id];

SELECT
    'PLAN_PROCESS_STATUS' AS [result_type],
    epp.[execution_plan_id],
    pp.[name] AS [process_name],
    sc.[code] AS [status_code],
    epp.[dependency_evaluation_details]
FROM [runtime].[execution_plan_processes] epp
INNER JOIN [metadata].[project_processes] pp
    ON pp.[id] = epp.[project_process_id]
INNER JOIN [reference].[status_codes] sc
    ON sc.[id] = epp.[status_code_id]
WHERE epp.[execution_plan_id] IN (@failure_plan_id, @recovery_plan_id, @cancel_plan_id)
ORDER BY epp.[execution_plan_id], pp.[name];

SELECT
    'STEP_STATUS' AS [result_type],
    es.[execution_run_id],
    pp.[name] AS [process_name],
    sc.[code] AS [status_code]
FROM [runtime].[execution_steps] es
INNER JOIN [metadata].[project_processes] pp
    ON pp.[id] = es.[project_process_id]
INNER JOIN [reference].[status_codes] sc
    ON sc.[id] = es.[status_code_id]
WHERE es.[execution_run_id] IN (@failure_run_id, @recovery_run_id)
ORDER BY es.[execution_run_id], es.[id];

SELECT
    'WATERMARK_NON_COMMIT' AS [result_type],
    CAST(ewc.[last_committed_watermark_value] AS NVARCHAR(100)) AS [control_committed_value],
    CAST(ew.[candidate_watermark_value] AS NVARCHAR(100)) AS [candidate_value],
    CAST(ew.[committed_watermark_value] AS NVARCHAR(100)) AS [history_committed_value],
    sc.[code] AS [history_status_code]
FROM [runtime].[execution_watermark_controls] ewc
INNER JOIN [runtime].[execution_watermarks] ew
    ON ew.[execution_watermark_control_id] = ewc.[id]
INNER JOIN [reference].[status_codes] sc
    ON sc.[id] = ew.[status_code_id]
WHERE ew.[id] = @failure_execution_watermark_id;

SELECT
    'VIEW_COUNTS' AS [result_type],
    (SELECT COUNT(*) FROM [runtime].[vw_execution_plan_summary] WHERE [execution_plan_id] IN (@failure_plan_id, @recovery_plan_id, @cancel_plan_id)) AS [plan_summary_count],
    (SELECT COUNT(*) FROM [runtime].[vw_execution_plan_process_summary] WHERE [execution_plan_id] IN (@failure_plan_id, @recovery_plan_id, @cancel_plan_id)) AS [plan_process_summary_count],
    (SELECT COUNT(*) FROM [runtime].[vw_execution_run_summary] WHERE [execution_run_id] IN (@failure_run_id, @recovery_run_id)) AS [run_summary_count],
    (SELECT COUNT(*) FROM [runtime].[vw_execution_step_summary] WHERE [execution_run_id] IN (@failure_run_id, @recovery_run_id)) AS [step_summary_count],
    (SELECT COUNT(*) FROM [runtime].[vw_execution_watermark_summary] WHERE [execution_watermark_id] = @failure_execution_watermark_id) AS [watermark_summary_count],
    (SELECT COUNT(*) FROM [observability].[vw_execution_observability_summary] WHERE [execution_run_id] IN (@failure_run_id, @recovery_run_id)) AS [observability_summary_count];

SELECT
    'FORBIDDEN_STATUS_COUNT' AS [result_type],
    COUNT(*) AS [forbidden_status_count]
FROM [reference].[status_codes]
WHERE [code] IN ('WAITING', 'REQUIRES_RERUN');

SELECT 'TEST_RESULT' AS [result_type], 'PASS' AS [result_value];
GO
