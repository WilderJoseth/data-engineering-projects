USE control_db;

CREATE SCHEMA study_space_missions_db;

CREATE TABLE study_space_missions_db.runs (
	id INT IDENTITY NOT NULL,
	start_process_date DATETIME NOT NULL,
	end_process_date DATETIME NULL,
	start_count INT NOT NULL,
	end_count INT NULL,
	status VARCHAR(15) NOT NULL,

	CONSTRAINT study_space_missions_db_runs PRIMARY KEY(id)
);

/*
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
	CONSTRAINT study_space_missions_db_logs_run_id FOREIGN KEY(run_id) REFERENCES study_space_missions_db.runs(id)
);
*/

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
	column_name VARCHAR(20) NOT NULL,
	column_type VARCHAR(20) NOT NULL,
	column_size SMALLINT NULL,
	column_size_scale SMALLINT NULL,
	default_value VARCHAR(50) NULL,

	CONSTRAINT study_space_missions_db_validation_rules PRIMARY KEY(id)
);

ALTER PROCEDURE study_space_missions_db.usp_start_process
	@start_count INT
AS
BEGIN
SET NOCOUNT ON
	DECLARE @start_process_date DATETIME
	SET @start_process_date = GETDATE()

	INSERT INTO study_space_missions_db.runs (start_process_date, start_count, status)
	VALUES (GETDATE(), @start_count, 'STARTED')

	SELECT id, FORMAT(start_process_date, 'yyyy-MM-dd HH:mm:ss') AS start_process_date 
	FROM study_space_missions_db.runs WHERE id = SCOPE_IDENTITY()
SET NOCOUNT OFF
END;

ALTER PROCEDURE study_space_missions_db.usp_end_process
	@id INT,
	@end_count INT
AS
BEGIN
SET NOCOUNT ON
	UPDATE study_space_missions_db.runs SET end_process_date = GETDATE(), end_count = @end_count, status = 'COMPLETED'
	WHERE id = @id
SET NOCOUNT OFF
END;

EXEC study_space_missions_db.usp_start_process 'BRONZE', 10, 'STARTED'

SELECT * FROM study_space_missions_db.runs
