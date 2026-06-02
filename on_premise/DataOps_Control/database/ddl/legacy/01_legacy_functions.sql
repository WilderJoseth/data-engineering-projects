/*============================================================================
  Legacy Functions

  Purpose:
  - Preserves functions from previous design iterations.
  - These functions are not part of the current v2 process-action orchestration
    path.
  - They are kept for reference, comparison, or possible future reuse.
============================================================================*/
CREATE OR ALTER FUNCTION [metadata].[ufn_list_project_process_tables]
(
    @p_project_id SMALLINT,
    @p_parent_project_process_id INT,
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
        - Used to inspect process-table scope or support legacy/table-level
          orchestration patterns.

        Typical usage:
        - In v1, SSIS could transform this result into table/container run flags.
        - In v2, process-level orchestration should prefer:
            metadata.ufn_list_project_process_children
            metadata.ufn_list_project_process_actions
        - This function remains useful when table context is needed for a process.

        Parameters:
        - @p_project_id:
            Project being executed.

        - @p_parent_project_process_id:
            Parent process whose child processes should be listed.

        - @p_batch_column_active:
            0 = return non-batch table flows.
            1 = return batch-enabled table flows.
    */

    SELECT
        p1.[id] AS [parent_project_process_id],
        p1.[name] AS [parent_project_process_name],
        p2.[id] AS [child_project_process_id],
        p2.[name] AS [child_project_process_name],
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
    AND p1.[id] = @p_parent_project_process_id
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

CREATE OR ALTER FUNCTION [metadata].[ufn_list_project_process_descendants]
(
    @p_root_project_process_id INT
)
RETURNS TABLE
AS
RETURN
(
    /*
        Purpose:
        - Lists all active descendant project processes under a selected root
          project process.
        - Starts from one project_processes.id and returns its children,
          grandchildren, and deeper descendants until the last hierarchy level.
        - Used by orchestration logic to inspect process hierarchy and identify
          descendant processes that may require execution.

        Typical usage:
        - A parent ETL package or pipeline calls this function to understand
          the process tree below a selected root process.
        - The result can be used to inspect:
            - hierarchy depth
            - direct process/table scope
            - direct execution_required flag
            - dependency presence
        - The root process itself is not returned.

        Parameters:
        - @p_root_project_process_id:
            Root project process used as the hierarchy scope anchor.
            This value references metadata.project_processes.id.

        Important:
        - project_process refers to records in metadata.project_processes.
        - hierarchy_level describes structural depth under the selected root.
        - hierarchy_path is a technical path used for recursive traversal and
          debugging. It should not be interpreted as execution order.
        - table_count counts active controlled tables directly assigned to the
          returned process.
        - execution_required is derived only from tables directly assigned to the
          returned process through metadata.project_process_tables. It does not
          roll up execution_required from descendant processes.
        - dependency_count counts active dependency processes in the same project.
          It does not list dependency details.
        - has_dependencies is derived from dependency_count.
        - This function does not calculate dependency levels or execution ranks.
        - Use a dependency-detail query/function to see which exact processes
          each process depends on.
    */

    WITH root_process AS
    (
        SELECT
            p.[project_id],
            p.[id] AS [root_project_process_id],
            p.[name] AS [root_project_process_name]
        FROM [metadata].[project_processes] p
        WHERE p.[id] = @p_root_project_process_id
        AND p.[is_active] = 1
    ),
    process_tree AS
    (
        SELECT
            rp.[project_id],
            rp.[root_project_process_id],
            rp.[root_project_process_name],
            p.[id] AS [project_process_id],
            p.[name] AS [project_process_name],
            p.[parent_process_id],
            CAST(1 AS INT) AS [hierarchy_level],
            CAST
            (
                '/'
                + CAST(rp.[root_project_process_id] AS VARCHAR(20))
                + '/'
                + CAST(p.[id] AS VARCHAR(20))
                + '/'
                AS VARCHAR(MAX)
            ) AS [hierarchy_path]
        FROM root_process rp
        INNER JOIN [metadata].[project_processes] p
            ON p.[parent_process_id] = rp.[root_project_process_id]
            AND p.[project_id] = rp.[project_id]
            AND p.[is_active] = 1

        UNION ALL

        SELECT
            pt.[project_id],
            pt.[root_project_process_id],
            pt.[root_project_process_name],
            p.[id] AS [project_process_id],
            p.[name] AS [project_process_name],
            p.[parent_process_id],
            pt.[hierarchy_level] + 1 AS [hierarchy_level],
            CAST
            (
                pt.[hierarchy_path]
                + CAST(p.[id] AS VARCHAR(20))
                + '/'
                AS VARCHAR(MAX)
            ) AS [hierarchy_path]
        FROM process_tree pt
        INNER JOIN [metadata].[project_processes] p
            ON p.[parent_process_id] = pt.[project_process_id]
            AND p.[project_id] = pt.[project_id]
            AND p.[is_active] = 1
        WHERE CHARINDEX
        (
            '/' + CAST(p.[id] AS VARCHAR(20)) + '/',
            pt.[hierarchy_path]
        ) = 0
    ),
    process_table_scope AS
    (
        SELECT
            ptree.[project_process_id],
            COUNT(t.[id]) AS [table_count],
            CAST
            (
                ISNULL(MAX(CAST(t.[execution_required] AS TINYINT)), 0)
                AS BIT
            ) AS [execution_required]
        FROM process_tree ptree
        LEFT JOIN [metadata].[project_process_tables] ppt
            ON ppt.[process_id] = ptree.[project_process_id]
        LEFT JOIN [metadata].[project_tables] t
            ON t.[id] = ppt.[table_id]
            AND t.[is_active] = 1
        GROUP BY
            ptree.[project_process_id]
    ),
    dependency_summary AS
    (
        SELECT
            ptree.[project_process_id],
            COUNT(dependency_p.[id]) AS [dependency_count]
        FROM process_tree ptree
        LEFT JOIN [metadata].[project_process_dependencies] d
            ON d.[project_process_id] = ptree.[project_process_id]
        LEFT JOIN [metadata].[project_processes] dependency_p
            ON dependency_p.[id] = d.[dependency_project_process_id]
            AND dependency_p.[project_id] = ptree.[project_id]
            AND dependency_p.[is_active] = 1
        GROUP BY
            ptree.[project_process_id]
    )
    SELECT
        ptree.[project_id],
        ptree.[root_project_process_id],
        ptree.[root_project_process_name],
        ptree.[project_process_id],
        ptree.[project_process_name],
        ptree.[parent_process_id],
        parent_p.[name] AS [parent_process_name],
        ptree.[hierarchy_level],
        pts.[table_count],
        pts.[execution_required],
        ds.[dependency_count],
        CAST
        (
            CASE
                WHEN ds.[dependency_count] > 0 THEN 1
                ELSE 0
            END AS BIT
        ) AS [has_dependencies],
        ptree.[hierarchy_path]
    FROM process_tree ptree
    LEFT JOIN [metadata].[project_processes] parent_p
        ON parent_p.[id] = ptree.[parent_process_id]
    INNER JOIN process_table_scope pts
        ON pts.[project_process_id] = ptree.[project_process_id]
    INNER JOIN dependency_summary ds
        ON ds.[project_process_id] = ptree.[project_process_id]
);
GO
