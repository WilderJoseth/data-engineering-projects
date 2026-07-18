USE [DataOps_Control];
GO

/* 
    Test Script: Table Flow + Grouped Table Flow

    Goal:
    - Simulate the way SSIS will use DataOps_Control metadata.
    - Get execution flags from metadata.ufn_list_project_process_tables.
    - Run only tables marked as execution_required = 1.
    - Start and end execution steps.
    - Register reconciliation and validation results.
    - End the execution run and validate final status.

    Test scope:
    - Simple table flow:
        AddressType
        ProductCategory

    - Grouped table flow:
        Geography Load
            CountryRegion
            StateProvince
            SalesTerritory

    Expected result:
    - AddressType       = Success
    - ProductCategory   = Success
    - CountryRegion     = Success
    - StateProvince     = Observed
    - SalesTerritory    = Success
    - Execution Run     = Observed
*/

DECLARE @project_id SMALLINT = 1;
DECLARE @parent_process_id INT = 4; -- Reference Data Load / PKG_REFERENCE_DATA
DECLARE @batch_column_active BIT = 0;

DECLARE @status_success SMALLINT = 3;
DECLARE @status_observed SMALLINT = 6;

DECLARE @execution_run_id INT;

DECLARE @AddressTypeProcessId INT;
DECLARE @ProductCategoryProcessId INT;
DECLARE @CountryRegionProcessId INT;
DECLARE @StateProvinceProcessId INT;
DECLARE @SalesTerritoryProcessId INT;

DECLARE @run_AddressType_load INT = 0;
DECLARE @run_ProductCategory_load INT = 0;
DECLARE @run_Geography_load INT = 0;
DECLARE @run_CountryRegion_load INT = 0;
DECLARE @run_StateProvince_load INT = 0;
DECLARE @run_SalesTerritory_load INT = 0;

-------------------------------------------------------------------------
-- 1. Test setup
--
-- This section simulates metadata configuration before the ETL starts.
--
-- execution_required = 1 means the orchestration layer should execute
-- that table load.
--
-- execution_required = 0 means the table is part of the model, but it
-- should not run in this test.
-------------------------------------------------------------------------

UPDATE [metadata].[project_tables]
SET [execution_required] = 0;

UPDATE [metadata].[project_tables]
SET [execution_required] = 1
WHERE [id] IN
(
    19, -- AddressType
    20, -- ProductCategory
    23, -- CountryRegion
    24, -- StateProvince
    25  -- SalesTerritory
);

-------------------------------------------------------------------------
-- 2. Get process/table execution scope
--
-- This function returns the child processes and controlled tables that
-- belong to the parent process.
--
-- In SSIS, this metadata result would be used to decide which containers
-- should run.
-------------------------------------------------------------------------

DECLARE @process_tables TABLE
(
    process_id INT,
    process_name VARCHAR(50),
    process_child_id INT,
    process_child_name VARCHAR(50),
    table_id INT,
    table_schema_name VARCHAR(50),
    table_name VARCHAR(50),
    execution_required BIT
);

INSERT INTO @process_tables
(
    process_id,
    process_name,
    process_child_id,
    process_child_name,
    table_id,
    table_schema_name,
    table_name,
    execution_required
)
SELECT
    process_id,
    process_name,
    process_child_id,
    process_child_name,
    table_id,
    table_schema_name,
    table_name,
    execution_required
FROM [metadata].[ufn_list_project_process_tables]
(
    @project_id,
    @parent_process_id,
    @batch_column_active
);

-- Review the full metadata execution scope returned by the function.
SELECT *
FROM @process_tables
ORDER BY process_child_name, table_name;

-------------------------------------------------------------------------
-- 3. Resolve run flags and process IDs
--
-- This simulates the SSIS Execute SQL Task that loads package variables.
--
-- Example:
--   run_AddressType_load = 1  -> AddressType container should run.
--   run_AddressType_load = 0  -> AddressType container should be skipped.
--
-- The process IDs are also taken from the same metadata result, so each
-- execution step can be registered against the correct project process.
-------------------------------------------------------------------------

