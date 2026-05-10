CREATE DATABASE [Sales_Operational];
GO

CREATE SCHEMA [staging];
GO

CREATE SCHEMA [work];
GO

CREATE SCHEMA [prod];
GO

CREATE SCHEMA [control];
GO

-------------------------- TABLES --------------------------
CREATE TABLE [staging].[AddressType] (
	[AddressTypeID] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,

	CONSTRAINT [pk_staging_AddressType_AddressTypeID] PRIMARY KEY CLUSTERED ([AddressTypeID] ASC)
) ON [PRIMARY];
GO

CREATE TABLE [staging].[Person] (
	[BusinessEntityID] [int] NOT NULL,
	[PersonType] [nchar](2) NOT NULL,
	[Title] [nvarchar](8) NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NOT NULL,

	CONSTRAINT [pk_staging_Person_BusinessEntityID] PRIMARY KEY CLUSTERED ([BusinessEntityID] ASC)
 ) ON [PRIMARY];
GO

CREATE TABLE [staging].[SalesOrderHeader](
	[SalesOrderID] [int] NOT NULL,
	[RevisionNumber] [tinyint] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[DueDate] [datetime] NOT NULL,
	[ShipDate] [datetime] NULL,
	[Status] [tinyint] NOT NULL,
	[SalesOrderNumber] [varchar](10) NOT NULL,
	[PurchaseOrderNumber] [varchar](20) NULL,
	[AccountNumber] [varchar](20) NULL,
	[CustomerID] [int] NOT NULL,
	[SalesPersonID] [int] NULL,
	[TerritoryID] [int] NULL,
	[BillToAddressID] [int] NOT NULL,
	[ShipToAddressID] [int] NOT NULL,
	[ShipMethodID] [int] NOT NULL,
	[CreditCardID] [int] NULL,
	[CurrencyRateID] [int] NULL,
	[SubTotal] [decimal](15, 4) NOT NULL,
	[TaxAmt] [decimal](15, 4) NOT NULL,
	[Freight] [decimal](15, 4) NOT NULL,
	[TotalDue] [decimal](15, 4) NOT NULL,

	CONSTRAINT [pk_staging_SalesOrderHeader_SalesOrderID] PRIMARY KEY CLUSTERED ([SalesOrderID] ASC)
) ON [PRIMARY];
GO

CREATE TABLE [work].[AddressType] (
	[AddressTypeID] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,

	CONSTRAINT [pk_work_AddressType_AddressTypeID] PRIMARY KEY CLUSTERED ([AddressTypeID] ASC)
) ON [PRIMARY];
GO

CREATE TABLE [work].[Customer](
	[CustomerID] [int] NOT NULL,
	[Title] [nvarchar](8) NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[AccountNumber] [varchar](20) NULL,

	CONSTRAINT [pk_work_Customer_CustomerID] PRIMARY KEY CLUSTERED ([CustomerID] ASC)
) ON [PRIMARY];
GO

