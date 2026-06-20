/*
    Script name
        05_create_work_tables.sql

    Purpose
        Creates transformed work tables for the Sales_Operational migration.

    Scope
        Work tables store cleaned rows and validation indicator columns used before loading prod tables.
*/

USE [Sales_Operational];
GO

CREATE TABLE [work].[AddressType] (
    [WorkAddressTypeKey] INT IDENTITY(1,1) NOT NULL,
    [SourceAddressTypeID] INT NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [IsNameNotBlank] BIT NOT NULL CONSTRAINT [df_work_AddressType_IsNameNotBlank] DEFAULT ((0)),

    CONSTRAINT [pk_work_AddressType_WorkAddressTypeKey] PRIMARY KEY CLUSTERED ([WorkAddressTypeKey] ASC)
);
GO

CREATE TABLE [work].[ProductCategory] (
    [WorkProductCategoryKey] INT IDENTITY(1,1) NOT NULL,
    [SourceProductCategoryID] INT NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [IsNameNotBlank] BIT NOT NULL CONSTRAINT [df_work_ProductCategory_IsNameNotBlank] DEFAULT ((0)),

    CONSTRAINT [pk_work_ProductCategory_WorkProductCategoryKey] PRIMARY KEY CLUSTERED ([WorkProductCategoryKey] ASC)
);
GO

CREATE TABLE [work].[SpecialOffer] (
    [WorkSpecialOfferKey] INT IDENTITY(1,1) NOT NULL,
    [SourceSpecialOfferID] INT NOT NULL,
    [Description] VARCHAR(255) NOT NULL,
    [DiscountPct] DECIMAL(10,4) NOT NULL,
    [OfferType] VARCHAR(50) NOT NULL,
    [Category] VARCHAR(50) NOT NULL,
    [StartDate] DATE NOT NULL,
    [EndDate] DATE NOT NULL,
    [MinQty] INT NOT NULL,
    [MaxQty] INT NULL,
    [IsDescriptionNotBlank] BIT NOT NULL CONSTRAINT [df_work_SpecialOffer_IsDescriptionNotBlank] DEFAULT ((0)),
    [IsOfferTypeNotBlank] BIT NOT NULL CONSTRAINT [df_work_SpecialOffer_IsOfferTypeNotBlank] DEFAULT ((0)),
    [IsCategoryNotBlank] BIT NOT NULL CONSTRAINT [df_work_SpecialOffer_IsCategoryNotBlank] DEFAULT ((0)),

    CONSTRAINT [pk_work_SpecialOffer_WorkSpecialOfferKey] PRIMARY KEY CLUSTERED ([WorkSpecialOfferKey] ASC)
);
GO

CREATE TABLE [work].[ShipMethod] (
    [WorkShipMethodKey] INT IDENTITY(1,1) NOT NULL,
    [SourceShipMethodID] INT NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [ShipBase] DECIMAL(19,4) NOT NULL,
    [ShipRate] DECIMAL(19,4) NOT NULL,
    [IsNameNotBlank] BIT NOT NULL CONSTRAINT [df_work_ShipMethod_IsNameNotBlank] DEFAULT ((0)),

    CONSTRAINT [pk_work_ShipMethod_WorkShipMethodKey] PRIMARY KEY CLUSTERED ([WorkShipMethodKey] ASC)
);
GO

CREATE TABLE [work].[CountryRegion] (
    [WorkCountryRegionKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCountryRegionCode] VARCHAR(3) NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [IsCountryRegionCodeNotBlank] BIT NOT NULL CONSTRAINT [df_work_CountryRegion_IsCountryRegionCodeNotBlank] DEFAULT ((0)),
    [IsNameNotBlank] BIT NOT NULL CONSTRAINT [df_work_CountryRegion_IsNameNotBlank] DEFAULT ((0)),

    CONSTRAINT [pk_work_CountryRegion_WorkCountryRegionKey] PRIMARY KEY CLUSTERED ([WorkCountryRegionKey] ASC)
);
GO

CREATE TABLE [work].[SalesTerritory] (
    [WorkSalesTerritoryKey] INT IDENTITY(1,1) NOT NULL,
    [SourceTerritoryID] INT NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [TerritoryGroup] VARCHAR(50) NOT NULL,
    [SourceCountryRegionCode] VARCHAR(3) NOT NULL,
    [IsNameNotBlank] BIT NOT NULL CONSTRAINT [df_work_SalesTerritory_IsNameNotBlank] DEFAULT ((0)),
    [IsTerritoryGroupNotBlank] BIT NOT NULL CONSTRAINT [df_work_SalesTerritory_IsTerritoryGroupNotBlank] DEFAULT ((0)),
    [IsCountryRegionValid] BIT NOT NULL CONSTRAINT [df_work_SalesTerritory_IsCountryRegionValid] DEFAULT ((0)),

    CONSTRAINT [pk_work_SalesTerritory_WorkSalesTerritoryKey] PRIMARY KEY CLUSTERED ([WorkSalesTerritoryKey] ASC)
);
GO

