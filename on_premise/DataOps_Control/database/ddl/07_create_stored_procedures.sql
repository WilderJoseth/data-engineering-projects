USE [DataOps_Control];
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_start_execution_run]
    @p_project_id SMALLINT
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Purpose:
        - Starts a new execution run for a registered project.
        - The run represents one execution of a project.

        Status behavior:
        - New runs are created with Running status.
        - Status code 2 = Running.

        Output:
        - Returns execution_run_id.
    */

    DECLARE @status_code_id_running SMALLINT = 2;

    -------------------------------------------------------------------------
    -- Validate project.
    -- The project must exist and be active before starting an execution run.
    -------------------------------------------------------------------------

    IF NOT EXISTS
    (
        SELECT 1
        FROM [metadata].[projects]
        WHERE [id] = @p_project_id
        AND [is_active] = 1
    )
    BEGIN
        ;THROW 50001, 'Project was not found or is inactive.', 1;
    END;

    -------------------------------------------------------------------------
    -- Validate status code.
    -- Running must exist and be active in reference.status_codes.
    -------------------------------------------------------------------------

    IF NOT EXISTS
    (
        SELECT 1
        FROM [reference].[status_codes]
        WHERE [id] = @status_code_id_running
        AND [is_active] = 1
    )
    BEGIN
        ;THROW 50002, 'Status code Running was not found or is inactive.', 1;
    END;

    -------------------------------------------------------------------------
    -- Register execution run.
    -------------------------------------------------------------------------

    INSERT INTO [runtime].[execution_runs]
    (
        [status_code_id],
        [project_id]
    )
    VALUES
    (
        @status_code_id_running,
        @p_project_id
    );

    SELECT CAST(SCOPE_IDENTITY() AS BIGINT) AS [execution_run_id];
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_start_execution_step]
    @p_execution_run_id BIGINT,
    @p_project_process_id INT
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Purpose:
        - Starts a new execution step inside an existing execution run.
        - Each execution step represents one execution of one registered process.

        Status behavior:
        - New steps are created with Running status.
        - Status code 2 = Running.

        Output:
        - Returns execution_step_id.
        - This ID is used by observability tables.
    */

    DECLARE @status_code_id_running SMALLINT = 2;
    DECLARE @execution_run_project_id SMALLINT;

    -------------------------------------------------------------------------
    -- Validate execution run.
    -- The run must exist and must still be open.
    -------------------------------------------------------------------------

    SELECT
        @execution_run_project_id = [project_id]
    FROM [runtime].[execution_runs]
    WHERE [id] = @p_execution_run_id
    AND [end_run_date] IS NULL;

    IF @execution_run_project_id IS NULL
    BEGIN
        ;THROW 50003, 'Execution run was not found or is already closed.', 1;
    END;

    -------------------------------------------------------------------------
    -- Validate project process.
    -- The process must exist, be active, and belong to the same project as
    -- the execution run.
    -------------------------------------------------------------------------

    IF NOT EXISTS
    (
        SELECT 1
        FROM [metadata].[project_processes]
        WHERE [id] = @p_project_process_id
        AND [project_id] = @execution_run_project_id
        AND [is_active] = 1
    )
    BEGIN
        ;THROW 50004, 'Project process was not found, is inactive, or does not belong to the execution run project.', 1;
    END;

    -------------------------------------------------------------------------
    -- Validate status code.
    -------------------------------------------------------------------------

    IF NOT EXISTS
    (
        SELECT 1
        FROM [reference].[status_codes]
        WHERE [id] = @status_code_id_running
        AND [is_active] = 1
    )
    BEGIN
        ;THROW 50005, 'Status code Running was not found or is inactive.', 1;
    END;

    -------------------------------------------------------------------------
    -- Register execution step.
    -------------------------------------------------------------------------

    INSERT INTO [runtime].[execution_steps]
    (
        [status_code_id],
        [execution_run_id],
        [project_process_id]
    )
    VALUES
    (
        @status_code_id_running,
        @p_execution_run_id,
        @p_project_process_id
    );

    SELECT CAST(SCOPE_IDENTITY() AS BIGINT) AS [execution_step_id];
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_end_execution_step]
    @p_execution_step_id BIGINT,
    @p_status_code_id SMALLINT
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Purpose:
        - Ends an execution step.
        - Updates the step end date and final status.

        Important design rule:
        - This procedure does not decide whether the step is Success,
          Observed, or Failed.
        - The final status is provided by the process-specific logic.

        Examples:
        - Technical error handler passes Failed.
        - Validation/reconciliation logic may pass Success or Observed.
    */

    -------------------------------------------------------------------------
    -- Validate status code.
    -------------------------------------------------------------------------

    IF NOT EXISTS
    (
        SELECT 1
        FROM [reference].[status_codes]
        WHERE [id] = @p_status_code_id
        AND [is_active] = 1
    )
    BEGIN
        ;THROW 50006, 'Status code was not found or is inactive.', 1;
    END;

    -------------------------------------------------------------------------
    -- End execution step.
    -- The step must exist and still be open.
    -------------------------------------------------------------------------

    UPDATE [runtime].[execution_steps]
    SET
        [end_step_date] = SYSUTCDATETIME(),
        [status_code_id] = @p_status_code_id
    WHERE [id] = @p_execution_step_id
    AND [end_step_date] IS NULL;

    IF @@ROWCOUNT = 0
    BEGIN
        ;THROW 50007, 'Execution step was not found or is already closed.', 1;
    END;
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_end_parent_execution_step]
(
    @p_execution_step_id BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Purpose:
        - Ends a parent/group execution step based on the statuses of its direct child steps.

        Status rule:
        - If any child step FAILED   -> parent becomes FAILED.
        - Else if any child OBSERVED -> parent becomes OBSERVED.
        - Else                       -> parent becomes SUCCESS.

        Notes:
        - This procedure evaluates only direct child processes.
        - Child processes are identified through metadata.project_processes.parent_process_id.
        - Leaf process status is still defined by the project/orchestrator using runtime.usp_end_execution_step.
    */

    DECLARE @execution_run_id INT;
    DECLARE @parent_project_process_id INT;

    /*
        Keep status IDs consistent with runtime.usp_end_execution_run.

        Expected reference.status_codes:
        1 = PENDING
        2 = RUNNING
        3 = SUCCESS
        4 = FAILED
        5 = SKIPPED
        6 = OBSERVED
    */
    DECLARE @status_pending SMALLINT = 1;
    DECLARE @status_running SMALLINT = 2;
    DECLARE @status_success SMALLINT = 3;
    DECLARE @status_failed SMALLINT = 4;
    DECLARE @status_observed SMALLINT = 6;

    DECLARE @final_status_code_id SMALLINT;

    /*
        Get the execution run and the process represented by the parent step.
    */
    SELECT
        @execution_run_id = es.[execution_run_id],
        @parent_project_process_id = es.[project_process_id]
    FROM [runtime].[execution_steps] es
    WHERE es.[id] = @p_execution_step_id;

    IF @execution_run_id IS NULL
        THROW 51000, 'Execution step was not found.', 1;

    /*
        Validate that the provided step belongs to a parent process.
        A parent process must have at least one direct child process.
    */
    IF NOT EXISTS
    (
        SELECT 1
        FROM [metadata].[project_processes]
        WHERE [parent_process_id] = @parent_project_process_id
        AND [is_active] = 1
    )
    BEGIN
        ;THROW 51001, 'The execution step does not belong to a parent process or is inactive.', 1;
    END;

    /*
        A parent step cannot be closed if any existing direct child step
        in the same execution run is still PENDING or RUNNING.
    */
    IF EXISTS
    (
        SELECT 1
        FROM [runtime].[execution_steps] step
        WHERE step.[execution_run_id] = @execution_run_id
        AND step.[status_code_id] IN (@status_pending, @status_running)
        AND EXISTS 
        (
            SELECT 1 
            FROM [metadata].[project_processes] child 
            WHERE child.[id] = step.[project_process_id] 
            AND child.[parent_process_id] = @parent_project_process_id
        )
    )
    BEGIN
        ;THROW 51002, 'Cannot close parent execution step because one or more child steps are still open.', 1;
    END;

    /*
        At least one direct child execution step must exist for this parent
        in the current execution run.
    */
    IF NOT EXISTS
    (
        SELECT 1
        FROM [runtime].[execution_steps] step
        WHERE step.[execution_run_id] = @execution_run_id
        AND EXISTS
        (
            SELECT 1
            FROM [metadata].[project_processes] child
            WHERE child.[id] = step.[project_process_id]
            AND child.[parent_process_id] = @parent_project_process_id
        )
    )
    BEGIN
        ;THROW 51003, 'Cannot close parent execution step because no child execution steps were found.', 1;
    END;

    /*
        Derive parent status from direct child statuses.

        Priority:
        1. FAILED
        2. OBSERVED
        3. SUCCESS (SKIPPED children are treated as terminal and neutral)
    */
    IF EXISTS
    (
        SELECT 1
        FROM [runtime].[execution_steps] step
        WHERE step.[execution_run_id] = @execution_run_id
        AND step.[status_code_id] = @status_failed
        AND EXISTS 
        (
            SELECT 1 FROM [metadata].[project_processes] child 
            WHERE child.[id] = step.[project_process_id] 
            AND  child.[parent_process_id] = @parent_project_process_id
        )
    )
    BEGIN
        SET @final_status_code_id = @status_failed;
    END;
    ELSE IF EXISTS
    (
        SELECT 1
        FROM [runtime].[execution_steps] step
        WHERE step.[execution_run_id] = @execution_run_id
        AND step.[status_code_id] = @status_observed
        AND EXISTS 
        (
            SELECT 1 FROM [metadata].[project_processes] child 
            WHERE child.[id] = step.[project_process_id] 
            AND child.[parent_process_id] = @parent_project_process_id
        )
    )
    BEGIN
        SET @final_status_code_id = @status_observed;
    END;
    ELSE
    BEGIN
        SET @final_status_code_id = @status_success;
    END;

    /*
        Reuse the standard step-ending procedure.

        This keeps audit behavior and runtime update behavior centralized in:
            runtime.usp_end_execution_step
    */
    EXEC [runtime].[usp_end_execution_step]
        @p_execution_step_id = @p_execution_step_id,
        @p_status_code_id = @final_status_code_id;
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_register_skipped_child_execution_steps]
(
    @p_parent_execution_step_id BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Purpose:
        - Registers SKIPPED execution steps for active direct child processes
          that are not required for execution.

        Rule:
        - is_active = 1 and execution_required = 0 -> create SKIPPED step.
        - is_active = 0 -> ignore.
        - execution_required = 1 -> this procedure does nothing.

        Notes:
        - This procedure only handles direct child processes.
        - This procedure does not close the parent step.
        - This procedure does not derive parent status.
        - This procedure does not call runtime.usp_start_execution_step or
          runtime.usp_end_execution_step because SKIPPED is not a real execution.
    */

    DECLARE @execution_run_id INT;
    DECLARE @parent_project_process_id INT;

    /*
        Expected reference.status_codes:
        1 = PENDING
        2 = RUNNING
        3 = SUCCESS
        4 = FAILED
        5 = SKIPPED
        6 = OBSERVED
    */
    DECLARE @status_skipped SMALLINT = 5;

    /*
        Get the execution run and parent process represented by the parent step.
    */
    SELECT
        @execution_run_id = es.[execution_run_id],
        @parent_project_process_id = es.[project_process_id]
    FROM [runtime].[execution_steps] es
    WHERE es.[id] = @p_parent_execution_step_id;

    IF @execution_run_id IS NULL
        THROW 51000, 'Parent execution step was not found.', 1;

    /*
        Validate that the provided step belongs to a parent process.
    */
    IF NOT EXISTS
    (
        SELECT 1
        FROM [metadata].[project_processes]
        WHERE [parent_process_id] = @parent_project_process_id
        AND [is_active] = 1
    )
    BEGIN
        ;THROW 51001, 'The execution step does not belong to a parent process or is inactive.', 1;
    END;

    /*
        Register SKIPPED steps for active non-required direct child processes
        that do not already have an execution step in this run.
    */
    INSERT INTO [runtime].[execution_steps]
    (
        [execution_run_id],
        [project_process_id],
        [status_code_id],
        [start_step_date],
        [end_step_date]
    )
    SELECT
        @execution_run_id,
        child.[id],
        @status_skipped,
        SYSUTCDATETIME(),
        SYSUTCDATETIME()
    FROM [metadata].[project_processes] child
    LEFT JOIN [runtime].[execution_steps] child_step
        ON child_step.[project_process_id] = child.[id]
        AND child_step.[execution_run_id] = @execution_run_id
    WHERE child.[parent_process_id] = @parent_project_process_id
    AND child.[is_active] = 1
    AND child.[execution_required] = 0
    AND child_step.[id] IS NULL;
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_end_execution_run]
    @p_execution_run_id INT
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Purpose:
        - Ends an execution run.
        - The final run status is derived from its related execution steps.

        Status derivation rule:
        1. If the run has no steps, mark the run as Observed.
        2. If any step is still Pending or Running, do not end the run.
        3. If any step is Failed, mark the run as Failed.
        4. If no step failed but at least one step is Observed, mark the run as Observed.
        5. Otherwise, mark the run as Success.

        Status code assumptions:
        - 1 = Pending
        - 2 = Running
        - 3 = Success
        - 4 = Failed
        - 6 = Observed
    */

    DECLARE @status_pending SMALLINT = 1;
    DECLARE @status_running SMALLINT = 2;
    DECLARE @status_success SMALLINT = 3;
    DECLARE @status_failed SMALLINT = 4;
    DECLARE @status_observed SMALLINT = 6;

    DECLARE @final_status_code_id SMALLINT;

    -------------------------------------------------------------------------
    -- Validate execution run.
    -- The run must exist and still be open.
    -------------------------------------------------------------------------

    IF NOT EXISTS
    (
        SELECT 1
        FROM [runtime].[execution_runs]
        WHERE [id] = @p_execution_run_id
        AND [end_run_date] IS NULL
    )
    BEGIN
        ;THROW 50008, 'Execution run was not found or is already closed.', 1;
    END;

    -------------------------------------------------------------------------
    -- If the run has no steps, mark it as Observed.
    -- This means the run started, but no process-level work was recorded.
    -------------------------------------------------------------------------

    IF NOT EXISTS
    (
        SELECT 1
        FROM [runtime].[execution_steps]
        WHERE [execution_run_id] = @p_execution_run_id
    )
    BEGIN
        SET @final_status_code_id = @status_observed;
    END

    -------------------------------------------------------------------------
    -- If any step is still Pending or Running, the run cannot be closed.
    -------------------------------------------------------------------------

    ELSE IF EXISTS
    (
        SELECT 1
        FROM [runtime].[execution_steps]
        WHERE [execution_run_id] = @p_execution_run_id
        AND [status_code_id] IN (@status_pending, @status_running)
    )
    BEGIN
        ;THROW 50009, 'Execution run cannot be ended because one or more steps are still pending or running.', 1;
    END

    -------------------------------------------------------------------------
    -- Failed has the highest priority.
    -------------------------------------------------------------------------

    ELSE IF EXISTS
    (
        SELECT 1
        FROM [runtime].[execution_steps]
        WHERE [execution_run_id] = @p_execution_run_id
        AND [status_code_id] = @status_failed
    )
    BEGIN
        SET @final_status_code_id = @status_failed;
    END

    -------------------------------------------------------------------------
    -- Observed has the second priority.
    -------------------------------------------------------------------------

    ELSE IF EXISTS
    (
        SELECT 1
        FROM [runtime].[execution_steps]
        WHERE [execution_run_id] = @p_execution_run_id
        AND [status_code_id] = @status_observed
    )
    BEGIN
        SET @final_status_code_id = @status_observed;
    END

    -------------------------------------------------------------------------
    -- Otherwise, the run is successful.
    -------------------------------------------------------------------------

    ELSE
    BEGIN
        SET @final_status_code_id = @status_success;
    END;

    -------------------------------------------------------------------------
    -- Validate derived final status.
    -------------------------------------------------------------------------

    IF NOT EXISTS
    (
        SELECT 1
        FROM [reference].[status_codes]
        WHERE [id] = @final_status_code_id
        AND [is_active] = 1
    )
    BEGIN
        ;THROW 50010, 'Derived final status code was not found or is inactive.', 1;
    END;

    -------------------------------------------------------------------------
    -- End execution run.
    -------------------------------------------------------------------------

    UPDATE [runtime].[execution_runs]
    SET
        [end_run_date] = SYSUTCDATETIME(),
        [status_code_id] = @final_status_code_id
    WHERE [id] = @p_execution_run_id
    AND [end_run_date] IS NULL;

    IF @@ROWCOUNT = 0
    BEGIN
        ;THROW 50011, 'Execution run was not found or is already closed.', 1;
    END;
