
-------------------------
INSERT INTO [metadata].[projects] ([id], [name]) VALUES (1, 'Oracle to SQL Server Migration - Sales Domain');
-------------------------

-------------------------
INSERT INTO [metadata].[project_databases] ([id], [name], [platform_type], [database_role], [project_id]) VALUES (1, 'ADVENTUREWORKS2022', 'Oracle XE 21c', 'Source', 1);
INSERT INTO [metadata].[project_databases] ([id], [name], [platform_type], [database_role], [project_id]) VALUES (2, 'Sales_Operational', 'SQL Server 2022', 'Target', 1);
INSERT INTO [metadata].[project_databases] ([id], [name], [platform_type], [database_role], [project_id]) VALUES (3, 'Sales_Analytics', 'SQL Server 2022', 'Target', 1);
-------------------------

-------------------------
INSERT INTO [metadata].[project_database_mappings] ([database_source_id], [database_target_id]) VALUES (1, 2);
INSERT INTO [metadata].[project_database_mappings] ([database_source_id], [database_target_id]) VALUES (2, 3);
-------------------------

-------------------------
INSERT INTO [metadata].[project_processes] ([name], [database_id]) VALUES ('', 1);
-------------------------

-------------------------
SELECT * FROM [metadata].[project_tables]
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (1, 'ADVENTUREWORKS2022', 'PERSON_ADDRESSTYPE', 1);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (2, 'ADVENTUREWORKS2022', 'PRODUCTION_PRODUCTSUBCATEGORY', 1);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (3, 'ADVENTUREWORKS2022', 'SALES_SPECIALOFFER', 1);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (4, 'ADVENTUREWORKS2022', 'PURCHASING_SHIPMETHOD', 1);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (5, 'ADVENTUREWORKS2022', 'PERSON_COUNTRYREGION', 1);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (6, 'ADVENTUREWORKS2022', 'PERSON_STATEPROVINCE', 1);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (7, 'ADVENTUREWORKS2022', 'SALES_SALESTERRITORY', 1);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (8, 'ADVENTUREWORKS2022', 'SALES_CURRENCY', 1);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (9, 'ADVENTUREWORKS2022', 'SALES_CURRENCYRATE', 1);

INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (10, 'ADVENTUREWORKS2022', 'SALES_CREDITCARD', 1);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (11, 'ADVENTUREWORKS2022', 'PERSON_ADDRESS', 1);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (12, 'ADVENTUREWORKS2022', 'PRODUCTION_PRODUCT', 1);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (13, 'ADVENTUREWORKS2022', 'PERSON_PERSON', 1);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (14, 'ADVENTUREWORKS2022', 'SALES_SALESPERSON', 1);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (15, 'ADVENTUREWORKS2022', 'HUMANRESOURCES_EMPLOYEE', 1);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (16, 'ADVENTUREWORKS2022', 'SALES_CUSTOMER', 1);

INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [is_transactional_table], [database_id]) VALUES (17, 'ADVENTUREWORKS2022', 'SALES_SALESORDERHEADER', 1, 1);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [is_transactional_table], [database_id]) VALUES (18, 'ADVENTUREWORKS2022', 'SALES_SALESORDERDETAIL', 1, 1);

INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (19, 'prod', 'AddressType', 2);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (20, 'prod', 'ProductCategory', 2);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (21, 'prod', 'SpecialOffer', 2);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (22, 'prod', 'ShipMethod', 2);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (23, 'prod', 'CountryRegion', 2);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (24, 'prod', 'StateProvince', 2);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (25, 'prod', 'SalesTerritory', 2);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (26, 'prod', 'Currency', 2);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (27, 'prod', 'CurrencyRate', 2);

INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (28, 'prod', 'CreditCard', 2);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (29, 'prod', 'Address', 2);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (30, 'prod', 'Product', 2);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (31, 'prod', 'SalesPerson', 2);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (32, 'prod', 'Customer', 2);

INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [is_transactional_table], [batch_column_active], [database_id]) VALUES (33, 'prod', 'SalesOrderHeader', 1, 1, 2);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [is_transactional_table], [batch_column_active], [database_id]) VALUES (34, 'prod', 'SalesOrderDetail', 1, 1, 2);

INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (35, 'dim', 'DimCustomer', 3);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (36, 'dim', 'DimPaymentMethod', 3);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (37, 'dim', 'DimShipMethod', 3);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (38, 'dim', 'DimProduct', 3);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (39, 'dim', 'DimSalesTerritory', 3);
INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [database_id]) VALUES (40, 'dim', 'DimSalesPerson', 3);

INSERT INTO [metadata].[project_tables] ([id], [schema_name], [name], [is_fact_table], [batch_column_active], [database_id]) VALUES (41, 'fact', 'FactSales', 1, 1, 3);
-------------------------

-------------------------
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (1, 19);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (2, 20);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (3, 21);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (4, 22);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (5, 23);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (6, 24);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (7, 25);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (8, 26);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (9, 27);

INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (10, 28);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (11, 29);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (12, 30);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (13, 31);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (14, 31);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (15, 31);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (16, 32);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (13, 32);

INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (17, 33);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (18, 34);

INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (32, 35);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (28, 36);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (22, 37);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (30, 38);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (20, 38);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (23, 39);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (25, 39);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (31, 40);

INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (33, 41);
INSERT INTO [metadata].[project_table_mappings] ([table_source_id], [table_target_id]) VALUES (34, 41);
-------------------------

