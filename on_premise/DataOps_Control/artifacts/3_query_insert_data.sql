
-------------------------
INSERT INTO [prod].[projects] ([id], [name]) VALUES (1, 'Oracle to SQL Server Migration - Sales Domain');
-------------------------

-------------------------
INSERT INTO [prod].[project_databases] ([id], [name], [project_id]) VALUES (1, 'ADVENTUREWORKS2022', 1);
INSERT INTO [prod].[project_databases] ([id], [name], [project_id]) VALUES (2, 'Sales_Operational', 1);
INSERT INTO [prod].[project_databases] ([id], [name], [project_id]) VALUES (3, 'Sales_Analytics', 1);
-------------------------

-------------------------
INSERT INTO [prod].[project_database_mappings] ([database_source_id], [database_target_id]) VALUES (1, 2);
INSERT INTO [prod].[project_database_mappings] ([database_source_id], [database_target_id]) VALUES (2, 3);
-------------------------

-------------------------
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (1, 'PERSON_ADDRESSTYPE', 1);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (2, 'PRODUCTION_PRODUCTSUBCATEGORY', 1);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (3, 'SALES_SPECIALOFFER', 1);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (4, 'PURCHASING_SHIPMETHOD', 1);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (5, 'PERSON_COUNTRYREGION', 1);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (6, 'PERSON_STATEPROVINCE', 1);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (7, 'SALES_SALESTERRITORY', 1);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (8, 'SALES_CURRENCY', 1);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (9, 'SALES_CURRENCYRATE', 1);

INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (10, 'SALES_CREDITCARD', 1);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (11, 'PERSON_ADDRESS', 1);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (12, 'PRODUCTION_PRODUCT', 1);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (13, 'PERSON_PERSON', 1);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (14, 'SALES_SALESPERSON', 1);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (15, 'HUMANRESOURCES_EMPLOYEE', 1);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (16, 'SALES_CUSTOMER', 1);

INSERT INTO [prod].[project_tables] ([id], [name], [is_transactional_table], [database_id]) VALUES (17, 'SALES_SALESORDERHEADER', 1, 1);
INSERT INTO [prod].[project_tables] ([id], [name], [is_transactional_table], [database_id]) VALUES (18, 'SALES_SALESORDERDETAIL', 1, 1);

INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (19, 'AddressType', 2);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (20, 'ProductCategory', 2);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (21, 'SpecialOffer', 2);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (22, 'ShipMethod', 2);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (23, 'CountryRegion', 2);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (24, 'StateProvince', 2);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (25, 'SalesTerritory', 2);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (26, 'Currency', 2);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (27, 'CurrencyRate', 2);

INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (28, 'CreditCard', 2);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (29, 'Address', 2);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (30, 'Product', 2);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (31, 'SalesPerson', 2);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (32, 'Customer', 2);

INSERT INTO [prod].[project_tables] ([id], [name], [is_transactional_table], [batch_column_active], [database_id]) VALUES (33, 'SalesOrderHeader', 1, 1, 2);
INSERT INTO [prod].[project_tables] ([id], [name], [is_transactional_table], [batch_column_active], [database_id]) VALUES (34, 'SalesOrderDetail', 1, 1, 2);

INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (35, 'DimCustomer', 3);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (36, 'DimPaymentMethod', 3);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (37, 'DimShipMethod', 3);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (38, 'DimProduct', 3);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (39, 'DimSalesTerritory', 3);
INSERT INTO [prod].[project_tables] ([id], [name], [database_id]) VALUES (40, 'DimSalesPerson', 3);

INSERT INTO [prod].[project_tables] ([id], [name], [is_fact_table], [batch_column_active], [database_id]) VALUES (41, 'FactSales', 1, 1, 3);
-------------------------

-------------------------
SELECT * FROM [prod].[project_table_mappings]

INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (1, 19);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (2, 20);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (3, 21);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (4, 22);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (5, 23);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (6, 24);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (7, 25);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (8, 26);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (9, 27);

INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (10, 28);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (11, 29);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (12, 30);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (13, 31);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (14, 31);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (15, 31);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (16, 32);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (13, 32);

INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (17, 33);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (18, 34);

INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (32, 35);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (28, 36);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (22, 37);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (30, 38);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (20, 38);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (23, 39);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (25, 39);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (31, 40);

INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (33, 41);
INSERT INTO [prod].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (34, 41);
-------------------------
