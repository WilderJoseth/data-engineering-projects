/*
    Script name
        03_create_prod_tables.sql

    Purpose
        Creates the final normalized operational tables for the Sales-domain migration target.

    Scope
        Prod tables include business keys, selected business attributes, and audit columns required by the solution design.
*/

USE [Sales_Operational];
GO

CREATE TABLE [prod].[AddressType] (
    [AddressTypeKey] INT IDENTITY(1,1) NOT NULL,
    [SourceAddressTypeID] INT NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_prod_AddressType_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_prod_AddressType_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_execution_step_id] INT NOT NULL,
    [last_updated_execution_step_id] INT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_prod_AddressType_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_prod_AddressType] PRIMARY KEY CLUSTERED ([AddressTypeKey] ASC),
    CONSTRAINT [uk_prod_AddressType_SourceAddressTypeID] UNIQUE ([SourceAddressTypeID])
);
GO

CREATE TABLE [prod].[ProductCategory] (
    [ProductCategoryKey] INT IDENTITY(1,1) NOT NULL,
    [SourceProductCategoryID] INT NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_prod_ProductCategory_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_prod_ProductCategory_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_execution_step_id] INT NOT NULL,
    [last_updated_execution_step_id] INT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_prod_ProductCategory_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_prod_ProductCategory] PRIMARY KEY CLUSTERED ([ProductCategoryKey] ASC),
    CONSTRAINT [uk_prod_ProductCategory_SourceProductCategoryID] UNIQUE ([SourceProductCategoryID])
);
GO

CREATE TABLE [prod].[ShipMethod] (
    [ShipMethodKey] INT IDENTITY(1,1) NOT NULL,
    [SourceShipMethodID] INT NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [ShipBase] DECIMAL(19,4) NOT NULL,
    [ShipRate] DECIMAL(19,4) NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_prod_ShipMethod_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_prod_ShipMethod_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_execution_step_id] INT NOT NULL,
    [last_updated_execution_step_id] INT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_prod_ShipMethod_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_prod_ShipMethod] PRIMARY KEY CLUSTERED ([ShipMethodKey] ASC),
    CONSTRAINT [uk_prod_ShipMethod_SourceShipMethodID] UNIQUE ([SourceShipMethodID])
);
GO

CREATE TABLE [prod].[CountryRegion] (
    [CountryRegionKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCountryRegionCode] VARCHAR(3) NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_prod_CountryRegion_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_prod_CountryRegion_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_execution_step_id] INT NOT NULL,
    [last_updated_execution_step_id] INT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_prod_CountryRegion_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_prod_CountryRegion] PRIMARY KEY CLUSTERED ([CountryRegionKey] ASC),
    CONSTRAINT [uk_prod_CountryRegion_SourceCountryRegionCode] UNIQUE ([SourceCountryRegionCode])
);
GO

CREATE TABLE [prod].[SalesTerritory] (
    [SalesTerritoryKey] INT IDENTITY(1,1) NOT NULL,
    [SourceTerritoryID] INT NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [TerritoryGroup] VARCHAR(50) NOT NULL,
    [CountryRegionKey] INT NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_prod_SalesTerritory_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_prod_SalesTerritory_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_execution_step_id] INT NOT NULL,
    [last_updated_execution_step_id] INT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_prod_SalesTerritory_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_prod_SalesTerritory] PRIMARY KEY CLUSTERED ([SalesTerritoryKey] ASC),
    CONSTRAINT [uk_prod_SalesTerritory_SourceTerritoryID] UNIQUE ([SourceTerritoryID]),
    CONSTRAINT [fk_prod_SalesTerritory_CountryRegionKey] FOREIGN KEY ([CountryRegionKey]) REFERENCES [prod].[CountryRegion]([CountryRegionKey])
);
GO

