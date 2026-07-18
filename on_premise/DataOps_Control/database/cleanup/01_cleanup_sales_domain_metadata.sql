/*============================================================================
  DataOps_Control
  Cleanup Script: Sales Domain Metadata

  Purpose:
  - Removes metadata and execution evidence related to the sample project:
      Oracle to SQL Server Migration - Sales Domain
  - Allows the Sales Domain seed script to be executed again.
  - Resets identity values where applicable.

  Notes:
  - This script does not delete reference data from reference.status_codes
    or reference.validation_codes.
  - Metadata seed IDs are manually assigned, so most metadata tables do not
    require identity reseeding.
  - Runtime and observability tables may use identity columns, so they are
    reseeded when identity columns exist.
============================================================================*/

USE [DataOps_Control];
GO

DECLARE @project_id SMALLINT = 1;

/*============================================================================
  1. Remove observability records linked to project executions
============================================================================*/

DELETE vr
FROM [observability].[validation_results] vr
INNER JOIN [runtime].[execution_steps] es
    ON es.[id] = vr.[execution_step_id]
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

DELETE el
FROM [observability].[error_logs] el
INNER JOIN [runtime].[execution_steps] es
    ON es.[id] = el.[execution_step_id]
INNER JOIN [runtime].[execution_runs] er
    ON er.[id] = es.[execution_run_id]
WHERE er.[project_id] = @project_id;
GO

/*============================================================================
  2. Remove runtime records linked to the project
============================================================================*/

DECLARE @project_id SMALLINT = 1;

DELETE es
FROM [runtime].[execution_steps] es
INNER JOIN [runtime].[execution_runs] er
    ON er.[id] = es.[execution_run_id]
WHERE er.[project_id] = @project_id;

DELETE er
FROM [runtime].[execution_runs] er
WHERE er.[project_id] = @project_id;
GO

/*============================================================================
  3. Remove metadata relationships and child records
============================================================================*/

DECLARE @project_id SMALLINT = 1;

DELETE ptb
FROM [metadata].[project_process_table_batches] ptb
INNER JOIN [metadata].[project_processes] pp
    ON pp.[id] = ptb.[process_id]
WHERE pp.[project_id] = @project_id;

DELETE tb
FROM [metadata].[project_table_batches] tb
INNER JOIN [metadata].[project_tables] t
    ON t.[id] = tb.[batch_source_table_id]
INNER JOIN [metadata].[project_databases] d
    ON d.[id] = t.[database_id]
WHERE d.[project_id] = @project_id;

DELETE pc
FROM [metadata].[project_columns] pc
INNER JOIN [metadata].[project_tables] t
    ON t.[id] = pc.[table_id]
INNER JOIN [metadata].[project_databases] d
    ON d.[id] = t.[database_id]
WHERE d.[project_id] = @project_id;

DELETE ppt
FROM [metadata].[project_process_tables] ppt
INNER JOIN [metadata].[project_processes] pp
    ON pp.[id] = ppt.[process_id]
WHERE pp.[project_id] = @project_id;

DELETE tm
FROM [metadata].[project_table_mappings] tm
WHERE EXISTS (
    SELECT 1
    FROM [metadata].[project_tables] src
    INNER JOIN [metadata].[project_databases] src_db
        ON src_db.[id] = src.[database_id]
    WHERE src.[id] = tm.[table_source_id]
      AND src_db.[project_id] = @project_id
)
OR EXISTS (
    SELECT 1
    FROM [metadata].[project_tables] tgt
    INNER JOIN [metadata].[project_databases] tgt_db
        ON tgt_db.[id] = tgt.[database_id]
    WHERE tgt.[id] = tm.[table_target_id]
    AND tgt_db.[project_id] = @project_id
);

DELETE dm
FROM [metadata].[project_database_mappings] dm
WHERE EXISTS (
    SELECT 1
    FROM [metadata].[project_databases] src_db
    WHERE src_db.[id] = dm.[database_source_id]
    AND src_db.[project_id] = @project_id
)
OR EXISTS (
    SELECT 1
    FROM [metadata].[project_databases] tgt_db
    WHERE tgt_db.[id] = dm.[database_target_id]
    AND tgt_db.[project_id] = @project_id
);
GO

/*============================================================================
  4. Remove metadata parent records
============================================================================*/

DECLARE @project_id SMALLINT = 1;

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
GO

/*============================================================================
  5. Reset identity values where applicable

  Notes:
  - DBCC CHECKIDENT only works for tables with identity columns.
  - These checks avoid errors for manually assigned metadata tables.
============================================================================*/

IF EXISTS (
    SELECT 1
    FROM sys.identity_columns
    WHERE [object_id] = OBJECT_ID('[runtime].[execution_runs]')
)
BEGIN
    DBCC CHECKIDENT ('[runtime].[execution_runs]', RESEED, 0);
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.identity_columns
    WHERE [object_id] = OBJECT_ID('[runtime].[execution_steps]')
)
BEGIN
    DBCC CHECKIDENT ('[runtime].[execution_steps]', RESEED, 0);
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.identity_columns
    WHERE [object_id] = OBJECT_ID('[observability].[error_logs]')
)
BEGIN
    DBCC CHECKIDENT ('[observability].[error_logs]', RESEED, 0);
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.identity_columns
    WHERE [object_id] = OBJECT_ID('[observability].[validation_results]')
)
BEGIN
    DBCC CHECKIDENT ('[observability].[validation_results]', RESEED, 0);
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.identity_columns
    WHERE [object_id] = OBJECT_ID('[observability].[reconciliation_results]')
)
BEGIN
    DBCC CHECKIDENT ('[observability].[reconciliation_results]', RESEED, 0);
END;
GO

/*============================================================================
  6. Optional verification
============================================================================*/

DECLARE @project_id SMALLINT = 1;

SELECT 'metadata.projects' AS [table_name], COUNT(*) AS [rows_remaining]
FROM [metadata].[projects]
WHERE [id] = @project_id

UNION ALL

SELECT 'metadata.project_databases', COUNT(*)
FROM [metadata].[project_databases]
WHERE [project_id] = @project_id

UNION ALL

SELECT 'metadata.project_processes', COUNT(*)
FROM [metadata].[project_processes]
WHERE [project_id] = @project_id

UNION ALL

SELECT 'runtime.execution_runs', COUNT(*)
FROM [runtime].[execution_runs]
WHERE [project_id] = @project_id;
GO