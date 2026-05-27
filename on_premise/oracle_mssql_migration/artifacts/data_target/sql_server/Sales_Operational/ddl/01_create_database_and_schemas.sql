/*
    Script name
        01_create_database_and_schemas.sql

    Purpose
        Creates the Sales_Operational database and the schemas required by the
        migration pipeline.

    Scope
        Creates staging, work, prod, and control schemas.
*/

CREATE DATABASE [Sales_Operational];
GO

USE [Sales_Operational];
GO

CREATE SCHEMA [prod];
GO

CREATE SCHEMA [staging];
GO

CREATE SCHEMA [work];
GO

CREATE SCHEMA [control];
GO
