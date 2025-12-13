USE control_db;

CREATE SCHEMA study_space_missions_db;

------------------------- Start tables -------------------------
CREATE TABLE study_space_missions_db.runs (
	id INT IDENTITY NOT NULL,
	start_process_date DATETIME NOT NULL,
	end_process_date DATETIME NULL,
	status VARCHAR(15) NOT NULL,

	CONSTRAINT study_space_missions_db_runs PRIMARY KEY(id)
);

CREATE TABLE study_space_missions_db.sub_runs (
	id INT IDENTITY NOT NULL,
	run_id INT NOT NULL,
	start_process_date DATETIME NOT NULL,
	end_process_date DATETIME NULL,
	layer VARCHAR(20) NOT NULL,
	start_count INT NOT NULL,
	end_count INT NULL,
	status VARCHAR(15) NOT NULL,

	CONSTRAINT study_space_missions_db_sub_runs PRIMARY KEY(id),
	CONSTRAINT study_space_missions_db_sub_runs_run_id FOREIGN KEY(run_id) REFERENCES study_space_missions_db.runs(id)
);

CREATE TABLE study_space_missions_db.logs (
	id INT IDENTITY NOT NULL,
	run_id INT NOT NULL,
	code CHAR(2) NOT NULL,
	description VARCHAR(200) NOT NULL,

	CONSTRAINT study_space_missions_db_logs PRIMARY KEY(id),
	CONSTRAINT study_space_missions_db_logs_run_id FOREIGN KEY(run_id) REFERENCES study_space_missions_db.runs(id)
);

CREATE TABLE study_space_missions_db.validation_rules (
	id SMALLINT IDENTITY NOT NULL,
	schema_name VARCHAR(20) NOT NULL,
	table_name VARCHAR(20) NOT NULL,
	column_order SMALLINT NOT NULL,
	column_name_original VARCHAR(20) NULL,
	column_name_new VARCHAR(20) NOT NULL,
	column_type VARCHAR(20) NOT NULL,
	column_size SMALLINT NULL,
	column_size_scale SMALLINT NULL,
	default_value VARCHAR(50) NULL,
	is_from_file BIT NOT NULL,
	is_active BIT NOT NULL,

	CONSTRAINT study_space_missions_db_validation_rules PRIMARY KEY(id)
);
------------------------- End tables -------------------------

------------------------- Start storeds -------------------------
CREATE PROCEDURE study_space_missions_db.usp_start_run
AS
BEGIN
SET NOCOUNT ON
	DECLARE @start_process_date DATETIME
	SET @start_process_date = GETDATE()

	INSERT INTO study_space_missions_db.runs (start_process_date, status)
	VALUES (GETDATE(), 'STARTED')

	SELECT id, FORMAT(start_process_date, 'yyyy-MM-dd HH:mm:ss') AS start_process_date
	FROM study_space_missions_db.runs WHERE id = SCOPE_IDENTITY()
SET NOCOUNT OFF
END;

CREATE PROCEDURE study_space_missions_db.usp_end_run
	@id INT
AS
BEGIN
SET NOCOUNT ON
	UPDATE study_space_missions_db.runs SET end_process_date = GETDATE(), status = 'COMPLETED'
	WHERE id = @id
SET NOCOUNT OFF
END;

CREATE PROCEDURE study_space_missions_db.usp_start_sub_run
	@run_id INT,
	@layer VARCHAR(20),
	@start_count INT
AS
BEGIN
SET NOCOUNT ON
	INSERT INTO study_space_missions_db.sub_runs (run_id, start_process_date, status, layer, start_count)
	VALUES (@run_id, GETDATE(), 'STARTED', @layer, @start_count)
SET NOCOUNT OFF
END;

CREATE PROCEDURE study_space_missions_db.usp_end_sub_run
	@run_id INT,
	@layer VARCHAR(20),
	@end_count INT
AS
BEGIN
SET NOCOUNT ON
	UPDATE study_space_missions_db.sub_runs SET end_process_date = GETDATE(), end_count = @end_count, status = 'COMPLETED'
	WHERE run_id = @run_id
	AND layer = @layer
