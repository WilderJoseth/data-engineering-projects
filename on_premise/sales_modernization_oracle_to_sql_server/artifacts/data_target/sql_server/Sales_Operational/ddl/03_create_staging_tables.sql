/*
    Script name
        03_create_staging_tables.sql

    Purpose
        Creates raw staging tables for the Sales_Operational migration.

    Design rules
        - Staging tables receive extracted Oracle data before validation.
        - Table names use PascalCase under the lower-case staging schema.
        - Source identifiers are preserved for traceability and rerun support.
        - Source identifiers use unique constraints only when the Oracle source
          table guarantees uniqueness through a primary key.
        - Character columns use NVARCHAR/NCHAR to preserve source Unicode text
          before validation and target conversion.
        - Audit columns are intentionally excluded because staging data is
          temporary and controlled by ETL execution metadata.
*/

USE [Sales_Operational];
GO

CREATE TABLE [staging].[AddressType] (
    [StagingAddressTypeKey] INT IDENTITY(1,1) NOT NULL,
    [SourceAddressTypeID] INT NOT NULL,
    [Name] NVARCHAR(50) NOT NULL,

    CONSTRAINT [pk_staging_AddressType_StagingAddressTypeKey] PRIMARY KEY CLUSTERED ([StagingAddressTypeKey] ASC),
    CONSTRAINT [uk_staging_AddressType_SourceAddressTypeID] UNIQUE ([SourceAddressTypeID])
);
GO

CREATE TABLE [staging].[ProductCategory] (
    [StagingProductCategoryKey] INT IDENTITY(1,1) NOT NULL,
    [SourceProductSubcategoryID] INT NOT NULL,
    [Name] NVARCHAR(50) NOT NULL,

    CONSTRAINT [pk_staging_ProductCategory_StagingProductCategoryKey] PRIMARY KEY CLUSTERED ([StagingProductCategoryKey] ASC),
    CONSTRAINT [uk_staging_ProductCategory_SourceProductSubcategoryID] UNIQUE ([SourceProductSubcategoryID])
);
GO

CREATE TABLE [staging].[SpecialOffer] (
    [StagingSpecialOfferKey] INT IDENTITY(1,1) NOT NULL,
    [SourceSpecialOfferID] INT NOT NULL,
    [Description] NVARCHAR(255) NOT NULL,
    [DiscountPct] DECIMAL(10,4) NOT NULL,
    [OfferType] NVARCHAR(50) NOT NULL,
    [Category] NVARCHAR(50) NOT NULL,
    [StartDate] DATE NOT NULL,
    [EndDate] DATE NOT NULL,
    [MinQty] INT NOT NULL,
    [MaxQty] INT NULL,

    CONSTRAINT [pk_staging_SpecialOffer_StagingSpecialOfferKey] PRIMARY KEY CLUSTERED ([StagingSpecialOfferKey] ASC),
    CONSTRAINT [uk_staging_SpecialOffer_SourceSpecialOfferID] UNIQUE ([SourceSpecialOfferID])
);
GO

CREATE TABLE [staging].[ShipMethod] (
    [StagingShipMethodKey] INT IDENTITY(1,1) NOT NULL,
    [SourceShipMethodID] INT NOT NULL,
    [Name] NVARCHAR(50) NOT NULL,
    [ShipBase] DECIMAL(19,4) NOT NULL,
    [ShipRate] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_staging_ShipMethod_StagingShipMethodKey] PRIMARY KEY CLUSTERED ([StagingShipMethodKey] ASC),
    CONSTRAINT [uk_staging_ShipMethod_SourceShipMethodID] UNIQUE ([SourceShipMethodID])
);
GO

CREATE TABLE [staging].[CountryRegion] (
    [StagingCountryRegionKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCountryRegionCode] NVARCHAR(3) NOT NULL,
    [Name] NVARCHAR(50) NOT NULL,

    CONSTRAINT [pk_staging_CountryRegion_StagingCountryRegionKey] PRIMARY KEY CLUSTERED ([StagingCountryRegionKey] ASC),
    CONSTRAINT [uk_staging_CountryRegion_SourceCountryRegionCode] UNIQUE ([SourceCountryRegionCode])
);
GO

