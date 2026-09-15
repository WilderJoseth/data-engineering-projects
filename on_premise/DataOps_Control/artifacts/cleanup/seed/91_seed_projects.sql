/*============================================================================
  DataOps_Control
  Cleanup Script: Seed Projects

  Purpose:
  - Removes project-specific seed data loaded by artifacts/seed/02 through
    artifacts/seed/05.
  - Does not remove reference data from artifacts/seed/01_reference_data.sql.

  Scope:
  - Project IDs: 1 through 4
  - Project database IDs: 1 through 18
  - Project process IDs: 1 through 159
    - Current seed process IDs skip legacy package containers 3 and 7.
    - Cleanup still targets 1 through 159 to remove older seeded data if present.
  - Project object IDs: 1 through 176
  - Project object batch IDs: 1 through 5
============================================================================*/

USE [DataOps_Control];
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /*========================================================================
      1. Observability rows tied to seed project execution steps
    ========================================================================*/
    DELETE mr
    FROM [observability].[monitoring_results] AS mr
    INNER JOIN [runtime].[execution_steps] AS es
        ON es.[id] = mr.[execution_step_id]
    INNER JOIN [runtime].[execution_runs] AS er
        ON er.[id] = es.[execution_run_id]
    WHERE er.[project_id] IN (1, 2, 3, 4);

    DELETE mr
    FROM [observability].[monitoring_results] AS mr
    INNER JOIN [metadata].[project_process_monitoring_metrics] AS ppmm
        ON ppmm.[id] = mr.[project_process_monitoring_metric_id]
    WHERE ppmm.[project_process_id] BETWEEN 1 AND 159;

    DELETE vr
    FROM [observability].[validation_results] AS vr
    INNER JOIN [runtime].[execution_steps] AS es
        ON es.[id] = vr.[execution_step_id]
    INNER JOIN [runtime].[execution_runs] AS er
        ON er.[id] = es.[execution_run_id]
    WHERE er.[project_id] IN (1, 2, 3, 4);

    DELETE rr
    FROM [observability].[reconciliation_results] AS rr
    INNER JOIN [runtime].[execution_steps] AS es
        ON es.[id] = rr.[execution_step_id]
    INNER JOIN [runtime].[execution_runs] AS er
        ON er.[id] = es.[execution_run_id]
    WHERE er.[project_id] IN (1, 2, 3, 4);

    DELETE el
    FROM [observability].[error_logs] AS el
    INNER JOIN [runtime].[execution_steps] AS es
        ON es.[id] = el.[execution_step_id]
    INNER JOIN [runtime].[execution_runs] AS er
        ON er.[id] = es.[execution_run_id]
    WHERE er.[project_id] IN (1, 2, 3, 4);

    /*========================================================================
      2. Runtime rows tied to seed projects
    ========================================================================*/
    DELETE ew
    FROM [runtime].[execution_watermarks] AS ew
    LEFT JOIN [runtime].[execution_steps] AS es
        ON es.[id] = ew.[execution_step_id]
    LEFT JOIN [runtime].[execution_runs] AS er
        ON er.[id] = es.[execution_run_id]
    LEFT JOIN [runtime].[execution_watermark_controls] AS ewc
        ON ewc.[id] = ew.[execution_watermark_control_id]
    WHERE er.[project_id] IN (1, 2, 3, 4)
       OR ewc.[project_process_id] BETWEEN 1 AND 159
       OR ewc.[object_id] BETWEEN 1 AND 176;

    DELETE es
    FROM [runtime].[execution_steps] AS es
    INNER JOIN [runtime].[execution_runs] AS er
        ON er.[id] = es.[execution_run_id]
    WHERE er.[project_id] IN (1, 2, 3, 4)
       OR es.[project_process_id] BETWEEN 1 AND 159;

    DELETE FROM [runtime].[execution_runs]
    WHERE [project_id] IN (1, 2, 3, 4);

    DELETE FROM [runtime].[execution_watermark_controls]
    WHERE [project_process_id] BETWEEN 1 AND 159
       OR [object_id] BETWEEN 1 AND 176;

    DELETE epp
    FROM [runtime].[execution_plan_processes] AS epp
    LEFT JOIN [runtime].[execution_plans] AS ep
        ON ep.[id] = epp.[execution_plan_id]
    WHERE ep.[project_id] IN (1, 2, 3, 4)
       OR epp.[project_process_id] BETWEEN 1 AND 159;

    DELETE FROM [runtime].[execution_plans]
    WHERE [project_id] IN (1, 2, 3, 4)
       OR [root_project_process_id] BETWEEN 1 AND 159;

    /*========================================================================
      3. Metadata rows loaded by project seed scripts
    ========================================================================*/
    DELETE FROM [metadata].[project_notifications]
    WHERE [project_id] IN (1, 2, 3, 4)
       OR [project_process_id] BETWEEN 1 AND 159;

    DELETE FROM [metadata].[project_process_monitoring_metrics]
    WHERE [project_process_id] BETWEEN 1 AND 159;

    DELETE FROM [metadata].[project_process_dependencies]
    WHERE [project_process_id] BETWEEN 1 AND 159
       OR [dependency_project_process_id] BETWEEN 1 AND 159;

    DELETE FROM [metadata].[project_process_actions]
    WHERE [project_process_id] BETWEEN 1 AND 159
       OR [execution_database_id] BETWEEN 1 AND 18;

    DELETE FROM [metadata].[project_process_object_batches]
    WHERE [process_id] BETWEEN 1 AND 159
       OR [object_id] BETWEEN 1 AND 176
       OR [batch_id] BETWEEN 1 AND 5;

    DELETE FROM [metadata].[project_object_batches]
    WHERE [id] BETWEEN 1 AND 5
       OR [batch_driver_object_id] BETWEEN 1 AND 176;

    DELETE FROM [metadata].[project_process_objects]
    WHERE [process_id] BETWEEN 1 AND 159
       OR [object_id] BETWEEN 1 AND 176;

    DELETE FROM [metadata].[project_object_mappings]
    WHERE [object_source_id] BETWEEN 1 AND 176
       OR [object_target_id] BETWEEN 1 AND 176;

    DELETE FROM [metadata].[project_object_columns]
    WHERE [object_id] BETWEEN 1 AND 176;

    DELETE FROM [metadata].[project_objects]
    WHERE [id] BETWEEN 1 AND 176;

    DELETE FROM [metadata].[project_database_mappings]
    WHERE [database_source_id] BETWEEN 1 AND 18
       OR [database_target_id] BETWEEN 1 AND 18;

    DELETE FROM [metadata].[project_processes]
    WHERE [id] BETWEEN 142 AND 159;

    DELETE FROM [metadata].[project_processes]
    WHERE [id] BETWEEN 86 AND 141;

    DELETE FROM [metadata].[project_processes]
    WHERE [id] BETWEEN 72 AND 85;

    DELETE FROM [metadata].[project_processes]
    WHERE [id] BETWEEN 43 AND 58;

    DELETE FROM [metadata].[project_processes]
    WHERE [id] BETWEEN 37 AND 42;

    DELETE FROM [metadata].[project_processes]
    WHERE [id] BETWEEN 60 AND 71
       OR [id] BETWEEN 31 AND 35
       OR [id] BETWEEN 10 AND 28;

    DELETE FROM [metadata].[project_processes]
    WHERE [id] = 36
       OR [id] = 59
       OR [id] BETWEEN 29 AND 30
       OR [id] BETWEEN 4 AND 6
       OR [id] BETWEEN 8 AND 9;

    -- Remove legacy package containers from earlier seed versions, if present.
    DELETE FROM [metadata].[project_processes]
    WHERE [id] IN (3, 7);

    DELETE FROM [metadata].[project_processes]
    WHERE [id] BETWEEN 1 AND 2;

    DELETE FROM [metadata].[project_databases]
    WHERE [id] BETWEEN 1 AND 18;

    DELETE FROM [metadata].[projects]
    WHERE [id] IN (1, 2, 3, 4);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO

