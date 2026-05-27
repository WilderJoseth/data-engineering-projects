/*
    Script name
        04_create_work_tables.sql

    Purpose
        Creates transformed work tables for the Sales_Analytics migration.

    Design rules
        - Work tables store validated dimensional and fact rows before final load.
        - Table names use PascalCase under the lower-case work schema.
        - Fact work rows store resolved dimension keys and date keys.
        - Audit columns are intentionally excluded because work data is temporary
          and controlled by ETL execution metadata.
*/

USE [Sales_Analytics];
GO

CREATE TABLE [work].[DimDate] (
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

    CONSTRAINT [pk_work_DimDate_DateKey] PRIMARY KEY CLUSTERED ([DateKey] ASC)
);
GO

CREATE TABLE [work].[DimCustomer] (
    [SourceCustomerID] INT NOT NULL,
    [AccountNumber] VARCHAR(20) NULL,
    [CustomerName] VARCHAR(160) NOT NULL,
    [PersonType] CHAR(2) NULL,

    CONSTRAINT [pk_work_DimCustomer_SourceCustomerID] PRIMARY KEY CLUSTERED ([SourceCustomerID] ASC)
);
GO

CREATE TABLE [work].[DimSalesPerson] (
    [SourceBusinessEntityID] INT NOT NULL,
    [SalesPersonName] VARCHAR(160) NOT NULL,
    [JobTitle] VARCHAR(50) NOT NULL,
    [Gender] CHAR(1) NOT NULL,
    [HireDate] DATE NOT NULL,

    CONSTRAINT [pk_work_DimSalesPerson_SourceBusinessEntityID] PRIMARY KEY CLUSTERED ([SourceBusinessEntityID] ASC)
);
GO

CREATE TABLE [work].[DimSalesTerritory] (
    [SourceTerritoryID] INT NOT NULL,
    [TerritoryName] VARCHAR(50) NOT NULL,
    [TerritoryGroup] VARCHAR(50) NOT NULL,
    [CountryRegionCode] VARCHAR(3) NOT NULL,
    [CountryRegionName] VARCHAR(50) NOT NULL,

    CONSTRAINT [pk_work_DimSalesTerritory_SourceTerritoryID] PRIMARY KEY CLUSTERED ([SourceTerritoryID] ASC)
);
GO

CREATE TABLE [work].[DimProduct] (
    [SourceProductID] INT NOT NULL,
    [ProductNumber] VARCHAR(25) NOT NULL,
    [ProductName] VARCHAR(50) NOT NULL,
    [Color] VARCHAR(15) NULL,
    [Size] VARCHAR(5) NULL,
    [ProductCategoryName] VARCHAR(50) NULL,
    [StandardCost] DECIMAL(19,4) NOT NULL,
    [ListPrice] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_work_DimProduct_SourceProductID] PRIMARY KEY CLUSTERED ([SourceProductID] ASC)
);
GO

CREATE TABLE [work].[DimPaymentMethod] (
    [PaymentMethodCode] VARCHAR(60) NOT NULL,
    [SourceCreditCardID] INT NULL,
    [PaymentMethodType] VARCHAR(50) NOT NULL,
    [CardType] VARCHAR(50) NULL,
    [CardNumberLast4] CHAR(4) NULL,

    CONSTRAINT [pk_work_DimPaymentMethod_PaymentMethodCode] PRIMARY KEY CLUSTERED ([PaymentMethodCode] ASC)
);
GO

CREATE TABLE [work].[DimShipMethod] (
    [SourceShipMethodID] INT NOT NULL,
    [ShipMethodName] VARCHAR(50) NOT NULL,
    [ShipBase] DECIMAL(19,4) NOT NULL,
    [ShipRate] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_work_DimShipMethod_SourceShipMethodID] PRIMARY KEY CLUSTERED ([SourceShipMethodID] ASC)
);
GO

CREATE TABLE [work].[FactSales] (
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

    CONSTRAINT [pk_work_FactSales_SourceOrderDetail] PRIMARY KEY CLUSTERED ([SourceSalesOrderID] ASC, [SourceSalesOrderDetailID] ASC)
);
GO
