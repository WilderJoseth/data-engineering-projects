/*
    Script name
        01_drop_programmable_objects.sql

    Purpose
        Safely drops stored procedures and functions from the Sales_Operational
        database before table or schema cleanup.

    Safety rules
        - Drops validation, load, cleanup, reconciliation, and status routines.
        - Uses DROP ... IF EXISTS so the script can be re-run.
*/

USE [Sales_Operational];
GO

DROP PROCEDURE IF EXISTS [prod].[usp_load_SalesOrder];
DROP PROCEDURE IF EXISTS [prod].[usp_load_Currency];
DROP PROCEDURE IF EXISTS [prod].[usp_load_Geography];
DROP PROCEDURE IF EXISTS [prod].[usp_load_ShipMethod];
DROP PROCEDURE IF EXISTS [prod].[usp_load_SpecialOffer];
DROP PROCEDURE IF EXISTS [prod].[usp_load_ProductCategory];
DROP PROCEDURE IF EXISTS [prod].[usp_load_AddressType];
DROP PROCEDURE IF EXISTS [prod].[usp_load_Customer];
DROP PROCEDURE IF EXISTS [prod].[usp_load_SalesPerson];
DROP PROCEDURE IF EXISTS [prod].[usp_load_Product];
DROP PROCEDURE IF EXISTS [prod].[usp_load_Address];
DROP PROCEDURE IF EXISTS [prod].[usp_load_CreditCard];
GO

DROP PROCEDURE IF EXISTS [work].[usp_validate_SalesOrder];
DROP PROCEDURE IF EXISTS [work].[usp_validate_Currency];
DROP PROCEDURE IF EXISTS [work].[usp_validate_Geography];
DROP PROCEDURE IF EXISTS [work].[usp_validate_SpecialOffer];
DROP PROCEDURE IF EXISTS [work].[usp_validate_ShipMethod];
DROP PROCEDURE IF EXISTS [work].[usp_validate_ProductCategory];
DROP PROCEDURE IF EXISTS [work].[usp_validate_AddressType];
DROP PROCEDURE IF EXISTS [work].[usp_validate_Customer];
DROP PROCEDURE IF EXISTS [work].[usp_validate_SalesPerson];
DROP PROCEDURE IF EXISTS [work].[usp_validate_Product];
DROP PROCEDURE IF EXISTS [work].[usp_validate_Address];
DROP PROCEDURE IF EXISTS [work].[usp_validate_CreditCard];
GO

DROP PROCEDURE IF EXISTS [control].[usp_cleanup_SalesOrder];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_Currency];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_Geography];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_SpecialOffer];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_ShipMethod];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_ProductCategory];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_AddressType];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_Customer];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_SalesPerson];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_Product];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_Address];
DROP PROCEDURE IF EXISTS [control].[usp_cleanup_CreditCard];
GO

DROP FUNCTION IF EXISTS [control].[ufn_get_SalesOrder_load_status_code];
DROP FUNCTION IF EXISTS [control].[ufn_get_status_code_from_reconciliation_results];
DROP FUNCTION IF EXISTS [control].[ufn_get_AddressType_load_status_code];
DROP FUNCTION IF EXISTS [control].[ufn_get_ProductCategory_load_status_code];
DROP FUNCTION IF EXISTS [control].[ufn_get_ShipMethod_load_status_code];
DROP FUNCTION IF EXISTS [control].[ufn_get_SpecialOffer_load_status_code];
DROP FUNCTION IF EXISTS [control].[ufn_get_Geography_load_status_code];
DROP FUNCTION IF EXISTS [control].[ufn_get_Currency_load_status_code];
DROP FUNCTION IF EXISTS [control].[ufn_get_CreditCard_load_status_code];
DROP FUNCTION IF EXISTS [control].[ufn_get_Address_load_status_code];
DROP FUNCTION IF EXISTS [control].[ufn_get_Product_load_status_code];
DROP FUNCTION IF EXISTS [control].[ufn_get_SalesPerson_load_status_code];
DROP FUNCTION IF EXISTS [control].[ufn_get_Customer_load_status_code];
GO

DROP FUNCTION IF EXISTS [control].[ufn_get_SalesOrder_reconciliation_results];
DROP FUNCTION IF EXISTS [control].[ufn_get_AddressType_reconciliation_results];
DROP FUNCTION IF EXISTS [control].[ufn_get_ProductCategory_reconciliation_results];
DROP FUNCTION IF EXISTS [control].[ufn_get_ShipMethod_reconciliation_results];
DROP FUNCTION IF EXISTS [control].[ufn_get_SpecialOffer_reconciliation_results];
DROP FUNCTION IF EXISTS [control].[ufn_get_Geography_reconciliation_results];
DROP FUNCTION IF EXISTS [control].[ufn_get_Currency_reconciliation_results];
DROP FUNCTION IF EXISTS [control].[ufn_get_CreditCard_reconciliation_results];
DROP FUNCTION IF EXISTS [control].[ufn_get_Address_reconciliation_results];
DROP FUNCTION IF EXISTS [control].[ufn_get_Product_reconciliation_results];
DROP FUNCTION IF EXISTS [control].[ufn_get_SalesPerson_reconciliation_results];
DROP FUNCTION IF EXISTS [control].[ufn_get_Customer_reconciliation_results];
GO
