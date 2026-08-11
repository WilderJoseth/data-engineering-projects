-- WARNING:
-- This script is destructive and intended only for the local Oracle XE Docker environment.
-- Do not execute against shared, UAT, certification, or production databases.
-- =============================================================================
-- Purpose          : Delete only base-seed transactional and audit rows.
-- Execution order  : 01 of 05.
-- Connection user  : SYSTEM; CURRENT_SCHEMA is set to ADVENTUREWORKS2022.
-- Tables affected  : Sales/purchasing transactions, production work/history,
--                    shopping carts, and synthetic DBO log rows.
-- Notes            : Child rows are deleted before their parents.
-- =============================================================================

ALTER SESSION SET CURRENT_SCHEMA = ADVENTUREWORKS2022;

DELETE FROM SALES_SALESORDERHEADERSALESREASON WHERE SALESORDERID BETWEEN 1001 AND 1006;
DELETE FROM SALES_SALESORDERDETAIL WHERE SALESORDERID BETWEEN 1001 AND 1006;
DELETE FROM SALES_SALESORDERHEADER WHERE SALESORDERID BETWEEN 1001 AND 1006;
DELETE FROM SALES_SHOPPINGCARTITEM WHERE SHOPPINGCARTITEMID IN (1, 2);

DELETE FROM PURCHASING_PURCHASEORDERDETAIL WHERE PURCHASEORDERID IN (1, 2);
DELETE FROM PURCHASING_PURCHASEORDERHEADER WHERE PURCHASEORDERID IN (1, 2);

DELETE FROM PRODUCTION_WORKORDERROUTING WHERE WORKORDERID = 1;
DELETE FROM PRODUCTION_WORKORDER WHERE WORKORDERID = 1;
DELETE FROM PRODUCTION_TRANSACTIONHISTORY WHERE TRANSACTIONID IN (1, 2);
DELETE FROM PRODUCTION_TRANSACTIONHISTORYARCHIVE WHERE TRANSACTIONID = 9001;

DELETE FROM DBO_DATABASELOG WHERE DATABASELOGID = 1;
DELETE FROM DBO_ERRORLOG WHERE ERRORLOGID = 1;

COMMIT;

PROMPT [01] Seeded transactional data removed.
