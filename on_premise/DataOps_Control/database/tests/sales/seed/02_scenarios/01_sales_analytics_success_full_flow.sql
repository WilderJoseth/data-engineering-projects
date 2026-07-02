/*============================================================================
  DataOps_Control Runtime Test
  Scenario: Sales_Analytics_Migration - Successful Full Flow

  Purpose:
  - Simulates a successful execution of the full Sales_Analytics_Migration flow.
  - Ends leaf execution steps using runtime.usp_end_execution_step.
  - Ends parent/group execution steps using runtime.usp_end_parent_execution_step.
  - Uses observability.usp_capture_execution_step_bigint_monitoring_results
    to populate monitoring results from runtime/observability evidence.
  - Focuses final exploration on runtime and observability results.

  Cleanup:
  - Run 00_cleanup_sales_analytics_success_full_flow.sql to remove test data.
============================================================================*/

USE [DataOps_Control];
GO

SET NOCOUNT ON;

DECLARE @scenario_name VARCHAR(100) = 'SALES_ANALYTICS_SUCCESS_FULL_FLOW';
DECLARE @project_name VARCHAR(100) = 'Oracle to SQL Server Migration - Sales Domain';

DECLARE @project_id SMALLINT;
DECLARE @execution_run_id INT;

DECLARE @root_execution_step_id BIGINT;
DECLARE @group_execution_step_id BIGINT;
DECLARE @execution_step_id BIGINT;

DECLARE @root_project_process_id INT;
DECLARE @group_project_process_id INT;
DECLARE @project_process_id INT;

DECLARE @group_name VARCHAR(100);
DECLARE @process_name VARCHAR(100);
DECLARE @row_count BIGINT;
DECLARE @duration_seconds BIGINT;
DECLARE @status_success_id SMALLINT;

DECLARE @run_result TABLE ([execution_run_id] INT);
DECLARE @step_result TABLE ([execution_step_id] BIGINT);

DECLARE @groups TABLE
(
    [execution_order] SMALLINT NOT NULL,
    [group_name] VARCHAR(100) NOT NULL
);

DECLARE @leaf_flow TABLE
(
    [group_name] VARCHAR(100) NOT NULL,
    [execution_order] SMALLINT NOT NULL,
    [process_name] VARCHAR(100) NOT NULL,
    [row_count] BIGINT NOT NULL,
    [duration_seconds] BIGINT NOT NULL
);

INSERT INTO @groups
(
    [execution_order],
    [group_name]
)
VALUES
    (1, 'Dimensions Data Load'),
    (2, 'Facts Data Load');

INSERT INTO @leaf_flow
(
    [group_name],
    [execution_order],
    [process_name],
    [row_count],
    [duration_seconds]
)
VALUES
    ('Dimensions Data Load', 1, 'DimCustomer Load',       250000,  180),
    ('Dimensions Data Load', 2, 'DimPaymentMethod Load',  5000,    60),
    ('Dimensions Data Load', 3, 'DimShipMethod Load',     50,      30),
    ('Dimensions Data Load', 4, 'DimProduct Load',        25000,   120),
    ('Dimensions Data Load', 5, 'DimSalesTerritory Load', 500,     45),
    ('Dimensions Data Load', 6, 'DimSalesPerson Load',    5000,    90),
    ('Facts Data Load',      1, 'FactSales Load',         1500000, 900);

SELECT @project_id = [id]
FROM [metadata].[projects]
WHERE [name] = @project_name;

SELECT @status_success_id = [id]
FROM [reference].[status_codes]
WHERE [code] = 'SUCCESS';

IF @project_id IS NULL
    THROW 51000, 'Project seed data was not found.', 1;

IF @status_success_id IS NULL
    THROW 51001, 'SUCCESS status code was not found.', 1;

SELECT @root_project_process_id = [id]
FROM [metadata].[project_processes]
WHERE [project_id] = @project_id
AND [name] = 'Sales_Analytics_Migration';

IF @root_project_process_id IS NULL
    THROW 51002, 'Sales_Analytics_Migration process was not found.', 1;


/*============================================================================
  1. Start project execution run
============================================================================*/

INSERT INTO @run_result
EXEC [runtime].[usp_start_execution_run]
    @p_project_id = @project_id;

SELECT @execution_run_id = [execution_run_id]
FROM @run_result;

UPDATE [runtime].[execution_runs]
SET [created_by] = @scenario_name
WHERE [id] = @execution_run_id;


/*============================================================================
  2. Start root parent process step
============================================================================*/

DELETE FROM @step_result;

INSERT INTO @step_result
EXEC [runtime].[usp_start_execution_step]
    @p_execution_run_id = @execution_run_id,
    @p_project_process_id = @root_project_process_id;

SELECT @root_execution_step_id = [execution_step_id]
FROM @step_result;


