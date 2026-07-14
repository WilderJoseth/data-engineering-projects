USE [DataOps_Control];
GO

/*============================================================================
  5. Runtime Tables
============================================================================*/

CREATE TABLE [runtime].[execution_plans] (
    [id] BIGINT IDENTITY(1,1) NOT NULL,
    [plan_name] VARCHAR(100) NULL,
    [plan_type] VARCHAR(30) NOT NULL,
    [status_code_id] SMALLINT NOT NULL,
    [project_id] SMALLINT NOT NULL,
    [root_project_process_id] INT NULL,
    [scope_description] VARCHAR(500) NULL,
    [start_plan_date] DATETIME2(7) NULL,
    [end_plan_date] DATETIME2(7) NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [DF_runtime_execution_plans_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [DF_runtime_execution_plans_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [PK_runtime_execution_plans] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_runtime_execution_plans_project_id] FOREIGN KEY ([project_id]) REFERENCES [metadata].[projects]([id]),
    CONSTRAINT [FK_runtime_execution_plans_root_project_process_id] FOREIGN KEY ([root_project_process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [FK_runtime_execution_plans_status_code_id] FOREIGN KEY ([status_code_id]) REFERENCES [reference].[status_codes]([id]),
    CONSTRAINT [CK_runtime_execution_plans_plan_type] CHECK ([plan_type] IN ('FULL', 'RECOVERY', 'RERUN', 'REPROCESSING', 'BACKFILL', 'MANUAL')),
    CONSTRAINT [CK_runtime_execution_plans_end_plan_date] CHECK ([end_plan_date] IS NULL OR [start_plan_date] IS NULL OR [end_plan_date] >= [start_plan_date])
) ON [PRIMARY];
GO

CREATE TABLE [runtime].[execution_plan_processes] (
    [id] BIGINT IDENTITY(1,1) NOT NULL,
    [execution_plan_id] BIGINT NOT NULL,
    [project_process_id] INT NOT NULL,
    [status_code_id] SMALLINT NOT NULL,
    [dependency_evaluation_details] VARCHAR(1000) NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [DF_runtime_execution_plan_processes_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [DF_runtime_execution_plan_processes_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [PK_runtime_execution_plan_processes] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_runtime_execution_plan_processes_execution_plan_id] FOREIGN KEY ([execution_plan_id]) REFERENCES [runtime].[execution_plans]([id]),
    CONSTRAINT [FK_runtime_execution_plan_processes_project_process_id] FOREIGN KEY ([project_process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [FK_runtime_execution_plan_processes_status_code_id] FOREIGN KEY ([status_code_id]) REFERENCES [reference].[status_codes]([id]),
    CONSTRAINT [UK_runtime_execution_plan_processes_plan_process] UNIQUE ([execution_plan_id], [project_process_id])
) ON [PRIMARY];
GO

CREATE TABLE [runtime].[execution_watermark_controls] (
    [id] BIGINT IDENTITY(1,1) NOT NULL,
    [project_process_id] INT NOT NULL,
    [table_id] INT NOT NULL,
    [watermark_column_id] INT NOT NULL,
    [last_committed_watermark_value] NVARCHAR(4000) NULL,
    [lower_bound_operator] VARCHAR(5) NOT NULL CONSTRAINT [DF_runtime_execution_watermark_controls_lower_bound_operator] DEFAULT ('>'),
    [upper_bound_operator] VARCHAR(5) NOT NULL CONSTRAINT [DF_runtime_execution_watermark_controls_upper_bound_operator] DEFAULT ('<='),
    [upper_bound_strategy] VARCHAR(50) NOT NULL CONSTRAINT [DF_runtime_execution_watermark_controls_upper_bound_strategy] DEFAULT ('EXECUTION_START_TIME'),
    [is_active] BIT NOT NULL CONSTRAINT [DF_runtime_execution_watermark_controls_is_active] DEFAULT (1),
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [DF_runtime_execution_watermark_controls_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [DF_runtime_execution_watermark_controls_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [PK_runtime_execution_watermark_controls] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_runtime_execution_watermark_controls_project_process_id] FOREIGN KEY ([project_process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [FK_runtime_execution_watermark_controls_table_id] FOREIGN KEY ([table_id]) REFERENCES [metadata].[project_tables]([id]),
    CONSTRAINT [FK_runtime_execution_watermark_controls_watermark_column_id] FOREIGN KEY ([watermark_column_id]) REFERENCES [metadata].[project_columns]([id]),
    CONSTRAINT [UK_runtime_execution_watermark_controls_process_table_column] UNIQUE ([project_process_id], [table_id], [watermark_column_id]),
    CONSTRAINT [CK_runtime_execution_watermark_controls_lower_bound_operator] CHECK ([lower_bound_operator] IN ('>', '>=', '=', '<', '<=')),
    CONSTRAINT [CK_runtime_execution_watermark_controls_upper_bound_operator] CHECK ([upper_bound_operator] IN ('>', '>=', '=', '<', '<=')),
    CONSTRAINT [CK_runtime_execution_watermark_controls_upper_bound_strategy] CHECK ([upper_bound_strategy] IN ('EXECUTION_START_TIME', 'CURRENT_UTC_TIMESTAMP', 'STATIC_VALUE', 'MAX_SOURCE_VALUE'))
) ON [PRIMARY];
GO

CREATE TABLE [runtime].[execution_runs] (
    [id] BIGINT IDENTITY(1,1) NOT NULL,
    [start_run_date] DATETIME2(7) NOT NULL CONSTRAINT [DF_runtime_execution_runs_start_run_date] DEFAULT SYSUTCDATETIME(),
    [end_run_date] DATETIME2(7) NULL,
    [status_code_id] SMALLINT NOT NULL,
    [project_id] SMALLINT NOT NULL,
    [execution_plan_id] BIGINT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [DF_runtime_execution_runs_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [DF_runtime_execution_runs_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [PK_runtime_execution_runs] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_runtime_execution_runs_project_id] FOREIGN KEY ([project_id]) REFERENCES [metadata].[projects]([id]),
    CONSTRAINT [FK_runtime_execution_runs_execution_plan_id] FOREIGN KEY ([execution_plan_id]) REFERENCES [runtime].[execution_plans]([id]),
    CONSTRAINT [FK_runtime_execution_runs_status_code_id] FOREIGN KEY ([status_code_id]) REFERENCES [reference].[status_codes]([id]),
    CONSTRAINT [CK_runtime_execution_runs_end_run_date] CHECK ([end_run_date] IS NULL OR [end_run_date] >= [start_run_date])
) ON [PRIMARY];
GO

CREATE TABLE [runtime].[execution_steps] (
    [id] BIGINT IDENTITY(1,1) NOT NULL,
    [start_step_date] DATETIME2(7) NOT NULL CONSTRAINT [DF_runtime_execution_steps_start_step_date] DEFAULT SYSUTCDATETIME(),
    [end_step_date] DATETIME2(7) NULL,
    [status_code_id] SMALLINT NOT NULL,
    [execution_run_id] BIGINT NOT NULL,
    [project_process_id] INT NOT NULL,
    [execution_plan_process_id] BIGINT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [DF_runtime_execution_steps_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [DF_runtime_execution_steps_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [PK_runtime_execution_steps] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_runtime_execution_steps_execution_run_id] FOREIGN KEY ([execution_run_id]) REFERENCES [runtime].[execution_runs]([id]),
    CONSTRAINT [FK_runtime_execution_steps_project_process_id] FOREIGN KEY ([project_process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [FK_runtime_execution_steps_execution_plan_process_id] FOREIGN KEY ([execution_plan_process_id]) REFERENCES [runtime].[execution_plan_processes]([id]),
    CONSTRAINT [FK_runtime_execution_steps_status_code_id] FOREIGN KEY ([status_code_id]) REFERENCES [reference].[status_codes]([id]),
    CONSTRAINT [CK_runtime_execution_steps_end_step_date] CHECK ([end_step_date] IS NULL OR [end_step_date] >= [start_step_date])
) ON [PRIMARY];
GO

CREATE TABLE [runtime].[execution_watermarks] (
    [id] BIGINT IDENTITY(1,1) NOT NULL,
    [execution_step_id] BIGINT NOT NULL,
    [execution_watermark_control_id] BIGINT NOT NULL,
    [previous_committed_watermark_value] NVARCHAR(4000) NULL,
    [extraction_upper_bound_value] NVARCHAR(4000) NULL,
    [candidate_watermark_value] NVARCHAR(4000) NULL,
    [committed_watermark_value] NVARCHAR(4000) NULL,
    [status_code_id] SMALLINT NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [DF_runtime_execution_watermarks_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [DF_runtime_execution_watermarks_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [PK_runtime_execution_watermarks] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_runtime_execution_watermarks_execution_step_id] FOREIGN KEY ([execution_step_id]) REFERENCES [runtime].[execution_steps]([id]),
    CONSTRAINT [FK_runtime_execution_watermarks_execution_watermark_control_id] FOREIGN KEY ([execution_watermark_control_id]) REFERENCES [runtime].[execution_watermark_controls]([id]),
    CONSTRAINT [FK_runtime_execution_watermarks_status_code_id] FOREIGN KEY ([status_code_id]) REFERENCES [reference].[status_codes]([id]),
    CONSTRAINT [UK_runtime_execution_watermarks_step_control] UNIQUE ([execution_step_id], [execution_watermark_control_id])
) ON [PRIMARY];
GO
