CREATE DATABASE [DataOps_Control];

USE [DataOps_Control];

CREATE SCHEMA [metadata];
CREATE SCHEMA [runtime];
CREATE SCHEMA [observability];
CREATE SCHEMA [reference];

CREATE TABLE [metadata].[projects] (
	[id] [smallint] NOT NULL,
	[name] [varchar](100) NOT NULL,
	[is_active] [bit] NOT NULL CONSTRAINT [df_metadata_projects_is_active] DEFAULT 1,
	[created_at] [datetime2] NOT NULL CONSTRAINT [df_metadata_projects_created_at] DEFAULT SYSUTCDATETIME(),

	CONSTRAINT [pk_metadata_projects] PRIMARY KEY CLUSTERED ([id] ASC)
) ON [PRIMARY];

CREATE TABLE [metadata].[project_databases](
	[id] [smallint] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[platform_type] [varchar](30) NOT NULL,
	[database_role] [varchar](30) NULL,
	[project_id] [smallint] NOT NULL,
	[is_active] [bit] NOT NULL CONSTRAINT [df_metadata_project_databases_is_active] DEFAULT 1,
	[created_at] [datetime2] NOT NULL CONSTRAINT [df_metadata_project_databases_created_at] DEFAULT SYSUTCDATETIME(),

	CONSTRAINT [pk_metadata_project_databases] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_metadata_project_databases_project_id] FOREIGN KEY (project_id) REFERENCES [metadata].[projects]([id])
) ON [PRIMARY];

CREATE TABLE [metadata].[project_database_mappings](
	[database_source_id] [smallint] NOT NULL,
	[database_target_id] [smallint] NOT NULL,

	CONSTRAINT [pk_metadata_project_database_mappings] PRIMARY KEY CLUSTERED ([database_source_id] ASC, [database_target_id] ASC),
	CONSTRAINT [fk_metadata_project_database_mappings_database_source_id] FOREIGN KEY ([database_source_id]) REFERENCES [metadata].[project_databases]([id]),
	CONSTRAINT [fk_metadata_project_database_mappings_database_target_id] FOREIGN KEY ([database_target_id]) REFERENCES [metadata].[project_databases]([id])
) ON [PRIMARY];

CREATE TABLE [metadata].[project_processes](
	[id] [int] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[database_id] [smallint] NOT NULL,
	[parent_process_id] [int] NULL,
	[is_active] [bit] NOT NULL CONSTRAINT [df_metadata_project_processes_is_active] DEFAULT 1,
	[created_at] [datetime2] NOT NULL CONSTRAINT [df_metadata_project_processes_created_at] DEFAULT SYSUTCDATETIME(),

	CONSTRAINT [pk_metadata_project_processes] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_metadata_project_processes_database_id] FOREIGN KEY ([database_id]) REFERENCES [metadata].[project_databases]([id]),
	CONSTRAINT [fk_metadata_project_processes_parent_process_id] FOREIGN KEY ([parent_process_id]) REFERENCES [metadata].[project_processes]([id])
) ON [PRIMARY];

CREATE TABLE [reference].[status_codes] (
	[id] [smallint] IDENTITY(1, 1) NOT NULL,
    [code] [varchar](15) NOT NULL,
    [description] [varchar](100) NULL,
    [is_active] [bit] NOT NULL CONSTRAINT [df_reference_status_codes_is_active] DEFAULT 1,
	[created_at] [datetime2] NOT NULL CONSTRAINT [df_reference_status_codes_created_at] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [pk_reference_status_codes] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [uk_reference_status_codes_code] UNIQUE ([code])
) ON [PRIMARY];

CREATE TABLE [metadata].[project_tables] (
	[id] [int] NOT NULL,
	[schema_name] [varchar](50) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[is_fact_table] [bit] NOT NULL CONSTRAINT [df_metadata_project_tables_is_fact_table] DEFAULT 0,
	[is_transactional_table] [bit] NOT NULL CONSTRAINT [df_metadata_project_tables_is_transactional_table] DEFAULT 0,
	[batch_column_active] [bit] NOT NULL CONSTRAINT [df_metadata_project_tables_batch_column_active] DEFAULT 0,
	[rerun_required] [bit] NOT NULL CONSTRAINT [df_metadata_project_tables_rerun_required] DEFAULT 0,
	[database_id] [smallint] NOT NULL,
	[is_active] [bit] NOT NULL CONSTRAINT [df_metadata_project_tables_is_active] DEFAULT 1,
	[created_at] [datetime2] NOT NULL CONSTRAINT [df_metadata_project_tables_created_at] DEFAULT SYSUTCDATETIME(),
	
	CONSTRAINT [pk_metadata_project_tables] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_metadata_project_tables_database_id] FOREIGN KEY ([database_id]) REFERENCES [metadata].[project_databases]([id])
) ON [PRIMARY];

