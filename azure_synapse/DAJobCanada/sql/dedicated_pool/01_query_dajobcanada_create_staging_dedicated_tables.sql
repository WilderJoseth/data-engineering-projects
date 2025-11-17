
CREATE SCHEMA DAJOBCANADA_DB;

--------------- Stage_jobs ---------------
IF (SELECT OBJECT_ID('DAJOBCANADA_DB.Stage_jobs', 'U')) IS NOT NULL
    DROP TABLE DAJOBCANADA_DB.Stage_jobs;

CREATE TABLE DAJOBCANADA_DB.Stage_jobs
(
    job_id VARCHAR(50) NOT NULL,
    job_title VARCHAR(50) NOT NULL,
    company_name VARCHAR(50) NOT NULL,
    language_tools VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    province VARCHAR(50) NOT NULL,
    job_link VARCHAR(200) NOT NULL,
    level VARCHAR(15) NOT NULL,
    role VARCHAR(15) NOT NULL,
    job_salary_min DECIMAL(15, 2) NOT NULL,
    job_salary_max DECIMAL(15, 2) NOT NULL,
    job_salary_type CHAR(1) NOT NULL,
    run_id SMALLINT NOT NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
);
--------------- Stage_jobs ---------------


