/* WARNING: LOCAL/DEV CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
   Purpose: Drop procedures in target schemas. Order: 91, after views. */
USE [Sales_Operational];
GO
DECLARE @sql NVARCHAR(MAX)=N'';
SELECT @sql+=N'DROP PROCEDURE '+QUOTENAME(s.name)+N'.'+QUOTENAME(p.name)+N';'+CHAR(13)
FROM sys.procedures p JOIN sys.schemas s ON s.schema_id=p.schema_id
WHERE s.name IN (N'control',N'staging',N'work',N'prod');
IF @sql<>N'' EXEC sys.sp_executesql @sql;
GO
