
----------------- START create objects -----------------
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
	is_fact_table BIT NOT NULL,
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

CREATE TABLE dbo.fact_table_years (
	id SMALLINT IDENTITY(1, 1) NOT NULL,
	year INT NOT NULL,
	is_active BIT NOT NULL,
	table_id INT NOT NULL,

	CONSTRAINT dbo_fact_table_years_table_id FOREIGN KEY (table_id) REFERENCES dbo.project_tables(id)
)
----------------- END create objects -----------------

----------------- START load data -----------------
-------------------------
INSERT INTO dbo.projects (name, date_creation)
VALUES ('AdventureWorksDW2022_Migration', GETDATE());
-------------------------

-------------------------
SELECT * FROM dbo.stages
INSERT INTO dbo.stages (name) VALUES ('BRONZE');
INSERT INTO dbo.stages (name) VALUES ('SILVER');
INSERT INTO dbo.stages (name) VALUES ('WS STAGING');
INSERT INTO dbo.stages (name) VALUES ('WS PRODUCTION');
-------------------------

-------------------------
SELECT * FROM dbo.project_tables

INSERT INTO dbo.project_tables (table_name, is_fact_table, is_active, project_id)
VALUES ('FactFinance', 1, 1, 1);

INSERT INTO dbo.project_tables (table_name, is_fact_table, is_active, project_id)
VALUES ('DimOrganization', 0, 1, 1);

INSERT INTO dbo.project_tables (table_name, is_fact_table, is_active, project_id)
VALUES ('DimDepartmentGroup', 0, 1, 1);

INSERT INTO dbo.project_tables (table_name, is_fact_table, is_active, project_id)
VALUES ('DimScenario', 0, 1, 1);

INSERT INTO dbo.project_tables (table_name, is_fact_table, is_active, project_id)
VALUES ('DimAccount', 0, 1, 1);
-------------------------

-------------------------
SELECT * FROM dbo.validation_rules

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
VALUES (8, 'Date', 'DATETIME', 0, NULL, '1900-01-01 00:00:00', 1)


INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (1, 'OrganizationKey', 'INT', 0, NULL, '0', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (2, 'ParentOrganizationKey', 'INT', 0, NULL, '0', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (3, 'PercentageOfOwnership', 'DECIMAL', 3, 2, '0', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (4, 'OrganizationName', 'NVARCHAR', 50, NULL, '', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (5, 'CurrencyKey', 'INT', 0, NULL, '0', 2)


INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (1, 'DepartmentGroupKey', 'INT', 0, NULL, '0', 3)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (2, 'ParentDepartmentGroupKey', 'INT', 0, NULL, '0', 3)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (3, 'DepartmentGroupName', 'NVARCHAR', 50, NULL, '', 3)


INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (1, 'ScenarioKey', 'INT', 0, NULL, '0', 4)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (2, 'ScenarioName', 'NVARCHAR', 50, NULL, '', 4)


INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (1, 'AccountKey', 'INT', 0, NULL, '0', 5)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (2, 'ParentAccountKey', 'INT', 0, NULL, '0', 5)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (3, 'AccountCodeAlternateKey', 'INT', 0, NULL, '0', 5)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (4, 'ParentAccountCodeAlternateKey', 'INT', 0, NULL, '0', 5)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (5, 'AccountDescription', 'NVARCHAR', 50, NULL, '', 5)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (6, 'AccountType', 'NVARCHAR', 50, NULL, '', 5)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (7, 'Operator', 'NVARCHAR', 50, NULL, '', 5)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (8, 'ValueType', 'NVARCHAR', 50, NULL, '', 5)
-------------------------

-------------------------
SELECT * FROM dbo.fact_table_years

INSERT INTO dbo.fact_table_years (year, is_active, table_id) VALUES (2010, 0, 1)
INSERT INTO dbo.fact_table_years (year, is_active, table_id) VALUES (2011, 0, 1)
INSERT INTO dbo.fact_table_years (year, is_active, table_id) VALUES (2012, 0, 1)
INSERT INTO dbo.fact_table_years (year, is_active, table_id) VALUES (2013, 0, 1)
-------------------------
----------------- END load data -----------------



