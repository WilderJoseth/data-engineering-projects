USE CATALOG training_catalog;
USE SCHEMA market_segmentation_insurance_db;

INSERT INTO duplicated_values_profiling_data (
  balance,
  balance_frequency,
  purchases,
  oneoff_purchases,
  installments_purchases,
  cash_advance,
  purchases_frequency,
  oneoff_purchases_frequency,
  purchases_installments_frequency,
  cash_advance_frequency,
  cash_advance_trx,
  purchases_trx,
  credit_limit,
  payments,
  minimum_payments,
  prc_full_payment,
  tenure,
  count_duplicated
)
SELECT
  balance,
  balance_frequency,
  purchases,
  oneoff_purchases,
  installments_purchases,
  cash_advance,
  purchases_frequency,
  oneoff_purchases_frequency,
  purchases_installments_frequency,
  cash_advance_frequency,
  cash_advance_trx,
  purchases_trx,
  credit_limit,
  payments,
  minimum_payments,
  prc_full_payment,
  tenure,
  COUNT(*) count_duplicated
FROM raw_data
GROUP BY
  balance,
  balance_frequency,
  purchases,
  oneoff_purchases,
  installments_purchases,
  cash_advance,
  purchases_frequency,
  oneoff_purchases_frequency,
  purchases_installments_frequency,
  cash_advance_frequency,
  cash_advance_trx,
  purchases_trx,
  credit_limit,
  payments,
  minimum_payments,
  prc_full_payment,
  tenure
HAVING COUNT(*) > 1;