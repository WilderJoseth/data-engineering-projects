# Solution Design

This section describes the target solution in sufficient detail to support implementation.

The purpose of the solution is to migrate the legacy Oracle Sales module into a modern SQL Server 2022 platform with explicit logic, controlled data movement, and separation between operational and analytical workloads.

## 1. Target databases

The target platform will be implemented with two SQL Server databases:

- Sales_DB
- Sales_DW

### Sales_DB
This database supports the new web application and stores current operational data.

It is responsible for:

- Customer and product master data used by the application.
- Sales transactions.
- Inventory-related operational data.
- Explicit database-side logic required for controlled writes.
- Technical schemas for migration and synchronization support.

### Sales_DW
This database supports reporting and analytics.

It is responsible for:

- Historical and analytical data storage.
- Dimensional and fact-oriented structures.
- Reporting views and reporting-ready data sets.
- Technical schemas for warehouse loading and transformation.

## 2. Schema organization

Each database will contain both business schemas and technical schemas.

### Sales_DB schemas

Business schemas:
- customer
- sales
- billing

Technical schemas:
- staging
- work
- control

### Sales_DW schemas

Business schemas:
- dim
- fact

Technical schemas:
- staging
- work
- control

### Purpose of technical schemas

- **staging** stores raw extracted data before final processing.
- **work** stores intermediate transformed data sets.
- **control** stores control metadata such as batch identifiers, watermarks, row counts, and execution status.

## 3. Table design principles

The target table design differs between the operational and analytical databases according to their responsibilities.

### Sales_DB

- Audit columns like CreationDate, CreationUser, ModificationDate, ModificationUser.
- Id columns are identity-based and primary key.

### Sales_DW

- Audit columns like CreationDate, CreationUser, ModificationDate, ModificationUser.
- Id columns are autoincremetal and primary key.
- No null values are allowed.

## 4. ETL and data movement

The solution will use **SSIS** as the primary ETL and orchestration tool for data extraction, transformation, and loading.

The ETL design will support:

- Initial migration of source data.
- Recurring incremental synchronization.
- Loading of OLTP target data.
- Loading of OLAP target data.
- Validation and reconciliation.
- Error capture and restartability.

### Data movement flow

The standard data movement pattern will be:

**Oracle source → SQL Server `staging` → SQL Server `work` → final target tables**

### ETL responsibilities

ETL processes will be responsible for:

- Extracting data from Oracle.
- Standardizing source values.
- Loading raw staging tables.
- Invoking transformation and load procedures.
- Capturing rejected rows.
- Updating control metadata.
- Recording execution logs.

## 5. Stored procedures and business logic

The target platform will use explicit **SQL Server stored procedures** for controlled database-side processing.

Stored procedures will be used for:

- Merge and upsert operations from staging into final tables.
- Validation of business rules during load.
- Controlled write operations for important business entities.
- Batch-oriented data processing.
- Reconciliation and audit support.

The project will not use triggers in the target database. This means that any Oracle trigger-based behavior must be reassigned explicitly to one of the following:

- Stored procedures
- ETL processes
- Application logic

The objective is to ensure that all important business behavior is explicit, testable, and maintainable.

## 6. Jobs and scheduling

The solution will use **SQL Server Agent** for job execution and scheduling.

SQL Server Agent jobs will be used for:

- Initial migration runs.
- Incremental synchronization cycles.
- Warehouse refresh processes.
- Cleanup of staging and error tables.
- Reconciliation execution.
- Operational monitoring processes.

## 7. Control and monitoring

The solution will include a control framework to support migration operation and traceability.

Control information will be stored in `control` schemas and will include:

- Batch identifiers
- Source and target row counts
- Execution start and end times
- Execution status
- Watermark values
- Reconciliation results
- Error counts
- Process logs

## 8. Load strategy

The migration will support two load modes:

### Initial load
Used to migrate the existing source data into the new platform.

The initial load will:

- Extract data from Oracle in controlled batches.
- Load raw data into `staging`.
- Transform data in `work`.
- Load final OLTP and DW tables.
- Perform validations and reconciliation before acceptance.

### Incremental load
Used to synchronize changes after the initial baseline has been loaded.

The incremental load will:

- Identify source changes.
- Extract only the required deltas.
- Apply controlled merge logic.
- Update target data.
- Record watermark progress and execution results.

## 9. Security, Users, and Roles

The target solution must include a controlled security model for both operational and analytical environments.

The objective is to ensure that application access, ETL execution, reporting access, and administrative activities are clearly separated and governed through explicit users and roles.

### 9.1. Security principles

The security model follows these principles:

- Least privilege.
- Separation of duties.
- Schema-based access control.
- No direct access to technical schemas by end users or application users.
- Controlled execution of ETL and scheduled jobs.
- Explicit ownership of objects and permissions.

### 9.2. Users

The implementation should define dedicated users or service accounts according to system responsibility.

Typical users include:

- **Application user**
  - Used by the web application.
  - Allowed to execute controlled stored procedures and access required operational objects.
  - No direct access to staging or control schemas.

- **ETL user**
  - Used by SSIS packages and migration processes.
  - Allowed to read/write staging, work, error, and control schemas.
  - Allowed to execute load and merge stored procedures.

- **Reporting user**
  - Used by reporting tools or BI consumers.
  - Read-only access to the DW reporting structures.
  - No write access to OLTP.

- **SQL Agent execution user**
  - Used for scheduled job execution.
  - Allowed to execute ETL packages and operational procedures as required.
  - Restricted to job-related responsibilities.

- **DBA / administrative user**
  - Used for database administration and maintenance.
  - Full operational privileges according to environment.

### 9.3. Roles

Permissions should be assigned through database roles rather than directly to individual users whenever possible.

Recommended roles include:

#### Sales_DB roles

- `role_app_readwrite`
  - access to application-required schemas and stored procedures
- `role_etl_executor`
  - access to `staging`, `work`, and `control`
  - execute permissions on ETL-related procedures
- `role_ops_monitor`
  - read access to logs, control data, and operational monitoring objects
- `role_audit_reader`
  - read access to audit-related objects where required

#### Sales_DW roles

- `role_report_reader`
  - read-only access to `dim`, `fact`, and reporting views
- `role_dw_etl_executor`
  - access to technical schemas for warehouse loading
  - execute permissions on load and refresh procedures
- `role_dw_monitor`
  - read access to warehouse control and load metadata

### 9.4. Schema access model

Permissions should be assigned according to schema responsibility.

#### Sales_DB

- `customer`, `sales`, `billing`, `reference`
  - application and controlled operational access
- `staging`, `work`, `control`
  - ETL and operational support access only

#### Sales_DW

- `dim`, `fact`
  - reporting read access and ETL load access
- `staging`, `work`, `control`
  - ETL and operational support access only

Technical schemas must not be part of normal application or end-user access.

### 9.5. Stored procedure access pattern

Where possible, business writes should be performed through stored procedures instead of granting unrestricted write access to base tables.
