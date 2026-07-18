# Data engineering projects

This repository is a technical portfolio showcasing real-world data engineering workflows I've designed and implemented using:
- **Azure Synapse Analytics**
- **Databricks / Delta Lake**
- **Microsoft SQL Server (On-Premise)**
- **Microsoft Fabric**

It serves two purposes:
1. **For recruiters and peers** — to showcase my hands-on experience building data pipelines, performing migrations, and optimizing data architectures on modern cloud platforms.  
2. **For learners** — to provide clear, reproducible examples of data engineering patterns, including ingestion, transformation, and performance tuning.

## ⭐ Featured Projects

#### Sales Analytics Modernization: SQL Server to Microsoft Fabric
* Portfolio design baseline for modernizing Sales reporting from on-premise SQL Server to Microsoft Fabric.
* Defines the new documentation standard for future projects, including scope, architecture, source profiling, data flows, load strategy, validation/reconciliation, CI/CD, security, and project dependencies.
* Implementation is planned as the next phase.
* Link: <https://github.com/WilderJoseth/data-engineering-projects/tree/main/microsoft_fabric/sales_analytics_modernization_sql_server_to_fabric>

#### Synapse Dedicated DW → Microsoft Fabric DW Migration (Medallion + Control Plane)
* End-to-end migration data project built using Microsoft Fabric and Synapse.
* Link: <https://github.com/WilderJoseth/data-engineering-projects/tree/main/microsoft_fabric/adventure_works_dw_2022_migration>

#### Azure Synapse – Brazilian E-Commerce Lakehouse:
* End-to-end data lakehouse project built using Azure Synapse Serverless.
* Link: <https://github.com/WilderJoseth/data-engineering-projects/tree/main/azure_synapse/brazilian_e_commerce>

#### Fabric - Study space missions:
* End-to-end data lakehouse / warehouse project built using Microsoft Fabric.
* Link: <https://github.com/WilderJoseth/data-engineering-projects/tree/main/microsoft_fabric/study_space_missions>

## 🗂️ Repository Structure

| Folder | Description |
|---------|--------------|
| **/azure_synapse/** | Projects using Azure Synapse (Serverless/Dedicated), with examples of external tables, CTAS, and `COPY INTO` for initial loads and incremental ingestion. Some follow the **Medallion Architecture** pattern (bronze/silver/gold). |
| **/databricks/** | Notebooks demonstrating Delta Lake pipelines, transformations with PySpark, and cost/performance experiments (Delta optimization, caching, partitioning). |
| **/on_premise/** | Legacy or hybrid SQL Server workloads showing incremental loads, historical data management, and CDC strategies before cloud migration. |
| **/microsoft_fabric/** | Projects using Microsoft Fabric. |

> Each folder contains standalone projects — some fully orchestrated (ADF/Synapse/Fabric), others exploratory or educational (notebooks, scripts, or ETLs focused on specific concepts).

---

## ⚙️ Key Technologies
* **Languages:** SQL (T-SQL), Python (pandas, PySpark)  
* **Cloud / Platforms:** Azure Synapse, Microsoft Fabric, Databricks, Azure Data Lake Storage Gen2  
* **ETL / Orchestration:** Azure Data Factory, SSIS, Pipelines
* **Data Modeling:** Star schema, Medallion (bronze/silver/gold), Parquet/Delta  
* **Governance:** Purview, Unity Catalog  
* **Visualization:** Power BI  
* **Infra & DevOps:** Docker, GitHub Actions, Bicep/Terraform (basics)

---
