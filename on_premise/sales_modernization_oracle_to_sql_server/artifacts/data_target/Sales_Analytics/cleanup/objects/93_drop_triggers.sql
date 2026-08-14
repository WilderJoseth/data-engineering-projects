/* WARNING: LOCAL/DEV CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
   Purpose: Drop schema-scoped DML triggers. Order: 93, after functions. */
USE [Sales_Analytics];
GO
DECLARE @sql NVARCHAR(MAX)=N'';
SELECT @sql+=N'DROP TRIGGER '+QUOTENAME(s.name)+N'.'+QUOTENAME(o.name)+N';'+CHAR(13)
FROM sys.triggers o JOIN sys.objects p ON p.object_id=o.parent_id
JOIN sys.schemas s ON s.schema_id=p.schema_id
WHERE s.name IN (N'control',N'staging',N'work',N'dim',N'fact') AND o.parent_class=1;
IF @sql<>N'' EXEC sys.sp_executesql @sql;
GO
