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