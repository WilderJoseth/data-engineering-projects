USE [DataOps_Control];
GO

/* 
    Test Script: Batch Data Flow

    Goal:
    - Simulate a batch-enabled table flow.
    - Get batch execution scope from metadata.ufn_list_project_process_table_batches.
    - Run only batches marked as execution_required = 1.
    - Start one execution step per batch.
    - Register reconciliation and validation results.
    - End each batch execution step.
    - End the execution run and validate final status.

    Test scope:
    - Parent process:
        PKG_TRANSACTIONAL_DATA

    - Child process:
        Sales Load

    - Target table:
        SalesOrderHeader

    - Batch source table:
        SALES_SALESORDERHEADER

    Expected result:
    - Batch 2011-05 = Success
    - Batch 2011-06 = Observed
    - Execution Run = Observed
*/

DECLARE @project_id SMALLINT = 1;
DECLARE @parent_process_id INT = 6; -- PKG_TRANSACTIONAL_DATA

DECLARE @status_success SMALLINT = 3;
DECLARE @status_observed SMALLINT = 6;

DECLARE @execution_run_id INT;

DECLARE @SalesOrderHeaderProcessId INT;

DECLARE @run_SalesOrderHeader_load INT = 0;
DECLARE @run_Batch_2011_05 INT = 0;
DECLARE @run_Batch_2011_06 INT = 0;

DECLARE @Batch201105Id INT;
DECLARE @Batch201106Id INT;

DECLARE @Batch201105Value VARCHAR(50);
DECLARE @Batch201106Value VARCHAR(50);

-------------------------------------------------------------------------
-- 1. Test setup
--
-- This section simulates metadata configuration before the ETL starts.
--
-- execution_required = 1 means the orchestration layer should execute
-- that table or batch.
--
-- For this test:
-- - SalesOrderHeader requires execution.
-- - Two batches require execution: 2011-05 and 2011-06.
-------------------------------------------------------------------------

UPDATE [metadata].[project_tables]
SET [execution_required] = 0;

UPDATE [metadata].[project_table_batches]
SET [execution_required] = 0;

UPDATE [metadata].[project_tables]
SET [execution_required] = 1
WHERE [id] = 33; -- SalesOrderHeader target table

UPDATE [metadata].[project_table_batches]
SET [execution_required] = 1
WHERE [batch_value] IN
(
    '2011-05',
    '2011-06'
)
AND [batch_source_table_id] = 17; -- SALES_SALESORDERHEADER source table

-------------------------------------------------------------------------
-- 2. Get batch execution scope
--
-- This function returns:
-- - parent process
-- - child process
-- - target table
-- - source table used for batch filtering
-- - batch definition
--
-- In SSIS, this metadata result would be used to decide whether the batch
-- container or Foreach iteration should run.
-------------------------------------------------------------------------

DECLARE @batch_scope TABLE
(
    process_id INT,
    process_name VARCHAR(50),
    process_child_id INT,
    process_child_name VARCHAR(50),

    target_table_id INT,
    target_table_schema_name VARCHAR(50),
    target_table_name VARCHAR(50),
    target_table_execution_required BIT,

    batch_source_table_id INT,
    batch_source_schema_name VARCHAR(50),
    batch_source_table_name VARCHAR(50),

    batch_id INT,
    batch_column_name VARCHAR(50),
    batch_value VARCHAR(50),
    batch_start_value VARCHAR(50),
    batch_end_value VARCHAR(50),
    batch_column_type VARCHAR(20),
    batch_execution_required BIT
);

INSERT INTO @batch_scope
(
    process_id,
    process_name,
    process_child_id,
    process_child_name,

    target_table_id,
    target_table_schema_name,
    target_table_name,
    target_table_execution_required,

    batch_source_table_id,
    batch_source_schema_name,
    batch_source_table_name,

    batch_id,
    batch_column_name,
    batch_value,
    batch_start_value,
    batch_end_value,
    batch_column_type,
    batch_execution_required
)
SELECT
    process_id,
    process_name,
    process_child_id,
    process_child_name,

    target_table_id,
    target_table_schema_name,
    target_table_name,
    target_table_execution_required,

    batch_source_table_id,
    batch_source_schema_name,
    batch_source_table_name,

    batch_id,
    batch_column_name,
    batch_value,
    batch_start_value,
    batch_end_value,
    batch_column_type,
    batch_execution_required
