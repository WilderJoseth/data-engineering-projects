-- =============================================================================
-- Purpose          : Create selective secondary indexes for source extraction,
--                    joins, operational lookup, and reporting access paths.
-- Execution order  : 04 of 07; run after 03_create_constraints.sql.
-- Connection user  : SYSTEM; CURRENT_SCHEMA is set to ADVENTUREWORKS2022.
-- Objects affected : Secondary indexes IX_AW_01 through IX_AW_20.
-- Notes            : Primary-key and unique indexes are created by constraints.
--                    This is a deliberately modest legacy-source index set, not
--                    an idealized target-platform design.
-- =============================================================================

ALTER SESSION SET CURRENT_SCHEMA = ADVENTUREWORKS2022;

-- Sales extraction and operational joins

-- Historical/monthly sales extraction.
CREATE INDEX IX_AW_01 ON SALES_SALESORDERHEADER (ORDERDATE);

-- Incremental extraction watermark used by later integrations.
CREATE INDEX IX_AW_02 ON SALES_SALESORDERHEADER (MODIFIEDDATE);

-- Operational customer-order lookup and join.
CREATE INDEX IX_AW_03 ON SALES_SALESORDERHEADER (CUSTOMERID);

-- High-volume header-to-line join.
CREATE INDEX IX_AW_04 ON SALES_SALESORDERDETAIL (SALESORDERID);

-- Product sales reporting lookup.
CREATE INDEX IX_AW_05 ON SALES_SALESORDERDETAIL (PRODUCTID);

-- Customer-to-person resolution.
CREATE INDEX IX_AW_06 ON SALES_CUSTOMER (PERSONID);

-- Territory reporting lookup added for regional reports.
CREATE INDEX IX_AW_07 ON SALES_CUSTOMER (TERRITORYID);

-- Person and address change tracking

-- Incremental person extraction.
CREATE INDEX IX_AW_08 ON PERSON_PERSON (MODIFIEDDATE);

-- Address geography join.
CREATE INDEX IX_AW_09 ON PERSON_ADDRESS (STATEPROVINCEID);

-- Incremental address extraction.
CREATE INDEX IX_AW_10 ON PERSON_ADDRESS (MODIFIEDDATE);

-- Historical exchange-rate lookup.
CREATE INDEX IX_AW_11 ON SALES_CURRENCYRATE (CURRENCYRATEDATE);

-- Offer effective-date searches.
CREATE INDEX IX_AW_12 ON SALES_SPECIALOFFER (STARTDATE);

-- Offer expiry operational report.
CREATE INDEX IX_AW_13 ON SALES_SPECIALOFFER (ENDDATE);

-- Production and purchasing history and lookup paths

-- Historical inventory extraction.
CREATE INDEX IX_AW_14 ON PRODUCTION_TRANSACTIONHISTORY (TRANSACTIONDATE);

-- Product transaction history lookup.
CREATE INDEX IX_AW_15 ON PRODUCTION_TRANSACTIONHISTORY (PRODUCTID);

-- Historical purchasing extraction.
CREATE INDEX IX_AW_16 ON PURCHASING_PURCHASEORDERHEADER (ORDERDATE);

-- Product procurement analysis.
CREATE INDEX IX_AW_17 ON PURCHASING_PURCHASEORDERDETAIL (PRODUCTID);

-- Legacy address-to-entity join.
CREATE INDEX IX_AW_18 ON PERSON_BUSINESSENTITYADDRESS (ADDRESSID);

-- Catalog category reporting.
CREATE INDEX IX_AW_19 ON PRODUCTION_PRODUCT (PRODUCTSUBCATEGORYID);

-- Vendor purchase-order lookup.
CREATE INDEX IX_AW_20 ON PURCHASING_PURCHASEORDERHEADER (VENDORID);

-- This is not an idealized target index design. Redundant and low-value source indexes were omitted.