-------------------------
INSERT INTO [metadata].[project_table_batches] ([batch_column_name], [batch_value], [batch_start_value], [batch_end_value], [column_type], [table_id]) VALUES ('OrderDate', '2011-05-31', '2011-05-01', '2014-06-30', 'DATE', 33);
INSERT INTO [metadata].[project_table_batches] ([batch_column_name], [batch_value], [batch_start_value], [batch_end_value], [column_type], [table_id]) VALUES ('OrderDate', '201105', '201105', '201406', 'INT', 41);
-------------------------

-------------------------
SELECT * FROM [metadata].[project_processes]
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id]) VALUES (1, 'Sales_Operational_Migration', 1);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id]) VALUES (2, 'Sales_Analytics_Migration', 1);

INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (3, 'PKG_OPERATIONAL_MIGRATION', 1, 1);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (4, 'PKG_REFERENCE_DATA', 1, 3);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (5, 'PKG_MASTER_DATA', 1, 3);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (6, 'PKG_TRANSACTIONAL_DATA', 1, 3);

INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (7, 'PKG_ANALYTICS_MIGRATION', 1, 2);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (8, 'PKG_DIMENSIONS', 1, 7);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (9, 'PKG_FACTS', 1, 7);

INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (10, 'AddressType Load', 1, 4);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (11, 'ProductCategory Load', 1, 4);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (12, 'SpecialOffer Load', 1, 4);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (13, 'ShipMethod Load', 1, 4);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (14, 'Geography Load', 1, 4);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (15, 'Currency Load', 1, 4);

INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (16, 'CreditCard Load', 1, 5);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (17, 'Address Load', 1, 5);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (18, 'Product Load', 1, 5);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (19, 'SalesPerson Load', 1, 5);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (20, 'Customer Load', 1, 5);

INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (21, 'Sales Load', 1, 6);

INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (22, 'DimCustomer Load', 1, 8);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (23, 'DimPaymentMethod Load', 1, 8);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (24, 'DimShipMethod Load', 1, 8);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (25, 'DimProduct Load', 1, 8);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (26, 'DimSalesTerritory Load', 1, 8);
INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (27, 'DimSalesPerson Load', 1, 8);

INSERT INTO [metadata].[project_processes] ([id], [name], [project_id], [parent_process_id]) VALUES (28, 'FactSales Load', 1, 9);
-------------------------

-------------------------
SELECT * FROM [metadata].[project_tables]
SELECT * FROM [metadata].[project_processes]
SELECT * FROM [metadata].[project_table_process_mappings]
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (10, 19);
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (11, 20);
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (12, 21);
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (13, 22);
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (14, 23);
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (14, 24);
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (14, 25);
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (15, 26);
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (15, 27);

INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (16, 28);
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (17, 29);
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (18, 30);
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (19, 31);
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (20, 32);

INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (21, 33);
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (21, 34);

INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (22, 35);
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (23, 36);
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (24, 37);
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (25, 38);
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (26, 39);
INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (27, 40);

INSERT INTO [metadata].[project_table_process_mappings] ([process_id], [table_id]) VALUES (28, 41);
-------------------------

-------------------------
INSERT INTO [reference].[status_codes] ([code], [description])
VALUES
    ('Pending', 'Execution is registered but has not started yet.'),
    ('Running', 'Execution is currently in progress.'),
    ('Success', 'Execution completed successfully.'),
    ('Failed', 'Execution failed due to a technical, validation, or reconciliation issue.'),
    ('Skipped', 'Execution was intentionally skipped.'),
    ('RerunRequired', 'Object or process is marked for reprocessing.');

INSERT INTO [reference].[validation_codes] ([code], [description], [severity])
VALUES
    ('NOT_NULL', 'Required column contains null values.', 'Error'),
    ('DUPLICATE', 'Duplicate records were found based on expected key columns.', 'Error'),
    ('FK_CHECK', 'Referenced value does not exist in the expected parent or lookup table.', 'Error'),
    ('DATA_TYPE', 'Value does not match the expected data type or conversion rule.', 'Error'),
    ('LENGTH_CHECK', 'Text value exceeds the expected length.', 'Error'),
    ('DATE_RANGE', 'Date value is outside the expected range.', 'Warning'),
    ('NEGATIVE_VALUE', 'Numeric value is negative where it may require review.', 'Warning'),
    ('RECON_WARNING', 'Validation passed with reconciliation or tolerance warning.', 'Warning'),
    ('INFO_CHECK', 'Informational validation result.', 'Info');
-------------------------

-------------------------
SELECT * FROM [metadata].[project_processes]

SELECT p1.[id], p1.[name], p2.[id], p2.[name], t.[schema_name], t.[name], t.[rerun_required]
FROM [metadata].[project_processes] p1
LEFT JOIN [metadata].[project_processes] p2 ON p2.[parent_process_id] = p1.[id] AND p2.[is_active] = 1
LEFT JOIN [metadata].[project_table_process_mappings] tp2 ON tp2.[process_id] = p2.[id]
LEFT JOIN [metadata].[project_tables] t ON t.[id] = tp2.[table_id] AND t.[is_active] = 1 AND t.[batch_column_active] = 0
WHERE p1.[project_id] = 1
AND p1.[id] = 4
AND p1.[is_active] = 1
ORDER BY p2.[name], t.[name]
-------------------------