END;
GO

CREATE OR ALTER PROCEDURE [observability].[usp_log_error]
    @p_execution_step_id BIGINT,
    @p_error_source VARCHAR(200),
    @p_details VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Purpose:
        - Logs a technical error related to an execution step.

        Examples of error_source:
        - SSIS package name
        - SSIS container name
        - SSIS task name
        - Stored procedure name
        - Pipeline activity name

        Important:
        - This procedure only logs the error.
        - The caller should separately end the execution step as Failed by calling:
            runtime.usp_end_execution_step
    */

    -------------------------------------------------------------------------
    -- Validate execution step.
    -- The error must be linked to a valid execution step.
    -------------------------------------------------------------------------

    IF NOT EXISTS
    (
        SELECT 1
        FROM [runtime].[execution_steps]
        WHERE [id] = @p_execution_step_id
    )
    BEGIN
        ;THROW 50012, 'Execution step was not found.', 1;
    END;

    -------------------------------------------------------------------------
    -- Validate required error fields.
    -------------------------------------------------------------------------

    IF NULLIF(LTRIM(RTRIM(@p_error_source)), '') IS NULL
    BEGIN
        ;THROW 50013, 'Error source is required.', 1;
    END;

    IF NULLIF(LTRIM(RTRIM(@p_details)), '') IS NULL
    BEGIN
        ;THROW 50014, 'Error details are required.', 1;
    END;

    -------------------------------------------------------------------------
    -- Register technical error.
    -------------------------------------------------------------------------

    INSERT INTO [observability].[error_logs]
    (
        [error_source],
        [details],
        [execution_step_id]
    )
    VALUES
    (
        @p_error_source,
        @p_details,
        @p_execution_step_id
    );
