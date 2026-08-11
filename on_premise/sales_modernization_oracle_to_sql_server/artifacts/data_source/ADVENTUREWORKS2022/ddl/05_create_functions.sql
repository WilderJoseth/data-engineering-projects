-- =============================================================================
-- Purpose          : Create portable helper functions used by the Oracle source
--                    simulation.
-- Execution order  : 05 of 07; run after 04_create_indexes.sql.
-- Connection user  : SYSTEM; CURRENT_SCHEMA is set to ADVENTUREWORKS2022.
-- Objects affected : DBO_UFNGETACCOUNTINGSTARTDATE,
--                    DBO_UFNGETACCOUNTINGENDDATE, DBO_UFNLEADINGZEROS,
--                    status-text helpers, and DBO_UFNGETSTOCK.
-- Notes            : Only helpers with useful and maintainable Oracle XE 21c
--                    equivalents are included.
-- =============================================================================

ALTER SESSION SET CURRENT_SCHEMA = ADVENTUREWORKS2022;

-- Accounting-period helpers
CREATE OR REPLACE FUNCTION DBO_UFNGETACCOUNTINGSTARTDATE
  RETURN DATE
IS
BEGIN
  RETURN DATE '2002-07-01';
END;
/

CREATE OR REPLACE FUNCTION DBO_UFNGETACCOUNTINGENDDATE
  RETURN DATE
IS
BEGIN
  RETURN DATE '2003-06-30';
END;
/

-- Identifier formatting helper
CREATE OR REPLACE FUNCTION DBO_UFNLEADINGZEROS (
  P_VALUE IN NUMBER
)
  RETURN VARCHAR2
  DETERMINISTIC
IS
BEGIN
  RETURN LPAD(TO_CHAR(P_VALUE), 8, '0');
END;
/

-- Status-code description helpers
CREATE OR REPLACE FUNCTION DBO_UFNGETDOCUMENTSTATUSTEXT (
  P_STATUS IN NUMBER
)
  RETURN VARCHAR2
  DETERMINISTIC
IS
BEGIN
  RETURN CASE P_STATUS
           WHEN 1 THEN 'Pending approval'
           WHEN 2 THEN 'Approved'
           WHEN 3 THEN 'Obsolete'
           ELSE 'Invalid'
         END;
END;
/

CREATE OR REPLACE FUNCTION DBO_UFNGETPURCHASEORDERSTATUSTEXT (
  P_STATUS IN NUMBER
)
  RETURN VARCHAR2
  DETERMINISTIC
IS
BEGIN
  RETURN CASE P_STATUS
           WHEN 1 THEN 'Pending'
           WHEN 2 THEN 'Approved'
           WHEN 3 THEN 'Rejected'
           WHEN 4 THEN 'Complete'
           ELSE 'Invalid'
         END;
END;
/

CREATE OR REPLACE FUNCTION DBO_UFNGETSALESORDERSTATUSTEXT (
  P_STATUS IN NUMBER
)
  RETURN VARCHAR2
  DETERMINISTIC
IS
BEGIN
  RETURN CASE P_STATUS
           WHEN 0 THEN 'In process'
           WHEN 1 THEN 'Approved'
           WHEN 2 THEN 'Backordered'
           WHEN 3 THEN 'Rejected'
           WHEN 4 THEN 'Shipped'
           WHEN 5 THEN 'Cancelled'
           ELSE 'Invalid'
         END;
END;
/

-- Inventory helper; location 6 is the legacy miscellaneous-storage location
CREATE OR REPLACE FUNCTION DBO_UFNGETSTOCK (
  P_PRODUCTID IN NUMBER
)
  RETURN NUMBER
IS
  V_STOCK NUMBER;
BEGIN
  SELECT NVL(SUM(QUANTITY), 0)
  INTO V_STOCK
  FROM PRODUCTION_PRODUCTINVENTORY
  WHERE PRODUCTID = P_PRODUCTID
    AND LOCATIONID = 6;

  RETURN V_STOCK;
END;
/

-- Deliberately omitted SQL Server helpers
-- Skipped: UFNGETCONTACTINFORMATION (SQL Server multi-statement table function);
-- dealer/list-price and standard-cost functions use TOP/order semantics that are
-- better represented by direct effective-date queries in this simulation.
