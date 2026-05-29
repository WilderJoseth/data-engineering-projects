/*
    Script name
        01_seed_reference_master_staging_test_data.sql

    Purpose
        Loads deterministic test rows into Sales_Operational staging tables for
        reference and master data load validation.

    Usage notes
        - Run after creating staging, work, control, and prod objects.
        - The script intentionally inserts valid and invalid rows.
        - Invalid rows are designed to pass staging constraints and fail only in
          work-schema validation procedures.
        - Execute inside a test database only. The script clears reference and
          master staging tables before inserting test data.
*/

USE [Sales_Operational];
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

/*
    Reset only the staging tables covered by reference and master data flows.
    Transactional sales order staging tables are intentionally not touched here.
*/
DELETE FROM [staging].[Customer];
DELETE FROM [staging].[SalesPerson];
DELETE FROM [staging].[Product];
DELETE FROM [staging].[Address];
DELETE FROM [staging].[CreditCard];
DELETE FROM [staging].[CurrencyRate];
DELETE FROM [staging].[Currency];
DELETE FROM [staging].[ShipMethod];
DELETE FROM [staging].[SpecialOffer];
DELETE FROM [staging].[ProductCategory];
DELETE FROM [staging].[StateProvince];
DELETE FROM [staging].[SalesTerritory];
DELETE FROM [staging].[CountryRegion];
DELETE FROM [staging].[AddressType];

/*
    Reference data: AddressType
    Validation coverage:
        - Valid names.
        - Name that becomes blank after TRIM.
*/
INSERT INTO [staging].[AddressType] ([SourceAddressTypeID], [Name])
VALUES
    (1, 'Billing'),
    (2, 'Shipping'),
    (99, '   ');

/*
    Reference data: Geography
    Validation coverage:
        - Valid CountryRegion, SalesTerritory, and StateProvince rows.
        - Blank CountryRegion code and name.
        - Blank SalesTerritory name and group.
        - Invalid CountryRegion dependency for SalesTerritory and StateProvince.
        - Invalid SalesTerritory dependency for StateProvince.
*/
INSERT INTO [staging].[CountryRegion] ([SourceCountryRegionCode], [Name])
VALUES
    ('US', 'United States'),
    ('CA', 'Canada'),
    ('   ', 'Blank country code case'),
    ('ZZ', '   ');

INSERT INTO [staging].[SalesTerritory] (
    [SourceTerritoryID],
    [Name],
    [TerritoryGroup],
    [SourceCountryRegionCode]
)
VALUES
    (1, 'Northwest', 'North America', 'US'),
    (2, '   ', 'North America', 'US'),
    (3, 'Canada', '   ', 'CA'),
    (4, 'Invalid Country Territory', 'North America', 'XXX');

INSERT INTO [staging].[StateProvince] (
    [SourceStateProvinceID],
    [StateProvinceCode],
    [Name],
    [SourceCountryRegionCode],
    [SourceTerritoryID]
)
VALUES
    (10, 'WA', 'Washington', 'US', 1),
    (11, '   ', 'Blank state code case', 'US', 1),
    (12, 'BC', '   ', 'CA', 3),
    (13, 'ZZ', 'Invalid Country State', 'XXX', 1),
    (14, 'OR', 'Invalid Territory State', 'US', 999);

/*
    Reference data: ProductCategory
    Validation coverage:
        - Valid product subcategories.
        - Blank name.
*/
INSERT INTO [staging].[ProductCategory] (
    [SourceProductSubcategoryID],
    [SourceProductCategoryID],
    [Name]
)
VALUES
    (100, 10, 'Road Bikes'),
    (101, 10, 'Mountain Bikes'),
    (199, 19, '   ');

/*
    Reference data: ShipMethod
    Validation coverage:
        - Valid ship methods.
        - Blank name.
*/
INSERT INTO [staging].[ShipMethod] (
    [SourceShipMethodID],
    [Name],
    [ShipBase],
    [ShipRate]
)
VALUES
    (1, 'CARGO TRANSPORT 5', 10.0000, 1.2500),
    (2, 'OVERNIGHT J-FAST', 25.0000, 4.5000),
    (99, '   ', 0.0000, 0.0000);

