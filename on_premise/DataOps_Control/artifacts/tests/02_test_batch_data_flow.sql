USE [DataOps_Control];
GO

/* 
    Test Script: Batch Data Flow

    Goal:
    - Simulate a batch-enabled table flow using explicit process-table-batch scope.
    - Get batch execution scope from metadata.ufn_list_project_process_table_batches.
    - Run only target tables and batches marked as execution_required = 1.
    - Start one execution step per process-table-batch item.
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
    - SalesOrderHeader / Batch 2011-05 = Success
    - SalesOrderHeader / Batch 2011-06 = Observed
    - Execution Run = Observed

    Design note:
    - metadata.project_process_table_batches defines which batches are assigned
      to each process-table execution scope.
    - runtime.execution_steps remains process-based.
    - Table and batch context is visible through metadata scope and
      observability.reconciliation_key.
*/

DECLARE @project_id SMALLINT = 1;
DECLARE @parent_process_id INT = 6; -- PKG_TRANSACTIONAL_DATA

DECLARE @status_success SMALLINT = 3;
DECLARE @status_observed SMALLINT = 6;

DECLARE @execution_run_id INT;

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
-- - Batch assignments are controlled by:
--     metadata.project_process_table_batches
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
-- The function should now resolve batch scope through:
--
-- metadata.project_processes
--     -> metadata.project_process_tables
--         -> metadata.project_process_table_batches
--             -> metadata.project_table_batches
--
-- In SSIS, this metadata result would be used by a Foreach Loop or
-- equivalent orchestration pattern.
-------------------------------------------------------------------------

DECLARE @batch_scope TABLE
(
    row_id INT IDENTITY(1,1) PRIMARY KEY,
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
)
WHERE [target_table_execution_required] = 1
AND [batch_execution_required] = 1
AND [target_table_name] = 'SalesOrderHeader';

-- Review the batch execution scope returned by the function.
SELECT *
FROM @batch_scope
ORDER BY
    target_table_name,
    batch_start_value;

IF NOT EXISTS (SELECT 1 FROM @batch_scope)
BEGIN
    THROW 51000, 'No batch execution scope was found. Validate metadata.project_process_table_batches and execution_required flags.', 1;
END;

-------------------------------------------------------------------------
-- 3. Start execution run
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
-- 4. Execute process-table-batch scope
--
-- This loop simulates an orchestration tool iterating over batch metadata.
--
-- Current runtime model:
-- - One execution step is created per process-table-batch item.
-- - The execution step references the process.
-- - The table and batch context is registered in reconciliation_key.
--
-- Note:
-- - runtime.execution_steps does not store table_id or batch_id directly.
-- - The process-table-batch scope comes from metadata.
-- - Observability records keep the execution evidence for each table/batch.
-------------------------------------------------------------------------

DECLARE
    @current_row_id INT = 1,
    @max_row_id INT,
    @current_process_child_id INT,
    @current_process_child_name VARCHAR(50),
    @current_target_table_id INT,
    @current_target_table_name VARCHAR(50),
    @current_batch_id INT,
    @current_batch_value VARCHAR(50),
    @current_execution_step_id BIGINT,
    @current_status_code_id SMALLINT,
    @source_row_count BIGINT,
    @target_row_count BIGINT,
    @source_amount DECIMAL(18,4),
    @target_amount DECIMAL(18,4),
    @reconciliation_key VARCHAR(200);
SELECT @max_row_id = MAX(row_id)
FROM @batch_scope;

