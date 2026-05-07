# Oracle to SQL Server 2022 Migration Architecture
## Sales Domain Modernization Project

## Overview

This project presents a migration and modernization case study for moving a Sales-focused legacy data domain from Oracle to SQL Server 2022.

The objective is to design and document a phased migration solution using professional data engineering practices, from problem framing and target architecture to implementation-oriented design decisions.

This case study is intended to:
- Explain the migration problem
- Propose a target solution from architecture to implementation design
- Justify the main technical decisions
- Evaluate whether key data engineering design concepts are applied appropriately

## Problem Context

The scenario assumes that a company has operated for more than 10 years with a legacy Oracle database as its main business data platform.

Over time, the company has accumulated transactional, historical, and reference data in Oracle while also relying on database-side logic to support operational processing and reporting. As the business evolves, a **new web platform** is introduced to modernize operational processes and improve maintainability. As a result, business data must be migrated to a new database platform hosted on SQL Server 2022.

The company has chosen to execute the migration in phases defined by business domain. For that reason, the first migration scope is centered on the **Sales domain**, including the supporting entities required for customer, product, territory, and related sales processing. This means the project does not attempt to migrate the full legacy platform at once, but instead focuses on one domain with clear business value and strong dependency on surrounding master data.

## Architecture Overview

The proposed architecture separates the migration into operational and analytical workloads.

Data is first migrated from the Oracle Sales domain into `Sales_Operational`, which becomes the normalized operational target for the new application. After the operational data is validated and reconciled, `Sales_Analytics` is built from `Sales_Operational` as the curated source.

A reusable `DataOps_Control` database acts as the technical control plane for the solution. It stores project metadata, execution tracking, validation and reconciliation results, error logs, and rerun support information used by the ETL processes.

![Sales Domain Architecture](docs/img/data_processing_design.png)

## Data Source Profile

The source model is based on an Oracle-adapted version of **AdventureWorks2022** and represents a multi-domain environment that includes Sales and supporting areas such as customer, product, and purchasing data.

From a migration perspective, the source cannot be treated as a uniform dataset. It contains:
- **Reference data**, which is generally low-volume and relatively stable
- **Master data**, which is low-to-medium volume and supports core Sales processing
- **Transactional data**, which represents the main operational workload and includes larger tables that may reach millions of rows
- **Historical data**, which may span many years and includes very large tables

### Characteristics
- Oracle XE 21c
- Source schema: `ADVENTUREWORKS2022`

## Related Document

For the technical design and decision rationale, see:
- [Solution Design](docs/solution_design.md)

## Project Scope

### In Scope

- Sales domain migration and modernization
- Supporting entities required for Sales processing
- SQL Server 2022 target design
- Operational and analytical workload separation
- Technical control framework
- Execution traceability and reconciliation

### Out of Scope

- Full migration of all source domains
- Full ERP replatforming
- Detailed application design for the new web platform
- Exhaustive debate about platform selection
- Production infrastructure sizing and deployment topology
