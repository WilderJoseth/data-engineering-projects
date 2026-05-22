USE [DataOps_Control];
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_start_execution_run]
	@p_project_id SMALLINT
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @status_code_id_running SMALLINT = 2;
	INSERT INTO [runtime].[execution_runs] ([status_code_id], [project_id]) VALUES (@status_code_id_running, @p_project_id);

	SELECT CAST(SCOPE_IDENTITY() AS INT) AS [execution_run_id];
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_start_execution_step]
	@p_execution_run_id INT,
	@p_project_process_id INT
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @status_code_id_running SMALLINT = 2;
	INSERT INTO [runtime].[execution_steps]	([status_code_id], [execution_run_id], [project_process_id]) 
	VALUES (@status_code_id_running, @p_execution_run_id, @p_project_process_id);

    SELECT CAST(SCOPE_IDENTITY() AS BIGINT) AS [execution_step_id];
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_end_execution_run]
	@p_execution_run_id INT
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @status_pending SMALLINT = 1;
	DECLARE @status_running SMALLINT = 2;
    DECLARE @status_success SMALLINT = 3;
    DECLARE @status_failed SMALLINT = 4;
    DECLARE @status_observed SMALLINT = 7;

    DECLARE @final_status_code_id SMALLINT;

	IF NOT EXISTS
	(
		SELECT 1
		FROM [runtime].[execution_steps]
		WHERE [execution_run_id] = @p_execution_run_id
	)
	BEGIN
		SET @final_status_code_id = @status_observed;
	END
	ELSE IF EXISTS
	(
		SELECT 1
		FROM [runtime].[execution_steps]
		WHERE [execution_run_id] = @p_execution_run_id
		AND [status_code_id] IN (@status_pending, @status_running)
	)
	BEGIN
		THROW 50001, 'Execution run cannot be ended because one or more steps are still pending or running.', 1;
	END
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
    ELSE
    BEGIN
        SET @final_status_code_id = @status_success;
    END;

    UPDATE [runtime].[execution_runs]
    SET
        [end_run_date] = SYSUTCDATETIME(),
        [status_code_id] = @final_status_code_id
    WHERE [id] = @p_execution_run_id;
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_end_execution_step]
	@p_execution_step_id BIGINT,
	@p_status_code_id SMALLINT
AS
BEGIN
SET NOCOUNT ON;
	UPDATE [runtime].[execution_steps]
	SET
		[end_run_date] = SYSUTCDATETIME(),
		[status_code_id] = @p_status_code_id
	WHERE [id] = @p_execution_step_id;
END;
GO

CREATE OR ALTER FUNCTION [metadata].[ufn_list_project_processes_tables]
(
	@p_project_id SMALLINT,
	@p_process_id INT,
	@p_batch_column_active BIT 
)
RETURNS TABLE
AS
RETURN
(
	SELECT 
		p1.[name] AS [process_name], 
		p2.[name] AS [process_child_name],
		t.[id] AS [table_id],
		t.[schema_name] AS [table_schema_name], 
		t.[name] AS [table_name],
		t.[rerun_required]
	FROM [metadata].[project_processes] p1
	LEFT JOIN [metadata].[project_processes] p2 ON p2.[parent_process_id] = p1.[id] AND p2.[is_active] = 1
	LEFT JOIN [metadata].[project_process_tables] pt2 ON pt2.[process_id] = p2.[id]
	LEFT JOIN [metadata].[project_tables] t ON t.[id] = pt2.[table_id] AND t.[is_active] = 1 AND t.[batch_column_active] = @p_batch_column_active
	WHERE p1.[project_id] = @p_project_id
	AND p1.[id] = @p_process_id
	AND p1.[is_active] = 1
);
GO

CREATE OR ALTER PROCEDURE [observability].[usp_log_error]
	@p_execution_step_id BIGINT,
	@p_error_source VARCHAR(200),
	@p_details VARCHAR(MAX)
AS
BEGIN
SET NOCOUNT ON;
	INSERT INTO [observability].[error_logs] ([error_source], [details], [execution_step_id])
	VALUES (@p_error_source, @p_details, @p_execution_step_id);
END;
GO

/*
CREATE OR ALTER FUNCTION [observability].[ufn_get_reconciliation_status]
(
    @p_execution_step_id BIGINT
)
RETURNS TABLE
AS
RETURN
(
    WITH reconciliation_pairs AS
    (
        SELECT
            [metric_name],
            [reconciliation_key],
            MAX(CASE WHEN [reconciliation_side] = 'SOURCE' THEN [metric_value_bigint] END) AS source_bigint_value,
            MAX(CASE WHEN [reconciliation_side] = 'TARGET' THEN [metric_value_bigint] END) AS target_bigint_value,
            MAX(CASE WHEN [reconciliation_side] = 'SOURCE' THEN [metric_value_decimal] END) AS source_decimal_value,
            MAX(CASE WHEN [reconciliation_side] = 'TARGET' THEN [metric_value_decimal] END) AS target_decimal_value
        FROM [observability].[reconciliation_results]
        WHERE [execution_step_id] = @p_execution_step_id
        GROUP BY [metric_name], [reconciliation_key]
    ),
    evaluation AS
    (
        SELECT
            COUNT(*) AS metric_count,
            SUM
            (
                CASE
                    WHEN
                        ISNULL(source_bigint_value, -9223372036854775808) <> ISNULL(target_bigint_value, -9223372036854775808)
                        OR
                        ISNULL(source_decimal_value, -9999999999999999.9999) <> ISNULL(target_decimal_value, -9999999999999999.9999)
                    THEN 1
                    ELSE 0
                END
            ) AS observed_count
        FROM reconciliation_pairs
    )
    SELECT
        CASE
            WHEN metric_count = 0 THEN 7       -- Observed: reconciliation missing
            WHEN observed_count > 0 THEN 7     -- Observed: mismatch found
            ELSE 3                             -- Success
        END AS status_code_id,
        metric_count,
        observed_count
    FROM evaluation
);
GO
*/