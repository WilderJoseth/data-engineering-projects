/*
    Script name
        08_create_prod_reference_stored_procedures.sql

    Purpose
        Creates prod-schema load stored procedures for reference data load processes.
*/

USE [Sales_Operational];
GO
CREATE OR ALTER PROCEDURE [prod].[usp_load_AddressType]
    @created_run_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    /*
        Uses explicit UPDATE + INSERT statements.
        This keeps the upsert behavior clear and avoids single-statement
        upsert edge cases while preserving a simple source-key based pattern.
    */

    BEGIN TRANSACTION;

    UPDATE tgt
    SET
        tgt.[Name] = src.[Name],
        tgt.[updated_at] = SYSUTCDATETIME(),
        tgt.[updated_by] = USER_NAME(),
        tgt.[is_active] = 1
    FROM [prod].[AddressType] AS tgt
    INNER JOIN [work].[AddressType] AS src
        ON src.[SourceAddressTypeID] = tgt.[SourceAddressTypeID]
    WHERE src.[IsNameNotBlank] = 1;

    INSERT INTO [prod].[AddressType] (
        [SourceAddressTypeID],
        [Name],
        [created_run_id]
    )
    SELECT
        src.[SourceAddressTypeID],
        src.[Name],
        @created_run_id
    FROM [work].[AddressType] AS src
    WHERE src.[IsNameNotBlank] = 1
      AND NOT EXISTS (
            SELECT 1
            FROM [prod].[AddressType] AS tgt
            WHERE tgt.[SourceAddressTypeID] = src.[SourceAddressTypeID]
        );

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [prod].[usp_load_ProductCategory]
    @created_run_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    UPDATE tgt
    SET
        tgt.[SourceProductCategoryID] = src.[SourceProductCategoryID],
        tgt.[Name] = src.[Name],
        tgt.[updated_at] = SYSUTCDATETIME(),
        tgt.[updated_by] = USER_NAME(),
        tgt.[is_active] = 1
    FROM [prod].[ProductCategory] AS tgt
    INNER JOIN [work].[ProductCategory] AS src
        ON src.[SourceProductSubcategoryID] = tgt.[SourceProductSubcategoryID]
    WHERE src.[IsNameNotBlank] = 1;

    INSERT INTO [prod].[ProductCategory] (
        [SourceProductSubcategoryID],
        [SourceProductCategoryID],
        [Name],
        [created_run_id]
    )
    SELECT
        src.[SourceProductSubcategoryID],
        src.[SourceProductCategoryID],
        src.[Name],
        @created_run_id
    FROM [work].[ProductCategory] AS src
    WHERE src.[IsNameNotBlank] = 1
      AND NOT EXISTS (
            SELECT 1
            FROM [prod].[ProductCategory] AS tgt
            WHERE tgt.[SourceProductSubcategoryID] = src.[SourceProductSubcategoryID]
        );

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [prod].[usp_load_ShipMethod]
    @created_run_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    UPDATE tgt
    SET
        tgt.[Name] = src.[Name],
        tgt.[ShipBase] = src.[ShipBase],
        tgt.[ShipRate] = src.[ShipRate],
        tgt.[updated_at] = SYSUTCDATETIME(),
        tgt.[updated_by] = USER_NAME(),
        tgt.[is_active] = 1
    FROM [prod].[ShipMethod] AS tgt
    INNER JOIN [work].[ShipMethod] AS src
        ON src.[SourceShipMethodID] = tgt.[SourceShipMethodID]
    WHERE src.[IsNameNotBlank] = 1;

    INSERT INTO [prod].[ShipMethod] (
        [SourceShipMethodID],
        [Name],
        [ShipBase],
        [ShipRate],
        [created_run_id]
    )
    SELECT
        src.[SourceShipMethodID],
        src.[Name],
        src.[ShipBase],
        src.[ShipRate],
        @created_run_id
    FROM [work].[ShipMethod] AS src
    WHERE src.[IsNameNotBlank] = 1
      AND NOT EXISTS (
            SELECT 1
            FROM [prod].[ShipMethod] AS tgt
            WHERE tgt.[SourceShipMethodID] = src.[SourceShipMethodID]
        );

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [prod].[usp_load_SpecialOffer]
    @created_run_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    UPDATE tgt
    SET
        tgt.[Description] = src.[Description],
        tgt.[DiscountPct] = src.[DiscountPct],
        tgt.[OfferType] = src.[OfferType],
        tgt.[Category] = src.[Category],
        tgt.[StartDate] = src.[StartDate],
        tgt.[EndDate] = src.[EndDate],
        tgt.[MinQty] = src.[MinQty],
        tgt.[MaxQty] = src.[MaxQty],
        tgt.[updated_at] = SYSUTCDATETIME(),
        tgt.[updated_by] = USER_NAME(),
        tgt.[is_active] = 1
    FROM [prod].[SpecialOffer] AS tgt
    INNER JOIN [work].[SpecialOffer] AS src
        ON src.[SourceSpecialOfferID] = tgt.[SourceSpecialOfferID]
    WHERE src.[IsDescriptionNotBlank] = 1
      AND src.[IsOfferTypeNotBlank] = 1
      AND src.[IsCategoryNotBlank] = 1;

    INSERT INTO [prod].[SpecialOffer] (
        [SourceSpecialOfferID],
        [Description],
        [DiscountPct],
        [OfferType],
        [Category],
        [StartDate],
        [EndDate],
        [MinQty],
        [MaxQty],
        [created_run_id]
    )
    SELECT
        src.[SourceSpecialOfferID],
        src.[Description],
        src.[DiscountPct],
        src.[OfferType],
        src.[Category],
        src.[StartDate],
        src.[EndDate],
        src.[MinQty],
        src.[MaxQty],
        @created_run_id
    FROM [work].[SpecialOffer] AS src
    WHERE src.[IsDescriptionNotBlank] = 1
      AND src.[IsOfferTypeNotBlank] = 1
      AND src.[IsCategoryNotBlank] = 1
      AND NOT EXISTS (
            SELECT 1
            FROM [prod].[SpecialOffer] AS tgt
            WHERE tgt.[SourceSpecialOfferID] = src.[SourceSpecialOfferID]
        );

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [prod].[usp_load_Geography]
    @created_run_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    UPDATE tgt
    SET
        tgt.[Name] = src.[Name],
        tgt.[updated_at] = SYSUTCDATETIME(),
        tgt.[updated_by] = USER_NAME(),
        tgt.[is_active] = 1
    FROM [prod].[CountryRegion] AS tgt
    INNER JOIN [work].[CountryRegion] AS src
        ON src.[SourceCountryRegionCode] = tgt.[SourceCountryRegionCode]
    WHERE src.[IsCountryRegionCodeNotBlank] = 1
      AND src.[IsNameNotBlank] = 1;

    INSERT INTO [prod].[CountryRegion] (
        [SourceCountryRegionCode],
        [Name],
        [created_run_id]
    )
    SELECT
        src.[SourceCountryRegionCode],
        src.[Name],
        @created_run_id
    FROM [work].[CountryRegion] AS src
    WHERE src.[IsCountryRegionCodeNotBlank] = 1
      AND src.[IsNameNotBlank] = 1
      AND NOT EXISTS (
            SELECT 1
            FROM [prod].[CountryRegion] AS tgt
            WHERE tgt.[SourceCountryRegionCode] = src.[SourceCountryRegionCode]
        );

    UPDATE tgt
    SET
        tgt.[Name] = src.[Name],
        tgt.[TerritoryGroup] = src.[TerritoryGroup],
        tgt.[CountryRegionKey] = cr.[CountryRegionKey],
        tgt.[updated_at] = SYSUTCDATETIME(),
        tgt.[updated_by] = USER_NAME(),
        tgt.[is_active] = 1
    FROM [prod].[SalesTerritory] AS tgt
    INNER JOIN [work].[SalesTerritory] AS src
        ON src.[SourceTerritoryID] = tgt.[SourceTerritoryID]
    INNER JOIN [prod].[CountryRegion] AS cr
        ON cr.[SourceCountryRegionCode] = src.[SourceCountryRegionCode]
    WHERE src.[IsNameNotBlank] = 1
      AND src.[IsTerritoryGroupNotBlank] = 1
      AND src.[IsCountryRegionValid] = 1;

    INSERT INTO [prod].[SalesTerritory] (
        [SourceTerritoryID],
        [Name],
        [TerritoryGroup],
        [CountryRegionKey],
        [created_run_id]
    )
    SELECT
        src.[SourceTerritoryID],
        src.[Name],
        src.[TerritoryGroup],
        cr.[CountryRegionKey],
        @created_run_id
    FROM [work].[SalesTerritory] AS src
    INNER JOIN [prod].[CountryRegion] AS cr
        ON cr.[SourceCountryRegionCode] = src.[SourceCountryRegionCode]
    WHERE src.[IsNameNotBlank] = 1
      AND src.[IsTerritoryGroupNotBlank] = 1
      AND src.[IsCountryRegionValid] = 1
      AND NOT EXISTS (
            SELECT 1
            FROM [prod].[SalesTerritory] AS tgt
            WHERE tgt.[SourceTerritoryID] = src.[SourceTerritoryID]
        );

    UPDATE tgt
    SET
        tgt.[StateProvinceCode] = src.[StateProvinceCode],
        tgt.[Name] = src.[Name],
        tgt.[CountryRegionKey] = cr.[CountryRegionKey],
        tgt.[SalesTerritoryKey] = st.[SalesTerritoryKey],
        tgt.[updated_at] = SYSUTCDATETIME(),
        tgt.[updated_by] = USER_NAME(),
        tgt.[is_active] = 1
    FROM [prod].[StateProvince] AS tgt
    INNER JOIN [work].[StateProvince] AS src
        ON src.[SourceStateProvinceID] = tgt.[SourceStateProvinceID]
    INNER JOIN [prod].[CountryRegion] AS cr
        ON cr.[SourceCountryRegionCode] = src.[SourceCountryRegionCode]
    INNER JOIN [prod].[SalesTerritory] AS st
        ON st.[SourceTerritoryID] = src.[SourceTerritoryID]
    WHERE src.[IsStateProvinceCodeNotBlank] = 1
      AND src.[IsNameNotBlank] = 1
      AND src.[IsCountryRegionValid] = 1
      AND src.[IsSalesTerritoryValid] = 1;

    INSERT INTO [prod].[StateProvince] (
        [SourceStateProvinceID],
        [StateProvinceCode],
        [Name],
        [CountryRegionKey],
        [SalesTerritoryKey],
        [created_run_id]
    )
    SELECT
        src.[SourceStateProvinceID],
        src.[StateProvinceCode],
        src.[Name],
        cr.[CountryRegionKey],
        st.[SalesTerritoryKey],
        @created_run_id
    FROM [work].[StateProvince] AS src
    INNER JOIN [prod].[CountryRegion] AS cr
        ON cr.[SourceCountryRegionCode] = src.[SourceCountryRegionCode]
    INNER JOIN [prod].[SalesTerritory] AS st
        ON st.[SourceTerritoryID] = src.[SourceTerritoryID]
    WHERE src.[IsStateProvinceCodeNotBlank] = 1
      AND src.[IsNameNotBlank] = 1
      AND src.[IsCountryRegionValid] = 1
      AND src.[IsSalesTerritoryValid] = 1
      AND NOT EXISTS (
            SELECT 1
            FROM [prod].[StateProvince] AS tgt
            WHERE tgt.[SourceStateProvinceID] = src.[SourceStateProvinceID]
        );

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [prod].[usp_load_Currency]
    @created_run_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    UPDATE tgt
    SET
        tgt.[Name] = src.[Name],
        tgt.[updated_at] = SYSUTCDATETIME(),
        tgt.[updated_by] = USER_NAME(),
        tgt.[is_active] = 1
    FROM [prod].[Currency] AS tgt
    INNER JOIN [work].[Currency] AS src
        ON src.[SourceCurrencyCode] = tgt.[SourceCurrencyCode]
    WHERE src.[IsCurrencyCodeNotBlank] = 1
      AND src.[IsNameNotBlank] = 1;

    INSERT INTO [prod].[Currency] (
        [SourceCurrencyCode],
        [Name],
        [created_run_id]
    )
    SELECT
        src.[SourceCurrencyCode],
        src.[Name],
        @created_run_id
    FROM [work].[Currency] AS src
    WHERE src.[IsCurrencyCodeNotBlank] = 1
      AND src.[IsNameNotBlank] = 1
      AND NOT EXISTS (
            SELECT 1
            FROM [prod].[Currency] AS tgt
            WHERE tgt.[SourceCurrencyCode] = src.[SourceCurrencyCode]
        );

    UPDATE tgt
    SET
        tgt.[CurrencyRateDate] = src.[CurrencyRateDate],
        tgt.[FromCurrencyKey] = from_currency.[CurrencyKey],
        tgt.[ToCurrencyKey] = to_currency.[CurrencyKey],
        tgt.[AverageRate] = src.[AverageRate],
        tgt.[EndOfDayRate] = src.[EndOfDayRate],
        tgt.[updated_at] = SYSUTCDATETIME(),
        tgt.[updated_by] = USER_NAME(),
        tgt.[is_active] = 1
    FROM [prod].[CurrencyRate] AS tgt
    INNER JOIN [work].[CurrencyRate] AS src
        ON src.[SourceCurrencyRateID] = tgt.[SourceCurrencyRateID]
    INNER JOIN [prod].[Currency] AS from_currency
        ON from_currency.[SourceCurrencyCode] = src.[FromCurrencyCode]
    INNER JOIN [prod].[Currency] AS to_currency
        ON to_currency.[SourceCurrencyCode] = src.[ToCurrencyCode]
    WHERE src.[IsFromCurrencyValid] = 1
      AND src.[IsToCurrencyValid] = 1;

    INSERT INTO [prod].[CurrencyRate] (
        [SourceCurrencyRateID],
        [CurrencyRateDate],
        [FromCurrencyKey],
        [ToCurrencyKey],
        [AverageRate],
        [EndOfDayRate],
        [created_run_id]
    )
    SELECT
        src.[SourceCurrencyRateID],
        src.[CurrencyRateDate],
        from_currency.[CurrencyKey],
        to_currency.[CurrencyKey],
        src.[AverageRate],
        src.[EndOfDayRate],
        @created_run_id
    FROM [work].[CurrencyRate] AS src
    INNER JOIN [prod].[Currency] AS from_currency
        ON from_currency.[SourceCurrencyCode] = src.[FromCurrencyCode]
    INNER JOIN [prod].[Currency] AS to_currency
        ON to_currency.[SourceCurrencyCode] = src.[ToCurrencyCode]
    WHERE src.[IsFromCurrencyValid] = 1
      AND src.[IsToCurrencyValid] = 1
      AND NOT EXISTS (
            SELECT 1
            FROM [prod].[CurrencyRate] AS tgt
            WHERE tgt.[SourceCurrencyRateID] = src.[SourceCurrencyRateID]
        );

    COMMIT TRANSACTION;
END;
GO

