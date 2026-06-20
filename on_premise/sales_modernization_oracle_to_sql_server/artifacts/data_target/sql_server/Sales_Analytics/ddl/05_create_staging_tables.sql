/*
    Script name
        03_create_staging_tables.sql

    Purpose
        Creates staging tables for the Sales_Analytics migration.

    Design rules
        - Staging tables receive curated operational data before analytical
          validation and dimensional transformation.
        - Table names use PascalCase under the lower-case staging schema.
        - Source identifiers are retained where they support lineage.
        - Audit columns are intentionally excluded because staging data is
          temporary and controlled by ETL execution metadata.
*/

USE [Sales_Analytics];
GO

CREATE TABLE [staging].[DimCustomer] (
    [SourceCustomerID] INT NOT NULL,
    [AccountNumber] VARCHAR(20) NULL,
    [CustomerName] VARCHAR(160) NOT NULL,
    [PersonType] CHAR(2) NULL,

    CONSTRAINT [pk_staging_DimCustomer_SourceCustomerID] PRIMARY KEY CLUSTERED ([SourceCustomerID] ASC)
);
GO

CREATE TABLE [staging].[DimSalesPerson] (
    [SourceBusinessEntityID] INT NOT NULL,
    [SalesPersonName] VARCHAR(160) NOT NULL,
    [JobTitle] VARCHAR(50) NOT NULL,
    [Gender] CHAR(1) NOT NULL,
    [HireDate] DATE NOT NULL,

    CONSTRAINT [pk_staging_DimSalesPerson_SourceBusinessEntityID] PRIMARY KEY CLUSTERED ([SourceBusinessEntityID] ASC)
);
GO

CREATE TABLE [staging].[DimSalesTerritory] (
    [SourceTerritoryID] INT NOT NULL,
    [TerritoryName] VARCHAR(50) NOT NULL,
    [TerritoryGroup] VARCHAR(50) NOT NULL,
    [CountryRegionCode] VARCHAR(3) NOT NULL,
    [CountryRegionName] VARCHAR(50) NOT NULL,

    CONSTRAINT [pk_staging_DimSalesTerritory_SourceTerritoryID] PRIMARY KEY CLUSTERED ([SourceTerritoryID] ASC)
);
GO

CREATE TABLE [staging].[DimProduct] (
    [SourceProductID] INT NOT NULL,
    [ProductNumber] VARCHAR(25) NOT NULL,
    [ProductName] VARCHAR(50) NOT NULL,
    [Color] VARCHAR(15) NULL,
    [Size] VARCHAR(5) NULL,
    [ProductCategoryName] VARCHAR(50) NULL,
    [StandardCost] DECIMAL(19,4) NOT NULL,
    [ListPrice] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_staging_DimProduct_SourceProductID] PRIMARY KEY CLUSTERED ([SourceProductID] ASC)
);
GO

CREATE TABLE [staging].[DimPaymentMethod] (
    [PaymentMethodCode] VARCHAR(60) NOT NULL,
    [SourceCreditCardID] INT NULL,
    [PaymentMethodType] VARCHAR(50) NOT NULL,
    [CardType] VARCHAR(50) NULL,
    [CardNumberLast4] CHAR(4) NULL,

    CONSTRAINT [pk_staging_DimPaymentMethod_PaymentMethodCode] PRIMARY KEY CLUSTERED ([PaymentMethodCode] ASC)
);
GO

CREATE TABLE [staging].[DimShipMethod] (
    [SourceShipMethodID] INT NOT NULL,
    [ShipMethodName] VARCHAR(50) NOT NULL,
    [ShipBase] DECIMAL(19,4) NOT NULL,
    [ShipRate] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_staging_DimShipMethod_SourceShipMethodID] PRIMARY KEY CLUSTERED ([SourceShipMethodID] ASC)
);
GO

CREATE TABLE [staging].[FactSales] (
    [SourceSalesOrderID] INT NOT NULL,
    [SourceSalesOrderDetailID] INT NOT NULL,
    [OrderDate] DATE NOT NULL,
    [DueDate] DATE NOT NULL,
    [ShipDate] DATE NULL,
    [SourceCustomerID] INT NOT NULL,
    [SourceSalesPersonID] INT NULL,
    [SourceTerritoryID] INT NULL,
    [SourceProductID] INT NOT NULL,
    [PaymentMethodCode] VARCHAR(60) NOT NULL,
    [SourceShipMethodID] INT NOT NULL,
    [OrderQty] SMALLINT NOT NULL,
    [UnitPrice] DECIMAL(19,4) NOT NULL,
    [UnitPriceDiscount] DECIMAL(19,4) NOT NULL,
    [LineTotal] DECIMAL(19,4) NOT NULL,
    [SubTotal] DECIMAL(19,4) NOT NULL,
    [TaxAmt] DECIMAL(19,4) NOT NULL,
    [Freight] DECIMAL(19,4) NOT NULL,
    [TotalDue] DECIMAL(19,4) NOT NULL,
    [SalesAmountUSD] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_staging_FactSales_SourceOrderDetail] PRIMARY KEY CLUSTERED ([SourceSalesOrderID] ASC, [SourceSalesOrderDetailID] ASC)
);
GO
