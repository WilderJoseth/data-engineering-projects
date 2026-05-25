/*
    Script: 09_create_security.sql
    Database: DataOps_Control

    Purpose:
    - Creates database roles used by the DataOps_Control framework.
    - Grants permissions required by framework administrators and project execution accounts.

    Security model:
    - DataOps_Admin:
        Used by framework maintainers or deployment scripts.
        Can maintain metadata, reference data, runtime records, and observability records.

    - DataOps_Project_Executor:
        Used by ETL/ELT project service accounts.
        Can read metadata and reference data, execute runtime procedures,
        log technical errors, and publish validation/reconciliation evidence.

    Important:
    - This script does not create SQL Server logins or database users.
    - Each consuming project should create or use its own login/service account.
    - That login/service account should be mapped to a database user in DataOps_Control.
    - The database user should then be added to DataOps_Project_Executor.
    - Project execution accounts should not directly modify metadata or reference data.
*/

USE [DataOps_Control];
GO

/*==============================================================
    1. Create database roles
==============================================================*/

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE [name] = 'DataOps_Admin'
      AND [type] = 'R'
)
BEGIN
    CREATE ROLE [DataOps_Admin];
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE [name] = 'DataOps_Project_Executor'
      AND [type] = 'R'
)
BEGIN
    CREATE ROLE [DataOps_Project_Executor];
END;
GO

/*==============================================================
    2. DataOps_Admin permissions

    This role is intended for:
    - Framework maintainers.
    - Controlled deployment scripts.
    - Administrative users responsible for framework configuration.

    This role can:
    - Maintain metadata and reference data.
    - Read and maintain runtime and observability records.
    - Execute framework procedures.
==============================================================*/

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[metadata] TO [DataOps_Admin];
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[reference] TO [DataOps_Admin];
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[runtime] TO [DataOps_Admin];
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[observability] TO [DataOps_Admin];

GRANT EXECUTE ON SCHEMA::[runtime] TO [DataOps_Admin];
GRANT EXECUTE ON SCHEMA::[observability] TO [DataOps_Admin];
GO

/*==============================================================
    3. DataOps_Project_Executor permissions

    This role is intended for:
    - SSIS packages.
    - SQL Server Agent jobs.
    - Azure Data Factory pipelines.
    - Fabric Data Pipelines.
    - Other ETL/ELT project service accounts.

    This role can:
    - Read framework metadata and reference values.
    - Execute runtime procedures.
    - Execute observability procedures such as technical error logging.
    - Insert validation and reconciliation evidence.
    - Read runtime and observability history for troubleshooting.

    This role should not:
    - Modify metadata configuration.
    - Modify reference values.
    - Directly update runtime records outside controlled procedures.
==============================================================*/

GRANT SELECT ON SCHEMA::[metadata] TO [DataOps_Project_Executor];
GRANT SELECT ON SCHEMA::[reference] TO [DataOps_Project_Executor];

GRANT EXECUTE ON SCHEMA::[runtime] TO [DataOps_Project_Executor];
GRANT EXECUTE ON SCHEMA::[observability] TO [DataOps_Project_Executor];

GRANT INSERT ON [observability].[validation_results] TO [DataOps_Project_Executor];
GRANT INSERT ON [observability].[reconciliation_results] TO [DataOps_Project_Executor];

GRANT SELECT ON SCHEMA::[runtime] TO [DataOps_Project_Executor];
GRANT SELECT ON SCHEMA::[observability] TO [DataOps_Project_Executor];
GO