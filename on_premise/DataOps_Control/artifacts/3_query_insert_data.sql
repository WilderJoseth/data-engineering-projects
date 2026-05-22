
-------------------------
SELECT * FROM [metadata].[projects];
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
SELECT * FROM [metadata].[project_tables]
SELECT * FROM [metadata].[project_processes]
SELECT * FROM [metadata].[project_process_tables]
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (10, 19);
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (11, 20);
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (12, 21);
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (13, 22);
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (14, 23);
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (14, 24);
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (14, 25);
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (15, 26);
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (15, 27);

INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (16, 28);
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (17, 29);
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (18, 30);
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (19, 31);
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (20, 32);

INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (21, 33);
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (21, 34);

INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (22, 35);
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (23, 36);
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (24, 37);
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (25, 38);
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (26, 39);
INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (27, 40);

INSERT INTO [metadata].[project_process_tables] ([process_id], [table_id]) VALUES (28, 41);
-------------------------

-------------------------
INSERT INTO [reference].[status_codes] ([id], [code], [description], [is_active])
VALUES
    (1, 'Pending',       'Execution is registered but has not started yet.', 1),
    (2, 'Running',       'Execution is currently in progress.', 1),
    (3, 'Success',       'Execution completed successfully.', 1),
    (4, 'Failed',        'Execution failed due to a technical, validation, or reconciliation issue.', 1),
    (5, 'Skipped',       'Execution was intentionally skipped.', 1),
    (6, 'RerunRequired', 'Object or process is marked for reprocessing.', 1);
GO

INSERT INTO [reference].[validation_codes] ([id], [code], [description], [severity], [is_active])
VALUES
    (1, 'NOT_NULL',       'Required column contains null values.', 'Error', 1),
    (2, 'DUPLICATE',      'Duplicate records were found based on expected key columns.', 'Error', 1),
    (3, 'FK_CHECK',       'Referenced value does not exist in the expected parent or lookup table.', 'Error', 1),
    (4, 'DATA_TYPE',      'Value does not match the expected data type or conversion rule.', 'Error', 1),
    (5, 'LENGTH_CHECK',   'Text value exceeds the expected length.', 'Error', 1),
    (6, 'DATE_RANGE',     'Date value is outside the expected range.', 'Warning', 1),
    (7, 'NEGATIVE_VALUE', 'Numeric value is negative where it may require review.', 'Warning', 1),
    (8, 'RECON_WARNING',  'Validation passed with reconciliation or tolerance warning.', 'Warning', 1),
    (9, 'INFO_CHECK',     'Informational validation result.', 'Info', 1);
GO

INSERT INTO [observability].[reconciliation_results]
(
    [metric_name],
    [reconciliation_key],
    [reconciliation_side],
    [metric_value_decimal],
    [metric_value_bigint],
    [execution_step_id]
)
VALUES
    ('ROW_COUNT', 'TOTAL', 'SOURCE', NULL, 6, 4),
    ('ROW_COUNT', 'TOTAL', 'TARGET', NULL, 6, 4),
    ('TOTAL_AMOUNT', 'TOTAL', 'SOURCE', 1250.7500, NULL, 4),
    ('TOTAL_AMOUNT', 'TOTAL', 'TARGET', 1250.7500, NULL, 4);
-------------------------

-------------------------
SELECT * FROM [metadata].[project_processes]

SELECT * FROM [runtime].[execution_runs];

SELECT * FROM [runtime].[execution_steps];

SELECT * FROM [observability].[reconciliation_results];

DELETE FROM [observability].[reconciliation_results];

EXEC [runtime].[usp_start_execution_run] 1;

EXEC [runtime].[usp_start_execution_step] 2, 10;
-------------------------

SELECT * FROM [observability].[ufn_get_reconciliation_status](4);
