/* Purpose: Seed one coherent local-development row in every staging table.
   Order: 01. Run after Sales_Operational DDL. Rerunnable by source keys. */
USE [Sales_Operational];
GO
IF NOT EXISTS (SELECT 1 FROM staging.AddressType WHERE SourceAddressTypeID=1)
 INSERT staging.AddressType(SourceAddressTypeID,Name) VALUES(1,N'Home');
IF NOT EXISTS (SELECT 1 FROM staging.ProductSubCategory WHERE SourceProductSubCategoryID=1)
 INSERT staging.ProductSubCategory(SourceProductSubCategoryID,Name) VALUES(1,N'Road Bikes');
IF NOT EXISTS (SELECT 1 FROM staging.SpecialOffer WHERE SourceSpecialOfferID=1)
 INSERT staging.SpecialOffer(SourceSpecialOfferID,Description,DiscountPct,OfferType,Category,StartDate,EndDate,MinQty,MaxQty)
 VALUES(1,N'Local seed offer',0.1000,N'Discount',N'Reseller','2023-01-01','2027-12-31',1,10);
IF NOT EXISTS (SELECT 1 FROM staging.ShipMethod WHERE SourceShipMethodID=1)
 INSERT staging.ShipMethod(SourceShipMethodID,Name,ShipBase,ShipRate) VALUES(1,N'Ground',5,1);
IF NOT EXISTS (SELECT 1 FROM staging.CountryRegion WHERE SourceCountryRegionCode=N'US')
 INSERT staging.CountryRegion(SourceCountryRegionCode,Name) VALUES(N'US',N'United States');
IF NOT EXISTS (SELECT 1 FROM staging.SalesTerritory WHERE SourceTerritoryID=1)
 INSERT staging.SalesTerritory(SourceTerritoryID,Name,TerritoryGroup,SourceCountryRegionCode) VALUES(1,N'Northwest',N'North America',N'US');
IF NOT EXISTS (SELECT 1 FROM staging.StateProvince WHERE SourceStateProvinceID=1)
 INSERT staging.StateProvince(SourceStateProvinceID,StateProvinceCode,Name,SourceCountryRegionCode,SourceTerritoryID) VALUES(1,N'WA',N'Washington',N'US',1);
IF NOT EXISTS (SELECT 1 FROM staging.Currency WHERE SourceCurrencyCode=N'USD')
 INSERT staging.Currency(SourceCurrencyCode,Name) VALUES(N'USD',N'US Dollar');
IF NOT EXISTS (SELECT 1 FROM staging.CurrencyRate WHERE SourceCurrencyRateID=1)
 INSERT staging.CurrencyRate(SourceCurrencyRateID,CurrencyRateDate,FromCurrencyCode,ToCurrencyCode,AverageRate,EndOfDayRate) VALUES(1,'2023-01-01',N'USD',N'USD',1,1);
IF NOT EXISTS (SELECT 1 FROM staging.CreditCard WHERE SourceCreditCardID=1)
 INSERT staging.CreditCard(SourceCreditCardID,CardType,CardNumber,ExpMonth,ExpYear) VALUES(1,N'Visa',N'4111111111111111',12,2030);
IF NOT EXISTS (SELECT 1 FROM staging.Address WHERE SourceAddressID=1)
 INSERT staging.Address(SourceAddressID,AddressLine1,City,SourceStateProvinceID,PostalCode,SourceAddressTypeID) VALUES(1,N'1 Seed Street',N'Seattle',1,N'98101',1);
IF NOT EXISTS (SELECT 1 FROM staging.Product WHERE SourceProductID=1)
 INSERT staging.Product(SourceProductID,ProductNumber,Name,Color,SafetyStockLevel,ReorderPoint,StandardCost,ListPrice,Size,Weight,SourceProductSubCategoryID,SellStartDate)
 VALUES(1,N'SEED-001',N'Seed Road Bike',N'Red',100,10,500,750,N'M',10,1,'2023-01-01');
IF NOT EXISTS (SELECT 1 FROM staging.Person WHERE SourceBusinessEntityID=1)
 INSERT staging.Person(SourceBusinessEntityID,PersonType,Title,FirstName,LastName) VALUES(1,N'IN',N'Ms.',N'Alex',N'Rivera');
IF NOT EXISTS (SELECT 1 FROM staging.Employee WHERE SourceBusinessEntityID=1)
 INSERT staging.Employee(SourceBusinessEntityID,JobTitle,Gender,HireDate) VALUES(1,N'Sales Representative',N'F','2020-01-01');
IF NOT EXISTS (SELECT 1 FROM staging.SalesPerson WHERE SourceBusinessEntityID=1)
 INSERT staging.SalesPerson(SourceBusinessEntityID,SourceTerritoryID,SalesQuota,Bonus,CommissionPct,SalesYTD,SalesLastYear) VALUES(1,1,100000,1000,0.0500,25000,20000);
IF NOT EXISTS (SELECT 1 FROM staging.Customer WHERE SourceCustomerID=1)
 INSERT staging.Customer(SourceCustomerID,SourcePersonID,SourceTerritoryID,AccountNumber) VALUES(1,1,1,N'AW00000001');
IF NOT EXISTS (SELECT 1 FROM staging.SalesOrderHeader WHERE SourceSalesOrderID=1)
 INSERT staging.SalesOrderHeader(SourceSalesOrderID,RevisionNumber,OrderDate,DueDate,ShipDate,Status,SalesOrderNumber,PurchaseOrderNumber,AccountNumber,SourceCustomerID,SourceSalesPersonID,SourceTerritoryID,SourceBillToAddressID,SourceShipToAddressID,SourceShipMethodID,SourceCreditCardID,SourceCurrencyRateID,SubTotal,TaxAmt,Freight,TotalDue,Comment)
 VALUES(1,1,'2023-01-15','2023-01-22','2023-01-17',5,N'SO-SEED-001',N'PO-SEED-001',N'AW00000001',1,1,1,1,1,1,1,1,750,60,15,825,N'Local seed order');
IF NOT EXISTS (SELECT 1 FROM staging.SalesOrderDetail WHERE SourceSalesOrderID=1 AND SourceSalesOrderDetailID=1)
 INSERT staging.SalesOrderDetail(SourceSalesOrderID,SourceSalesOrderDetailID,CarrierTrackingNumber,OrderQty,SourceProductID,SourceSpecialOfferID,UnitPrice,UnitPriceDiscount,LineTotal)
 VALUES(1,1,N'TRACK-SEED-001',1,1,1,750,0,750);
IF NOT EXISTS (SELECT 1 FROM staging.BusinessEntityAddress WHERE SourceBusinessEntityID=1 AND SourceAddressID=1 AND SourceAddressTypeID=1)
 INSERT staging.BusinessEntityAddress(SourceBusinessEntityID,SourceAddressID,SourceAddressTypeID) VALUES(1,1,1);
IF NOT EXISTS (SELECT 1 FROM staging.SpecialOfferProduct WHERE SourceSpecialOfferID=1 AND SourceProductID=1)
 INSERT staging.SpecialOfferProduct(SourceSpecialOfferID,SourceProductID) VALUES(1,1);
GO