WHILE @current_row_id <= @max_row_id
BEGIN
    SELECT
        @current_process_child_id = [process_child_id],
        @current_process_child_name = [process_child_name],
        @current_target_table_id = [target_table_id],
        @current_target_table_name = [target_table_name],
        @current_batch_id = [batch_id],
        @current_batch_value = [batch_value]
    FROM @batch_scope
    WHERE [row_id] = @current_row_id;

    SET @reconciliation_key = CONCAT('TABLE=', @current_target_table_name, ';BATCH=', @current_batch_value);

    ---------------------------------------------------------------------
    -- 4.1 Start execution step.
    ---------------------------------------------------------------------

    DECLARE @execution_step_output TABLE
    (
        execution_step_id BIGINT
    );

    INSERT INTO @execution_step_output
    EXEC [runtime].[usp_start_execution_step]
        @p_execution_run_id = @execution_run_id,
        @p_project_process_id = @current_process_child_id;

    SELECT @current_execution_step_id = [execution_step_id]
    FROM @execution_step_output;

    ---------------------------------------------------------------------
    -- 4.2 Simulate batch-level reconciliation values.
    --
    -- These values represent test evidence only. In a real project, they
    -- would come from source/target queries or project-specific procedures.
    ---------------------------------------------------------------------

    SET @current_status_code_id = @status_success;
    SET @source_row_count = NULL;
    SET @target_row_count = NULL;
    SET @source_amount = NULL;
    SET @target_amount = NULL;

    IF @current_target_table_name = 'SalesOrderHeader'
       AND @current_batch_value = '2011-05'
    BEGIN
        SET @source_row_count = 436;
        SET @target_row_count = 436;
        SET @source_amount = 815233.4200;
        SET @target_amount = 815233.4200;
    END;

    IF @current_target_table_name = 'SalesOrderHeader'
       AND @current_batch_value = '2011-06'
    BEGIN
        SET @source_row_count = 500;
        SET @target_row_count = 498;
        SET @source_amount = 950120.0000;
        SET @target_amount = 947650.0000;
        SET @current_status_code_id = @status_observed;
    END;
    ---------------------------------------------------------------------
    -- 4.3 Register row-count reconciliation results.
    ---------------------------------------------------------------------

    INSERT INTO [observability].[reconciliation_results]
    (
        [metric_name],
        [reconciliation_key],
        [reconciliation_side],
        [metric_value_bigint],
        [execution_step_id]
    )
    VALUES
        ('ROW_COUNT', @reconciliation_key, 'SOURCE', @source_row_count, @current_execution_step_id),
        ('ROW_COUNT', @reconciliation_key, 'TARGET', @target_row_count, @current_execution_step_id);

    ---------------------------------------------------------------------
    -- 4.4 Register amount reconciliation results when applicable.
    ---------------------------------------------------------------------

    IF @source_amount IS NOT NULL
    BEGIN
        INSERT INTO [observability].[reconciliation_results]
        (
            [metric_name],
            [reconciliation_key],
            [reconciliation_side],
            [metric_value_decimal],
            [execution_step_id]
        )
        VALUES
            ('TOTAL_DUE', @reconciliation_key, 'SOURCE', @source_amount, @current_execution_step_id),
            ('TOTAL_DUE', @reconciliation_key, 'TARGET', @target_amount, @current_execution_step_id);
    END;

    ---------------------------------------------------------------------
    -- 4.5 Register validation result for the observed batch.
    --
    -- This is not a technical failure. The batch completed, but the
    -- validation/reconciliation evidence requires review.
    ---------------------------------------------------------------------

    IF @current_target_table_name = 'SalesOrderHeader'
       AND @current_batch_value = '2011-06'
    BEGIN
        INSERT INTO [observability].[validation_results]
        (
            [details],
            [affected_row_count],
            [execution_step_id],
            [validation_code_id]
        )
        VALUES
        (
            CONCAT('2 source rows were excluded from ', @current_target_table_name, ' batch ', @current_batch_value, ' because required customer references were not found.'),
            2,
            @current_execution_step_id,
            3 -- FK_CHECK
        );
    END;

    ---------------------------------------------------------------------
    -- 4.6 End execution step.
    ---------------------------------------------------------------------

    EXEC [runtime].[usp_end_execution_step]
        @p_execution_step_id = @current_execution_step_id,
        @p_status_code_id = @current_status_code_id;

    SET @current_row_id += 1;
END;

-------------------------------------------------------------------------
-- 5. End execution run
--
-- runtime.usp_end_execution_run derives the final run status from all
-- related execution steps.
--
-- Expected result:
--   Observed
--
-- Reason:
--   SalesOrderHeader / Batch 2011-06 ended as Observed.
-------------------------------------------------------------------------

EXEC [runtime].[usp_end_execution_run]
    @p_execution_run_id = @execution_run_id;

-------------------------------------------------------------------------
-- 6. Review execution run result
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
-- 7. Review execution step results
--
-- Expected:
--   Two execution steps:
--   - SalesOrderHeader / 2011-05 = Success
--   - SalesOrderHeader / 2011-06 = Observed
--
-- Note:
-- - All steps reference the Sales Load process.
-- - Table and batch context is visible through reconciliation_key.
-------------------------------------------------------------------------

SELECT
    es.[id] AS [execution_step_id],
    pp.[name] AS [process_name],
    ss.[code] AS [step_status],
    es.[start_step_date],
    es.[end_step_date]
FROM [runtime].[execution_steps] es
INNER JOIN [metadata].[project_processes] pp
    ON pp.[id] = es.[project_process_id]
INNER JOIN [reference].[status_codes] ss
    ON ss.[id] = es.[status_code_id]
WHERE es.[execution_run_id] = @execution_run_id
ORDER BY es.[id];

-------------------------------------------------------------------------
-- 8. Review reconciliation results
--
-- This query shows the row-count and amount evidence registered for each
-- SalesOrderHeader batch execution step.
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
-- 9. Review validation results
--
-- Expected:
-- - SalesOrderHeader / Batch 2011-06 has one FK_CHECK validation result.
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

-------------------------------------------------------------------------
-- 10. Review metadata scope used by the test
--
-- This confirms that the SalesOrderHeader target table and its batches were
-- selected through the process-table-batch execution scope.
-------------------------------------------------------------------------

SELECT
    [process_child_name],
    [target_table_name],
    [batch_source_table_name],
    [batch_value],
    [target_table_execution_required],
    [batch_execution_required]
FROM @batch_scope
ORDER BY
    [process_child_name],
    [target_table_name],
    [batch_value];
GO
