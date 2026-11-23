# ACT-03 — Microsoft Fabric Resource Design

**Project:** Fabric Enterprise Knowledge Platform  
**References:** HLD v1.1 — Consolidated Architecture; ACT-02 — Azure and Fabric Environment and Resource Architecture  
**Status:** Draft — pending specialist review  
**Scope:** MVP Fabric resource design; no provisioning or implementation

## 1. Purpose and design principles

Map the approved Bronze → Silver → Gold → Retrieval architecture to Microsoft Fabric resources while keeping DEV simple enough for the existing trial capacity. Preserve governed, reusable knowledge in Fabric; Azure AI Search remains a **derived retrieval index**, not the authoritative store.

- **Logical enterprise design:** Separate DEV and PROD workspaces and operational boundaries; no dedicated TEST environment.
- **Portfolio implementation:** Initially one DEV workspace on Fabric trial capacity. A logical PROD design is documented but not claimed as deployed or isolated. One Azure subscription and one physical Azure SQL `DataOps_Control` may be shared, with logical environment segregation.
- **MVP boundary:** Document/evidence retrieval and validation; no generated answers, conversational agent, or employee-facing search UI.

## 2. Proposed Fabric resource mapping

| Fabric resource | Layer / role | Main responsibilities | Design decision |
|---|---|---|---|
| **Knowledge Lakehouse** | Bronze + Silver | Store captured source files/definitions and capture metadata; hold extracted, standardized content and source-local metadata | **One Lakehouse**, with clear Bronze/Silver namespaces or paths; controlled retention of Bronze copies |
| **Knowledge Warehouse** | Gold | Store trusted knowledge assets, versions, full-content references, evidence, relationships, lifecycle and policy references | **One Warehouse**; dedicated Gold schemas |
| **Knowledge Warehouse** | Project configuration | Store project-owned, admin-managed processing and knowledge-policy configuration where appropriate | Separate configuration schemas from Gold; validate write, audit and administration requirements |
| **Retrieval Lakehouse** | Retrieval | Persist structure-aware chunks, embeddings, model/version information, source evidence, section identifiers and security references | **Recommended separate logical Lakehouse** to isolate retrieval processing and permissions; confirm with specialists |
| **Data Pipelines** | Orchestration | Ingest, standardize, prepare knowledge, publish index changes, control retries and execution boundaries | Responsibility-based parent/child pipelines; parameterize common steps |
| **Notebooks** | Processing | Parse/standardize content, build knowledge outputs, chunk text, generate/store embeddings, prepare publication payloads | Reusable parameterized notebooks where practical |
| **Fabric connections / gateway** | Connectivity | Read-only access to on-prem SQL Server and approved external knowledge sources; reach existing control services | Reuse proven SQL gateway and GitHub integration; SharePoint connectivity remains unavailable |

**Outside Fabric but required by HLD:** Azure SQL `DataOps_Control` (operational control), embedding model service, Azure AI Search, Entra ID, secret management, and a trusted **request-time retrieval/authorization boundary**. The physical form of the authorization boundary remains to be validated; storing permission fields in an index is insufficient by itself.

## 3. Organization and separation

| Logical environment | Workspace | Capacity / deployment intent |
|---|---|---|
| **DEV** | One DEV workspace containing the Fabric items above | Existing trial capacity; development, integration, QA and security tests |
| **PROD** | One separate PROD workspace with equivalent item responsibilities | Target design only; paid/suitable capacity and independent access/security controls required before production claims |

Within the shared DEV workspace, enforce separation using item permissions, distinct schemas/paths, controlled service identities and configuration. This is **not equivalent to physical PROD isolation**. Gold and Retrieval require special attention because they can contain sensitive text, chunks, embeddings and policy metadata.

## 4. Orchestration approach

Group pipelines by **responsibility**, not necessarily by source. A parent pipeline coordinates dependencies, while reusable child pipelines/notebooks accept parameters (for example `source_system`, `source_object`, `execution_run_id`).

