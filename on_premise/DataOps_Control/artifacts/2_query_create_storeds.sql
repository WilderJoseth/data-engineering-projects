USE [DataOps_Control];
GO

CREATE OR ALTER FUNCTION [reference].[ufn_get_status_code_id]
(
	@p_status_code VARCHAR(15)
)
RETURNS SMALLINT
AS
BEGIN
	DECLARE @status_code_id SMALLINT;

	SELECT @status_code_id = [id]
	FROM [reference].[status_codes]
	WHERE [code] = @p_status_code
	AND [is_active] = 1;

	RETURN @status_code_id;
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_start_execution_run]
	@p_project_id SMALLINT,
	@p_status_code VARCHAR(15) = 'STARTED'
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @status_code_id SMALLINT = [reference].[ufn_get_status_code_id](@p_status_code);

	IF @status_code_id IS NULL
	BEGIN
		THROW 50001, 'Invalid or inactive status code.', 1;
	END;

	INSERT INTO [runtime].[execution_runs] ([status_code_id], [project_id]) VALUES (@status_code_id, @p_project_id);

	SELECT
		er.[id],
		er.[project_id],
		sc.[code] AS [status_code],
		er.[start_run_date],
		er.[end_run_date],
		er.[created_by]
	FROM [runtime].[execution_runs] er
	INNER JOIN [reference].[status_codes] sc ON sc.[id] = er.[status_code_id]
	WHERE er.[id] = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_end_execution_run]
	@p_execution_run_id INT,
	@p_status_code VARCHAR(15) = 'COMPLETED'
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @status_code_id SMALLINT = [reference].[ufn_get_status_code_id](@p_status_code);

	IF @status_code_id IS NULL
	BEGIN
		THROW 50001, 'Invalid or inactive status code.', 1;
	END;

	UPDATE [runtime].[execution_runs]
	SET
		[end_run_date] = SYSUTCDATETIME(),
		[status_code_id] = @status_code_id
	WHERE [id] = @p_execution_run_id;

	SELECT
		er.[id],
		er.[project_id],
		sc.[code] AS [status_code],
		er.[start_run_date],
		er.[end_run_date],
		er.[created_by]
	FROM [runtime].[execution_runs] er
	INNER JOIN [reference].[status_codes] sc ON sc.[id] = er.[status_code_id]
	WHERE er.[id] = @p_execution_run_id;
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_start_execution_step]
	@p_execution_run_id INT,
	@p_project_process_id INT,
	@p_project_table_id INT = NULL,
	@p_project_table_batch_id INT = NULL,
	@p_status_code VARCHAR(15) = 'STARTED'
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @status_code_id SMALLINT = [reference].[ufn_get_status_code_id](@p_status_code);

	IF @status_code_id IS NULL
	BEGIN
		THROW 50001, 'Invalid or inactive status code.', 1;
	END;

	INSERT INTO [runtime].[execution_steps]
	(
		[status_code_id],
		[execution_run_id],
		[project_process_id],
		[project_table_id],
		[project_table_batch_id]
	)
	VALUES
	(
		@status_code_id,
		@p_execution_run_id,
		@p_project_process_id,
		@p_project_table_id,
		@p_project_table_batch_id
	);

	SELECT
		es.[id],
		es.[execution_run_id],
		es.[project_process_id],
		es.[project_table_id],
		es.[project_table_batch_id],
		sc.[code] AS [status_code],
		es.[start_run_date],
		es.[end_run_date],
		es.[created_by]
	FROM [runtime].[execution_steps] es
	INNER JOIN [reference].[status_codes] sc ON sc.[id] = es.[status_code_id]
	WHERE es.[id] = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE [runtime].[usp_end_execution_step]
	@p_execution_step_id BIGINT,
	@p_status_code VARCHAR(15) = 'COMPLETED'
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @status_code_id SMALLINT = [reference].[ufn_get_status_code_id](@p_status_code);

	IF @status_code_id IS NULL
	BEGIN
		THROW 50001, 'Invalid or inactive status code.', 1;
	END;

	UPDATE [runtime].[execution_steps]
	SET
		[end_run_date] = SYSUTCDATETIME(),
		[status_code_id] = @status_code_id
	WHERE [id] = @p_execution_step_id;

	SELECT
		es.[id],
		es.[execution_run_id],
		es.[project_process_id],
		es.[project_table_id],
		es.[project_table_batch_id],
		sc.[code] AS [status_code],
		es.[start_run_date],
		es.[end_run_date],
		es.[created_by]
	FROM [runtime].[execution_steps] es
	INNER JOIN [reference].[status_codes] sc ON sc.[id] = es.[status_code_id]
	WHERE es.[id] = @p_execution_step_id;
