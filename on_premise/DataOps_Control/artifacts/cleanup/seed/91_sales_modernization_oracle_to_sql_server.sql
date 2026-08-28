USE [DataOps_Control];
GO

/*============================================================================
  Cleanup Seed Script: Sales Domain Metadata

  Purpose:
  - Removes the sample metadata loaded by artifacts/seed/02_seed_sales_domain_metadata.sql.

  Notes:
  - Deletes only the fixed sample IDs used by the Sales Domain metadata seed.
  - Run before DDL cleanup if both seed data and framework objects must be removed.
============================================================================*/

DELETE FROM [metadata].[project_process_table_batches]
WHERE [process_id] = 21
  AND [table_id] = 33
  AND [batch_id] BETWEEN 1 AND 5;
GO

DELETE FROM [metadata].[project_table_batches]
WHERE [id] BETWEEN 1 AND 5;
GO

DELETE FROM [metadata].[project_process_tables]
WHERE [process_id] BETWEEN 10 AND 28
  AND [table_id] BETWEEN 19 AND 41;
GO

DELETE FROM [metadata].[project_table_mappings]
WHERE ([table_source_id] BETWEEN 1 AND 18 AND [table_target_id] BETWEEN 19 AND 34)
   OR ([table_source_id] BETWEEN 20 AND 34 AND [table_target_id] BETWEEN 35 AND 41);
GO

DELETE FROM [metadata].[project_tables]
WHERE [id] BETWEEN 1 AND 41;
GO

DELETE FROM [metadata].[project_database_mappings]
WHERE ([database_source_id] = 1 AND [database_target_id] = 2)
   OR ([database_source_id] = 2 AND [database_target_id] = 3);
GO

DELETE FROM [metadata].[project_processes]
WHERE [id] BETWEEN 10 AND 28;
GO

DELETE FROM [metadata].[project_processes]
WHERE [id] BETWEEN 7 AND 9;
GO

DELETE FROM [metadata].[project_processes]
WHERE [id] BETWEEN 3 AND 6;
GO

DELETE FROM [metadata].[project_processes]
WHERE [id] BETWEEN 1 AND 2;
GO

DELETE FROM [metadata].[project_databases]
WHERE [id] BETWEEN 1 AND 3;
GO

DELETE FROM [metadata].[projects]
WHERE [id] = 1;
GO
