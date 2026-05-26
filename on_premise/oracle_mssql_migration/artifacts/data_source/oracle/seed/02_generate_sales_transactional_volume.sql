/*
    Script name
        02_generate_sales_transactional_volume.sql

    Purpose
        Generates a configurable high-volume Sales transactional dataset for
        migration, batching, reconciliation, and performance testing.

    Design
        - Uses set-based INSERT statements instead of row-by-row loops.
        - Reuses reference/master data from 01_seed_sales_domain_sample_data.sql.
        - Creates additional customers, people, addresses, order headers, and
          order details.
        - Uses deterministic ID ranges so the generated dataset can be cleaned
          and regenerated without touching the compact baseline seed data.

    Default volume
        - 5,000 generated customers.
        - 100,000 generated sales order headers.
        - 500,000 generated sales order details.

    How to scale
        Override the DEFINE values before running in SQL*Plus or SQLcl.
        For example:

            DEFINE customer_count = 20000
            DEFINE order_count = 1000000
            DEFINE details_per_order = 5

    Execution
        Run after 01_seed_sales_domain_sample_data.sql.

    Requirements
        The compact seed must already provide:
        - Country/region, territory, state/province, address type.
        - Salesperson 200.
        - Product 500.
        - Special offer 1.
        - Ship method 5.
        - Credit card 600.
        - Currency rate 700.
*/

SET DEFINE ON;

DEFINE customer_count = 5000;
DEFINE order_count = 100000;
DEFINE details_per_order = 5;

DEFINE base_business_entity_id = 1000000;
DEFINE base_customer_id = 2000000;
DEFINE base_address_id = 3000000;
DEFINE base_sales_order_id = 4000000;

PROMPT Cleaning previous generated high-volume Sales data.

DELETE FROM ADVENTUREWORKS2022.SALES_SALESORDERDETAIL
WHERE SALESORDERID >= &base_sales_order_id
  AND SALESORDERID <  &base_sales_order_id + &order_count;

DELETE FROM ADVENTUREWORKS2022.SALES_SALESORDERHEADER
WHERE SALESORDERID >= &base_sales_order_id
  AND SALESORDERID <  &base_sales_order_id + &order_count;

DELETE FROM ADVENTUREWORKS2022.SALES_CUSTOMER
WHERE CUSTOMERID >= &base_customer_id
  AND CUSTOMERID <  &base_customer_id + &customer_count;

DELETE FROM ADVENTUREWORKS2022.PERSON_BUSINESSENTITYADDRESS
WHERE BUSINESSENTITYID >= &base_business_entity_id
  AND BUSINESSENTITYID <  &base_business_entity_id + &customer_count;

DELETE FROM ADVENTUREWORKS2022.PERSON_ADDRESS
WHERE ADDRESSID >= &base_address_id
  AND ADDRESSID <  &base_address_id + &customer_count;

DELETE FROM ADVENTUREWORKS2022.PERSON_PERSON
WHERE BUSINESSENTITYID >= &base_business_entity_id
  AND BUSINESSENTITYID <  &base_business_entity_id + &customer_count;

DELETE FROM ADVENTUREWORKS2022.PERSON_BUSINESSENTITY
WHERE BUSINESSENTITYID >= &base_business_entity_id
  AND BUSINESSENTITYID <  &base_business_entity_id + &customer_count;

COMMIT;

PROMPT Creating generated customer business entities.

INSERT INTO ADVENTUREWORKS2022.PERSON_BUSINESSENTITY
    (BUSINESSENTITYID)
SELECT
    &base_business_entity_id + LEVEL - 1 AS BUSINESSENTITYID
FROM DUAL
CONNECT BY LEVEL <= &customer_count;

INSERT INTO ADVENTUREWORKS2022.PERSON_PERSON
    (BUSINESSENTITYID, PERSONTYPE, FIRSTNAME, MIDDLENAME, LASTNAME, EMAILPROMOTION)