CREATE TABLE [staging].[SalesTerritory] (
    [StagingSalesTerritoryKey] INT IDENTITY(1,1) NOT NULL,
    [SourceTerritoryID] INT NOT NULL,
    [Name] NVARCHAR(50) NOT NULL,
    [TerritoryGroup] NVARCHAR(50) NOT NULL,
    [SourceCountryRegionCode] NVARCHAR(3) NOT NULL,

    CONSTRAINT [pk_staging_SalesTerritory_StagingSalesTerritoryKey] PRIMARY KEY CLUSTERED ([StagingSalesTerritoryKey] ASC),
    CONSTRAINT [uk_staging_SalesTerritory_SourceTerritoryID] UNIQUE ([SourceTerritoryID])
);
GO

CREATE TABLE [staging].[StateProvince] (
    [StagingStateProvinceKey] INT IDENTITY(1,1) NOT NULL,
    [SourceStateProvinceID] INT NOT NULL,
    [StateProvinceCode] NCHAR(3) NOT NULL,
    [Name] NVARCHAR(50) NOT NULL,
    [SourceCountryRegionCode] NVARCHAR(3) NOT NULL,
    [SourceTerritoryID] INT NOT NULL,

    CONSTRAINT [pk_staging_StateProvince_StagingStateProvinceKey] PRIMARY KEY CLUSTERED ([StagingStateProvinceKey] ASC),
    CONSTRAINT [uk_staging_StateProvince_SourceStateProvinceID] UNIQUE ([SourceStateProvinceID])
);
GO

CREATE TABLE [staging].[Currency] (
    [StagingCurrencyKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCurrencyCode] NCHAR(3) NOT NULL,
    [Name] NVARCHAR(50) NOT NULL,

    CONSTRAINT [pk_staging_Currency_StagingCurrencyKey] PRIMARY KEY CLUSTERED ([StagingCurrencyKey] ASC),
    CONSTRAINT [uk_staging_Currency_SourceCurrencyCode] UNIQUE ([SourceCurrencyCode])
);
GO

CREATE TABLE [staging].[CurrencyRate] (
    [StagingCurrencyRateKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCurrencyRateID] INT NOT NULL,
    [CurrencyRateDate] DATETIME2(7) NOT NULL,
    [FromCurrencyCode] NCHAR(3) NOT NULL,
    [ToCurrencyCode] NCHAR(3) NOT NULL,
    [AverageRate] DECIMAL(19,4) NOT NULL,
    [EndOfDayRate] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_staging_CurrencyRate_StagingCurrencyRateKey] PRIMARY KEY CLUSTERED ([StagingCurrencyRateKey] ASC),
    CONSTRAINT [uk_staging_CurrencyRate_SourceCurrencyRateID] UNIQUE ([SourceCurrencyRateID])
);
GO

CREATE TABLE [staging].[CreditCard] (
    [StagingCreditCardKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCreditCardID] INT NOT NULL,
    [CardType] NVARCHAR(50) NOT NULL,
    [CardNumber] NVARCHAR(25) NOT NULL,
    [ExpMonth] TINYINT NOT NULL,
    [ExpYear] SMALLINT NOT NULL,

    CONSTRAINT [pk_staging_CreditCard_StagingCreditCardKey] PRIMARY KEY CLUSTERED ([StagingCreditCardKey] ASC),
    CONSTRAINT [uk_staging_CreditCard_SourceCreditCardID] UNIQUE ([SourceCreditCardID])
);
GO

CREATE TABLE [staging].[Address] (
    [StagingAddressKey] INT IDENTITY(1,1) NOT NULL,
    [SourceAddressID] INT NOT NULL,
    [AddressLine1] NVARCHAR(60) NOT NULL,
    [AddressLine2] NVARCHAR(60) NULL,
    [City] NVARCHAR(30) NOT NULL,
    [SourceStateProvinceID] INT NOT NULL,
    [PostalCode] NVARCHAR(15) NOT NULL,
    [SourceAddressTypeID] INT NULL,

    CONSTRAINT [pk_staging_Address_StagingAddressKey] PRIMARY KEY CLUSTERED ([StagingAddressKey] ASC),
    CONSTRAINT [uk_staging_Address_SourceAddressID] UNIQUE ([SourceAddressID])
);
GO

CREATE TABLE [staging].[Product] (
    [StagingProductKey] INT IDENTITY(1,1) NOT NULL,
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

    CONSTRAINT [pk_staging_Product_StagingProductKey] PRIMARY KEY CLUSTERED ([StagingProductKey] ASC),
    CONSTRAINT [uk_staging_Product_SourceProductID] UNIQUE ([SourceProductID])
);
GO

