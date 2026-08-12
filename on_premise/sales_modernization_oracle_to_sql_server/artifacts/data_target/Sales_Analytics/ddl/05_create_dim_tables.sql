/*
    Script name
        05_create_dim_tables.sql

    Purpose
        Creates the dimension tables for the analytical star schema used by
        Sales reporting.

    Design rules
        - Dimensions expose business-friendly descriptive attributes.
        - Source identifiers are retained where useful for lineage.
        - Source*ID values are Sales_Operational.prod generated keys, not
          original Oracle identifiers.
        - Operational and source technical columns are excluded.
        - Final tables include standard audit columns from the solution design.
        - Execution-step audit identifiers are supplied by the load process.
*/

USE [Sales_Analytics];
GO

CREATE TABLE [dim].[DimDate] (
    [DimDateKey] INT IDENTITY(1,1) NOT NULL,
    [FullDate] DATE NOT NULL,
    [DayNumberOfWeek] TINYINT NOT NULL,
    [DayName] NVARCHAR(10) NOT NULL,
    [DayNumberOfMonth] TINYINT NOT NULL,
    [DayNumberOfYear] SMALLINT NOT NULL,
    [WeekNumberOfYear] TINYINT NOT NULL,
    [MonthNumber] TINYINT NOT NULL,
    [MonthName] NVARCHAR(10) NOT NULL,
    [CalendarQuarter] TINYINT NOT NULL,
    [CalendarYear] SMALLINT NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_dim_DimDate_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] NVARCHAR(128) NOT NULL CONSTRAINT [df_dim_DimDate_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] NVARCHAR(128) NULL,
    [created_execution_step_id] BIGINT NULL,
    [last_updated_execution_step_id] BIGINT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_dim_DimDate_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_dim_DimDate] PRIMARY KEY CLUSTERED ([DimDateKey] ASC),
    CONSTRAINT [uk_dim_DimDate_FullDate] UNIQUE ([FullDate])
);
GO

CREATE TABLE [dim].[DimCustomer] (
    [DimCustomerKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCustomerID] INT NOT NULL,
    [AccountNumber] VARCHAR(20) NULL,
    [CustomerName] NVARCHAR(160) NOT NULL,
    [PersonType] CHAR(2) NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_dim_DimCustomer_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] NVARCHAR(128) NOT NULL CONSTRAINT [df_dim_DimCustomer_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] NVARCHAR(128) NULL,
    [created_execution_step_id] BIGINT NULL,
    [last_updated_execution_step_id] BIGINT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_dim_DimCustomer_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_dim_DimCustomer] PRIMARY KEY CLUSTERED ([DimCustomerKey] ASC),
    CONSTRAINT [uk_dim_DimCustomer_SourceCustomerID] UNIQUE ([SourceCustomerID])
);
GO

CREATE TABLE [dim].[DimSalesPerson] (
    [DimSalesPersonKey] INT IDENTITY(1,1) NOT NULL,
    [SourceSalesPersonID] INT NOT NULL,
    [SalesPersonName] NVARCHAR(160) NOT NULL,
    [JobTitle] NVARCHAR(50) NOT NULL,
    [Gender] CHAR(1) NOT NULL,
    [HireDate] DATE NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_dim_DimSalesPerson_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] NVARCHAR(128) NOT NULL CONSTRAINT [df_dim_DimSalesPerson_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] NVARCHAR(128) NULL,
    [created_execution_step_id] BIGINT NULL,
    [last_updated_execution_step_id] BIGINT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_dim_DimSalesPerson_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_dim_DimSalesPerson] PRIMARY KEY CLUSTERED ([DimSalesPersonKey] ASC),
    CONSTRAINT [uk_dim_DimSalesPerson_SourceSalesPersonID] UNIQUE ([SourceSalesPersonID])
);
GO