SELECT
    @run_AddressType_load =
        MAX(IIF([table_id] = 19 AND [execution_required] = 1, 1, 0)),
    @AddressTypeProcessId =
        MAX(IIF([table_id] = 19 AND [execution_required] = 1, [process_child_id], NULL)),

    @run_ProductCategory_load =
        MAX(IIF([table_id] = 20 AND [execution_required] = 1, 1, 0)),
    @ProductCategoryProcessId =
        MAX(IIF([table_id] = 20 AND [execution_required] = 1, [process_child_id], NULL)),

    -- Parent/group flag. Geography container should run if any Geography
    -- child table requires execution.
    @run_Geography_load =
        MAX(IIF([table_id] IN (23, 24, 25) AND [execution_required] = 1, 1, 0)),

    @run_CountryRegion_load =
        MAX(IIF([table_id] = 23 AND [execution_required] = 1, 1, 0)),
    @CountryRegionProcessId =
        MAX(IIF([table_id] = 23 AND [execution_required] = 1, [process_child_id], NULL)),

    @run_StateProvince_load =
        MAX(IIF([table_id] = 24 AND [execution_required] = 1, 1, 0)),
    @StateProvinceProcessId =
        MAX(IIF([table_id] = 24 AND [execution_required] = 1, [process_child_id], NULL)),

    @run_SalesTerritory_load =
        MAX(IIF([table_id] = 25 AND [execution_required] = 1, 1, 0)),
    @SalesTerritoryProcessId =
        MAX(IIF([table_id] = 25 AND [execution_required] = 1, [process_child_id], NULL))
FROM @process_tables;

-- Review the flags that would normally be mapped to SSIS variables.
SELECT
    @run_AddressType_load AS [run_AddressType_load],
    @AddressTypeProcessId AS [AddressTypeProcessId],

    @run_ProductCategory_load AS [run_ProductCategory_load],
    @ProductCategoryProcessId AS [ProductCategoryProcessId],

    @run_Geography_load AS [run_Geography_load],

    @run_CountryRegion_load AS [run_CountryRegion_load],
    @CountryRegionProcessId AS [CountryRegionProcessId],

    @run_StateProvince_load AS [run_StateProvince_load],
    @StateProvinceProcessId AS [StateProvinceProcessId],

    @run_SalesTerritory_load AS [run_SalesTerritory_load],
    @SalesTerritoryProcessId AS [SalesTerritoryProcessId];

-------------------------------------------------------------------------
-- 4. Start execution run
--
-- This represents the start of the whole parent execution.
--
-- Example:
--   Reference Data Load execution starts.
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
-- 5. AddressType Load - Success
--
-- This block simulates one SSIS Sequence Container:
--   AddressType Load
--
-- Flow:
--   1. Check run flag.
--   2. Start execution step.
--   3. Simulate table load.
--   4. Register reconciliation results.
--   5. End execution step as Success.
-------------------------------------------------------------------------

IF @run_AddressType_load = 1
BEGIN
    DECLARE @AddressTypeStep TABLE (execution_step_id BIGINT);
    DECLARE @AddressTypeStepId BIGINT;

    ---------------------------------------------------------------------
    -- Start execution step
    --
    -- This creates a row in runtime.execution_steps for AddressType Load.
    -- The returned execution_step_id will be used by observability tables.
    ---------------------------------------------------------------------

    INSERT INTO @AddressTypeStep
    EXEC [runtime].[usp_start_execution_step]
        @p_execution_run_id = @execution_run_id,
        @p_project_process_id = @AddressTypeProcessId;

    SELECT @AddressTypeStepId = [execution_step_id]
    FROM @AddressTypeStep;

    ---------------------------------------------------------------------
    -- Register reconciliation results
    --
    -- This simulates the reconciliation evidence generated by the load.
    -- For AddressType, source and target row counts match.
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
        ('ROW_COUNT', 'TABLE=AddressType', 'SOURCE', 6, @AddressTypeStepId),
        ('ROW_COUNT', 'TABLE=AddressType', 'TARGET', 6, @AddressTypeStepId);

    ---------------------------------------------------------------------
    -- End execution step
    --
    -- The process-specific logic decided this step is successful.
    ---------------------------------------------------------------------

    EXEC [runtime].[usp_end_execution_step]
        @p_execution_step_id = @AddressTypeStepId,
        @p_status_code_id = @status_success;
END;

-------------------------------------------------------------------------
-- 6. ProductCategory Load - Success
--
-- Same pattern as AddressType:
--   start step -> register reconciliation -> end step
-------------------------------------------------------------------------

