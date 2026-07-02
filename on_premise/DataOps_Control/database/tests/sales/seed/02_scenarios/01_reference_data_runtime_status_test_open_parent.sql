/*============================================================================
  DataOps_Control Runtime Test
  Scenario: Reference Data Load - Runtime Status Test

  Purpose:
  - Tests runtime step-closing behavior only.
  - Focuses on the Reference Data Load parent process.
  - Excludes CreditCard Load because it belongs under Master Data Load.
  - Does not insert reconciliation, validation, monitoring, or error evidence.
  - ProductCategory Load ends as OBSERVED.
  - SpecialOffer Load ends as SKIPPED.
  - All other Reference Data Load child processes end as SUCCESS.
  - Reference Data Load parent step is intentionally left open so it can be closed manually.

  Expected result:
  - AddressType Load      = SUCCESS
  - ProductCategory Load  = OBSERVED
  - SpecialOffer Load     = SKIPPED
  - ShipMethod Load       = SUCCESS
  - Geography Load        = SUCCESS
  - Currency Load         = SUCCESS
  - Reference Data Load   = RUNNING until manually closed

  Cleanup:
  - Run 00_cleanup_reference_data_runtime_status_test.sql to remove test data.
============================================================================*/

USE [DataOps_Control];
GO

SET NOCOUNT ON;

DECLARE @scenario_name VARCHAR(100) = 'REFERENCE_DATA_RUNTIME_STATUS_TEST';
DECLARE @project_name VARCHAR(100) = 'Oracle to SQL Server Migration - Sales Domain';

DECLARE @project_id SMALLINT;
DECLARE @execution_run_id INT;

DECLARE @reference_group_process_id INT;
DECLARE @project_process_id INT;

DECLARE @reference_group_execution_step_id BIGINT;
DECLARE @execution_step_id BIGINT;

DECLARE @process_name VARCHAR(100);
DECLARE @final_status_code VARCHAR(20);
DECLARE @final_status_code_id SMALLINT;

DECLARE @run_result TABLE ([execution_run_id] INT);
DECLARE @step_result TABLE ([execution_step_id] BIGINT);

DECLARE @reference_flow TABLE
(
    [execution_order] SMALLINT NOT NULL,
    [process_name] VARCHAR(100) NOT NULL,
    [final_status_code] VARCHAR(20) NOT NULL
);

INSERT INTO @reference_flow
(
    [execution_order],
    [process_name],
    [final_status_code]
)
VALUES
    (1, 'AddressType Load',     'SUCCESS'),
    (2, 'ProductCategory Load', 'OBSERVED'),
    (3, 'SpecialOffer Load',    'SKIPPED'),
    (4, 'ShipMethod Load',      'SUCCESS'),
    (5, 'Geography Load',       'SUCCESS'),
    (6, 'Currency Load',        'SUCCESS');

SELECT @project_id = [id]
FROM [metadata].[projects]
WHERE [name] = @project_name;

IF @project_id IS NULL
    THROW 51000, 'Project seed data was not found.', 1;

SELECT @reference_group_process_id = [id]
FROM [metadata].[project_processes]
WHERE [project_id] = @project_id
AND [name] = 'Reference Data Load';

IF @reference_group_process_id IS NULL
    THROW 51001, 'Reference Data Load process was not found.', 1;


/*============================================================================
  1. Start execution run
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
  2. Start Reference Data Load parent step
============================================================================*/

DELETE FROM @step_result;

INSERT INTO @step_result
EXEC [runtime].[usp_start_execution_step]
    @p_execution_run_id = @execution_run_id,
    @p_project_process_id = @reference_group_process_id;

SELECT @reference_group_execution_step_id = [execution_step_id]
FROM @step_result;


/*============================================================================
  3. Start and close Reference Data Load child steps

  This section intentionally focuses only on runtime statuses.
  No observability records are inserted.
============================================================================*/

DECLARE reference_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT
    [process_name],
    [final_status_code]
FROM @reference_flow
ORDER BY [execution_order];

OPEN reference_cursor;

FETCH NEXT FROM reference_cursor
INTO @process_name, @final_status_code;

WHILE @@FETCH_STATUS = 0
BEGIN
    DELETE FROM @step_result;

    SELECT @project_process_id = [id]
    FROM [metadata].[project_processes]
    WHERE [project_id] = @project_id
    AND [name] = @process_name;

    IF @project_process_id IS NULL
        THROW 51002, 'A Reference Data Load child process was not found.', 1;

    SELECT @final_status_code_id = [id]
    FROM [reference].[status_codes]
    WHERE [code] = @final_status_code;

    IF @final_status_code_id IS NULL
        THROW 51003, 'Final status code was not found.', 1;

    INSERT INTO @step_result
    EXEC [runtime].[usp_start_execution_step]
        @p_execution_run_id = @execution_run_id,
        @p_project_process_id = @project_process_id;

    SELECT @execution_step_id = [execution_step_id]
    FROM @step_result;

    EXEC [runtime].[usp_end_execution_step]
        @p_execution_step_id = @execution_step_id,
        @p_status_code_id = @final_status_code_id;

    FETCH NEXT FROM reference_cursor
    INTO @process_name, @final_status_code;
END;

CLOSE reference_cursor;
DEALLOCATE reference_cursor;


/*============================================================================
  4. Keep Reference Data Load parent step open

  The parent step is intentionally not closed in this script.
  Use the returned @reference_group_execution_step_id value from the final
  SELECT output to test runtime.usp_end_parent_execution_step manually.

  Example:
      EXEC [runtime].[usp_end_parent_execution_step]
          @p_execution_step_id = <reference_group_execution_step_id>;

  Then close the execution run manually:
      EXEC [runtime].[usp_end_execution_run]
          @p_execution_run_id = <execution_run_id>;
============================================================================*/


/*============================================================================
  5. Explore runtime results
============================================================================*/

SELECT *
FROM [runtime].[vw_execution_run_summary]
WHERE [execution_run_id] = @execution_run_id;

SELECT *
FROM [runtime].[vw_execution_step_summary]
WHERE [execution_run_id] = @execution_run_id
ORDER BY [execution_step_id];

SELECT
    @execution_run_id AS [execution_run_id],
    @reference_group_execution_step_id AS [reference_group_execution_step_id],
    'Reference Data Load parent step was intentionally left open.' AS [note];
GO
