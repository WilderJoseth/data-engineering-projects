-- =============================================================================
-- Purpose          : Create source-query procedures retained for migration and
--                    source-simulation scenarios.
-- Execution order  : 06 of 07; run after 05_create_functions.sql.
-- Connection user  : SYSTEM; CURRENT_SCHEMA is set to ADVENTUREWORKS2022.
-- Objects affected : DBO_USPGETBILLOFMATERIALS and
--                    DBO_USPGETEMPLOYEEMANAGERS.
-- Notes            : Result sets are returned as SYS_REFCURSOR values, which is
--                    the portable Oracle equivalent used by this simulation.
-- =============================================================================

ALTER SESSION SET CURRENT_SCHEMA = ADVENTUREWORKS2022;

-- Bill-of-materials lookup
CREATE OR REPLACE PROCEDURE DBO_USPGETBILLOFMATERIALS (
  P_STARTPRODUCTID IN  NUMBER,
  P_CHECKDATE       IN  DATE,
  P_RESULTS         OUT SYS_REFCURSOR
)
IS
BEGIN
  OPEN P_RESULTS FOR
    SELECT PRODUCTASSEMBLYID,
           COMPONENTID,
           STARTDATE,
           ENDDATE,
           UNITMEASURECODE,
           BOMLEVEL,
           PERASSEMBLYQTY
    FROM PRODUCTION_BILLOFMATERIALS
    WHERE PRODUCTASSEMBLYID = P_STARTPRODUCTID
      AND P_CHECKDATE >= STARTDATE
      AND (ENDDATE IS NULL OR P_CHECKDATE <= ENDDATE);
END;
/

-- Employee lookup retained without SQL Server hierarchy traversal
CREATE OR REPLACE PROCEDURE DBO_USPGETEMPLOYEEMANAGERS (
  P_BUSINESSENTITYID IN  NUMBER,
  P_RESULTS           OUT SYS_REFCURSOR
)
IS
BEGIN
  OPEN P_RESULTS FOR
    SELECT E.BUSINESSENTITYID,
           E.ORGANIZATIONNODE,
           P.FIRSTNAME,
           P.LASTNAME,
           E.JOBTITLE
    FROM HUMANRESOURCES_EMPLOYEE E
    JOIN PERSON_PERSON P
      ON P.BUSINESSENTITYID = E.BUSINESSENTITYID
    WHERE E.BUSINESSENTITYID = P_BUSINESSENTITYID;
END;
/

-- Deliberately simplified or omitted SQL Server procedures
-- Simplified: hierarchy traversal is not reproduced because hierarchyid was retained as path text.
-- Skipped: error-print/log procedures, resume XML search, and employee update procedures;
-- they are SQL Server operational helpers unrelated to source profiling or migration simulation.
