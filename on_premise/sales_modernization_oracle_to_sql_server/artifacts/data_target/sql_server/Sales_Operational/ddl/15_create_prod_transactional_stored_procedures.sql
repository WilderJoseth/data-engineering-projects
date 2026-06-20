/*
    Script name
        15_create_prod_transactional_stored_procedures.sql

    Purpose
        Creates prod-schema load procedures for transactional load processes.

    Scope
        Transactional load procedures upsert only validated work rows into prod tables.
*/

USE [Sales_Operational];
GO

CREATE OR ALTER PROCEDURE [prod].[usp_load_SalesOrder]
    @execution_step_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    DELETE detail_target
    FROM [prod].[SalesOrderDetail] AS detail_target
    INNER JOIN [work].[SalesOrderHeader] AS header_source
        ON header_source.[SourceSalesOrderID] = detail_target.[SourceSalesOrderID]
    WHERE header_source.[IsSalesOrderNumberNotBlank] = 1
      AND header_source.[IsCustomerValid] = 1
      AND header_source.[IsSalesPersonValid] = 1
      AND header_source.[IsSalesTerritoryValid] = 1
      AND header_source.[IsBillToAddressValid] = 1
      AND header_source.[IsShipToAddressValid] = 1
      AND header_source.[IsShipMethodValid] = 1
      AND header_source.[IsCreditCardValid] = 1
      AND header_source.[IsCurrencyRateValid] = 1;

    DELETE header_target
    FROM [prod].[SalesOrderHeader] AS header_target
    INNER JOIN [work].[SalesOrderHeader] AS header_source
        ON header_source.[SourceSalesOrderID] = header_target.[SourceSalesOrderID]
    WHERE header_source.[IsSalesOrderNumberNotBlank] = 1
      AND header_source.[IsCustomerValid] = 1
      AND header_source.[IsSalesPersonValid] = 1
      AND header_source.[IsSalesTerritoryValid] = 1
      AND header_source.[IsBillToAddressValid] = 1
      AND header_source.[IsShipToAddressValid] = 1
      AND header_source.[IsShipMethodValid] = 1
      AND header_source.[IsCreditCardValid] = 1
      AND header_source.[IsCurrencyRateValid] = 1;

    INSERT INTO [prod].[SalesOrderHeader] (
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
        [created_execution_step_id]
    )
    SELECT
        header_source.[SourceSalesOrderID],
        header_source.[RevisionNumber],
        header_source.[OrderDate],
        header_source.[DueDate],
        header_source.[ShipDate],
        header_source.[Status],
        header_source.[SalesOrderNumber],
        header_source.[PurchaseOrderNumber],
        header_source.[AccountNumber],
        header_source.[CustomerKey],
        header_source.[SalesPersonKey],
        header_source.[SalesTerritoryKey],
        header_source.[BillToAddressKey],
        header_source.[ShipToAddressKey],
        header_source.[ShipMethodKey],
        header_source.[CreditCardKey],
        header_source.[CurrencyRateKey],
        header_source.[SubTotal],
        header_source.[TaxAmt],
        header_source.[Freight],
        header_source.[TotalDue],
        header_source.[Comment],
        @execution_step_id
    FROM [work].[SalesOrderHeader] AS header_source
    WHERE header_source.[IsSalesOrderNumberNotBlank] = 1
      AND header_source.[IsCustomerValid] = 1
      AND header_source.[IsSalesPersonValid] = 1
      AND header_source.[IsSalesTerritoryValid] = 1
      AND header_source.[IsBillToAddressValid] = 1
      AND header_source.[IsShipToAddressValid] = 1
      AND header_source.[IsShipMethodValid] = 1
      AND header_source.[IsCreditCardValid] = 1
      AND header_source.[IsCurrencyRateValid] = 1;

    INSERT INTO [prod].[SalesOrderDetail] (
        [SalesOrderHeaderKey],
        [SourceSalesOrderID],
        [SourceSalesOrderDetailID],
        [ProductKey],
        [SpecialOfferKey],
        [CarrierTrackingNumber],
        [OrderQty],
        [UnitPrice],
        [UnitPriceDiscount],
        [LineTotal],
        [created_execution_step_id]
    )
    SELECT
        header_target.[SalesOrderHeaderKey],
        detail_source.[SourceSalesOrderID],
        detail_source.[SourceSalesOrderDetailID],
        detail_source.[ProductKey],
        detail_source.[SpecialOfferKey],
        detail_source.[CarrierTrackingNumber],
        detail_source.[OrderQty],
        detail_source.[UnitPrice],
        detail_source.[UnitPriceDiscount],
        detail_source.[LineTotal],
        @execution_step_id
    FROM [work].[SalesOrderDetail] AS detail_source
    INNER JOIN [prod].[SalesOrderHeader] AS header_target
        ON header_target.[SourceSalesOrderID] = detail_source.[SourceSalesOrderID]
    WHERE detail_source.[IsSalesOrderHeaderValid] = 1
      AND detail_source.[IsProductValid] = 1
      AND detail_source.[IsSpecialOfferValid] = 1;

    COMMIT TRANSACTION;
END;
GO