SELECT
    &base_business_entity_id + LEVEL - 1 AS BUSINESSENTITYID,
    'IN' AS PERSONTYPE,
    'Customer' AS FIRSTNAME,
    NULL AS MIDDLENAME,
    'Generated ' || TO_CHAR(LEVEL) AS LASTNAME,
    MOD(LEVEL, 3) AS EMAILPROMOTION
FROM DUAL
CONNECT BY LEVEL <= &customer_count;

INSERT INTO ADVENTUREWORKS2022.PERSON_ADDRESS
    (ADDRESSID, ADDRESSLINE1, CITY, STATEPROVINCEID, POSTALCODE)
SELECT
    &base_address_id + LEVEL - 1 AS ADDRESSID,
    TO_CHAR(LEVEL) || ' Generated Sales Avenue' AS ADDRESSLINE1,
    CASE MOD(LEVEL, 5)
        WHEN 0 THEN 'Seattle'
        WHEN 1 THEN 'Bellevue'
        WHEN 2 THEN 'Tacoma'
        WHEN 3 THEN 'Redmond'
        ELSE 'Everett'
    END AS CITY,
    79 AS STATEPROVINCEID,
    LPAD(TO_CHAR(98000 + MOD(LEVEL, 900)), 5, '0') AS POSTALCODE
FROM DUAL
CONNECT BY LEVEL <= &customer_count;

INSERT INTO ADVENTUREWORKS2022.PERSON_BUSINESSENTITYADDRESS
    (BUSINESSENTITYID, ADDRESSID, ADDRESSTYPEID)
SELECT
    &base_business_entity_id + LEVEL - 1 AS BUSINESSENTITYID,
    &base_address_id + LEVEL - 1 AS ADDRESSID,
    CASE WHEN MOD(LEVEL, 2) = 0 THEN 1 ELSE 2 END AS ADDRESSTYPEID
FROM DUAL
CONNECT BY LEVEL <= &customer_count;

INSERT INTO ADVENTUREWORKS2022.SALES_CUSTOMER
    (CUSTOMERID, PERSONID, TERRITORYID, ACCOUNTNUMBER)
SELECT
    &base_customer_id + LEVEL - 1 AS CUSTOMERID,
    &base_business_entity_id + LEVEL - 1 AS PERSONID,
    1 AS TERRITORYID,
    'AW' || LPAD(TO_CHAR(&base_customer_id + LEVEL - 1), 10, '0') AS ACCOUNTNUMBER
FROM DUAL
CONNECT BY LEVEL <= &customer_count;

COMMIT;

PROMPT Creating generated sales order headers.

