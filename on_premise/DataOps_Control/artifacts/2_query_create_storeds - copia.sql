USE [DataOps_Control];
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_start_execution_run]
	@p_project_id SMALLINT
AS
BEGIN
SET NOCOUNT ON;
	-- Status: Pending
	INSERT INTO [runtime].[execution_runs] ([status_code_id], [project_id]) VALUES (2, @p_project_id);
	SELECT SCOPE_IDENTITY() AS [Id];
SET NOCOUNT OFF;
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_end_execution_run]
	@p_execution_run_id INT,
	@p_status_code_id SMALLINT -- Status: Success / Failed
AS
BEGIN
SET NOCOUNT ON;
	UPDATE [runtime].[execution_runs]
	SET
		[end_run_date] = SYSUTCDATETIME(),
		[status_code_id] = @p_status_code_id
	WHERE [id] = @p_execution_run_id;
SET NOCOUNT OFF;
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_start_execution_step]
	@p_execution_run_id INT,
	@p_project_process_id INT
AS
BEGIN
SET NOCOUNT ON;
	INSERT INTO [runtime].[execution_steps]
	(
		[status_code_id],
		[execution_run_id],
		[project_process_id]
	)
	VALUES
	(
		2, -- Status: Pending
		@p_execution_run_id,
		@p_project_process_id
	);
SET NOCOUNT OFF;
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_end_execution_step]
	@p_execution_step_id BIGINT,
	@p_status_code_id SMALLINT -- Status: Success / Failed
AS
BEGIN
SET NOCOUNT ON;
	UPDATE [runtime].[execution_steps]
	SET
		[end_run_date] = SYSUTCDATETIME(),
		[status_code_id] = @p_status_code_id
	WHERE [id] = @p_execution_step_id;
SET NOCOUNT OFF;
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
	LEFT JOIN [metadata].[project_table_process_mappings] tp2 ON tp2.[process_id] = p2.[id]
	LEFT JOIN [metadata].[project_tables] t ON t.[id] = tp2.[table_id] AND t.[is_active] = 1 AND t.[batch_column_active] = @p_batch_column_active --AND t.[rerun_required] = 1
	WHERE p1.[project_id] = @p_project_id
	AND p1.[id] = @p_process_id
	AND p1.[is_active] = 1
);
GO

CREATE OR ALTER FUNCTION [metadata].[ufn_list_project_table_batches_by_table]
(
	@p_project_table_id INT
)
RETURNS TABLE
AS
RETURN
(
	WITH batch_bounds AS (
		SELECT
			CONVERT(DATETIME, b.[batch_start_value]) AS batch_start_value,
			CONVERT(DATETIME, b.[batch_end_value]) AS batch_end_value
		FROM [metadata].[project_table_batches] b
		WHERE b.[table_id] = @p_project_table_id
		AND b.[is_active] = 1
	),
	month_series AS (
		SELECT
			b.batch_start_value,
			b.batch_end_value,
			DATEADD(MONTH, gs.[value], DATETRUNC(MONTH, b.batch_start_value)) AS month_start
		FROM batch_bounds b
		CROSS APPLY GENERATE_SERIES(
			0,
			DATEDIFF(MONTH, DATETRUNC(MONTH, b.batch_start_value), DATETRUNC(MONTH, b.batch_end_value))
		) gs
	)
	SELECT
		CASE
			WHEN month_start < batch_start_value THEN batch_start_value
			ELSE month_start
		END AS batch_start_value,

		CASE
			WHEN DATEADD(SECOND, -1, DATEADD(MONTH, 1, month_start)) > batch_end_value THEN batch_end_value
			ELSE DATEADD(SECOND, -1, DATEADD(MONTH, 1, month_start))
		END AS batch_end_value
	FROM month_series
);
GO

CREATE OR ALTER FUNCTION [metadata].[ufn_list_columns_rules]
(
	@p_project_id SMALLINT,
	@p_database_name VARCHAR(50)
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		d.[id] AS [database_id],
		d.[name] AS [database_name],
		t.[id] AS [table_id],
		t.[schema_name],
		t.[name] AS [table_name],
		c.[position] AS [column_position],
		c.[name] AS [column_name],
		c.[type] AS [column_type],
		c.[size] AS [column_size],
		c.[size_scale] AS [column_size_scale],
		c.[default_value] AS [column_default_value],
		c.[is_nullable],
		c.[is_watermark],
		c.[is_reconciliation_column]
	FROM [metadata].[project_databases] d
	INNER JOIN [metadata].[project_tables] t ON t.[database_id] = d.[id]
	INNER JOIN [metadata].[project_columns] c ON c.[table_id] = t.[id]
	WHERE d.[project_id] = @p_project_id
	AND d.[name] = @p_database_name
	AND d.[is_active] = 1
	AND t.[is_active] = 1
	AND c.[is_active] = 1
);
GO

CREATE OR ALTER PROCEDURE [observability].[usp_log_error]
	@p_execution_step_id BIGINT,
	@p_error_source VARCHAR(200),
	@p_details VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

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

	SELECT
		[id],
		[error_source],
		[details],
		[execution_step_id],
		[created_at]
	FROM [observability].[error_logs]
	WHERE [id] = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE [observability].[usp_record_reconciliation_result]
	@p_execution_step_id BIGINT,
	@p_metric_name VARCHAR(50),
	@p_reconciliation_side VARCHAR(20),
	@p_reconciliation_key VARCHAR(100) = NULL,
	@p_metric_value_decimal DECIMAL(20, 4) = NULL,
	@p_metric_value_bigint BIGINT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO [observability].[reconciliation_results]
	(
		[metric_name],
		[reconciliation_key],
		[reconciliation_side],
		[metric_value_decimal],
		[metric_value_bigint],
		[execution_step_id]
	)
	VALUES
	(
		@p_metric_name,
		@p_reconciliation_key,
		@p_reconciliation_side,
		@p_metric_value_decimal,
		@p_metric_value_bigint,
		@p_execution_step_id
	);

	SELECT
		[id],
		[metric_name],
		[reconciliation_key],
		[reconciliation_side],
		[metric_value_decimal],
		[metric_value_bigint],
		[execution_step_id],
		[created_at]
	FROM [observability].[reconciliation_results]
	WHERE [id] = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE [observability].[usp_record_validation_result]
	@p_execution_step_id BIGINT,
	@p_validation_code VARCHAR(50),
	@p_details VARCHAR(MAX),
	@p_affected_row_count BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @validation_code_id SMALLINT;

	SELECT @validation_code_id = [id]
	FROM [reference].[validation_codes]
	WHERE [code] = @p_validation_code
	AND [is_active] = 1;

	IF @validation_code_id IS NULL
	BEGIN
		THROW 50002, 'Invalid or inactive validation code.', 1;
	END;

	INSERT INTO [observability].[validation_results]
	(
		[details],
		[affected_row_count],
		[execution_step_id],
		[validation_code_id]
	)
	VALUES
	(
		@p_details,
		@p_affected_row_count,
		@p_execution_step_id,
		@validation_code_id
	);

	SELECT
		vr.[id],
		vc.[code] AS [validation_code],
		vc.[severity],
		vr.[details],
		vr.[affected_row_count],
		vr.[execution_step_id],
		vr.[created_at]
	FROM [observability].[validation_results] vr
	INNER JOIN [reference].[validation_codes] vc ON vc.[id] = vr.[validation_code_id]
	WHERE vr.[id] = SCOPE_IDENTITY();
END;
GO
