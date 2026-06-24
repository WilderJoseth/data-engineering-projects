# Security and Access Strategy

## Document Goal

This document defines the security and access strategy for the Sales Analytics Modernization project.

## Connection Authentication Strategy

| Connection Area               | Authentication Method | Purpose                                                             |
| ----------------------------- | --------------------- | ------------------------------------------------------------------- |
| On-premise SQL Server sources | Basic authentication  | Reads data from `Sales_Operational` and `Sales_Analytics`           |
| Lakehouse                     | OAuth 2.0             | Connects to `lh_sales_operational`                                  |
| Warehouse                     | OAuth 2.0             | Connects to `wh_sales_analytics`                                    |
| Pipeline orchestration        | OAuth 2.0             | Supports Fabric pipeline orchestration                              |
| Azure SQL `DataOps_Control`   | Workspace identity    | Supports execution control, validation, reconciliation, and logging |

Authentication methods and credentials are configured in Fabric connection management. They are not stored in notebooks, pipelines, SQL scripts, documentation, or the GitHub repository.

## On-Premise Source Access

The on-premise SQL Server source connections use dedicated database users with read-only permissions.

| Source Database     | Recommended User                       | Recommended Role                  | Permission                           |
| ------------------- | -------------------------------------- | --------------------------------- | ------------------------------------ |
| `Sales_Operational` | `user_sales_operational_fabric_reader` | `Sales_Operational_Fabric_Reader` | `SELECT` on schema `prod`            |
| `Sales_Analytics`   | `user_sales_analytics_fabric_reader`   | `Sales_Analytics_Fabric_Reader`   | `SELECT` on schemas `dim` and `fact` |

## DataOps Control Access

The `DataOps_Control` connection uses workspace identity with permissions assigned through a dedicated database role.

| Database | Recommended Identity / User | Recommended Role | Permission |
|---|---|---|---|
| `DataOps_Control` | Fabric workspace identity | `DataOps_Control_Fabric_Executor` | `SELECT`, `INSERT`, and `EXECUTE` on approved control schemas |

## Secret Handling

Secrets are managed through Fabric connection management or the relevant platform security configuration.

| Secret Type                              | Storage Location                      |
| ---------------------------------------- | ------------------------------------- |
| SQL passwords for on-premise connections | Fabric connection management          |
| OAuth credentials                        | Fabric-managed authentication         |
| Workspace identity access                | Fabric / Azure identity configuration |
| Tokens and client secrets                | Not stored in project artifacts       |
| Connection ids                           | Variable Library                      |
| Item ids                                 | Variable Library                      |

Secrets must not be stored in:

| Location               | Rule                     |
| ---------------------- | ------------------------ |
| GitHub repository      | No secrets committed     |
| Notebooks              | No hardcoded credentials |
| Pipelines              | No hardcoded credentials |
| SQL scripts            | No passwords or tokens   |
| Markdown documentation | No passwords or tokens   |
| Variable Library       | No passwords or tokens   |

## Sensitive Data Handling

The source platform may contain sensitive customer, address, employee, and payment-related data. Sensitive data must not be broadly exposed in any target layer, including Bronze and Silver.

Bronze and Silver may retain source-aligned or curated sensitive attributes when required for processing, validation, or transformation. However, access to those layers should be restricted to approved technical users and service identities. Developers and analysts should not automatically have access to sensitive attributes such as full credit card numbers, personal contact details, or unnecessary customer identifiers.

Sensitive data handling is applied by layer.

| Layer          | Security Approach                                                                                                                             |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| Bronze         | Stores source-aligned data for ingestion and traceability; access is restricted and sensitive fields are not broadly exposed                  |
| Silver         | Stores curated operational data for transformation; access is restricted and sensitive fields are masked, excluded, or limited where possible |
| Gold           | Publishes only reporting-safe attributes required for business analysis                                                                       |
| Semantic Model | Exposes only approved reporting fields when implemented                                                                                       |

Recommended handling by data area:

| Data Area                         | Recommended Handling                                                                                        |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| Credit card data                  | Do not expose full card values; keep only reporting-safe payment attributes or last four digits if required |
| Customer email                    | Mask or exclude unless required for reporting                                                               |
| Customer phone                    | Mask or exclude unless required for reporting                                                               |
| Customer address                  | Prefer reporting-safe geography attributes such as city, state/province, country, or territory              |
| Customer name                     | Expose only if required for reporting                                                                       |
| Salesperson / employee attributes | Expose only business reporting attributes                                                                   |

## Security Rules

| Rule                             | Description                                                                                      |
| -------------------------------- | ------------------------------------------------------------------------------------------------ |
| Use least privilege              | Grant only the access required for each process                                                  |
| Use read-only source users       | Fabric source connections must not modify source databases                                       |
| Separate environments            | Development and Production use separate workspaces, connections, and variable values             |
| Avoid hardcoded credentials      | Credentials must not be stored in code, scripts, notebooks, or documentation                     |
| Restrict Bronze and Silver       | Raw and curated operational data should not be broadly exposed                                   |
| Publish reporting-safe Gold data | Gold should contain only approved reporting attributes                                           |
| Keep execution traceability      | Data loads should be traceable through `DataOps_Control`                                         |
| Do not reuse broad ETL accounts  | Existing ETL accounts with write permissions should not be reused for Fabric read-only ingestion |