CREATE TABLE [work].[StateProvince] (
    [WorkStateProvinceKey] INT IDENTITY(1,1) NOT NULL,
    [SourceStateProvinceID] INT NOT NULL,
    [StateProvinceCode] CHAR(3) NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [SourceCountryRegionCode] VARCHAR(3) NOT NULL,
    [SourceTerritoryID] INT NOT NULL,
    [IsStateProvinceCodeNotBlank] BIT NOT NULL CONSTRAINT [df_work_StateProvince_IsStateProvinceCodeNotBlank] DEFAULT ((0)),
    [IsNameNotBlank] BIT NOT NULL CONSTRAINT [df_work_StateProvince_IsNameNotBlank] DEFAULT ((0)),
    [IsCountryRegionValid] BIT NOT NULL CONSTRAINT [df_work_StateProvince_IsCountryRegionValid] DEFAULT ((0)),
    [IsSalesTerritoryValid] BIT NOT NULL CONSTRAINT [df_work_StateProvince_IsSalesTerritoryValid] DEFAULT ((0)),

    CONSTRAINT [pk_work_StateProvince_WorkStateProvinceKey] PRIMARY KEY CLUSTERED ([WorkStateProvinceKey] ASC)
);
GO

CREATE TABLE [work].[Currency] (
    [WorkCurrencyKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCurrencyCode] CHAR(3) NOT NULL,
    [Name] VARCHAR(50) NOT NULL,
    [IsCurrencyCodeNotBlank] BIT NOT NULL CONSTRAINT [df_work_Currency_IsCurrencyCodeNotBlank] DEFAULT ((0)),
    [IsNameNotBlank] BIT NOT NULL CONSTRAINT [df_work_Currency_IsNameNotBlank] DEFAULT ((0)),

    CONSTRAINT [pk_work_Currency_WorkCurrencyKey] PRIMARY KEY CLUSTERED ([WorkCurrencyKey] ASC)
);
GO

CREATE TABLE [work].[CurrencyRate] (
    [WorkCurrencyRateKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCurrencyRateID] INT NOT NULL,
    [CurrencyRateDate] DATETIME2(7) NOT NULL,
    [FromCurrencyCode] CHAR(3) NOT NULL,
    [ToCurrencyCode] CHAR(3) NOT NULL,
    [AverageRate] DECIMAL(19,4) NOT NULL,
    [EndOfDayRate] DECIMAL(19,4) NOT NULL,
    [IsFromCurrencyValid] BIT NOT NULL CONSTRAINT [df_work_CurrencyRate_IsFromCurrencyValid] DEFAULT ((0)),
    [IsToCurrencyValid] BIT NOT NULL CONSTRAINT [df_work_CurrencyRate_IsToCurrencyValid] DEFAULT ((0)),

    CONSTRAINT [pk_work_CurrencyRate_WorkCurrencyRateKey] PRIMARY KEY CLUSTERED ([WorkCurrencyRateKey] ASC)
);
GO

CREATE TABLE [work].[CreditCard] (
    [WorkCreditCardKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCreditCardID] INT NOT NULL,
    [CardType] VARCHAR(50) NOT NULL,
    [CardNumber] VARCHAR(25) NOT NULL,
    [ExpMonth] TINYINT NOT NULL,
    [ExpYear] SMALLINT NOT NULL,
    [IsCardTypeNotBlank] BIT NOT NULL CONSTRAINT [df_work_CreditCard_IsCardTypeNotBlank] DEFAULT ((0)),
    [IsCardNumberUsable] BIT NOT NULL CONSTRAINT [df_work_CreditCard_IsCardNumberUsable] DEFAULT ((0)),

    CONSTRAINT [pk_work_CreditCard_WorkCreditCardKey] PRIMARY KEY CLUSTERED ([WorkCreditCardKey] ASC)
);
GO