CREATE TABLE [metadata].[project_table_mappings](
	[table_source_id] [int] NOT NULL,
	[table_target_id] [int] NOT NULL,

	CONSTRAINT [pk_metadata_project_table_mappings] PRIMARY KEY CLUSTERED ([table_source_id] ASC, [table_target_id] ASC),
	CONSTRAINT [fk_metadata_project_table_mappings_table_source_id] FOREIGN KEY ([table_source_id]) REFERENCES [metadata].[project_tables]([id]),
	CONSTRAINT [fk_metadata_project_table_mappings_table_target_id] FOREIGN KEY ([table_target_id]) REFERENCES [metadata].[project_tables]([id])
) ON [PRIMARY];

CREATE TABLE [metadata].[project_columns](
	[id] [int] IDENTITY(1, 1) NOT NULL,
	[position] [smallint] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[type] [varchar](20) NOT NULL,
	[size] [smallint] NULL,
	[size_scale] [smallint] NULL,
	[default_value] [varchar](50) NULL,
	[is_nullable] [bit] NOT NULL CONSTRAINT [df_metadata_project_columns_is_nullable] DEFAULT 0,
	[is_watermark] [bit] NOT NULL CONSTRAINT [df_metadata_project_columns_is_watermark] DEFAULT 0,
	[is_reconciliation_column] [bit] NOT NULL CONSTRAINT [df_metadata_project_columns_is_reconciliation_column] DEFAULT 0,
	[table_id] [int] NOT NULL,
	[is_active] [bit] NOT NULL CONSTRAINT [df_metadata_project_columns_is_active] DEFAULT 1,
	[created_at] [datetime2] NOT NULL CONSTRAINT [df_metadata_project_columns_created_at] DEFAULT SYSUTCDATETIME(),

	CONSTRAINT [pk_metadata_project_columns] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_metadata_project_columns_table_id] FOREIGN KEY ([table_id]) REFERENCES [metadata].[project_tables]([id])
) ON [PRIMARY];

CREATE TABLE [metadata].[project_table_batches](
	[id] [int] IDENTITY(1, 1) NOT NULL,
	[batch_column_name] [varchar](50) NOT NULL,
	[batch_value] [varchar](50) NOT NULL,
	[batch_start_value] [varchar](50) NULL,
	[batch_end_value] [varchar](50) NULL,
	[column_type] [varchar](20) NOT NULL,
	[rerun_required] [bit] NOT NULL CONSTRAINT [df_metadata_project_table_batches_rerun_required] DEFAULT 0,
	[table_id] [int] NOT NULL,
	[is_active] [bit] NOT NULL CONSTRAINT [df_metadata_project_table_batches_is_active] DEFAULT 1,
	[created_at] [datetime2] NOT NULL CONSTRAINT [df_metadata_project_table_batches_created_at] DEFAULT SYSUTCDATETIME(),

	CONSTRAINT [pk_metadata_project_table_batches] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_metadata_project_table_batches_table_id] FOREIGN KEY ([table_id]) REFERENCES [metadata].[project_tables]([id])
) ON [PRIMARY];

CREATE TABLE [runtime].[execution_runs](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[start_run_date] [datetime2] NOT NULL CONSTRAINT [df_runtime_execution_runs_start_run_date] DEFAULT SYSUTCDATETIME(),
	[end_run_date] [datetime2] NULL,
	[status_code_id] [smallint] NOT NULL,
	[project_id] [smallint] NOT NULL,
	[created_by] [varchar](50) NOT NULL CONSTRAINT [df_runtime_execution_runs_created_by] DEFAULT USER_NAME(),

	CONSTRAINT [pk_runtime_execution_runs] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_runtime_execution_runs_project_id] FOREIGN KEY ([project_id]) REFERENCES [metadata].[projects]([id]),
	CONSTRAINT [fk_runtime_execution_runs_status_code_id] FOREIGN KEY ([status_code_id]) REFERENCES [reference].[status_codes]([id])
) ON [PRIMARY];

