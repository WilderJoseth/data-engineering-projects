USE [DataOps_Control];
GO

/*============================================================================
  DataOps_Control
  Cleanup Script: Sales Domain Metadata

  Purpose:
  - Removes Sales Domain metadata seeded by 02_seed_sales_domain_metadata.sql.
  - Keeps framework reference data intact.
  - Deletes rows in dependency-safe order.

  Scope:
  - Project: Oracle to SQL Server Migration - Sales Domain
  - This script removes metadata and related runtime/observability records for
    the project.
  - This script does not delete rows from reference tables.

  Notes:
  - Run this before re-running the Sales Domain metadata seed script.
  - If the project name changes in the seed, update @project_name below.
============================================================================*/

DECLARE @project_name VARCHAR(100) = 'Oracle to SQL Server Migration - Sales Domain';
DECLARE @project_id INT;

SELECT
    @project_id = p.[id]
FROM [metadata].[projects] p
WHERE p.[name] = @project_name;

IF @project_id IS NULL
BEGIN
    PRINT 'Project not found. Nothing to clean.';
    RETURN;
END;


/*============================================================================
  1. Observability records linked to project runtime
============================================================================*/

DELETE mr
FROM [observability].[monitoring_results] mr
INNER JOIN [runtime].[execution_steps] es
    ON es.[id] = mr.[execution_step_id]
INNER JOIN [runtime].[execution_runs] er
    ON er.[id] = es.[execution_run_id]
WHERE er.[project_id] = @project_id;

DELETE rr
FROM [observability].[reconciliation_results] rr
INNER JOIN [runtime].[execution_steps] es
    ON es.[id] = rr.[execution_step_id]
INNER JOIN [runtime].[execution_runs] er
    ON er.[id] = es.[execution_run_id]
WHERE er.[project_id] = @project_id;

DELETE vr
FROM [observability].[validation_results] vr
INNER JOIN [runtime].[execution_steps] es
    ON es.[id] = vr.[execution_step_id]
INNER JOIN [runtime].[execution_runs] er
    ON er.[id] = es.[execution_run_id]
WHERE er.[project_id] = @project_id;

DELETE el
FROM [observability].[error_logs] el
INNER JOIN [runtime].[execution_steps] es
    ON es.[id] = el.[execution_step_id]
INNER JOIN [runtime].[execution_runs] er
    ON er.[id] = es.[execution_run_id]
WHERE er.[project_id] = @project_id;


/*============================================================================
  2. Runtime records
============================================================================*/

DELETE es
FROM [runtime].[execution_steps] es
INNER JOIN [runtime].[execution_runs] er
    ON er.[id] = es.[execution_run_id]
WHERE er.[project_id] = @project_id;

DELETE er
FROM [runtime].[execution_runs] er
WHERE er.[project_id] = @project_id;




/*============================================================================
  3. Project run notification configuration
============================================================================*/

DELETE pn
FROM [metadata].[project_notifications] pn
WHERE pn.[project_id] = @project_id;


/*============================================================================
  4. Process monitoring configuration
============================================================================*/

DELETE ppm
FROM [metadata].[project_process_monitoring_metrics] ppm
INNER JOIN [metadata].[project_processes] pp
    ON pp.[id] = ppm.[project_process_id]
WHERE pp.[project_id] = @project_id;


/*============================================================================
  5. Process action and dependency metadata
============================================================================*/

DELETE ppa
FROM [metadata].[project_process_actions] ppa
INNER JOIN [metadata].[project_processes] pp
    ON pp.[id] = ppa.[project_process_id]
WHERE pp.[project_id] = @project_id;

DELETE ppd
FROM [metadata].[project_process_dependencies] ppd
INNER JOIN [metadata].[project_processes] pp
    ON pp.[id] = ppd.[project_process_id]
WHERE pp.[project_id] = @project_id
OR EXISTS
(
    SELECT 1
    FROM [metadata].[project_processes] dpp
    WHERE dpp.[id] = ppd.[dependency_project_process_id]
    AND dpp.[project_id] = @project_id
);


/*============================================================================
  6. Batch execution scope and batch definitions
============================================================================*/

DELETE pptb
FROM [metadata].[project_process_table_batches] pptb
INNER JOIN [metadata].[project_processes] pp
    ON pp.[id] = pptb.[process_id]
WHERE pp.[project_id] = @project_id;

DELETE b
FROM [metadata].[project_table_batches] b
INNER JOIN [metadata].[project_tables] t
    ON t.[id] = b.[batch_source_table_id]
INNER JOIN [metadata].[project_databases] d
    ON d.[id] = t.[database_id]
WHERE d.[project_id] = @project_id;


/*============================================================================
  7. Process-table scope and table/column metadata
============================================================================*/

DELETE ppt
FROM [metadata].[project_process_tables] ppt
INNER JOIN [metadata].[project_processes] pp
    ON pp.[id] = ppt.[process_id]
WHERE pp.[project_id] = @project_id;

DELETE pc
FROM [metadata].[project_columns] pc
INNER JOIN [metadata].[project_tables] t
    ON t.[id] = pc.[table_id]
INNER JOIN [metadata].[project_databases] d
    ON d.[id] = t.[database_id]
WHERE d.[project_id] = @project_id;


/*============================================================================
  8. Table and database mappings
============================================================================*/

DELETE ptm
FROM [metadata].[project_table_mappings] ptm
WHERE EXISTS
(
    SELECT 1
    FROM [metadata].[project_tables] source_t
    INNER JOIN [metadata].[project_databases] source_d
        ON source_d.[id] = source_t.[database_id]
    WHERE source_t.[id] = ptm.[table_source_id]
    AND source_d.[project_id] = @project_id
)
OR EXISTS
(
    SELECT 1
    FROM [metadata].[project_tables] target_t
    INNER JOIN [metadata].[project_databases] target_d
        ON target_d.[id] = target_t.[database_id]
    WHERE target_t.[id] = ptm.[table_target_id]
    AND target_d.[project_id] = @project_id
);

DELETE pdm
FROM [metadata].[project_database_mappings] pdm
WHERE EXISTS
(
    SELECT 1
    FROM [metadata].[project_databases] source_d
    WHERE source_d.[id] = pdm.[database_source_id]
    AND source_d.[project_id] = @project_id
)
OR EXISTS
(
    SELECT 1
    FROM [metadata].[project_databases] target_d
    WHERE target_d.[id] = pdm.[database_target_id]
    AND target_d.[project_id] = @project_id
);


/*============================================================================
  9. Core metadata
============================================================================*/

DELETE t
FROM [metadata].[project_tables] t
INNER JOIN [metadata].[project_databases] d
    ON d.[id] = t.[database_id]
WHERE d.[project_id] = @project_id;

DELETE pp
FROM [metadata].[project_processes] pp
WHERE pp.[project_id] = @project_id;

DELETE d
FROM [metadata].[project_databases] d
WHERE d.[project_id] = @project_id;

DELETE p
FROM [metadata].[projects] p
WHERE p.[id] = @project_id;

PRINT 'Sales Domain metadata cleanup completed.';
GO
