/* WARNING: LOCAL/DEV DATA CLEANUP ONLY. Deletes all fact rows. Order: 01. */
USE [Sales_Analytics];
GO
DELETE fact.FactSales;
DBCC CHECKIDENT ('fact.FactSales',RESEED,0) WITH NO_INFOMSGS;
GO
