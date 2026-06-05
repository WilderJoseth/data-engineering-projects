/*
    Script name
        97_drop_process_stored_procedures.sql

    Purpose
        Safely drops stored procedures used by reference and master data load
        processes in the Sales_Operational database.

    Safety rules
        - Drops process cleanup procedures from the control schema.
        - Drops process validation procedures from the work schema.
        - Uses DROP PROCEDURE IF EXISTS so the script can be re-run.

    Usage warning
        This script removes procedure definitions only. It does not remove
        staging, work, control, or prod table data.
*/

USE [Sales_Operational];
GO

DROP PROCEDURE IF EXISTS [work].[usp_validate_Currency];
DROP PROCEDURE IF EXISTS [work].[usp_validate_Geography];
DROP PROCEDURE IF EXISTS [work].[usp_validate_SpecialOffer];
DROP PROCEDURE IF EXISTS [work].[usp_validate_ShipMethod];
DROP PROCEDURE IF EXISTS [work].[usp_validate_ProductCategory];
DROP PROCEDURE IF EXISTS [work].[usp_validate_AddressType];

DROP PROCEDURE IF EXISTS [control].[usp_cleanup_Currency];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_Geography];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_SpecialOffer];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_ShipMethod];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_ProductCategory];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_AddressType];
GO

DROP PROCEDURE IF EXISTS [work].[usp_validate_Customer];
DROP PROCEDURE IF EXISTS [work].[usp_validate_SalesOrder];
DROP PROCEDURE IF EXISTS [work].[usp_validate_SalesPerson];
DROP PROCEDURE IF EXISTS [work].[usp_validate_Product];
DROP PROCEDURE IF EXISTS [work].[usp_validate_Address];
DROP PROCEDURE IF EXISTS [work].[usp_validate_CreditCard];

DROP PROCEDURE IF EXISTS [control].[usp_cleanup_Customer];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_SalesOrder];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_SalesPerson];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_Product];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_Address];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_CreditCard];
GO

DROP PROCEDURE IF EXISTS [prod].[usp_load_SalesOrder];
GO
