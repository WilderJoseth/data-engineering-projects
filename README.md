# Data engineering projects

This repository is a **technical portfolio** and **learning space** where I document real data engineering workflows I've built using:
- **Azure Synapse Analytics**
- **Databricks / Delta Lake**
- **Microsoft SQL Server (On-Premise)**

It serves two purposes:
1. **For recruiters and peers** — to showcase my hands-on experience building data pipelines, performing migrations, and optimizing data architectures on modern cloud platforms.  
2. **For learners** — to provide clear, reproducible examples of data engineering patterns, including ingestion, transformation, and performance tuning.

## 🗂️ Repository Structure

| Folder | Description |
|---------|--------------|
| **/zure_synapse/** | Projects using Azure Synapse (Serverless/Dedicated), with examples of external tables, CTAS, and `COPY INTO` for initial loads and incremental ingestion. Some follow the **Medallion Architecture** pattern (bronze/silver/gold). |
| **/databricks/** | Notebooks demonstrating Delta Lake pipelines, transformations with PySpark, and cost/performance experiments (Delta optimization, caching, partitioning). |
| **/on_premise/** | Legacy or hybrid SQL Server workloads showing incremental loads, historical data management, and CDC strategies before cloud migration. |

> Each folder contains standalone projects — some fully orchestrated (ADF/Synapse), others exploratory or educational (notebooks, scripts, or ETLs focused on specific concepts).

---

## ⚙️ Key Technologies
* **Languages:** SQL (T-SQL), Python (pandas, PySpark)  
* **Cloud / Platforms:** Azure Synapse, Microsoft Fabric, Databricks, Azure Data Lake Storage Gen2  
* **ETL / Orchestration:** Azure Data Factory, SSIS  
* **Data Modeling:** Star schema, Medallion (bronze/silver/gold), Parquet/Delta  
* **Governance:** Purview, Unity Catalog  
* **Visualization:** Power BI  
* **Infra & DevOps:** Docker, GitHub Actions, Bicep/Terraform (basics)

---
