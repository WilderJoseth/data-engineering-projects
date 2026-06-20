/*
    Script name
        02_create_dimensional_tables.sql

    Purpose
        Creates the dimensional tables for the analytical star schema for Sales reporting.

    Design rules
        - Dimensions expose business-friendly descriptive attributes.
        - FactSales is line-grain: one row per sales order detail line.
        - Source identifiers are retained where useful for lineage.
        - Operational and source technical columns are excluded.
        - Final tables include standard audit columns from the solution design.
        - created_run_id must be supplied by the migration process.
*/

USE [Sales_Analytics];
GO

CREATE TABLE [dim].[DimDate] (
    [DateKey] INT NOT NULL,
    [FullDate] DATE NOT NULL,
    [DayNumberOfWeek] TINYINT NOT NULL,
    [DayName] VARCHAR(10) NOT NULL,
    [DayNumberOfMonth] TINYINT NOT NULL,
    [DayNumberOfYear] SMALLINT NOT NULL,
    [WeekNumberOfYear] TINYINT NOT NULL,
    [MonthNumber] TINYINT NOT NULL,
    [MonthName] VARCHAR(10) NOT NULL,
    [CalendarQuarter] TINYINT NOT NULL,
    [CalendarYear] SMALLINT NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_dim_DimDate_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_dim_DimDate_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_run_id] INT NOT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_dim_DimDate_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_dim_DimDate] PRIMARY KEY CLUSTERED ([DateKey] ASC),
    CONSTRAINT [uk_dim_DimDate_FullDate] UNIQUE ([FullDate])
);
GO

CREATE TABLE [dim].[DimCustomer] (
    [DimCustomerKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCustomerID] INT NOT NULL,
    [AccountNumber] VARCHAR(20) NULL,
    [CustomerName] VARCHAR(160) NOT NULL,
    [PersonType] CHAR(2) NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_dim_DimCustomer_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_dim_DimCustomer_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_run_id] INT NOT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_dim_DimCustomer_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_dim_DimCustomer] PRIMARY KEY CLUSTERED ([DimCustomerKey] ASC),
    CONSTRAINT [uk_dim_DimCustomer_SourceCustomerID] UNIQUE ([SourceCustomerID])
);
GO

CREATE TABLE [dim].[DimSalesPerson] (
    [DimSalesPersonKey] INT IDENTITY(1,1) NOT NULL,
    [SourceBusinessEntityID] INT NOT NULL,
    [SalesPersonName] VARCHAR(160) NOT NULL,
    [JobTitle] VARCHAR(50) NOT NULL,
    [Gender] CHAR(1) NOT NULL,
    [HireDate] DATE NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_dim_DimSalesPerson_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_dim_DimSalesPerson_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_run_id] INT NOT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_dim_DimSalesPerson_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_dim_DimSalesPerson] PRIMARY KEY CLUSTERED ([DimSalesPersonKey] ASC),
    CONSTRAINT [uk_dim_DimSalesPerson_SourceBusinessEntityID] UNIQUE ([SourceBusinessEntityID])
);
GO

CREATE TABLE [dim].[DimSalesTerritory] (
    [DimSalesTerritoryKey] INT IDENTITY(1,1) NOT NULL,
    [SourceTerritoryID] INT NOT NULL,
    [TerritoryName] VARCHAR(50) NOT NULL,
    [TerritoryGroup] VARCHAR(50) NOT NULL,
    [CountryRegionCode] VARCHAR(3) NOT NULL,
    [CountryRegionName] VARCHAR(50) NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_dim_DimSalesTerritory_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_dim_DimSalesTerritory_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_run_id] INT NOT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_dim_DimSalesTerritory_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_dim_DimSalesTerritory] PRIMARY KEY CLUSTERED ([DimSalesTerritoryKey] ASC),
    CONSTRAINT [uk_dim_DimSalesTerritory_SourceTerritoryID] UNIQUE ([SourceTerritoryID])
);
GO

CREATE TABLE [dim].[DimProduct] (
    [DimProductKey] INT IDENTITY(1,1) NOT NULL,
    [SourceProductID] INT NOT NULL,
    [ProductNumber] VARCHAR(25) NOT NULL,
    [ProductName] VARCHAR(50) NOT NULL,
    [Color] VARCHAR(15) NULL,
    [Size] VARCHAR(5) NULL,
    [ProductCategoryName] VARCHAR(50) NULL,
    [StandardCost] DECIMAL(19,4) NOT NULL,
    [ListPrice] DECIMAL(19,4) NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_dim_DimProduct_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_dim_DimProduct_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_run_id] INT NOT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_dim_DimProduct_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_dim_DimProduct] PRIMARY KEY CLUSTERED ([DimProductKey] ASC),
    CONSTRAINT [uk_dim_DimProduct_SourceProductID] UNIQUE ([SourceProductID])
);
GO

CREATE TABLE [dim].[DimPaymentMethod] (
    [DimPaymentMethodKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCreditCardID] INT NULL,
    [PaymentMethodType] VARCHAR(50) NOT NULL,
    [CardType] VARCHAR(50) NULL,
    [CardNumberLast4] CHAR(4) NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_dim_DimPaymentMethod_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_dim_DimPaymentMethod_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_run_id] INT NOT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_dim_DimPaymentMethod_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_dim_DimPaymentMethod] PRIMARY KEY CLUSTERED ([DimPaymentMethodKey] ASC)
);
GO

CREATE TABLE [dim].[DimShipMethod] (
    [DimShipMethodKey] INT IDENTITY(1,1) NOT NULL,
    [SourceShipMethodID] INT NOT NULL,
    [ShipMethodName] VARCHAR(50) NOT NULL,
    [ShipBase] DECIMAL(19,4) NOT NULL,
    [ShipRate] DECIMAL(19,4) NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_dim_DimShipMethod_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_dim_DimShipMethod_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_run_id] INT NOT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_dim_DimShipMethod_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_dim_DimShipMethod] PRIMARY KEY CLUSTERED ([DimShipMethodKey] ASC),
    CONSTRAINT [uk_dim_DimShipMethod_SourceShipMethodID] UNIQUE ([SourceShipMethodID])
);
GO
