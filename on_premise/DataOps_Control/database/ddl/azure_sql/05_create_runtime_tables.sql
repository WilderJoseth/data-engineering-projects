/*
    Azure SQL Database version of 05_create_runtime_tables.sql
    Target database: DataOps_Control
    Run this script while connected to the DataOps_Control Azure SQL database.
*/

USE [DataOps_Control];
GO

/*============================================================================
  5. Runtime Tables
============================================================================*/

CREATE TABLE [runtime].[execution_runs] (
    [id] [int] IDENTITY(1,1) NOT NULL,
    [start_run_date] [datetime2] NOT NULL CONSTRAINT [df_runtime_execution_runs_start_run_date] DEFAULT SYSUTCDATETIME(),
    [end_run_date] [datetime2] NULL,
    [status_code_id] [smallint] NOT NULL,
    [project_id] [smallint] NOT NULL,
    [created_by] [varchar](50) NOT NULL CONSTRAINT [df_runtime_execution_runs_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [pk_runtime_execution_runs] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_runtime_execution_runs_project_id] FOREIGN KEY ([project_id]) REFERENCES [metadata].[projects]([id]),
    CONSTRAINT [fk_runtime_execution_runs_status_code_id] FOREIGN KEY ([status_code_id]) REFERENCES [reference].[status_codes]([id])
);
GO

CREATE TABLE [runtime].[execution_steps] (
    [id] [bigint] IDENTITY(1,1) NOT NULL,
    [start_step_date] [datetime2] NOT NULL CONSTRAINT [df_runtime_execution_steps_start_step_date] DEFAULT SYSUTCDATETIME(),
    [end_step_date] [datetime2] NULL,
    [status_code_id] [smallint] NOT NULL,
    [execution_run_id] [int] NOT NULL,
    [project_process_id] [int] NOT NULL,
    [created_by] [varchar](50) NOT NULL CONSTRAINT [df_runtime_execution_steps_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [pk_runtime_execution_steps] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_runtime_execution_steps_execution_run_id] FOREIGN KEY ([execution_run_id]) REFERENCES [runtime].[execution_runs]([id]),
    CONSTRAINT [fk_runtime_execution_steps_project_process_id] FOREIGN KEY ([project_process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [fk_runtime_execution_steps_status_code_id] FOREIGN KEY ([status_code_id]) REFERENCES [reference].[status_codes]([id])
);
GO