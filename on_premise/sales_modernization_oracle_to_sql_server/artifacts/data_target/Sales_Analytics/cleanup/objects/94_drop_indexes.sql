/* WARNING: LOCAL/DEV CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
   Purpose: Drop standalone indexes; constraint-backed indexes are excluded.
   Order: 94. Run after 90_drop_programmable_objects.sql. */
USE [Sales_Analytics];
GO
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql += N'DROP INDEX '+QUOTENAME(i.[name])+N' ON '
 +QUOTENAME(s.[name])+N'.'+QUOTENAME(t.[name])+N';'+CHAR(13)
FROM sys.indexes i JOIN sys.tables t ON t.object_id=i.object_id
JOIN sys.schemas s ON s.schema_id=t.schema_id
WHERE s.[name] IN (N'control',N'staging',N'work',N'dim',N'fact')
 AND i.index_id>0 AND i.is_primary_key=0 AND i.is_unique_constraint=0;
IF @sql <> N'' EXEC sys.sp_executesql @sql;
GO