CREATE TABLE [work].[Address] (
    [WorkAddressKey] INT IDENTITY(1,1) NOT NULL,
    [SourceAddressID] INT NOT NULL,
    [AddressLine1] VARCHAR(60) NOT NULL,
    [AddressLine2] VARCHAR(60) NULL,
    [City] VARCHAR(30) NOT NULL,
    [SourceStateProvinceID] INT NOT NULL,
    [PostalCode] VARCHAR(15) NOT NULL,
    [SourceAddressTypeID] INT NULL,
    [IsAddressLine1NotBlank] BIT NOT NULL CONSTRAINT [df_work_Address_IsAddressLine1NotBlank] DEFAULT ((0)),
    [IsCityNotBlank] BIT NOT NULL CONSTRAINT [df_work_Address_IsCityNotBlank] DEFAULT ((0)),
    [IsPostalCodeNotBlank] BIT NOT NULL CONSTRAINT [df_work_Address_IsPostalCodeNotBlank] DEFAULT ((0)),
    [IsStateProvinceValid] BIT NOT NULL CONSTRAINT [df_work_Address_IsStateProvinceValid] DEFAULT ((0)),
    [IsAddressTypeValid] BIT NOT NULL CONSTRAINT [df_work_Address_IsAddressTypeValid] DEFAULT ((0)),

    CONSTRAINT [pk_work_Address_WorkAddressKey] PRIMARY KEY CLUSTERED ([WorkAddressKey] ASC)
);
GO

CREATE TABLE [work].[Product] (
    [WorkProductKey] INT IDENTITY(1,1) NOT NULL,
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
    [SourceProductCategoryID] INT NULL,
    [SellStartDate] DATE NOT NULL,
    [SellEndDate] DATE NULL,
    [DiscontinuedDate] DATE NULL,
    [IsProductNumberNotBlank] BIT NOT NULL CONSTRAINT [df_work_Product_IsProductNumberNotBlank] DEFAULT ((0)),
    [IsNameNotBlank] BIT NOT NULL CONSTRAINT [df_work_Product_IsNameNotBlank] DEFAULT ((0)),
    [IsProductCategoryValid] BIT NOT NULL CONSTRAINT [df_work_Product_IsProductCategoryValid] DEFAULT ((0)),

    CONSTRAINT [pk_work_Product_WorkProductKey] PRIMARY KEY CLUSTERED ([WorkProductKey] ASC)
);
GO

CREATE TABLE [work].[SalesPerson] (
    [WorkSalesPersonKey] INT IDENTITY(1,1) NOT NULL,
    [SourceSalesPersonID] INT NOT NULL,
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
    [IsFirstNameNotBlank] BIT NOT NULL CONSTRAINT [df_work_SalesPerson_IsFirstNameNotBlank] DEFAULT ((0)),
    [IsLastNameNotBlank] BIT NOT NULL CONSTRAINT [df_work_SalesPerson_IsLastNameNotBlank] DEFAULT ((0)),
    [IsJobTitleNotBlank] BIT NOT NULL CONSTRAINT [df_work_SalesPerson_IsJobTitleNotBlank] DEFAULT ((0)),
    [IsGenderNotBlank] BIT NOT NULL CONSTRAINT [df_work_SalesPerson_IsGenderNotBlank] DEFAULT ((0)),
    [IsSalesTerritoryValid] BIT NOT NULL CONSTRAINT [df_work_SalesPerson_IsSalesTerritoryValid] DEFAULT ((0)),

    CONSTRAINT [pk_work_SalesPerson_WorkSalesPersonKey] PRIMARY KEY CLUSTERED ([WorkSalesPersonKey] ASC)
);
GO

CREATE TABLE [work].[Customer] (
    [WorkCustomerKey] INT IDENTITY(1,1) NOT NULL,
    [SourceCustomerID] INT NOT NULL,
    [SourceTerritoryID] INT NULL,
    [PersonType] CHAR(2) NULL,
    [Title] VARCHAR(8) NULL,
    [FirstName] VARCHAR(50) NULL,
    [MiddleName] VARCHAR(50) NULL,
    [LastName] VARCHAR(50) NULL,
    [AccountNumber] VARCHAR(20) NULL,
    [IsPersonNameValid] BIT NOT NULL CONSTRAINT [df_work_Customer_IsPersonNameValid] DEFAULT ((0)),
    [IsSalesTerritoryValid] BIT NOT NULL CONSTRAINT [df_work_Customer_IsSalesTerritoryValid] DEFAULT ((0)),

    CONSTRAINT [pk_work_Customer_WorkCustomerKey] PRIMARY KEY CLUSTERED ([WorkCustomerKey] ASC)
);
GO

