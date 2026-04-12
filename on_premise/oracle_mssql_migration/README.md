# Oracle to SQL Server 2022 Migration Architecture
## Sales Domain Modernization Project

## 1. Overview

This project defines the target architecture and migration approach for modernizing the **Sales domain** from Oracle to SQL Server 2022.

The migration is driven by the implementation of a new **web platform** that requires a new SQL Server-based data layer for operational processing. The legacy Oracle environment remains the source of existing business data, while the new platform becomes the target application environment.

The source environment is an Oracle-adapted implementation of the **AdventureWorks2022** model under schema `ADVENTUREWORKS2022`. Although the source database contains multiple functional areas, the current migration scope is limited to **Sales** and to the supporting entities required by the target design.

The target solution is designed to provide:
- A new SQL Server 2022 operational database for the web platform
- A separate analytical database for reporting and historical analysis
- Controlled migration processes for initial and incremental loads
- Explicit and maintainable target-side logic
- Execution tracking, reconciliation, and restartability

The resulting solution must support both:
- Data migration from the legacy Oracle source
- Ongoing operation of the new web platform against the SQL Server target

## 2. Architecture

The solution is based on three layers:

- **Oracle source layer**
- **SQL Server destination layer**
- **Migration and control layer**

![Data Processing Design](docs/img/data_processing_design.png)

### Oracle source layer
The source layer contains:
- Business tables
- Historical data
- Oracle procedures, jobs, and triggers
- Foreign-key relationships across multiple functional areas
- Oracle-specific implementations such as identity and virtual columns

### SQL Server destination layer
The destination platform is divided into:

- **Sales_Operational**: OLTP database used by the new web platform for operational processes
- **Sales_Analytics**: OLAP database for reporting and historical analysis

### Migration and control layer
This layer is responsible for extraction, transformation, loading, execution tracking, and reconciliation.

It uses:
- SSIS
- SQL Server stored procedures
- SQL Server Agent
- Control_DB

The migration flow is:

**Oracle source → staging → work → final target tables**

### Architectural principles
- OLTP and OLAP workloads are separated.
- Trigger-based logic is not used in the target solution.
- Data is validated before final load.
- Legacy Oracle logic is reviewed and reimplemented only where required.
- The solution supports both initial and incremental loads.
- Technical execution tracking is handled separately from business-domain storage.

## 3. Migration Strategy

The migration is based on three principles:

### Schema redesign
The target SQL Server model is designed according to the needs of the new web platform and is not a direct copy of the Oracle source.

### Logic reengineering
Legacy Oracle logic is analyzed and reimplemented using explicit mechanisms such as stored procedures, ETL processes, and application-side logic where required.

### Controlled data migration
Data is migrated through staged processes that support:
- Validation
- Reconciliation
- Restartability
- Controlled cutover
- Initial and incremental loading

## 4. Scope of the Sales Domain

The current project is centered on the **Sales domain**.

This includes:
- Core Sales entities
- Supporting master and reference data required for Sales processing
- Analytical structures required for Sales reporting

The project does not attempt to migrate the full Oracle source as a single monolithic scope. The design keeps the door open for future extension to additional domains using the same architectural pattern.

## 5. Table-Based Migration Approach

Tables are classified into four categories:

### Reference tables
Stable and low-volume tables, usually copied with light adaptation.

### Master tables
Core business entities required for Sales processing, usually migrated with controlled validation and merge logic.

### Transactional tables
Operational tables such as sales orders and order details, requiring the most careful redesign and load control.

### Historical tables
History-oriented data retained selectively and moved to the analytical layer where appropriate.

## 6. Tooling Strategy

The project uses the following toolset:

- Manual source analysis
- SSIS
- SQL Server stored procedures
- SQL Server Agent
- Bulk-load methods where required for large initial loads

## 7. Control and Validation

Each load cycle must be controlled and validated.

The solution tracks:
- Execution runs
- Logs
- Row counts
- Reconciliation results
- Watermarks
- Errors and rejected records

This supports:
- Auditability
- Restartability
- Operational monitoring
- Production cutover readiness

## 8. Migration Outcome

The final solution provides:
- A new SQL Server-based operational platform for the Sales domain
- A separate analytical database for reporting and historical analysis
- Explicit and maintainable target-side behavior
- Controlled migration from Oracle to SQL Server
- An architecture that can be extended later to additional domains