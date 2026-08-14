/* WARNING: LOCAL/DEV CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
   Purpose: Drop views in Sales_Operational application schemas. Order: 90. */
USE [Sales_Operational];
GO
DECLARE @sql NVARCHAR(MAX)=N'';
SELECT @sql+=N'DROP VIEW '+QUOTENAME(s.name)+N'.'+QUOTENAME(v.name)+N';'+CHAR(13)
FROM sys.views v JOIN sys.schemas s ON s.schema_id=v.schema_id
WHERE s.name IN (N'control',N'staging',N'work',N'prod');
IF @sql<>N'' EXEC sys.sp_executesql @sql;
GO
