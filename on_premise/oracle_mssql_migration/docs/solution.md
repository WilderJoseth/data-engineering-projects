# Solution Design

## Overview

This document defines the technical implementation of the Oracle 11gR2 to SQL Server 2022 migration for the Sales / Customer Orders module.

The solution includes:
- One SQL Server 2022 database for OLTP
- One SQL Server 2022 database for OLAP
- SSIS for extraction and load processes
- Stored procedures for validation, transformation, and load logic
- SQL Server Agent for scheduling and execution

## Target Databases

The target solution uses three SQL Server 2022 databases:

- **Sales_Operational**: transactional database for operational processes.
- **Sales_Analytics**: analytical database for reporting and historical analysis.
- **Control_DB**: technical database for execution tracking, logging, reconciliation, and reusable control metadata.

### Design Rules
- OLTP, OLAP, and technical control responsibilities must remain separated.
- `Sales_Operational` stores operational business data.
- `Sales_Analytics` stores analytical and historical reporting data.
- `Control_DB` stores technical metadata and operational control objects only.
- Cross-database dependencies should be minimized and documented to reduce coupling and simplify maintenance.

## Schema Organization

The solution uses business and technical schemas to separate final business objects from processing and control support objects.

### Sales_Operational

**Business schemas**
- Business schemas will be defined from the detailed source analysis and target model design.
- The final schema structure may change as Oracle source objects are analyzed and grouped into target business domains.

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
- `control` stores technical objects required by the solution, including objects used to register, prepare, or return execution data to the central control database `Control_DB`.
- Objects must be created explicitly in the correct schema and must not rely on default schema behavior.

## Table Design Principles

Final table structures will be defined during detailed source analysis and target model design. However, the following design principles apply to table creation across the solution.

### General Rules
- Tables must be created explicitly in the correct schema.
- SQL Server data types must be selected according to business meaning and expected usage.
- Final tables must define a surrogate primary key.

### OLTP Principles
- `Sales_Operational` tables must support transactional processing and controlled updates.
- Business keys from the source must be preserved where required for reconciliation, integration, or business uniqueness.
- Audit and technical columns should be included where required for operational traceability.

### OLAP Principles
- `Sales_Analytics` tables must be designed for reporting, historical analysis, and query performance.
- The model should use dimension and fact structures where appropriate.
- Business keys from source systems should be preserved where needed for lineage and reconciliation.
- Where appropriate, unknown or missing values should be mapped to predefined default value.

### Keys and Relationships
- Each final table must define a primary key.
- Surrogate keys are implemented as system-generated identifier columns in SQL Server.
- Foreign key relationships should be implemented where they support integrity and do not conflict with controlled load processes.

### Audit and Technical Columns
Where applicable, final tables should include technical columns such as:
- `created_at`
- `updated_at`
- `batch_id`
- `is_active`

### Default Values
- Default values must be used only when they represent valid technical or business behavior.
- Technical audit columns may use system defaults where appropriate.

### Nullability
- Nullability must be defined explicitly during target design.
- Required business columns should be defined as `NOT NULL`.

### Data Types
- SQL Server data types must be selected according to business meaning and expected usage.
- Oracle data type mappings must be reviewed during design.
- Date, numeric, and text columns should use precise target types instead of generic oversized definitions.

### Storage and Filegroup Principles

For this project, all objects in `Sales_Operational` and `Sales_Analytics` are created in the default `PRIMARY` filegroup. No custom filegroup allocation is required for the initial implementation. This decision is based on project scope and implementation simplicity.

For enterprise production environments, filegroup design should be evaluated according to:
- Expected data volume
- Workload type
- Maintenance windows
- Index rebuild strategy
- Partitioning requirements
- Backup and restore objectives

Where justified, separate filegroups may be defined for large tables, large indexes, or partitioned structures.

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
- `staging` stores source-aligned extracted data before processing.
- `work` stores intermediate data used during validation and transformation.
- Final loads must be executed in a controlled and traceable way.
- Execution tracking, logs, and reconciliation results must be sent to `Control_DB`.

### Load Types
- **Initial load**: used for first-time population of target tables.
- **Incremental load**: used for recurring data synchronization after the initial load.

### Failure Handling and Rollback
- Final target loads must be executed within controlled transactions.
- If a failure occurs during a final load step, the transaction for that load unit must be rolled back.
- Failed executions must be registered in `Control_DB` with status, error details, and batch identifier.
- Load processes must be restartable and must prevent duplicate target data after failure.

## Control and Monitoring

Execution control and operational monitoring are managed through `Control_DB`.

### Purpose
`Control_DB` is used to:
- Register process executions
- Store execution status and timestamps
- Store logs and reconciliation results
- Support rerun and recovery control
- Centralize technical tracking for the solution

## Security, Users, and Roles

Security must separate business access, ETL execution, and administrative control.

### Design Rules
- Access must follow the principle of least privilege.
- Business users must not have direct write access to technical schemas.
- ETL execution accounts must use only the permissions required for extraction, processing, and load operations.
- Administrative permissions must be restricted to authorized technical users.
- Access to `Control_DB` must be limited to operational and technical roles.

### Access Scope
- `Sales_Operational` must expose business data only through approved schemas and objects.
- `Sales_Analytics` must expose analytical data only through approved schemas and objects.
- Technical schemas such as `staging`, `work`, and `control` must be restricted to ETL and support processes.

### Role Categories
The solution may define separate roles for:
- Application access
- ETL execution
- Read-only reporting access
- Operational support
- Database administration

