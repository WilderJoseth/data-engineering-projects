# Fabric Enterprise Knowledge Platform
## Senior Data Engineer — Architecture Review Report (Updated)

**Date:** 2026-11-17  
**Basis:** Business Requirements Baseline v0.5; HLD v1.0 Draft; Data Architect and AI/Search review reports; agreed technical assessment decisions  
**Purpose:** Input for Solution Architect HLD consolidation  
**Assessment:** **Accept the Data Engineering architecture direction**, with targeted implementation validation.

### 1. Assessment

The proposed **source ingestion → Bronze → Silver → Gold → Retrieval → Azure AI Search** flow is appropriate for the MVP. Source systems remain authoritative; the platform preserves complete permitted source content and evidence. The agreed MVP delivers **retrieval of existing knowledge**, not generated answers. No additional processing platform is recommended.

**MVP knowledge sources:** `Sales_Operational` and `Sales_Analytics` (separate on-premises SQL Server instances), the **Sales Domain Migration** GitHub repository, and the **Sales Knowledge Portal** in SharePoint. The **Azure SQL `DataOps_Control`** database supports operations; its contents are not knowledge ingested for search.

### 2. Source assessment

| Source | Known characteristics | Engineering decision |
|---|---|---|
| SQL Server | ~500 objects in `Sales_Operational`; ~100 in `Sales_Analytics`. On-premises Data Gateway and SQL authentication are used. | Read-only catalog extraction; initial full inventory, then full inventory comparisons with changed-object processing. Assess each instance separately. |
| GitHub | Up to ~3,000 files per repository; Markdown files up to ~500 lines. Web/Web v2 activities are already used in other projects. | Preserve complete in-scope files; initial repository snapshot, followed by commit/tree change detection and periodic inventory reconciliation. |
| SharePoint | ~500 Office documents; some Word files reach ~500 pages. Word/Excel are mostly text and tables; PowerPoint is primarily images. No connection established yet. | Preserve complete original files in Lakehouse Bronze; use a supported SharePoint/Graph extraction path, with delta detection where available and full inventory fallback. |

Changes are **typically monthly**, ranging from small schema changes to multiple new objects. Related GitHub commits and SharePoint updates are expected but **must not be assumed synchronized** with SQL deployment.

### 3. Agreed engineering decisions

| Area | Decision |
|---|---|
| **Bronze** | Keep complete original documents/files in **Lakehouse Files**, alongside capture metadata. Retain initial and changed versions rather than re-copying unchanged content when reliable change detection exists. Preserve SQL definitions and source evidence. |
| **Identity and change handling** | Maintain source-qualified stable asset IDs, source versions, timestamps and change evidence. Track additions, modifications, deletions and renames. Preserve identity on a confirmed rename; do not infer continuity from similar logic or names alone. |
| **Silver** | Preserve **complete extractable content**, structure and source references; do not summarize or truncate. Normalize SQL metadata, repository files and Office content independently. |
| **Embedded/visual content** | Skip complex embedded-object extraction in the MVP. Preserve originals and label known extraction limitations. Image-heavy PowerPoint slides may yield little searchable text. |
| **Quality states** | Track **Success / Partial / Failed / Skipped** at item level, plus overall run/step status. Publish permitted partial content with explicit quality indicators; block critically invalid or unauthorized content. |
| **Orchestration** | Run source-specific ingestion processes independently. Unrelated successful sources continue despite another source's failure; enforce genuine downstream dependencies. |
| **Recovery** | Use bounded automatic retries, durable checkpoints, idempotent writes and **item-level reruns**. Keep full refresh/reconciliation as recovery options. |
| **Reconciliation** | Compare source inventory, captured changes, processed items and expected outputs, accounting for exclusions and partial extraction. Do not treat pipeline success as proof of completeness. |
| **Technology choice** | Prefer the simplest maintainable Fabric-native method: pipelines for orchestration/copy, SQL for straightforward relational work, Python for API/document extraction, PySpark when Spark/Delta or distributed processing adds value. |
| **Operational tracking** | Reuse **Azure SQL `DataOps_Control`**, which supports execution/step and individual item tracking. Avoid a new control framework. |
| **Project configuration** | Use **Fabric Warehouse** for administrator-editable project parameters, separate from `DataOps_Control`; changes must be audited and should not require redeployment. Validate execution-schedule synchronization and update permissions. |

Gold retains complete normalized knowledge and source evidence under the Data Architect's model. Retrieval chunks, embeddings and publication belong to the AI/Search workstream; Data Engineering provides reliable inputs, provenance and processing outcomes.

### 4. Freshness, performance and cost

- **Freshness target:** **60 minutes** from source change to searchable content, initially; administrators can update the target through configuration. **15-minute ingestion checks** are a provisional scheduling option, not a proven end-to-end service guarantee.
- **Capacity:** Use existing Fabric resources and bounded concurrency first. **F8** is an *exploratory sizing candidate*, not an approved SKU; large Office files and notebook startup/resource consumption require benchmarking.
- **Cost:** Prefer incremental extraction, unchanged-file reuse and controlled parallelism. An **illustrative, nonbinding planning guide of US$100/month for incremental processing/storage** (excluding existing Fabric capacity, Azure AI Search and shared services) may be used for early monitoring; it is **not a cost estimate**. Review against actual bills and consumption.

### 5. Implementation validations (not architecture blockers)

| Validation | Action |
|---|---|
| SharePoint access | Establish approved connection, permissions, file enumeration/download and change/delete detection. |
| Source connectivity | Verify both SQL Server gateway paths and read-only metadata visibility; verify GitHub API permissions, pagination and rate limits. |
| Source profiling | Measure actual byte sizes, formats, extraction completeness, change rates and inventory reconciliation results. |
| Identity/lifecycle | Test rename, drop/recreate, deletion and version continuity across each source. |
| Runtime controls | Confirm Warehouse configuration-update/audit behavior and mapping of execution/item states to existing `DataOps_Control` facilities. |
| Performance | Benchmark representative large Office documents, concurrency and full source-to-search freshness with AI/Search. |

### 6. Cross-workstream dependencies (for Solution Architect)

- **Data Architect:** Approve Gold identity/version/relationship contracts and source-evidence semantics.
- **Security/Governance:** Approve effective permissions, classification propagation, retention and deletion policy; define whether extraction gaps affecting image-only documents are acceptable for MVP coverage.
- **AI/Search Engineer:** Validate Gold→Retrieval handoff, publication status/reconciliation, removal of retired content and the end-to-end freshness measurement.
- **Solution Architect:** Confirm Fabric capacity and final ownership of configuration/scheduling boundaries.

### 7. Recommendation

**Retain the proposed HLD.** The Data Engineering workstream has a clear approach for source-specific ingestion, complete-content preservation, versioning, independently recoverable processing, validation, operational tracking and configurable freshness. Proceed to source connectivity/profiling tests and detailed design using these decisions; no major architectural change is required.
