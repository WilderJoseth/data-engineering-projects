/* WARNING: LOCAL/DEV CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
   Purpose: Drop empty Sales_Operational application schemas.
   Order: 97. Run after 96_drop_tables.sql. */
USE [Sales_Operational];
GO
DROP SCHEMA IF EXISTS [prod];
DROP SCHEMA IF EXISTS [work];
DROP SCHEMA IF EXISTS [staging];
DROP SCHEMA IF EXISTS [control];
GO
