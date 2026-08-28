USE [DataOps_Control];
GO

CREATE OR ALTER FUNCTION [metadata].[ufn_list_project_process_children]
(
    @p_parent_project_process_id INT
)
RETURNS TABLE
AS
RETURN
(
    /*
        Purpose:
        - Lists active immediate child project processes under a selected parent
          project process.
        - Returns only child project processes marked as execution_required = 1.
        - Used by the ETL/orchestration layer to navigate one process level at a time.

        Important:
        - This function returns immediate children only.
        - It does not inspect table-level execution flags.
        - Table-level execution remains available through project_process_tables
          and project_tables when the selected process needs table context.
    */

    SELECT
        parent_p.[id] AS [parent_project_process_id],
        parent_p.[name] AS [parent_project_process_name],
        child_p.[id] AS [child_project_process_id],
        child_p.[name] AS [child_project_process_name],
        CAST
        (
            CASE
                WHEN EXISTS
                (
                    SELECT 1
                    FROM [metadata].[project_processes] grandchild_p
                    WHERE grandchild_p.[parent_process_id] = child_p.[id]
                    AND grandchild_p.[project_id] = child_p.[project_id]
                    AND grandchild_p.[is_active] = 1
                )
                THEN 1
                ELSE 0
            END AS BIT
        ) AS [has_descendant_project_processes]
    FROM [metadata].[project_processes] parent_p
    INNER JOIN [metadata].[project_processes] child_p
        ON child_p.[parent_process_id] = parent_p.[id]
        AND child_p.[project_id] = parent_p.[project_id]
        AND child_p.[is_active] = 1
        AND child_p.[execution_required] = 1
    WHERE parent_p.[id] = @p_parent_project_process_id
    AND parent_p.[is_active] = 1
);
GO

CREATE OR ALTER FUNCTION [metadata].[ufn_list_project_process_table_batches]
(
    @p_project_process_id INT
)
RETURNS TABLE
AS
RETURN
(
    /*
        Purpose:
        - Lists active executable batch definitions assigned to one project process.
        - Used by the ETL/orchestration layer after a batch-enabled process has
          been selected for execution.
        - Returns only batches marked as execution_required = 1.

        Typical usage:
        - The orchestration layer selects a project process.
        - If the process is batch-based, the ETL calls this function using the
          current project_process_id.
        - The result can be used by a Foreach Loop to execute each required batch.

        Parameters:
        - @p_project_process_id:
            Current project process whose executable batches should be listed.
            This value references metadata.project_processes.id.

        Important:
        - This function returns batches for one project process only.
        - Batch definitions are attached to the source table used for filtering.
        - Target table context is resolved through metadata.project_process_tables.
        - Batch execution scope is resolved through
          metadata.project_process_table_batches.
    */

    SELECT
        p.[id] AS [project_process_id],
        b.[id] AS [batch_id],
        b.[batch_column_type],
        b.[batch_value],
        b.[batch_start_value],
        b.[batch_end_value],
        b.[batch_column_name]
    FROM [metadata].[project_processes] p
    INNER JOIN [metadata].[project_process_table_batches] ptb
        ON ptb.[process_id] = p.[id]
    INNER JOIN [metadata].[project_table_batches] b
        ON b.[id] = ptb.[batch_id]
        AND b.[is_active] = 1
        AND b.[execution_required] = 1
    WHERE p.[id] = @p_project_process_id
    AND p.[is_active] = 1
);
GO

CREATE OR ALTER FUNCTION [metadata].[ufn_list_project_process_actions]
(
    @p_project_process_id INT
)
RETURNS TABLE
AS
RETURN
(
    /*
        Purpose:
        - Lists required active executable actions configured for one project
          process.
        - Used by the ETL/orchestration layer after a project process has been
          selected for execution.
        - Returns one row per required action configured in
          metadata.project_process_actions.

        Typical usage:
        - The orchestration layer loops over project processes.
        - For each selected project process:
            1. Call this function.
            2. Read required active actions ordered by action_position.
            3. Replace parameter_template tokens with runtime values.
            4. Execute the generated execution_command_template.
        - The caller should order by action_position.

        Parameters:
        - @p_project_process_id:
            Project process whose executable actions should be listed.
            This value references metadata.project_processes.id.

        Supported action types:
        - STORED_PROCEDURE:
            Generates an EXEC command template.

        - TABLE_VALUED_FUNCTION:
            Generates a SELECT * FROM function command template.

        - SCALAR_FUNCTION:
            Generates a SELECT function(...) AS [result_value] command template.

        Important:
        - project_process refers to records in metadata.project_processes.
        - execution_database_id identifies where the executable object is located.
        - parameter_template stores custom ETL placeholder tokens such as
          {1}, {2}, or {1}, {2}, {3}.
        - parameter_template does not store real runtime values.
        - Placeholder tokens are not SQL Server or SSIS parameter markers.
          They must be replaced by the orchestration layer before execution.
        - execution_command_template is a command template, not necessarily
          executable until placeholders are replaced.
        - This function returns only active actions where is_required = 1.
        - Optional actions are intentionally excluded from this execution-focused
          result set.
    */

    SELECT
        a.[id] AS [action_id],
        a.[position] AS [action_position],
        a.[action_name],
        a.[action_type],
        d.[name] AS [execution_database_name],
        d.[platform_type] AS [execution_platform_type],
        d.[database_role] AS [execution_database_role],
        a.[schema_name],
        a.[object_name],
        a.[parameter_template],
        CONCAT
        (
            QUOTENAME(d.[name]),
            '.',
            QUOTENAME(a.[schema_name]),
            '.',
            QUOTENAME(a.[object_name])
        ) AS [fully_qualified_object_name],
        CASE
            WHEN a.[action_type] = 'STORED_PROCEDURE'
            THEN CONCAT
            (
                'EXEC ',
                QUOTENAME(d.[name]),
                '.',
                QUOTENAME(a.[schema_name]),
                '.',
                QUOTENAME(a.[object_name]),
                CASE
                    WHEN NULLIF(LTRIM(RTRIM(a.[parameter_template])), '') IS NULL
                    THEN ''
                    ELSE ' ' + a.[parameter_template]
                END
            )
            WHEN a.[action_type] = 'TABLE_VALUED_FUNCTION'
            THEN CONCAT
            (
                'SELECT * FROM ',
                QUOTENAME(d.[name]),
                '.',
                QUOTENAME(a.[schema_name]),
                '.',
                QUOTENAME(a.[object_name]),
                '(',
                ISNULL(a.[parameter_template], ''),
                ')'
            )
            WHEN a.[action_type] = 'SCALAR_FUNCTION'
            THEN CONCAT
            (
                'SELECT ',
                QUOTENAME(d.[name]),
                '.',
                QUOTENAME(a.[schema_name]),
                '.',
                QUOTENAME(a.[object_name]),
                '(',
                ISNULL(a.[parameter_template], ''),
                ') AS [result_value]'
            )
            ELSE NULL
        END AS [execution_command_template]
    FROM [metadata].[project_process_actions] a
    INNER JOIN [metadata].[project_databases] d
        ON d.[id] = a.[execution_database_id]
        AND d.[is_active] = 1
    WHERE a.[project_process_id] = @p_project_process_id
    AND a.[is_required] = 1
    AND a.[is_active] = 1
);
GO