/* WARNING: LOCAL/DEV DATA CLEANUP ONLY. Deletes all staging rows. Order: 03. */
USE [Sales_Operational];
GO
DECLARE @sql NVARCHAR(MAX)=N'';
SELECT @sql+=N'DELETE '+QUOTENAME(s.name)+N'.'+QUOTENAME(t.name)+N';'+CHAR(13)
FROM sys.tables t JOIN sys.schemas s ON s.schema_id=t.schema_id WHERE s.name=N'staging';
EXEC sys.sp_executesql @sql; SET @sql=N'';
SELECT @sql+=N'DBCC CHECKIDENT ('+QUOTENAME(s.name+N'.'+t.name,'''')+N', RESEED, 0) WITH NO_INFOMSGS;'
FROM sys.tables t JOIN sys.schemas s ON s.schema_id=t.schema_id WHERE s.name=N'staging';
EXEC sys.sp_executesql @sql;
GO
