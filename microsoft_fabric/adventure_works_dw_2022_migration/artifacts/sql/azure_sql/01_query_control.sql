
CREATE TABLE dbo.projects (
	id SMALLINT IDENTITY(1, 1) NOT NULL,
	name VARCHAR(50) NOT NULL,
	date_creation DATETIME NOT NULL,

	CONSTRAINT dbo_projects PRIMARY KEY CLUSTERED (id)
);

CREATE TABLE dbo.runs (
	id INT IDENTITY(1, 1) NOT NULL,
	name VARCHAR(50) NOT NULL,
	start_process_date DATETIME NOT NULL,
	end_process_date DATETIME NULL,
	status VARCHAR(15) NOT NULL,
	project_id SMALLINT NOT NULL,
	
	CONSTRAINT dbo_runs PRIMARY KEY CLUSTERED (id),
	CONSTRAINT dbo_runs_project_id FOREIGN KEY (project_id) REFERENCES dbo.projects(id)
);

CREATE TABLE dbo.sub_runs (
	id INT IDENTITY(1, 1) NOT NULL,
	run_id INT NOT NULL,
	start_process_date DATETIME NOT NULL,
	end_process_date DATETIME NULL,
	layer VARCHAR(50) NOT NULL,
	start_count INT NOT NULL,
	end_count INT NULL,
	status VARCHAR(15) NOT NULL,
	
	CONSTRAINT dbo_sub_runs PRIMARY KEY CLUSTERED (id),
	CONSTRAINT dbo_runs_run_id FOREIGN KEY (run_id) REFERENCES dbo.runs(id)
);

CREATE TABLE dbo.logs (
	id INT IDENTITY(1, 1) NOT NULL,
	run_id INT NOT NULL,
	code CHAR(2) NOT NULL,
	description VARCHAR(MAX) NOT NULL,

	CONSTRAINT dbo_logs PRIMARY KEY CLUSTERED (id),
	CONSTRAINT dbo_logs_run_id FOREIGN KEY (run_id) REFERENCES dbo.runs(id)
);

CREATE TABLE dbo.project_tables (
	id INT IDENTITY(1, 1) NOT NULL,
	table_name VARCHAR(50) NOT NULL,
	is_active BIT NOT NULL,
	project_id SMALLINT NOT NULL,

	CONSTRAINT dbo_project_tables PRIMARY KEY CLUSTERED (id),
	CONSTRAINT dbo_project_tables_project_id FOREIGN KEY (project_id) REFERENCES dbo.projects(id)
)

CREATE TABLE dbo.stages (
	id SMALLINT IDENTITY(1, 1) NOT NULL,
	name VARCHAR(50) NOT NULL,

	CONSTRAINT dbo_stages PRIMARY KEY CLUSTERED (id)
)

CREATE TABLE dbo.validation_stages (
	id SMALLINT IDENTITY(1, 1) NOT NULL,
	stage_id SMALLINT NOT NULL,
	table_id INT NOT NULL,

	CONSTRAINT dbo_validation_stages PRIMARY KEY CLUSTERED (id),
	CONSTRAINT dbo_validation_stages_stage_id FOREIGN KEY (stage_id) REFERENCES dbo.stages(id),
	CONSTRAINT dbo_validation_stages_table_id FOREIGN KEY (table_id) REFERENCES dbo.project_tables(id)
)

--CREATE TABLE dbo.table_dependencies (
--	id INT IDENTITY(1, 1) NOT NULL,
--	table_id INT NOT NULL,
--	table_parent_id INT NULL,

--	CONSTRAINT dbo_table_dependencies PRIMARY KEY CLUSTERED (id),
--	CONSTRAINT dbo_table_dependencies_table_id FOREIGN KEY (table_id) REFERENCES dbo.table_dependencies(id)
--)

CREATE TABLE dbo.validation_rules (
	id INT IDENTITY(1,1) NOT NULL,
	column_order SMALLINT NOT NULL,
	column_name_original VARCHAR(50) NULL,
	column_name_new VARCHAR(50) NULL,
	column_type VARCHAR(20) NOT NULL,
	column_size SMALLINT NULL,
	column_size_scale SMALLINT NULL,
	default_value VARCHAR(50) NULL CONSTRAINT df_dbo_validation_rules_default_value DEFAULT(''),
	is_from_file BIT NOT NULL CONSTRAINT df_dbo_validation_rules_is_from_file DEFAULT(0),
	is_active BIT NOT NULL CONSTRAINT df_dbo_validation_rules_is_active DEFAULT(1),
	table_id INT NOT NULL,

	CONSTRAINT dbo_validation_rules PRIMARY KEY CLUSTERED (id),
	CONSTRAINT dbo_validation_rules_table_id FOREIGN KEY (table_id) REFERENCES dbo.project_tables(id)
)