INSERT INTO ADVENTUREWORKS2022.SALES_SALESORDERHEADER
(
    SALESORDERID,
    REVISIONNUMBER,
    ORDERDATE,
    DUEDATE,
    SHIPDATE,
    STATUS,
    ONLINEORDERFLAG,
    PURCHASEORDERNUMBER,
    ACCOUNTNUMBER,
    CUSTOMERID,
    SALESPERSONID,
    TERRITORYID,
    BILLTOADDRESSID,
    SHIPTOADDRESSID,
    SHIPMETHODID,
    CREDITCARDID,
    CREDITCARDAPPROVALCODE,
    CURRENCYRATEID,
    SUBTOTAL,
    TAXAMT,
    FREIGHT,
    "COMMENT"
)
SELECT
    &base_sales_order_id + order_n - 1 AS SALESORDERID,
    0 AS REVISIONNUMBER,
    DATE '2011-05-01' + MOD(order_n - 1, 1095) AS ORDERDATE,
    DATE '2011-05-01' + MOD(order_n - 1, 1095) + 12 AS DUEDATE,
    DATE '2011-05-01' + MOD(order_n - 1, 1095) + 7 AS SHIPDATE,
    5 AS STATUS,
    CASE WHEN MOD(order_n, 4) = 0 THEN 0 ELSE 1 END AS ONLINEORDERFLAG,
    'PO-' || TO_CHAR(&base_sales_order_id + order_n - 1) AS PURCHASEORDERNUMBER,
    '10-' || LPAD(TO_CHAR(&base_customer_id + MOD(order_n - 1, &customer_count)), 10, '0') AS ACCOUNTNUMBER,
    &base_customer_id + MOD(order_n - 1, &customer_count) AS CUSTOMERID,
    200 AS SALESPERSONID,
    1 AS TERRITORYID,
    &base_address_id + MOD(order_n - 1, &customer_count) AS BILLTOADDRESSID,
    &base_address_id + MOD(order_n - 1, &customer_count) AS SHIPTOADDRESSID,
    5 AS SHIPMETHODID,
    600 AS CREDITCARDID,
    'APPROVED' AS CREDITCARDAPPROVALCODE,
    700 AS CURRENCYRATEID,
    &details_per_order * (100 + MOD(order_n, 50)) AS SUBTOTAL,
    ROUND((&details_per_order * (100 + MOD(order_n, 50))) * 0.08, 4) AS TAXAMT,
    ROUND((&details_per_order * (100 + MOD(order_n, 50))) * 0.025, 4) AS FREIGHT,
    'Generated high-volume migration test order' AS "COMMENT"
FROM
(
    SELECT LEVEL AS order_n
    FROM DUAL
    CONNECT BY LEVEL <= &order_count
);

COMMIT;

PROMPT Creating generated sales order details.

INSERT INTO ADVENTUREWORKS2022.SALES_SALESORDERDETAIL
(
    SALESORDERID,
    SALESORDERDETAILID,
    CARRIERTRACKINGNUMBER,
    ORDERQTY,
    PRODUCTID,
    SPECIALOFFERID,
    UNITPRICE,
    UNITPRICEDISCOUNT
)
SELECT
    &base_sales_order_id + o.order_n - 1 AS SALESORDERID,
    d.detail_n AS SALESORDERDETAILID,
    'TRK-' || TO_CHAR(&base_sales_order_id + o.order_n - 1) || '-' || TO_CHAR(d.detail_n) AS CARRIERTRACKINGNUMBER,
    1 + MOD(o.order_n + d.detail_n, 4) AS ORDERQTY,
    500 AS PRODUCTID,
    1 AS SPECIALOFFERID,
    100 + MOD(o.order_n, 50) AS UNITPRICE,
    CASE WHEN MOD(o.order_n, 20) = 0 THEN 0.0500 ELSE 0.0000 END AS UNITPRICEDISCOUNT
FROM
(
    SELECT LEVEL AS order_n
    FROM DUAL
    CONNECT BY LEVEL <= &order_count
) o
CROSS JOIN
(
    SELECT LEVEL AS detail_n
    FROM DUAL
    CONNECT BY LEVEL <= &details_per_order
) d;

COMMIT;

PROMPT High-volume Sales data generation completed.

SELECT 'Generated customers' AS metric_name, COUNT(*) AS metric_value
FROM ADVENTUREWORKS2022.SALES_CUSTOMER
WHERE CUSTOMERID >= &base_customer_id
  AND CUSTOMERID <  &base_customer_id + &customer_count
UNION ALL
SELECT 'Generated sales order headers' AS metric_name, COUNT(*) AS metric_value
FROM ADVENTUREWORKS2022.SALES_SALESORDERHEADER
WHERE SALESORDERID >= &base_sales_order_id
  AND SALESORDERID <  &base_sales_order_id + &order_count
UNION ALL
SELECT 'Generated sales order details' AS metric_name, COUNT(*) AS metric_value
FROM ADVENTUREWORKS2022.SALES_SALESORDERDETAIL
WHERE SALESORDERID >= &base_sales_order_id
  AND SALESORDERID <  &base_sales_order_id + &order_count;
