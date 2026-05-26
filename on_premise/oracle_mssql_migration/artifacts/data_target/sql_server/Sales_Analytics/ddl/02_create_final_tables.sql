/*
    Script name
        02_create_final_tables.sql

    Purpose
        Creates the final analytical star schema for Sales reporting.

    Design rules
        - Dimensions expose business-friendly descriptive attributes.
        - FactSales is line-grain: one row per sales order detail line.
        - Source identifiers are retained where useful for lineage.
        - Operational and source technical columns are excluded.
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

    CONSTRAINT [pk_dim_DimPaymentMethod] PRIMARY KEY CLUSTERED ([DimPaymentMethodKey] ASC)
);
GO

CREATE TABLE [dim].[DimShipMethod] (
    [DimShipMethodKey] INT IDENTITY(1,1) NOT NULL,
    [SourceShipMethodID] INT NOT NULL,
    [ShipMethodName] VARCHAR(50) NOT NULL,
    [ShipBase] DECIMAL(19,4) NOT NULL,
    [ShipRate] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_dim_DimShipMethod] PRIMARY KEY CLUSTERED ([DimShipMethodKey] ASC),
    CONSTRAINT [uk_dim_DimShipMethod_SourceShipMethodID] UNIQUE ([SourceShipMethodID])
);
GO

CREATE TABLE [fact].[FactSales] (
    [FactSalesKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceSalesOrderID] INT NOT NULL,
    [SourceSalesOrderDetailID] INT NOT NULL,
    [OrderDateKey] INT NOT NULL,
    [DueDateKey] INT NOT NULL,
    [ShipDateKey] INT NOT NULL,
    [DimCustomerKey] INT NOT NULL,
    [DimSalesPersonKey] INT NOT NULL,
    [DimSalesTerritoryKey] INT NOT NULL,
    [DimProductKey] INT NOT NULL,
    [DimPaymentMethodKey] INT NOT NULL,
    [DimShipMethodKey] INT NOT NULL,
    [OrderQty] SMALLINT NOT NULL,
    [UnitPrice] DECIMAL(19,4) NOT NULL,
    [UnitPriceDiscount] DECIMAL(19,4) NOT NULL,
    [LineTotal] DECIMAL(19,4) NOT NULL,
    [SubTotal] DECIMAL(19,4) NOT NULL,
    [TaxAmt] DECIMAL(19,4) NOT NULL,
    [Freight] DECIMAL(19,4) NOT NULL,
    [TotalDue] DECIMAL(19,4) NOT NULL,
    [SalesAmountUSD] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_fact_FactSales] PRIMARY KEY CLUSTERED ([FactSalesKey] ASC),
    CONSTRAINT [uk_fact_FactSales_SourceOrderDetail] UNIQUE ([SourceSalesOrderID], [SourceSalesOrderDetailID]),
    CONSTRAINT [fk_fact_FactSales_OrderDateKey] FOREIGN KEY ([OrderDateKey]) REFERENCES [dim].[DimDate]([DateKey]),
    CONSTRAINT [fk_fact_FactSales_DueDateKey] FOREIGN KEY ([DueDateKey]) REFERENCES [dim].[DimDate]([DateKey]),
    CONSTRAINT [fk_fact_FactSales_ShipDateKey] FOREIGN KEY ([ShipDateKey]) REFERENCES [dim].[DimDate]([DateKey]),
    CONSTRAINT [fk_fact_FactSales_DimCustomerKey] FOREIGN KEY ([DimCustomerKey]) REFERENCES [dim].[DimCustomer]([DimCustomerKey]),
    CONSTRAINT [fk_fact_FactSales_DimSalesPersonKey] FOREIGN KEY ([DimSalesPersonKey]) REFERENCES [dim].[DimSalesPerson]([DimSalesPersonKey]),
    CONSTRAINT [fk_fact_FactSales_DimSalesTerritoryKey] FOREIGN KEY ([DimSalesTerritoryKey]) REFERENCES [dim].[DimSalesTerritory]([DimSalesTerritoryKey]),
    CONSTRAINT [fk_fact_FactSales_DimProductKey] FOREIGN KEY ([DimProductKey]) REFERENCES [dim].[DimProduct]([DimProductKey]),
    CONSTRAINT [fk_fact_FactSales_DimPaymentMethodKey] FOREIGN KEY ([DimPaymentMethodKey]) REFERENCES [dim].[DimPaymentMethod]([DimPaymentMethodKey]),
    CONSTRAINT [fk_fact_FactSales_DimShipMethodKey] FOREIGN KEY ([DimShipMethodKey]) REFERENCES [dim].[DimShipMethod]([DimShipMethodKey])
);
GO
