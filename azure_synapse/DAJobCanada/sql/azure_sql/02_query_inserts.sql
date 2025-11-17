
---------------------------------- dajobcanada_db.validation_definition ----------------------------------
INSERT INTO dajobcanada_db.validation_definition (table_name, column_name, column_type, column_size, default_value, active)
VALUES ('jobs', 'job_id', 'VARCHAR', 50, '', 1)

INSERT INTO dajobcanada_db.validation_definition (table_name, column_name, column_type, column_size, default_value, active)
VALUES ('jobs', 'job_title', 'VARCHAR', 50, 'UNKNOWN', 1)

INSERT INTO dajobcanada_db.validation_definition (table_name, column_name, column_type, column_size, default_value, active)
VALUES ('jobs', 'company_name', 'VARCHAR', 50, 'UNKNOWN', 1)

INSERT INTO dajobcanada_db.validation_definition (table_name, column_name, column_type, column_size, default_value, active)
VALUES ('jobs', 'language_tools', 'VARCHAR', 50, 'UNKNOWN', 1)

INSERT INTO dajobcanada_db.validation_definition (table_name, column_name, column_type, column_size, default_value, active)
VALUES ('jobs', 'job_salary', 'VARCHAR', 50, '0', 1)

INSERT INTO dajobcanada_db.validation_definition (table_name, column_name, column_type, column_size, default_value, active)
VALUES ('jobs', 'city', 'VARCHAR', 50, 'UNKNOWN', 1)

INSERT INTO dajobcanada_db.validation_definition (table_name, column_name, column_type, column_size, default_value, active)
VALUES ('jobs', 'province', 'VARCHAR', 50, 'UNKNOWN', 1)

INSERT INTO dajobcanada_db.validation_definition (table_name, column_name, column_type, column_size, default_value, active)
VALUES ('jobs', 'job_link', 'VARCHAR', 200, 'UNKNOWN', 1)

INSERT INTO dajobcanada_db.validation_definition (table_name, column_name, column_type, column_size, column_scale, default_value, active)
VALUES ('jobs', 'job_salary_min', 'DECIMAL', 15, 2, '0', 1)

INSERT INTO dajobcanada_db.validation_definition (table_name, column_name, column_type, column_size, column_scale, default_value, active)
VALUES ('jobs', 'job_salary_max', 'DECIMAL', 15, 2, '0', 1)

INSERT INTO dajobcanada_db.validation_definition (table_name, column_name, column_type, column_size, default_value, active)
VALUES ('jobs', 'job_salary_type', 'CHAR', 1, 'O', 1)

INSERT INTO dajobcanada_db.validation_definition (table_name, column_name, column_type, column_size, default_value, active)
VALUES ('jobs', 'level', 'VARCHAR', 15, 'JUNIOR', 1)

INSERT INTO dajobcanada_db.validation_definition (table_name, column_name, column_type, column_size, default_value, active)
VALUES ('jobs', 'role', 'VARCHAR', 15, 'HYBRID', 1)
---------------------------------- dajobcanada_db.validation_definition ----------------------------------

---------------------------------- dajobcanada_db.job_roles ----------------------------------
INSERT INTO dajobcanada_db.job_roles (level, role, job_salary_min_base, job_salary_max_base)
VALUES ('SENIOR', 'ANALYST', 18.00, 54.80)

INSERT INTO dajobcanada_db.job_roles (level, role, job_salary_min_base, job_salary_max_base)
VALUES ('SENIOR', 'DEVELOPER', 40.00, 70.80)

INSERT INTO dajobcanada_db.job_roles (level, role, job_salary_min_base, job_salary_max_base)
VALUES ('SENIOR', 'ENGINEER', 65.00, 85.80)

INSERT INTO dajobcanada_db.job_roles (level, role, job_salary_min_base, job_salary_max_base)
VALUES ('SENIOR', 'HYBRID', 55.00, 65.00)

INSERT INTO dajobcanada_db.job_roles (level, role, job_salary_min_base, job_salary_max_base)
VALUES ('LEAD', 'ANALYST', 18.00, 32.80)

INSERT INTO dajobcanada_db.job_roles (level, role, job_salary_min_base, job_salary_max_base)
VALUES ('LEAD', 'DEVELOPER', 40.00, 50.80)

INSERT INTO dajobcanada_db.job_roles (level, role, job_salary_min_base, job_salary_max_base)
VALUES ('LEAD', 'ENGINEER', 55.00, 65.80)

INSERT INTO dajobcanada_db.job_roles (level, role, job_salary_min_base, job_salary_max_base)
VALUES ('LEAD', 'HYBRID', 50.00, 60.00)

INSERT INTO dajobcanada_db.job_roles (level, role, job_salary_min_base, job_salary_max_base)
VALUES ('SPECIALIST', 'ANALYST', 32.00, 35.00)

INSERT INTO dajobcanada_db.job_roles (level, role, job_salary_min_base, job_salary_max_base)
VALUES ('SPECIALIST', 'DEVELOPER', 42.00, 50.00)

INSERT INTO dajobcanada_db.job_roles (level, role, job_salary_min_base, job_salary_max_base)
VALUES ('SPECIALIST', 'ENGINEER', 52.00, 60.80)

INSERT INTO dajobcanada_db.job_roles (level, role, job_salary_min_base, job_salary_max_base)
VALUES ('SPECIALIST', 'HYBRID', 50.00, 55.00)

INSERT INTO dajobcanada_db.job_roles (level, role, job_salary_min_base, job_salary_max_base)
VALUES ('JUNIOR', 'ANALYST', 43.00, 51.00)

INSERT INTO dajobcanada_db.job_roles (level, role, job_salary_min_base, job_salary_max_base)
VALUES ('JUNIOR', 'DEVELOPER', 65.00, 75.00)

INSERT INTO dajobcanada_db.job_roles (level, role, job_salary_min_base, job_salary_max_base)
VALUES ('JUNIOR', 'ENGINEER', 85.00, 95.80)

INSERT INTO dajobcanada_db.job_roles (level, role, job_salary_min_base, job_salary_max_base)
VALUES ('JUNIOR', 'HYBRID', 50.00, 100.00)
---------------------------------- dajobcanada_db.job_roles ----------------------------------

