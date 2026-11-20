# ACT-02 — Azure and Fabric Environment and Resource Architecture

**Project:** Fabric Enterprise Knowledge Platform  
**Basis:** HLD v1.1 and environment assessment (20 November 2026)  
**Status:** Accepted — with tracked readiness and validation conditions  
**Scope:** MVP; design only, no provisioning

## 1. Purpose

Define the logical DEV/PROD environment design, Azure and Fabric resource needs, dependencies, and an achievable portfolio deployment. The logical target and the actual deployment must be distinguished; shared portfolio infrastructure is **not** evidence of production isolation.

## 2. Environment model

| Area | Logical enterprise target | Portfolio implementation |
|---|---|---|
| Azure subscriptions | Separate DEV and PROD subscriptions | One subscription for both |
| Fabric capacity | Capacity provisioned appropriately for each environment | Existing trial capacity for as long as available |
| Fabric workspaces | Separate DEV and PROD workspaces | Existing DEV workspace; PROD workspace later if needed |
| DataOps_Control | Independent Azure SQL control databases per environment | One existing Azure SQL database; segregate configurations/runs by environment |
| Azure AI Search | Environment-separated search services/indexes and access | Initially one service, with DEV resources/configuration; any PROD simulation explicitly labeled |
| Identity and secrets | Environment-specific identities, privileges and secrets | Available Entra ID / Key Vault or equivalent; enforce feasible logical separation |
| Source systems | Environment-appropriate access and permissions | Existing SQL and GitHub integrations; SharePoint unavailable |

**DEV:** Development, integration testing, QA scenarios and retrieval/security validation.  
**PROD:** Logical deployment target for governed content and authorized retrieval. The portfolio does not claim production-grade isolation until independently deployed and verified.

## 3. Resource inventory and responsibilities

| Component | Purpose | Current state / action |
|---|---|---|
| Fabric capacity | Run Fabric workloads | Trial available; evaluate limits and expiration |
| Fabric workspace(s) | Contain environment-specific Fabric items | DEV exists; design separate PROD |
| Fabric Lakehouse | Bronze raw content/metadata; Silver extracted and standardized knowledge; retrieval persistence as designed | Required Fabric item(s); confirm item layout |
| Fabric Warehouse | Gold trusted structured knowledge and queryable control/configuration data as applicable | Required design evaluation; avoid assuming control-plane migration |
| Fabric pipelines/notebooks | Ingestion, extraction, standardization, chunking, embeddings, and publication orchestration | Required MVP components |
| Azure SQL `DataOps_Control` | Process metadata, run tracking, errors, reconciliation and rerun control | Existing and connected to Fabric; logically independent DEV/PROD |
| On-premises SQL Server sources | Sales operational and analytical metadata/knowledge | Both accessible through existing gateway |
| Connectivity gateway | Secure on-premises access | Working for both SQL sources |
| GitHub | Sales-domain repository knowledge source | Access/integration working |
| SharePoint | Sales Knowledge Portal document source | **Missing**; define test-source availability before full MVP validation |
| Azure AI Search | Index and retrieve authorized published knowledge | **Not created**; evaluate SKU, indexes, identity, access and cost |
| Embedding model service | Generate versioned embeddings for persistent retrieval assets | **Not confirmed**; choose service/model and authentication before embeddings implementation |
| Microsoft Entra ID | Authentication and authorization identities | Available; map roles/departments and retrieval authorization |
| Key Vault or equivalent | Credential/secret management | Available; validate per-environment secret handling |
| Monitoring/logging | Freshness, pipeline/index status, failures and audit trail | Use DataOps_Control plus applicable platform telemetry; finalize scope |

**Source-of-truth boundary:** Fabric contains centralized governed knowledge; end-user retrieval does not query original source systems. Azure AI Search is a rebuildable serving index, not the authoritative store.

## 4. Security and operational boundaries

- Apply least privilege to ingestion, transformation, indexing, and retrieval identities.
- Enforce role/department/sensitivity and approved section-level access at retrieval time; permissions must reflect current authorization and fail closed on uncertainty.
- Keep DEV content masked or synthetic where sensitive; avoid production data exposure through trial/shared resources.
- Separate configuration, indexes, secrets, naming and execution records logically even when sharing physical portfolio resources.
- Track source provenance, versions, quality and freshness; target searchable updates within 60 minutes under agreed operating conditions.
- Treat all unverified enterprise controls (especially isolation and immediate permission revocation) as **pending validation**, not implemented capabilities.

