# Azure DEV Environment Setup

## Document Goal

This document describes the Azure DEV environment implemented for the `hybrid_data_integration_to_azure_sql` project.

It records the Azure resources, security configuration, network access, and connectivity that have already been configured and validated.

## Environment

| Area | Configuration |
|---|---|
| Subscription | Pay-As-You-Go |
| Environment | `dev` |
| Primary region | Australia East |
| Project code | `hdi` |
| Resource group | `rg-hdi-dev-aue-001` |

## Azure Resources

| Resource | Name |
|---|---|
| Azure Resource Group | `rg-hdi-dev-aue-001` |
| Azure Data Factory | `adf-hdi-dev-aue-001` |
| Azure Data Lake Storage Gen2 | `sthdidevaue001` |
| Azure SQL logical server | `sql-hdi-dev-aue-001` |
| Azure SQL Database | `Enterprise_Operational` |
| Azure Key Vault | `kv-hdi-dev-aue-001` |
| Self-hosted Integration Runtime | `ir-hdi-selfhosted-dev` |

Resource naming pattern:

```text
<resource-type>-<project>-<environment>-<region>-<instance>
```

## Azure Data Factory

Azure Data Factory is the orchestration service for the solution.

### Integration Runtimes

| Name | Type | Purpose |
|---|---|---|
| `ir-hdi-selfhosted-dev` | Self-Hosted | Establish communication between Azure Data Factory and on-premises systems |
| `AutoResolveIntegrationRuntime` | Azure | Azure-hosted connectivity |

### Linked Services

| Source | Name | Type | Integration Runtime |
|---|---|---|---|
| `Sales_Operational` | `ls_sqlserver_source` | SQL Server | `ir-hdi-selfhosted-dev` |
| `ADVENTUREWORKS2022` | `ls_oracle_source` | Oracle | `ir-hdi-selfhosted-dev` |
| `sthdidevaue001` | `ls_adls` | Azure Data Lake Storage Gen2 | `AutoResolveIntegrationRuntime` |
| `DataOps_Control` | `ls_azuresql_dataops_control` | Azure SQL Database | `AutoResolveIntegrationRuntime` |
| `Enterprise_Operational` | `ls_azuresql_serving` | Azure SQL Database | `AutoResolveIntegrationRuntime` |
| `kv-hdi-dev-aue-001` | `ls_keyvault` | Azure Key Vault | N/A |

### Managed Identity

The Data Factory system-assigned managed identity is used for Azure service authentication where supported.

The Data Factory managed identity is used to authenticate to the following Azure resources:

- `sthdidevaue001`
- `DataOps_Control`
- `Enterprise_Operational`
- `kv-hdi-dev-aue-001`

## Azure Key Vault

Azure Key Vault has been created for credentials that cannot use managed identity.

Current secrets:

| Name | Purpose |
|---|---|
| `oracle-user-hdi-adf-reader-password` | Store password |
| `sqlserver-login-hdi-adf-reader-password` | Store password |

Role assignments:

| Role | Resource affected |
|---|---|
| `Key Vault Secrets Officer` | Azure account |
| `Key Vault Secrets User` | Azure Data Factory |

Key Vault secrets are used by the following source connections:

- `Sales_Operational`
- `ADVENTUREWORKS2022`

## Azure Data Lake Storage Gen2

The storage account was configured with:

| Setting | Value |
|---|---|
| Account type | General-purpose v2 |
| Performance | Standard |
| Hierarchical Namespace | Enabled |
| Secure transfer | Enabled |
| Anonymous Blob access | Disabled |
| Storage account key access | Disabled |
| Default portal authorization | Microsoft Entra |
| Minimum TLS | TLS 1.2 |

Containers:

| Name | Purpose |
|---|---|
| `bronze` | Raw landed source data |
| `silver` | Curated data produced by Databricks |

> The ADF managed identity was granted `Storage Blob Data Contributor` on the storage account Access Control.

## Azure SQL

The server was configured with:

| Setting | Value |
|---|---|
| Microsoft Entra-only authentication | Enabled |
| SQL authentication | Disabled |
| Public access | Selected networks |

Databases:

- `Enterprise_Operational`

## DataOps_Control

`DataOps_Control` is an existing Azure SQL Database used for metadata and execution control.

The implementation of this resource is not part of this project, as it is assumed to have been created previously and is maintained in a separate resource group: `rg-dataops-control-dev-aue-001`.