/*
    Reference data: SpecialOffer
    Validation coverage:
        - Valid offer.
        - Blank description, offer type, and category.
*/
INSERT INTO [staging].[SpecialOffer] (
    [SourceSpecialOfferID],
    [Description],
    [DiscountPct],
    [OfferType],
    [Category],
    [StartDate],
    [EndDate],
    [MinQty],
    [MaxQty]
)
VALUES
    (1, 'No Discount', 0.0000, 'No Discount', 'No Discount', '2022-01-01', '2026-12-31', 0, NULL),
    (91, '   ', 0.1000, 'Seasonal Discount', 'Reseller', '2024-01-01', '2024-12-31', 1, 10),
    (92, 'Volume Discount', 0.1500, '   ', 'Reseller', '2024-01-01', '2024-12-31', 5, 20),
    (93, 'Clearance Discount', 0.2000, 'Discontinued Product', '   ', '2024-01-01', '2024-12-31', 1, NULL);

/*
    Reference data: Currency
    Validation coverage:
        - Valid currencies and rate.
        - Blank currency code and name.
        - Invalid from/to currency dependencies for rates.
*/
INSERT INTO [staging].[Currency] ([SourceCurrencyCode], [Name])
VALUES
    ('USD', 'US Dollar'),
    ('EUR', 'Euro'),
    ('   ', 'Blank currency code case'),
    ('JPY', '   ');

INSERT INTO [staging].[CurrencyRate] (
    [SourceCurrencyRateID],
    [CurrencyRateDate],
    [FromCurrencyCode],
    [ToCurrencyCode],
    [AverageRate],
    [EndOfDayRate]
)
VALUES
    (1, '2024-01-01T00:00:00', 'USD', 'EUR', 0.9200, 0.9250),
    (91, '2024-01-02T00:00:00', 'XXX', 'EUR', 1.1000, 1.1000),
    (92, '2024-01-03T00:00:00', 'USD', 'YYY', 1.2000, 1.2000);

/*
    Master data: CreditCard
    Validation coverage:
        - Valid card.
        - Blank card type.
        - Card number that cannot produce a reliable last-four value.
*/
INSERT INTO [staging].[CreditCard] (
    [SourceCreditCardID],
    [CardType],
    [CardNumber],
    [ExpMonth],
    [ExpYear]
)
VALUES
    (1, 'Vista', '1111222233334444', 12, 2027),
    (91, '   ', '5555666677778888', 11, 2028),
    (92, 'SuperiorCard', '123', 10, 2029);

/*
    Master data: Address
    Validation coverage:
        - Valid address.
        - Blank address line, city, and postal code.
        - Invalid StateProvince dependency.
        - Invalid AddressType dependency.
*/
INSERT INTO [staging].[Address] (
    [SourceAddressID],
    [AddressLine1],
    [AddressLine2],
    [City],
    [SourceStateProvinceID],
    [PostalCode],
    [SourceAddressTypeID]
)
VALUES
    (1000, '1970 Napa Ct.', NULL, 'Bothell', 10, '98011', 1),
    (1091, '   ', NULL, 'Bothell', 10, '98011', 1),
    (1092, '123 Test St.', NULL, '   ', 10, '98011', 1),
    (1093, '456 Test St.', NULL, 'Seattle', 10, '   ', 1),
    (1094, '789 Test St.', NULL, 'Seattle', 999, '98101', 1),
    (1095, '321 Test St.', NULL, 'Seattle', 10, '98101', 999);

