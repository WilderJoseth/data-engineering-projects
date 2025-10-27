USE CATALOG training_catalog;
USE SCHEMA market_segmentation_insurance_db;

DROP TABLE IF EXISTS raw_data;
CREATE TABLE raw_data (
  cust_id STRING, 
  balance STRING, 
  balance_frequency STRING, 
  purchases STRING, 
  oneoff_purchases STRING, 
  installments_purchases STRING, 
  cash_advance STRING, 
  purchases_frequency STRING, 
  oneoff_purchases_frequency STRING, 
  purchases_installments_frequency STRING, 
  cash_advance_frequency STRING, 
  cash_advance_trx STRING, 
  purchases_trx STRING, 
  credit_limit STRING, 
  payments STRING, 
  minimum_payments STRING, 
  prc_full_payment STRING, 
  tenure STRING
);
