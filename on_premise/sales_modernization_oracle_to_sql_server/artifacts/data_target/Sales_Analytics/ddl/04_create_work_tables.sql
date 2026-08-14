/*
    Script name
        04_create_work_tables.sql
    Purpose
        Creates transformed work tables for the Sales_Analytics migration.

    Design rules
        - Work tables store validated dimensional and fact rows before final load.
        - Source*ID columns identify rows generated in Sales_Operational.prod;
          original Oracle identifiers are not carried into Analytics.
        - Table names use PascalCase under the lower-case work schema.
        - Fact work rows store resolved dimension keys and date keys.
        - DimDate rows are generated in work before loading dim.DimDate.
        - Default dimension keys are resolved dynamically by ETL; default
          member rows are not hardcoded in DDL.
        - Audit columns are intentionally excluded because work data is temporary
          and controlled by ETL execution metadata.
*/

USE [Sales_Analytics];
GO

CREATE TABLE [work].[DimDate] (
    [WorkDimDateKey] INT IDENTITY(1,1) NOT NULL,
    [DimDateKey] INT NOT NULL,
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

    CONSTRAINT [pk_work_DimDate_WorkDimDateKey] PRIMARY KEY CLUSTERED ([WorkDimDateKey] ASC),
    CONSTRAINT [uk_work_DimDate_DimDateKey] UNIQUE ([DimDateKey]),
    CONSTRAINT [uk_work_DimDate_FullDate] UNIQUE ([FullDate])
);
GO

CREATE TABLE [work].[DimCustomer] (
    [WorkDimCustomerKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCustomerID] INT NOT NULL,
    [AccountNumber] VARCHAR(20) NULL,
    [CustomerName] NVARCHAR(160) NOT NULL,
    [PersonType] CHAR(2) NULL,

    CONSTRAINT [pk_work_DimCustomer_WorkDimCustomerKey] PRIMARY KEY CLUSTERED ([WorkDimCustomerKey] ASC),
    CONSTRAINT [uk_work_DimCustomer_SourceCustomerID] UNIQUE ([SourceCustomerID])
);
GO

CREATE TABLE [work].[DimSalesPerson] (
    [WorkDimSalesPersonKey] INT IDENTITY(1,1) NOT NULL,
    [SourceSalesPersonID] INT NOT NULL,
    [SalesPersonName] NVARCHAR(160) NOT NULL,
    [JobTitle] NVARCHAR(50) NOT NULL,
    [Gender] CHAR(1) NOT NULL,
    [HireDate] DATE NOT NULL,

    CONSTRAINT [pk_work_DimSalesPerson_WorkDimSalesPersonKey] PRIMARY KEY CLUSTERED ([WorkDimSalesPersonKey] ASC),
    CONSTRAINT [uk_work_DimSalesPerson_SourceSalesPersonID] UNIQUE ([SourceSalesPersonID])
);
GO

CREATE TABLE [work].[DimSalesTerritory] (
    [WorkDimSalesTerritoryKey] INT IDENTITY(1,1) NOT NULL,
    [SourceSalesTerritoryID] INT NOT NULL,
    [TerritoryName] NVARCHAR(50) NOT NULL,
    [TerritoryGroup] NVARCHAR(50) NOT NULL,
    [CountryRegionCode] VARCHAR(3) NOT NULL,
    [CountryRegionName] NVARCHAR(50) NOT NULL,

    CONSTRAINT [pk_work_DimSalesTerritory_WorkDimSalesTerritoryKey] PRIMARY KEY CLUSTERED ([WorkDimSalesTerritoryKey] ASC),
    CONSTRAINT [uk_work_DimSalesTerritory_SourceSalesTerritoryID] UNIQUE ([SourceSalesTerritoryID])
);
GO

CREATE TABLE [work].[DimProduct] (
    [WorkDimProductKey] INT IDENTITY(1,1) NOT NULL,
    [SourceProductID] INT NOT NULL,
    [ProductNumber] VARCHAR(25) NOT NULL,
    [ProductName] NVARCHAR(50) NOT NULL,
    [Color] NVARCHAR(15) NULL,
    [Size] NVARCHAR(5) NULL,
    [ProductCategoryName] NVARCHAR(50) NULL,
    [StandardCost] DECIMAL(19,4) NOT NULL,
    [ListPrice] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_work_DimProduct_WorkDimProductKey] PRIMARY KEY CLUSTERED ([WorkDimProductKey] ASC),
    CONSTRAINT [uk_work_DimProduct_SourceProductID] UNIQUE ([SourceProductID])
);
GO

CREATE TABLE [work].[DimPaymentMethod] (
    [WorkDimPaymentMethodKey] INT IDENTITY(1,1) NOT NULL,
    [PaymentMethodCode] VARCHAR(60) NOT NULL,
    [SourceCreditCardID] INT NULL,
    [PaymentMethodType] NVARCHAR(50) NOT NULL,
    [CardType] NVARCHAR(50) NULL,
    [CardNumberLast4] CHAR(4) NULL,

    CONSTRAINT [pk_work_DimPaymentMethod_WorkDimPaymentMethodKey] PRIMARY KEY CLUSTERED ([WorkDimPaymentMethodKey] ASC),
    CONSTRAINT [uk_work_DimPaymentMethod_PaymentMethodCode] UNIQUE ([PaymentMethodCode])
);
GO

CREATE TABLE [work].[DimShipMethod] (
    [WorkDimShipMethodKey] INT IDENTITY(1,1) NOT NULL,
    [SourceShipMethodID] INT NOT NULL,
    [ShipMethodName] NVARCHAR(50) NOT NULL,
    [ShipBase] DECIMAL(19,4) NOT NULL,
    [ShipRate] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_work_DimShipMethod_WorkDimShipMethodKey] PRIMARY KEY CLUSTERED ([WorkDimShipMethodKey] ASC),
    CONSTRAINT [uk_work_DimShipMethod_SourceShipMethodID] UNIQUE ([SourceShipMethodID])
);
GO

CREATE TABLE [work].[FactSales] (
    [WorkFactSalesKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceSalesOrderID] BIGINT NOT NULL,
    [SourceSalesOrderDetailID] BIGINT NOT NULL,
    [OrderDimDateKey] INT NOT NULL,
    [DueDimDateKey] INT NOT NULL,
    [ShipDimDateKey] INT NOT NULL,
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

    CONSTRAINT [pk_work_FactSales_WorkFactSalesKey] PRIMARY KEY CLUSTERED ([WorkFactSalesKey] ASC),
    CONSTRAINT [uk_work_FactSales_SourceOrderDetail] UNIQUE ([SourceSalesOrderID], [SourceSalesOrderDetailID])
);
GO