CREATE TABLE [dim].[DimSalesTerritory] (
    [DimSalesTerritoryKey] INT IDENTITY(1,1) NOT NULL,
    [SourceSalesTerritoryID] INT NOT NULL,
    [TerritoryName] NVARCHAR(50) NOT NULL,
    [TerritoryGroup] NVARCHAR(50) NOT NULL,
    [CountryRegionCode] VARCHAR(3) NOT NULL,
    [CountryRegionName] NVARCHAR(50) NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_dim_DimSalesTerritory_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] NVARCHAR(128) NOT NULL CONSTRAINT [df_dim_DimSalesTerritory_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] NVARCHAR(128) NULL,
    [created_execution_step_id] BIGINT NULL,
    [last_updated_execution_step_id] BIGINT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_dim_DimSalesTerritory_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_dim_DimSalesTerritory] PRIMARY KEY CLUSTERED ([DimSalesTerritoryKey] ASC),
    CONSTRAINT [uk_dim_DimSalesTerritory_SourceSalesTerritoryID] UNIQUE ([SourceSalesTerritoryID])
);
GO

CREATE TABLE [dim].[DimProduct] (
    [DimProductKey] INT IDENTITY(1,1) NOT NULL,
    [SourceProductID] INT NOT NULL,
    [ProductNumber] VARCHAR(25) NOT NULL,
    [ProductName] NVARCHAR(50) NOT NULL,
    [Color] NVARCHAR(15) NULL,
    [Size] NVARCHAR(5) NULL,
    [ProductCategoryName] NVARCHAR(50) NULL,
    [StandardCost] DECIMAL(19,4) NOT NULL,
    [ListPrice] DECIMAL(19,4) NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_dim_DimProduct_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] NVARCHAR(128) NOT NULL CONSTRAINT [df_dim_DimProduct_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] NVARCHAR(128) NULL,
    [created_execution_step_id] BIGINT NULL,
    [last_updated_execution_step_id] BIGINT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_dim_DimProduct_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_dim_DimProduct] PRIMARY KEY CLUSTERED ([DimProductKey] ASC),
    CONSTRAINT [uk_dim_DimProduct_SourceProductID] UNIQUE ([SourceProductID])
);
GO

CREATE TABLE [dim].[DimPaymentMethod] (
    [DimPaymentMethodKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCreditCardID] INT NULL,
    [PaymentMethodType] NVARCHAR(50) NOT NULL,
    [CardType] NVARCHAR(50) NULL,
    [CardNumberLast4] CHAR(4) NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_dim_DimPaymentMethod_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] NVARCHAR(128) NOT NULL CONSTRAINT [df_dim_DimPaymentMethod_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] NVARCHAR(128) NULL,
    [created_execution_step_id] BIGINT NULL,
    [last_updated_execution_step_id] BIGINT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_dim_DimPaymentMethod_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_dim_DimPaymentMethod] PRIMARY KEY CLUSTERED ([DimPaymentMethodKey] ASC)
);
GO

CREATE TABLE [dim].[DimShipMethod] (
    [DimShipMethodKey] INT IDENTITY(1,1) NOT NULL,
    [SourceShipMethodID] INT NOT NULL,
    [ShipMethodName] NVARCHAR(50) NOT NULL,
    [ShipBase] DECIMAL(19,4) NOT NULL,
    [ShipRate] DECIMAL(19,4) NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_dim_DimShipMethod_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] NVARCHAR(128) NOT NULL CONSTRAINT [df_dim_DimShipMethod_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] NVARCHAR(128) NULL,
    [created_execution_step_id] BIGINT NULL,
    [last_updated_execution_step_id] BIGINT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_dim_DimShipMethod_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_dim_DimShipMethod] PRIMARY KEY CLUSTERED ([DimShipMethodKey] ASC),
    CONSTRAINT [uk_dim_DimShipMethod_SourceShipMethodID] UNIQUE ([SourceShipMethodID])
);
GO
