/* Purpose: Seed final line-grain fact with resolved dimension keys. Order: 04. */
USE [Sales_Analytics];
GO
INSERT fact.FactSales(SourceSalesOrderID,SourceSalesOrderDetailID,OrderDimDateKey,DueDimDateKey,ShipDimDateKey,DimCustomerKey,DimSalesPersonKey,DimSalesTerritoryKey,DimProductKey,DimPaymentMethodKey,DimShipMethodKey,OrderQty,UnitPrice,UnitPriceDiscount,LineTotal,SubTotal,TaxAmt,Freight,TotalDue,SalesAmountUSD)
SELECT w.SourceSalesOrderID,w.SourceSalesOrderDetailID,od.DimDateKey,dd.DimDateKey,sd.DimDateKey,c.DimCustomerKey,sp.DimSalesPersonKey,st.DimSalesTerritoryKey,p.DimProductKey,pm.DimPaymentMethodKey,sm.DimShipMethodKey,w.OrderQty,w.UnitPrice,w.UnitPriceDiscount,w.LineTotal,w.SubTotal,w.TaxAmt,w.Freight,w.TotalDue,w.SalesAmountUSD
FROM work.FactSales w
JOIN staging.SalesOrderHeader h ON h.SourceSalesOrderID=w.SourceSalesOrderID
JOIN dim.DimDate od ON od.FullDate=CAST(h.OrderDate AS DATE)
JOIN dim.DimDate dd ON dd.FullDate=CAST(h.DueDate AS DATE)
JOIN dim.DimDate sd ON sd.FullDate=CAST(h.ShipDate AS DATE)
JOIN dim.DimCustomer c ON c.SourceCustomerID=h.SourceCustomerID
JOIN dim.DimSalesPerson sp ON sp.SourceSalesPersonID=h.SourceSalesPersonID
JOIN dim.DimSalesTerritory st ON st.SourceSalesTerritoryID=h.SourceSalesTerritoryID
JOIN staging.SalesOrderDetail x ON x.SourceSalesOrderDetailID=w.SourceSalesOrderDetailID
JOIN dim.DimProduct p ON p.SourceProductID=x.SourceProductID
JOIN dim.DimPaymentMethod pm ON pm.SourceCreditCardID=h.SourceCreditCardID
JOIN dim.DimShipMethod sm ON sm.SourceShipMethodID=h.SourceShipMethodID
WHERE NOT EXISTS(SELECT 1 FROM fact.FactSales f WHERE f.SourceSalesOrderID=w.SourceSalesOrderID AND f.SourceSalesOrderDetailID=w.SourceSalesOrderDetailID);
GO
