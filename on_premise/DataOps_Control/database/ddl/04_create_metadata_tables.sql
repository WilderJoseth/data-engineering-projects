USE [DataOps_Control];
GO

/*============================================================================
  4. Metadata Tables
============================================================================*/

CREATE TABLE [metadata].[projects] (
    [id] [smallint] NOT NULL,
    [name] [varchar](100) NOT NULL,
    [is_active] [bit] NOT NULL CONSTRAINT [df_metadata_projects_is_active] DEFAULT 1,
    [created_at] [datetime2] NOT NULL CONSTRAINT [df_metadata_projects_created_at] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [pk_metadata_projects] PRIMARY KEY CLUSTERED ([id] ASC)
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_databases] (
    [id] [smallint] NOT NULL,
    [name] [varchar](50) NOT NULL,
    [platform_type] [varchar](30) NOT NULL,
    [database_role] [varchar](30) NULL,
    [project_id] [smallint] NOT NULL,
    [is_active] [bit] NOT NULL CONSTRAINT [df_metadata_project_databases_is_active] DEFAULT 1,
    [created_at] [datetime2] NOT NULL CONSTRAINT [df_metadata_project_databases_created_at] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [pk_metadata_project_databases] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_metadata_project_databases_project_id] FOREIGN KEY ([project_id]) REFERENCES [metadata].[projects]([id])
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_database_mappings] (
    [database_source_id] [smallint] NOT NULL,
    [database_target_id] [smallint] NOT NULL,

    CONSTRAINT [pk_metadata_project_database_mappings] PRIMARY KEY CLUSTERED ([database_source_id] ASC, [database_target_id] ASC),
    CONSTRAINT [fk_metadata_project_database_mappings_database_source_id] FOREIGN KEY ([database_source_id]) REFERENCES [metadata].[project_databases]([id]),
    CONSTRAINT [fk_metadata_project_database_mappings_database_target_id] FOREIGN KEY ([database_target_id]) REFERENCES [metadata].[project_databases]([id])
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_processes] (
    [id] [int] NOT NULL,
    [name] [varchar](50) NOT NULL,
    [project_id] [smallint] NOT NULL,
    [parent_process_id] [int] NULL,
    [is_active] [bit] NOT NULL CONSTRAINT [df_metadata_project_processes_is_active] DEFAULT 1,
    [created_at] [datetime2] NOT NULL CONSTRAINT [df_metadata_project_processes_created_at] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [pk_metadata_project_processes] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_metadata_project_processes_project_id] FOREIGN KEY ([project_id]) REFERENCES [metadata].[projects]([id]),
    CONSTRAINT [fk_metadata_project_processes_parent_process_id] FOREIGN KEY ([parent_process_id]) REFERENCES [metadata].[project_processes]([id])
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_tables] (
    [id] [int] NOT NULL,
    [schema_name] [varchar](50) NOT NULL,
    [name] [varchar](50) NOT NULL,
    [is_fact_table] [bit] NOT NULL CONSTRAINT [df_metadata_project_tables_is_fact_table] DEFAULT 0,
    [is_transactional_table] [bit] NOT NULL CONSTRAINT [df_metadata_project_tables_is_transactional_table] DEFAULT 0,
    [batch_column_active] [bit] NOT NULL CONSTRAINT [df_metadata_project_tables_batch_column_active] DEFAULT 0,
    [execution_required] [bit] NOT NULL CONSTRAINT [df_metadata_project_tables_execution_required] DEFAULT 0,
    [database_id] [smallint] NOT NULL,
    [is_active] [bit] NOT NULL CONSTRAINT [df_metadata_project_tables_is_active] DEFAULT 1,
    [created_at] [datetime2] NOT NULL CONSTRAINT [df_metadata_project_tables_created_at] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [pk_metadata_project_tables] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_metadata_project_tables_database_id] FOREIGN KEY ([database_id]) REFERENCES [metadata].[project_databases]([id])
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_table_mappings] (
    [table_source_id] [int] NOT NULL,
    [table_target_id] [int] NOT NULL,

    CONSTRAINT [pk_metadata_project_table_mappings] PRIMARY KEY CLUSTERED ([table_source_id] ASC, [table_target_id] ASC),
    CONSTRAINT [fk_metadata_project_table_mappings_table_source_id] FOREIGN KEY ([table_source_id]) REFERENCES [metadata].[project_tables]([id]),
    CONSTRAINT [fk_metadata_project_table_mappings_table_target_id] FOREIGN KEY ([table_target_id]) REFERENCES [metadata].[project_tables]([id])
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_process_tables] (
    [process_id] [int] NOT NULL,
    [table_id] [int] NOT NULL,

    CONSTRAINT [pk_metadata_project_process_tables] PRIMARY KEY CLUSTERED ([process_id] ASC, [table_id] ASC),
    CONSTRAINT [fk_metadata_project_process_tables_process_id] FOREIGN KEY ([process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [fk_metadata_project_process_tables_table_id] FOREIGN KEY ([table_id]) REFERENCES [metadata].[project_tables]([id])
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_table_batches] (
    [id] [int] NOT NULL,
    [position] [smallint] NOT NULL,
    [batch_column_name] [varchar](50) NOT NULL,
    [batch_value] [varchar](50) NOT NULL,
    [batch_start_value] [varchar](50) NULL,
    [batch_end_value] [varchar](50) NULL,
    [batch_column_type] [varchar](20) NOT NULL,
    [execution_required] [bit] NOT NULL CONSTRAINT [df_metadata_project_table_batches_execution_required] DEFAULT 0,
    [batch_source_table_id] [int] NOT NULL,
    [is_active] [bit] NOT NULL CONSTRAINT [df_metadata_project_table_batches_is_active] DEFAULT 1,
    [created_at] [datetime2] NOT NULL CONSTRAINT [df_metadata_project_table_batches_created_at] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [pk_metadata_project_table_batches] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_metadata_project_table_batches_batch_source_table_id] FOREIGN KEY ([batch_source_table_id]) REFERENCES [metadata].[project_tables]([id])
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_process_table_batches] (
    [process_id] [int] NOT NULL,
    [table_id] [int] NOT NULL,
    [batch_id] [int] NOT NULL,

    CONSTRAINT [pk_metadata_project_process_table_batches] PRIMARY KEY CLUSTERED ([process_id] ASC, [table_id] ASC, [batch_id] ASC),
    CONSTRAINT [fk_metadata_project_process_table_batches_process_id] FOREIGN KEY ([process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [fk_metadata_project_process_table_batches_table_id] FOREIGN KEY ([table_id]) REFERENCES [metadata].[project_tables]([id]),
    CONSTRAINT [fk_metadata_project_process_table_batches_batch_id] FOREIGN KEY ([batch_id]) REFERENCES [metadata].[project_table_batches]([id])
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_columns] (
    [id] [int] NOT NULL,
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
GO

---------------------- V2 ----------------------
CREATE TABLE [metadata].[project_process_actions]
(
    [id] INT NOT NULL,
    [project_process_id] INT NOT NULL,
    [position] SMALLINT NOT NULL,
    [action_name] VARCHAR(100) NOT NULL,
    [action_type] VARCHAR(30) NOT NULL,
    [execution_database_id] SMALLINT NULL,
    [schema_name] VARCHAR(50) NOT NULL,
    [object_name] VARCHAR(128) NOT NULL,
    [parameter_template] VARCHAR(30) NULL,
    [is_required] BIT NOT NULL CONSTRAINT [df_metadata_project_process_actions_is_required] DEFAULT (1),
    [is_active] BIT NOT NULL CONSTRAINT [df_metadata_project_process_actions_is_active] DEFAULT (1),
    [created_at] DATETIME2 NOT NULL CONSTRAINT [df_metadata_project_process_actions_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_metadata_project_process_actions_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [pk_metadata_project_process_actions] PRIMARY KEY ([id]),
    CONSTRAINT [fk_metadata_project_process_actions_project_process_id] FOREIGN KEY ([project_process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [fk_metadata_project_process_actions_execution_database_id] FOREIGN KEY ([execution_database_id]) REFERENCES [metadata].[project_databases]([id]),
    CONSTRAINT [uk_metadata_project_process_actions_process_position] UNIQUE ([project_process_id], [position])
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_process_dependencies]
(
    [project_process_id] INT NOT NULL,
    [dependency_project_process_id] INT NOT NULL,

    CONSTRAINT [pk_metadata_project_process_dependencies] PRIMARY KEY ([project_process_id], [dependency_project_process_id]),
    CONSTRAINT [fk_metadata_project_process_dependencies_project_process_id] FOREIGN KEY ([project_process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [fk_metadata_project_process_dependencies_dependency_project_process_id] FOREIGN KEY ([dependency_project_process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [ck_metadata_project_process_dependencies_no_self_dependency] CHECK ([project_process_id] <> [dependency_project_process_id])
);