**Candidate process hierarchy:**

1. **Knowledge Source Ingestion** — inventory, extract source metadata/content, capture Bronze originals, register outcomes.
2. **Knowledge Standardization** — metadata standardization and content extraction into Silver.
3. **Knowledge Preparation** — Gold-to-Retrieval chunking and versioned embeddings.
4. **Knowledge Indexing** — controlled Azure AI Search publication, upsert/delete and reconciliation.

Source-specific connectors and extraction behavior remain specialized when needed. Independent source/item execution, checkpoints, dependency-aware reruns, partial-failure handling and audit records must remain possible. Existing Azure SQL `DataOps_Control` is reused **where capabilities are supported**; do not assume it already manages Search indexing or every non-dataflow operation.

## 5. Configuration, dependencies and constraints

| Area | Requirement / open validation |
|---|---|
| Lakehouse layout | Define Bronze/Silver paths/tables and lifecycle conventions without merging their responsibilities; ensure originals and complete supported extracts remain available |
| Warehouse | Confirm schemas and permissions for Gold vs project-owned configuration; validate admin-edit, audit and scheduling requirements |
| Retrieval | Validate Delta/vector persistence, model-version tracking, chunk/section-policy integrity and publication contract with Azure AI Search |
| Identity/security | Separate processing and retrieval privileges; protect sensitive original text and derivatives; enforce current role/department/sensitivity and section-level policy at request time, with fail-closed and next-request revocation |
| DEV/PROD control | Keep configurations, execution IDs, watermarks, checkpoints, secrets and index names logically distinct where infrastructure is shared |
| Capacity/continuity | Use trial as long as feasible; preserve notebooks, pipelines, settings and deployment artifacts for redeployment if trial expires |
| Source readiness | Both on-prem SQL databases via gateway and GitHub are accessible; SharePoint is missing, so initial vertical slice may use SQL/GitHub but cannot validate complete source coverage |
| AI/Search readiness | Azure AI Search and embedding service not yet provisioned/confirmed; validate SKU, model compatibility, access and budget before search work |
| Observability | Record per-source/item failures, indexing status, reconciliation and freshness; target searchable updates within 60 minutes, with monitored exceptions |

## 6. Initial DEV validation path

**Proposed vertical slice:** SQL Server *or* GitHub → Bronze → Silver → Gold → Retrieval → Azure AI Search → trusted authorization/retrieval tests.

Validate source-to-index lineage, idempotent reprocessing, index reconciliation, evidence-backed results, and permission-safe retrieval. Expand to all four sources only when SharePoint access is established. No PROD provisioning or security-readiness claim is implied by this draft.

## 7. Decisions and specialist review

| ID | Proposed decision | Status |
|---|---|---|
| FAB-01 | One Lakehouse for Bronze and Silver, logically separated | Proposed; Data Engineer and Security review |
| FAB-02 | One Warehouse for Gold and project configuration, in separate schemas | Proposed; Data Engineer and Security review |
| FAB-03 | Lakehouse persistence for Retrieval chunks and embeddings; preferably a distinct Retrieval Lakehouse | Recommended; Data Engineer, AI/Search and Security review |
| FAB-04 | Responsibility-based, parameterized pipelines with source-specific adapters and independent recovery | Proposed; Data Engineer review |
| FAB-05 | One workspace per logical environment; portfolio runs initial DEV on trial capacity | Proposed; Security review; ACT-02 constraints apply |
| FAB-06 | Preserve current-policy, section-aware authorization outside the index-only security assumption | Required by HLD; AI/Search and Security validation pending |

**Requested specialist review:** Identify only critical contradictions, security/capability gaps or changes required before implementation. Provide **Accept / Accept with Conditions / Revision Required**, concisely, within the specialist's scope.

**Solution Architect status:** Design proposal ready for specialist review. All ACT-02 readiness conditions remain open until their respective validation gates are met; this document does not certify technical feasibility or production readiness.
