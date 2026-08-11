-- =============================================================================
-- Purpose          : Seed audit/error examples used by validation exercises.
-- Execution order  : 06 of 06; run after 05_seed_sales_data.sql.
-- Connection user  : SYSTEM; CURRENT_SCHEMA is set to ADVENTUREWORKS2022.
-- Tables populated : DBO_DATABASELOG and DBO_ERRORLOG.
-- Notes            : Rows are synthetic and contain no operational credentials
--                    or production error content.
-- =============================================================================

SET DEFINE OFF
ALTER SESSION SET CURRENT_SCHEMA = ADVENTUREWORKS2022;

INSERT INTO DBO_DATABASELOG (
  DATABASELOGID, POSTTIME, DATABASEUSER, EVENT, SCHEMA, OBJECT, TSQL, XMLEVENT
) VALUES (
  1, DATE '2024-04-15', 'ADVENTUREWORKS2022', 'SEED_VALIDATION',
  'SALES', 'SALESORDERHEADER',
  'Synthetic local seed execution',
  '<Event><Source>Local Docker seed</Source><Result>Success</Result></Event>'
);

INSERT INTO DBO_ERRORLOG (
  ERRORLOGID, ERRORTIME, USERNAME, ERRORNUMBER, ERRORSEVERITY,
  ERRORSTATE, ERRORPROCEDURE, ERRORLINE, ERRORMESSAGE
) VALUES (
  1, DATE '2024-04-15', 'ADVENTUREWORKS2022', 20001, 10,
  1, 'SEED_VALIDATION', 1, 'Synthetic handled validation error.'
);

COMMIT;

PROMPT [06] Validation-scenario data seeded.
