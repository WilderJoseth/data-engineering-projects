
CREATE DATABASE control_db;

CREATE SCHEMA dajobcanada_db;

---------------------------------- tables ----------------------------------
CREATE TABLE dajobcanada_db.control (
	id smallint IDENTITY NOT NULL,
	start_process datetime NOT NULL,
	end_process datetime NULL,
	status varchar(20) NOT NULL,
	count_processed_bronze int NULL,
	count_processed_layer int NULL,

	CONSTRAINT pk_dajobcanada_db_control PRIMARY KEY(id)
);

CREATE TABLE dajobcanada_db.validation_definition (
	id SMALLINT IDENTITY NOT NULL,
	table_name VARCHAR(30) NOT NULL,
	column_name VARCHAR(30) NOT NULL,
	column_type VARCHAR(20) NOT NULL,
	column_size INT NOT NULl,
	column_scale INT NULl,
	default_value VARCHAR(20) NOT NULL,
	active BIT NOT NULL,

	CONSTRAINT pk_dajobcanada_db_validation_definition PRIMARY KEY(id)
);

CREATE TABLE dajobcanada_db.job_roles (
	id SMALLINT IDENTITY NOT NULL,
	level VARCHAR(15) NOT NULL,
	role VARCHAR(15) NOT NULL,
	job_salary_min_base DECIMAL(15, 2) NOT NULL,
	job_salary_max_base DECIMAL(15, 2) NOT NULl,

	CONSTRAINT pk_dajobcanada_db_job_roles PRIMARY KEY(id)
);

CREATE TABLE dajobcanada_db.log_validation (
	id SMALLINT IDENTITY NOT NULL,
	id_run SMALLINT NOT NULL,
	description VARCHAR(100) NOT NULL,

	CONSTRAINT pk_dajobcanada_db_log_validation PRIMARY KEY(id),
	CONSTRAINT fk_dajobcanada_db_log_validation_id_run FOREIGN KEY (id_run) REFERENCES dajobcanada_db.validation_definition(Id)
);
---------------------------------- tables ----------------------------------

---------------------------------- procedures ----------------------------------
CREATE PROCEDURE dajobcanada_db.usp_start_process
AS
BEGIN
SET NOCOUNT ON

	INSERT INTO dajobcanada_db.control (start_process, status)
	VALUES (GETDATE(), 'STARTED')

	SELECT id AS id_run, FORMAT(start_process, 'yyyy-MM-dd hh:mm:ss') process_date FROM dajobcanada_db.control
	WHERE id = SCOPE_IDENTITY()

SET NOCOUNT OFF
END;

CREATE PROCEDURE dajobcanada_db.usp_update_process
	@id SMALLINT,
	@status_number SMALLINT,
	@count_processed INT
AS
BEGIN
SET NOCOUNT ON

	IF @status_number = 1
	BEGIN
		UPDATE dajobcanada_db.control SET status = 'BRONZE', count_processed_bronze = @count_processed
		WHERE id = @id
	END
	ELSE IF @status_number = 2
	BEGIN
		UPDATE dajobcanada_db.control SET status = 'SILVER', count_processed_layer = @count_processed
		WHERE id = @id
	END
	ELSE
	BEGIN
		UPDATE dajobcanada_db.control SET status = 'FINISHED', end_process = GETDATE()
		WHERE id = @id
	END

SET NOCOUNT OFF
END;

CREATE PROCEDURE dajobcanada_db.usp_get_validations
AS
BEGIN
	SELECT column_name,	column_type, column_size, column_scale, default_value
	FROM dajobcanada_db.validation_definition
	WHERE active = 1
END;

CREATE PROCEDURE dajobcanada_db.usp_get_job_roles
AS
BEGIN
	SELECT level, role, job_salary_min_base, job_salary_max_base
	FROM dajobcanada_db.job_roles
END;
---------------------------------- procedures ----------------------------------

SELECT * FROM dajobcanada_db.validation_definition

SELECT * FROM dajobcanada_db.log_validation

SELECT * FROM dajobcanada_db.control

