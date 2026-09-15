USE [master];
GO

/*============================================================================
  1. Database
============================================================================*/
IF DB_ID('DataOps_Control') IS NULL
BEGIN
    CREATE DATABASE [DataOps_Control];
END;
GO
