# Sales Platform Modernization: SQL Server to Microsoft Fabric

## Overview

This project presents a Sales data platform modernization from an on-premise SQL Server environment to Microsoft Fabric.

The goal is to design a cloud-based architecture that supports historical migration, incremental data processing, operational data structures, analytical reporting, and controlled execution tracking.

This project is part of a data engineering portfolio focused on cloud modernization, Microsoft Fabric, data platform design, and migration practices.

## Project Scope

| Area                      | In Scope                                                      |
| ------------------------- | ------------------------------------------------------------- |
| Source platform           | On-premise SQL Server Sales databases                         |
| Target analytics platform | Microsoft Fabric with Azure SQL Database for DataOps control  |
| Data storage              | Lakehouse and Warehouse patterns                              |
| Processing                | Historical and incremental migration                          |
| Control                   | Metadata-driven execution tracking                            |
| Validation                | Data validation and reconciliation design                     |
| Consumption               | Analytical model for reporting                                |

## Out of Scope

| Area                             | Reason                                   |
| -------------------------------- | ---------------------------------------- |
| Real-time streaming              | Not required for the first version       |
| Full enterprise migration        | The scope is limited to the Sales domain |
| Production deployment automation | May be added in a later phase            |
| Security implementation details  | Covered only at design level for now     |

## High-Level Architecture

```text
On-Premise SQL Server
        |
        v
Fabric Data Factory Pipelines
        |
        v
Fabric Lakehouse Bronze data area
        |
        v
Curated Operational Data
        |
        v
Fabric Warehouse Gold analytical model
        |
        v
Power BI Semantic Model
```

A shared control database supports metadata, execution tracking, validation, reconciliation, error logging, and rerun management.

## Technologies

| Category       | Technology          |
| -------------- | ------------------- |
| Source system  | SQL Server          |
| Cloud platform | Microsoft Fabric    |
| Orchestration  | Fabric Data Factory |
| Storage        | OneLake / Lakehouse |
| Analytics      | Fabric Warehouse    |
| Processing     | SQL / PySpark       |
| Reporting      | Power BI            |
| Control layer  | Azure SQL Database  |

## Repository Structure

```text
sales_platform_modernization_sql_server_to_microsoft_fabric/
|
|-- README.md
|-- docs/
|   |-- 00_concepts_and_terminology_guide.md
|   |-- 01_current_state_assessment.md
|   |-- 02_solution_design.md
|   |-- 03_source_data_profile.md
|   |-- 04_target_data_model.md
|   |-- 05_data_flow_strategy.md
|   |-- 06_load_strategy.md
|
|-- diagrams/        # planned
|-- fabric/          # planned
|-- sql/             # planned
```

## Documentation

| Document                                     | Purpose                                                     |
| -------------------------------------------- | ----------------------------------------------------------- |
| `docs/00_concepts_and_terminology_guide.md` | Defines project terminology and usage rules                 |
| `docs/01_current_state_assessment.md`       | Describes the current source platform and modernization drivers |
| `docs/02_solution_design.md`                | Describes the target architecture and main design decisions |
| `docs/03_source_data_profile.md`            | Describes source databases, source objects, and profiling needs |
| `docs/04_target_data_model.md`              | Describes Lakehouse, Warehouse, Gold, and semantic model objects |
| `docs/05_data_flow_strategy.md`             | Describes historical, new reporting, and coexistence data flows |
| `docs/06_load_strategy.md`                  | Describes full, incremental, and batch loading rules        |
| `docs/validation_reconciliation_strategy.md` | Planned document for data quality and reconciliation        |
| `docs/cutover_strategy.md`                   | Planned document for transition from on-premise to Fabric   |

## Project Status

| Area                          | Status      |
| ----------------------------- | ----------- |
| Project framing               | In progress |
| Solution design               | In progress |
| Repository structure          | In progress |
| Fabric implementation         | Planned     |
| Validation and reconciliation | Planned     |
| Reporting layer               | Planned     |

## Notes

This version keeps the README focused. The detailed explanation should move to `docs/02_solution_design.md` and future supporting documents.
