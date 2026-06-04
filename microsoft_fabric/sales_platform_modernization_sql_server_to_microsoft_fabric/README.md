# Sales Platform Modernization: SQL Server to Microsoft Fabric

## Overview

This project presents a migration and modernization case study for moving an on-premise Sales data platform from SQL Server to Microsoft Fabric.

The objective is to design and document a phased cloud migration solution using professional data engineering practices, from problem framing and target architecture to implementation.

This case study is intended to:

* Explain the on-premise to cloud migration problem.
* Propose a Microsoft Fabric target solution from architecture to implementation design.
* Preserve the logical separation between operational and analytical workloads.
* Justify the main technical decisions.
* Demonstrate the application of key data engineering design concepts, including medallion architecture, metadata-driven orchestration, validation, reconciliation, and cloud analytics modernization.

## Problem Context

The scenario assumes that a company currently operates a Sales data platform on an on-premise SQL Server environment.

The existing architecture separates Sales data into two main databases:

* `Sales_Operational`, which stores curated transactional and operational Sales data.
* `Sales_Analytics`, which stores dimensional structures used for reporting and business analysis.

Over time, the company has accumulated transactional, historical, master, and reference data in the on-premise environment. Business users rely on this platform for Sales reporting, operational visibility, and analytical decision-making. However, the current architecture creates limitations around scalability, cloud integration, centralized analytics, self-service reporting, and long-term maintainability.

The company has decided to modernize the Sales data platform using Microsoft Fabric. The goal is not only to move data from on-premise SQL Server to the cloud, but also to redesign the platform using cloud-native analytical components such as OneLake, Lakehouse, Warehouse, Fabric Data Factory pipelines, and Power BI semantic modeling.

The migration is executed in phases and focuses first on the Sales domain. This allows the project to deliver clear business value while keeping the scope controlled and technically demonstrable.

## Architecture Overview

The proposed architecture preserves the original separation between operational and analytical workloads while modernizing the physical implementation in Microsoft Fabric.

Data is first extracted from the on-premise SQL Server Sales source through Fabric Data Factory pipelines. Raw source-aligned data is landed in a Bronze Lakehouse. After ingestion, data is standardized, validated, and transformed into a curated operational model represented by `Sales_Operational`. Once the operational layer is validated and reconciled, the dimensional analytical model represented by `Sales_Analytics` is built for reporting and semantic consumption.

A shared cloud version of `DataOps_Control`, hosted in Azure SQL Database, acts as the metadata-driven control framework for the solution. This control database is not owned by the Sales migration project. Instead, the Sales migration is registered as one project inside the shared framework.

`DataOps_Control` stores project metadata, process metadata, table metadata, batch definitions, execution tracking, validation results, reconciliation results, error logs, and rerun support information used by the Fabric pipelines.

```text
+-----------------------------+
| Azure SQL Database          |
| DataOps_Control             |
| - metadata                  |
| - runtime                   |
| - observability             |
| - reference                 |
+--------------+--------------+
               |
               | metadata, execution status,
               | validation, reconciliation
               v
+-----------------------------+       +-----------------------------+
| On-Premise SQL Server       |       | Microsoft Fabric            |
| Sales Source System         | ----> | Data Factory Pipelines      |
+-----------------------------+       +--------------+--------------+
                                                     |
                                                     v
                                      +-----------------------------+
                                      | Bronze Lakehouse            |
                                      | Raw source-aligned data     |
                                      +--------------+--------------+
                                                     |
                                                     v
                                      +-----------------------------+
                                      | Sales_Operational           |
                                      | Curated operational model   |
                                      +--------------+--------------+
                                                     |
                                                     v
                                      +-----------------------------+
                                      | Sales_Analytics             |
                                      | Dimensional reporting model |
                                      +--------------+--------------+
                                                     |
                                                     v
                                      +-----------------------------+
                                      | Power BI Semantic Model     |
                                      | Business reporting layer    |
                                      +-----------------------------+
```

## Target Platform

The target platform is Microsoft Fabric, supported by Azure SQL Database for the shared control layer.

The Fabric implementation includes:

* Fabric Data Factory pipelines for orchestration and data movement.
* On-premises data gateway for secure connectivity to the SQL Server source.
* Fabric Lakehouse for raw Bronze storage.
* Fabric Warehouse or Lakehouse-based curated structures for `Sales_Operational`.
* Fabric Warehouse for `Sales_Analytics` dimensional reporting.
* Power BI semantic model for business consumption.
* Azure SQL Database for the shared `DataOps_Control` framework.

## Logical Target Layers

The solution is organized into logical layers.

| Layer | Component | Purpose |
|---|---|---|
| Source | On-premise SQL Server | Existing Sales source system |
| Control | Azure SQL Database - `DataOps_Control` | Shared metadata-driven control framework |
| Bronze | Fabric Lakehouse | Raw source-aligned data landing layer |
| Operational | `Sales_Operational` | Curated transactional and operational Sales model |
| Analytical | `Sales_Analytics` | Dimensional model for reporting and analysis |
| Consumption | Power BI semantic model | Business-facing reporting layer |

## Data Source Profile

