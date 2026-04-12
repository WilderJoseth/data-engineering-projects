# Solution Design

## Overview

This document defines the technical design for migrating the **Sales domain** from Oracle Database 11g Release 2 to SQL Server 2022.

The source environment is an Oracle-adapted implementation of the **AdventureWorks2022** model under schema `ADVENTUREWORKS2022`. Although the source includes multiple functional areas, the current scope is limited to **Sales** and the supporting entities required by the target design.

The target solution uses:
- **Sales_Operational** for OLTP workloads
- **Sales_Analytics** for OLAP workloads
- **Control_DB** for execution tracking, logs, reconciliation, and reusable control metadata

## Target Databases

The target solution uses three SQL Server 2022 databases:

- **Sales_Operational**: transactional database for operational processes
- **Sales_Analytics**: analytical database for reporting and historical analysis
- **Control_DB**: technical database for execution tracking, logging, reconciliation, and reusable control metadata

### Design Rules
- OLTP, OLAP, and technical control responsibilities must remain separated.
- Cross-database dependencies should be minimized and documented to reduce coupling and simplify maintenance.
- `Sales_Operational` should follow a normalized relational design to reduce redundancy and support transactional consistency.
- `Sales_Analytics` should follow a star schema design to support reporting and analytical queries.

## Schema Organization

The solution uses business and technical schemas to separate final business objects from processing and control support objects.

### Sales_Operational

**Business schemas**
- Business schemas will be defined from detailed source analysis and target model design.

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
- Business schemas store final business-facing tables only.
- Technical schemas store temporary, intermediate, and support objects used during processing.
- `staging` stores extracted data before validation and transformation.
- `work` stores intermediate processed data used during load execution.
- `control` stores technical objects used to support execution, reconciliation, and integration with `Control_DB`.

## Table Design Principles

### General Rules
- Oracle source structures must not be copied blindly into SQL Server.
- All database objects for this project will be created in the `PRIMARY` filegroup.
- Audit and technical columns should be included where required for operational traceability.
- Nullability must be defined explicitly during target design.
- Required business columns should be defined as `NOT NULL`.
- Date, numeric, and text columns should use precise target types instead of generic oversized definitions. For example, data types such as `float` should be avoided unless they are strictly required.
- Default values must be used only when they represent valid technical or business behavior.

### Keys and Relationships
- Final target tables should define a surrogate primary key unless the target design requires a different key strategy.
- Surrogate keys will be implemented as system-generated identifier columns in SQL Server.
- Source business keys must be preserved where required for reconciliation, integration, and business rule enforcement.
- Relationships between tables must be defined explicitly in the target model.

### Audit and Technical Columns
Where applicable, final tables should include technical columns such as:
- `created_at`
- `updated_at`
- `batch_id`
- `is_active`

## Implementation Tooling

The solution is implemented using the following components:

- **Source platform**: Oracle Database 11g Release 2
- **Target platform**: SQL Server 2022
- **ETL tool**: SQL Server Integration Services (SSIS)
- **Development environment**: Visual Studio 2026 version 18.4
- **Target-side processing**: Transact-SQL stored procedures
- **Job scheduling**: SQL Server Agent

## ETL and Data Movement

Data migration is implemented through a controlled ETL flow from Oracle to SQL Server.

### Processing Flow
1. Extract data from Oracle source objects.
2. Load extracted data into `staging` tables.
3. Validate and transform data in `work` tables.
4. Execute target-side load logic through stored procedures.
5. Load final target tables in `Sales_Operational` or `Sales_Analytics`.
6. Register execution results, reconciliation data, and process status in `Control_DB`.

### ETL Rules
- SSIS is used for extraction and controlled data movement.
- Stored procedures are used for validation, transformation, and final load logic.
- Data must not be loaded directly from source into final business tables.
- Execution tracking, logs, and reconciliation results must be sent to `Control_DB`.

### Load Types
- **Initial load**: used for first-time population of target tables.
- **Incremental load**: used for recurring data synchronization after the initial load.

## Control and Monitoring

Execution control and operational monitoring are managed through `Control_DB`.

### Purpose
- Register process executions
- Store execution status and timestamps
- Store logs and reconciliation results
- Support rerun and recovery
- Centralize technical tracking for the solution

### Design Rules
- Every ETL execution must generate a traceable execution record.
- Each process must register at least start time, end time, status, and affected object or load unit.
- Row counts and reconciliation results must be stored for critical loads.
- Failures must store enough detail to support troubleshooting and rerun.
- Batch or execution identifiers must be used consistently across ETL and stored procedure processing.
- Control data must remain technical and must not store final business-domain data.

## Security, Users, and Roles

Security must separate business access, ETL execution, and administrative responsibilities.

### Design Rules
- Access must follow the principle of least privilege.
- Business users must not have direct write access to technical schemas.
- ETL execution accounts must use only the permissions required for extraction, processing, and load operations.
- Access to `Control_DB` must be limited to operational and technical roles.
- Technical schemas such as `staging`, `work`, and `control` must be restricted to ETL and support processes.

### Role Categories
- Application access
- ETL execution
- Read-only reporting access
- Operational support
- Database administration

## Load Strategy

### General Rules
- Reference and master data must be loaded before dependent transactional or analytical data.
- Failed loads must support rollback or controlled recovery to avoid inconsistent target data.
- `staging` and `work` tables must be managed through controlled cleanup rules according to processing and support requirements.
