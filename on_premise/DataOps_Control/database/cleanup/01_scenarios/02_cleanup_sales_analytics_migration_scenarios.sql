/*============================================================================
  DataOps_Control Runtime Scenario Cleanup
  Scope: Sales_Analytics_Migration / FactSales Load scenarios

  Purpose:
  - Removes runtime and observability rows generated for process id 28.
  - Keeps project metadata, process metadata, and monitoring metric metadata.

  Warning:
  - This deletes all execution evidence for project process id 28.
============================================================================*/

USE [DataOps_Control];
GO

DECLARE @execution_steps TABLE ([id] BIGINT PRIMARY KEY);
DECLARE @execution_runs TABLE ([id] INT PRIMARY KEY);

INSERT INTO @execution_steps ([id])
SELECT es.[id]
FROM [runtime].[execution_steps] es
INNER JOIN [runtime].[execution_runs] er
    ON er.[id] = es.[execution_run_id]
WHERE er.[project_id] = 1
AND es.[project_process_id] = 28;

INSERT INTO @execution_runs ([id])
SELECT DISTINCT es.[execution_run_id]
FROM [runtime].[execution_steps] es
INNER JOIN @execution_steps target_es
    ON target_es.[id] = es.[id];

IF OBJECT_ID('[observability].[monitoring_results]', 'U') IS NOT NULL
BEGIN
    DELETE mr
    FROM [observability].[monitoring_results] mr
    INNER JOIN @execution_steps es
        ON es.[id] = mr.[execution_step_id];
END;

DELETE el
FROM [observability].[error_logs] el
INNER JOIN @execution_steps es
    ON es.[id] = el.[execution_step_id];

DELETE vr
FROM [observability].[validation_results] vr
INNER JOIN @execution_steps es
    ON es.[id] = vr.[execution_step_id];

DELETE rr
FROM [observability].[reconciliation_results] rr
INNER JOIN @execution_steps es
    ON es.[id] = rr.[execution_step_id];

DELETE es
FROM [runtime].[execution_steps] es
INNER JOIN @execution_steps target_es
    ON target_es.[id] = es.[id];

DELETE er
FROM [runtime].[execution_runs] er
INNER JOIN @execution_runs target_er
    ON target_er.[id] = er.[id]
WHERE NOT EXISTS
(
    SELECT 1
    FROM [runtime].[execution_steps] remaining_es
    WHERE remaining_es.[execution_run_id] = er.[id]
);
GO