## 5. Dependencies and readiness

| Dependency | Priority | Next decision / validation |
|---|---|---|
| SharePoint environment | High | Arrange an accessible portal or representative test source for complete MVP coverage |
| Azure AI Search | High | Confirm service configuration, security approach, and cost before creation |
| Embedding service | High | Confirm API/service availability, model/version policy and budget |
| Fabric trial continuity | High | Check expiration, workload constraints, and fallback; no assumed production SLA |
| Dynamic access enforcement | High | Validate current-permission checks, section-level filtering and fail-closed behavior |
| DEV/PROD separation | Medium | Define naming and segregation; document shared physical infrastructure risk |
| Control-plane reuse | Medium | Confirm DataOps_Control supports isolated environments and non-dataflow operations |
| Capacity/cost sizing | Medium | Estimate data volumes, refresh frequency, indexing and embedding consumption |

## 6. Proposed sequencing (no provisioning in ACT-02)

1. **Completed:** Technical specialists reviewed the logical inventory, environment model, and portfolio constraints.
2. Finalize DEV/PROD naming, workspace boundaries, identities, control configuration and resource dependencies.
3. Validate trial limits, AI Search/embedding service prerequisites and estimated spend.
4. Resolve SharePoint test-source strategy and the initial source coverage plan.
5. Approve the minimum DEV vertical slice: SQL or GitHub → Bronze → Silver → Gold → Retrieval → Azure AI Search, with access and freshness tests.
6. Defer PROD provisioning and claims of production isolation until independently validated.

## 7. Architecture decisions and risks

| ID | Decision / accepted constraint |
|---|---|
| ENV-01 | Design assumes distinct DEV and PROD subscription/security boundaries; portfolio shares one subscription. |
| ENV-02 | Trial Fabric capacity used as long as possible for portfolio DEV; expiration/limits are accepted risks. |
| ENV-03 | Logical DEV and PROD DataOps_Control databases are separate; portfolio shares one physically. |
| ENV-04 | Logical DEV/PROD search environments are separate; portfolio initially uses one service. |
| ENV-05 | No dedicated TEST environment; testing and QA validation take place in DEV. |
| ENV-06 | SharePoint absence prevents claiming full MVP source integration. |

## 8. Specialist review and acceptance

| Reviewer | Verdict | Required architecture change |
|---|---|---|
| Security/Governance Specialist | Accept | None |
| Data Engineer | Accept with Conditions | None |
| AI/Search Engineer | Accept with Conditions | None |

**Consolidated Solution Architect verdict: ACCEPT — with tracked conditions.** ACT-02 is approved as the DEV implementation-planning baseline; no HLD or resource-architecture redesign is required.

### Tracked conditions

| ID | Condition | Completion gate |
|---|---|---|
| C-01 | Establish Sales Knowledge Portal access or a representative SharePoint test source | Before claiming complete four-source MVP validation |
| C-02 | Preserve code, configurations and deployment artifacts against Fabric trial expiration | During DEV preparation |
| C-03 | Keep `DataOps_Control` configurations, execution IDs, checkpoints and recovery operations isolated by environment | Before shared DEV/PROD operations |
| C-04 | Confirm Azure AI Search SKU/capabilities and embedding service/model, including persistent-vector compatibility | Before search and embedding implementation |
| C-05 | Demonstrate request-time, section-aware authorization, next-request permission revocation and fail-closed behavior | Before exposing restricted content or claiming secure retrieval |
| C-06 | Maintain separate logical search configurations and credentials; clearly label portfolio infrastructure as DEV/testing, not production isolation | Throughout implementation and reporting |

The conditions are implementation prerequisites or validation gates, **not blockers to initial DEV setup**. SharePoint absence does not block an initial SQL Server/GitHub vertical slice, but prevents full MVP acceptance.

**Approval limitation:** This acceptance does not authorize PROD deployment or certify production isolation, access controls, or service readiness. No resources have been provisioned as part of ACT-02.
