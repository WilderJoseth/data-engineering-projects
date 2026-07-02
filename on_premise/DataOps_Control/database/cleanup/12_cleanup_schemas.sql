/*============================================================================
  DataOps_Control
  Cleanup Script: Schemas

  Purpose:
  - Drops schemas created by database/ddl/02_create_schemas.sql.

  Important execution order:
  - Run this script last, after all objects inside these schemas have been
    dropped.
============================================================================*/

USE [DataOps_Control];
GO

DROP SCHEMA IF EXISTS [observability];
GO

DROP SCHEMA IF EXISTS [runtime];
GO

DROP SCHEMA IF EXISTS [metadata];
GO

DROP SCHEMA IF EXISTS [reference];
GO
