USE CATALOG training_catalog;
USE SCHEMA market_segmentation_insurance_db;

INSERT INTO consistency_values_profiling_data (column_name, count_invalid)
SELECT
  'balance' AS column_name,
  (SELECT COUNT(1) FROM raw_data WHERE NOT REGEXP(balance, '^[0-9]+(\\.[0-9]+)?$')) AS count_invalid;

INSERT INTO consistency_values_profiling_data (column_name, count_invalid)
SELECT
  'balance_frequency' AS column_name,
  (SELECT COUNT(1) FROM raw_data WHERE NOT REGEXP(balance_frequency, '^[0-9]+(\\.[0-9]+)?$')) AS count_invalid;

INSERT INTO consistency_values_profiling_data (column_name, count_invalid)
SELECT
  'purchases' AS column_name,
  (SELECT COUNT(1) FROM raw_data WHERE NOT REGEXP(purchases, '^[0-9]+(\\.[0-9]+)?$')) AS count_invalid;

INSERT INTO consistency_values_profiling_data (column_name, count_invalid)
SELECT
  'oneoff_purchases' AS column_name,
  (SELECT COUNT(1) FROM raw_data WHERE NOT REGEXP(oneoff_purchases, '^[0-9]+(\\.[0-9]+)?$')) AS count_invalid;

INSERT INTO consistency_values_profiling_data (column_name, count_invalid)
SELECT
  'installments_purchases' AS column_name,
  (SELECT COUNT(1) FROM raw_data WHERE NOT REGEXP(installments_purchases, '^[0-9]+(\\.[0-9]+)?$')) AS count_invalid;

INSERT INTO consistency_values_profiling_data (column_name, count_invalid)
SELECT
  'cash_advance' AS column_name,
  (SELECT COUNT(1) FROM raw_data WHERE NOT REGEXP(cash_advance, '^[0-9]+(\\.[0-9]+)?$')) AS count_invalid;

INSERT INTO consistency_values_profiling_data (column_name, count_invalid)
SELECT
  'purchases_frequency' AS column_name,
  (SELECT COUNT(1) FROM raw_data WHERE NOT REGEXP(purchases_frequency, '^[0-9]+(\\.[0-9]+)?$')) AS count_invalid;

INSERT INTO consistency_values_profiling_data (column_name, count_invalid)
SELECT
  'oneoff_purchases_frequency' AS column_name,
  (SELECT COUNT(1) FROM raw_data WHERE NOT REGEXP(oneoff_purchases_frequency, '^[0-9]+(\\.[0-9]+)?$')) AS count_invalid;

INSERT INTO consistency_values_profiling_data (column_name, count_invalid)
SELECT
  'purchases_installments_frequency' AS column_name,
  (SELECT COUNT(1) FROM raw_data WHERE NOT REGEXP(purchases_installments_frequency, '^[0-9]+(\\.[0-9]+)?$')) AS count_invalid;

INSERT INTO consistency_values_profiling_data (column_name, count_invalid)
SELECT
  'cash_advance_frequency' AS column_name,
  (SELECT COUNT(1) FROM raw_data WHERE NOT REGEXP(cash_advance_frequency, '^[0-9]+(\\.[0-9]+)?$')) AS count_invalid;

INSERT INTO consistency_values_profiling_data (column_name, count_invalid)
SELECT
  'cash_advance_trx' AS column_name,
  (SELECT COUNT(1) FROM raw_data WHERE NOT REGEXP(cash_advance_trx, '^[0-9]+(\\.[0-9]+)?$')) AS count_invalid;

INSERT INTO consistency_values_profiling_data (column_name, count_invalid)
SELECT
  'purchases_trx' AS column_name,
  (SELECT COUNT(1) FROM raw_data WHERE NOT REGEXP(purchases_trx, '^[0-9]+(\\.[0-9]+)?$')) AS count_invalid;

INSERT INTO consistency_values_profiling_data (column_name, count_invalid)
SELECT
  'credit_limit' AS column_name,
  (SELECT COUNT(1) FROM raw_data WHERE NOT REGEXP(credit_limit, '^[0-9]+(\\.[0-9]+)?$')) AS count_invalid;

INSERT INTO consistency_values_profiling_data (column_name, count_invalid)
SELECT
  'minimum_payments' AS column_name,
  (SELECT COUNT(1) FROM raw_data WHERE NOT REGEXP(minimum_payments, '^[0-9]+(\\.[0-9]+)?$')) AS count_invalid;

INSERT INTO consistency_values_profiling_data (column_name, count_invalid)
SELECT
  'prc_full_payment' AS column_name,
  (SELECT COUNT(1) FROM raw_data WHERE NOT REGEXP(prc_full_payment, '^[0-9]+(\\.[0-9]+)?$')) AS count_invalid;
