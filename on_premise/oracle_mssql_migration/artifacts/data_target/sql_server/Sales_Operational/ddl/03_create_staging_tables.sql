/*
    Script name
        03_create_staging_tables.sql

    Purpose
        Creates raw staging tables for the Sales_Operational migration.

    Design rules
        - Staging tables receive extracted Oracle data before validation.
        - Table names use PascalCase under the lower-case staging schema.
        - Source identifiers are preserved for traceability and rerun support.
        - Source identifiers are not constrained as unique in staging because
          repeated extract loads and duplicate detection are handled by the
          validation layer.
        - Character columns use NVARCHAR/NCHAR to preserve source Unicode text
          before validation and target conversion.
        - Audit columns are intentionally excluded because staging data is
          temporary and controlled by ETL execution metadata.
*/

USE [Sales_Operational];
GO

CREATE TABLE [staging].[AddressType] (
    [StagingAddressTypeKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceAddressTypeID] INT NOT NULL,
    [Name] NVARCHAR(50) NOT NULL,

    CONSTRAINT [pk_staging_AddressType_StagingAddressTypeKey] PRIMARY KEY CLUSTERED ([StagingAddressTypeKey] ASC)
);
GO

CREATE TABLE [staging].[CountryRegion] (
    [StagingCountryRegionKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceCountryRegionCode] NVARCHAR(3) NOT NULL,
    [Name] NVARCHAR(50) NOT NULL,

    CONSTRAINT [pk_staging_CountryRegion_StagingCountryRegionKey] PRIMARY KEY CLUSTERED ([StagingCountryRegionKey] ASC)
);
GO

CREATE TABLE [staging].[SalesTerritory] (
    [StagingSalesTerritoryKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceTerritoryID] INT NOT NULL,
    [Name] NVARCHAR(50) NOT NULL,
    [TerritoryGroup] NVARCHAR(50) NOT NULL,
    [SourceCountryRegionCode] NVARCHAR(3) NOT NULL,

    CONSTRAINT [pk_staging_SalesTerritory_StagingSalesTerritoryKey] PRIMARY KEY CLUSTERED ([StagingSalesTerritoryKey] ASC)
);
GO

CREATE TABLE [staging].[StateProvince] (
    [StagingStateProvinceKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceStateProvinceID] INT NOT NULL,
    [StateProvinceCode] NCHAR(3) NOT NULL,
    [Name] NVARCHAR(50) NOT NULL,
    [SourceCountryRegionCode] NVARCHAR(3) NOT NULL,
    [SourceTerritoryID] INT NOT NULL,

    CONSTRAINT [pk_staging_StateProvince_StagingStateProvinceKey] PRIMARY KEY CLUSTERED ([StagingStateProvinceKey] ASC)
);
GO

CREATE TABLE [staging].[ProductCategory] (
    [StagingProductCategoryKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceProductSubcategoryID] INT NOT NULL,
    [SourceProductCategoryID] INT NOT NULL,
    [Name] NVARCHAR(50) NOT NULL,

    CONSTRAINT [pk_staging_ProductCategory_StagingProductCategoryKey] PRIMARY KEY CLUSTERED ([StagingProductCategoryKey] ASC)
);
GO

CREATE TABLE [staging].[SpecialOffer] (
    [StagingSpecialOfferKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceSpecialOfferID] INT NOT NULL,
    [Description] NVARCHAR(255) NOT NULL,
    [DiscountPct] DECIMAL(10,4) NOT NULL,
    [OfferType] NVARCHAR(50) NOT NULL,
    [Category] NVARCHAR(50) NOT NULL,
    [StartDate] DATE NOT NULL,
    [EndDate] DATE NOT NULL,
    [MinQty] INT NOT NULL,
    [MaxQty] INT NULL,

    CONSTRAINT [pk_staging_SpecialOffer_StagingSpecialOfferKey] PRIMARY KEY CLUSTERED ([StagingSpecialOfferKey] ASC)
);
GO