CREATE TABLE [prod].[AddressType] (
	[ID] [int] IDENTITY(1, 1) NOT NULL,
	[AddressTypeID] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[created_run_id] [int] NOT NULL,
	[created_at] [datetime] NOT NULL,
	[created_by] [varchar](50) NOT NULL,
	[updated_at] [datetime] NULL,
	[updated_by] [varchar](50) NULL,
	[is_active] [bit] NOT NULL CONSTRAINT [df_prod_AddressType_is_active] DEFAULT 1,

	CONSTRAINT [pk_prod_AddressType_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
) ON [PRIMARY];
GO

CREATE TABLE [prod].[Customer](
	[ID] [int] IDENTITY(1, 1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[Title] [nvarchar](8) NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[AccountNumber] [varchar](20) NULL,
	[created_run_id] [int] NOT NULL,
	[created_at] [datetime] NOT NULL,
	[created_by] [varchar](50) NOT NULL,
	[updated_at] [datetime] NULL,
	[updated_by] [varchar](50) NULL,
	[is_active] [bit] NOT NULL CONSTRAINT [df_prod_Customer_is_active] DEFAULT 1,

	CONSTRAINT [pk_prod_Customer_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
) ON [PRIMARY];
GO

CREATE TABLE [control].[reconcilation_results](
	[id] [int] IDENTITY(1, 1) NOT NULL,
	[code] [char](2) NOT NULL,
	[is_start] [bit] NOT NULL CONSTRAINT [df_control_reconcilation_results_is_start] DEFAULT 1,
	[quantity] [bigint] NOT NULL,
	[amount] [decimal](15, 4) NULL,
	[execution_step_id] [int] NOT NULL

	CONSTRAINT [pk_control_reconcilation_results_id] PRIMARY KEY CLUSTERED ([id] ASC)
) ON [PRIMARY];
GO
-------------------------- TABLES --------------------------

-------------------------- STOREDS --------------------------
CREATE PROCEDURE [staging].[usp_cleanup_tables]
AS
BEGIN
SET NOCOUNT ON;
	TRUNCATE TABLE [staging].[AddressType];
	TRUNCATE TABLE [staging].[Person];
SET NOCOUNT OFF;
END;
GO;

CREATE PROCEDURE [work].[usp_cleanup_tables]
AS
BEGIN
SET NOCOUNT ON;
	TRUNCATE TABLE [work].[AddressType];
	TRUNCATE TABLE [work].[Person];
SET NOCOUNT OFF;
END;
GO;

CREATE PROCEDURE [control].[usp_reconcile_AddressType]
	@p_execution_step_id INT,
	@p_is_start BIT = 1
AS
BEGIN
SET NOCOUNT ON;
	IF @p_is_start = 1
	BEGIN
		INSERT INTO [control].[reconcilation_results] ([code], [quantity], [execution_step_id])
		SELECT '', COUNT(1), @p_execution_step_id FROM [staging].[AddressType];
	END
	ELSE
	BEGIN
		INSERT INTO [control].[reconcilation_results] ([code], [is_start], [quantity], [execution_step_id])
		SELECT '', @p_is_start, COUNT(1), @p_execution_step_id FROM [work].[AddressType];		
	END
SET NOCOUNT OFF;
END;
GO;

CREATE PROCEDURE [work].[usp_validate_AddressType]
AS
BEGIN
SET NOCOUNT ON;
	INSERT INTO [work].[AddressType]([AddressTypeID], [Name])
	SELECT [AddressTypeID], [Name] FROM [staging].[AddressType];
SET NOCOUNT OFF;
END;
GO;

CREATE PROCEDURE [prod].[usp_load_AddressType]
AS
BEGIN
SET NOCOUNT ON;
	INSERT INTO [prod].[AddressType]([AddressTypeID], [Name])
	SELECT [AddressTypeID], [Name] FROM [work].[AddressType];
SET NOCOUNT OFF;
END;
GO;

CREATE PROCEDURE [work].[usp_validate_Customer]
AS
BEGIN
SET NOCOUNT ON;
	SELECT 'Person'
	SELECT 'Customer'
SET NOCOUNT OFF;
END;
GO;

CREATE PROCEDURE [prod].[usp_load_Customer]
AS
BEGIN
SET NOCOUNT ON;
	SELECT 'Customer'
SET NOCOUNT OFF;
END;
GO;

CREATE PROCEDURE [work].[usp_validate_SalesOrderHeader]
AS
BEGIN
SET NOCOUNT ON;
	SELECT 'SalesOrderHeader';
SET NOCOUNT OFF;
END;
GO;

CREATE PROCEDURE [prod].[usp_validate_SalesOrderHeader]
AS
BEGIN
SET NOCOUNT ON;
	SELECT 'SalesOrderHeader';
SET NOCOUNT OFF;
END;
GO;
-------------------------- STOREDS --------------------------

