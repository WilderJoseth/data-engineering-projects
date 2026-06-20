/*
    Azure SQL Database version of 06_create_observability_tables.sql
    Target database: DataOps_Control
    Run this script while connected to the DataOps_Control Azure SQL database.
*/

USE [DataOps_Control];
GO

/*============================================================================
  6. Observability Tables
============================================================================*/

CREATE TABLE [observability].[error_logs] (
    [id] [int] IDENTITY(1,1) NOT NULL,
    [error_source] [varchar](200) NOT NULL,
    [details] [varchar](MAX) NOT NULL,
    [execution_step_id] [bigint] NOT NULL,
    [created_at] [datetime2] NOT NULL CONSTRAINT [df_observability_error_logs_created_at] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [pk_observability_error_logs] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_observability_error_logs_execution_step_id] FOREIGN KEY ([execution_step_id]) REFERENCES [runtime].[execution_steps]([id])
);
GO

CREATE TABLE [observability].[reconciliation_results] (
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
);
GO

CREATE TABLE [observability].[validation_results] (
    [id] [int] IDENTITY(1,1) NOT NULL,
    [details] [varchar](MAX) NOT NULL,
    [affected_row_count] [bigint] NOT NULL,
    [execution_step_id] [bigint] NOT NULL,
    [validation_code_id] [smallint] NOT NULL,
    [created_at] [datetime2] NOT NULL CONSTRAINT [df_observability_validation_results_created_at] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [pk_observability_validation_results] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_observability_validation_results_execution_step_id] FOREIGN KEY ([execution_step_id]) REFERENCES [runtime].[execution_steps]([id]),
    CONSTRAINT [fk_observability_validation_results_validation_code_id] FOREIGN KEY ([validation_code_id]) REFERENCES [reference].[validation_codes]([id])
);
GO