FROM [metadata].[ufn_list_project_process_table_batches]
(
    @project_id,
    @parent_process_id
);

-- Review the full batch execution scope returned by the function.
SELECT *
FROM @batch_scope
ORDER BY target_table_name, batch_start_value;

-------------------------------------------------------------------------
-- 3. Resolve run flags and process IDs
--
-- This simulates the SSIS Execute SQL Task that loads package variables.
--
-- Example:
--   run_SalesOrderHeader_load = 1 -> SalesOrderHeader batch flow should run.
--   run_Batch_2011_05 = 1         -> Batch 2011-05 should run.
--   run_Batch_2011_06 = 1         -> Batch 2011-06 should run.
-------------------------------------------------------------------------

SELECT
    @run_SalesOrderHeader_load =
        MAX(IIF(
            [target_table_id] = 33
            AND [target_table_execution_required] = 1
            AND [batch_execution_required] = 1,
            1,
            0
        )),

    @SalesOrderHeaderProcessId =
        MAX(IIF(
            [target_table_id] = 33
            AND [target_table_execution_required] = 1
            AND [batch_execution_required] = 1,
            [process_child_id],
            NULL
        )),

    @run_Batch_2011_05 =
        MAX(IIF(
            [target_table_id] = 33
            AND [batch_value] = '2011-05'
            AND [batch_execution_required] = 1,
            1,
            0
        )),

    @Batch201105Id =
        MAX(IIF([batch_value] = '2011-05', [batch_id], NULL)),

    @Batch201105Value =
        MAX(IIF([batch_value] = '2011-05', [batch_value], NULL)),

    @run_Batch_2011_06 =
        MAX(IIF(
            [target_table_id] = 33
            AND [batch_value] = '2011-06'
            AND [batch_execution_required] = 1,
            1,
            0
        )),

    @Batch201106Id =
        MAX(IIF([batch_value] = '2011-06', [batch_id], NULL)),

    @Batch201106Value =
        MAX(IIF([batch_value] = '2011-06', [batch_value], NULL))
FROM @batch_scope;

-- Review the flags that would normally be mapped to SSIS variables.
SELECT
    @run_SalesOrderHeader_load AS [run_SalesOrderHeader_load],
    @SalesOrderHeaderProcessId AS [SalesOrderHeaderProcessId],

    @run_Batch_2011_05 AS [run_Batch_2011_05],
    @Batch201105Id AS [Batch201105Id],
    @Batch201105Value AS [Batch201105Value],

    @run_Batch_2011_06 AS [run_Batch_2011_06],
    @Batch201106Id AS [Batch201106Id],
    @Batch201106Value AS [Batch201106Value];

-------------------------------------------------------------------------
-- 4. Start execution run
--
-- This represents the start of the transactional data execution.
--
-- runtime.usp_start_execution_run inserts a row into:
--   runtime.execution_runs
--
-- and returns:
--   execution_run_id
-------------------------------------------------------------------------

DECLARE @execution_run_output TABLE
(
    execution_run_id INT
);

INSERT INTO @execution_run_output
EXEC [runtime].[usp_start_execution_run]
    @p_project_id = @project_id;

SELECT @execution_run_id = [execution_run_id]
FROM @execution_run_output;

-------------------------------------------------------------------------
-- 5. SalesOrderHeader batch flow
--
-- In SSIS, this could be implemented as:
-- - A SalesOrderHeader Load container controlled by run_SalesOrderHeader_load.
-- - Inside it, a Foreach Loop or batch container per batch.
--
-- Current runtime model:
-- - One execution step is created per batch.
-- - The batch identifier is stored in reconciliation_key.
--
-- Note:
-- - runtime.execution_steps does not currently store batch_id directly.
-- - This is acceptable for this test because batch context is registered
--   in observability.reconciliation_results.
-------------------------------------------------------------------------

