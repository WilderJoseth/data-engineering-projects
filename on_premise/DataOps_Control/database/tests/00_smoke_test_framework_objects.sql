/*
    Script: 00_smoke_test_framework_objects.sql
    Database: DataOps_Control

    Purpose:
    - Verifies that the main DataOps_Control schemas, tables, procedures,
      functions, roles, and reference values exist.
    - Intended to be executed after deployment and before data-flow tests.
*/

USE [DataOps_Control];
GO

DECLARE @missing_objects TABLE
(
    object_type VARCHAR(50),
    object_name SYSNAME
);

/* Schemas */
INSERT INTO @missing_objects
SELECT 'SCHEMA', v.[name]
FROM (VALUES
    ('metadata'),
    ('runtime'),
    ('observability'),
    ('reference')
) v([name])
WHERE NOT EXISTS (
    SELECT 1
    FROM sys.schemas s
    WHERE s.[name] = v.[name]
);

/* Tables */
INSERT INTO @missing_objects
SELECT 'TABLE', v.[name]
FROM (VALUES
    ('reference.status_codes'),
    ('reference.validation_codes'),
    ('reference.monitoring_metric_codes'),
    ('metadata.projects'),
    ('metadata.project_databases'),
    ('metadata.project_database_mappings'),
    ('metadata.project_processes'),
    ('metadata.project_tables'),
    ('metadata.project_table_mappings'),
    ('metadata.project_process_tables'),
    ('metadata.project_process_table_batches'),
    ('metadata.project_table_batches'),
    ('metadata.project_columns'),
    ('metadata.project_process_actions'),
    ('metadata.project_process_dependencies'),
    ('metadata.project_process_monitoring_metrics'),
    ('runtime.execution_runs'),
    ('runtime.execution_steps'),
    ('observability.error_logs'),
    ('observability.validation_results'),
    ('observability.reconciliation_results'),
    ('observability.monitoring_results')
) v([name])
WHERE OBJECT_ID(v.[name], 'U') IS NULL;

/* Stored procedures */
INSERT INTO @missing_objects
SELECT 'PROCEDURE', v.[name]
FROM (VALUES
    ('runtime.usp_start_execution_run'),
    ('runtime.usp_start_execution_step'),
    ('runtime.usp_end_execution_step'),
    ('runtime.usp_end_execution_run'),
    ('observability.usp_log_error')
) v([name])
WHERE OBJECT_ID(v.[name], 'P') IS NULL;

/* Functions */
INSERT INTO @missing_objects
SELECT 'FUNCTION', v.[name]
FROM (VALUES
    ('metadata.ufn_list_project_process_children'),
    ('metadata.ufn_list_project_process_table_batches'),
    ('metadata.ufn_list_project_process_actions')
) v([name])
WHERE OBJECT_ID(v.[name], 'IF') IS NULL;

/* Views */
INSERT INTO @missing_objects
SELECT 'VIEW', v.[name]
FROM (VALUES
    ('metadata.vw_project_process_hierarchy'),
    ('metadata.vw_project_process_dependency_summary'),
    ('metadata.vw_project_process_action_summary'),
    ('metadata.vw_project_batch_execution_scope'),
    ('metadata.vw_project_table_lineage_summary'),
    ('metadata.vw_project_process_monitoring_metric_summary'),
    ('runtime.vw_execution_run_summary'),
    ('runtime.vw_execution_step_summary'),
    ('observability.vw_execution_observability_summary'),
    ('observability.vw_monitoring_result_summary')
) v([name])
WHERE OBJECT_ID(v.[name], 'V') IS NULL;

/* Roles */
INSERT INTO @missing_objects
SELECT 'ROLE', v.[name]
FROM (VALUES
    ('DataOps_Admin'),
    ('DataOps_Project_Executor')
) v([name])
WHERE NOT EXISTS (
    SELECT 1
    FROM sys.database_principals dp
    WHERE dp.[name] = v.[name]
      AND dp.[type] = 'R'
);

/* Reference status values */
INSERT INTO @missing_objects
SELECT 'REFERENCE STATUS', v.[code]
FROM (VALUES
    ('PENDING'),
    ('RUNNING'),
    ('SUCCESS'),
    ('OBSERVED'),
    ('FAILED'),
    ('SKIPPED')
) v([code])
WHERE NOT EXISTS (
    SELECT 1
    FROM [reference].[status_codes] sc
    WHERE sc.[code] = v.[code]
);

/* Reference validation values */
INSERT INTO @missing_objects
SELECT 'REFERENCE VALIDATION', v.[code]
FROM (VALUES
    ('NOT_NULL'),
    ('DUPLICATE'),
    ('FK_CHECK'),
    ('DATA_TYPE'),
    ('LENGTH_CHECK'),
    ('DATE_RANGE'),
    ('NEGATIVE_VALUE'),
    ('RECON_WARNING'),
    ('INFO_CHECK')
) v([code])
WHERE NOT EXISTS (
    SELECT 1
    FROM [reference].[validation_codes] vc
    WHERE vc.[code] = v.[code]
);

/* Reference monitoring metric values */
INSERT INTO @missing_objects
SELECT 'REFERENCE MONITORING', v.[code]
FROM (VALUES
    ('DURATION_SECONDS'),
    ('VALIDATION_ISSUE_COUNT'),
    ('RECONCILIATION_MISMATCH_COUNT'),
    ('ERROR_COUNT'),
    ('ROW_COUNT')
) v([code])
WHERE NOT EXISTS (
    SELECT 1
    FROM [reference].[monitoring_metric_codes] mmc
    WHERE mmc.[code] = v.[code]
);

IF EXISTS (SELECT 1 FROM @missing_objects)
BEGIN
    SELECT
        object_type,
        object_name
    FROM @missing_objects
    ORDER BY object_type, object_name;

    ;THROW 51000, 'Smoke test failed. One or more required DataOps_Control objects are missing.', 1;
END;

SELECT
    'Smoke test passed. All required DataOps_Control objects exist.' AS [result];
GO
