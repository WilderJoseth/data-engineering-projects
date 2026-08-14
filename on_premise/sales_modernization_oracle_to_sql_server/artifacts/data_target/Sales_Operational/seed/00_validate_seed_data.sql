/* Purpose: Return schema-qualified exact row counts for every target table.
   Run before seeding for a baseline and after 03_seed_prod.sql for validation. */
USE [Sales_Operational];
GO
CREATE TABLE #Counts(SchemaName SYSNAME,TableName SYSNAME,[RowCount] BIGINT);
DECLARE @Schema SYSNAME,@Table SYSNAME,@sql NVARCHAR(MAX);
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
 SELECT s.name,t.name FROM sys.tables t JOIN sys.schemas s ON s.schema_id=t.schema_id
 WHERE s.name IN(N'staging',N'work',N'prod') ORDER BY s.name,t.name;
OPEN c; FETCH NEXT FROM c INTO @Schema,@Table;
WHILE @@FETCH_STATUS=0 BEGIN
 SET @sql=N'INSERT #Counts SELECT N'''+REPLACE(@Schema,'''','''''')+N''',N'''+REPLACE(@Table,'''','''''')+N''',COUNT_BIG(*) FROM '+QUOTENAME(@Schema)+N'.'+QUOTENAME(@Table)+N';';
 EXEC sys.sp_executesql @sql; FETCH NEXT FROM c INTO @Schema,@Table;
END
CLOSE c; DEALLOCATE c;
SELECT SchemaName,TableName,[RowCount] FROM #Counts ORDER BY SchemaName,TableName;
DROP TABLE #Counts;
GO
