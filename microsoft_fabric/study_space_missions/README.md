# Data processing using Fabric

The goal of this project was to build a **data lakehouse structure** on Azure using **Fabric - Spark** for exploration, transformation, and reporting.
Additionality, the curated data was loaded into data warehouse base.

Technologies:

* Azure SQL database
    * Store run history and data configuration.
* Delta tables
	* For storage.
* Microsoft Fabric - Spark
	* For data cleaning and transformation.
* Microsoft Fabric - Warehouse
	* For data warehouse.
* Pipelines
	* For orchestation.

Link data: <https://www.kaggle.com/datasets/sidraaazam/a-comprehensive-study-of-space-missions>

## 1. Data Processing Design

The data was organized following a **medallion architecture**:

| Layer | Description | Example Path |
|--------|--------------|--------------|
| **Raw** | Original CSV files in synapse storage | `/raw/study_space_missions/*.csv` |
| **Bronze** | Managed tables without data transformation | `/Tables/bronze` |
| **Silver** | Managed tables after data transformation | `/Tables/silver` |
| **Staging** | Warehouse tables | |
| **Production** | Warehouse tables | |

![Data Processing Design](docs/img/data_processing_design.png)

## 2. Workflow

The workflow is made of a series of pipelines:

### 2.1. Main pipeline

![Main pipeline](docs/img/01_pl_main.png)

### 2.2. Sub main pipeline

![Sub Main pipeline](docs/img/02_pl_sub_main.png)

### 2.3. Medallion process

![ETL Medallion](docs/img/03_pl_etl_medallion.png)

### 2.4. Medallion process

![Gold Warehouse](docs/img/04_pl_gold_warehouse.png)

## 3. Limitations

This project has the following limititations:

* Silver data is removed during each run.
