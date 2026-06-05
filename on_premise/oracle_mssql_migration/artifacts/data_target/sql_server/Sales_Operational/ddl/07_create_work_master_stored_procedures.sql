/*
    Script name
        07_create_work_master_stored_procedures.sql

    Purpose
        Creates work-schema validation stored procedures for master data load processes.
*/

USE [Sales_Operational];
GO

CREATE OR ALTER PROCEDURE [control].[usp_cleanup_CreditCard]
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    TRUNCATE TABLE [work].[CreditCard];
    TRUNCATE TABLE [staging].[CreditCard];

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [control].[usp_cleanup_Address]
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    TRUNCATE TABLE [work].[Address];
    TRUNCATE TABLE [staging].[Address];

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [control].[usp_cleanup_Product]
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    TRUNCATE TABLE [work].[Product];
    TRUNCATE TABLE [staging].[Product];

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [control].[usp_cleanup_Employee]
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    TRUNCATE TABLE [work].[Employee];
    DELETE p
    FROM [staging].[Person] AS p
    WHERE EXISTS (
        SELECT 1
        FROM [staging].[SalesPerson] AS sp
        WHERE sp.[SourceBusinessEntityID] = p.[SourceBusinessEntityID]
    );
    TRUNCATE TABLE [staging].[SalesPerson];
    TRUNCATE TABLE [staging].[Employee];

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [control].[usp_cleanup_Customer]
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    TRUNCATE TABLE [work].[Customer];
    DELETE p
    FROM [staging].[Person] AS p
    WHERE EXISTS (
        SELECT 1
        FROM [staging].[Customer] AS c
        WHERE c.[SourcePersonID] = p.[SourceBusinessEntityID]
    );
    TRUNCATE TABLE [staging].[Customer];

    COMMIT TRANSACTION;
END;
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

CREATE OR ALTER PROCEDURE [work].[usp_validate_Employee]
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

    INSERT INTO [work].[Employee] (
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
        NULLIF(TRIM(p.[Title]), '') AS [Title],
        TRIM(p.[FirstName]) AS [FirstName],
        NULLIF(TRIM(p.[MiddleName]), '') AS [MiddleName],
        TRIM(p.[LastName]) AS [LastName],
        TRIM(e.[JobTitle]) AS [JobTitle],
        TRIM(e.[Gender]) AS [Gender],
        e.[HireDate],
        sp.[SalesQuota],
        sp.[Bonus],
        sp.[CommissionPct],
        sp.[SalesYTD],
        sp.[SalesLastYear],
        IIF(LEN(TRIM(p.[FirstName])) > 0, 1, 0) AS [IsFirstNameNotBlank],
        IIF(LEN(TRIM(p.[LastName])) > 0, 1, 0) AS [IsLastNameNotBlank],
        IIF(LEN(TRIM(e.[JobTitle])) > 0, 1, 0) AS [IsJobTitleNotBlank],
        IIF(LEN(TRIM(e.[Gender])) > 0, 1, 0) AS [IsGenderNotBlank],
        IIF(sp.[SourceTerritoryID] IS NULL OR st.[SalesTerritoryKey] IS NOT NULL, 1, 0) AS [IsSalesTerritoryValid]
    FROM [staging].[SalesPerson] AS sp
    INNER JOIN [staging].[Person] AS p
        ON p.[SourceBusinessEntityID] = sp.[SourceBusinessEntityID]
    INNER JOIN [staging].[Employee] AS e
        ON e.[SourceBusinessEntityID] = sp.[SourceBusinessEntityID]
    LEFT JOIN [prod].[SalesTerritory] AS st
        ON st.[SourceTerritoryID] = sp.[SourceTerritoryID];

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Employee Load - FirstName must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[Employee]
    WHERE [IsFirstNameNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Employee Load - LastName must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[Employee]
    WHERE [IsLastNameNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Employee Load - JobTitle must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[Employee]
    WHERE [IsJobTitleNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Employee Load - Gender must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[Employee]
    WHERE [IsGenderNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Employee Load - SourceTerritoryID must reference a valid SalesTerritory when provided.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[Employee]
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
        NULLIF(TRIM(p.[PersonType]), '') AS [PersonType],
        NULLIF(TRIM(p.[Title]), '') AS [Title],
        NULLIF(TRIM(p.[FirstName]), '') AS [FirstName],
        NULLIF(TRIM(p.[MiddleName]), '') AS [MiddleName],
        NULLIF(TRIM(p.[LastName]), '') AS [LastName],
        NULLIF(TRIM(c.[AccountNumber]), '') AS [AccountNumber],
        IIF(c.[SourcePersonID] IS NULL OR (p.[SourceBusinessEntityID] IS NOT NULL AND LEN(TRIM(p.[FirstName])) > 0 AND LEN(TRIM(p.[LastName])) > 0), 1, 0) AS [IsPersonNameValid],
        IIF(c.[SourceTerritoryID] IS NULL OR st.[SalesTerritoryKey] IS NOT NULL, 1, 0) AS [IsSalesTerritoryValid]
    FROM [staging].[Customer] AS c
    LEFT JOIN [staging].[Person] AS p
        ON p.[SourceBusinessEntityID] = c.[SourcePersonID]
    LEFT JOIN [prod].[SalesTerritory] AS st
        ON st.[SourceTerritoryID] = c.[SourceTerritoryID];

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'Customer Load - SourcePersonID must reference a person with nonblank FirstName and LastName when provided.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
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




