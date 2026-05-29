/*
    Script name
        07_create_work_master_stored_procedures.sql

    Purpose
        Creates work-schema validation stored procedures for master data load processes.
*/

USE [Sales_Operational];
GO
CREATE OR ALTER PROCEDURE [work].[usp_validate_CreditCard]
    @execution_step_id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @not_null_validation_code_id SMALLINT;
    DECLARE @fk_validation_code_id SMALLINT;
    DECLARE @length_validation_code_id SMALLINT;

    SELECT @not_null_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'NOT_NULL';

    SELECT @fk_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'FK_CHECK';

    SELECT @length_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'LENGTH_CHECK';

    IF @not_null_validation_code_id IS NULL
        THROW 51001, 'Missing validation code: NOT_NULL.', 1;

    IF @fk_validation_code_id IS NULL
        THROW 51002, 'Missing validation code: FK_CHECK.', 1;

    IF @length_validation_code_id IS NULL
        THROW 51003, 'Missing validation code: LENGTH_CHECK.', 1;
    BEGIN TRANSACTION;

    INSERT INTO [work].[CreditCard] (
        [SourceCreditCardID],
        [CardType],
        [CardNumberLast4],
        [ExpMonth],
        [ExpYear],
        [IsCardTypeNotBlank],
        [IsCardNumberUsable]
    )
    SELECT
        [SourceCreditCardID],
        TRIM([CardType]) AS [CardType],
        RIGHT(TRIM([CardNumber]), 4) AS [CardNumberLast4],
        [ExpMonth],
        [ExpYear],
        IIF(LEN(TRIM([CardType])) > 0, 1, 0) AS [IsCardTypeNotBlank],
        IIF(LEN(TRIM([CardNumber])) >= 4, 1, 0) AS [IsCardNumberUsable]
    FROM [staging].[CreditCard];

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'CreditCard Load - CardType must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[CreditCard]
    WHERE [IsCardTypeNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'CreditCard Load - CardNumber must contain at least four nonblank characters.', COUNT_BIG(*), @execution_step_id, @length_validation_code_id
    FROM [work].[CreditCard]
    WHERE [IsCardNumberUsable] = 0
    HAVING COUNT_BIG(*) > 0;

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [work].[usp_validate_Address]
    @execution_step_id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @not_null_validation_code_id SMALLINT;
    DECLARE @fk_validation_code_id SMALLINT;
    DECLARE @length_validation_code_id SMALLINT;

    SELECT @not_null_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'NOT_NULL';

    SELECT @fk_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'FK_CHECK';

    SELECT @length_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'LENGTH_CHECK';

    IF @not_null_validation_code_id IS NULL
        THROW 51001, 'Missing validation code: NOT_NULL.', 1;

    IF @fk_validation_code_id IS NULL
        THROW 51002, 'Missing validation code: FK_CHECK.', 1;

    IF @length_validation_code_id IS NULL
        THROW 51003, 'Missing validation code: LENGTH_CHECK.', 1;
    BEGIN TRANSACTION;

    INSERT INTO [work].[Address] (
        [SourceAddressID],
        [AddressLine1],
        [AddressLine2],
        [City],
        [SourceStateProvinceID],
        [PostalCode],
        [SourceAddressTypeID],
        [IsAddressLine1NotBlank],
        [IsCityNotBlank],
        [IsPostalCodeNotBlank],
        [IsStateProvinceValid],
        [IsAddressTypeValid]
    )
    SELECT
        a.[SourceAddressID],
        TRIM(a.[AddressLine1]) AS [AddressLine1],
        NULLIF(TRIM(a.[AddressLine2]), '') AS [AddressLine2],
        TRIM(a.[City]) AS [City],
        a.[SourceStateProvinceID],
        TRIM(a.[PostalCode]) AS [PostalCode],
        a.[SourceAddressTypeID],
        IIF(LEN(TRIM(a.[AddressLine1])) > 0, 1, 0) AS [IsAddressLine1NotBlank],
        IIF(LEN(TRIM(a.[City])) > 0, 1, 0) AS [IsCityNotBlank],
        IIF(LEN(TRIM(a.[PostalCode])) > 0, 1, 0) AS [IsPostalCodeNotBlank],
        IIF(sp.[StateProvinceKey] IS NOT NULL, 1, 0) AS [IsStateProvinceValid],
        IIF(a.[SourceAddressTypeID] IS NULL OR atp.[AddressTypeKey] IS NOT NULL, 1, 0) AS [IsAddressTypeValid]
    FROM [staging].[Address] AS a
    LEFT JOIN [prod].[StateProvince] AS sp
        ON sp.[SourceStateProvinceID] = a.[SourceStateProvinceID]
    LEFT JOIN [prod].[AddressType] AS atp
        ON atp.[SourceAddressTypeID] = a.[SourceAddressTypeID];

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Address Load - AddressLine1 must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[Address]
    WHERE [IsAddressLine1NotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Address Load - City must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[Address]
    WHERE [IsCityNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Address Load - PostalCode must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[Address]
    WHERE [IsPostalCodeNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Address Load - SourceStateProvinceID must reference a valid StateProvince.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[Address]
    WHERE [IsStateProvinceValid] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Address Load - SourceAddressTypeID must reference a valid AddressType when provided.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[Address]
    WHERE [IsAddressTypeValid] = 0
    HAVING COUNT_BIG(*) > 0;

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [work].[usp_validate_Product]
    @execution_step_id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @not_null_validation_code_id SMALLINT;
    DECLARE @fk_validation_code_id SMALLINT;
    DECLARE @length_validation_code_id SMALLINT;

    SELECT @not_null_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'NOT_NULL';

    SELECT @fk_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'FK_CHECK';

    SELECT @length_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'LENGTH_CHECK';

    IF @not_null_validation_code_id IS NULL
        THROW 51001, 'Missing validation code: NOT_NULL.', 1;

    IF @fk_validation_code_id IS NULL
        THROW 51002, 'Missing validation code: FK_CHECK.', 1;

    IF @length_validation_code_id IS NULL
        THROW 51003, 'Missing validation code: LENGTH_CHECK.', 1;
    BEGIN TRANSACTION;

    INSERT INTO [work].[Product] (
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
        [DiscontinuedDate],
        [IsProductNumberNotBlank],
        [IsNameNotBlank],
        [IsProductCategoryValid]
    )
    SELECT
        p.[SourceProductID],
        TRIM(p.[ProductNumber]) AS [ProductNumber],
        TRIM(p.[Name]) AS [Name],
        NULLIF(TRIM(p.[Color]), '') AS [Color],
        p.[SafetyStockLevel],
        p.[ReorderPoint],
        p.[StandardCost],
        p.[ListPrice],
        NULLIF(TRIM(p.[Size]), '') AS [Size],
        p.[Weight],
        p.[SourceProductSubcategoryID],
        p.[SellStartDate],
        p.[SellEndDate],
        p.[DiscontinuedDate],
        IIF(LEN(TRIM(p.[ProductNumber])) > 0, 1, 0) AS [IsProductNumberNotBlank],
        IIF(LEN(TRIM(p.[Name])) > 0, 1, 0) AS [IsNameNotBlank],
        IIF(p.[SourceProductSubcategoryID] IS NULL OR pc.[ProductCategoryKey] IS NOT NULL, 1, 0) AS [IsProductCategoryValid]
    FROM [staging].[Product] AS p
    LEFT JOIN [prod].[ProductCategory] AS pc
        ON pc.[SourceProductSubcategoryID] = p.[SourceProductSubcategoryID];

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Product Load - ProductNumber must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[Product]
    WHERE [IsProductNumberNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Product Load - Name must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[Product]
    WHERE [IsNameNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Product Load - SourceProductSubcategoryID must reference a valid ProductCategory when provided.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[Product]
    WHERE [IsProductCategoryValid] = 0
    HAVING COUNT_BIG(*) > 0;

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [work].[usp_validate_SalesPerson]
    @execution_step_id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @not_null_validation_code_id SMALLINT;
    DECLARE @fk_validation_code_id SMALLINT;
    DECLARE @length_validation_code_id SMALLINT;

    SELECT @not_null_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'NOT_NULL';

    SELECT @fk_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'FK_CHECK';

    SELECT @length_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'LENGTH_CHECK';

    IF @not_null_validation_code_id IS NULL
        THROW 51001, 'Missing validation code: NOT_NULL.', 1;

    IF @fk_validation_code_id IS NULL
        THROW 51002, 'Missing validation code: FK_CHECK.', 1;

    IF @length_validation_code_id IS NULL
        THROW 51003, 'Missing validation code: LENGTH_CHECK.', 1;
    BEGIN TRANSACTION;

    INSERT INTO [work].[SalesPerson] (
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
        [SalesLastYear],
        [IsFirstNameNotBlank],
        [IsLastNameNotBlank],
        [IsJobTitleNotBlank],
        [IsGenderNotBlank],
        [IsSalesTerritoryValid]
    )
    SELECT
        sp.[SourceBusinessEntityID],
        sp.[SourceTerritoryID],
        NULLIF(TRIM(sp.[Title]), '') AS [Title],
        TRIM(sp.[FirstName]) AS [FirstName],
        NULLIF(TRIM(sp.[MiddleName]), '') AS [MiddleName],
        TRIM(sp.[LastName]) AS [LastName],
        TRIM(sp.[JobTitle]) AS [JobTitle],
        TRIM(sp.[Gender]) AS [Gender],
        sp.[HireDate],
        sp.[SalesQuota],
        sp.[Bonus],
        sp.[CommissionPct],
        sp.[SalesYTD],
        sp.[SalesLastYear],
        IIF(LEN(TRIM(sp.[FirstName])) > 0, 1, 0) AS [IsFirstNameNotBlank],
        IIF(LEN(TRIM(sp.[LastName])) > 0, 1, 0) AS [IsLastNameNotBlank],
        IIF(LEN(TRIM(sp.[JobTitle])) > 0, 1, 0) AS [IsJobTitleNotBlank],
        IIF(LEN(TRIM(sp.[Gender])) > 0, 1, 0) AS [IsGenderNotBlank],
        IIF(sp.[SourceTerritoryID] IS NULL OR st.[SalesTerritoryKey] IS NOT NULL, 1, 0) AS [IsSalesTerritoryValid]
    FROM [staging].[SalesPerson] AS sp
    LEFT JOIN [prod].[SalesTerritory] AS st
        ON st.[SourceTerritoryID] = sp.[SourceTerritoryID];

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'SalesPerson Load - FirstName must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[SalesPerson]
    WHERE [IsFirstNameNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'SalesPerson Load - LastName must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[SalesPerson]
    WHERE [IsLastNameNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'SalesPerson Load - JobTitle must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[SalesPerson]
    WHERE [IsJobTitleNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'SalesPerson Load - Gender must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[SalesPerson]
    WHERE [IsGenderNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'SalesPerson Load - SourceTerritoryID must reference a valid SalesTerritory when provided.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[SalesPerson]
    WHERE [IsSalesTerritoryValid] = 0
    HAVING COUNT_BIG(*) > 0;

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [work].[usp_validate_Customer]
    @execution_step_id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @not_null_validation_code_id SMALLINT;
    DECLARE @fk_validation_code_id SMALLINT;
    DECLARE @length_validation_code_id SMALLINT;

    SELECT @not_null_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'NOT_NULL';

    SELECT @fk_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'FK_CHECK';

    SELECT @length_validation_code_id = [id]
    FROM [control].[validation_codes]
    WHERE [code] = 'LENGTH_CHECK';

    IF @not_null_validation_code_id IS NULL
        THROW 51001, 'Missing validation code: NOT_NULL.', 1;

    IF @fk_validation_code_id IS NULL
        THROW 51002, 'Missing validation code: FK_CHECK.', 1;

    IF @length_validation_code_id IS NULL
        THROW 51003, 'Missing validation code: LENGTH_CHECK.', 1;
    BEGIN TRANSACTION;

    INSERT INTO [work].[Customer] (
        [SourceCustomerID],
        [SourcePersonID],
        [SourceTerritoryID],
        [PersonType],
        [Title],
        [FirstName],
        [MiddleName],
        [LastName],
        [AccountNumber],
        [IsPersonNameValid],
        [IsSalesTerritoryValid]
    )
    SELECT
        c.[SourceCustomerID],
        c.[SourcePersonID],
        c.[SourceTerritoryID],
        NULLIF(TRIM(c.[PersonType]), '') AS [PersonType],
        NULLIF(TRIM(c.[Title]), '') AS [Title],
        NULLIF(TRIM(c.[FirstName]), '') AS [FirstName],
        NULLIF(TRIM(c.[MiddleName]), '') AS [MiddleName],
        NULLIF(TRIM(c.[LastName]), '') AS [LastName],
        NULLIF(TRIM(c.[AccountNumber]), '') AS [AccountNumber],
        IIF(c.[SourcePersonID] IS NULL OR (LEN(TRIM(c.[FirstName])) > 0 AND LEN(TRIM(c.[LastName])) > 0), 1, 0) AS [IsPersonNameValid],
        IIF(c.[SourceTerritoryID] IS NULL OR st.[SalesTerritoryKey] IS NOT NULL, 1, 0) AS [IsSalesTerritoryValid]
    FROM [staging].[Customer] AS c
    LEFT JOIN [prod].[SalesTerritory] AS st
        ON st.[SourceTerritoryID] = c.[SourceTerritoryID];

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Customer Load - FirstName and LastName must not be blank when SourcePersonID is provided.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[Customer]
    WHERE [IsPersonNameValid] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Customer Load - SourceTerritoryID must reference a valid SalesTerritory when provided.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[Customer]
    WHERE [IsSalesTerritoryValid] = 0
    HAVING COUNT_BIG(*) > 0;

    COMMIT TRANSACTION;
END;
GO




