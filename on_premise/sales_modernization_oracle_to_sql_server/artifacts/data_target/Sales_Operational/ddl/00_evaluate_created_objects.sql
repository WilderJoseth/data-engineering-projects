/* Purpose: Read-only creation-status check for Sales_Operational DDL objects.
   Order: 00; run from master before setup and again after DDL execution.
   Result columns: ObjectName, ObjectType, CreatedOrNot. */
USE [master];
GO
CREATE TABLE #ActualObjects (ObjectName NVARCHAR(300), ObjectType VARCHAR(20));
IF DB_ID(N'Sales_Operational') IS NOT NULL
BEGIN
    INSERT #ActualObjects VALUES (N'Sales_Operational','DATABASE');
    EXEC(N'USE [Sales_Operational];
      INSERT #ActualObjects
      SELECT s.name,''SCHEMA'' FROM sys.schemas s
       WHERE s.name IN (''control'',''staging'',''work'',''prod'');
      INSERT #ActualObjects
      SELECT s.name+''.''+t.name,''TABLE'' FROM sys.tables t
       JOIN sys.schemas s ON s.schema_id=t.schema_id
       WHERE s.name IN (''control'',''staging'',''work'',''prod'');
      IF (SELECT COUNT(*) FROM sys.objects o JOIN sys.tables t ON t.object_id=o.parent_object_id
          JOIN sys.schemas s ON s.schema_id=t.schema_id
          WHERE s.name IN (''control'',''staging'',''work'',''prod'')
            AND o.type IN (''F'',''C'',''D'',''UQ'',''PK'')) = 205
        INSERT #ActualObjects VALUES (''Named constraints (205)'',''CONSTRAINT SET'');');
END;
WITH Expected(ObjectName,ObjectType) AS (
 SELECT N'Sales_Operational','DATABASE' UNION ALL
 SELECT N'control','SCHEMA' UNION ALL SELECT N'staging','SCHEMA' UNION ALL
 SELECT N'work','SCHEMA' UNION ALL SELECT N'prod','SCHEMA' UNION ALL
 SELECT v.ObjectName,'TABLE' FROM (VALUES
 (N'staging.AddressType'),(N'staging.ProductSubCategory'),(N'staging.SpecialOffer'),
 (N'staging.ShipMethod'),(N'staging.CountryRegion'),(N'staging.SalesTerritory'),
 (N'staging.StateProvince'),(N'staging.Currency'),(N'staging.CurrencyRate'),
 (N'staging.CreditCard'),(N'staging.Address'),(N'staging.Product'),
 (N'staging.Person'),(N'staging.Employee'),(N'staging.SalesPerson'),
 (N'staging.Customer'),(N'staging.SalesOrderHeader'),(N'staging.SalesOrderDetail'),
 (N'staging.BusinessEntityAddress'),(N'staging.SpecialOfferProduct'),
 (N'work.AddressType'),(N'work.ProductCategory'),(N'work.SpecialOffer'),
 (N'work.ShipMethod'),(N'work.CountryRegion'),(N'work.SalesTerritory'),
 (N'work.StateProvince'),(N'work.Currency'),(N'work.CurrencyRate'),
 (N'work.CreditCard'),(N'work.Address'),(N'work.Product'),(N'work.SalesPerson'),
 (N'work.Customer'),(N'work.SalesOrderHeader'),(N'work.SalesOrderDetail'),
 (N'prod.AddressType'),(N'prod.ProductCategory'),(N'prod.ShipMethod'),
 (N'prod.CountryRegion'),(N'prod.SalesTerritory'),(N'prod.StateProvince'),
 (N'prod.SpecialOffer'),(N'prod.Currency'),(N'prod.CurrencyRate'),
 (N'prod.CreditCard'),(N'prod.Address'),(N'prod.Product'),(N'prod.SalesPerson'),
 (N'prod.Customer'),(N'prod.SalesOrderHeader'),(N'prod.SalesOrderDetail')
 ) v(ObjectName) UNION ALL SELECT N'Named constraints (205)','CONSTRAINT SET'
)
SELECT e.ObjectName, e.ObjectType,
 CASE WHEN a.ObjectName IS NULL THEN 'NO' ELSE 'YES' END AS CreatedOrNot
FROM Expected e LEFT JOIN #ActualObjects a
 ON a.ObjectName=e.ObjectName AND a.ObjectType=e.ObjectType
ORDER BY CASE e.ObjectType WHEN 'DATABASE' THEN 1 WHEN 'SCHEMA' THEN 2
 WHEN 'TABLE' THEN 3 ELSE 4 END,e.ObjectName;
DROP TABLE #ActualObjects;
GO