SET NOCOUNT OFF
END;

CREATE PROCEDURE study_space_missions_db.register_log
	@run_id INT,
	@code CHAR(2),
	@description VARCHAR(200)
AS
BEGIN
	/****** Codes *******
		01: No files
		02: File copied
		03: Missing values
		04: Wrong data integrity
	******* Codes *******/
	
	INSERT INTO study_space_missions_db.logs (run_id, code, description)
	VALUES (@run_id, @code, @description)
END;
------------------------- End storeds -------------------------

------------------------- Start insert -------------------------
TRUNCATE TABLE study_space_missions_db.validation_rules

INSERT INTO study_space_missions_db.validation_rules (schema_name, table_name, column_order, column_name_original, column_name_new, column_type, column_size, column_size_scale, default_value, is_from_file, is_active)
VALUES ('silver', 'missions', 1, 'Company', 'company', 'STRING', 50, NULL, 'UNKNOWN', 1, 1);

INSERT INTO study_space_missions_db.validation_rules (schema_name, table_name, column_order, column_name_original, column_name_new, column_type, column_size, column_size_scale, default_value, is_from_file, is_active)
VALUES ('silver', 'missions', 2, 'Location', 'location', 'STRING', 100, NULL, 'UNKNOWN', 1, 1);

INSERT INTO study_space_missions_db.validation_rules (schema_name, table_name, column_order, column_name_original, column_name_new, column_type, column_size, column_size_scale, default_value, is_from_file, is_active)
VALUES ('silver', 'missions', 3, 'Date', 'date', 'DATE', NULL, NULL, '1900-01-01', 1, 1);

INSERT INTO study_space_missions_db.validation_rules (schema_name, table_name, column_order, column_name_original, column_name_new, column_type, column_size, column_size_scale, default_value, is_from_file, is_active)
VALUES ('silver', 'missions', 4, 'Time', 'time', 'STRING', 8, NULL, '00:00:00', 1, 1);

INSERT INTO study_space_missions_db.validation_rules (schema_name, table_name, column_order, column_name_original, column_name_new, column_type, column_size, column_size_scale, default_value, is_from_file, is_active)
VALUES ('silver', 'missions', 5, 'Rocket', 'rocket', 'STRING', 50, NULL, 'UNKNOWN', 1, 1);

INSERT INTO study_space_missions_db.validation_rules (schema_name, table_name, column_order, column_name_original, column_name_new, column_type, column_size, column_size_scale, default_value, is_from_file, is_active)
VALUES ('silver', 'missions', 6, 'Mission', 'mission', 'STRING', 50, NULL, 'UNKNOWN', 1, 1);

INSERT INTO study_space_missions_db.validation_rules (schema_name, table_name, column_order, column_name_original, column_name_new, column_type, column_size, column_size_scale, default_value, is_from_file, is_active)
VALUES ('silver', 'missions', 7, 'RocketStatus', 'rocket_status', 'STRING', 15, NULL, 'UNKNOWN', 1, 1);

INSERT INTO study_space_missions_db.validation_rules (schema_name, table_name, column_order, column_name_original, column_name_new, column_type, column_size, column_size_scale, default_value, is_from_file, is_active)
VALUES ('silver', 'missions', 8, 'Price', 'price', 'DECIMAL', 10, 2, 100, 1, 1);

INSERT INTO study_space_missions_db.validation_rules (schema_name, table_name, column_order, column_name_original, column_name_new, column_type, column_size, column_size_scale, default_value, is_from_file, is_active)
VALUES ('silver', 'missions', 9, 'MissionStatus', 'mission_status', 'STRING', 15, NULL, 'UNKNOWN', 1, 1);

INSERT INTO study_space_missions_db.validation_rules (schema_name, table_name, column_order, column_name_original, column_name_new, column_type, column_size, column_size_scale, default_value, is_from_file, is_active)
VALUES ('silver', 'missions', 10, NULL, 'country', 'STRING', 20, NULL, 'UNKNOWN', 0, 1);
------------------------- End insert -------------------------
