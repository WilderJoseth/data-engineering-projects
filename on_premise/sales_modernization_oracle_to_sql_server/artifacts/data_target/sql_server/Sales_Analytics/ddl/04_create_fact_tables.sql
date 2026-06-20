/*
    Script name
        03_create_fact_tables.sql

    Purpose
        Creates the fact tables for the analytical star schema used by Sales
        reporting.

    Design rules
        - FactSales is line-grain: one row per sales order detail line.
        - Source identifiers are retained where useful for lineage.
        - Operational and source technical columns are excluded.
        - Final tables include standard audit columns from the solution design.
        - created_run_id must be supplied by the migration process.
*/

USE [Sales_Analytics];
GO

CREATE TABLE [fact].[FactSales] (
    [FactSalesKey] BIGINT IDENTITY(1,1) NOT NULL,
    [SourceSalesOrderID] INT NOT NULL,
    [SourceSalesOrderDetailID] INT NOT NULL,
    [OrderDateKey] INT NOT NULL,
    [DueDateKey] INT NOT NULL,
    [ShipDateKey] INT NOT NULL,
    [DimCustomerKey] INT NOT NULL,
    [DimSalesPersonKey] INT NOT NULL,
    [DimSalesTerritoryKey] INT NOT NULL,
    [DimProductKey] INT NOT NULL,
    [DimPaymentMethodKey] INT NOT NULL,
    [DimShipMethodKey] INT NOT NULL,
    [OrderQty] SMALLINT NOT NULL,
    [UnitPrice] DECIMAL(19,4) NOT NULL,
    [UnitPriceDiscount] DECIMAL(19,4) NOT NULL,
    [LineTotal] DECIMAL(19,4) NOT NULL,
    [SubTotal] DECIMAL(19,4) NOT NULL,
    [TaxAmt] DECIMAL(19,4) NOT NULL,
    [Freight] DECIMAL(19,4) NOT NULL,
    [TotalDue] DECIMAL(19,4) NOT NULL,
    [SalesAmountUSD] DECIMAL(19,4) NOT NULL,
    [created_at] DATETIME2(7) NOT NULL CONSTRAINT [df_fact_FactSales_created_at] DEFAULT (SYSUTCDATETIME()),
    [created_by] VARCHAR(50) NOT NULL CONSTRAINT [df_fact_FactSales_created_by] DEFAULT (USER_NAME()),
    [updated_at] DATETIME2(7) NULL,
    [updated_by] VARCHAR(50) NULL,
    [created_run_id] INT NOT NULL,
    [is_active] BIT NOT NULL CONSTRAINT [df_fact_FactSales_is_active] DEFAULT ((1)),

    CONSTRAINT [pk_fact_FactSales] PRIMARY KEY CLUSTERED ([FactSalesKey] ASC),
    CONSTRAINT [uk_fact_FactSales_SourceOrderDetail] UNIQUE ([SourceSalesOrderID], [SourceSalesOrderDetailID]),
    CONSTRAINT [fk_fact_FactSales_OrderDateKey] FOREIGN KEY ([OrderDateKey]) REFERENCES [dim].[DimDate]([DateKey]),
    CONSTRAINT [fk_fact_FactSales_DueDateKey] FOREIGN KEY ([DueDateKey]) REFERENCES [dim].[DimDate]([DateKey]),
    CONSTRAINT [fk_fact_FactSales_ShipDateKey] FOREIGN KEY ([ShipDateKey]) REFERENCES [dim].[DimDate]([DateKey]),
    CONSTRAINT [fk_fact_FactSales_DimCustomerKey] FOREIGN KEY ([DimCustomerKey]) REFERENCES [dim].[DimCustomer]([DimCustomerKey]),
    CONSTRAINT [fk_fact_FactSales_DimSalesPersonKey] FOREIGN KEY ([DimSalesPersonKey]) REFERENCES [dim].[DimSalesPerson]([DimSalesPersonKey]),
    CONSTRAINT [fk_fact_FactSales_DimSalesTerritoryKey] FOREIGN KEY ([DimSalesTerritoryKey]) REFERENCES [dim].[DimSalesTerritory]([DimSalesTerritoryKey]),
    CONSTRAINT [fk_fact_FactSales_DimProductKey] FOREIGN KEY ([DimProductKey]) REFERENCES [dim].[DimProduct]([DimProductKey]),
    CONSTRAINT [fk_fact_FactSales_DimPaymentMethodKey] FOREIGN KEY ([DimPaymentMethodKey]) REFERENCES [dim].[DimPaymentMethod]([DimPaymentMethodKey]),
    CONSTRAINT [fk_fact_FactSales_DimShipMethodKey] FOREIGN KEY ([DimShipMethodKey]) REFERENCES [dim].[DimShipMethod]([DimShipMethodKey])
);
GO