CREATE TABLE [staging].[ShipMethod] (
    [StagingShipMethodKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceShipMethodID] INT NOT NULL,
    [Name] NVARCHAR(50) NOT NULL,
    [ShipBase] DECIMAL(19,4) NOT NULL,
    [ShipRate] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_staging_ShipMethod_StagingShipMethodKey] PRIMARY KEY CLUSTERED ([StagingShipMethodKey] ASC)
);
GO

CREATE TABLE [staging].[Currency] (
    [StagingCurrencyKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceCurrencyCode] NCHAR(3) NOT NULL,
    [Name] NVARCHAR(50) NOT NULL,

    CONSTRAINT [pk_staging_Currency_StagingCurrencyKey] PRIMARY KEY CLUSTERED ([StagingCurrencyKey] ASC)
);
GO

CREATE TABLE [staging].[CurrencyRate] (
    [StagingCurrencyRateKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceCurrencyRateID] INT NOT NULL,
    [CurrencyRateDate] DATETIME2(7) NOT NULL,
    [FromCurrencyCode] NCHAR(3) NOT NULL,
    [ToCurrencyCode] NCHAR(3) NOT NULL,
    [AverageRate] DECIMAL(19,4) NOT NULL,
    [EndOfDayRate] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_staging_CurrencyRate_StagingCurrencyRateKey] PRIMARY KEY CLUSTERED ([StagingCurrencyRateKey] ASC)
);
GO

CREATE TABLE [staging].[CreditCard] (
    [StagingCreditCardKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceCreditCardID] INT NOT NULL,
    [CardType] NVARCHAR(50) NOT NULL,
    [CardNumber] NVARCHAR(25) NOT NULL,
    [ExpMonth] TINYINT NOT NULL,
    [ExpYear] SMALLINT NOT NULL,

    CONSTRAINT [pk_staging_CreditCard_StagingCreditCardKey] PRIMARY KEY CLUSTERED ([StagingCreditCardKey] ASC)
);
GO

CREATE TABLE [staging].[Address] (
    [StagingAddressKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceAddressID] INT NOT NULL,
    [AddressLine1] NVARCHAR(60) NOT NULL,
    [AddressLine2] NVARCHAR(60) NULL,
    [City] NVARCHAR(30) NOT NULL,
    [SourceStateProvinceID] INT NOT NULL,
    [PostalCode] NVARCHAR(15) NOT NULL,
    [SourceAddressTypeID] INT NULL,

    CONSTRAINT [pk_staging_Address_StagingAddressKey] PRIMARY KEY CLUSTERED ([StagingAddressKey] ASC)
);
GO

CREATE TABLE [staging].[Product] (
    [StagingProductKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceProductID] INT NOT NULL,
    [ProductNumber] NVARCHAR(25) NOT NULL,
    [Name] NVARCHAR(50) NOT NULL,
    [Color] NVARCHAR(15) NULL,
    [SafetyStockLevel] SMALLINT NOT NULL,
    [ReorderPoint] SMALLINT NOT NULL,
    [StandardCost] DECIMAL(19,4) NOT NULL,
    [ListPrice] DECIMAL(19,4) NOT NULL,
    [Size] NVARCHAR(5) NULL,
    [Weight] DECIMAL(8,2) NULL,
    [SourceProductSubcategoryID] INT NULL,
    [SellStartDate] DATE NOT NULL,
    [SellEndDate] DATE NULL,
    [DiscontinuedDate] DATE NULL,

    CONSTRAINT [pk_staging_Product_StagingProductKey] PRIMARY KEY CLUSTERED ([StagingProductKey] ASC)
);
GO