CREATE TABLE [prod].[StateProvince] (
    [StateProvinceKey] INT IDENTITY(1,1) NOT NULL,
    [SourceStateProvinceID] INT NOT NULL,
    [StateProvinceCode] CHAR(3) NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [CountryRegionKey] INT NOT NULL,
    [SalesTerritoryKey] INT NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_prod_StateProvince_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_prod_StateProvince_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_execution_step_id] INT NOT NULL,
    [last_updated_execution_step_id] INT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_prod_StateProvince_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_prod_StateProvince] PRIMARY KEY CLUSTERED ([StateProvinceKey] ASC),
    CONSTRAINT [uk_prod_StateProvince_SourceStateProvinceID] UNIQUE ([SourceStateProvinceID]),
    CONSTRAINT [fk_prod_StateProvince_CountryRegionKey] FOREIGN KEY ([CountryRegionKey]) REFERENCES [prod].[CountryRegion]([CountryRegionKey]),
    CONSTRAINT [fk_prod_StateProvince_SalesTerritoryKey] FOREIGN KEY ([SalesTerritoryKey]) REFERENCES [prod].[SalesTerritory]([SalesTerritoryKey])
);
GO

CREATE TABLE [prod].[SpecialOffer] (
    [SpecialOfferKey] INT IDENTITY(1,1) NOT NULL,
    [SourceSpecialOfferID] INT NOT NULL,
    [Description] VARCHAR(255) NOT NULL,
    [DiscountPct] DECIMAL(10,4) NOT NULL,
    [OfferType] VARCHAR(50) NOT NULL,
    [Category] VARCHAR(50) NOT NULL,
    [StartDate] DATE NOT NULL,
    [EndDate] DATE NOT NULL,
    [MinQty] INT NOT NULL,
    [MaxQty] INT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_prod_SpecialOffer_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_prod_SpecialOffer_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_execution_step_id] INT NOT NULL,
    [last_updated_execution_step_id] INT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_prod_SpecialOffer_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_prod_SpecialOffer] PRIMARY KEY CLUSTERED ([SpecialOfferKey] ASC),
    CONSTRAINT [uk_prod_SpecialOffer_SourceSpecialOfferID] UNIQUE ([SourceSpecialOfferID])
);
GO

CREATE TABLE [prod].[Currency] (
    [CurrencyKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCurrencyCode] CHAR(3) NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_prod_Currency_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_prod_Currency_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_execution_step_id] INT NOT NULL,
    [last_updated_execution_step_id] INT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_prod_Currency_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_prod_Currency] PRIMARY KEY CLUSTERED ([CurrencyKey] ASC),
    CONSTRAINT [uk_prod_Currency_SourceCurrencyCode] UNIQUE ([SourceCurrencyCode])
);
GO

CREATE TABLE [prod].[CurrencyRate] (
    [CurrencyRateKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCurrencyRateID] INT NOT NULL,
    [CurrencyRateDate] DATETIME2 NOT NULL,
    [FromCurrencyKey] INT NOT NULL,
    [ToCurrencyKey] INT NOT NULL,
    [AverageRate] DECIMAL(19,4) NOT NULL,
    [EndOfDayRate] DECIMAL(19,4) NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_prod_CurrencyRate_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_prod_CurrencyRate_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_execution_step_id] INT NOT NULL,
    [last_updated_execution_step_id] INT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_prod_CurrencyRate_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_prod_CurrencyRate] PRIMARY KEY CLUSTERED ([CurrencyRateKey] ASC),
    CONSTRAINT [uk_prod_CurrencyRate_SourceCurrencyRateID] UNIQUE ([SourceCurrencyRateID]),
    CONSTRAINT [fk_prod_CurrencyRate_FromCurrencyKey] FOREIGN KEY ([FromCurrencyKey]) REFERENCES [prod].[Currency]([CurrencyKey]),
    CONSTRAINT [fk_prod_CurrencyRate_ToCurrencyKey] FOREIGN KEY ([ToCurrencyKey]) REFERENCES [prod].[Currency]([CurrencyKey])
);
GO

CREATE TABLE [prod].[CreditCard] (
    [CreditCardKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCreditCardID] INT NOT NULL,
    [CardType] VARCHAR(50) NOT NULL,
    [CardNumber] VARCHAR(25) NOT NULL,
    [ExpMonth] TINYINT NOT NULL,
    [ExpYear] SMALLINT NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_prod_CreditCard_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_prod_CreditCard_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_execution_step_id] INT NOT NULL,
    [last_updated_execution_step_id] INT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_prod_CreditCard_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_prod_CreditCard] PRIMARY KEY CLUSTERED ([CreditCardKey] ASC),
    CONSTRAINT [uk_prod_CreditCard_SourceCreditCardID] UNIQUE ([SourceCreditCardID])
);
GO