/*============================================================================
  3. Execute process groups and leaf processes

  Parent/group steps are closed with runtime.usp_end_parent_execution_step.
  Leaf steps are closed with runtime.usp_end_execution_step.
============================================================================*/

DECLARE group_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT [group_name]
FROM @groups
ORDER BY [execution_order];

OPEN group_cursor;

FETCH NEXT FROM group_cursor
INTO @group_name;

WHILE @@FETCH_STATUS = 0
BEGIN
    DELETE FROM @step_result;

    SELECT @group_project_process_id = [id]
    FROM [metadata].[project_processes]
    WHERE [project_id] = @project_id
    AND [name] = @group_name;

    IF @group_project_process_id IS NULL
        THROW 51003, 'A process group in the Sales_Analytics_Migration flow was not found.', 1;

    INSERT INTO @step_result
    EXEC [runtime].[usp_start_execution_step]
        @p_execution_run_id = @execution_run_id,
        @p_project_process_id = @group_project_process_id;

    SELECT @group_execution_step_id = [execution_step_id]
    FROM @step_result;

    DECLARE leaf_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT
        [process_name],
        [row_count],
        [duration_seconds]
    FROM @leaf_flow
    WHERE [group_name] = @group_name
    ORDER BY [execution_order];

    OPEN leaf_cursor;

    FETCH NEXT FROM leaf_cursor
    INTO @process_name, @row_count, @duration_seconds;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DELETE FROM @step_result;

        SELECT @project_process_id = [id]
        FROM [metadata].[project_processes]
        WHERE [project_id] = @project_id
        AND [name] = @process_name;

        IF @project_process_id IS NULL
            THROW 51004, 'A leaf process in the Sales_Analytics_Migration flow was not found.', 1;

        INSERT INTO @step_result
        EXEC [runtime].[usp_start_execution_step]
            @p_execution_run_id = @execution_run_id,
            @p_project_process_id = @project_process_id;

        SELECT @execution_step_id = [execution_step_id]
        FROM @step_result;

        INSERT INTO [observability].[reconciliation_results]
        (
            [metric_name],
            [reconciliation_key],
            [reconciliation_side],
            [metric_value_bigint],
            [execution_step_id]
        )
        VALUES
            ('ROW_COUNT', @process_name, 'SOURCE', @row_count, @execution_step_id),
            ('ROW_COUNT', @process_name, 'TARGET', @row_count, @execution_step_id);

        /*
            Test-only adjustment:
            - The monitoring capture procedure calculates DURATION_SECONDS
              from runtime.execution_steps.
            - This update simulates elapsed execution time for the test scenario.
        */
        UPDATE [runtime].[execution_steps]
        SET [start_step_date] = DATEADD(SECOND, -@duration_seconds, SYSUTCDATETIME())
        WHERE [id] = @execution_step_id;

        EXEC [observability].[usp_capture_execution_step_bigint_monitoring_results]
            @p_execution_step_id = @execution_step_id;

        EXEC [runtime].[usp_end_execution_step]
            @p_execution_step_id = @execution_step_id,
            @p_status_code_id = @status_success_id;

        FETCH NEXT FROM leaf_cursor
        INTO @process_name, @row_count, @duration_seconds;
    END;

    CLOSE leaf_cursor;
    DEALLOCATE leaf_cursor;

    /*
        The group status is derived from its direct child steps.
    */
    EXEC [runtime].[usp_end_parent_execution_step]
        @p_execution_step_id = @group_execution_step_id;

    FETCH NEXT FROM group_cursor
    INTO @group_name;
END;

CLOSE group_cursor;
DEALLOCATE group_cursor;


/*============================================================================
  4. End root parent process step and project execution run
============================================================================*/

/*
    The root process status is derived from its direct child group steps.
*/
EXEC [runtime].[usp_end_parent_execution_step]
    @p_execution_step_id = @root_execution_step_id;

EXEC [runtime].[usp_end_execution_run]
    @p_execution_run_id = @execution_run_id;


/*============================================================================
  5. Explore runtime and observability results
============================================================================*/

SELECT *
FROM [runtime].[vw_execution_run_summary]
WHERE [execution_run_id] = @execution_run_id;

SELECT *
FROM [runtime].[vw_execution_step_summary]
WHERE [execution_run_id] = @execution_run_id
ORDER BY [execution_step_id];

SELECT *
FROM [observability].[vw_execution_observability_summary]
WHERE [execution_run_id] = @execution_run_id
ORDER BY [execution_step_id];

SELECT *
FROM [observability].[vw_monitoring_result_summary]
WHERE [execution_run_id] = @execution_run_id
ORDER BY [execution_step_id], [metric_code];

SELECT
    *
FROM [observability].[vw_reconciliation_result_summary]
WHERE [execution_run_id] = @execution_run_id
ORDER BY
    [execution_step_id],
    [metric_name],
    [reconciliation_key],
    [reconciliation_side];
GO