INSERT INTO dbo.projects (name, date_creation)
VALUES ('AdventureWorksDW2022_Migration', GETDATE());

-------------------------
SELECT * FROM dbo.stages
INSERT INTO dbo.stages (name) VALUES ('BRONZE');
INSERT INTO dbo.stages (name) VALUES ('SILVER');
INSERT INTO dbo.stages (name) VALUES ('WS - STAGING');
--INSERT INTO dbo.stages (name, project_id) VALUES ('WS - PRODUCTION', 1);
-------------------------

-------------------------
INSERT INTO dbo.project_tables (table_name, is_active, project_id)
VALUES ('FactFinance', 1, 1);

INSERT INTO dbo.project_tables (table_name, is_active, project_id)
VALUES ('DimDate', 1, 1);

INSERT INTO dbo.project_tables (table_name, is_active, project_id)
VALUES ('DimOrganization', 1, 1);

INSERT INTO dbo.project_tables (table_name, is_active, project_id)
VALUES ('DimDepartmentGroup', 1, 1);

INSERT INTO dbo.project_tables (table_name, is_active, project_id)
VALUES ('DimScenario', 1, 1);

INSERT INTO dbo.project_tables (table_name, is_active, project_id)
VALUES ('DimAccount', 1, 1);
-------------------------

-------------------------
SELECT * FROM dbo.validation_stages

INSERT INTO dbo.validation_stages (stage_id, table_id) VALUES (1, 1)
INSERT INTO dbo.validation_stages (stage_id, table_id) VALUES (1, 2)
INSERT INTO dbo.validation_stages (stage_id, table_id) VALUES (1, 3)
INSERT INTO dbo.validation_stages (stage_id, table_id) VALUES (1, 4)
INSERT INTO dbo.validation_stages (stage_id, table_id) VALUES (1, 5)
INSERT INTO dbo.validation_stages (stage_id, table_id) VALUES (1, 6)

INSERT INTO dbo.validation_stages (stage_id, table_id) VALUES (2, 1)
INSERT INTO dbo.validation_stages (stage_id, table_id) VALUES (2, 2)
INSERT INTO dbo.validation_stages (stage_id, table_id) VALUES (2, 3)
INSERT INTO dbo.validation_stages (stage_id, table_id) VALUES (2, 4)
INSERT INTO dbo.validation_stages (stage_id, table_id) VALUES (2, 5)
INSERT INTO dbo.validation_stages (stage_id, table_id) VALUES (2, 6)

INSERT INTO dbo.validation_stages (stage_id, table_id) VALUES (3, 1)
INSERT INTO dbo.validation_stages (stage_id, table_id) VALUES (3, 2)
INSERT INTO dbo.validation_stages (stage_id, table_id) VALUES (3, 3)
INSERT INTO dbo.validation_stages (stage_id, table_id) VALUES (3, 4)
INSERT INTO dbo.validation_stages (stage_id, table_id) VALUES (3, 5)
INSERT INTO dbo.validation_stages (stage_id, table_id) VALUES (3, 6)


-------------------------

-------------------------
--INSERT INTO dbo.table_dependencies (table_id) VALUES (1)
--INSERT INTO dbo.table_dependencies (table_id, table_parent_id) VALUES (2, 1)
--INSERT INTO dbo.table_dependencies (table_id, table_parent_id) VALUES (3, 1)
--INSERT INTO dbo.table_dependencies (table_id, table_parent_id) VALUES (4, 1)
--INSERT INTO dbo.table_dependencies (table_id, table_parent_id) VALUES (5, 1)
--INSERT INTO dbo.table_dependencies (table_id, table_parent_id) VALUES (6, 1)
-------------------------

-------------------------
SELECT * FROM dbo.project_tables

SELECT * FROM dbo.validation_rules WHERE table_id = 2

TRUNCATE TABLE dbo.validation_rules

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (1, 'FinanceKey', 'INT', 0, NULL, '0', 1)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (2, 'DateKey', 'INT', 0, NULL, '0', 1)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (3, 'OrganizationKey', 'INT', 0, NULL, '0', 1)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (4, 'DepartmentGroupKey', 'INT', 0, NULL, '0', 1)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (5, 'ScenarioKey', 'INT', 0, NULL, '0', 1)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (6, 'AccountKey', 'INT', 0, NULL, '0', 1)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (7, 'Amount', 'DECIMAL', 10, 2, '0', 1)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (8, 'Date', 'DATETIME', 0, NULL, '0', 1)


INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (1, 'DateKey', 'INT', 0, NULL, '0', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (2, 'FullDateAlternateKey', 'DATE', 0, NULL, '1900-01-01', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (3, 'DayNumberOfWeek', 'TINYINT', 0, NULL, '0', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (4, 'EnglishDayNameOfWeek', 'NVARCHAR', 10, NULL, '', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (5, 'SpanishDayNameOfWeek', 'NVARCHAR', 10, NULL, '', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (6, 'FrenchDayNameOfWeek', 'NVARCHAR', 10, NULL, '', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (7, 'DayNumberOfMonth', 'TINYINT', 0, NULL, '0', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (8, 'DayNumberOfYear', 'SMALLINT', 0, NULL, '0', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (9, 'WeekNumberOfYear', 'TINYINT', 0, NULL, '0', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (10, 'EnglishMonthName', 'NVARCHAR', 10, NULL, '', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (11, 'SpanishMonthName', 'NVARCHAR', 10, NULL, '', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (12, 'FrenchMonthName', 'NVARCHAR', 10, NULL, '', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (13, 'MonthNumberOfYear', 'TINYINT', 0, NULL, '0', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (14, 'CalendarQuarter', 'TINYINT', 0, NULL, '0', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (15, 'CalendarYear', 'SMALLINT', 0, NULL, '0', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (16, 'CalendarSemester', 'TINYINT', 0, NULL, '0', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (17, 'FiscalQuarter', 'TINYINT', 0, NULL, '0', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (18, 'FiscalYear', 'SMALLINT', 0, NULL, '0', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (19, 'FiscalSemester', 'TINYINT', 0, NULL, '0', 2)


INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (1, 'OrganizationKey', 'INT', 0, NULL, '0', 3)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (2, 'ParentOrganizationKey', 'INT', 0, NULL, '0', 3)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (3, 'PercentageOfOwnership', 'DECIMAL', 3, 2, '', 3)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (4, 'OrganizationName', 'NVARCHAR', 50, NULL, '', 3)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (5, 'CurrencyKey', 'INT', 0, NULL, '0', 3)


INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (1, 'DepartmentGroupKey', 'INT', 0, NULL, '0', 4)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (2, 'ParentDepartmentGroupKey', 'INT', 0, NULL, '0', 4)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (3, 'DepartmentGroupName', 'NVARCHAR', 50, NULL, '', 4)


INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (1, 'ScenarioKey', 'INT', 0, NULL, '0', 5)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (2, 'ScenarioName', 'NVARCHAR', 50, NULL, '', 5)


INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (1, 'AccountKey', 'INT', 0, NULL, '0', 6)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (2, 'ParentAccountKey', 'INT', 0, NULL, '0', 6)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (3, 'AccountCodeAlternateKey', 'INT', 0, NULL, '0', 6)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (4, 'ParentAccountCodeAlternateKey', 'INT', 0, NULL, '0', 6)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (5, 'AccountDescription', 'NVARCHAR', 50, NULL, '', 6)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (6, 'AccountType', 'NVARCHAR', 50, NULL, '', 6)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (7, 'Operator', 'NVARCHAR', 50, NULL, '', 6)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (8, 'ValueType', 'NVARCHAR', 50, NULL, '', 6)
-------------------------


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
		t.schema_name,
		t.table_name,
		v.column_order,
		v.column_name_original,
		v.column_type,
		v.column_size,
		v.column_size_scale
	FROM dbo.project_tables t
	INNER JOIN dbo.validation_rules v ON v.table_id = t.id
	WHERE t.project_id = @project_id
	AND t.is_active = 1
	AND v.is_active = 1
END;

--CREATE PROCEDURE dbo.usp_list_table_dependencies
--	@project_id INT
--AS
--BEGIN
--	SELECT t1.schema_name, t1.table_name, t2.schema_name AS schema_name_parent, t2.table_name AS table_name_parent
--	FROM dbo.table_dependencies d
--	INNER JOIN dbo.project_tables t1 ON t1.id = d.table_id
--	LEFT JOIN dbo.project_tables t2 ON t2.id = d.table_parent_id AND t2.is_active = 1 AND t2.project_id = 1
--	WHERE t1.project_id = @project_id
--	AND t1.is_active = 1
--END;

ALTER PROCEDURE dbo.usp_list_table_dependencies_stage
	@project_id INT,
	@stage_name VARCHAR(50)
AS
BEGIN
	SELECT s.name AS stage_name, t.table_name
	FROM dbo.project_tables t
	INNER JOIN dbo.validation_stages v ON v.table_id = t.id
	INNER JOIN dbo.stages s ON s.id = v.stage_id
	WHERE t.project_id = @project_id
	AND t.is_active = 1
	AND s.name = @stage_name;
END;

EXEC dbo.usp_list_validation_rules 1

EXEC dbo.usp_list_table_dependencies_stage 1, 'SILVER'

SELECT * FROM dbo.runs
ORDER BY id DESC

SELECT * FROM dbo.sub_runs
WHERE run_id = 14



SELECT * FROM dbo.stages

SELECT * FROM dbo.validation_stages

SELECT * FROM dbo.project_tables

SELECT * FROM dbo.table_dependencies

-- 01: Notebook does not exist
-- 02: Notebook executed
SELECT * FROM dbo.logs;