/*
    Master data: Product
    Validation coverage:
        - Valid product.
        - Blank product number and name.
        - Invalid ProductCategory dependency.
*/
INSERT INTO [staging].[Product] (
    [SourceProductID],
    [ProductNumber],
    [Name],
    [Color],
    [SafetyStockLevel],
    [ReorderPoint],
    [StandardCost],
    [ListPrice],
    [Size],
    [Weight],
    [SourceProductSubcategoryID],
    [SellStartDate],
    [SellEndDate],
    [DiscontinuedDate]
)
VALUES
    (2000, 'BK-R93R-62', 'Road-150 Red, 62', 'Red', 100, 75, 2171.2942, 3578.2700, '62', 15.00, 100, '2022-01-01', NULL, NULL),
    (2091, '   ', 'Mountain-100 Silver, 42', 'Silver', 100, 75, 1912.1544, 3399.9900, '42', 20.00, 101, '2022-01-01', NULL, NULL),
    (2092, 'BK-M82S-44', '   ', 'Silver', 100, 75, 1912.1544, 3399.9900, '44', 20.00, 101, '2022-01-01', NULL, NULL),
    (2093, 'BK-X99B-48', 'Invalid Category Product', 'Black', 100, 75, 1000.0000, 1500.0000, '48', 18.50, 999, '2022-01-01', NULL, NULL);

/*
    Master data: SalesPerson
    Validation coverage:
        - Valid salesperson.
        - Blank first name, last name, job title, and gender.
        - Invalid SalesTerritory dependency.
*/
INSERT INTO [staging].[SalesPerson] (
    [SourceBusinessEntityID],
    [SourceTerritoryID],
    [Title],
    [FirstName],
    [MiddleName],
    [LastName],
    [JobTitle],
    [Gender],
    [HireDate],
    [SalesQuota],
    [Bonus],
    [CommissionPct],
    [SalesYTD],
    [SalesLastYear]
)
VALUES
    (3000, 1, 'Mr.', 'David', 'R.', 'Campbell', 'Sales Representative', 'M', '2018-06-01', 250000.0000, 5000.0000, 0.0150, 4251368.5497, 4116871.2277),
    (3091, 1, 'Ms.', '   ', NULL, 'Martinez', 'Sales Representative', 'F', '2019-01-15', 250000.0000, 3500.0000, 0.0120, 1200000.0000, 900000.0000),
    (3092, 1, 'Mr.', 'John', NULL, '   ', 'Sales Representative', 'M', '2019-02-15', 250000.0000, 3500.0000, 0.0120, 1200000.0000, 900000.0000),
    (3093, 1, NULL, 'Sarah', NULL, 'Smith', '   ', 'F', '2019-03-15', 250000.0000, 3500.0000, 0.0120, 1200000.0000, 900000.0000),
    (3094, 1, NULL, 'Kyle', NULL, 'Young', 'Sales Representative', ' ', '2019-04-15', 250000.0000, 3500.0000, 0.0120, 1200000.0000, 900000.0000),
    (3095, 999, NULL, 'Maria', NULL, 'Lopez', 'Sales Representative', 'F', '2019-05-15', 250000.0000, 3500.0000, 0.0120, 1200000.0000, 900000.0000);

/*
    Master data: Customer
    Validation coverage:
        - Valid person customer.
        - Store customer without person data.
        - Person customer with blank name.
        - Invalid SalesTerritory dependency.
*/
INSERT INTO [staging].[Customer] (
    [SourceCustomerID],
    [SourcePersonID],
    [SourceTerritoryID],
    [PersonType],
    [Title],
    [FirstName],
    [MiddleName],
    [LastName],
    [AccountNumber]
)
VALUES
    (4000, 5000, 1, 'IN', 'Mr.', 'Aaron', NULL, 'Conner', 'AW00004000'),
    (4001, NULL, 1, NULL, NULL, NULL, NULL, NULL, 'AW00004001'),
    (4091, 5091, 1, 'IN', 'Ms.', '   ', NULL, 'Parker', 'AW00004091'),
    (4092, 5092, 1, 'IN', 'Mr.', 'James', NULL, '   ', 'AW00004092'),
    (4093, 5093, 999, 'IN', 'Ms.', 'Laura', NULL, 'Green', 'AW00004093');

COMMIT TRANSACTION;
GO