CREATE TABLE [staging].[Person] (
    [StagingPersonKey] INT IDENTITY(1,1) NOT NULL,
    [SourceBusinessEntityID] INT NOT NULL,
    [PersonType] NCHAR(2) NOT NULL,
    [Title] NVARCHAR(8) NULL,
    [FirstName] NVARCHAR(50) NOT NULL,
    [MiddleName] NVARCHAR(50) NULL,
    [LastName] NVARCHAR(50) NOT NULL,

    CONSTRAINT [pk_staging_Person_StagingPersonKey] PRIMARY KEY CLUSTERED ([StagingPersonKey] ASC),
    CONSTRAINT [uk_staging_Person_SourceBusinessEntityID] UNIQUE ([SourceBusinessEntityID])
);
GO

CREATE TABLE [staging].[Employee] (
    [StagingEmployeeKey] INT IDENTITY(1,1) NOT NULL,
    [SourceBusinessEntityID] INT NOT NULL,
    [JobTitle] NVARCHAR(50) NOT NULL,
    [Gender] NCHAR(1) NOT NULL,
    [HireDate] DATE NOT NULL,

    CONSTRAINT [pk_staging_Employee_StagingEmployeeKey] PRIMARY KEY CLUSTERED ([StagingEmployeeKey] ASC),
    CONSTRAINT [uk_staging_Employee_SourceBusinessEntityID] UNIQUE ([SourceBusinessEntityID])
);
GO

CREATE TABLE [staging].[SalesPerson] (
    [StagingSalesPersonKey] INT IDENTITY(1,1) NOT NULL,
    [SourceBusinessEntityID] INT NOT NULL,
    [SourceTerritoryID] INT NULL,
    [SalesQuota] DECIMAL(19,4) NULL,
    [Bonus] DECIMAL(19,4) NOT NULL,
    [CommissionPct] DECIMAL(10,4) NOT NULL,
    [SalesYTD] DECIMAL(19,4) NOT NULL,
    [SalesLastYear] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_staging_SalesPerson_StagingSalesPersonKey] PRIMARY KEY CLUSTERED ([StagingSalesPersonKey] ASC),
    CONSTRAINT [uk_staging_SalesPerson_SourceBusinessEntityID] UNIQUE ([SourceBusinessEntityID])
);
GO

CREATE TABLE [staging].[Customer] (
    [StagingCustomerKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCustomerID] INT NOT NULL,
    [SourcePersonID] INT NULL,
    [SourceStoreID] INT NULL,
    [SourceTerritoryID] INT NULL,
    [AccountNumber] NVARCHAR(20) NULL,

    CONSTRAINT [pk_staging_Customer_StagingCustomerKey] PRIMARY KEY CLUSTERED ([StagingCustomerKey] ASC),
    CONSTRAINT [uk_staging_Customer_SourceCustomerID] UNIQUE ([SourceCustomerID])
);
GO

CREATE TABLE [staging].[SalesOrderHeader] (
    [StagingSalesOrderHeaderKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceSalesOrderID] BIGINT NOT NULL,
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

    CONSTRAINT [pk_staging_SalesOrderHeader_StagingSalesOrderHeaderKey] PRIMARY KEY CLUSTERED ([StagingSalesOrderHeaderKey] ASC),
    CONSTRAINT [uk_staging_SalesOrderHeader_SourceSalesOrderID] UNIQUE ([SourceSalesOrderID])
);
GO

CREATE TABLE [staging].[SalesOrderDetail] (
    [StagingSalesOrderDetailKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceSalesOrderID] BIGINT NOT NULL,
    [SourceSalesOrderDetailID] BIGINT NOT NULL,
    [CarrierTrackingNumber] NVARCHAR(25) NULL,
    [OrderQty] SMALLINT NOT NULL,
    [SourceProductID] INT NOT NULL,
    [SourceSpecialOfferID] INT NOT NULL,
    [UnitPrice] DECIMAL(19,4) NOT NULL,
    [UnitPriceDiscount] DECIMAL(19,4) NOT NULL,
    [LineTotal] DECIMAL(19,4) NOT NULL,

    CONSTRAINT [pk_staging_SalesOrderDetail_StagingSalesOrderDetailKey] PRIMARY KEY CLUSTERED ([StagingSalesOrderDetailKey] ASC),
    CONSTRAINT [uk_staging_SalesOrderDetail_SourceOrderDetail] UNIQUE ([SourceSalesOrderID], [SourceSalesOrderDetailID])
);
GO
