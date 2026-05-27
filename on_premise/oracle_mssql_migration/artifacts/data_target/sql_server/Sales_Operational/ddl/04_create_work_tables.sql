/*
    Script name
        04_create_work_tables.sql

    Purpose
        Creates transformed work tables for the Sales_Operational migration.

    Design rules
        - Work tables store validated and transformed rows before final load.
        - Table names use PascalCase under the lower-case work schema.
        - Resolved prod surrogate keys are stored where final loads require
          foreign-key relationships.
        - Audit columns are intentionally excluded because work data is
          temporary and controlled by ETL execution metadata.
*/

USE [Sales_Operational];
GO

CREATE TABLE [work].[AddressType] (
    [SourceAddressTypeID] INT NOT NULL,
    [Name] VARCHAR(50) NOT NULL,

    CONSTRAINT [pk_work_AddressType_SourceAddressTypeID] PRIMARY KEY CLUSTERED ([SourceAddressTypeID] ASC)
);
GO

CREATE TABLE [work].[CountryRegion] (
    [SourceCountryRegionCode] VARCHAR(3) NOT NULL,
    [Name] VARCHAR(50) NOT NULL,

    CONSTRAINT [pk_work_CountryRegion_SourceCountryRegionCode] PRIMARY KEY CLUSTERED ([SourceCountryRegionCode] ASC)
);
GO

CREATE TABLE [work].[SalesTerritory] (
    [SourceTerritoryID] INT NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [TerritoryGroup] VARCHAR(50) NOT NULL,
    [CountryRegionKey] INT NOT NULL,

    CONSTRAINT [pk_work_SalesTerritory_SourceTerritoryID] PRIMARY KEY CLUSTERED ([SourceTerritoryID] ASC)
);
GO

CREATE TABLE [work].[StateProvince] (
    [SourceStateProvinceID] INT NOT NULL,
    [StateProvinceCode] CHAR(3) NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [CountryRegionKey] INT NOT NULL,
    [SalesTerritoryKey] INT NOT NULL,

    CONSTRAINT [pk_work_StateProvince_SourceStateProvinceID] PRIMARY KEY CLUSTERED ([SourceStateProvinceID] ASC)
);
GO

CREATE TABLE [work].[ProductCategory] (
    [SourceProductSubcategoryID] INT NOT NULL,
    [SourceProductCategoryID] INT NOT NULL,
    [Name] VARCHAR(50) NOT NULL,

    CONSTRAINT [pk_work_ProductCategory_SourceProductSubcategoryID] PRIMARY KEY CLUSTERED ([SourceProductSubcategoryID] ASC)
);
GO

CREATE TABLE [work].[SpecialOffer] (
    [SourceSpecialOfferID] INT NOT NULL,
    [Description] VARCHAR(255) NOT NULL,
    [DiscountPct] DECIMAL(10,4) NOT NULL,
    [OfferType] VARCHAR(50) NOT NULL,
    [Category] VARCHAR(50) NOT NULL,
    [StartDate] DATE NOT NULL,
    [EndDate] DATE NOT NULL,
    [MinQty] INT NOT NULL,
    [MaxQty] INT NULL,

    CONSTRAINT [pk_work_SpecialOffer_SourceSpecialOfferID] PRIMARY KEY CLUSTERED ([SourceSpecialOfferID] ASC)
);
GO

CREATE TABLE [work].[ShipMethod] (
    [SourceShipMethodID] INT NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [ShipBase] DECIMAL(19,4) NOT NULL,
    [ShipRate] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_work_ShipMethod_SourceShipMethodID] PRIMARY KEY CLUSTERED ([SourceShipMethodID] ASC)
);
GO

CREATE TABLE [work].[Currency] (
    [SourceCurrencyCode] CHAR(3) NOT NULL,
    [Name] VARCHAR(50) NOT NULL,

    CONSTRAINT [pk_work_Currency_SourceCurrencyCode] PRIMARY KEY CLUSTERED ([SourceCurrencyCode] ASC)
);
GO

CREATE TABLE [work].[CurrencyRate] (
    [SourceCurrencyRateID] INT NOT NULL,
    [CurrencyRateDate] DATETIME2(7) NOT NULL,
    [FromCurrencyKey] INT NOT NULL,
    [ToCurrencyKey] INT NOT NULL,
    [AverageRate] DECIMAL(19,4) NOT NULL,
    [EndOfDayRate] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_work_CurrencyRate_SourceCurrencyRateID] PRIMARY KEY CLUSTERED ([SourceCurrencyRateID] ASC)
);
GO

CREATE TABLE [work].[CreditCard] (
    [SourceCreditCardID] INT NOT NULL,
    [CardType] VARCHAR(50) NOT NULL,
    [CardNumberLast4] CHAR(4) NOT NULL,
    [ExpMonth] TINYINT NOT NULL,
    [ExpYear] SMALLINT NOT NULL,

    CONSTRAINT [pk_work_CreditCard_SourceCreditCardID] PRIMARY KEY CLUSTERED ([SourceCreditCardID] ASC)
);
GO

