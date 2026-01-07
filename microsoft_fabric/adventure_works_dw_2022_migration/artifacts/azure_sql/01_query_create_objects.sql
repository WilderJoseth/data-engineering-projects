
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
