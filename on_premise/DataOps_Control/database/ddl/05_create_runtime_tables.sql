USE [DataOps_Control];
GO

/*============================================================================
  5. Runtime Tables
============================================================================*/

CREATE TABLE [runtime].[execution_runs] (
    [id] BIGINT IDENTITY(1,1) NOT NULL,
    [start_run_date] DATETIME2(7) NOT NULL CONSTRAINT [df_runtime_execution_runs_start_run_date] DEFAULT SYSUTCDATETIME(),
    [end_run_date] DATETIME2(7) NULL,
    [status_code_id] SMALLINT NOT NULL,
    [project_id] SMALLINT NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_runtime_execution_runs_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_runtime_execution_runs_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [pk_runtime_execution_runs] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_runtime_execution_runs_project_id] FOREIGN KEY ([project_id]) REFERENCES [metadata].[projects]([id]),
    CONSTRAINT [fk_runtime_execution_runs_status_code_id] FOREIGN KEY ([status_code_id]) REFERENCES [reference].[status_codes]([id]),
    CONSTRAINT [ck_runtime_execution_runs_end_run_date] CHECK ([end_run_date] IS NULL OR [end_run_date] >= [start_run_date])
) ON [PRIMARY];
GO

CREATE TABLE [runtime].[execution_steps] (
    [id] BIGINT IDENTITY(1,1) NOT NULL,
    [start_step_date] DATETIME2(7) NOT NULL CONSTRAINT [df_runtime_execution_steps_start_step_date] DEFAULT SYSUTCDATETIME(),
    [end_step_date] DATETIME2(7) NULL,
    [status_code_id] SMALLINT NOT NULL,
    [execution_run_id] BIGINT NOT NULL,
    [project_process_id] INT NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_runtime_execution_steps_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_runtime_execution_steps_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [pk_runtime_execution_steps] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_runtime_execution_steps_execution_run_id] FOREIGN KEY ([execution_run_id]) REFERENCES [runtime].[execution_runs]([id]),
    CONSTRAINT [fk_runtime_execution_steps_project_process_id] FOREIGN KEY ([project_process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [fk_runtime_execution_steps_status_code_id] FOREIGN KEY ([status_code_id]) REFERENCES [reference].[status_codes]([id]),
    CONSTRAINT [ck_runtime_execution_steps_end_step_date] CHECK ([end_step_date] IS NULL OR [end_step_date] >= [start_step_date])
) ON [PRIMARY];
GO
