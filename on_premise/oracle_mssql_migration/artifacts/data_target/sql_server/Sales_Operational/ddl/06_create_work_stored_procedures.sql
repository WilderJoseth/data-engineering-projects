/*
    Script name
        06_create_work_stored_procedures.sql

    Purpose
        Creates work-schema stored procedures used to validate staging data and
        prepare clean rows for final loads.

    Design rules
        - Validation procedures read from staging tables and write all staged
          rows to work tables with validation flags.
        - Invalid-row summaries are stored in control.validation_results for
          later publication to DataOps_Control.
        - DataOps_Control validation code IDs are received as parameters so this
          project does not hard-code shared reference values.
*/

USE [Sales_Operational];
GO

CREATE OR ALTER PROCEDURE [work].[usp_validate_AddressType]
    @execution_step_id BIGINT,
    @not_null_validation_code_id SMALLINT,
    @duplicate_validation_code_id SMALLINT,
    @length_validation_code_id SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    /*
        AddressType validation flags:
        1. SourceAddressTypeID is required.
        2. Name is required after trimming whitespace.
        3. Name must fit the final VARCHAR(50) target definition.
        4. SourceAddressTypeID must be unique within the current staging set.

        All staged rows are inserted into work.AddressType. Rows are eligible for
        the final prod load only when every flag_valid_* column equals 1.
    */

    BEGIN TRANSACTION;

    INSERT INTO [work].[AddressType] (
        [StagingAddressTypeKey],
        [SourceAddressTypeID],
        [Name],
        [flag_valid_source_address_type_id],
        [flag_valid_name_required],
        [flag_valid_name_length],
        [flag_valid_source_address_type_id_unique]
    )
    SELECT
        src.[StagingAddressTypeKey],
        src.[SourceAddressTypeID],
        src.[Name],
        CASE WHEN src.[SourceAddressTypeID] IS NOT NULL THEN 1 ELSE 0 END AS [flag_valid_source_address_type_id],
        CASE WHEN src.[Name] IS NOT NULL THEN 1 ELSE 0 END AS [flag_valid_name_required],
        CASE WHEN src.[Name] IS NULL OR LEN(src.[Name]) <= 50 THEN 1 ELSE 0 END AS [flag_valid_name_length],
        CASE
            WHEN src.[SourceAddressTypeID] IS NOT NULL
             AND src.[SourceAddressTypeIDCount] = 1 THEN 1
            ELSE 0
        END AS [flag_valid_source_address_type_id_unique]
    FROM (
        SELECT
            s.[StagingAddressTypeKey],
            s.[SourceAddressTypeID],
            NULLIF(TRIM(s.[Name]), '') AS [Name],
            COUNT(*) OVER (PARTITION BY s.[SourceAddressTypeID]) AS [SourceAddressTypeIDCount]
        FROM [staging].[AddressType] AS s
    ) AS src;

    INSERT INTO [control].[validation_results] (
        [details],
        [affected_row_count],
        [execution_step_id],
        [validation_code_id]
    )
    SELECT
        'AddressType Load - SourceAddressTypeID is required.' AS [details],
        COUNT_BIG(*) AS [affected_row_count],
        @execution_step_id AS [execution_step_id],
        @not_null_validation_code_id AS [validation_code_id]
    FROM [work].[AddressType]
    WHERE [flag_valid_source_address_type_id] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] (
        [details],
        [affected_row_count],
        [execution_step_id],
        [validation_code_id]
    )
    SELECT
        'AddressType Load - Name is required.' AS [details],
        COUNT_BIG(*) AS [affected_row_count],
        @execution_step_id AS [execution_step_id],
        @not_null_validation_code_id AS [validation_code_id]
    FROM [work].[AddressType]
    WHERE [flag_valid_name_required] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] (
        [details],
        [affected_row_count],
        [execution_step_id],
        [validation_code_id]
    )
    SELECT
        'AddressType Load - Name exceeds 50 characters.' AS [details],
        COUNT_BIG(*) AS [affected_row_count],
        @execution_step_id AS [execution_step_id],
        @length_validation_code_id AS [validation_code_id]
    FROM [work].[AddressType]
    WHERE [flag_valid_name_length] = 0
    HAVING COUNT_BIG(*) > 0;

    INSERT INTO [control].[validation_results] (
        [details],
        [affected_row_count],
        [execution_step_id],
        [validation_code_id]
    )
    SELECT
        'AddressType Load - SourceAddressTypeID must be unique.' AS [details],
        COUNT_BIG(*) AS [affected_row_count],
        @execution_step_id AS [execution_step_id],
        @duplicate_validation_code_id AS [validation_code_id]
    FROM [work].[AddressType]
    WHERE [flag_valid_source_address_type_id_unique] = 0
      AND [SourceAddressTypeID] IS NOT NULL
    HAVING COUNT_BIG(*) > 0;

    COMMIT TRANSACTION;
END;
GO
