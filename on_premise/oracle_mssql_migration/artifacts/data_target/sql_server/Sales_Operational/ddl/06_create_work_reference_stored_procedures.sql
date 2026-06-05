/*
    Script name
        06_create_work_reference_stored_procedures.sql

    Purpose
        Creates work-schema validation stored procedures for reference data load processes.
*/

USE [Sales_Operational];
GO

CREATE OR ALTER PROCEDURE [control].[usp_cleanup_AddressType]
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    TRUNCATE TABLE [work].[AddressType];
    TRUNCATE TABLE [staging].[AddressType];

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [control].[usp_cleanup_ProductCategory]
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    TRUNCATE TABLE [work].[ProductCategory];
    TRUNCATE TABLE [staging].[ProductCategory];

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [control].[usp_cleanup_ShipMethod]
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    TRUNCATE TABLE [work].[ShipMethod];
    TRUNCATE TABLE [staging].[ShipMethod];

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [control].[usp_cleanup_SpecialOffer]
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    TRUNCATE TABLE [work].[SpecialOffer];
    TRUNCATE TABLE [staging].[SpecialOffer];

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [control].[usp_cleanup_Geography]
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    TRUNCATE TABLE [work].[StateProvince];
    TRUNCATE TABLE [work].[SalesTerritory];
    TRUNCATE TABLE [work].[CountryRegion];

    TRUNCATE TABLE [staging].[StateProvince];
    TRUNCATE TABLE [staging].[SalesTerritory];
    TRUNCATE TABLE [staging].[CountryRegion];

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [control].[usp_cleanup_Currency]
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    TRUNCATE TABLE [work].[CurrencyRate];
    TRUNCATE TABLE [work].[Currency];

    TRUNCATE TABLE [staging].[CurrencyRate];
    TRUNCATE TABLE [staging].[Currency];

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [work].[usp_validate_AddressType]
    @execution_step_id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @not_null_validation_code_id SMALLINT;

    SELECT @not_null_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'NOT_NULL';

    IF @not_null_validation_code_id IS NULL
        THROW 51001, 'Missing validation code: NOT_NULL.', 1;

    BEGIN TRANSACTION;

    INSERT INTO [work].[AddressType] (
        [SourceAddressTypeID],
        [Name],
        [IsNameNotBlank]
    )
    SELECT
        [SourceAddressTypeID],
        TRIM([Name]) AS [Name],
        IIF(LEN(TRIM([Name])) > 0, 1, 0) AS [IsNameNotBlank]
    FROM [staging].[AddressType];

    INSERT INTO [control].[validation_results] (
        [details],
        [affected_row_count],
        [execution_step_id],
        [validation_code_id]
    )
    SELECT
        'AddressType Load - Name must not be blank after trimming.' AS [details],
        COUNT_BIG(*) AS [affected_row_count],
        @execution_step_id AS [execution_step_id],
        @not_null_validation_code_id AS [validation_code_id]
    FROM [work].[AddressType]
    WHERE [IsNameNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [work].[usp_validate_ProductCategory]
    @execution_step_id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @not_null_validation_code_id SMALLINT;

    SELECT @not_null_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'NOT_NULL';

    IF @not_null_validation_code_id IS NULL
        THROW 51001, 'Missing validation code: NOT_NULL.', 1;

    BEGIN TRANSACTION;

    INSERT INTO [work].[ProductCategory] (
        [SourceProductCategoryID],
        [Name],
        [IsNameNotBlank]
    )
    SELECT
        [SourceProductSubcategoryID],
        TRIM([Name]) AS [Name],
        IIF(LEN(TRIM([Name])) > 0, 1, 0) AS [IsNameNotBlank]
    FROM [staging].[ProductCategory];

    INSERT INTO [control].[validation_results] (
        [details],
        [affected_row_count],
        [execution_step_id],
        [validation_code_id]
    )
    SELECT
        'ProductCategory Load - Name must not be blank after trimming.' AS [details],
        COUNT_BIG(*) AS [affected_row_count],
        @execution_step_id AS [execution_step_id],
        @not_null_validation_code_id AS [validation_code_id]
    FROM [work].[ProductCategory]
    WHERE [IsNameNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [work].[usp_validate_SpecialOffer]
    @execution_step_id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @not_null_validation_code_id SMALLINT;

    SELECT @not_null_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'NOT_NULL';

    IF @not_null_validation_code_id IS NULL
        THROW 51001, 'Missing validation code: NOT_NULL.', 1;

    BEGIN TRANSACTION;

    INSERT INTO [work].[SpecialOffer] (
        [SourceSpecialOfferID],
        [Description],
        [DiscountPct],
        [OfferType],
        [Category],
        [StartDate],
        [EndDate],
        [MinQty],
        [MaxQty],
        [IsDescriptionNotBlank],
        [IsOfferTypeNotBlank],
        [IsCategoryNotBlank]
    )
    SELECT
        [SourceSpecialOfferID],
        TRIM([Description]) AS [Description],
        [DiscountPct],
        TRIM([OfferType]) AS [OfferType],
        TRIM([Category]) AS [Category],
        [StartDate],
        [EndDate],
        [MinQty],
        [MaxQty],
        IIF(LEN(TRIM([Description])) > 0, 1, 0) AS [IsDescriptionNotBlank],
        IIF(LEN(TRIM([OfferType])) > 0, 1, 0) AS [IsOfferTypeNotBlank],
        IIF(LEN(TRIM([Category])) > 0, 1, 0) AS [IsCategoryNotBlank]
    FROM [staging].[SpecialOffer];

    INSERT INTO [control].[validation_results] (
        [details],
        [affected_row_count],
        [execution_step_id],
        [validation_code_id]
    )
    SELECT
        'SpecialOffer Load - Description must not be blank after trimming.' AS [details],
        COUNT_BIG(*) AS [affected_row_count],
        @execution_step_id AS [execution_step_id],
        @not_null_validation_code_id AS [validation_code_id]
    FROM [work].[SpecialOffer]
    WHERE [IsDescriptionNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] (
        [details],
        [affected_row_count],
        [execution_step_id],
        [validation_code_id]
    )
    SELECT
        'SpecialOffer Load - OfferType must not be blank after trimming.' AS [details],
        COUNT_BIG(*) AS [affected_row_count],
        @execution_step_id AS [execution_step_id],
        @not_null_validation_code_id AS [validation_code_id]
    FROM [work].[SpecialOffer]
    WHERE [IsOfferTypeNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] (
        [details],
        [affected_row_count],
        [execution_step_id],
        [validation_code_id]
    )
    SELECT
        'SpecialOffer Load - Category must not be blank after trimming.' AS [details],
        COUNT_BIG(*) AS [affected_row_count],
        @execution_step_id AS [execution_step_id],
        @not_null_validation_code_id AS [validation_code_id]
    FROM [work].[SpecialOffer]
    WHERE [IsCategoryNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [work].[usp_validate_ShipMethod]
    @execution_step_id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @not_null_validation_code_id SMALLINT;

    SELECT @not_null_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'NOT_NULL';

    IF @not_null_validation_code_id IS NULL
        THROW 51001, 'Missing validation code: NOT_NULL.', 1;

    BEGIN TRANSACTION;

    INSERT INTO [work].[ShipMethod] (
        [SourceShipMethodID],
        [Name],
        [ShipBase],
        [ShipRate],
        [IsNameNotBlank]
    )
    SELECT
        [SourceShipMethodID],
        TRIM([Name]) AS [Name],
        [ShipBase],
        [ShipRate],
        IIF(LEN(TRIM([Name])) > 0, 1, 0) AS [IsNameNotBlank]
    FROM [staging].[ShipMethod];

    INSERT INTO [control].[validation_results] (
        [details],
        [affected_row_count],
        [execution_step_id],
        [validation_code_id]
    )
    SELECT
        'ShipMethod Load - Name must not be blank after trimming.' AS [details],
        COUNT_BIG(*) AS [affected_row_count],
        @execution_step_id AS [execution_step_id],
        @not_null_validation_code_id AS [validation_code_id]
    FROM [work].[ShipMethod]
    WHERE [IsNameNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [work].[usp_validate_Geography]
    @execution_step_id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @not_null_validation_code_id SMALLINT;
    DECLARE @fk_validation_code_id SMALLINT;

    SELECT @not_null_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'NOT_NULL';

    SELECT @fk_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'FK_CHECK';

    IF @not_null_validation_code_id IS NULL
        THROW 51001, 'Missing validation code: NOT_NULL.', 1;

    IF @fk_validation_code_id IS NULL
        THROW 51002, 'Missing validation code: FK_CHECK.', 1;

    BEGIN TRANSACTION;

    INSERT INTO [work].[CountryRegion] (
        [SourceCountryRegionCode],
        [Name],
        [IsCountryRegionCodeNotBlank],
        [IsNameNotBlank]
    )
    SELECT
        TRIM([SourceCountryRegionCode]) AS [SourceCountryRegionCode],
        TRIM([Name]) AS [Name],
        IIF(LEN(TRIM([SourceCountryRegionCode])) > 0, 1, 0) AS [IsCountryRegionCodeNotBlank],
        IIF(LEN(TRIM([Name])) > 0, 1, 0) AS [IsNameNotBlank]
    FROM [staging].[CountryRegion];

    INSERT INTO [work].[SalesTerritory] (
        [SourceTerritoryID],
        [Name],
        [TerritoryGroup],
        [SourceCountryRegionCode],
        [IsNameNotBlank],
        [IsTerritoryGroupNotBlank],
        [IsCountryRegionValid]
    )
    SELECT
        st.[SourceTerritoryID],
        TRIM(st.[Name]) AS [Name],
        TRIM(st.[TerritoryGroup]) AS [TerritoryGroup],
        TRIM(st.[SourceCountryRegionCode]) AS [SourceCountryRegionCode],
        IIF(LEN(TRIM(st.[Name])) > 0, 1, 0) AS [IsNameNotBlank],
        IIF(LEN(TRIM(st.[TerritoryGroup])) > 0, 1, 0) AS [IsTerritoryGroupNotBlank],
        IIF(cr.[SourceCountryRegionCode] IS NOT NULL, 1, 0) AS [IsCountryRegionValid]
    FROM [staging].[SalesTerritory] AS st
    LEFT JOIN [work].[CountryRegion] AS cr
        ON cr.[SourceCountryRegionCode] = TRIM(st.[SourceCountryRegionCode])
       AND cr.[IsCountryRegionCodeNotBlank] = 1
       AND cr.[IsNameNotBlank] = 1;

    INSERT INTO [work].[StateProvince] (
        [SourceStateProvinceID],
        [StateProvinceCode],
        [Name],
        [SourceCountryRegionCode],
        [SourceTerritoryID],
        [IsStateProvinceCodeNotBlank],
        [IsNameNotBlank],
        [IsCountryRegionValid],
        [IsSalesTerritoryValid]
    )
    SELECT
        sp.[SourceStateProvinceID],
        TRIM(sp.[StateProvinceCode]) AS [StateProvinceCode],
        TRIM(sp.[Name]) AS [Name],
        TRIM(sp.[SourceCountryRegionCode]) AS [SourceCountryRegionCode],
        sp.[SourceTerritoryID],
        IIF(LEN(TRIM(sp.[StateProvinceCode])) > 0, 1, 0) AS [IsStateProvinceCodeNotBlank],
        IIF(LEN(TRIM(sp.[Name])) > 0, 1, 0) AS [IsNameNotBlank],
        IIF(cr.[SourceCountryRegionCode] IS NOT NULL, 1, 0) AS [IsCountryRegionValid],
        IIF(st.[SourceTerritoryID] IS NOT NULL, 1, 0) AS [IsSalesTerritoryValid]
    FROM [staging].[StateProvince] AS sp
    LEFT JOIN [work].[CountryRegion] AS cr
        ON cr.[SourceCountryRegionCode] = TRIM(sp.[SourceCountryRegionCode])
       AND cr.[IsCountryRegionCodeNotBlank] = 1
       AND cr.[IsNameNotBlank] = 1
    LEFT JOIN [work].[SalesTerritory] AS st
        ON st.[SourceTerritoryID] = sp.[SourceTerritoryID]
       AND st.[IsNameNotBlank] = 1
       AND st.[IsTerritoryGroupNotBlank] = 1
       AND st.[IsCountryRegionValid] = 1;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Geography Load - CountryRegionCode must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[CountryRegion]
    WHERE [IsCountryRegionCodeNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Geography Load - CountryRegion Name must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[CountryRegion]
    WHERE [IsNameNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Geography Load - SalesTerritory Name must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[SalesTerritory]
    WHERE [IsNameNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Geography Load - SalesTerritory group must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[SalesTerritory]
    WHERE [IsTerritoryGroupNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Geography Load - SalesTerritory must reference a valid CountryRegion.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[SalesTerritory]
    WHERE [IsCountryRegionValid] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Geography Load - StateProvinceCode must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[StateProvince]
    WHERE [IsStateProvinceCodeNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Geography Load - StateProvince Name must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[StateProvince]
    WHERE [IsNameNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Geography Load - StateProvince must reference a valid CountryRegion.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[StateProvince]
    WHERE [IsCountryRegionValid] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Geography Load - StateProvince must reference a valid SalesTerritory.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[StateProvince]
    WHERE [IsSalesTerritoryValid] = 0
    HAVING COUNT_BIG(*) > 0;

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [work].[usp_validate_Currency]
    @execution_step_id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @not_null_validation_code_id SMALLINT;
    DECLARE @fk_validation_code_id SMALLINT;

    SELECT @not_null_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'NOT_NULL';

    SELECT @fk_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'FK_CHECK';

    IF @not_null_validation_code_id IS NULL
        THROW 51001, 'Missing validation code: NOT_NULL.', 1;

    IF @fk_validation_code_id IS NULL
        THROW 51002, 'Missing validation code: FK_CHECK.', 1;

    BEGIN TRANSACTION;

    INSERT INTO [work].[Currency] (
        [SourceCurrencyCode],
        [Name],
        [IsCurrencyCodeNotBlank],
        [IsNameNotBlank]
    )
    SELECT
        TRIM([SourceCurrencyCode]) AS [SourceCurrencyCode],
        TRIM([Name]) AS [Name],
        IIF(LEN(TRIM([SourceCurrencyCode])) > 0, 1, 0) AS [IsCurrencyCodeNotBlank],
        IIF(LEN(TRIM([Name])) > 0, 1, 0) AS [IsNameNotBlank]
    FROM [staging].[Currency];

    INSERT INTO [work].[CurrencyRate] (
        [SourceCurrencyRateID],
        [CurrencyRateDate],
        [FromCurrencyCode],
        [ToCurrencyCode],
        [AverageRate],
        [EndOfDayRate],
        [IsFromCurrencyValid],
        [IsToCurrencyValid]
    )
    SELECT
        cr.[SourceCurrencyRateID],
        cr.[CurrencyRateDate],
        TRIM(cr.[FromCurrencyCode]) AS [FromCurrencyCode],
        TRIM(cr.[ToCurrencyCode]) AS [ToCurrencyCode],
        cr.[AverageRate],
        cr.[EndOfDayRate],
        IIF(fc.[SourceCurrencyCode] IS NOT NULL, 1, 0) AS [IsFromCurrencyValid],
        IIF(tc.[SourceCurrencyCode] IS NOT NULL, 1, 0) AS [IsToCurrencyValid]
    FROM [staging].[CurrencyRate] AS cr
    LEFT JOIN [work].[Currency] AS fc
        ON fc.[SourceCurrencyCode] = TRIM(cr.[FromCurrencyCode])
       AND fc.[IsCurrencyCodeNotBlank] = 1
       AND fc.[IsNameNotBlank] = 1
    LEFT JOIN [work].[Currency] AS tc
        ON tc.[SourceCurrencyCode] = TRIM(cr.[ToCurrencyCode])
       AND tc.[IsCurrencyCodeNotBlank] = 1
       AND tc.[IsNameNotBlank] = 1;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Currency Load - CurrencyCode must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[Currency]
    WHERE [IsCurrencyCodeNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Currency Load - Currency Name must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[Currency]
    WHERE [IsNameNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Currency Load - CurrencyRate FromCurrencyCode must reference a valid Currency.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[CurrencyRate]
    WHERE [IsFromCurrencyValid] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Currency Load - CurrencyRate ToCurrencyCode must reference a valid Currency.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[CurrencyRate]
    WHERE [IsToCurrencyValid] = 0
    HAVING COUNT_BIG(*) > 0;

    COMMIT TRANSACTION;
END;
GO

