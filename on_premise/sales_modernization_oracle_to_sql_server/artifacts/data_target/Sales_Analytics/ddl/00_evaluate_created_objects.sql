/* Purpose: Read-only creation-status check for Sales_Analytics DDL objects.
   Order: 00; run from master before setup and again after DDL execution.
   Result columns: ObjectName, ObjectType, CreatedOrNot. */
USE [master];
GO
CREATE TABLE #ActualObjects (ObjectName NVARCHAR(300), ObjectType VARCHAR(20));
IF DB_ID(N'Sales_Analytics') IS NOT NULL
BEGIN
    INSERT #ActualObjects VALUES (N'Sales_Analytics','DATABASE');
    EXEC(N'USE [Sales_Analytics];
      INSERT #ActualObjects
      SELECT s.name,''SCHEMA'' FROM sys.schemas s
       WHERE s.name IN (''control'',''staging'',''work'',''dim'',''fact'');
      INSERT #ActualObjects
      SELECT s.name+''.''+t.name,''TABLE'' FROM sys.tables t
       JOIN sys.schemas s ON s.schema_id=t.schema_id
       WHERE s.name IN (''control'',''staging'',''work'',''dim'',''fact'');
      IF (SELECT COUNT(*) FROM sys.objects o JOIN sys.tables t ON t.object_id=o.parent_object_id
          JOIN sys.schemas s ON s.schema_id=t.schema_id
          WHERE s.name IN (''control'',''staging'',''work'',''dim'',''fact'')
            AND o.type IN (''F'',''C'',''D'',''UQ'',''PK'')) = 97
        INSERT #ActualObjects VALUES (''Named constraints (97)'',''CONSTRAINT SET'');');
END;
WITH Expected(ObjectName,ObjectType) AS (
 SELECT N'Sales_Analytics','DATABASE' UNION ALL
 SELECT N'control','SCHEMA' UNION ALL SELECT N'staging','SCHEMA' UNION ALL
 SELECT N'work','SCHEMA' UNION ALL SELECT N'dim','SCHEMA' UNION ALL SELECT N'fact','SCHEMA' UNION ALL
 SELECT v.ObjectName,'TABLE' FROM (VALUES
 (N'staging.AddressType'),(N'staging.ProductCategory'),(N'staging.ShipMethod'),
 (N'staging.CountryRegion'),(N'staging.SalesTerritory'),(N'staging.StateProvince'),
 (N'staging.SpecialOffer'),(N'staging.Currency'),(N'staging.CurrencyRate'),
 (N'staging.CreditCard'),(N'staging.Address'),(N'staging.Product'),
 (N'staging.SalesPerson'),(N'staging.Customer'),(N'staging.SalesOrderHeader'),
 (N'staging.SalesOrderDetail'),(N'work.DimDate'),(N'work.DimCustomer'),
 (N'work.DimSalesPerson'),(N'work.DimSalesTerritory'),(N'work.DimProduct'),
 (N'work.DimPaymentMethod'),(N'work.DimShipMethod'),(N'work.FactSales'),
 (N'dim.DimDate'),(N'dim.DimCustomer'),(N'dim.DimSalesPerson'),
 (N'dim.DimSalesTerritory'),(N'dim.DimProduct'),(N'dim.DimPaymentMethod'),
 (N'dim.DimShipMethod'),(N'fact.FactSales')
 ) v(ObjectName) UNION ALL SELECT N'Named constraints (97)','CONSTRAINT SET'
)
SELECT e.ObjectName, e.ObjectType,
 CASE WHEN a.ObjectName IS NULL THEN 'NO' ELSE 'YES' END AS CreatedOrNot
FROM Expected e LEFT JOIN #ActualObjects a
 ON a.ObjectName=e.ObjectName AND a.ObjectType=e.ObjectType
ORDER BY CASE e.ObjectType WHEN 'DATABASE' THEN 1 WHEN 'SCHEMA' THEN 2
 WHEN 'TABLE' THEN 3 ELSE 4 END,e.ObjectName;
DROP TABLE #ActualObjects;
GO