END;
GO

CREATE OR ALTER PROCEDURE [observability].[usp_capture_execution_step_bigint_monitoring_results]
(
    @p_execution_step_id BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Purpose:
        - Captures BIGINT-based monitoring results for one execution step.
        - Reads configured monitoring metrics from metadata.
        - Calculates actual metric values from runtime and observability tables.
        - Inserts results into observability.monitoring_results.

        Idempotency:
        - Existing monitoring results for the execution step are deleted first.
        - Results are then recalculated and inserted again.

        Supported BIGINT metrics:
        - DURATION_SECONDS
        - VALIDATION_ISSUE_COUNT
        - RECONCILIATION_MISMATCH_COUNT
        - ERROR_COUNT
        - ROW_COUNT

        Notes:
        - This procedure only supports metrics configured with metric_value_type = 'BIGINT'.
        - Decimal metrics should be handled by a separate procedure if needed later.
        - This procedure does not decide the final execution step status.
        - Status decision remains responsibility of the project-specific logic,
          such as a load status code function.
        - If end_step_date is still NULL, duration is calculated using
          SYSUTCDATETIME().
    */

    DECLARE @project_process_id INT;

    SELECT
        @project_process_id = es.[project_process_id]
    FROM [runtime].[execution_steps] es
    WHERE es.[id] = @p_execution_step_id;

    IF @project_process_id IS NULL
    BEGIN
        ;THROW 51000, 'Execution step was not found.', 1;
    END;

    DELETE FROM [observability].[monitoring_results]
    WHERE [execution_step_id] = @p_execution_step_id;

    ;WITH reconciliation_pairs AS
    (
        SELECT
            rr.[metric_name],
            rr.[reconciliation_key],
            MAX(CASE WHEN rr.[reconciliation_side] = 'SOURCE' THEN rr.[metric_value_bigint] END) AS [source_value_bigint],
            MAX(CASE WHEN rr.[reconciliation_side] = 'TARGET' THEN rr.[metric_value_bigint] END) AS [target_value_bigint]
        FROM [observability].[reconciliation_results] rr
        WHERE rr.[execution_step_id] = @p_execution_step_id
        AND rr.[reconciliation_side] IN ('SOURCE', 'TARGET')
        AND rr.[metric_value_bigint] IS NOT NULL
        GROUP BY
            rr.[metric_name],
            rr.[reconciliation_key]
    ),
    reconciliation_mismatch AS
    (
        SELECT
            COUNT_BIG(1) AS [mismatch_count]
        FROM reconciliation_pairs rp
        WHERE
            rp.[source_value_bigint] IS NULL
            OR rp.[target_value_bigint] IS NULL
            OR rp.[source_value_bigint] <> rp.[target_value_bigint]
    ),
    calculated_metrics AS
    (
        SELECT
            'DURATION_SECONDS' AS [metric_code],
            CAST
            (
                DATEDIFF
                (
                    SECOND,
                    es.[start_step_date],
                    COALESCE(es.[end_step_date], SYSUTCDATETIME())
                ) AS BIGINT
            ) AS [actual_value_bigint]
        FROM [runtime].[execution_steps] es
        WHERE es.[id] = @p_execution_step_id

        UNION ALL

        SELECT
            'VALIDATION_ISSUE_COUNT' AS [metric_code],
            CAST(COUNT_BIG(1) AS BIGINT) AS [actual_value_bigint]
        FROM [observability].[validation_results] vr
        WHERE vr.[execution_step_id] = @p_execution_step_id

        UNION ALL

        SELECT
            'ERROR_COUNT' AS [metric_code],
            CAST(COUNT_BIG(1) AS BIGINT) AS [actual_value_bigint]
        FROM [observability].[error_logs] el
        WHERE el.[execution_step_id] = @p_execution_step_id

        UNION ALL

        SELECT
            'RECONCILIATION_MISMATCH_COUNT' AS [metric_code],
            CAST(ISNULL(rm.[mismatch_count], 0) AS BIGINT) AS [actual_value_bigint]
        FROM reconciliation_mismatch rm

        UNION ALL

        SELECT
            'ROW_COUNT' AS [metric_code],
            CAST(ISNULL(SUM(rr.[metric_value_bigint]), 0) AS BIGINT) AS [actual_value_bigint]
        FROM [observability].[reconciliation_results] rr
        WHERE rr.[execution_step_id] = @p_execution_step_id
        AND rr.[metric_name] = 'ROW_COUNT'
        AND rr.[reconciliation_side] = 'TARGET'
    )
    INSERT INTO [observability].[monitoring_results]
    (
        [execution_step_id],
        [project_process_monitoring_metric_id],
        [actual_value_bigint],
        [actual_value_decimal],
        [is_within_expected_range]
    )
    SELECT
        @p_execution_step_id AS [execution_step_id],
        ppm.[id] AS [project_process_monitoring_metric_id],
        cm.[actual_value_bigint],
        NULL AS [actual_value_decimal],
        CAST
        (
            CASE
                WHEN ppm.[min_value_bigint] IS NOT NULL
                     AND cm.[actual_value_bigint] < ppm.[min_value_bigint]
                THEN 0

                WHEN ppm.[max_value_bigint] IS NOT NULL
                     AND cm.[actual_value_bigint] > ppm.[max_value_bigint]
                THEN 0

                ELSE 1
            END AS BIT
        ) AS [is_within_expected_range]
    FROM [metadata].[project_process_monitoring_metrics] ppm
    INNER JOIN [reference].[monitoring_metric_codes] mmc
        ON mmc.[id] = ppm.[monitoring_metric_code_id]
        AND mmc.[is_active] = 1
    INNER JOIN calculated_metrics cm
        ON cm.[metric_code] = mmc.[code]
    WHERE ppm.[project_process_id] = @project_process_id
    AND ppm.[is_active] = 1
    AND mmc.[metric_value_type] = 'BIGINT';
END;
GO