CREATE TABLE [work].[SalesOrderHeader] (
    [WorkSalesOrderHeaderKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceSalesOrderID] BIGINT NOT NULL,
    [RevisionNumber] TINYINT NOT NULL,
    [OrderDate] DATETIME2(7) NOT NULL,
    [DueDate] DATETIME2(7) NOT NULL,
    [ShipDate] DATETIME2(7) NULL,
    [Status] TINYINT NOT NULL,
    [SalesOrderNumber] VARCHAR(25) NOT NULL,
    [PurchaseOrderNumber] VARCHAR(25) NULL,
    [AccountNumber] VARCHAR(20) NULL,
    [CustomerKey] INT NULL,
    [SalesPersonKey] INT NULL,
    [SalesTerritoryKey] INT NULL,
    [BillToAddressKey] INT NULL,
    [ShipToAddressKey] INT NULL,
    [ShipMethodKey] INT NULL,
    [CreditCardKey] INT NULL,
    [CurrencyRateKey] INT NULL,
    [SubTotal] DECIMAL(19,4) NOT NULL,
    [TaxAmt] DECIMAL(19,4) NOT NULL,
    [Freight] DECIMAL(19,4) NOT NULL,
    [TotalDue] DECIMAL(19,4) NOT NULL,
    [Comment] NVARCHAR(128) NULL,
    [IsSalesOrderNumberNotBlank] BIT NOT NULL CONSTRAINT [df_work_SalesOrderHeader_IsSalesOrderNumberNotBlank] DEFAULT ((0)),
    [IsCustomerValid] BIT NOT NULL CONSTRAINT [df_work_SalesOrderHeader_IsCustomerValid] DEFAULT ((0)),
    [IsSalesPersonValid] BIT NOT NULL CONSTRAINT [df_work_SalesOrderHeader_IsSalesPersonValid] DEFAULT ((0)),
    [IsSalesTerritoryValid] BIT NOT NULL CONSTRAINT [df_work_SalesOrderHeader_IsSalesTerritoryValid] DEFAULT ((0)),
    [IsBillToAddressValid] BIT NOT NULL CONSTRAINT [df_work_SalesOrderHeader_IsBillToAddressValid] DEFAULT ((0)),
    [IsShipToAddressValid] BIT NOT NULL CONSTRAINT [df_work_SalesOrderHeader_IsShipToAddressValid] DEFAULT ((0)),
    [IsShipMethodValid] BIT NOT NULL CONSTRAINT [df_work_SalesOrderHeader_IsShipMethodValid] DEFAULT ((0)),
    [IsCreditCardValid] BIT NOT NULL CONSTRAINT [df_work_SalesOrderHeader_IsCreditCardValid] DEFAULT ((0)),
    [IsCurrencyRateValid] BIT NOT NULL CONSTRAINT [df_work_SalesOrderHeader_IsCurrencyRateValid] DEFAULT ((0)),

    CONSTRAINT [pk_work_SalesOrderHeader_WorkSalesOrderHeaderKey] PRIMARY KEY CLUSTERED ([WorkSalesOrderHeaderKey] ASC)
);
GO

CREATE TABLE [work].[SalesOrderDetail] (
    [WorkSalesOrderDetailKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SalesOrderHeaderKey] BIGINT NULL,
    [SourceSalesOrderID] BIGINT NOT NULL,
    [SourceSalesOrderDetailID] BIGINT NOT NULL,
    [ProductKey] INT NULL,
    [SpecialOfferKey] INT NULL,
    [CarrierTrackingNumber] VARCHAR(25) NULL,
    [OrderQty] SMALLINT NOT NULL,
    [UnitPrice] DECIMAL(19,4) NOT NULL,
    [UnitPriceDiscount] DECIMAL(19,4) NOT NULL,
    [LineTotal] DECIMAL(19,4) NOT NULL,
    [IsSalesOrderHeaderValid] BIT NOT NULL CONSTRAINT [df_work_SalesOrderDetail_IsSalesOrderHeaderValid] DEFAULT ((0)),
    [IsProductValid] BIT NOT NULL CONSTRAINT [df_work_SalesOrderDetail_IsProductValid] DEFAULT ((0)),
    [IsSpecialOfferValid] BIT NOT NULL CONSTRAINT [df_work_SalesOrderDetail_IsSpecialOfferValid] DEFAULT ((0)),

    CONSTRAINT [pk_work_SalesOrderDetail_WorkSalesOrderDetailKey] PRIMARY KEY CLUSTERED ([WorkSalesOrderDetailKey] ASC)
);
GO
