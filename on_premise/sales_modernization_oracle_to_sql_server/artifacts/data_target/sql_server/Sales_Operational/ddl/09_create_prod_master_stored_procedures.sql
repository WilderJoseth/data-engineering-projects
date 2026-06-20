/*
    Script name
        09_create_prod_master_stored_procedures.sql

    Purpose
        Creates prod-schema load stored procedures for master data load processes.
*/

USE [Sales_Operational];
GO

CREATE OR ALTER PROCEDURE [prod].[usp_load_CreditCard]
    @execution_step_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    UPDATE tgt
    SET
        tgt.[CardType] = src.[CardType],
        tgt.[CardNumber] = src.[CardNumber],
        tgt.[ExpMonth] = src.[ExpMonth],
        tgt.[ExpYear] = src.[ExpYear],
        tgt.[updated_at] = SYSUTCDATETIME(),
        tgt.[updated_by] = USER_NAME(),
        tgt.[last_updated_execution_step_id] = @execution_step_id,
        tgt.[is_active] = 1
    FROM [prod].[CreditCard] AS tgt
    INNER JOIN [work].[CreditCard] AS src
        ON src.[SourceCreditCardID] = tgt.[SourceCreditCardID]
    WHERE src.[IsCardTypeNotBlank] = 1
      AND src.[IsCardNumberUsable] = 1;

    INSERT INTO [prod].[CreditCard] (
        [SourceCreditCardID],
        [CardType],
        [CardNumber],
        [ExpMonth],
        [ExpYear],
        [created_execution_step_id]
    )
    SELECT
        src.[SourceCreditCardID],
        src.[CardType],
        src.[CardNumber],
        src.[ExpMonth],
        src.[ExpYear],
        @execution_step_id
    FROM [work].[CreditCard] AS src
    WHERE src.[IsCardTypeNotBlank] = 1
      AND src.[IsCardNumberUsable] = 1
      AND NOT EXISTS (
            SELECT 1
            FROM [prod].[CreditCard] AS tgt
            WHERE tgt.[SourceCreditCardID] = src.[SourceCreditCardID]
        );

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [prod].[usp_load_Address]
    @execution_step_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    UPDATE tgt
    SET
        tgt.[AddressLine1] = src.[AddressLine1],
        tgt.[AddressLine2] = src.[AddressLine2],
        tgt.[City] = src.[City],
        tgt.[StateProvinceKey] = state_province.[StateProvinceKey],
        tgt.[PostalCode] = src.[PostalCode],
        tgt.[AddressTypeKey] = address_type.[AddressTypeKey],
        tgt.[updated_at] = SYSUTCDATETIME(),
        tgt.[updated_by] = USER_NAME(),
        tgt.[last_updated_execution_step_id] = @execution_step_id,
        tgt.[is_active] = 1
    FROM [prod].[Address] AS tgt
    INNER JOIN [work].[Address] AS src
        ON src.[SourceAddressID] = tgt.[SourceAddressID]
    INNER JOIN [prod].[StateProvince] AS state_province
        ON state_province.[SourceStateProvinceID] = src.[SourceStateProvinceID]
    LEFT JOIN [prod].[AddressType] AS address_type
        ON address_type.[SourceAddressTypeID] = src.[SourceAddressTypeID]
    WHERE src.[IsAddressLine1NotBlank] = 1
      AND src.[IsCityNotBlank] = 1
      AND src.[IsPostalCodeNotBlank] = 1
      AND src.[IsStateProvinceValid] = 1
      AND src.[IsAddressTypeValid] = 1;

    INSERT INTO [prod].[Address] (
        [SourceAddressID],
        [AddressLine1],
        [AddressLine2],
        [City],
        [StateProvinceKey],
        [PostalCode],
        [AddressTypeKey],
        [created_execution_step_id]
    )
    SELECT
        src.[SourceAddressID],
        src.[AddressLine1],
        src.[AddressLine2],
        src.[City],
        state_province.[StateProvinceKey],
        src.[PostalCode],
        address_type.[AddressTypeKey],
        @execution_step_id
    FROM [work].[Address] AS src
    INNER JOIN [prod].[StateProvince] AS state_province
        ON state_province.[SourceStateProvinceID] = src.[SourceStateProvinceID]
    LEFT JOIN [prod].[AddressType] AS address_type
        ON address_type.[SourceAddressTypeID] = src.[SourceAddressTypeID]
    WHERE src.[IsAddressLine1NotBlank] = 1
      AND src.[IsCityNotBlank] = 1
      AND src.[IsPostalCodeNotBlank] = 1
      AND src.[IsStateProvinceValid] = 1
      AND src.[IsAddressTypeValid] = 1
      AND NOT EXISTS (
            SELECT 1
            FROM [prod].[Address] AS tgt
            WHERE tgt.[SourceAddressID] = src.[SourceAddressID]
        );

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [prod].[usp_load_Product]
    @execution_step_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    UPDATE tgt
    SET
        tgt.[ProductNumber] = src.[ProductNumber],
        tgt.[Name] = src.[Name],
        tgt.[Color] = src.[Color],
        tgt.[SafetyStockLevel] = src.[SafetyStockLevel],
        tgt.[ReorderPoint] = src.[ReorderPoint],
        tgt.[StandardCost] = src.[StandardCost],
        tgt.[ListPrice] = src.[ListPrice],
        tgt.[Size] = src.[Size],
        tgt.[Weight] = src.[Weight],
        tgt.[ProductCategoryKey] = product_category.[ProductCategoryKey],
        tgt.[SellStartDate] = src.[SellStartDate],
        tgt.[SellEndDate] = src.[SellEndDate],
        tgt.[DiscontinuedDate] = src.[DiscontinuedDate],
        tgt.[updated_at] = SYSUTCDATETIME(),
        tgt.[updated_by] = USER_NAME(),
        tgt.[last_updated_execution_step_id] = @execution_step_id,
        tgt.[is_active] = 1
    FROM [prod].[Product] AS tgt
    INNER JOIN [work].[Product] AS src
        ON src.[SourceProductID] = tgt.[SourceProductID]
    LEFT JOIN [prod].[ProductCategory] AS product_category
        ON product_category.[SourceProductCategoryID] = src.[SourceProductCategoryID]
    WHERE src.[IsProductNumberNotBlank] = 1
      AND src.[IsNameNotBlank] = 1
      AND src.[IsProductCategoryValid] = 1;

    INSERT INTO [prod].[Product] (
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
        [ProductCategoryKey],
        [SellStartDate],
        [SellEndDate],
        [DiscontinuedDate],
        [created_execution_step_id]
    )
    SELECT
        src.[SourceProductID],
        src.[ProductNumber],
        src.[Name],
        src.[Color],
        src.[SafetyStockLevel],
        src.[ReorderPoint],
        src.[StandardCost],
        src.[ListPrice],
        src.[Size],
        src.[Weight],
        product_category.[ProductCategoryKey],
        src.[SellStartDate],
        src.[SellEndDate],
        src.[DiscontinuedDate],
        @execution_step_id
    FROM [work].[Product] AS src
    LEFT JOIN [prod].[ProductCategory] AS product_category
        ON product_category.[SourceProductCategoryID] = src.[SourceProductCategoryID]
    WHERE src.[IsProductNumberNotBlank] = 1
      AND src.[IsNameNotBlank] = 1
      AND src.[IsProductCategoryValid] = 1
      AND NOT EXISTS (
            SELECT 1
            FROM [prod].[Product] AS tgt
            WHERE tgt.[SourceProductID] = src.[SourceProductID]
        );

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [prod].[usp_load_SalesPerson]
    @execution_step_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    UPDATE tgt
    SET
        tgt.[SalesTerritoryKey] = sales_territory.[SalesTerritoryKey],
        tgt.[Title] = src.[Title],
        tgt.[FirstName] = src.[FirstName],
        tgt.[MiddleName] = src.[MiddleName],
        tgt.[LastName] = src.[LastName],
        tgt.[JobTitle] = src.[JobTitle],
        tgt.[Gender] = src.[Gender],
        tgt.[HireDate] = src.[HireDate],
        tgt.[SalesQuota] = src.[SalesQuota],
        tgt.[Bonus] = src.[Bonus],
        tgt.[CommissionPct] = src.[CommissionPct],
        tgt.[SalesYTD] = src.[SalesYTD],
        tgt.[SalesLastYear] = src.[SalesLastYear],
        tgt.[updated_at] = SYSUTCDATETIME(),
        tgt.[updated_by] = USER_NAME(),
        tgt.[last_updated_execution_step_id] = @execution_step_id,
        tgt.[is_active] = 1
    FROM [prod].[SalesPerson] AS tgt
    INNER JOIN [work].[SalesPerson] AS src
        ON src.[SourceSalesPersonID] = tgt.[SourceSalesPersonID]
    LEFT JOIN [prod].[SalesTerritory] AS sales_territory
        ON sales_territory.[SourceTerritoryID] = src.[SourceTerritoryID]
    WHERE src.[IsFirstNameNotBlank] = 1
      AND src.[IsLastNameNotBlank] = 1
      AND src.[IsJobTitleNotBlank] = 1
      AND src.[IsGenderNotBlank] = 1
      AND src.[IsSalesTerritoryValid] = 1;

    INSERT INTO [prod].[SalesPerson] (
        [SourceSalesPersonID],
        [SalesTerritoryKey],
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
        [created_execution_step_id]
    )
    SELECT
        src.[SourceSalesPersonID],
        sales_territory.[SalesTerritoryKey],
        src.[Title],
        src.[FirstName],
        src.[MiddleName],
        src.[LastName],
        src.[JobTitle],
        src.[Gender],
        src.[HireDate],
        src.[SalesQuota],
        src.[Bonus],
        src.[CommissionPct],
        src.[SalesYTD],
        src.[SalesLastYear],
        @execution_step_id
    FROM [work].[SalesPerson] AS src
    LEFT JOIN [prod].[SalesTerritory] AS sales_territory
        ON sales_territory.[SourceTerritoryID] = src.[SourceTerritoryID]
    WHERE src.[IsFirstNameNotBlank] = 1
      AND src.[IsLastNameNotBlank] = 1
      AND src.[IsJobTitleNotBlank] = 1
      AND src.[IsGenderNotBlank] = 1
      AND src.[IsSalesTerritoryValid] = 1
      AND NOT EXISTS (
            SELECT 1
            FROM [prod].[SalesPerson] AS tgt
            WHERE tgt.[SourceSalesPersonID] = src.[SourceSalesPersonID]
        );

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [prod].[usp_load_Customer]
    @execution_step_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    UPDATE tgt
    SET
        tgt.[SalesTerritoryKey] = sales_territory.[SalesTerritoryKey],
        tgt.[PersonType] = src.[PersonType],
        tgt.[Title] = src.[Title],
        tgt.[FirstName] = src.[FirstName],
        tgt.[MiddleName] = src.[MiddleName],
        tgt.[LastName] = src.[LastName],
        tgt.[AccountNumber] = src.[AccountNumber],
        tgt.[updated_at] = SYSUTCDATETIME(),
        tgt.[updated_by] = USER_NAME(),
        tgt.[last_updated_execution_step_id] = @execution_step_id,
        tgt.[is_active] = 1
    FROM [prod].[Customer] AS tgt
    INNER JOIN [work].[Customer] AS src
        ON src.[SourceCustomerID] = tgt.[SourceCustomerID]
    LEFT JOIN [prod].[SalesTerritory] AS sales_territory
        ON sales_territory.[SourceTerritoryID] = src.[SourceTerritoryID]
    WHERE src.[IsPersonNameValid] = 1
      AND src.[IsSalesTerritoryValid] = 1;

    INSERT INTO [prod].[Customer] (
        [SourceCustomerID],
        [SalesTerritoryKey],
        [PersonType],
        [Title],
        [FirstName],
        [MiddleName],
        [LastName],
        [AccountNumber],
        [created_execution_step_id]
    )
    SELECT
        src.[SourceCustomerID],
        sales_territory.[SalesTerritoryKey],
        src.[PersonType],
        src.[Title],
        src.[FirstName],
        src.[MiddleName],
        src.[LastName],
        src.[AccountNumber],
        @execution_step_id
    FROM [work].[Customer] AS src
    LEFT JOIN [prod].[SalesTerritory] AS sales_territory
        ON sales_territory.[SourceTerritoryID] = src.[SourceTerritoryID]
    WHERE src.[IsPersonNameValid] = 1
      AND src.[IsSalesTerritoryValid] = 1
      AND NOT EXISTS (
            SELECT 1
            FROM [prod].[Customer] AS tgt
            WHERE tgt.[SourceCustomerID] = src.[SourceCustomerID]
        );

    COMMIT TRANSACTION;
END;
GO



