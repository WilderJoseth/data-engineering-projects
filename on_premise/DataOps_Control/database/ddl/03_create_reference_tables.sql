USE [DataOps_Control];
GO

/*============================================================================
  3. Reference Tables
============================================================================*/

CREATE TABLE [reference].[status_codes] (
    [id] SMALLINT NOT NULL,
    [code] VARCHAR(15) NOT NULL,
    [description] VARCHAR(100) NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_reference_status_codes_is_active] DEFAULT (1),
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_reference_status_codes_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_reference_status_codes_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [pk_reference_status_codes] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [uk_reference_status_codes_code] UNIQUE ([code])
) ON [PRIMARY];
GO

CREATE TABLE [reference].[validation_codes] (
    [id] SMALLINT NOT NULL,
    [code] VARCHAR(50) NOT NULL,
    [description] VARCHAR(200) NULL,
    [severity] VARCHAR(15) NOT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_reference_validation_codes_is_active] DEFAULT (1),
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_reference_validation_codes_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_reference_validation_codes_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [pk_reference_validation_codes] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [uk_reference_validation_codes_code] UNIQUE ([code]),
    CONSTRAINT [ck_reference_validation_codes_severity] CHECK ([severity] IN ('ERROR', 'WARNING', 'INFO'))
) ON [PRIMARY];
GO

CREATE TABLE [reference].[monitoring_metric_codes] (
    [id] SMALLINT NOT NULL,
    [code] VARCHAR(100) NOT NULL,
    [description] VARCHAR(500) NULL,
    [metric_source] VARCHAR(50) NOT NULL,
    [metric_value_type] VARCHAR(20) NOT NULL,
    [metric_unit] VARCHAR(30) NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_reference_monitoring_metric_codes_is_active] DEFAULT (1),
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_reference_monitoring_metric_codes_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_reference_monitoring_metric_codes_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [pk_reference_monitoring_metric_codes] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [uk_reference_monitoring_metric_codes_code] UNIQUE ([code]),
    CONSTRAINT [ck_reference_monitoring_metric_codes_metric_source] CHECK ([metric_source] IN ('RUNTIME', 'VALIDATION', 'RECONCILIATION', 'ERROR_LOG')),
    CONSTRAINT [ck_reference_monitoring_metric_codes_metric_value_type] CHECK ([metric_value_type] IN ('BIGINT', 'DECIMAL')),
    CONSTRAINT [ck_reference_monitoring_metric_codes_metric_unit] CHECK ([metric_unit] IN ('SECONDS', 'ISSUES', 'MISMATCHES', 'ERRORS', 'ROWS'))
);
GO
