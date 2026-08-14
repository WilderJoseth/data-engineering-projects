/* WARNING: LOCAL/DEV CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
   Purpose: Drop explicitly named table constraints in dependency-safe order.
   Order: 95. Run after 94_drop_indexes.sql. */
USE [Sales_Analytics];
GO
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql += N'ALTER TABLE '+QUOTENAME(s.[name])+N'.'+QUOTENAME(t.[name])
 +N' DROP CONSTRAINT '+QUOTENAME(o.[name])+N';'+CHAR(13)
FROM sys.objects o JOIN sys.tables t ON t.object_id=o.parent_object_id
JOIN sys.schemas s ON s.schema_id=t.schema_id
WHERE s.[name] IN (N'control',N'staging',N'work',N'dim',N'fact')
 AND o.[type] IN ('F','C','D','UQ','PK')
ORDER BY CASE o.[type] WHEN 'F' THEN 1 WHEN 'C' THEN 2 WHEN 'D' THEN 3 WHEN 'UQ' THEN 4 ELSE 5 END;
IF @sql <> N'' EXEC sys.sp_executesql @sql;
GO