The source platform is based on an on-premise SQL Server Sales environment. The source model represents a business Sales domain that includes customer, product, territory, salesperson, order, and supporting reference data.

From a migration perspective, the source cannot be treated as a uniform dataset. It contains:

* Reference data, which is generally low-volume and relatively stable.
* Master data, which is low-to-medium volume and supports core Sales processing.
* Transactional data, which represents the main operational workload.
* Historical data, which may span multiple years and require batch-based processing.

### Characteristics

* Source platform: SQL Server on-premise.
* Source domain: Sales.
* Source workload: operational and reporting data.
* Migration type: on-premise to cloud modernization.
* Target platform: Microsoft Fabric.
* Shared control layer: Azure SQL Database `DataOps_Control`.

## Operational and Analytical Workload Separation

The existing architecture includes both `Sales_Operational` and `Sales_Analytics`. The Fabric migration preserves this logical separation because each layer serves a different purpose.

`Sales_Operational` represents the curated operational model. It stores cleaned, standardized, and business-aligned Sales data while keeping a structure close to the transactional domain.

`Sales_Analytics` represents the dimensional analytical model. It is built from `Sales_Operational` and is designed for reporting, KPIs, business analysis, and Power BI semantic modeling.

This separation allows the platform to support both operational traceability and analytical consumption without forcing business reports to depend directly on raw or transactional source structures.

## Shared DataOps Control Framework

This project uses the cloud version of `DataOps_Control`, hosted in Azure SQL Database, as a shared metadata-driven control framework.

`DataOps_Control` is not created specifically for this Sales migration project. It is a reusable control framework used by multiple data engineering projects, where Sales is one registered project.

Fabric pipelines use `DataOps_Control` to:

* Read project, process, table, and batch metadata.
* Determine which objects must be executed.
* Track execution runs and execution steps.
* Store validation results.
* Store reconciliation results.
* Log technical errors.
* Support rerun and recovery behavior.

The Sales migration repository includes only the project-specific seed metadata required to register this solution in the shared control framework. The full `DataOps_Control` database design belongs to its own repository or platform-level implementation.

## Migration Flow

The migration flow follows a phased pattern.

1. Fabric pipeline starts an execution run in `DataOps_Control`.
2. Pipeline reads active Sales processes, tables, and batch definitions from the control database.
3. Pipeline extracts source data from on-premise SQL Server through the gateway.
4. Raw data is landed in the Bronze Lakehouse.
5. Bronze data is standardized and transformed into `Sales_Operational`.
6. `Sales_Operational` is validated and reconciled.
7. `Sales_Analytics` is built from the curated operational model.
8. Analytical data is validated and reconciled.
9. Results are written back to `DataOps_Control`.
10. The semantic model consumes `Sales_Analytics` for reporting.

## Related Documentation

For the technical design, see:

* [Solution Design](docs/solution_design.md)

Additional documentation may include:

* [Source Data Profile](docs/source_data_profile.md)
* [Migration Strategy](docs/migration_strategy.md)
* [Validation and Reconciliation](docs/validation_reconciliation.md)
* [Operational Runbook](docs/operational_runbook.md)

## Project Scope

### In Scope

* On-premise SQL Server to Microsoft Fabric migration scenario.
* Sales domain migration and modernization.
* Bronze Lakehouse raw ingestion layer.
* Curated `Sales_Operational` layer.
* Dimensional `Sales_Analytics` layer.
* Fabric Data Factory pipeline orchestration.
* Use of a shared Azure SQL `DataOps_Control` framework.
* Project-specific metadata seed scripts for `DataOps_Control`.
* Execution traceability, validation, reconciliation, and error logging.
* Power BI semantic model readiness.

### Out of Scope

* Full migration of all enterprise domains.
* Full ERP or application replatforming.
* Replacing the shared `DataOps_Control` framework.
* Building the complete `DataOps_Control` database from this repository.
* Real-time streaming or event-driven ingestion.
* Full production infrastructure sizing.
* Exhaustive security, networking, and deployment hardening.
* Complete Power BI report suite.

## Expected Repository Structure

```text
sqlserver_fabric_sales_migration/
|
|-- README.md
|-- docs/
|   |-- solution_design.md
|   |-- source_data_profile.md
|   |-- migration_strategy.md
|   |-- validation_reconciliation.md
|   |-- operational_runbook.md
|
|-- fabric/
|   |-- pipelines/
|   |-- notebooks/
|   |-- lakehouse/
|   |-- warehouse/
|
|-- sql/
|   |-- source/
|   |-- sales_operational/
|   |-- sales_analytics/
|   |-- dataops_project_seed/
|
|-- diagrams/
|   |-- architecture_overview.png
|   |-- migration_flow.png
|   |-- logical_data_model.png
```

## Key Design Principles

* Preserve the logical separation between operational and analytical workloads.
* Use Fabric as the target cloud analytics platform, not only as a storage destination.
* Keep `DataOps_Control` as a shared platform-level control framework.
* Use metadata-driven orchestration where practical.
* Validate and reconcile data across migration stages.
* Keep the first implementation realistic and controlled in scope.
* Design the project as a professional portfolio case study that demonstrates both on-premise experience and cloud modernization skills.
