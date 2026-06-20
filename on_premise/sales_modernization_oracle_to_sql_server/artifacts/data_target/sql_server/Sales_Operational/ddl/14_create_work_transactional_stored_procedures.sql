/*
    Script name
        14_create_work_transactional_stored_procedures.sql

    Purpose
        Creates work-schema cleanup and validation procedures for transactional load processes.

    Scope
        Transactional validation procedures process related staging tables as one business unit when required.
*/

USE [Sales_Operational];
GO

CREATE OR ALTER PROCEDURE [control].[usp_cleanup_SalesOrder]
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    TRUNCATE TABLE [work].[SalesOrderDetail];
    TRUNCATE TABLE [work].[SalesOrderHeader];

    TRUNCATE TABLE [staging].[SalesOrderDetail];
    TRUNCATE TABLE [staging].[SalesOrderHeader];

    COMMIT TRANSACTION;
END;
GO

CREATE OR ALTER PROCEDURE [work].[usp_validate_SalesOrder]
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

    INSERT INTO [work].[SalesOrderHeader] (
        [SourceSalesOrderID],
        [RevisionNumber],
        [OrderDate],
        [DueDate],
        [ShipDate],
        [Status],
        [SalesOrderNumber],
        [PurchaseOrderNumber],
        [AccountNumber],
        [CustomerKey],
        [SalesPersonKey],
        [SalesTerritoryKey],
        [BillToAddressKey],
        [ShipToAddressKey],
        [ShipMethodKey],
        [CreditCardKey],
        [CurrencyRateKey],
        [SubTotal],
        [TaxAmt],
        [Freight],
        [TotalDue],
        [Comment],
        [IsSalesOrderNumberNotBlank],
        [IsCustomerValid],
        [IsSalesPersonValid],
        [IsSalesTerritoryValid],
        [IsBillToAddressValid],
        [IsShipToAddressValid],
        [IsShipMethodValid],
        [IsCreditCardValid],
        [IsCurrencyRateValid]
    )
    SELECT
        source_header.[SourceSalesOrderID],
        source_header.[RevisionNumber],
        source_header.[OrderDate],
        source_header.[DueDate],
        source_header.[ShipDate],
        source_header.[Status],
        TRIM(source_header.[SalesOrderNumber]) AS [SalesOrderNumber],
        NULLIF(TRIM(source_header.[PurchaseOrderNumber]), '') AS [PurchaseOrderNumber],
        NULLIF(TRIM(source_header.[AccountNumber]), '') AS [AccountNumber],
        customer.[CustomerKey],
        sales_person.[SalesPersonKey],
        sales_territory.[SalesTerritoryKey],
        bill_to_address.[AddressKey] AS [BillToAddressKey],
        ship_to_address.[AddressKey] AS [ShipToAddressKey],
        ship_method.[ShipMethodKey],
        credit_card.[CreditCardKey],
        currency_rate.[CurrencyRateKey],
        source_header.[SubTotal],
        source_header.[TaxAmt],
        source_header.[Freight],
        source_header.[TotalDue],
        NULLIF(TRIM(source_header.[Comment]), '') AS [Comment],
        IIF(LEN(TRIM(source_header.[SalesOrderNumber])) > 0, 1, 0) AS [IsSalesOrderNumberNotBlank],
        IIF(customer.[CustomerKey] IS NOT NULL, 1, 0) AS [IsCustomerValid],
        IIF(source_header.[SourceSalesPersonID] IS NULL OR sales_person.[SalesPersonKey] IS NOT NULL, 1, 0) AS [IsSalesPersonValid],
        IIF(source_header.[SourceTerritoryID] IS NULL OR sales_territory.[SalesTerritoryKey] IS NOT NULL, 1, 0) AS [IsSalesTerritoryValid],
        IIF(bill_to_address.[AddressKey] IS NOT NULL, 1, 0) AS [IsBillToAddressValid],
        IIF(ship_to_address.[AddressKey] IS NOT NULL, 1, 0) AS [IsShipToAddressValid],
        IIF(ship_method.[ShipMethodKey] IS NOT NULL, 1, 0) AS [IsShipMethodValid],
        IIF(source_header.[SourceCreditCardID] IS NULL OR credit_card.[CreditCardKey] IS NOT NULL, 1, 0) AS [IsCreditCardValid],
        IIF(source_header.[SourceCurrencyRateID] IS NULL OR currency_rate.[CurrencyRateKey] IS NOT NULL, 1, 0) AS [IsCurrencyRateValid]
    FROM [staging].[SalesOrderHeader] AS source_header
    LEFT JOIN [prod].[Customer] AS customer
        ON customer.[SourceCustomerID] = source_header.[SourceCustomerID]
    LEFT JOIN [prod].[SalesPerson] AS sales_person
        ON sales_person.[SourceSalesPersonID] = source_header.[SourceSalesPersonID]
    LEFT JOIN [prod].[SalesTerritory] AS sales_territory
        ON sales_territory.[SourceTerritoryID] = source_header.[SourceTerritoryID]
    LEFT JOIN [prod].[Address] AS bill_to_address
        ON bill_to_address.[SourceAddressID] = source_header.[SourceBillToAddressID]
    LEFT JOIN [prod].[Address] AS ship_to_address
        ON ship_to_address.[SourceAddressID] = source_header.[SourceShipToAddressID]
    LEFT JOIN [prod].[ShipMethod] AS ship_method
        ON ship_method.[SourceShipMethodID] = source_header.[SourceShipMethodID]
    LEFT JOIN [prod].[CreditCard] AS credit_card
        ON credit_card.[SourceCreditCardID] = source_header.[SourceCreditCardID]
    LEFT JOIN [prod].[CurrencyRate] AS currency_rate
        ON currency_rate.[SourceCurrencyRateID] = source_header.[SourceCurrencyRateID];

    INSERT INTO [work].[SalesOrderDetail] (
        [SourceSalesOrderID],
        [SourceSalesOrderDetailID],
        [SalesOrderHeaderKey],
        [ProductKey],
        [SpecialOfferKey],
        [CarrierTrackingNumber],
        [OrderQty],
        [UnitPrice],
        [UnitPriceDiscount],
        [LineTotal],
        [IsSalesOrderHeaderValid],
        [IsProductValid],
        [IsSpecialOfferValid]
    )
    SELECT
        source_detail.[SourceSalesOrderID],
        source_detail.[SourceSalesOrderDetailID],
        sales_order_header.[SalesOrderHeaderKey],
        product.[ProductKey],
        special_offer.[SpecialOfferKey],
        NULLIF(TRIM(source_detail.[CarrierTrackingNumber]), '') AS [CarrierTrackingNumber],
        source_detail.[OrderQty],
        source_detail.[UnitPrice],
        source_detail.[UnitPriceDiscount],
        source_detail.[LineTotal],
        IIF(work_header.[SourceSalesOrderID] IS NOT NULL
            AND work_header.[IsSalesOrderNumberNotBlank] = 1
            AND work_header.[IsCustomerValid] = 1
            AND work_header.[IsSalesPersonValid] = 1
            AND work_header.[IsSalesTerritoryValid] = 1
            AND work_header.[IsBillToAddressValid] = 1
            AND work_header.[IsShipToAddressValid] = 1
            AND work_header.[IsShipMethodValid] = 1
            AND work_header.[IsCreditCardValid] = 1
            AND work_header.[IsCurrencyRateValid] = 1, 1, 0) AS [IsSalesOrderHeaderValid],
        IIF(product.[ProductKey] IS NOT NULL, 1, 0) AS [IsProductValid],
        IIF(special_offer.[SpecialOfferKey] IS NOT NULL, 1, 0) AS [IsSpecialOfferValid]
    FROM [staging].[SalesOrderDetail] AS source_detail
    LEFT JOIN [work].[SalesOrderHeader] AS work_header
        ON work_header.[SourceSalesOrderID] = source_detail.[SourceSalesOrderID]
    LEFT JOIN [prod].[SalesOrderHeader] AS sales_order_header
        ON sales_order_header.[SourceSalesOrderID] = source_detail.[SourceSalesOrderID]
    LEFT JOIN [prod].[Product] AS product
        ON product.[SourceProductID] = source_detail.[SourceProductID]
    LEFT JOIN [prod].[SpecialOffer] AS special_offer
        ON special_offer.[SourceSpecialOfferID] = source_detail.[SourceSpecialOfferID];

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'SalesOrder Load - SalesOrderNumber must not be blank after trimming.', COUNT_BIG(*), @execution_step_id, @not_null_validation_code_id
    FROM [work].[SalesOrderHeader]
    WHERE [IsSalesOrderNumberNotBlank] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'SalesOrder Load - SourceCustomerID must reference a valid Customer.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[SalesOrderHeader]
    WHERE [IsCustomerValid] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'SalesOrder Load - SourceSalesPersonID must reference a valid SalesPerson when provided.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[SalesOrderHeader]
    WHERE [IsSalesPersonValid] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'SalesOrder Load - SourceTerritoryID must reference a valid SalesTerritory when provided.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[SalesOrderHeader]
    WHERE [IsSalesTerritoryValid] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'SalesOrder Load - SourceBillToAddressID must reference a valid Address.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[SalesOrderHeader]
    WHERE [IsBillToAddressValid] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'SalesOrder Load - SourceShipToAddressID must reference a valid Address.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[SalesOrderHeader]
    WHERE [IsShipToAddressValid] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'SalesOrder Load - SourceShipMethodID must reference a valid ShipMethod.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[SalesOrderHeader]
    WHERE [IsShipMethodValid] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'SalesOrder Load - SourceCreditCardID must reference a valid CreditCard when provided.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[SalesOrderHeader]
    WHERE [IsCreditCardValid] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'SalesOrder Load - SourceCurrencyRateID must reference a valid CurrencyRate when provided.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[SalesOrderHeader]
    WHERE [IsCurrencyRateValid] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'SalesOrder Load - SourceSalesOrderID must reference a valid SalesOrderHeader.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[SalesOrderDetail]
    WHERE [IsSalesOrderHeaderValid] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'SalesOrder Load - SourceProductID must reference a valid Product.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[SalesOrderDetail]
    WHERE [IsProductValid] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] ([details], [affected_row_count], [execution_step_id], [validation_code_id])
    SELECT 'SalesOrder Load - SourceSpecialOfferID must reference a valid SpecialOffer.', COUNT_BIG(*), @execution_step_id, @fk_validation_code_id
    FROM [work].[SalesOrderDetail]
    WHERE [IsSpecialOfferValid] = 0
    HAVING COUNT_BIG(*) > 0;

    COMMIT TRANSACTION;
END;
GO