CREATE TABLE [prod].[Address] (
    [AddressKey] INT IDENTITY(1,1) NOT NULL,
    [SourceAddressID] INT NOT NULL,
    [AddressLine1] VARCHAR(60) NOT NULL,
    [AddressLine2] VARCHAR(60) NULL,
    [City] VARCHAR(30) NOT NULL,
    [StateProvinceKey] INT NOT NULL,
    [PostalCode] VARCHAR(15) NOT NULL,
    [AddressTypeKey] INT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_prod_Address_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_prod_Address_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_execution_step_id] INT NOT NULL,
    [last_updated_execution_step_id] INT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_prod_Address_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_prod_Address] PRIMARY KEY CLUSTERED ([AddressKey] ASC),
    CONSTRAINT [uk_prod_Address_SourceAddressID] UNIQUE ([SourceAddressID]),
    CONSTRAINT [fk_prod_Address_StateProvinceKey] FOREIGN KEY ([StateProvinceKey]) REFERENCES [prod].[StateProvince]([StateProvinceKey]),
    CONSTRAINT [fk_prod_Address_AddressTypeKey] FOREIGN KEY ([AddressTypeKey]) REFERENCES [prod].[AddressType]([AddressTypeKey])
);
GO

CREATE TABLE [prod].[Product] (
    [ProductKey] INT IDENTITY(1,1) NOT NULL,
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
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_prod_Product_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_prod_Product_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_execution_step_id] INT NOT NULL,
    [last_updated_execution_step_id] INT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_prod_Product_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_prod_Product] PRIMARY KEY CLUSTERED ([ProductKey] ASC),
    CONSTRAINT [uk_prod_Product_SourceProductID] UNIQUE ([SourceProductID]),
    CONSTRAINT [fk_prod_Product_ProductCategoryKey] FOREIGN KEY ([ProductCategoryKey]) REFERENCES [prod].[ProductCategory]([ProductCategoryKey])
);
GO

CREATE TABLE [prod].[SalesPerson] (
    [SalesPersonKey] INT IDENTITY(1,1) NOT NULL,
    [SourceSalesPersonID] INT NOT NULL,
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
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_prod_SalesPerson_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_prod_SalesPerson_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_execution_step_id] INT NOT NULL,
    [last_updated_execution_step_id] INT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_prod_SalesPerson_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_prod_SalesPerson] PRIMARY KEY CLUSTERED ([SalesPersonKey] ASC),
    CONSTRAINT [uk_prod_SalesPerson_SourceSalesPersonID] UNIQUE ([SourceSalesPersonID]),
    CONSTRAINT [fk_prod_SalesPerson_SalesTerritoryKey] FOREIGN KEY ([SalesTerritoryKey]) REFERENCES [prod].[SalesTerritory]([SalesTerritoryKey])
);
GO

CREATE TABLE [prod].[Customer] (
    [CustomerKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCustomerID] INT NOT NULL,
    [SalesTerritoryKey] INT NULL,
    [PersonType] CHAR(2) NULL,
    [Title] VARCHAR(8) NULL,
    [FirstName] VARCHAR(50) NULL,
    [MiddleName] VARCHAR(50) NULL,
    [LastName] VARCHAR(50) NULL,
    [AccountNumber] VARCHAR(20) NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_prod_Customer_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_prod_Customer_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_execution_step_id] INT NOT NULL,
    [last_updated_execution_step_id] INT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_prod_Customer_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_prod_Customer] PRIMARY KEY CLUSTERED ([CustomerKey] ASC),
    CONSTRAINT [uk_prod_Customer_SourceCustomerID] UNIQUE ([SourceCustomerID]),
    CONSTRAINT [fk_prod_Customer_SalesTerritoryKey] FOREIGN KEY ([SalesTerritoryKey]) REFERENCES [prod].[SalesTerritory]([SalesTerritoryKey])
);
GO

