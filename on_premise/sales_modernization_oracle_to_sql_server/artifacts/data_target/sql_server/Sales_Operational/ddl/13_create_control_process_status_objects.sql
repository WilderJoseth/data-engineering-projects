/*
    Script name
        13_create_control_process_status_objects.sql

    Purpose
        Creates control functions that derive process completion status from reconciliation and validation results.

    Scope
        Functions return a status code id that can be passed to DataOps_Control execution-step finalization.
*/

USE [Sales_Operational];
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_status_code_from_reconciliation_results] (
    @execution_step_id BIGINT,
    @has_reconciliation_mismatch BIT
)
RETURNS SMALLINT
AS
BEGIN
    DECLARE @success_status_code_id SMALLINT;
    DECLARE @observed_status_code_id SMALLINT;
    DECLARE @has_observed_validation BIT = 0;
    DECLARE @status_code_id SMALLINT;

    SELECT @success_status_code_id = [id]
    FROM [control].[status_codes]
    WHERE [code] = 'Success';

    SELECT @observed_status_code_id = [id]
    FROM [control].[status_codes]
    WHERE [code] = 'Observed';

    IF EXISTS (
        SELECT 1
        FROM [control].[validation_results] AS validation_result
        INNER JOIN [control].[validation_codes] AS validation_code
            ON validation_code.[id] = validation_result.[validation_code_id]
        WHERE validation_result.[execution_step_id] = @execution_step_id
          AND validation_result.[affected_row_count] > 0
          AND UPPER(validation_code.[severity]) <> 'INFO'
    )
    BEGIN
        SET @has_observed_validation = 1;
    END;

    SET @status_code_id =
        CASE
            WHEN @success_status_code_id IS NULL
              OR @observed_status_code_id IS NULL THEN NULL
            WHEN @has_reconciliation_mismatch = 1
              OR @has_observed_validation = 1 THEN @observed_status_code_id
            ELSE @success_status_code_id
        END;

    RETURN @status_code_id;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_AddressType_load_status_code] (
    @execution_step_id BIGINT
)
RETURNS SMALLINT
AS
BEGIN
    DECLARE @has_reconciliation_mismatch BIT = 0;

    IF (
        SELECT [metric_value_bigint]
        FROM [control].[ufn_get_AddressType_reconciliation_results]('SOURCE', @execution_step_id)
        WHERE [reconciliation_key] = 'TABLE=AddressType'
    ) <> (
        SELECT [metric_value_bigint]
        FROM [control].[ufn_get_AddressType_reconciliation_results]('TARGET', @execution_step_id)
        WHERE [reconciliation_key] = 'TABLE=AddressType'
    )
    BEGIN
        SET @has_reconciliation_mismatch = 1;
    END;

    DECLARE @status_code_id SMALLINT = [control].[ufn_get_status_code_from_reconciliation_results](@execution_step_id, @has_reconciliation_mismatch);

    RETURN @status_code_id;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_ProductCategory_load_status_code] (
    @execution_step_id BIGINT
)
RETURNS SMALLINT
AS
BEGIN
    DECLARE @has_reconciliation_mismatch BIT = 0;

    IF (
        SELECT [metric_value_bigint]
        FROM [control].[ufn_get_ProductCategory_reconciliation_results]('SOURCE', @execution_step_id)
        WHERE [reconciliation_key] = 'TABLE=ProductCategory'
    ) <> (
        SELECT [metric_value_bigint]
        FROM [control].[ufn_get_ProductCategory_reconciliation_results]('TARGET', @execution_step_id)
        WHERE [reconciliation_key] = 'TABLE=ProductCategory'
    )
    BEGIN
        SET @has_reconciliation_mismatch = 1;
    END;

    DECLARE @status_code_id SMALLINT = [control].[ufn_get_status_code_from_reconciliation_results](@execution_step_id, @has_reconciliation_mismatch);

    RETURN @status_code_id;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_ShipMethod_load_status_code] (
    @execution_step_id BIGINT
)
RETURNS SMALLINT
AS
BEGIN
    DECLARE @has_reconciliation_mismatch BIT = 0;

    IF (
        SELECT [metric_value_bigint]
        FROM [control].[ufn_get_ShipMethod_reconciliation_results]('SOURCE', @execution_step_id)
        WHERE [reconciliation_key] = 'TABLE=ShipMethod'
    ) <> (
        SELECT [metric_value_bigint]
        FROM [control].[ufn_get_ShipMethod_reconciliation_results]('TARGET', @execution_step_id)
        WHERE [reconciliation_key] = 'TABLE=ShipMethod'
    )
    BEGIN
        SET @has_reconciliation_mismatch = 1;
    END;

    DECLARE @status_code_id SMALLINT = [control].[ufn_get_status_code_from_reconciliation_results](@execution_step_id, @has_reconciliation_mismatch);

    RETURN @status_code_id;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_SpecialOffer_load_status_code] (
    @execution_step_id BIGINT
)
RETURNS SMALLINT
AS
BEGIN
    DECLARE @has_reconciliation_mismatch BIT = 0;

    IF (
        SELECT [metric_value_bigint]
        FROM [control].[ufn_get_SpecialOffer_reconciliation_results]('SOURCE', @execution_step_id)
        WHERE [reconciliation_key] = 'TABLE=SpecialOffer'
    ) <> (
        SELECT [metric_value_bigint]
        FROM [control].[ufn_get_SpecialOffer_reconciliation_results]('TARGET', @execution_step_id)
        WHERE [reconciliation_key] = 'TABLE=SpecialOffer'
    )
    BEGIN
        SET @has_reconciliation_mismatch = 1;
    END;

    DECLARE @status_code_id SMALLINT = [control].[ufn_get_status_code_from_reconciliation_results](@execution_step_id, @has_reconciliation_mismatch);

    RETURN @status_code_id;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_Geography_load_status_code] (
    @execution_step_id BIGINT
)
RETURNS SMALLINT
AS
BEGIN
    DECLARE @has_reconciliation_mismatch BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM [control].[ufn_get_Geography_reconciliation_results]('SOURCE', @execution_step_id) AS source_result
        INNER JOIN [control].[ufn_get_Geography_reconciliation_results]('TARGET', @execution_step_id) AS target_result
            ON target_result.[metric_name] = source_result.[metric_name]
           AND target_result.[reconciliation_key] = source_result.[reconciliation_key]
        WHERE source_result.[metric_name] = 'ROW_COUNT'
          AND source_result.[metric_value_bigint] <> target_result.[metric_value_bigint]
    )
    BEGIN
        SET @has_reconciliation_mismatch = 1;
    END;

    DECLARE @status_code_id SMALLINT = [control].[ufn_get_status_code_from_reconciliation_results](@execution_step_id, @has_reconciliation_mismatch);

    RETURN @status_code_id;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_Currency_load_status_code] (
    @execution_step_id BIGINT
)
RETURNS SMALLINT
AS
BEGIN
    DECLARE @has_reconciliation_mismatch BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM [control].[ufn_get_Currency_reconciliation_results]('SOURCE', @execution_step_id) AS source_result
        INNER JOIN [control].[ufn_get_Currency_reconciliation_results]('TARGET', @execution_step_id) AS target_result
            ON target_result.[metric_name] = source_result.[metric_name]
           AND target_result.[reconciliation_key] = source_result.[reconciliation_key]
        WHERE source_result.[metric_name] = 'ROW_COUNT'
          AND source_result.[metric_value_bigint] <> target_result.[metric_value_bigint]
    )
    BEGIN
        SET @has_reconciliation_mismatch = 1;
    END;

    DECLARE @status_code_id SMALLINT = [control].[ufn_get_status_code_from_reconciliation_results](@execution_step_id, @has_reconciliation_mismatch);

    RETURN @status_code_id;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_CreditCard_load_status_code] (
    @execution_step_id BIGINT
)
RETURNS SMALLINT
AS
BEGIN
    DECLARE @has_reconciliation_mismatch BIT = 0;

    IF (
        SELECT [metric_value_bigint]
        FROM [control].[ufn_get_CreditCard_reconciliation_results]('SOURCE', @execution_step_id)
        WHERE [reconciliation_key] = 'TABLE=CreditCard'
    ) <> (
        SELECT [metric_value_bigint]
        FROM [control].[ufn_get_CreditCard_reconciliation_results]('TARGET', @execution_step_id)
        WHERE [reconciliation_key] = 'TABLE=CreditCard'
    )
    BEGIN
        SET @has_reconciliation_mismatch = 1;
    END;

    DECLARE @status_code_id SMALLINT = [control].[ufn_get_status_code_from_reconciliation_results](@execution_step_id, @has_reconciliation_mismatch);

    RETURN @status_code_id;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_Address_load_status_code] (
    @execution_step_id BIGINT
)
RETURNS SMALLINT
AS
BEGIN
    DECLARE @has_reconciliation_mismatch BIT = 0;

    IF (
        SELECT [metric_value_bigint]
        FROM [control].[ufn_get_Address_reconciliation_results]('SOURCE', @execution_step_id)
        WHERE [reconciliation_key] = 'TABLE=Address'
    ) <> (
        SELECT [metric_value_bigint]
        FROM [control].[ufn_get_Address_reconciliation_results]('TARGET', @execution_step_id)
        WHERE [reconciliation_key] = 'TABLE=Address'
    )
    BEGIN
        SET @has_reconciliation_mismatch = 1;
    END;

    DECLARE @status_code_id SMALLINT = [control].[ufn_get_status_code_from_reconciliation_results](@execution_step_id, @has_reconciliation_mismatch);

    RETURN @status_code_id;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_Product_load_status_code] (
    @execution_step_id BIGINT
)
RETURNS SMALLINT
AS
BEGIN
    DECLARE @has_reconciliation_mismatch BIT = 0;

    IF (
        SELECT [metric_value_bigint]
        FROM [control].[ufn_get_Product_reconciliation_results]('SOURCE', @execution_step_id)
        WHERE [reconciliation_key] = 'TABLE=Product'
    ) <> (
        SELECT [metric_value_bigint]
        FROM [control].[ufn_get_Product_reconciliation_results]('TARGET', @execution_step_id)
        WHERE [reconciliation_key] = 'TABLE=Product'
    )
    BEGIN
        SET @has_reconciliation_mismatch = 1;
    END;

    DECLARE @status_code_id SMALLINT = [control].[ufn_get_status_code_from_reconciliation_results](@execution_step_id, @has_reconciliation_mismatch);

    RETURN @status_code_id;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_SalesPerson_load_status_code] (
    @execution_step_id BIGINT
)
RETURNS SMALLINT
AS
BEGIN
    DECLARE @has_reconciliation_mismatch BIT = 0;

    IF (
        SELECT [metric_value_bigint]
        FROM [control].[ufn_get_SalesPerson_reconciliation_results]('SOURCE', @execution_step_id)
        WHERE [reconciliation_key] = 'TABLE=SalesPerson'
    ) <> (
        SELECT [metric_value_bigint]
        FROM [control].[ufn_get_SalesPerson_reconciliation_results]('TARGET', @execution_step_id)
        WHERE [reconciliation_key] = 'TABLE=SalesPerson'
    )
    BEGIN
        SET @has_reconciliation_mismatch = 1;
    END;

    DECLARE @status_code_id SMALLINT = [control].[ufn_get_status_code_from_reconciliation_results](@execution_step_id, @has_reconciliation_mismatch);

    RETURN @status_code_id;
END;
GO

CREATE OR ALTER FUNCTION [control].[ufn_get_Customer_load_status_code] (
    @execution_step_id BIGINT
)
RETURNS SMALLINT
AS
BEGIN
    DECLARE @has_reconciliation_mismatch BIT = 0;

    IF (
        SELECT [metric_value_bigint]
        FROM [control].[ufn_get_Customer_reconciliation_results]('SOURCE', @execution_step_id)
        WHERE [reconciliation_key] = 'TABLE=Customer'
    ) <> (
        SELECT [metric_value_bigint]
        FROM [control].[ufn_get_Customer_reconciliation_results]('TARGET', @execution_step_id)
        WHERE [reconciliation_key] = 'TABLE=Customer'
    )
    BEGIN
        SET @has_reconciliation_mismatch = 1;
    END;

    DECLARE @status_code_id SMALLINT = [control].[ufn_get_status_code_from_reconciliation_results](@execution_step_id, @has_reconciliation_mismatch);

    RETURN @status_code_id;
END;
GO
