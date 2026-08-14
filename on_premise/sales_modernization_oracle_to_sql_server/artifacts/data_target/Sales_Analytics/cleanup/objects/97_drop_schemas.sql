/* WARNING: LOCAL/DEV CLEANUP ONLY. DO NOT RUN IN PRODUCTION.
   Purpose: Drop empty Sales_Analytics application schemas.
   Order: 97. Run after 96_drop_tables.sql. */
USE [Sales_Analytics];
GO
DROP SCHEMA IF EXISTS [fact];
DROP SCHEMA IF EXISTS [dim];
DROP SCHEMA IF EXISTS [work];
DROP SCHEMA IF EXISTS [staging];
DROP SCHEMA IF EXISTS [control];
GO
