USE [DataOps_Control];
GO

CREATE OR ALTER FUNCTION [metadata].[ufn_list_project_process_tables]
(
    @p_project_id SMALLINT,
    @p_process_id INT,
    @p_batch_column_active BIT 
)
RETURNS TABLE
AS
RETURN
(
    /*
        Purpose:
        - Lists active child processes and their associated controlled tables
          for a given parent process.
        - Used by orchestration logic to decide which table containers should run.

        Typical usage:
        - SSIS Execute SQL Task calls this function.
        - The result is transformed into run flags, such as:
            run_AddressType_load
            run_ProductCategory_load
            run_CountryRegion_load

        Parameters:
        - @p_project_id:
            Project being executed.

        - @p_process_id:
            Parent process whose child processes should be listed.

        - @p_batch_column_active:
            0 = return non-batch table flows.
            1 = return batch-enabled table flows.
    */

    SELECT
        p1.[id] AS [process_id],
        p1.[name] AS [process_name],
        p2.[id] AS [process_child_id],
        p2.[name] AS [process_child_name],
        t.[id] AS [table_id],
        t.[schema_name] AS [table_schema_name], 
        t.[name] AS [table_name],
        t.[execution_required]
    FROM [metadata].[project_processes] p1
    INNER JOIN [metadata].[project_processes] p2
        ON p2.[parent_process_id] = p1.[id]
        AND p2.[is_active] = 1
    INNER JOIN [metadata].[project_process_tables] pt2
        ON pt2.[process_id] = p2.[id]
    INNER JOIN [metadata].[project_tables] t
        ON t.[id] = pt2.[table_id]
        AND t.[is_active] = 1
        AND t.[batch_column_active] = @p_batch_column_active
    WHERE p1.[project_id] = @p_project_id
      AND p1.[id] = @p_process_id
      AND p1.[is_active] = 1
);
GO

CREATE OR ALTER FUNCTION [metadata].[ufn_list_project_process_table_batches]
(
    @p_project_id SMALLINT,
    @p_process_id INT
)
RETURNS TABLE
AS
RETURN
(
    /*
        Purpose:
        - Lists active child processes, controlled target tables, source batch tables,
          and batch definitions explicitly assigned to a process-table execution scope.

        Usage:
        - Used by orchestration logic to identify which batch-enabled table
          and batch slices should run.
        - This function is intended for batch table flows.

        Important:
        - Batch definitions are attached to the source table used for filtering.
        - Target table context is resolved through metadata.project_process_tables.
        - Batch execution scope is resolved through metadata.project_process_table_batches.
    */

    SELECT
        p1.[id] AS [process_id],
        p1.[name] AS [process_name],
        p2.[id] AS [process_child_id],
        p2.[name] AS [process_child_name],
        tgt.[id] AS [target_table_id],
        tgt.[schema_name] AS [target_table_schema_name],
        tgt.[name] AS [target_table_name],
        tgt.[execution_required] AS [target_table_execution_required],
        src.[id] AS [batch_source_table_id],
        src.[schema_name] AS [batch_source_schema_name],
        src.[name] AS [batch_source_table_name],
        b.[id] AS [batch_id],
        b.[batch_column_name],
        b.[batch_value],
        b.[batch_start_value],
        b.[batch_end_value],
        b.[batch_column_type],
        b.[execution_required] AS [batch_execution_required]
    FROM [metadata].[project_processes] p1
    INNER JOIN [metadata].[project_processes] p2
        ON p2.[parent_process_id] = p1.[id]
        AND p2.[project_id] = p1.[project_id]
        AND p2.[is_active] = 1
    INNER JOIN [metadata].[project_process_tables] pt
        ON pt.[process_id] = p2.[id]
    INNER JOIN [metadata].[project_tables] tgt
        ON tgt.[id] = pt.[table_id]
        AND tgt.[is_active] = 1
        AND tgt.[batch_column_active] = 1
    INNER JOIN [metadata].[project_process_table_batches] ptb
        ON ptb.[process_id] = pt.[process_id]
        AND ptb.[table_id] = pt.[table_id]
    INNER JOIN [metadata].[project_table_batches] b
        ON b.[id] = ptb.[batch_id]
        AND b.[is_active] = 1
    INNER JOIN [metadata].[project_tables] src
        ON src.[id] = b.[batch_source_table_id]
        AND src.[is_active] = 1
    WHERE p1.[project_id] = @p_project_id
      AND p1.[id] = @p_process_id
      AND p1.[is_active] = 1
);
GO
