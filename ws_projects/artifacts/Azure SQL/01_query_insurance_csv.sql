
INSERT INTO dbo.projects (name, date_creation) VALUES ('Insurance CSV', GETDATE())

INSERT INTO dbo.project_tables (table_name, is_fact_table, is_active, project_id)
VALUES ('Insurance', 0, 1, 2)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, is_from_file, is_active, table_id)
VALUES (1, 'age', 'INT', NULL, NULL, NULL, 1, 1, 6)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, is_from_file, is_active, table_id)
VALUES (2, 'sex', 'VARCHAR', 10, NULL, NULL, 1, 1, 6)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, is_from_file, is_active, table_id)
VALUES (3, 'bmi', 'DECIMAL', 4, 2, '20.0', 1, 1, 6)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, is_from_file, is_active, table_id)
VALUES (4, 'children', 'INT', NULL, NULL, '0', 1, 1, 6)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, is_from_file, is_active, table_id)
VALUES (5, 'smoker', 'VARCHAR', 3, NULL, 'NO', 1, 1, 6)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, is_from_file, is_active, table_id)
VALUES (6, 'region', 'VARCHAR', 15, NULL, NULL, 1, 0, 6)

INSERT INTO dbo.validation_rules (column_order, column_name_original, column_type, column_size, column_size_scale, default_value, is_from_file, is_active, table_id)
VALUES (7, 'expenses', 'DECIMAL', 8, 2, '0', 1, 0, 6)

EXEC [dbo].[usp_list_tables_project] 2

EXEC [dbo].[usp_list_validation_rules] 2

