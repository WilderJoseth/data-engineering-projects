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
        THROW 50001, 'Project was not found or is inactive.', 1;
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
        THROW 50002, 'Status code Running was not found or is inactive.', 1;
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

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS [execution_run_id];
END;
GO


CREATE OR ALTER PROCEDURE [runtime].[usp_start_execution_step]
    @p_execution_run_id INT,
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
        THROW 50003, 'Execution run was not found or is already closed.', 1;
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
        THROW 50004, 'Project process was not found, is inactive, or does not belong to the execution run project.', 1;
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
        THROW 50005, 'Status code Running was not found or is inactive.', 1;
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
        THROW 50006, 'Status code was not found or is inactive.', 1;
    END;

    -------------------------------------------------------------------------
    -- End execution step.
    -- The step must exist and still be open.
    -------------------------------------------------------------------------

    UPDATE [runtime].[execution_steps]
    SET
        [end_run_date] = SYSUTCDATETIME(),
        [status_code_id] = @p_status_code_id
    WHERE [id] = @p_execution_step_id
    AND [end_run_date] IS NULL;

    IF @@ROWCOUNT = 0
    BEGIN
        THROW 50007, 'Execution step was not found or is already closed.', 1;
    END;
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
        - 7 = Observed
    */

    DECLARE @status_pending SMALLINT = 1;
    DECLARE @status_running SMALLINT = 2;
    DECLARE @status_success SMALLINT = 3;
    DECLARE @status_failed SMALLINT = 4;
    DECLARE @status_observed SMALLINT = 7;

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
        THROW 50008, 'Execution run was not found or is already closed.', 1;
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
        THROW 50009, 'Execution run cannot be ended because one or more steps are still pending or running.', 1;
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
        THROW 50010, 'Derived final status code was not found or is inactive.', 1;
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
        THROW 50011, 'Execution run was not found or is already closed.', 1;
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
        THROW 50012, 'Execution step was not found.', 1;
    END;

    -------------------------------------------------------------------------
    -- Validate required error fields.
    -------------------------------------------------------------------------

    IF NULLIF(LTRIM(RTRIM(@p_error_source)), '') IS NULL
    BEGIN
        THROW 50013, 'Error source is required.', 1;
    END;

    IF NULLIF(LTRIM(RTRIM(@p_details)), '') IS NULL
    BEGIN
        THROW 50014, 'Error details are required.', 1;
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