# Sales Platform Modernization: SQL Server to Microsoft Fabric

## Overview

This project presents a Sales data platform modernization from an on-premise SQL Server environment to Microsoft Fabric.

The goal is to design a cloud-based architecture that supports historical migration, incremental data processing, operational data structures, analytical reporting, and controlled execution tracking.

This project is part of a data engineering portfolio focused on cloud modernization, Microsoft Fabric, data platform design, and migration practices.

## Current-State Assessment and Modernization Drivers

The current Sales platform runs on an on-premise SQL Server 2022 instance and is separated into two databases:

| Database            | Role                        | Current State                                                      |
| ------------------- | --------------------------- | ------------------------------------------------------------------ |
| `Sales_Operational` | Operational source of truth | Normalized database used to support transactional Sales operations |
| `Sales_Analytics`   | Reporting source of truth   | Star schema used for Sales reporting and business analysis         |

The current environment is not treated as a failed platform. `Sales_Operational` continues to support on-premise operations, and `Sales_Analytics` is a reliable reporting source of truth with existing execution control, metadata management, validation, and reconciliation processes.

The modernization need comes from the growing demand to use Sales analytical data beyond traditional reporting.

| Driver                    | Current Situation                                                         | Modernization Need                                                    |
| ------------------------- | ------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| Reporting modernization   | Sales reporting depends on the on-premise analytical database             | Move reporting ownership to Microsoft Fabric                          |
| Enterprise data access    | Other departments may need curated Sales data                             | Provide a shared cloud analytical layer                               |
| AI and data science       | Data science teams need governed access to historical Sales data          | Make curated Sales data available through Fabric                      |
| ETL duplication           | New consumers may require additional extracts or custom pipelines         | Reduce duplicated ETL by publishing reusable analytical data products |
| Data storage format       | Analytical data is stored in SQL Server structures                        | Use open analytical storage based on Delta/Parquet patterns           |
| Power BI integration      | Reporting depends on the current SQL Server analytical layer              | Enable Fabric-native reporting patterns such as Direct Lake           |
| Long-term maintainability | Large historical tables are maintained through year-based physical copies | Move toward a scalable lakehouse/warehouse structure                  |

The target state is not a full replacement of the on-premise Sales platform. The goal is to keep `Sales_Operational` on-premise while moving the reporting source of truth from `Sales_Analytics` to Microsoft Fabric.

This allows Fabric to become the cloud analytical platform for reporting, AI, data science, and future cross-domain consumption.

## Project Scope

| Area            | In Scope                                  |
| --------------- | ----------------------------------------- |
| Source platform | On-premise SQL Server Sales databases     |
| Target platform | Microsoft Fabric                          |
| Data storage    | Lakehouse and Warehouse patterns          |
| Processing      | Historical and incremental migration      |
| Control         | Metadata-driven execution tracking        |
| Validation      | Data validation and reconciliation design |
| Consumption     | Analytical model for reporting            |

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
Bronze Lakehouse
        |
        v
Curated Operational Data
        |
        v
Sales Analytics Warehouse
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
|   |-- solution_design.md
|
|-- diagrams/        # planned
|-- fabric/          # planned
|-- sql/             # planned
```

## Documentation

| Document                                     | Purpose                                                     |
| -------------------------------------------- | ----------------------------------------------------------- |
| `docs/solution_design.md`                    | Describes the target architecture and main design decisions |
| `docs/source_data_profile.md`                | Planned document for source data analysis                   |
| `docs/data_flow_strategy.md`                 | Planned document for migration and processing flows         |
| `docs/load_strategy.md`                      | Planned document for full, incremental, and batch loading   |
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

```

## Notes

This version keeps the README focused. The detailed explanation should move to `docs/solution_design.md` and future supporting documents.
```
