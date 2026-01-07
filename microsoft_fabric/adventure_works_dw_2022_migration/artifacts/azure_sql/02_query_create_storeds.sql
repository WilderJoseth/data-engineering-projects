
----------------- START create sp -----------------
CREATE PROCEDURE dbo.usp_start_run
	@name VARCHAR(50),
	@project_id SMALLINT
AS
BEGIN
SET NOCOUNT ON
	DECLARE @start_process_date DATETIME
	SET @start_process_date = GETDATE()

	INSERT INTO dbo.runs (name, start_process_date, status, project_id)
	VALUES (@name, GETDATE(), 'STARTED', @project_id)

	SELECT id, FORMAT(start_process_date, 'yyyy-MM-dd HH:mm:ss') AS start_process_date
	FROM dbo.runs WHERE id = SCOPE_IDENTITY()
SET NOCOUNT OFF
END;

CREATE PROCEDURE dbo.usp_end_run
	@id INT
AS
BEGIN
SET NOCOUNT ON
	UPDATE dbo.runs SET end_process_date = GETDATE(), status = 'COMPLETED'
	WHERE id = @id
SET NOCOUNT OFF
END;

CREATE PROCEDURE dbo.usp_start_sub_run
	@run_id INT,
	@layer VARCHAR(50),
	@start_count INT
AS
BEGIN
SET NOCOUNT ON
	INSERT INTO dbo.sub_runs (run_id, start_process_date, status, layer, start_count)
	VALUES (@run_id, GETDATE(), 'STARTED', @layer, @start_count)
SET NOCOUNT OFF
END;

CREATE PROCEDURE dbo.usp_end_sub_run
	@run_id INT,
	@layer VARCHAR(50),
	@end_count INT
AS
BEGIN
SET NOCOUNT ON
	UPDATE dbo.sub_runs SET end_process_date = GETDATE(), end_count = @end_count, status = 'COMPLETED'
	WHERE run_id = @run_id
	AND layer = @layer
SET NOCOUNT OFF
END;

CREATE PROCEDURE dbo.usp_list_validation_rules
	@project_id INT
AS
BEGIN
	SELECT
		t.table_name,
		v.column_order,
		v.column_name_original,
		v.column_type,
		v.column_size,
		v.column_size_scale,
		v.default_value
	FROM dbo.project_tables t
	INNER JOIN dbo.validation_rules v ON v.table_id = t.id
	WHERE t.project_id = @project_id
	AND t.is_active = 1
	AND v.is_active = 1
END;

CREATE PROCEDURE dbo.usp_list_tables_project
	@project_id INT
AS
BEGIN
	SELECT t.id, t.table_name, t.is_fact_table, STRING_AGG(v.column_name_original, ',') AS column_names
	FROM dbo.project_tables t
	INNER JOIN dbo.validation_rules v ON v.table_id = t.id AND v.is_active = 1
	WHERE t.project_id = @project_id
	AND t.is_active = 1
	GROUP BY t.id, t.table_name, t.is_fact_table;
END;

CREATE PROCEDURE dbo.usp_list_years_fact_table_to_process
	@table_id INT
AS
BEGIN
	SELECT year
	FROM dbo.fact_table_years 
	WHERE table_id = @table_id
	AND is_active = 0
END;
----------------- END create sp -----------------
