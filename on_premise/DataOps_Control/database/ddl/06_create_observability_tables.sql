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
    [created_at] [datetime2] NOT NULL,

    CONSTRAINT [pk_observability_error_logs] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_observability_error_logs_execution_step_id] FOREIGN KEY ([execution_step_id]) REFERENCES [runtime].[execution_steps]([id]),
    CONSTRAINT [df_observability_error_logs_created_at] DEFAULT SYSUTCDATETIME()
) ON [PRIMARY];
GO

CREATE TABLE [observability].[reconciliation_results] (
    [id] [int] IDENTITY(1,1) NOT NULL,
    [metric_name] [varchar](50) NOT NULL,
    [reconciliation_key] [varchar](100) NULL,
    [reconciliation_side] [varchar](20) NOT NULL,
    [metric_value_decimal] [decimal](20, 4) NULL,
    [metric_value_bigint] [bigint] NULL,
    [execution_step_id] [bigint] NOT NULL,
    [created_at] [datetime2] NOT NULL,

    CONSTRAINT [pk_observability_reconciliation_results] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_observability_reconciliation_results_execution_step_id] FOREIGN KEY ([execution_step_id]) REFERENCES [runtime].[execution_steps]([id]),
    CONSTRAINT [df_observability_reconciliation_results_created_at] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [ck_observability_reconciliation_results_single_metric_value]
        CHECK
        (
            (
                [metric_value_bigint] IS NOT NULL
                AND [metric_value_decimal] IS NULL
            )
            OR
            (
                [metric_value_decimal] IS NOT NULL
                AND [metric_value_bigint] IS NULL
            )
        ),
    CONSTRAINT [ck_observability_reconciliation_results_side] CHECK ([reconciliation_side] IN ('SOURCE', 'TARGET', 'STAGING', 'WORK', 'FINAL'))
) ON [PRIMARY];
GO

CREATE TABLE [observability].[validation_results] (
    [id] [int] IDENTITY(1,1) NOT NULL,
    [details] [varchar](MAX) NOT NULL,
    [affected_row_count] [bigint] NOT NULL,
    [execution_step_id] [bigint] NOT NULL,
    [validation_code_id] [smallint] NOT NULL,
    [created_at] [datetime2] NOT NULL,

    CONSTRAINT [pk_observability_validation_results] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_observability_validation_results_execution_step_id] FOREIGN KEY ([execution_step_id]) REFERENCES [runtime].[execution_steps]([id]),
    CONSTRAINT [fk_observability_validation_results_validation_code_id] FOREIGN KEY ([validation_code_id]) REFERENCES [reference].[validation_codes]([id]),
    CONSTRAINT [df_observability_validation_results_created_at] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [ck_observability_validation_results_affected_row_count] CHECK ([affected_row_count] >= 0)
) ON [PRIMARY];
GO

CREATE TABLE [observability].[monitoring_results] (
    [id] BIGINT IDENTITY(1,1) NOT NULL,
    [execution_step_id] BIGINT NOT NULL,
    [project_process_monitoring_metric_id] INT NOT NULL,
    [actual_value_bigint] BIGINT NULL,
    [actual_value_decimal] DECIMAL(20,4) NULL,
    [is_within_expected_range] BIT NOT NULL,
    [created_at] DATETIME2(7) NOT NULL,
    [created_by] VARCHAR(50) NOT NULL,

    CONSTRAINT [pk_observability_monitoring_results] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_observability_monitoring_results_execution_step_id] FOREIGN KEY ([execution_step_id]) REFERENCES [runtime].[execution_steps]([id]),
    CONSTRAINT [fk_observability_monitoring_results_project_process_monitoring_metric_id] FOREIGN KEY ([project_process_monitoring_metric_id]) REFERENCES [metadata].[project_process_monitoring_metrics]([id]),
    CONSTRAINT [uk_observability_monitoring_results_step_metric] UNIQUE ([execution_step_id], [project_process_monitoring_metric_id]),
    CONSTRAINT [df_observability_monitoring_results_created_at] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [df_observability_monitoring_results_created_by] DEFAULT USER_NAME(),
    CONSTRAINT [ck_observability_monitoring_results_single_actual_value]
        CHECK
        (
            (
                [actual_value_bigint] IS NOT NULL
                AND [actual_value_decimal] IS NULL
            )
            OR
            (
                [actual_value_decimal] IS NOT NULL
                AND [actual_value_bigint] IS NULL
            )
        )
);
GO
