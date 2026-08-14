/* WARNING: LOCAL/DEV DATA CLEANUP ONLY. Deletes all prod rows. Order: 01. */
USE [Sales_Operational];
GO
DELETE prod.SalesOrderDetail; DELETE prod.SalesOrderHeader; DELETE prod.Customer;
DELETE prod.SalesPerson; DELETE prod.Product; DELETE prod.Address;
DELETE prod.CreditCard; DELETE prod.CurrencyRate; DELETE prod.SpecialOffer;
DELETE prod.StateProvince; DELETE prod.SalesTerritory; DELETE prod.Currency;
DELETE prod.CountryRegion; DELETE prod.ShipMethod; DELETE prod.ProductCategory;
DELETE prod.AddressType;
DECLARE @sql NVARCHAR(MAX)=N'';
SELECT @sql+=N'DBCC CHECKIDENT ('+QUOTENAME(s.name+N'.'+t.name,'''')+N', RESEED, 0) WITH NO_INFOMSGS;'
FROM sys.tables t JOIN sys.schemas s ON s.schema_id=t.schema_id
WHERE s.name=N'prod' AND EXISTS(SELECT 1 FROM sys.identity_columns i WHERE i.object_id=t.object_id);
EXEC sys.sp_executesql @sql;
GO
