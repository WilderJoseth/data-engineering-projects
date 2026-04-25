# Solution Design

## Overview

This document defines the technical design for migrating the **Sales domain** from Oracle XE 21c to SQL Server 2022.

The source environment is an Oracle-adapted implementation of the **AdventureWorks2022** model under schema `ADVENTUREWORKS2022`. Although the source includes multiple functional areas, the current scope is limited to **Sales** and the supporting entities required by the target design.

## Target Databases

The target solution uses three SQL Server 2022 databases:
- **Sales_Operational**: transactional database for operational processes
- **Sales_Analytics**: analytical database for reporting and historical analysis
- **Control_DB**: technical database for execution tracking, logging, reconciliation, and reusable control metadata

### Reasons

- Separate responsibilities
- Simplify maintenance
- Allocate resources according to the workload of each database

### Design Rules

- `Sales_Operational` should follow a normalized relational design to reduce redundancy and support transactional consistency
- `Sales_Analytics` should follow a star schema design to support reporting and analytical queries

## Schema Organization

The solution uses business and technical schemas to separate final business objects from processing and control support objects.

### Sales_Operational

**Business schemas**
- `prod`

**Technical schemas**
- `staging`
- `work`
- `control`

### Sales_Analytics

**Business schemas**
- `dim`
- `fact`

**Technical schemas**
- `staging`
- `work`
- `control`

### Schema Rules

- Business schemas store final business-facing tables only
- Technical schemas store temporary, intermediate, and support objects used during processing
- `staging` stores extracted data before validation and transformation
- `work` stores intermediate processed data used during load execution
- `control` stores technical objects used to support execution, reconciliation, and integration with `Control_DB`

## Table Design Principles

### General Rules

- Oracle source structures must not be copied blindly into SQL Server
- All database objects for this project will be created in the `PRIMARY` filegroup
- Audit and technical columns should be included where required for operational traceability
- Nullability must be defined explicitly during target design
- Required business columns should be defined as `NOT NULL`
- Date, numeric, and text columns should use precise target types instead of generic oversized definitions. For example, data types such as `float` should be avoided unless they are strictly required
- Default values must be used only when they represent valid technical or business behavior

### Keys and Relationships

- Final target tables should define a surrogate primary key
- Surrogate keys will be implemented as system-generated identifier columns in SQL Server, for example: IDENTITY
- Source business keys must be preserved where required for reconciliation, integration, and business rule enforcement
- Relationships between tables must be defined explicitly in the target model to support integrity and reduce the risk of orphaned rows

### Audit and Technical Columns

Where applicable, final tables should include technical columns such as:
- `created_at`
- `created_by`
- `updated_at`
- `updated_by`
- `run_id`
- `is_active`

## Implementation Tooling

The solution is implemented using the following components:
- **Source platform**: Oracle XE 21c
- **Target platform**: SQL Server 2022
- **ETL tool**: SQL Server Integration Services (SSIS)
- **Development environment**: Visual Studio 2026
- **Target-side processing**: Transact-SQL stored procedures
- **Job scheduling**: SQL Server Agent

## ETL and Data Movement

Data migration is implemented through a controlled ETL flow from Oracle to SQL Server.

### Processing Flow

1. Extract data from Oracle source objects
2. Load extracted data into `staging` tables
3. Validate and transform data in `work` tables
4. Execute target-side load logic through stored procedures
5. Load final target tables in `Sales_Operational` or `Sales_Analytics`
6. Register execution results, reconciliation data, and process status in `Control_DB`

### Load Types

- **Baseline migration**: used to populate target tables during the initial migration, potentially in controlled batches for large-volume data
- **Transition synchronization**: used where required to synchronize new or changed source data during the coexistence period before final cutover
- **Final cutover load**: used to complete the transition and establish the SQL Server target as the new operational system of record

### Load Rules

- SSIS is used for extraction and controlled data movement
- Stored procedures are used for validation, transformation, and final load logic
- Data must not be loaded directly from source into final business tables
- Loads should support reruns in order to ensure idempotency
- Execution tracking, logs, and reconciliation results must be sent to `Control_DB`
- The watermarking columns should be defined by the necessities of each load like controlled batches
- Reference and master data must be loaded before dependent transactional or analytical data
- Failed loads must support rollback or controlled recovery to avoid inconsistent target data
- `staging` and `work` tables must be managed through controlled cleanup rules according to processing and support requirements
- Transactional and historical data should use phased baseline migration and, where required, incremental synchronization during transition

## Control and Monitoring

Execution control and operational monitoring are managed through `Control_DB`.

### Purpose

- Register process executions
- Store execution status and timestamps
- Store logs and reconciliation results
- Support rerun and recovery
- Centralize technical tracking for the solution

## Security, Users, and Roles

Security must separate business access, ETL execution, and administrative responsibilities.

### Design Rules

- Access must follow the principle of least privilege
- Business users must not have direct write access to technical schemas
- ETL execution accounts must use only the permissions required for extraction, processing, and load operations
- Access to `Control_DB` must be limited to operational and technical roles
- Technical schemas such as `staging`, `work`, and `control` must be restricted to ETL and support processes

### Role Categories

- Application access
- ETL execution
- Read-only reporting access
- Operational support
- Database administration