CREATE TABLE [prod].[SalesOrderHeader] (
    [SalesOrderHeaderKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceSalesOrderID] BIGINT NOT NULL,
    [RevisionNumber] TINYINT NOT NULL,
    [OrderDate] DATETIME2 NOT NULL,
    [DueDate] DATETIME2 NOT NULL,
    [ShipDate] DATETIME2 NULL,
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
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_prod_SalesOrderHeader_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_prod_SalesOrderHeader_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_execution_step_id] INT NOT NULL,
    [last_updated_execution_step_id] INT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_prod_SalesOrderHeader_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_prod_SalesOrderHeader] PRIMARY KEY CLUSTERED ([SalesOrderHeaderKey] ASC),
    CONSTRAINT [uk_prod_SalesOrderHeader_SourceSalesOrderID] UNIQUE ([SourceSalesOrderID]),
    CONSTRAINT [fk_prod_SalesOrderHeader_CustomerKey] FOREIGN KEY ([CustomerKey]) REFERENCES [prod].[Customer]([CustomerKey]),
    CONSTRAINT [fk_prod_SalesOrderHeader_SalesPersonKey] FOREIGN KEY ([SalesPersonKey]) REFERENCES [prod].[SalesPerson]([SalesPersonKey]),
    CONSTRAINT [fk_prod_SalesOrderHeader_SalesTerritoryKey] FOREIGN KEY ([SalesTerritoryKey]) REFERENCES [prod].[SalesTerritory]([SalesTerritoryKey]),
    CONSTRAINT [fk_prod_SalesOrderHeader_BillToAddressKey] FOREIGN KEY ([BillToAddressKey]) REFERENCES [prod].[Address]([AddressKey]),
    CONSTRAINT [fk_prod_SalesOrderHeader_ShipToAddressKey] FOREIGN KEY ([ShipToAddressKey]) REFERENCES [prod].[Address]([AddressKey]),
    CONSTRAINT [fk_prod_SalesOrderHeader_ShipMethodKey] FOREIGN KEY ([ShipMethodKey]) REFERENCES [prod].[ShipMethod]([ShipMethodKey]),
    CONSTRAINT [fk_prod_SalesOrderHeader_CreditCardKey] FOREIGN KEY ([CreditCardKey]) REFERENCES [prod].[CreditCard]([CreditCardKey]),
    CONSTRAINT [fk_prod_SalesOrderHeader_CurrencyRateKey] FOREIGN KEY ([CurrencyRateKey]) REFERENCES [prod].[CurrencyRate]([CurrencyRateKey])
);
GO

CREATE TABLE [prod].[SalesOrderDetail] (
    [SalesOrderDetailKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SalesOrderHeaderKey] BIGINT NOT NULL,
    [SourceSalesOrderID] BIGINT NOT NULL,
    [SourceSalesOrderDetailID] BIGINT NOT NULL,
    [ProductKey] INT NOT NULL,
    [SpecialOfferKey] INT NOT NULL,
    [CarrierTrackingNumber] VARCHAR(25) NULL,
    [OrderQty] SMALLINT NOT NULL,
    [UnitPrice] DECIMAL(19,4) NOT NULL,
    [UnitPriceDiscount] DECIMAL(19,4) NOT NULL,
    [LineTotal] DECIMAL(19,4) NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_prod_SalesOrderDetail_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_prod_SalesOrderDetail_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_execution_step_id] INT NOT NULL,
    [last_updated_execution_step_id] INT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_prod_SalesOrderDetail_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_prod_SalesOrderDetail] PRIMARY KEY CLUSTERED ([SalesOrderDetailKey] ASC),
    CONSTRAINT [fk_prod_SalesOrderDetail_SalesOrderHeaderKey] FOREIGN KEY ([SalesOrderHeaderKey]) REFERENCES [prod].[SalesOrderHeader]([SalesOrderHeaderKey]),
    CONSTRAINT [fk_prod_SalesOrderDetail_ProductKey] FOREIGN KEY ([ProductKey]) REFERENCES [prod].[Product]([ProductKey]),
    CONSTRAINT [fk_prod_SalesOrderDetail_SpecialOfferKey] FOREIGN KEY ([SpecialOfferKey]) REFERENCES [prod].[SpecialOffer]([SpecialOfferKey])
);
GO
