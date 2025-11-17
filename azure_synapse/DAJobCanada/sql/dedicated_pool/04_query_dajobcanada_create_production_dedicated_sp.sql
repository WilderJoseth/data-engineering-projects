
CREATE PROCEDURE DAJOBCANADA_DB.usp_load_Fact_Jobs
    @run_id SMALLINT
AS
BEGIN
    INSERT INTO DAJOBCANADA_DB.Fact_Jobs (
        job_id,
        job_title,
        company_name,
        language_tools,
        city,
        province,
        level,
        role,
        job_salary_min,
        job_salary_max,
        job_salary_type
    )
    SELECT
        job_id,
        job_title,
        company_name,
        language_tools,
        city,
        province,
        level,
        role,
        job_salary_min,
        job_salary_max,
        job_salary_type
    FROM DAJOBCANADA_DB.Stage_jobs
    WHERE run_id = @run_id;
END;

TRUNCATE TABLE DAJOBCANADA_DB.Fact_Jobs;

EXEC DAJOBCANADA_DB.usp_load_Fact_Jobs 3;

SELECT TOP 5 * FROM DAJOBCANADA_DB.Fact_Jobs;
