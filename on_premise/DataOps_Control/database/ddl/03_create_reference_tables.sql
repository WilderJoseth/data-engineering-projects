USE [DataOps_Control];
GO

/*============================================================================
  3. Reference Tables
============================================================================*/

CREATE TABLE [reference].[status_codes] (
    [id] [smallint] NOT NULL,
    [code] [varchar](15) NOT NULL,
    [description] [varchar](100) NULL,
    [is_active] [bit] NOT NULL CONSTRAINT [df_reference_status_codes_is_active] DEFAULT 1,
    [created_at] [datetime2] NOT NULL CONSTRAINT [df_reference_status_codes_created_at] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [pk_reference_status_codes] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [uk_reference_status_codes_code] UNIQUE ([code])
) ON [PRIMARY];
GO

CREATE TABLE [reference].[validation_codes] (
    [id] [smallint] NOT NULL,
    [code] [varchar](50) NOT NULL,
    [description] [varchar](200) NULL,
    [severity] [varchar](15) NOT NULL,
    [is_active] [bit] NOT NULL CONSTRAINT [df_reference_validation_codes_is_active] DEFAULT 1,
    [created_at] [datetime2] NOT NULL CONSTRAINT [df_reference_validation_codes_created_at] DEFAULT SYSUTCDATETIME(),

    CONSTRAINT [pk_reference_validation_codes] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [uk_reference_validation_codes_code] UNIQUE ([code])
) ON [PRIMARY];
GO

CREATE TABLE [reference].[monitoring_metric_codes] (
    [id] SMALLINT IDENTITY(1,1) NOT NULL,
    [code] VARCHAR(100) NOT NULL,
    [description] VARCHAR(500) NULL,
    [metric_source] VARCHAR(50) NOT NULL,
    [metric_value_type] VARCHAR(20) NOT NULL,
    [metric_unit] VARCHAR(30) NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_reference_monitoring_metric_codes_is_active] DEFAULT (1),
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_reference_monitoring_metric_codes_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_reference_monitoring_metric_codes_created_by] DEFAULT USER_NAME(),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,

    CONSTRAINT [pk_reference_monitoring_metric_codes] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [uk_reference_monitoring_metric_codes_code] UNIQUE ([code])
);
GO
