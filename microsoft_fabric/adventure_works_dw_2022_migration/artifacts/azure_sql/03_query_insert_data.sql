
----------------- START load data -----------------
-------------------------
INSERT INTO dbo.projects (name, date_creation)
VALUES ('AdventureWorksDW2022_Migration', GETDATE());
-------------------------

-------------------------
SELECT * FROM dbo.stages
INSERT INTO dbo.stages (name) VALUES ('BRONZE');
INSERT INTO dbo.stages (name) VALUES ('SILVER');
INSERT INTO dbo.stages (name) VALUES ('WS STAGING');
INSERT INTO dbo.stages (name) VALUES ('WS PRODUCTION');
-------------------------

-------------------------
SELECT * FROM dbo.project_tables

INSERT INTO dbo.project_tables (table_name, is_fact_table, is_active, project_id)
VALUES ('FactFinance', 1, 1, 1);

INSERT INTO dbo.project_tables (table_name, is_fact_table, is_active, project_id)
VALUES ('DimOrganization', 0, 1, 1);

INSERT INTO dbo.project_tables (table_name, is_fact_table, is_active, project_id)
VALUES ('DimDepartmentGroup', 0, 1, 1);

INSERT INTO dbo.project_tables (table_name, is_fact_table, is_active, project_id)
VALUES ('DimScenario', 0, 1, 1);

INSERT INTO dbo.project_tables (table_name, is_fact_table, is_active, project_id)
VALUES ('DimAccount', 0, 1, 1);
-------------------------

-------------------------
SELECT * FROM dbo.validation_rules

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (1, 'FinanceKey', 'INT', 0, NULL, '0', 1)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (2, 'DateKey', 'INT', 0, NULL, '0', 1)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (3, 'OrganizationKey', 'INT', 0, NULL, '0', 1)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (4, 'DepartmentGroupKey', 'INT', 0, NULL, '0', 1)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (5, 'ScenarioKey', 'INT', 0, NULL, '0', 1)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (6, 'AccountKey', 'INT', 0, NULL, '0', 1)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (7, 'Amount', 'DECIMAL', 10, 2, '0', 1)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (8, 'Date', 'DATETIME', 0, NULL, '1900-01-01 00:00:00', 1)


INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (1, 'OrganizationKey', 'INT', 0, NULL, '0', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (2, 'ParentOrganizationKey', 'INT', 0, NULL, '0', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (3, 'PercentageOfOwnership', 'DECIMAL', 3, 2, '0', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (4, 'OrganizationName', 'NVARCHAR', 50, NULL, '', 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (5, 'CurrencyKey', 'INT', 0, NULL, '0', 2)


INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (1, 'DepartmentGroupKey', 'INT', 0, NULL, '0', 3)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (2, 'ParentDepartmentGroupKey', 'INT', 0, NULL, '0', 3)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (3, 'DepartmentGroupName', 'NVARCHAR', 50, NULL, '', 3)


INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (1, 'ScenarioKey', 'INT', 0, NULL, '0', 4)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (2, 'ScenarioName', 'NVARCHAR', 50, NULL, '', 4)


INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (1, 'AccountKey', 'INT', 0, NULL, '0', 5)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (2, 'ParentAccountKey', 'INT', 0, NULL, '0', 5)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (3, 'AccountCodeAlternateKey', 'INT', 0, NULL, '0', 5)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (4, 'ParentAccountCodeAlternateKey', 'INT', 0, NULL, '0', 5)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (5, 'AccountDescription', 'NVARCHAR', 50, NULL, '', 5)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (6, 'AccountType', 'NVARCHAR', 50, NULL, '', 5)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (7, 'Operator', 'NVARCHAR', 50, NULL, '', 5)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, table_id)
VALUES (8, 'ValueType', 'NVARCHAR', 50, NULL, '', 5)
-------------------------

-------------------------
SELECT * FROM dbo.fact_table_years

INSERT INTO dbo.fact_table_years (year, is_active, table_id) VALUES (2010, 0, 1)
INSERT INTO dbo.fact_table_years (year, is_active, table_id) VALUES (2011, 0, 1)
INSERT INTO dbo.fact_table_years (year, is_active, table_id) VALUES (2012, 0, 1)
INSERT INTO dbo.fact_table_years (year, is_active, table_id) VALUES (2013, 0, 1)
-------------------------
----------------- END load data -----------------
