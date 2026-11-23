# Fabric Enterprise Knowledge Platform
## Data Architecture Review Report — Updated

**Role:** Data Architect  
**Basis:** Business Requirements Baseline v0.5; HLD v1.0 Draft; AI/Search Architecture Review (13 Nov 2026); stakeholder decisions  
**Purpose:** Recommendations for Solution Architect HLD consolidation  
**Assessment:** Data architecture direction accepted; identified refinements below

### 1. Assessment

The proposed **Bronze → Silver → Gold → Retrieval → Azure AI Search** architecture is suitable for the MVP. The agreed outcome is **retrieval of existing knowledge and source evidence**, not AI-generated answers. Gold must preserve reusable knowledge independently of search-index design. No additional knowledge-storage technology is warranted at this stage.

### 2. Agreed data architecture decisions

| ID | Decision | Rationale / design rule |
|---|---|---|
| DA-01 | **Hybrid knowledge model** | Represent SQL objects, GitHub files and SharePoint documents as **independent assets** with content and typed relationships. |
| DA-02 | **Stable identity and provenance** | Maintain canonical asset IDs, native source identifiers, source paths and capture/version references. Do not equate similarly named artifacts. |
| DA-03 | **Hybrid relationship discovery** | Capture explicit dependencies/references and evidence-supported inferred links. Record origin and verification state; never present inference as verified fact. |
| DA-04 | **Preserve full normalized content in Gold** | Retain complete in-scope SQL definitions, code and extractable document text/structure, alongside source evidence; original files remain in Bronze. |
| DA-05 | **Source-specific authority and conflicts** | Preserve differing source accounts and flag discrepancies. SQL Server describes **deployed behavior**; GitHub `main` describes its repository baseline; SharePoint provides documented business context. Authority does not prove correctness or deployment intent. |
| DA-06 | **Bounded history and change traceability** | Preserve source versions and meaningful knowledge versions. Support investigation of structural changes (e.g., column size changes) and available commit/deployment/author evidence, without asserting responsibility absent proof. Retention is configurable under approved policy. |
| DA-07 | **Quality and publication rules** | Require identity, provenance and effective security attributes. Flag incomplete, stale, conflicting and inferred knowledge; block publication for critical validation or security failures. |
| DA-08 | **Content classification** | Record content type and one or more intended audiences (e.g., Engineering, Support, Sales Analysts). Audience supports relevance, **not authorization**. |
| DA-09 | **Project-owned runtime configuration** | Administrators can update knowledge-policy parameters without redeployment. Use project-owned relational configuration tables; **Fabric Warehouse is the preferred candidate**, subject to technical validation. Keep them separate from shared Azure SQL `DataOps_Control`. |

### 3. Proposed minimal Gold logical model

| Concept | Purpose |
|---|---|
| **KnowledgeAsset** | Stable identity, asset type, source identity and classification |
| **AssetVersion** | Observed source revision, knowledge version, timestamps and lifecycle status |
| **KnowledgeContent** | Complete normalized content, structure and source-content reference |
| **KnowledgeRelationship** | Typed links between assets, explicit or inferred |
| **KnowledgeEvidence** | Source references supporting content, relationships and available change attribution |

These are **logical concepts**, not a mandate for five physical tables. Cross-source relationships may be absent when the evidence is insufficient. Business concepts need independent identities only when justified by source content and retrieval use cases.

### 4. Data rules and boundaries

- **Bronze:** Preserve permitted source files/metadata and historical captures under retention controls; avoid treating every unchanged ingestion as a new content version.
- **Silver:** Extract and normalize SQL metadata, GitHub code/docs and Office document content, preserving source-local context and extraction-quality indicators.
- **Gold:** Maintain current and selected historical assets, complete normalized content, relationships, evidence, quality, provenance and classification.
- **Retrieval contract:** Supply stable asset/version IDs, searchable text or references, content type, audience, source/evidence links, relationships, authorization attributes, lifecycle state, quality signals and timestamps. Chunking, embeddings and ranking remain with AI/Search.
- **History in search:** Current content is the default. Index selected history only where the existing retrieval design supports it without material MVP complexity; preserve the underlying history in governed storage regardless.
- **Change attribution:** Comments, Git commits and deployment documents are evidence of potential authorship or approval, not definitive proof of who deployed a change.
- **Configuration:** Capture parameter scope, valid values, effective dates and change audit. Changes to retention policy must not initiate uncontrolled deletion.

### 5. Data architecture risks and mitigation

| Risk | Recommended mitigation |
|---|---|
| Same name across databases/repositories or renamed objects | Use source-qualified identities and explicit continuity rules. |
| GitHub `main` differs from deployed SQL Server definition | Preserve both states; flag evidence-backed discrepancies rather than silently selecting a winner. |
| Missing or ambiguous cross-source links | Preserve evidence and verification status; do not invent links. |
| Source changes are observed after deployment | Distinguish **observed-at** from actual change/deployment time when known. |
| Historical copies or derived retrieval content outlive policy | Apply retention/lifecycle states and propagate removals to downstream assets. |
| Incomplete document extraction | Record extraction completeness and preserve source references; never silently claim full extraction when unsupported. |

### 6. Items owned outside Data Architecture

| Item for validation / approval | Owner |
|---|---|
| Retention periods, deletion obligations and effective access policy | Business / Security & Governance |
| Fabric Warehouse suitability for administrative SQL updates, access and audit enforcement | Solution Architect / Senior Data Engineer |
| Feasibility of source metadata, change detection, file extraction and actual identifiers | Senior Data Engineer / source owners |
| Historical index exposure, role-aware ranking and search quality | AI/Search Engineer |

### 7. Recommendation to the Solution Architect

**Retain the HLD architecture** and incorporate DA-01 through DA-09 as the Data Architect's agreed design directions. Specify the minimal Gold logical model, source authority distinctions, evidence-backed relationships, bounded history, and the Gold-to-Retrieval contract. Use project-owned administrator-managed configuration; validate Fabric Warehouse as its physical home. No new application, graph database or dedicated history subsystem is required for this MVP.

**Conclusion:** Ready for HLD consolidation. Remaining items are implementation feasibility or cross-workstream policy approvals, not further Data Architect stakeholder questions.