IF @run_SalesOrderHeader_load = 1
BEGIN
    ---------------------------------------------------------------------
    -- 5.1 Batch 2011-05 - Success
    --
    -- Flow:
    --   1. Check batch flag.
    --   2. Start execution step.
    --   3. Simulate batch load.
    --   4. Register reconciliation results.
    --   5. End execution step as Success.
    ---------------------------------------------------------------------

    IF @run_Batch_2011_05 = 1
    BEGIN
        DECLARE @Batch201105Step TABLE (execution_step_id BIGINT);
        DECLARE @Batch201105StepId BIGINT;

        -----------------------------------------------------------------
        -- Start execution step for SalesOrderHeader Batch 2011-05.
        -----------------------------------------------------------------

        INSERT INTO @Batch201105Step
        EXEC [runtime].[usp_start_execution_step]
            @p_execution_run_id = @execution_run_id,
            @p_project_process_id = @SalesOrderHeaderProcessId;

        SELECT @Batch201105StepId = [execution_step_id]
        FROM @Batch201105Step;

        -----------------------------------------------------------------
        -- Register reconciliation results.
        --
        -- This evidence shows that source and target match for the batch.
        -----------------------------------------------------------------

        INSERT INTO [observability].[reconciliation_results]
        (
            [metric_name],
            [reconciliation_key],
            [reconciliation_side],
            [metric_value_bigint],
            [execution_step_id]
        )
        VALUES
            ('ROW_COUNT', CONCAT('TABLE=SalesOrderHeader;BATCH=', @Batch201105Value), 'SOURCE', 436, @Batch201105StepId),
            ('ROW_COUNT', CONCAT('TABLE=SalesOrderHeader;BATCH=', @Batch201105Value), 'TARGET', 436, @Batch201105StepId);

        INSERT INTO [observability].[reconciliation_results]
        (
            [metric_name],
            [reconciliation_key],
            [reconciliation_side],
            [metric_value_decimal],
            [execution_step_id]
        )
        VALUES
            ('TOTAL_DUE', CONCAT('TABLE=SalesOrderHeader;BATCH=', @Batch201105Value), 'SOURCE', 815233.4200, @Batch201105StepId),
            ('TOTAL_DUE', CONCAT('TABLE=SalesOrderHeader;BATCH=', @Batch201105Value), 'TARGET', 815233.4200, @Batch201105StepId);

        -----------------------------------------------------------------
        -- End execution step as Success.
        -----------------------------------------------------------------

        EXEC [runtime].[usp_end_execution_step]
            @p_execution_step_id = @Batch201105StepId,
            @p_status_code_id = @status_success;
    END;

    ---------------------------------------------------------------------
    -- 5.2 Batch 2011-06 - Observed
    --
    -- Scenario:
    -- - Source has 500 rows.
    -- - Target has 498 rows.
    -- - Validation explains why 2 source rows were excluded.
    ---------------------------------------------------------------------

    IF @run_Batch_2011_06 = 1
    BEGIN
        DECLARE @Batch201106Step TABLE (execution_step_id BIGINT);
        DECLARE @Batch201106StepId BIGINT;

        -----------------------------------------------------------------
        -- Start execution step for SalesOrderHeader Batch 2011-06.
        -----------------------------------------------------------------

        INSERT INTO @Batch201106Step
        EXEC [runtime].[usp_start_execution_step]
            @p_execution_run_id = @execution_run_id,
            @p_project_process_id = @SalesOrderHeaderProcessId;

        SELECT @Batch201106StepId = [execution_step_id]
        FROM @Batch201106Step;

        -----------------------------------------------------------------
        -- Register reconciliation results.
        --
        -- This evidence shows the target has two rows less than the source.
        -----------------------------------------------------------------

        INSERT INTO [observability].[reconciliation_results]
        (
            [metric_name],
            [reconciliation_key],
            [reconciliation_side],
            [metric_value_bigint],
            [execution_step_id]
        )
        VALUES
            ('ROW_COUNT', CONCAT('TABLE=SalesOrderHeader;BATCH=', @Batch201106Value), 'SOURCE', 500, @Batch201106StepId),
            ('ROW_COUNT', CONCAT('TABLE=SalesOrderHeader;BATCH=', @Batch201106Value), 'TARGET', 498, @Batch201106StepId);

        -----------------------------------------------------------------
        -- Register validation result.
        --
        -- This explains why the target has fewer rows.
        -- DataOps_Control stores the validation summary, not the rejected
        -- business rows themselves.
        -----------------------------------------------------------------

        INSERT INTO [observability].[validation_results]
        (
            [details],
            [affected_row_count],
            [execution_step_id],
            [validation_code_id]
        )
        VALUES
        (
            CONCAT('2 source rows were excluded from SalesOrderHeader batch ', @Batch201106Value, ' because required customer references were not found.'),
            2,
            @Batch201106StepId,
            3 -- FK_CHECK
        );

        -----------------------------------------------------------------
        -- End execution step as Observed.
        --
        -- This is not a technical failure. The batch completed, but the
        -- validation/reconciliation evidence requires review.
        -----------------------------------------------------------------

        EXEC [runtime].[usp_end_execution_step]
            @p_execution_step_id = @Batch201106StepId,
            @p_status_code_id = @status_observed;
    END;
