CREATE PROCEDURE staging.usp_clean_tables
AS
BEGIN
    TRUNCATE TABLE staging.fact_missions;
END;

CREATE PROCEDURE staging.usp_load_fact_missions
    @process_date DATE,
    @run_id INT
AS
BEGIN
    INSERT INTO staging.fact_missions (
        company,
        location,
        date,
        rocket,
        mission,
        rocket_status,
        price,
        mission_status,
        country
    )
    SELECT
        company,
        location,
        date,
        rocket,
        mission,
        rocket_status,
        price,
        mission_status,
        country
    FROM lakehouse_main.silver.missions
    WHERE process_date = @process_date
    AND run_id = @run_id;
END;

CREATE PROCEDURE production.usp_clean_tables
AS
BEGIN
    TRUNCATE TABLE production.fact_missions;
END;

CREATE PROCEDURE production.usp_load_fact_missions
AS
BEGIN
    INSERT INTO production.fact_missions (
        company,
        location,
        date,
        rocket,
        mission,
        rocket_status,
        price,
        mission_status,
        country
    )
    SELECT
        company,
        location,
        date,
        rocket,
        mission,
        rocket_status,
        price,
        mission_status,
        country
    FROM staging.fact_missions;
END;

