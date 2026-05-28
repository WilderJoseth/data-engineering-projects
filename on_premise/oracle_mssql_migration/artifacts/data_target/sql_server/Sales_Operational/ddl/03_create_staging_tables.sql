/*
    Script name
        03_create_staging_tables.sql

    Purpose
        Creates raw staging tables for the Sales_Operational migration.

    Design rules
        - Staging tables receive extracted Oracle data before validation.
        - Table names use PascalCase under the lower-case staging schema.
        - Source identifiers are preserved for traceability and rerun support.
        - Audit columns are intentionally excluded because staging data is
          temporary and controlled by ETL execution metadata.
*/

USE [Sales_Operational];
GO

CREATE TABLE [staging].[AddressType] (
    [StagingAddressTypeKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceAddressTypeID] INT NOT NULL,
    [Name] VARCHAR(50) NOT NULL,

    CONSTRAINT [pk_staging_AddressType_StagingAddressTypeKey] PRIMARY KEY CLUSTERED ([StagingAddressTypeKey] ASC),
    CONSTRAINT [uk_staging_AddressType_SourceAddressTypeID] UNIQUE ([SourceAddressTypeID])
);
GO

CREATE TABLE [staging].[CountryRegion] (
    [SourceCountryRegionCode] VARCHAR(3) NOT NULL,
    [Name] VARCHAR(50) NOT NULL,

    CONSTRAINT [pk_staging_CountryRegion_SourceCountryRegionCode] PRIMARY KEY CLUSTERED ([SourceCountryRegionCode] ASC)
);
GO

CREATE TABLE [staging].[SalesTerritory] (
    [SourceTerritoryID] INT NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [TerritoryGroup] VARCHAR(50) NOT NULL,
    [SourceCountryRegionCode] VARCHAR(3) NOT NULL,

    CONSTRAINT [pk_staging_SalesTerritory_SourceTerritoryID] PRIMARY KEY CLUSTERED ([SourceTerritoryID] ASC)
);
GO

CREATE TABLE [staging].[StateProvince] (
    [SourceStateProvinceID] INT NOT NULL,
    [StateProvinceCode] CHAR(3) NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [SourceCountryRegionCode] VARCHAR(3) NOT NULL,
    [SourceTerritoryID] INT NOT NULL,

    CONSTRAINT [pk_staging_StateProvince_SourceStateProvinceID] PRIMARY KEY CLUSTERED ([SourceStateProvinceID] ASC)
);
GO

CREATE TABLE [staging].[ProductCategory] (
    [SourceProductSubcategoryID] INT NOT NULL,
    [SourceProductCategoryID] INT NOT NULL,
    [Name] VARCHAR(50) NOT NULL,

    CONSTRAINT [pk_staging_ProductCategory_SourceProductSubcategoryID] PRIMARY KEY CLUSTERED ([SourceProductSubcategoryID] ASC)
);
GO

CREATE TABLE [staging].[SpecialOffer] (
    [SourceSpecialOfferID] INT NOT NULL,
    [Description] VARCHAR(255) NOT NULL,
    [DiscountPct] DECIMAL(10,4) NOT NULL,
    [OfferType] VARCHAR(50) NOT NULL,
    [Category] VARCHAR(50) NOT NULL,
    [StartDate] DATE NOT NULL,
    [EndDate] DATE NOT NULL,
    [MinQty] INT NOT NULL,
    [MaxQty] INT NULL,

    CONSTRAINT [pk_staging_SpecialOffer_SourceSpecialOfferID] PRIMARY KEY CLUSTERED ([SourceSpecialOfferID] ASC)
);
GO

CREATE TABLE [staging].[ShipMethod] (
    [SourceShipMethodID] INT NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [ShipBase] DECIMAL(19,4) NOT NULL,
    [ShipRate] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_staging_ShipMethod_SourceShipMethodID] PRIMARY KEY CLUSTERED ([SourceShipMethodID] ASC)
);
GO

CREATE TABLE [staging].[Currency] (
    [SourceCurrencyCode] CHAR(3) NOT NULL,
    [Name] VARCHAR(50) NOT NULL,

    CONSTRAINT [pk_staging_Currency_SourceCurrencyCode] PRIMARY KEY CLUSTERED ([SourceCurrencyCode] ASC)
);
GO

