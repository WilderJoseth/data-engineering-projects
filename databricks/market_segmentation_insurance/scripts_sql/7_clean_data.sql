USE CATALOG training_catalog;
USE SCHEMA market_segmentation_insurance_db;

-- Calculate median values for credit_limit and minimum_payments
CREATE OR REPLACE TEMP VIEW data_median_view AS
SELECT 
  percentile_approx(CAST(credit_limit AS DOUBLE), 0.5) AS credit_limit_median,
  percentile_approx(CAST(minimum_payments AS DOUBLE), 0.5) AS minimum_payments_median
FROM raw_data;

-- Load cleaned data into a temporary view
CREATE OR REPLACE TEMP VIEW data_cleaned_view AS
SELECT
  CAST(balance AS DOUBLE) AS balance,
  CAST(balance_frequency AS DOUBLE) AS balance_frequency,
  CAST(purchases AS DOUBLE) AS purchases,
  CAST(oneoff_purchases AS DOUBLE) AS oneoff_purchases,
  CAST(installments_purchases AS DOUBLE) AS installments_purchases,
  CAST(cash_advance AS DOUBLE) AS cash_advance,
  CAST(purchases_frequency AS DOUBLE) AS purchases_frequency,
  CAST(oneoff_purchases_frequency AS DOUBLE) AS oneoff_purchases_frequency,
  CAST(purchases_installments_frequency AS DOUBLE) AS purchases_installments_frequency,
  CAST(cash_advance_frequency AS DOUBLE) AS cash_advance_frequency,
  CAST(cash_advance_trx AS DOUBLE) AS cash_advance_trx,
  CAST(purchases_trx AS DOUBLE) AS purchases_trx,
  IFNULL(CAST(credit_limit AS DOUBLE), (SELECT credit_limit_median FROM data_median_view)) AS credit_limit,
  CAST(payments AS DOUBLE) AS payments,
  IFNULL(CAST(minimum_payments AS DOUBLE), (SELECT minimum_payments_median FROM data_median_view)) AS minimum_payments,
  CAST(prc_full_payment AS DOUBLE) AS prc_full_payment,
  TRIM(tenure) AS tenure
FROM raw_data;