CREATE TABLE [runtime].[execution_steps](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[start_run_date] [datetime2] NOT NULL CONSTRAINT [df_runtime_execution_steps_start_run_date] DEFAULT SYSUTCDATETIME(),
	[end_run_date] [datetime2] NULL,
	[status_code_id] [smallint] NOT NULL,
	[execution_run_id] [int] NOT NULL,
	[project_process_id] [int] NOT NULL,
	[project_table_id] [int] NULL,
	[project_table_batch_id] [int] NULL,
	[created_by] [varchar](50) NOT NULL CONSTRAINT [df_runtime_execution_steps_created_by] DEFAULT USER_NAME(),

	CONSTRAINT [pk_runtime_execution_steps] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_runtime_execution_steps_execution_run_id] FOREIGN KEY ([execution_run_id]) REFERENCES [runtime].[execution_runs]([id]),
	CONSTRAINT [fk_runtime_execution_steps_project_process_id] FOREIGN KEY ([project_process_id]) REFERENCES [metadata].[project_processes]([id]),
	CONSTRAINT [fk_runtime_execution_steps_project_table_id] FOREIGN KEY ([project_table_id]) REFERENCES [metadata].[project_tables]([id]),
	CONSTRAINT [fk_runtime_execution_steps_project_table_batch_id] FOREIGN KEY ([project_table_batch_id]) REFERENCES [metadata].[project_table_batches]([id]),
	CONSTRAINT [fk_runtime_execution_steps_status_code_id] FOREIGN KEY ([status_code_id]) REFERENCES [reference].[status_codes]([id])
) ON [PRIMARY];

CREATE TABLE [observability].[error_logs](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[error_source] [varchar](200) NOT NULL,
	[details] [varchar](MAX) NOT NULL,
	[execution_step_id] [bigint] NOT NULL,
	[created_at] [datetime2] NOT NULL CONSTRAINT [df_observability_error_logs_created_at] DEFAULT SYSUTCDATETIME(),

	CONSTRAINT [pk_observability_error_logs] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_observability_error_logs_execution_step_id] FOREIGN KEY ([execution_step_id]) REFERENCES [runtime].[execution_steps]([id])
) ON [PRIMARY];

CREATE TABLE [observability].[reconciliation_results](
    [id] [int] IDENTITY(1,1) NOT NULL,
    [metric_name] [varchar](50) NOT NULL,
    [reconciliation_key] [varchar](100) NULL,
    [reconciliation_side] [varchar](20) NOT NULL,
    [metric_value_decimal] [decimal](20, 4) NULL,
    [metric_value_bigint] [bigint] NULL,
    [execution_step_id] [bigint] NOT NULL,
    [created_at] [datetime2] NOT NULL CONSTRAINT [df_observability_reconciliation_results_created_at] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [pk_observability_reconciliation_results] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_observability_reconciliation_results_execution_step_id] FOREIGN KEY ([execution_step_id]) REFERENCES [runtime].[execution_steps]([id])
) ON [PRIMARY];

CREATE TABLE [reference].[validation_codes](
    [id] [smallint] IDENTITY(1,1) NOT NULL,
    [code] [varchar](50) NOT NULL,
    [description] [varchar](200) NULL,
    [severity] [varchar](15) NOT NULL,
    [is_active] [bit] NOT NULL CONSTRAINT [df_reference_validation_codes_is_active] DEFAULT 1,
	[created_at] [datetime2] NOT NULL CONSTRAINT [df_reference_validation_codes_created_at] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [pk_reference_validation_codes] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [uk_reference_validation_codes_code] UNIQUE ([code])
) ON [PRIMARY];

CREATE TABLE [observability].[validation_results](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[details] [varchar](MAX) NOT NULL,
	[affected_row_count] [bigint] NOT NULL,
	[execution_step_id] [bigint] NOT NULL,
	[validation_code_id] [smallint] NOT NULL,
	[created_at] [datetime2] NOT NULL CONSTRAINT [df_observability_validation_results_created_at] DEFAULT SYSUTCDATETIME(),

	CONSTRAINT [pk_observability_validation_results] PRIMARY KEY CLUSTERED ([id] ASC),
	CONSTRAINT [fk_observability_validation_results_execution_step_id] FOREIGN KEY ([execution_step_id]) REFERENCES [runtime].[execution_steps]([id]),
	CONSTRAINT [fk_observability_validation_results_validation_code_id] FOREIGN KEY ([validation_code_id]) REFERENCES [reference].[validation_codes]([id])
) ON [PRIMARY];