CREATE TABLE [staging].[CurrencyRate] (
    [SourceCurrencyRateID] INT NOT NULL,
    [CurrencyRateDate] DATETIME2(7) NOT NULL,
    [FromCurrencyCode] CHAR(3) NOT NULL,
    [ToCurrencyCode] CHAR(3) NOT NULL,
    [AverageRate] DECIMAL(19,4) NOT NULL,
    [EndOfDayRate] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_staging_CurrencyRate_SourceCurrencyRateID] PRIMARY KEY CLUSTERED ([SourceCurrencyRateID] ASC)
);
GO

CREATE TABLE [staging].[CreditCard] (
    [SourceCreditCardID] INT NOT NULL,
    [CardType] VARCHAR(50) NOT NULL,
    [CardNumber] VARCHAR(25) NOT NULL,
    [ExpMonth] TINYINT NOT NULL,
    [ExpYear] SMALLINT NOT NULL,

    CONSTRAINT [pk_staging_CreditCard_SourceCreditCardID] PRIMARY KEY CLUSTERED ([SourceCreditCardID] ASC)
);
GO

CREATE TABLE [staging].[Address] (
    [SourceAddressID] INT NOT NULL,
    [AddressLine1] VARCHAR(60) NOT NULL,
    [AddressLine2] VARCHAR(60) NULL,
    [City] VARCHAR(30) NOT NULL,
    [SourceStateProvinceID] INT NOT NULL,
    [PostalCode] VARCHAR(15) NOT NULL,
    [SourceAddressTypeID] INT NULL,

    CONSTRAINT [pk_staging_Address_SourceAddressID] PRIMARY KEY CLUSTERED ([SourceAddressID] ASC)
);
GO

CREATE TABLE [staging].[Product] (
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
    [SourceProductSubcategoryID] INT NULL,
    [SellStartDate] DATE NOT NULL,
    [SellEndDate] DATE NULL,
    [DiscontinuedDate] DATE NULL,

    CONSTRAINT [pk_staging_Product_SourceProductID] PRIMARY KEY CLUSTERED ([SourceProductID] ASC)
);
GO

CREATE TABLE [staging].[SalesPerson] (
    [SourceBusinessEntityID] INT NOT NULL,
    [SourceTerritoryID] INT NULL,
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

    CONSTRAINT [pk_staging_SalesPerson_SourceBusinessEntityID] PRIMARY KEY CLUSTERED ([SourceBusinessEntityID] ASC)
);
GO

CREATE TABLE [staging].[Customer] (
    [SourceCustomerID] INT NOT NULL,
    [SourcePersonID] INT NULL,
    [SourceTerritoryID] INT NULL,
    [PersonType] CHAR(2) NULL,
    [Title] VARCHAR(8) NULL,
    [FirstName] VARCHAR(50) NULL,
    [MiddleName] VARCHAR(50) NULL,
    [LastName] VARCHAR(50) NULL,
    [AccountNumber] VARCHAR(20) NULL,

    CONSTRAINT [pk_staging_Customer_SourceCustomerID] PRIMARY KEY CLUSTERED ([SourceCustomerID] ASC)
);
GO

CREATE TABLE [staging].[SalesOrderHeader] (
    [SourceSalesOrderID] INT NOT NULL,
    [RevisionNumber] TINYINT NOT NULL,
    [OrderDate] DATETIME2(7) NOT NULL,
    [DueDate] DATETIME2(7) NOT NULL,
    [ShipDate] DATETIME2(7) NULL,
    [Status] TINYINT NOT NULL,
    [SalesOrderNumber] VARCHAR(25) NOT NULL,
    [PurchaseOrderNumber] VARCHAR(25) NULL,
    [AccountNumber] VARCHAR(20) NULL,
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

    CONSTRAINT [pk_staging_SalesOrderHeader_SourceSalesOrderID] PRIMARY KEY CLUSTERED ([SourceSalesOrderID] ASC)
);
GO

CREATE TABLE [staging].[SalesOrderDetail] (
    [SourceSalesOrderID] INT NOT NULL,
    [SourceSalesOrderDetailID] INT NOT NULL,
    [CarrierTrackingNumber] VARCHAR(25) NULL,
    [OrderQty] SMALLINT NOT NULL,
    [SourceProductID] INT NOT NULL,
    [SourceSpecialOfferID] INT NOT NULL,
    [UnitPrice] DECIMAL(19,4) NOT NULL,
    [UnitPriceDiscount] DECIMAL(19,4) NOT NULL,
    [LineTotal] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_staging_SalesOrderDetail_SourceOrderDetail] PRIMARY KEY CLUSTERED ([SourceSalesOrderID] ASC, [SourceSalesOrderDetailID] ASC)
);
GO
