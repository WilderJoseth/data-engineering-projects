USE [DataOps_Control];
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_create_execution_plan]
    @p_project_id SMALLINT,
    @p_plan_type VARCHAR(30),
    @p_plan_name VARCHAR(100) = NULL,
    @p_root_project_process_id INT = NULL,
    @p_scope_description VARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Purpose:
        - Creates a pending execution plan for an active project.
        - The plan represents one controlled execution scope.

        Status behavior:
        - New plans are created with Pending status.
        - Status IDs are fixed framework constants loaded by seed scripts.
    */

    DECLARE @status_code_id_pending SMALLINT = 1;

    -- Status code IDs are controlled framework constants inserted by seed scripts and should not be changed after deployment.

    IF NOT EXISTS
    (
        SELECT 1
        FROM [reference].[status_codes]
        WHERE [id] = @status_code_id_pending
        AND [code] = 'PENDING'
        AND [is_active] = 1
    )
    BEGIN
        ;THROW 50020, 'Status code Pending was not found or is inactive.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM [metadata].[projects]
        WHERE [id] = @p_project_id
        AND [is_active] = 1
    )
    BEGIN
        ;THROW 50021, 'Project was not found or is inactive.', 1;
    END;

    IF @p_root_project_process_id IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM [metadata].[project_processes]
        WHERE [id] = @p_root_project_process_id
        AND [project_id] = @p_project_id
        AND [is_active] = 1
    )
    BEGIN
        ;THROW 50022, 'Root project process was not found, is inactive, or does not belong to the project.', 1;
    END;

    INSERT INTO [runtime].[execution_plans]
    (
        [plan_name],
        [plan_type],
        [status_code_id],
        [project_id],
        [root_project_process_id],
        [scope_description]
    )
    VALUES
    (
        @p_plan_name,
        @p_plan_type,
        @status_code_id_pending,
        @p_project_id,
        @p_root_project_process_id,
        @p_scope_description
    );

    SELECT CAST(SCOPE_IDENTITY() AS BIGINT) AS [execution_plan_id];
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_add_execution_plan_process]
    @p_execution_plan_id BIGINT,
    @p_project_process_id INT
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Purpose:
        - Adds one active project process to an open execution plan.
        - Prevents duplicate process registration within the same plan.

        Status behavior:
        - New plan processes are created with Pending status.
        - Status IDs are fixed framework constants loaded by seed scripts.
    */

    DECLARE @status_code_id_pending SMALLINT = 1;
    DECLARE @project_id SMALLINT;

    -- Status code IDs are controlled framework constants inserted by seed scripts and should not be changed after deployment.

    SELECT
        @project_id = [project_id]
    FROM [runtime].[execution_plans]
    WHERE [id] = @p_execution_plan_id
    AND [end_plan_date] IS NULL;

    IF @project_id IS NULL
    BEGIN
        ;THROW 50023, 'Execution plan was not found or is already closed.', 1;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM [metadata].[project_processes]
        WHERE [id] = @p_project_process_id
        AND [project_id] = @project_id
        AND [is_active] = 1
    )
    BEGIN
        ;THROW 50024, 'Project process was not found, is inactive, or does not belong to the execution plan project.', 1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM [runtime].[execution_plan_processes]
        WHERE [execution_plan_id] = @p_execution_plan_id
        AND [project_process_id] = @p_project_process_id
    )
    BEGIN
        ;THROW 50025, 'Project process is already registered in the execution plan.', 1;
    END;

    INSERT INTO [runtime].[execution_plan_processes]
    (
        [execution_plan_id],
        [project_process_id],
        [status_code_id]
    )
    VALUES
    (
        @p_execution_plan_id,
        @p_project_process_id,
        @status_code_id_pending
    );

    SELECT CAST(SCOPE_IDENTITY() AS BIGINT) AS [execution_plan_process_id];
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_evaluate_execution_plan_dependencies]
    @p_execution_plan_id BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Purpose:
        - Evaluates included process dependencies for one open execution plan.
        - Updates non-final plan processes to Ready, Pending, or Blocked.

        Dependency rule:
        - All included dependencies successful -> Ready.
        - Failed or blocked dependency -> Blocked.
        - Other dependency statuses keep the process Pending.
    */

    DECLARE @status_pending SMALLINT = 1;
    DECLARE @status_ready SMALLINT = 7;
    DECLARE @status_success SMALLINT = 3;
    DECLARE @status_failed SMALLINT = 4;
    DECLARE @status_blocked SMALLINT = 8;
    DECLARE @status_running SMALLINT = 2;
    DECLARE @status_observed SMALLINT = 6;
    DECLARE @status_skipped SMALLINT = 5;
    DECLARE @status_cancelled SMALLINT = 9;

    -- Status code IDs are controlled framework constants inserted by seed scripts and should not be changed after deployment.

    IF NOT EXISTS
    (
        SELECT 1
        FROM [runtime].[execution_plans]
        WHERE [id] = @p_execution_plan_id
        AND [end_plan_date] IS NULL
    )
    BEGIN
        ;THROW 50026, 'Execution plan was not found or is already closed.', 1;
    END;

    UPDATE epp
    SET
        [status_code_id] =
            CASE
                WHEN EXISTS
                (
                    SELECT 1
                    FROM [metadata].[project_process_dependencies] ppd
                    INNER JOIN [runtime].[execution_plan_processes] dependency_epp
                        ON dependency_epp.[execution_plan_id] = epp.[execution_plan_id]
                        AND dependency_epp.[project_process_id] = ppd.[dependency_project_process_id]
                    WHERE ppd.[project_process_id] = epp.[project_process_id]
                    AND dependency_epp.[status_code_id] IN (@status_failed, @status_blocked)
                )
                THEN @status_blocked

                WHEN NOT EXISTS
                (
                    SELECT 1
                    FROM [metadata].[project_process_dependencies] ppd
                    INNER JOIN [runtime].[execution_plan_processes] dependency_epp
                        ON dependency_epp.[execution_plan_id] = epp.[execution_plan_id]
                        AND dependency_epp.[project_process_id] = ppd.[dependency_project_process_id]
                    WHERE ppd.[project_process_id] = epp.[project_process_id]
                    AND dependency_epp.[status_code_id] <> @status_success
                )
                THEN @status_ready

                ELSE @status_pending
            END,
        [dependency_evaluation_details] =
            CASE
                WHEN EXISTS
                (
                    SELECT 1
                    FROM [metadata].[project_process_dependencies] ppd
                    INNER JOIN [runtime].[execution_plan_processes] dependency_epp
                        ON dependency_epp.[execution_plan_id] = epp.[execution_plan_id]
                        AND dependency_epp.[project_process_id] = ppd.[dependency_project_process_id]
                    WHERE ppd.[project_process_id] = epp.[project_process_id]
                    AND dependency_epp.[status_code_id] IN (@status_failed, @status_blocked)
                )
                THEN 'At least one included dependency is failed or blocked.'

                WHEN NOT EXISTS
                (
                    SELECT 1
                    FROM [metadata].[project_process_dependencies] ppd
                    INNER JOIN [runtime].[execution_plan_processes] dependency_epp
                        ON dependency_epp.[execution_plan_id] = epp.[execution_plan_id]
                        AND dependency_epp.[project_process_id] = ppd.[dependency_project_process_id]
                    WHERE ppd.[project_process_id] = epp.[project_process_id]
                    AND dependency_epp.[status_code_id] <> @status_success
                )
                THEN 'All included dependencies are successful or no included dependencies exist.'

                ELSE 'One or more included dependencies are not complete.'
            END
    FROM [runtime].[execution_plan_processes] epp
    WHERE epp.[execution_plan_id] = @p_execution_plan_id
    AND epp.[status_code_id] NOT IN
    (
        @status_running,
        @status_success,
        @status_failed,
        @status_observed,
        @status_skipped,
        @status_cancelled
    );
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_close_execution_plan]
    @p_execution_plan_id BIGINT,
    @p_cancel BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Purpose:
        - Closes or cancels an open execution plan.
        - Derives the final plan status from plan process statuses.

        Important:
        - Plans cannot close while a plan process is Running.
        - Cancellation marks remaining non-final plan processes as Cancelled.
    */

    DECLARE @status_ready SMALLINT = 7;
    DECLARE @status_running SMALLINT = 2;
    DECLARE @status_success SMALLINT = 3;
    DECLARE @status_failed SMALLINT = 4;
    DECLARE @status_observed SMALLINT = 6;
    DECLARE @status_skipped SMALLINT = 5;
    DECLARE @status_cancelled SMALLINT = 9;
    DECLARE @final_status_code_id SMALLINT;

    -- Status code IDs are controlled framework constants inserted by seed scripts and should not be changed after deployment.
    BEGIN TRY
        IF NOT EXISTS
        (
            SELECT 1
            FROM [runtime].[execution_plans]
            WHERE [id] = @p_execution_plan_id
            AND [end_plan_date] IS NULL
        )
        BEGIN
            ;THROW 50027, 'Execution plan was not found or is already closed.', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM [runtime].[execution_plan_processes]
            WHERE [execution_plan_id] = @p_execution_plan_id
            AND [status_code_id] = @status_running
        )
        BEGIN
            ;THROW 50028, 'Execution plan cannot be closed because one or more plan processes are running.', 1;
        END;

        IF @p_cancel = 1
        BEGIN
            SET @final_status_code_id = @status_cancelled;
        END
        ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM [runtime].[execution_plan_processes]
            WHERE [execution_plan_id] = @p_execution_plan_id
        )
        BEGIN
            SET @final_status_code_id = @status_observed;
        END
        ELSE IF EXISTS
        (
            SELECT 1
            FROM [runtime].[execution_plan_processes]
            WHERE [execution_plan_id] = @p_execution_plan_id
            AND [status_code_id] = @status_failed
        )
        BEGIN
            SET @final_status_code_id = @status_failed;
        END
        ELSE IF EXISTS
        (
            SELECT 1
            FROM [runtime].[execution_plan_processes]
            WHERE [execution_plan_id] = @p_execution_plan_id
            AND [status_code_id] = @status_observed
        )
        BEGIN
            SET @final_status_code_id = @status_observed;
        END
        ELSE IF EXISTS
        (
            SELECT 1
            FROM [runtime].[execution_plan_processes]
            WHERE [execution_plan_id] = @p_execution_plan_id
            AND [status_code_id] NOT IN (@status_success, @status_skipped)
        )
        BEGIN
            ;THROW 50029, 'Execution plan cannot be closed because one or more plan processes are not in a final status.', 1;
        END
        ELSE
        BEGIN
            SET @final_status_code_id = @status_success;
        END;

        BEGIN TRANSACTION;

        IF @p_cancel = 1
        BEGIN
            UPDATE [runtime].[execution_plan_processes]
            SET [status_code_id] = @status_cancelled
            WHERE [execution_plan_id] = @p_execution_plan_id
            AND [status_code_id] NOT IN (@status_success, @status_failed, @status_observed, @status_skipped);
        END;

        UPDATE [runtime].[execution_plans]
        SET
            [status_code_id] = @final_status_code_id,
            [end_plan_date] = SYSUTCDATETIME()
        WHERE [id] = @p_execution_plan_id
        AND [end_plan_date] IS NULL;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_register_execution_watermark]
    @p_execution_step_id BIGINT,
    @p_execution_watermark_control_id BIGINT,
    @p_extraction_upper_bound_value NVARCHAR(4000)
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Purpose:
        - Registers the watermark range used by one execution step.
        - Captures the previous committed value from the active watermark control.

        Status behavior:
        - New execution watermark records are created with Pending status.
    */

    DECLARE @status_code_id_pending SMALLINT = 1;
    DECLARE @project_process_id INT;
    DECLARE @control_project_process_id INT;
    DECLARE @previous_committed_watermark_value NVARCHAR(4000);

    -- Status code IDs are controlled framework constants inserted by seed scripts and should not be changed after deployment.

    SELECT
        @project_process_id = [project_process_id]
    FROM [runtime].[execution_steps]
    WHERE [id] = @p_execution_step_id;

    IF @project_process_id IS NULL
    BEGIN
        ;THROW 50030, 'Execution step was not found.', 1;
    END;

    SELECT
        @control_project_process_id = [project_process_id],
        @previous_committed_watermark_value = [last_committed_watermark_value]
    FROM [runtime].[execution_watermark_controls]
    WHERE [id] = @p_execution_watermark_control_id
    AND [is_active] = 1;

    IF @control_project_process_id IS NULL
    BEGIN
        ;THROW 50031, 'Execution watermark control was not found or is inactive.', 1;
    END;

    IF @control_project_process_id <> @project_process_id
    BEGIN
        ;THROW 50032, 'Execution watermark control does not belong to the execution step process.', 1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM [runtime].[execution_watermarks]
        WHERE [execution_step_id] = @p_execution_step_id
        AND [execution_watermark_control_id] = @p_execution_watermark_control_id
    )
    BEGIN
        ;THROW 50033, 'Execution watermark is already registered for this step and control.', 1;
    END;

    INSERT INTO [runtime].[execution_watermarks]
    (
        [execution_step_id],
        [execution_watermark_control_id],
        [previous_committed_watermark_value],
        [extraction_upper_bound_value],
        [status_code_id]
    )
    VALUES
    (
        @p_execution_step_id,
        @p_execution_watermark_control_id,
        @previous_committed_watermark_value,
        @p_extraction_upper_bound_value,
        @status_code_id_pending
    );

    SELECT CAST(SCOPE_IDENTITY() AS BIGINT) AS [execution_watermark_id];
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_commit_execution_watermark]
    @p_execution_watermark_id BIGINT,
    @p_status_code_id SMALLINT,
    @p_candidate_watermark_value NVARCHAR(4000),
    @p_committed_watermark_value NVARCHAR(4000) = NULL,
    @p_allow_observed_commit BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Purpose:
        - Finalizes one execution watermark record.
        - Commits the watermark control value only for Success or explicitly accepted Observed outcomes.

        Important:
        - Failed, Blocked, Skipped, Cancelled, and non-accepted Observed outcomes update history only.
    */

    DECLARE @status_success SMALLINT = 3;
    DECLARE @status_failed SMALLINT = 4;
    DECLARE @status_skipped SMALLINT = 5;
    DECLARE @status_observed SMALLINT = 6;
    DECLARE @status_blocked SMALLINT = 8;
    DECLARE @status_cancelled SMALLINT = 9;
    DECLARE @execution_watermark_control_id BIGINT;
    DECLARE @final_committed_watermark_value NVARCHAR(4000);
    DECLARE @should_commit BIT = 0;

    -- Status code IDs are controlled framework constants inserted by seed scripts and should not be changed after deployment.
    BEGIN TRY
        IF @p_status_code_id NOT IN
        (
            @status_success,
            @status_failed,
            @status_skipped,
            @status_observed,
            @status_blocked,
            @status_cancelled
        )
        BEGIN
            ;THROW 50034, 'Watermark final status must be Success, Failed, Skipped, Observed, Blocked, or Cancelled.', 1;
        END;

        SELECT
            @execution_watermark_control_id = [execution_watermark_control_id]
        FROM [runtime].[execution_watermarks]
        WHERE [id] = @p_execution_watermark_id;

        IF @execution_watermark_control_id IS NULL
        BEGIN
            ;THROW 50035, 'Execution watermark was not found.', 1;
        END;

        IF @p_status_code_id = @status_success
        OR (@p_status_code_id = @status_observed AND @p_allow_observed_commit = 1)
        BEGIN
            SET @should_commit = 1;
        END;

        SET @final_committed_watermark_value = COALESCE(@p_committed_watermark_value, @p_candidate_watermark_value);

        IF @should_commit = 1
        AND @final_committed_watermark_value IS NULL
        BEGIN
            ;THROW 50036, 'Committed watermark value is required.', 1;
        END;

        BEGIN TRANSACTION;

        UPDATE [runtime].[execution_watermarks]
        SET
            [candidate_watermark_value] = @p_candidate_watermark_value,
            [committed_watermark_value] =
                CASE
                    WHEN @should_commit = 1 THEN @final_committed_watermark_value
                    ELSE [committed_watermark_value]
                END,
            [status_code_id] = @p_status_code_id
        WHERE [id] = @p_execution_watermark_id;

        IF @should_commit = 1
        BEGIN
            UPDATE [runtime].[execution_watermark_controls]
            SET [last_committed_watermark_value] = @final_committed_watermark_value
            WHERE [id] = @execution_watermark_control_id;
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_start_execution_run]
    @p_project_id SMALLINT,
    @p_execution_plan_id BIGINT = NULL
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
    DECLARE @execution_run_id BIGINT;

    -------------------------------------------------------------------------
    -- Validate status code.
    -- Running must exist and be active in reference.status_codes.
    -------------------------------------------------------------------------

    -- Status code IDs are controlled framework constants inserted by seed scripts and should not be changed after deployment.
    BEGIN TRY
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
        -- Validate execution plan when provided.
        -- The plan must belong to the same project and must still be open.
        -------------------------------------------------------------------------

        IF @p_execution_plan_id IS NOT NULL
        AND NOT EXISTS
        (
            SELECT 1
            FROM [runtime].[execution_plans]
            WHERE [id] = @p_execution_plan_id
            AND [project_id] = @p_project_id
            AND [end_plan_date] IS NULL
        )
        BEGIN
            ;THROW 50015, 'Execution plan was not found, is closed, or does not belong to the project.', 1;
        END;

        BEGIN TRANSACTION;

        -------------------------------------------------------------------------
        -- Register execution run.
        -------------------------------------------------------------------------

        INSERT INTO [runtime].[execution_runs]
        (
            [status_code_id],
            [project_id],
            [execution_plan_id]
        )
        VALUES
        (
            @status_code_id_running,
            @p_project_id,
            @p_execution_plan_id
        );

        SET @execution_run_id = CAST(SCOPE_IDENTITY() AS BIGINT);

        IF @p_execution_plan_id IS NOT NULL
        BEGIN
            UPDATE [runtime].[execution_plans]
            SET
                [status_code_id] = @status_code_id_running,
                [start_plan_date] = COALESCE([start_plan_date], SYSUTCDATETIME())
            WHERE [id] = @p_execution_plan_id
            AND [end_plan_date] IS NULL;
        END;

        COMMIT TRANSACTION;

        SELECT @execution_run_id AS [execution_run_id];
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_start_execution_step]
    @p_execution_run_id BIGINT,
    @p_project_process_id INT,
    @p_execution_plan_process_id BIGINT = NULL
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
    DECLARE @status_code_id_ready SMALLINT = 7;
    DECLARE @execution_run_project_id SMALLINT;
    DECLARE @execution_plan_id BIGINT;
    DECLARE @execution_step_id BIGINT;

    -------------------------------------------------------------------------
    -- Validate status code.
    -------------------------------------------------------------------------

    -- Status code IDs are controlled framework constants inserted by seed scripts and should not be changed after deployment.
    BEGIN TRY
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
        -- Validate execution run.
        -- The run must exist and must still be open.
        -------------------------------------------------------------------------

        SELECT
            @execution_run_project_id = [project_id],
            @execution_plan_id = [execution_plan_id]
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
        -- Assign or validate the execution plan process when the run is linked
        -- to an execution plan.
        -------------------------------------------------------------------------

        IF @p_execution_plan_process_id IS NULL
        AND @execution_plan_id IS NOT NULL
        BEGIN
            SELECT
                @p_execution_plan_process_id = [id]
            FROM [runtime].[execution_plan_processes]
            WHERE [execution_plan_id] = @execution_plan_id
            AND [project_process_id] = @p_project_process_id;
        END;

        IF @p_execution_plan_process_id IS NOT NULL
        AND NOT EXISTS
        (
            SELECT 1
            FROM [runtime].[execution_plan_processes] epp
            INNER JOIN [runtime].[execution_plans] ep
                ON ep.[id] = epp.[execution_plan_id]
            WHERE epp.[id] = @p_execution_plan_process_id
            AND epp.[project_process_id] = @p_project_process_id
            AND ep.[project_id] = @execution_run_project_id
            AND (@execution_plan_id IS NULL OR epp.[execution_plan_id] = @execution_plan_id)
        )
        BEGIN
            ;THROW 50016, 'Execution plan process was not found or does not match the execution step context.', 1;
        END;

        IF @p_execution_plan_process_id IS NOT NULL
        AND NOT EXISTS
        (
            SELECT 1
            FROM [runtime].[execution_plan_processes]
            WHERE [id] = @p_execution_plan_process_id
            AND [status_code_id] = @status_code_id_ready
        )
        BEGIN
            ;THROW 50017, 'Execution plan process must be Ready before an execution step can start.', 1;
        END;

        BEGIN TRANSACTION;

        -------------------------------------------------------------------------
        -- Register execution step.
        -------------------------------------------------------------------------

        INSERT INTO [runtime].[execution_steps]
        (
            [status_code_id],
            [execution_run_id],
            [project_process_id],
            [execution_plan_process_id]
        )
        VALUES
        (
            @status_code_id_running,
            @p_execution_run_id,
            @p_project_process_id,
            @p_execution_plan_process_id
        );

        SET @execution_step_id = CAST(SCOPE_IDENTITY() AS BIGINT);

        IF @p_execution_plan_process_id IS NOT NULL
        BEGIN
            UPDATE [runtime].[execution_plan_processes]
            SET [status_code_id] = @status_code_id_running
            WHERE [id] = @p_execution_plan_process_id;
        END;

        COMMIT TRANSACTION;

        SELECT @execution_step_id AS [execution_step_id];
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        THROW;
    END CATCH;
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

    DECLARE @execution_plan_process_id BIGINT;
    DECLARE @execution_plan_id BIGINT;
    DECLARE @status_success SMALLINT = 3;
    DECLARE @status_failed SMALLINT = 4;
    DECLARE @status_skipped SMALLINT = 5;
    DECLARE @status_observed SMALLINT = 6;

    -- Status code IDs are controlled framework constants inserted by seed scripts and should not be changed after deployment.
    BEGIN TRY
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

        SELECT
            @execution_plan_process_id = [execution_plan_process_id]
        FROM [runtime].[execution_steps]
        WHERE [id] = @p_execution_step_id
        AND [end_step_date] IS NULL;

        BEGIN TRANSACTION;

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

        IF @execution_plan_process_id IS NOT NULL
        AND @p_status_code_id IN (@status_success, @status_failed, @status_skipped, @status_observed)
        BEGIN
            UPDATE [runtime].[execution_plan_processes]
            SET [status_code_id] = @p_status_code_id
            WHERE [id] = @execution_plan_process_id;

            SELECT
                @execution_plan_id = [execution_plan_id]
            FROM [runtime].[execution_plan_processes]
            WHERE [id] = @execution_plan_process_id;

            /*
                Dependency readiness is re-evaluated automatically after a
                plan-linked step reaches a final status. This keeps downstream
                plan processes in READY, BLOCKED, or PENDING.
            */
            EXEC [runtime].[usp_evaluate_execution_plan_dependencies]
                @p_execution_plan_id = @execution_plan_id;
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_end_parent_execution_step]
    @p_execution_step_id BIGINT
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

    DECLARE @execution_run_id BIGINT;
    DECLARE @parent_project_process_id INT;

    DECLARE @status_pending SMALLINT = 1;
    DECLARE @status_running SMALLINT = 2;
    DECLARE @status_success SMALLINT = 3;
    DECLARE @status_failed SMALLINT = 4;
    DECLARE @status_observed SMALLINT = 6;

    DECLARE @final_status_code_id SMALLINT;

    -- Status code IDs are controlled framework constants inserted by seed scripts and should not be changed after deployment.

    /*
        Get the execution run and the process represented by the parent step.
    */
    SELECT
        @execution_run_id = [execution_run_id],
        @parent_project_process_id = [project_process_id]
    FROM [runtime].[execution_steps]
    WHERE [id] = @p_execution_step_id
    AND [end_step_date] IS NULL;

    IF @execution_run_id IS NULL
    BEGIN
        ;THROW 51000, 'Execution step was not found or is already closed.', 1;
    END;

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
    @p_parent_execution_step_id BIGINT
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

    DECLARE @execution_run_id BIGINT;
    DECLARE @parent_project_process_id INT;
    DECLARE @execution_plan_id BIGINT;
    DECLARE @status_code_id_skipped SMALLINT = 5;

    -- Status code IDs are controlled framework constants inserted by seed scripts and should not be changed after deployment.
    BEGIN TRY
        -------------------------------------------------------------------------
        -- Validate status code.
        -------------------------------------------------------------------------

        IF NOT EXISTS
        (
            SELECT 1
            FROM [reference].[status_codes]
            WHERE [id] = @status_code_id_skipped
            AND [is_active] = 1
        )
        BEGIN
            ;THROW 50005, 'Status code Skipped was not found or is inactive.', 1;
        END;

        /*
            Get the execution run and parent process represented by the parent step.
        */
        SELECT
            @execution_run_id = [execution_run_id],
            @parent_project_process_id = [project_process_id],
            @execution_plan_id = er.[execution_plan_id]
        FROM [runtime].[execution_steps] es
        INNER JOIN [runtime].[execution_runs] er
            ON er.[id] = es.[execution_run_id]
        WHERE es.[id] = @p_parent_execution_step_id
        AND es.[end_step_date] IS NULL;

        IF @execution_run_id IS NULL
        BEGIN
            ;THROW 51000, 'Parent execution step was not found or is already closed.', 1;
        END;

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

        BEGIN TRANSACTION;

        /*
            Register SKIPPED steps for active non-required direct child processes
            that do not already have an execution step in this run.
        */
        INSERT INTO [runtime].[execution_steps]
        (
            [execution_run_id],
            [project_process_id],
            [execution_plan_process_id],
            [status_code_id],
            [start_step_date],
            [end_step_date]
        )
        SELECT
            @execution_run_id,
            child.[id],
            epp.[id],
            @status_code_id_skipped,
            SYSUTCDATETIME(),
            SYSUTCDATETIME()
        FROM [metadata].[project_processes] child
        LEFT JOIN [runtime].[execution_steps] child_step
            ON child_step.[project_process_id] = child.[id]
            AND child_step.[execution_run_id] = @execution_run_id
        LEFT JOIN [runtime].[execution_plan_processes] epp
            ON epp.[execution_plan_id] = @execution_plan_id
            AND epp.[project_process_id] = child.[id]
        WHERE child.[parent_process_id] = @parent_project_process_id
        AND child.[is_active] = 1
        AND child.[execution_required] = 0
        AND child_step.[id] IS NULL;

        IF @execution_plan_id IS NOT NULL
        BEGIN
            UPDATE epp
            SET [status_code_id] = @status_code_id_skipped
            FROM [runtime].[execution_plan_processes] epp
            INNER JOIN [metadata].[project_processes] child
                ON child.[id] = epp.[project_process_id]
            WHERE epp.[execution_plan_id] = @execution_plan_id
            AND child.[parent_process_id] = @parent_project_process_id
            AND child.[is_active] = 1
            AND child.[execution_required] = 0;
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_end_execution_run]
    @p_execution_run_id BIGINT
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
    */

    DECLARE @status_pending SMALLINT = 1;
    DECLARE @status_running SMALLINT = 2;
    DECLARE @status_success SMALLINT = 3;
    DECLARE @status_failed SMALLINT = 4;
    DECLARE @status_observed SMALLINT = 6;

    DECLARE @final_status_code_id SMALLINT;

    -- Status code IDs are controlled framework constants inserted by seed scripts and should not be changed after deployment.

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

    BEGIN TRY
        SELECT
            @project_process_id = es.[project_process_id]
        FROM [runtime].[execution_steps] es
        WHERE es.[id] = @p_execution_step_id;

        IF @project_process_id IS NULL
        BEGIN
            ;THROW 51000, 'Execution step was not found.', 1;
        END;

        BEGIN TRANSACTION;

        /*
            Controlled idempotent recalculation:
            monitoring results for this execution step are deleted and recalculated
            by this procedure so repeated captures produce one current result per
            configured monitoring metric.
        */
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

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        THROW;
    END CATCH;
END;
GO