END;
GO

CREATE OR ALTER FUNCTION [metadata].[ufn_list_project_databases]
(
	@p_project_id SMALLINT
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		d.[id] AS [database_id],
		d.[name] AS [database_name],
		d.[platform_type],
		d.[database_role]
	FROM [metadata].[project_databases] d
	WHERE d.[project_id] = @p_project_id
	AND d.[is_active] = 1
);
GO

CREATE OR ALTER FUNCTION [metadata].[ufn_list_tables]
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
		t.[is_fact_table],
		t.[is_transactional_table],
		t.[batch_column_active],
		t.[rerun_required]
	FROM [metadata].[project_tables] t
	INNER JOIN [metadata].[project_databases] d ON d.[id] = t.[database_id]
	WHERE d.[project_id] = @p_project_id
	AND d.[name] = @p_database_name
	AND d.[is_active] = 1
	AND t.[is_active] = 1
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

CREATE OR ALTER FUNCTION [metadata].[ufn_list_table_batches]
(
	@p_project_id SMALLINT,
	@p_database_name VARCHAR(50),
	@p_table_name VARCHAR(50) = NULL
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
		b.[id] AS [batch_id],
		b.[batch_column_name],
		b.[batch_value],
		b.[batch_start_value],
		b.[batch_end_value],
		b.[column_type],
		b.[rerun_required]
	FROM [metadata].[project_table_batches] b
	INNER JOIN [metadata].[project_tables] t ON t.[id] = b.[table_id]
	INNER JOIN [metadata].[project_databases] d ON d.[id] = t.[database_id]
	WHERE d.[project_id] = @p_project_id
	AND d.[name] = @p_database_name
	AND (@p_table_name IS NULL OR t.[name] = @p_table_name)
	AND d.[is_active] = 1
	AND t.[is_active] = 1
	AND b.[is_active] = 1
);
GO

CREATE OR ALTER FUNCTION [metadata].[ufn_list_table_mappings]
(
	@p_project_id SMALLINT
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		st.[id] AS [source_table_id],
		sd.[name] AS [source_database_name],
		st.[schema_name] AS [source_schema_name],
		st.[name] AS [source_table_name],
		tt.[id] AS [target_table_id],
		td.[name] AS [target_database_name],
		tt.[schema_name] AS [target_schema_name],
		tt.[name] AS [target_table_name]
	FROM [metadata].[project_table_mappings] m
	INNER JOIN [metadata].[project_tables] st ON st.[id] = m.[table_source_id]
	INNER JOIN [metadata].[project_databases] sd ON sd.[id] = st.[database_id]
	INNER JOIN [metadata].[project_tables] tt ON tt.[id] = m.[table_target_id]
	INNER JOIN [metadata].[project_databases] td ON td.[id] = tt.[database_id]
	WHERE sd.[project_id] = @p_project_id
	AND td.[project_id] = @p_project_id
	AND sd.[is_active] = 1
	AND td.[is_active] = 1
	AND st.[is_active] = 1
	AND tt.[is_active] = 1
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
