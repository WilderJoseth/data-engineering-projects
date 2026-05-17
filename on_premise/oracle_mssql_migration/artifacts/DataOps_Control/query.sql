

INSERT INTO dbo.projects (name, date_creation) VALUES ('Oracle Sales Domain Migration', GETDATE())

INSERT INTO dbo.project_dbs (name, is_active, project_id) VALUES ('AdventureWorks2022_Oracle', 1, 5)
INSERT INTO dbo.project_dbs (name, is_active, project_id) VALUES ('Sales_Operational', 1, 5)
INSERT INTO dbo.project_dbs (name, is_active, project_id) VALUES ('Sales_Analytics', 1, 5)

INSERT INTO dbo.project_dbs_relation (bd_origin_id, bd_destination_id) VALUES(8, 9)
INSERT INTO dbo.project_dbs_relation (bd_origin_id, bd_destination_id) VALUES(9, 10)

INSERT INTO dbo.project_tables (name, is_fact_table, is_active, bd_id) VALUES ('HUMANRESOURCES_EMPLOYEE', 0, 1, 8)
INSERT INTO dbo.project_tables (name, is_fact_table, is_active, bd_id) VALUES ('SalesPerson', 0, 1, 9)
INSERT INTO dbo.project_tables (name, is_fact_table, is_active, bd_id) VALUES ('SalesPerson', 0, 1, 10)

INSERT INTO dbo.project_tables_relation (table_origin_id, table_destination_id) VALUES (7, 8)
INSERT INTO dbo.project_tables_relation (table_origin_id, table_destination_id) VALUES (8, 9)

INSERT INTO dbo.runs (name, start_process_date, end_process_date, status, project_id) VALUES ('Sales_Operational_Migration', GETDATE(), NULL, 'STARTED', 5)

INSERT INTO dbo.sub_runs (run_id, start_process_date, end_process_date, layer, start_count, end_count, status) VALUES (55, GETDATE(), NULL, 'Load Reference Data', 1000, NULL, 'STARTED')
INSERT INTO dbo.sub_runs (run_id, start_process_date, end_process_date, layer, start_count, end_count, status) VALUES (55, GETDATE(), NULL, 'Load AddressType Data', 1000, NULL, 'STARTED')
INSERT INTO dbo.sub_runs (run_id, start_process_date, end_process_date, layer, start_count, end_count, status) VALUES (55, GETDATE(), NULL, 'Load UnitMeasure Data', 1000, NULL, 'STARTED')

SELECT * FROM dbo.runs WHERE project_id = 5

SELECT * FROM dbo.sub_runs

SELECT * FROM dbo.project_tables


