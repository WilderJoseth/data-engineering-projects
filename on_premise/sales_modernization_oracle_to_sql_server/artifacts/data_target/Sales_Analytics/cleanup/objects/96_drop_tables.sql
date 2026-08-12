/* WARNING: LOCAL/DEV CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
   Purpose: Drop all tables and stored data in target application schemas.
   Order: 96. Run after 95_drop_constraints.sql. Irreversible. */
USE [Sales_Analytics];
GO
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql += N'DROP TABLE '+QUOTENAME(s.[name])+N'.'+QUOTENAME(t.[name])+N';'+CHAR(13)
FROM sys.tables t JOIN sys.schemas s ON s.schema_id=t.schema_id
WHERE s.[name] IN (N'control',N'staging',N'work',N'dim',N'fact');
IF @sql <> N'' EXEC sys.sp_executesql @sql;
GO