IF @run_ProductCategory_load = 1
BEGIN
    DECLARE @ProductCategoryStep TABLE (execution_step_id BIGINT);
    DECLARE @ProductCategoryStepId BIGINT;

    ---------------------------------------------------------------------
    -- Start execution step for ProductCategory Load.
    ---------------------------------------------------------------------

    INSERT INTO @ProductCategoryStep
    EXEC [runtime].[usp_start_execution_step]
        @p_execution_run_id = @execution_run_id,
        @p_project_process_id = @ProductCategoryProcessId;

    SELECT @ProductCategoryStepId = [execution_step_id]
    FROM @ProductCategoryStep;

    ---------------------------------------------------------------------
    -- Register reconciliation results.
    -- Source and target row counts match.
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
        ('ROW_COUNT', 'TABLE=ProductCategory', 'SOURCE', 37, @ProductCategoryStepId),
        ('ROW_COUNT', 'TABLE=ProductCategory', 'TARGET', 37, @ProductCategoryStepId);

    ---------------------------------------------------------------------
    -- End execution step as Success.
    ---------------------------------------------------------------------

    EXEC [runtime].[usp_end_execution_step]
        @p_execution_step_id = @ProductCategoryStepId,
        @p_status_code_id = @status_success;
END;

-------------------------------------------------------------------------
-- 7. Geography Load group
--
-- This simulates a grouped SSIS container:
--
-- Geography Load
--     ├── CountryRegion Load
--     ├── StateProvince Load
--     └── SalesTerritory Load
--
-- The parent group runs if at least one Geography child table has
-- execution_required = 1.
--
-- Each child table still creates its own execution step so observability
-- remains table-specific.
-------------------------------------------------------------------------

IF @run_Geography_load = 1
BEGIN
    ---------------------------------------------------------------------
    -- 7.1 CountryRegion Load - Success
    ---------------------------------------------------------------------

    IF @run_CountryRegion_load = 1
    BEGIN
        DECLARE @CountryRegionStep TABLE (execution_step_id BIGINT);
        DECLARE @CountryRegionStepId BIGINT;

        -----------------------------------------------------------------
        -- Start execution step for CountryRegion Load.
        -----------------------------------------------------------------

        INSERT INTO @CountryRegionStep
        EXEC [runtime].[usp_start_execution_step]
            @p_execution_run_id = @execution_run_id,
            @p_project_process_id = @CountryRegionProcessId;

        SELECT @CountryRegionStepId = [execution_step_id]
        FROM @CountryRegionStep;

        -----------------------------------------------------------------
        -- Register reconciliation results.
        -- Source and target row counts match.
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
            ('ROW_COUNT', 'TABLE=CountryRegion', 'SOURCE', 6, @CountryRegionStepId),
            ('ROW_COUNT', 'TABLE=CountryRegion', 'TARGET', 6, @CountryRegionStepId);

        -----------------------------------------------------------------
        -- End execution step as Success.
        -----------------------------------------------------------------

        EXEC [runtime].[usp_end_execution_step]
            @p_execution_step_id = @CountryRegionStepId,
            @p_status_code_id = @status_success;
    END;

    ---------------------------------------------------------------------
    -- 7.2 StateProvince Load - Observed
    --
    -- This block simulates a case where the technical load completed,
    -- but validation/reconciliation shows that one row was excluded.
    --
    -- Reconciliation:
    --   SOURCE = 181
    --   TARGET = 180
    --
    -- Validation:
    --   1 row failed FK_CHECK.
    --
    -- Final step status:
    --   Observed
    ---------------------------------------------------------------------

    IF @run_StateProvince_load = 1
    BEGIN
        DECLARE @StateProvinceStep TABLE (execution_step_id BIGINT);
        DECLARE @StateProvinceStepId BIGINT;

        -----------------------------------------------------------------
        -- Start execution step for StateProvince Load.
        -----------------------------------------------------------------

        INSERT INTO @StateProvinceStep
        EXEC [runtime].[usp_start_execution_step]
            @p_execution_run_id = @execution_run_id,
            @p_project_process_id = @StateProvinceProcessId;

        SELECT @StateProvinceStepId = [execution_step_id]
        FROM @StateProvinceStep;

        -----------------------------------------------------------------
        -- Register reconciliation results.
        --
        -- This evidence shows that the target has one row less than the
        -- source.
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
            ('ROW_COUNT', 'TABLE=StateProvince', 'SOURCE', 181, @StateProvinceStepId),
            ('ROW_COUNT', 'TABLE=StateProvince', 'TARGET', 180, @StateProvinceStepId);

        -----------------------------------------------------------------
        -- Register validation result.
        --
        -- This explains why the target has fewer rows.
        -- DataOps_Control stores the validation summary, not the rejected
        -- business row itself.
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
            '1 source row was excluded from the target load because CountryRegionCode does not exist in the CountryRegion target table.',
            1,
            @StateProvinceStepId,
            3 -- FK_CHECK
        );

        -----------------------------------------------------------------
        -- End execution step as Observed.
        --
        -- This is not a technical failure. The process completed, but the
        -- validation/reconciliation evidence requires review.
        -----------------------------------------------------------------

        EXEC [runtime].[usp_end_execution_step]
            @p_execution_step_id = @StateProvinceStepId,
            @p_status_code_id = @status_observed;
    END;

    ---------------------------------------------------------------------
    -- 7.3 SalesTerritory Load - Success
    ---------------------------------------------------------------------

    IF @run_SalesTerritory_load = 1
    BEGIN
        DECLARE @SalesTerritoryStep TABLE (execution_step_id BIGINT);
        DECLARE @SalesTerritoryStepId BIGINT;

        -----------------------------------------------------------------
        -- Start execution step for SalesTerritory Load.
        -----------------------------------------------------------------

        INSERT INTO @SalesTerritoryStep
        EXEC [runtime].[usp_start_execution_step]
            @p_execution_run_id = @execution_run_id,
            @p_project_process_id = @SalesTerritoryProcessId;

        SELECT @SalesTerritoryStepId = [execution_step_id]
        FROM @SalesTerritoryStep;

        -----------------------------------------------------------------
        -- Register reconciliation results.
        -- Source and target row counts match.
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
            ('ROW_COUNT', 'TABLE=SalesTerritory', 'SOURCE', 10, @SalesTerritoryStepId),
            ('ROW_COUNT', 'TABLE=SalesTerritory', 'TARGET', 10, @SalesTerritoryStepId);

        -----------------------------------------------------------------
        -- End execution step as Success.
        -----------------------------------------------------------------

        EXEC [runtime].[usp_end_execution_step]
            @p_execution_step_id = @SalesTerritoryStepId,
            @p_status_code_id = @status_success;
    END;
