/* WARNING: LOCAL/DEV CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
   Purpose: Drop SQL functions in target schemas. Order: 92, after procedures. */
USE [Sales_Operational];
GO
DECLARE @sql NVARCHAR(MAX)=N'';
SELECT @sql+=N'DROP FUNCTION '+QUOTENAME(s.name)+N'.'+QUOTENAME(o.name)+N';'+CHAR(13)
FROM sys.objects o JOIN sys.schemas s ON s.schema_id=o.schema_id
WHERE s.name IN (N'control',N'staging',N'work',N'prod') AND o.type IN ('FN','IF','TF');
IF @sql<>N'' EXEC sys.sp_executesql @sql;
GO
