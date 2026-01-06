

EXEC dbo.usp_list_tables_project 1

EXEC dbo.usp_list_validation_rules 1

EXEC dbo.usp_list_years_fact_table_to_process 1

SELECT * FROM dbo.runs
ORDER BY id DESC

SELECT * FROM dbo.sub_runs
WHERE run_id = 54;

-- 01: Notebook does not exist
-- 02: Notebook executed
SELECT * FROM dbo.logs
WHERE run_id = 47;

SELECT * FROM dbo.validation_rules

SELECT * FROM dbo.stages

SELECT * FROM dbo.project_tables

UPDATE dbo.project_tables SET is_active = 1
WHERE id = 1