END;

-------------------------------------------------------------------------
-- 8. End execution run
--
-- runtime.usp_end_execution_run derives the final run status from all
-- related execution steps.
--
-- Expected result:
--   Observed
--
-- Reason:
--   StateProvince Load ended as Observed.
-------------------------------------------------------------------------

EXEC [runtime].[usp_end_execution_run]
    @p_execution_run_id = @execution_run_id;

-------------------------------------------------------------------------
-- 9. Review execution run result
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
-- 10. Review execution step results
--
-- Expected:
--   AddressType       = Success
--   ProductCategory   = Success
--   CountryRegion     = Success
--   StateProvince     = Observed
--   SalesTerritory    = Success
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
-- 11. Review reconciliation results
--
-- This query shows the row-count evidence registered for each execution
-- step.
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
INNER JOIN [runtime].[execution_steps] es ON es.[id] = rr.[execution_step_id]
INNER JOIN [metadata].[project_processes] pp ON pp.[id] = es.[project_process_id]
WHERE es.[execution_run_id] = @execution_run_id
ORDER BY
    rr.[execution_step_id],
    rr.[metric_name],
    rr.[reconciliation_key],
    rr.[reconciliation_side];

-------------------------------------------------------------------------
-- 12. Review validation results
--
-- This query shows validation findings that explain observed outcomes.
--
-- Expected:
--   StateProvince has one FK_CHECK validation result.
-------------------------------------------------------------------------

SELECT
    vr.[execution_step_id],
    pp.[name] AS [process_name],
    vc.[code] AS [validation_code],
    vc.[severity],
    vr.[affected_row_count],
    vr.[details]
FROM [observability].[validation_results] vr
INNER JOIN [runtime].[execution_steps] es ON es.[id] = vr.[execution_step_id]
INNER JOIN [metadata].[project_processes] pp ON pp.[id] = es.[project_process_id]
INNER JOIN [reference].[validation_codes] vc ON vc.[id] = vr.[validation_code_id]
WHERE es.[execution_run_id] = @execution_run_id
ORDER BY
    vr.[execution_step_id],
    vc.[code];