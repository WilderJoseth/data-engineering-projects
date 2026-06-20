/*
    Script name
        06_create_control_tables.sql

    Purpose
        Creates local control tables used by the Sales_Operational migration.

    Scope
        Control tables store local validation, reconciliation, and process status results before they are published to DataOps_Control.
*/

USE [Sales_Operational];
GO

CREATE TABLE [control].[status_codes] (
    [id] [smallint] NOT NULL,
    [code] [varchar](50) NOT NULL,

    CONSTRAINT [pk_control_status_codes] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [uk_control_status_codes_code] UNIQUE ([code])
) ON [PRIMARY];
GO

CREATE TABLE [control].[validation_codes] (
    [id] [smallint] NOT NULL,
    [code] [varchar](50) NOT NULL,
    [severity] [varchar](15) NOT NULL,

    CONSTRAINT [pk_control_validation_codes] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [uk_control_validation_codes_code] UNIQUE ([code])
) ON [PRIMARY];
GO

CREATE TABLE [control].[reconciliation_results] (
    [id] [int] IDENTITY(1,1) NOT NULL,
    [metric_name] [varchar](50) NOT NULL,
    [reconciliation_key] [varchar](100) NULL,
    [reconciliation_side] [varchar](20) NOT NULL,
    [metric_value_decimal] [decimal](20, 4) NULL,
    [metric_value_bigint] [bigint] NULL,
    [execution_step_id] [bigint] NOT NULL,

    CONSTRAINT [pk_control_reconciliation_results] PRIMARY KEY CLUSTERED ([id] ASC)
) ON [PRIMARY];
GO

CREATE TABLE [control].[validation_results] (
    [id] [int] IDENTITY(1,1) NOT NULL,
    [details] [varchar](MAX) NOT NULL,
    [affected_row_count] [bigint] NOT NULL,
    [execution_step_id] [bigint] NOT NULL,
    [validation_code_id] [smallint] NOT NULL,

    CONSTRAINT [pk_control_validation_results] PRIMARY KEY CLUSTERED ([id] ASC)
) ON [PRIMARY];
GO