CREATE TABLE [staging].[SalesPerson] (
    [StagingSalesPersonKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceBusinessEntityID] INT NOT NULL,
    [SourceTerritoryID] INT NULL,
    [Title] NVARCHAR(8) NULL,
    [FirstName] NVARCHAR(50) NOT NULL,
    [MiddleName] NVARCHAR(50) NULL,
    [LastName] NVARCHAR(50) NOT NULL,
    [JobTitle] NVARCHAR(50) NOT NULL,
    [Gender] NCHAR(1) NOT NULL,
    [HireDate] DATE NOT NULL,
    [SalesQuota] DECIMAL(19,4) NULL,
    [Bonus] DECIMAL(19,4) NOT NULL,
    [CommissionPct] DECIMAL(10,4) NOT NULL,
    [SalesYTD] DECIMAL(19,4) NOT NULL,
    [SalesLastYear] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_staging_SalesPerson_StagingSalesPersonKey] PRIMARY KEY CLUSTERED ([StagingSalesPersonKey] ASC)
);
GO

CREATE TABLE [staging].[Customer] (
    [StagingCustomerKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceCustomerID] INT NOT NULL,
    [SourcePersonID] INT NULL,
    [SourceTerritoryID] INT NULL,
    [PersonType] NCHAR(2) NULL,
    [Title] NVARCHAR(8) NULL,
    [FirstName] NVARCHAR(50) NULL,
    [MiddleName] NVARCHAR(50) NULL,
    [LastName] NVARCHAR(50) NULL,
    [AccountNumber] NVARCHAR(20) NULL,

    CONSTRAINT [pk_staging_Customer_StagingCustomerKey] PRIMARY KEY CLUSTERED ([StagingCustomerKey] ASC)
);
GO

CREATE TABLE [staging].[SalesOrderHeader] (
    [StagingSalesOrderHeaderKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceSalesOrderID] INT NOT NULL,
    [RevisionNumber] TINYINT NOT NULL,
    [OrderDate] DATETIME2(7) NOT NULL,
    [DueDate] DATETIME2(7) NOT NULL,
    [ShipDate] DATETIME2(7) NULL,
    [Status] TINYINT NOT NULL,
    [SalesOrderNumber] NVARCHAR(25) NOT NULL,
    [PurchaseOrderNumber] NVARCHAR(25) NULL,
    [AccountNumber] NVARCHAR(20) NULL,
    [SourceCustomerID] INT NOT NULL,
    [SourceSalesPersonID] INT NULL,
    [SourceTerritoryID] INT NULL,
    [SourceBillToAddressID] INT NOT NULL,
    [SourceShipToAddressID] INT NOT NULL,
    [SourceShipMethodID] INT NOT NULL,
    [SourceCreditCardID] INT NULL,
    [SourceCurrencyRateID] INT NULL,
    [SubTotal] DECIMAL(19,4) NOT NULL,
    [TaxAmt] DECIMAL(19,4) NOT NULL,
    [Freight] DECIMAL(19,4) NOT NULL,
    [TotalDue] DECIMAL(19,4) NOT NULL,
    [Comment] NVARCHAR(128) NULL,

    CONSTRAINT [pk_staging_SalesOrderHeader_StagingSalesOrderHeaderKey] PRIMARY KEY CLUSTERED ([StagingSalesOrderHeaderKey] ASC)
);
GO

CREATE TABLE [staging].[SalesOrderDetail] (
    [StagingSalesOrderDetailKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceSalesOrderID] INT NOT NULL,
    [SourceSalesOrderDetailID] INT NOT NULL,
    [CarrierTrackingNumber] NVARCHAR(25) NULL,
    [OrderQty] SMALLINT NOT NULL,
    [SourceProductID] INT NOT NULL,
    [SourceSpecialOfferID] INT NOT NULL,
    [UnitPrice] DECIMAL(19,4) NOT NULL,
    [UnitPriceDiscount] DECIMAL(19,4) NOT NULL,
    [LineTotal] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_staging_SalesOrderDetail_StagingSalesOrderDetailKey] PRIMARY KEY CLUSTERED ([StagingSalesOrderDetailKey] ASC)
);
GO