END;

-------------------------------------------------------------------------
-- 6. End execution run
--
-- runtime.usp_end_execution_run derives the final run status from all
-- related execution steps.
--
-- Expected result:
--   Observed
--
-- Reason:
--   Batch 2011-06 ended as Observed.
-------------------------------------------------------------------------

EXEC [runtime].[usp_end_execution_run]
    @p_execution_run_id = @execution_run_id;

-------------------------------------------------------------------------
-- 7. Review execution run result
--
-- Expected:
--   run_status = Observed
-------------------------------------------------------------------------

SELECT
    er.[id] AS [execution_run_id],
    rs.[code] AS [run_status],
    er.[start_run_date],
    er.[end_run_date]
FROM [runtime].[execution_runs] er
INNER JOIN [reference].[status_codes] rs
    ON rs.[id] = er.[status_code_id]
WHERE er.[id] = @execution_run_id;

-------------------------------------------------------------------------
-- 8. Review execution step results
--
-- Expected:
--   Sales Load = Success
--   Sales Load = Observed
--
-- Note:
-- - Both steps reference the same process because both are batch executions
--   of the Sales Load process.
-- - Batch context is visible through reconciliation_key.
-------------------------------------------------------------------------

SELECT
    es.[id] AS [execution_step_id],
    pp.[name] AS [process_name],
    ss.[code] AS [step_status],
    es.[start_run_date],
    es.[end_run_date]
FROM [runtime].[execution_steps] es
INNER JOIN [metadata].[project_processes] pp
    ON pp.[id] = es.[project_process_id]
INNER JOIN [reference].[status_codes] ss
    ON ss.[id] = es.[status_code_id]
WHERE es.[execution_run_id] = @execution_run_id
ORDER BY es.[id];

-------------------------------------------------------------------------
-- 9. Review reconciliation results
--
-- This query shows the row-count and amount evidence registered for each
-- batch execution step.
-------------------------------------------------------------------------

SELECT
    rr.[execution_step_id],
    pp.[name] AS [process_name],
    rr.[metric_name],
    rr.[reconciliation_key],
    rr.[reconciliation_side],
    rr.[metric_value_bigint],
    rr.[metric_value_decimal]
FROM [observability].[reconciliation_results] rr
INNER JOIN [runtime].[execution_steps] es
    ON es.[id] = rr.[execution_step_id]
INNER JOIN [metadata].[project_processes] pp
    ON pp.[id] = es.[project_process_id]
WHERE es.[execution_run_id] = @execution_run_id
ORDER BY
    rr.[execution_step_id],
    rr.[metric_name],
    rr.[reconciliation_key],
    rr.[reconciliation_side];

-------------------------------------------------------------------------
-- 10. Review validation results
--
-- Expected:
-- - Batch 2011-06 has one FK_CHECK validation result.
-------------------------------------------------------------------------

SELECT
    vr.[execution_step_id],
    pp.[name] AS [process_name],
    vc.[code] AS [validation_code],
    vc.[severity],
    vr.[affected_row_count],
    vr.[details]
FROM [observability].[validation_results] vr
INNER JOIN [runtime].[execution_steps] es
    ON es.[id] = vr.[execution_step_id]
INNER JOIN [metadata].[project_processes] pp
    ON pp.[id] = es.[project_process_id]
INNER JOIN [reference].[validation_codes] vc
    ON vc.[id] = vr.[validation_code_id]
WHERE es.[execution_run_id] = @execution_run_id
ORDER BY
    vr.[execution_step_id],
    vc.[code];