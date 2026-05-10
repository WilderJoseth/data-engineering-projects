CREATE DATABASE [DataOps_Control];

CREATE SCHEMA [prod];

CREATE TABLE [prod].[projects] (
	[id] [smallint] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[date_creation] [datetime] NOT NULL CONSTRAINT [df_prod_projects_date_creation] DEFAULT GETDATE(),

	CONSTRAINT [pk_prod_projects] PRIMARY KEY CLUSTERED ([id] ASC)
) ON [PRIMARY];

CREATE TABLE [prod].[project_databases](
	[id] [smallint] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[is_active] [bit] NOT NULL CONSTRAINT [df_prod_project_databases_is_active] DEFAULT 1,
	[project_id] [smallint] NOT NULL,

	CONSTRAINT [pk_prod_project_databases] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_prod_project_databases_project_id] FOREIGN KEY (project_id) REFERENCES [prod].[projects]([id])
) ON [PRIMARY];

CREATE TABLE [prod].[project_processes](
	[id] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[is_active] [bit] NOT NULL CONSTRAINT [df_prod_project_processes_is_active] DEFAULT 1,
	[database_id] [smallint] NOT NULL,
	[process_id] [int] NULL,
	
	CONSTRAINT [pk_prod_project_processes] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_prod_project_processes_database_id] FOREIGN KEY ([database_id]) REFERENCES [prod].[projects]([id]),
	CONSTRAINT [fk_prod_project_processes_process_id] FOREIGN KEY ([process_id]) REFERENCES [prod].[project_processes]([id])
) ON [PRIMARY];

CREATE TABLE [prod].[project_tables](
	[id] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[is_fact_table] [bit] NOT NULL,
	[batch_column_name] [varchar](50) NULL,
	[last_load_status] [varchar](15) NOT NULL,
	[last_successful_run_id] [int] NULL,
	[is_active] [bit] NOT NULL CONSTRAINT [df_prod_project_tables_is_active] DEFAULT 1,
	[database_id] [smallint] NOT NULL,
	
	CONSTRAINT [pk_prod_project_tables] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_prod_project_tables_database_id] FOREIGN KEY ([database_id]) REFERENCES [prod].[projects]([id])
) ON [PRIMARY];


CREATE TABLE [prod].[project_columns](
	[id] [int] IDENTITY(1, 1) NOT NULL,
	[position] [smallint] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[type] [varchar](20) NOT NULL,
	[size] [smallint] NULL,
	[size_scale] [smallint] NULL,
	[default_value] [varchar](50) NULL,
	[is_active] [bit] NOT NULL CONSTRAINT [df_prod_project_columns_is_active] DEFAULT 1,
	[table_id] [int] NOT NULL,

	CONSTRAINT [pk_prod_project_columns] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_prod_project_columns_table_id] FOREIGN KEY ([table_id]) REFERENCES [prod].[project_tables]([id])
) ON [PRIMARY];

CREATE TABLE [prod].[table_batch_executions](
	[id] [int] IDENTITY(1, 1) NOT NULL,
	[column_value] [varchar](20) NOT NULL,
	[column_type] [varchar](20) NOT NULL,
	[table_id] [int] NOT NULL,

	CONSTRAINT [pk_prod_table_batch_executions] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_prod_table_batch_executions_table_id] FOREIGN KEY ([table_id]) REFERENCES [prod].[project_tables]([id])
) ON [PRIMARY]

CREATE TABLE [prod].[execution_runs](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[start_process_date] [datetime] NOT NULL,
	[end_process_date] [datetime] NULL,
	[status] [varchar](15) NOT NULL,
	[project_id] [smallint] NOT NULL,

	CONSTRAINT [pk_prod_execution_runs] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_prod_execution_runs_project_id] FOREIGN KEY ([project_id]) REFERENCES [prod].[projects]([id])

) ON [PRIMARY];

CREATE TABLE [prod].[execution_steps](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[start_process_date] [datetime] NOT NULL,
	[end_process_date] [datetime] NULL,
	[status] [varchar](15) NOT NULL,
	[execution_run_id] [int] NOT NULL,
	[project_table_id] [int] NULL,
	[table_batch_execution_id] [int] NULL,

	CONSTRAINT [pk_prod_execution_steps] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_prod_execution_steps_execution_run_id] FOREIGN KEY ([execution_run_id]) REFERENCES [prod].[execution_runs]([id]),
	CONSTRAINT [fk_prod_execution_steps_process_id] FOREIGN KEY ([project_table_id]) REFERENCES [prod].[project_tables]([id]),
	CONSTRAINT [fk_prod_execution_steps_table_batch_execution_id] FOREIGN KEY ([table_batch_execution_id]) REFERENCES [prod].[table_batch_executions]([id])

) ON [PRIMARY];

CREATE TABLE [prod].[error_logs](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[code] [char](2) NOT NULL,
	[execution_step_id] [int] NOT NULL,

	CONSTRAINT [pk_prod_error_logs] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_prod_error_logs_execution_step_id] FOREIGN KEY ([execution_step_id]) REFERENCES [prod].[execution_steps]([id])

) ON [PRIMARY];

CREATE TABLE [prod].[reconciliation_results](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[quantity] [bigint] NOT NULL,
	[amount] [decimal](15, 4) NULL,
	[execution_step_id] [int] NOT NULL,

	CONSTRAINT [pk_prod_reconciliation_results] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_prod_reconciliation_results_execution_step_id] FOREIGN KEY ([execution_step_id]) REFERENCES [prod].[execution_steps]([id])

) ON [PRIMARY];

CREATE TABLE [prod].[validation_results](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[execution_step_id] [int] NOT NULL,

	CONSTRAINT [pk_prod_validation_results] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_prod_validation_results_execution_step_id] FOREIGN KEY ([execution_step_id]) REFERENCES [prod].[execution_steps]([id])

) ON [PRIMARY];
