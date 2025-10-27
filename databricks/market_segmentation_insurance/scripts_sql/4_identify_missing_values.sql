USE CATALOG training_catalog;
USE SCHEMA market_segmentation_insurance_db;

INSERT INTO missing_values_profiling_data (column_name, missing_count)
SELECT column_name, missing_count
FROM (
  SELECT
    COUNT(CASE WHEN balance IS NULL OR TRIM(balance) = '' THEN 1 END) AS missing_balance,
    COUNT(CASE WHEN balance_frequency IS NULL OR TRIM(balance_frequency) = '' THEN 1 END) AS missing_balance_frequency,
    COUNT(CASE WHEN purchases IS NULL OR TRIM(purchases) = '' THEN 1 END) AS missing_purchases,
    COUNT(CASE WHEN oneoff_purchases IS NULL OR TRIM(oneoff_purchases) = '' THEN 1 END) AS missing_oneoff_purchases,
    COUNT(CASE WHEN installments_purchases IS NULL OR TRIM(installments_purchases) = '' THEN 1 END) AS missing_installments_purchases,
    COUNT(CASE WHEN cash_advance IS NULL OR TRIM(cash_advance) = '' THEN 1 END) AS missing_cash_advance,
    COUNT(CASE WHEN purchases_frequency IS NULL OR TRIM(purchases_frequency) = '' THEN 1 END) AS missing_purchases_frequency,
    COUNT(CASE WHEN oneoff_purchases_frequency IS NULL OR TRIM(oneoff_purchases_frequency) = '' THEN 1 END) AS missing_oneoff_purchases_frequency,
    COUNT(CASE WHEN purchases_installments_frequency IS NULL OR TRIM(purchases_installments_frequency) = '' THEN 1 END) AS missing_purchases_installments_frequency,
    COUNT(CASE WHEN cash_advance_frequency IS NULL OR TRIM(cash_advance_frequency) = '' THEN 1 END) AS missing_cash_advance_frequency,
    COUNT(CASE WHEN cash_advance_trx IS NULL OR TRIM(cash_advance_trx) = '' THEN 1 END) AS missing_cash_advance_trx,
    COUNT(CASE WHEN purchases_trx IS NULL OR TRIM(purchases_trx) = '' THEN 1 END) AS missing_purchases_trx,
    COUNT(CASE WHEN credit_limit IS NULL OR TRIM(credit_limit) = '' THEN 1 END) AS missing_credit_limit,
    COUNT(CASE WHEN payments IS NULL OR TRIM(payments) = '' THEN 1 END) AS missing_payments,
    COUNT(CASE WHEN minimum_payments IS NULL OR TRIM(minimum_payments) = '' THEN 1 END) AS missing_minimum_payments,
    COUNT(CASE WHEN prc_full_payment IS NULL OR TRIM(prc_full_payment) = '' THEN 1 END) AS missing_prc_full_payment,
    COUNT(CASE WHEN tenure IS NULL OR TRIM(tenure) = '' THEN 1 END) AS missing_tenure
  FROM raw_data
) t
LATERAL VIEW STACK(17,
  'balance', missing_balance,
  'balance_frequency', missing_balance_frequency,
  'purchases', missing_purchases,
  'oneoff_purchases', missing_oneoff_purchases,
  'installments_purchases', missing_installments_purchases,
  'cash_advance', missing_cash_advance,
  'purchases_frequency', missing_purchases_frequency,
  'oneoff_purchases_frequency', missing_oneoff_purchases_frequency,
  'purchases_installments_frequency', missing_purchases_installments_frequency,
  'cash_advance_frequency', missing_cash_advance_frequency,
  'cash_advance_trx', missing_cash_advance_trx,
  'purchases_trx', missing_purchases_trx,
  'credit_limit', missing_credit_limit,
  'payments', missing_payments,
  'minimum_payments', missing_minimum_payments,
  'prc_full_payment', missing_prc_full_payment,
  'tenure', missing_tenure
) AS column_name, missing_count;