CREATE TABLE [work].[Address] (
    [SourceAddressID] INT NOT NULL,
    [AddressLine1] VARCHAR(60) NOT NULL,
    [AddressLine2] VARCHAR(60) NULL,
    [City] VARCHAR(30) NOT NULL,
    [StateProvinceKey] INT NOT NULL,
    [PostalCode] VARCHAR(15) NOT NULL,
    [AddressTypeKey] INT NULL,

    CONSTRAINT [pk_work_Address_SourceAddressID] PRIMARY KEY CLUSTERED ([SourceAddressID] ASC)
);
GO

CREATE TABLE [work].[Product] (
    [SourceProductID] INT NOT NULL,
    [ProductNumber] VARCHAR(25) NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [Color] VARCHAR(15) NULL,
    [SafetyStockLevel] SMALLINT NOT NULL,
    [ReorderPoint] SMALLINT NOT NULL,
    [StandardCost] DECIMAL(19,4) NOT NULL,
    [ListPrice] DECIMAL(19,4) NOT NULL,
    [Size] VARCHAR(5) NULL,
    [Weight] DECIMAL(8,2) NULL,
    [ProductCategoryKey] INT NULL,
    [SellStartDate] DATE NOT NULL,
    [SellEndDate] DATE NULL,
    [DiscontinuedDate] DATE NULL,

    CONSTRAINT [pk_work_Product_SourceProductID] PRIMARY KEY CLUSTERED ([SourceProductID] ASC)
);
GO

CREATE TABLE [work].[SalesPerson] (
    [SourceBusinessEntityID] INT NOT NULL,
    [SalesTerritoryKey] INT NULL,
    [Title] VARCHAR(8) NULL,
    [FirstName] VARCHAR(50) NOT NULL,
    [MiddleName] VARCHAR(50) NULL,
    [LastName] VARCHAR(50) NOT NULL,
    [JobTitle] VARCHAR(50) NOT NULL,
    [Gender] CHAR(1) NOT NULL,
    [HireDate] DATE NOT NULL,
    [SalesQuota] DECIMAL(19,4) NULL,
    [Bonus] DECIMAL(19,4) NOT NULL,
    [CommissionPct] DECIMAL(10,4) NOT NULL,
    [SalesYTD] DECIMAL(19,4) NOT NULL,
    [SalesLastYear] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_work_SalesPerson_SourceBusinessEntityID] PRIMARY KEY CLUSTERED ([SourceBusinessEntityID] ASC)
);
GO

CREATE TABLE [work].[Customer] (
    [SourceCustomerID] INT NOT NULL,
    [SourcePersonID] INT NULL,
    [SalesTerritoryKey] INT NULL,
    [PersonType] CHAR(2) NULL,
    [Title] VARCHAR(8) NULL,
    [FirstName] VARCHAR(50) NULL,
    [MiddleName] VARCHAR(50) NULL,
    [LastName] VARCHAR(50) NULL,
    [AccountNumber] VARCHAR(20) NULL,

    CONSTRAINT [pk_work_Customer_SourceCustomerID] PRIMARY KEY CLUSTERED ([SourceCustomerID] ASC)
);
GO

CREATE TABLE [work].[SalesOrderHeader] (
    [SourceSalesOrderID] INT NOT NULL,
    [RevisionNumber] TINYINT NOT NULL,
    [OrderDate] DATETIME2(7) NOT NULL,
    [DueDate] DATETIME2(7) NOT NULL,
    [ShipDate] DATETIME2(7) NULL,
    [Status] TINYINT NOT NULL,
    [SalesOrderNumber] VARCHAR(25) NOT NULL,
    [PurchaseOrderNumber] VARCHAR(25) NULL,
    [AccountNumber] VARCHAR(20) NULL,
    [CustomerKey] INT NOT NULL,
    [SalesPersonKey] INT NULL,
    [SalesTerritoryKey] INT NULL,
    [BillToAddressKey] INT NOT NULL,
    [ShipToAddressKey] INT NOT NULL,
    [ShipMethodKey] INT NOT NULL,
    [CreditCardKey] INT NULL,
    [CurrencyRateKey] INT NULL,
    [SubTotal] DECIMAL(19,4) NOT NULL,
    [TaxAmt] DECIMAL(19,4) NOT NULL,
    [Freight] DECIMAL(19,4) NOT NULL,
    [TotalDue] DECIMAL(19,4) NOT NULL,
    [Comment] NVARCHAR(128) NULL,

    CONSTRAINT [pk_work_SalesOrderHeader_SourceSalesOrderID] PRIMARY KEY CLUSTERED ([SourceSalesOrderID] ASC)
);
GO

CREATE TABLE [work].[SalesOrderDetail] (
    [SourceSalesOrderID] INT NOT NULL,
    [SourceSalesOrderDetailID] INT NOT NULL,
    [SalesOrderHeaderKey] INT NOT NULL,
    [ProductKey] INT NOT NULL,
    [SpecialOfferKey] INT NOT NULL,
    [CarrierTrackingNumber] VARCHAR(25) NULL,
    [OrderQty] SMALLINT NOT NULL,
    [UnitPrice] DECIMAL(19,4) NOT NULL,
    [UnitPriceDiscount] DECIMAL(19,4) NOT NULL,
    [LineTotal] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_work_SalesOrderDetail_SourceOrderDetail] PRIMARY KEY CLUSTERED ([SourceSalesOrderID] ASC, [SourceSalesOrderDetailID] ASC)
);
GO
