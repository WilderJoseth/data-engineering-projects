USE [DataOps_Control];
GO

/*============================================================================
  4. Metadata Tables
============================================================================*/

CREATE TABLE [metadata].[projects] (
    [id] SMALLINT NOT NULL,
    [name] VARCHAR(100) NOT NULL,
    [repository_url] VARCHAR(500) NULL,
    [is_active] BIT NOT NULL CONSTRAINT [DF_metadata_projects_is_active] DEFAULT (1),
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [DF_metadata_projects_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [DF_metadata_projects_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [PK_metadata_projects] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [UK_metadata_projects_name] UNIQUE ([name])
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_databases] (
    [id] SMALLINT NOT NULL,
    [name] VARCHAR(50) NOT NULL,
    [platform_type] VARCHAR(30) NOT NULL,
    [database_role] VARCHAR(30) NULL,
    [project_id] SMALLINT NOT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [DF_metadata_project_databases_is_active] DEFAULT (1),
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [DF_metadata_project_databases_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [DF_metadata_project_databases_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [PK_metadata_project_databases] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_metadata_project_databases_project_id] FOREIGN KEY ([project_id]) REFERENCES [metadata].[projects]([id]),
    CONSTRAINT [UK_metadata_project_databases_project_name] UNIQUE ([project_id], [name]),
    CONSTRAINT [CK_metadata_project_databases_database_role] CHECK ([database_role] IN ('SOURCE', 'TARGET'))
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_database_mappings] (
    [database_source_id] SMALLINT NOT NULL,
    [database_target_id] SMALLINT NOT NULL,

    CONSTRAINT [PK_metadata_project_database_mappings] PRIMARY KEY CLUSTERED ([database_source_id] ASC, [database_target_id] ASC),
    CONSTRAINT [FK_metadata_project_database_mappings_database_source_id] FOREIGN KEY ([database_source_id]) REFERENCES [metadata].[project_databases]([id]),
    CONSTRAINT [FK_metadata_project_database_mappings_database_target_id] FOREIGN KEY ([database_target_id]) REFERENCES [metadata].[project_databases]([id])
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_processes] (
    [id] INT NOT NULL,
    [name] VARCHAR(50) NOT NULL,
    [project_id] SMALLINT NOT NULL,
    [parent_process_id] INT NULL,
    [load_strategy] VARCHAR(30) NULL,
    [is_execution_required] BIT NOT NULL CONSTRAINT [DF_metadata_project_processes_execution_required] DEFAULT (0),
    [is_active] BIT NOT NULL CONSTRAINT [DF_metadata_project_processes_is_active] DEFAULT (1),
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [DF_metadata_project_processes_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [DF_metadata_project_processes_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [PK_metadata_project_processes] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_metadata_project_processes_project_id] FOREIGN KEY ([project_id]) REFERENCES [metadata].[projects]([id]),
    CONSTRAINT [FK_metadata_project_processes_parent_process_id] FOREIGN KEY ([parent_process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [UK_metadata_project_processes_project_name] UNIQUE ([project_id], [parent_process_id], [name]),
    CONSTRAINT [CK_metadata_project_processes_no_self_parent] CHECK ([parent_process_id] IS NULL OR [parent_process_id] <> [id]),
    CONSTRAINT [CK_metadata_project_processes_load_strategy] CHECK ([load_strategy] IN ('FULL', 'BATCH', 'INCREMENTAL'))
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_objects] (
    [id] INT NOT NULL,
    [schema_name] VARCHAR(50) NOT NULL,
    [name] VARCHAR(50) NOT NULL,
    [database_id] SMALLINT NOT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [DF_metadata_project_objects_is_active] DEFAULT (1),
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [DF_metadata_project_objects_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [DF_metadata_project_objects_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [PK_metadata_project_objects] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_metadata_project_objects_database_id] FOREIGN KEY ([database_id]) REFERENCES [metadata].[project_databases]([id]),
    CONSTRAINT [UK_metadata_project_objects_database_schema_name] UNIQUE ([database_id], [schema_name], [name])
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_object_mappings] (
    [object_source_id] INT NOT NULL,
    [object_target_id] INT NOT NULL,

    CONSTRAINT [PK_metadata_project_object_mappings] PRIMARY KEY CLUSTERED ([object_source_id] ASC, [object_target_id] ASC),
    CONSTRAINT [FK_metadata_project_object_mappings_object_source_id] FOREIGN KEY ([object_source_id]) REFERENCES [metadata].[project_objects]([id]),
    CONSTRAINT [FK_metadata_project_object_mappings_object_target_id] FOREIGN KEY ([object_target_id]) REFERENCES [metadata].[project_objects]([id])
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_process_objects] (
    [process_id] INT NOT NULL,
    [object_id] INT NOT NULL,
    [write_strategy] VARCHAR(30) NULL,

    CONSTRAINT [PK_metadata_project_process_objects] PRIMARY KEY CLUSTERED ([process_id] ASC, [object_id] ASC),
    CONSTRAINT [FK_metadata_project_process_objects_process_id] FOREIGN KEY ([process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [FK_metadata_project_process_objects_object_id] FOREIGN KEY ([object_id]) REFERENCES [metadata].[project_objects]([id]),
    CONSTRAINT [CK_metadata_project_process_objects_write_strategy] CHECK ([write_strategy] IN ('APPEND', 'TRUNCATE_INSERT', 'OVERWRITE', 'UPSERT', 'MERGE'))
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_object_batches] (
    [id] INT NOT NULL,
    [position] SMALLINT NOT NULL,
    [batch_column_name] VARCHAR(50) NOT NULL,
    [batch_value] VARCHAR(50) NOT NULL,
    [batch_start_value] VARCHAR(50) NULL,
    [batch_end_value] VARCHAR(50) NULL,
    [batch_column_type] VARCHAR(20) NOT NULL,
    [is_execution_required] BIT NOT NULL CONSTRAINT [DF_metadata_project_object_batches_is_execution_required] DEFAULT (0),
    [batch_driver_object_id] INT NOT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [DF_metadata_project_object_batches_is_active] DEFAULT (1),
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [DF_metadata_project_object_batches_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [DF_metadata_project_object_batches_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [PK_metadata_project_object_batches] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_metadata_project_object_batches_batch_driver_object_id] FOREIGN KEY ([batch_driver_object_id]) REFERENCES [metadata].[project_objects]([id]),
    CONSTRAINT [CK_metadata_project_object_batches_position] CHECK ([position] > 0),
    CONSTRAINT [CK_metadata_project_object_batches_batch_column_type] CHECK ([batch_column_type] IN ('DATE', 'DATETIME', 'DATETIME2', 'INT', 'BIGINT', 'VARCHAR')),
    CONSTRAINT [CK_metadata_project_object_batches_range_pair]
        CHECK
        (
            ([batch_start_value] IS NULL AND [batch_end_value] IS NULL) 
            OR 
            ([batch_start_value] IS NOT NULL AND [batch_end_value] IS NOT NULL)
        ),
    CONSTRAINT [UK_metadata_project_object_batches_source_column_value] UNIQUE ([batch_driver_object_id], [batch_column_name], [batch_value])
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_process_object_batches] (
    [process_id] INT NOT NULL,
    [object_id] INT NOT NULL,
    [batch_id] INT NOT NULL,

    CONSTRAINT [PK_metadata_project_process_object_batches] PRIMARY KEY CLUSTERED ([process_id] ASC, [object_id] ASC, [batch_id] ASC),
    CONSTRAINT [FK_metadata_project_process_object_batches_process_id] FOREIGN KEY ([process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [FK_metadata_project_process_object_batches_object_id] FOREIGN KEY ([object_id]) REFERENCES [metadata].[project_objects]([id]),
    CONSTRAINT [FK_metadata_project_process_object_batches_batch_id] FOREIGN KEY ([batch_id]) REFERENCES [metadata].[project_object_batches]([id])
) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_object_columns] (
    [id] INT NOT NULL,
    [position] SMALLINT NOT NULL,
    [name] VARCHAR(50) NOT NULL,
    [type] VARCHAR(20) NOT NULL,
    [size] SMALLINT NULL,
    [size_scale] SMALLINT NULL,
    [default_value] VARCHAR(50) NULL,
    [is_nullable] BIT NOT NULL CONSTRAINT [DF_metadata_project_object_columns_is_nullable] DEFAULT (0),
    [is_watermark] BIT NOT NULL CONSTRAINT [DF_metadata_project_object_columns_is_watermark] DEFAULT (0),
    [is_reconciliation_column] BIT NOT NULL CONSTRAINT [DF_metadata_project_object_columns_is_reconciliation_column] DEFAULT (0),
    [object_id] INT NOT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [DF_metadata_project_object_columns_is_active] DEFAULT (1),
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [DF_metadata_project_object_columns_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [DF_metadata_project_object_columns_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [PK_metadata_project_object_columns] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_metadata_project_object_columns_object_id] FOREIGN KEY ([object_id]) REFERENCES [metadata].[project_objects]([id]),
    CONSTRAINT [UK_metadata_project_object_columns_object_name] UNIQUE ([object_id], [name]),
    CONSTRAINT [CK_metadata_project_object_columns_position] CHECK ([position] > 0),
    CONSTRAINT [CK_metadata_project_object_columns_size] CHECK ([size] IS NULL OR [size] > 0),
    CONSTRAINT [CK_metadata_project_object_columns_size_scale]
        CHECK
        (
            [size_scale] IS NULL
            OR
            (
                [size_scale] >= 0
                AND ([size] IS NULL OR [size_scale] <= [size])
            )
        )
) ON [PRIMARY];
GO

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
    [is_required] BIT NOT NULL CONSTRAINT [DF_metadata_project_process_actions_is_required] DEFAULT (1),
    [is_active] BIT NOT NULL CONSTRAINT [DF_metadata_project_process_actions_is_active] DEFAULT (1),
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [DF_metadata_project_process_actions_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [DF_metadata_project_process_actions_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [PK_metadata_project_process_actions] PRIMARY KEY ([id]),
    CONSTRAINT [FK_metadata_project_process_actions_project_process_id] FOREIGN KEY ([project_process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [FK_metadata_project_process_actions_execution_database_id] FOREIGN KEY ([execution_database_id]) REFERENCES [metadata].[project_databases]([id]),
    CONSTRAINT [UK_metadata_project_process_actions_process_position] UNIQUE ([project_process_id], [position])

) ON [PRIMARY];
GO

CREATE TABLE [metadata].[project_process_dependencies]
(
    [project_process_id] INT NOT NULL,
    [dependency_project_process_id] INT NOT NULL,

    CONSTRAINT [PK_metadata_project_process_dependencies] PRIMARY KEY ([project_process_id], [dependency_project_process_id]),
    CONSTRAINT [FK_metadata_project_process_dependencies_project_process_id] FOREIGN KEY ([project_process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [FK_metadata_project_process_dependencies_dependency_project_process_id] FOREIGN KEY ([dependency_project_process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [CK_metadata_project_process_dependencies_no_self_dependency] CHECK ([project_process_id] <> [dependency_project_process_id])
);

CREATE TABLE [metadata].[project_process_monitoring_metrics]
(
    [id] INT NOT NULL,
    [project_process_id] INT NOT NULL,
    [monitoring_metric_code_id] SMALLINT NOT NULL,
    [min_value_bigint] BIGINT NULL,
    [max_value_bigint] BIGINT NULL,
    [min_value_decimal] DECIMAL(20,4) NULL,
    [max_value_decimal] DECIMAL(20,4) NULL,
    [severity] VARCHAR(20) NOT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [DF_metadata_project_process_monitoring_metrics_is_active] DEFAULT (1),
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [DF_metadata_project_process_monitoring_metrics_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [DF_metadata_project_process_monitoring_metrics_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [PK_metadata_project_process_monitoring_metrics] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_metadata_project_process_monitoring_metrics_project_process_id] FOREIGN KEY ([project_process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [FK_metadata_project_process_monitoring_metrics_metric_code_id] FOREIGN KEY ([monitoring_metric_code_id]) REFERENCES [reference].[monitoring_metric_codes]([id]),
    CONSTRAINT [UK_metadata_project_process_monitoring_metrics_process_metric] UNIQUE ([project_process_id], [monitoring_metric_code_id]),
    CONSTRAINT [CK_metadata_project_process_monitoring_metrics_severity] CHECK ([severity] IN ('ERROR', 'WARNING', 'INFO')),
    CONSTRAINT [CK_metadata_project_process_monitoring_metrics_bigint_range]
        CHECK
        (
            [min_value_bigint] IS NULL
            OR [max_value_bigint] IS NULL
            OR [min_value_bigint] <= [max_value_bigint]
        ),
    CONSTRAINT [CK_metadata_project_process_monitoring_metrics_decimal_range]
        CHECK
        (
            [min_value_decimal] IS NULL
            OR [max_value_decimal] IS NULL
            OR [min_value_decimal] <= [max_value_decimal]
        ),
    CONSTRAINT [CK_metadata_project_process_monitoring_metrics_single_value_family]
        CHECK
        (
            (
                ([min_value_bigint] IS NOT NULL OR [max_value_bigint] IS NOT NULL)
                AND [min_value_decimal] IS NULL
                AND [max_value_decimal] IS NULL
            )
            OR
            (
                ([min_value_decimal] IS NOT NULL OR [max_value_decimal] IS NOT NULL)
                AND [min_value_bigint] IS NULL
                AND [max_value_bigint] IS NULL
            )
        )
);
GO

CREATE TABLE [metadata].[project_notifications]
(
    [id] INT NOT NULL,
    [project_id] SMALLINT NOT NULL,
    [project_process_id] INT NOT NULL,
    [notification_name] VARCHAR(100) NOT NULL,
    [description] VARCHAR(500) NULL,
    [notification_method] VARCHAR(30) NOT NULL,
    [subject_template] NVARCHAR(300) NOT NULL,
    [recipients] NVARCHAR(MAX) NOT NULL,
    [copy_recipients] NVARCHAR(MAX) NULL,
    [blind_copy_recipients] NVARCHAR(MAX) NULL,
    [is_active] BIT NOT NULL CONSTRAINT [DF_metadata_project_notifications_is_active] DEFAULT (1),
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [DF_metadata_project_notifications_created_at] DEFAULT SYSUTCDATETIME(),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [DF_metadata_project_notifications_created_by] DEFAULT USER_NAME(),

    CONSTRAINT [PK_metadata_project_notifications] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_metadata_project_notifications_project_id] FOREIGN KEY ([project_id]) REFERENCES [metadata].[projects]([id]),
    CONSTRAINT [FK_metadata_project_notifications_project_process_id] FOREIGN KEY ([project_process_id]) REFERENCES [metadata].[project_processes]([id]),
    CONSTRAINT [UK_metadata_project_notifications_process_method] UNIQUE ([project_process_id], [notification_method]),
    CONSTRAINT [CK_metadata_project_notifications_notification_method] CHECK ([notification_method] IN ('EMAIL', 'TEAMS', 'WEBHOOK'))
);
GO
