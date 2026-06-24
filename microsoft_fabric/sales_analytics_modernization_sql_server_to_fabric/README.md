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

![Sales Analytics Modernization High Level Architecture](docs/img/sales_analytics_modernization_high_level_architecture.png)

## Technologies

| Category       | Technology          |
| -------------- | ------------------- |
| Source system  | SQL Server          |
| Cloud platform | Microsoft Fabric    |
| Orchestration  | Fabric Pipelines    |
| Storage        | Fabric Lakehouse    |
| Analytics      | Fabric Warehouse    |
| Processing     | SQL / PySpark       |
| Reporting      | Power BI            |
| Control layer  | Azure SQL Database  |

## Documentation

The solution design is supported by detailed documents.

| Area                          | Document                                                                                          | Purpose                                                                                                                       |
| ----------------------------- | ------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Current state assessment      | [01_current_state_assessment.md](docs/01_current_state_assessment.md)                             | Defines the current Sales data platform, its limitations, and the modernization need                                         |
| Source Data Profile           | [02_source_data_profile.md](docs/02_source_data_profile.md)                                       | Defines the SQL Server source databases, their roles, estimated volumes, growth, and profiling assumptions                   |
| Target Data Architecture      | [03_target_data_architecture.md](docs/03_target_data_architecture.md)                             | Defines the Fabric target structure, including the Lakehouse Bronze/Silver schemas and Warehouse Staging/Gold schemas        |
| Data Flow Strategy            | [04_data_flow_strategy.md](docs/04_data_flow_strategy.md)                                         | Defines the historical reporting flow from `Sales_Analytics` and the new reporting flow from `Sales_Operational`             |
| Load Strategy                 | [05_load_strategy.md](docs/05_load_strategy.md)                                                   | Defines the append, incremental, full reload, batch period reload, and upsert patterns used across the solution              |
| Validation and Reconciliation | [06_validation_and_reconciliation_strategy.md](docs/06_validation_and_reconciliation_strategy.md) | Defines the row count checks, total checks, reconciliation grain, and result tracking in `DataOps_Control`                   |
| CI/CD and Deployment          | [07_ci_cd_and_deployment_strategy.md](docs/07_ci_cd_and_deployment_strategy.md)                   | Defines the Development and Production environments, deployment pipeline usage, repository structure, and deployment scope   |
| Security and Access           | [08_security_and_access_strategy.md](docs/08_security_and_access_strategy.md)                     | Defines authentication, access control, secret handling, source users, `DataOps_Control` access, and sensitive data handling |

## Project Status

| Area                          | Status      |
| ----------------------------- | ----------- |
| Project framing               | In progress |
| Solution design               | In progress |
| Repository structure          | In progress |
| Fabric implementation         | Planned     |
| Validation and reconciliation | Planned     |
| Reporting layer               | Planned     |
