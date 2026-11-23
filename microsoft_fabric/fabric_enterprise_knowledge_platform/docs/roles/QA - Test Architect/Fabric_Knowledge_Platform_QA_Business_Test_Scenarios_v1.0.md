# Fabric Enterprise Knowledge Platform
## QA Business Test Scenario Report — v1.0

**Status:** Stakeholder-reviewed scenario baseline — for Solution Architect scope and coverage assessment  
**Basis:** Business Requirements Baseline v0.5; HLD v1.0; Data Architect, Senior Data Engineer, Security/Governance and AI/Search reviews; stakeholder decisions for S01–S24.  
**Purpose:** Define expected MVP business behavior and acceptance outcomes. This report does not certify architectural support or prescribe implementation.

**MVP boundary:** Centralized knowledge from two SQL Server databases (`Sales_Operational`, `Sales_Analytics`), one GitHub Sales Domain Migration repository and SharePoint Sales Knowledge Portal. Fabric Bronze → Silver → Gold → Retrieval → Azure AI Search. Retrieve existing indexed knowledge and source evidence; no generated answers, agent or employee-facing UI. Azure SQL `DataOps_Control` is operational infrastructure, not a knowledge source.

**Priority:** P0 = critical MVP validation; P1 = important MVP completeness.  
**Acceptance method:** Each scenario passes when its expected outcome is demonstrated with representative source content, users or controlled failures. Technical test scripts and quantitative retrieval benchmarks are separate deliverables.

## A. Ingestion and processing

| ID | Priority | Scenario / goal | Expected behavior and acceptance criteria | Requirements |
|---|---|---|---|---|
| **S01** | P0 | **Initial Full Load** — establish usable initial knowledge. | All four sources are accounted for and permitted knowledge reaches Search. Originals are preserved. Source-owner-designated critical file failures block publication of the initial load; noncritical file failures allow approved content to publish with **Completed with Warnings**. Files default to noncritical until designated otherwise. An unavailable entire source does **not** prevent independent sources publishing; overall initial load stays **Incomplete**. Warnings show a count with item-level details separately; administrators decide file retries. | FR-01, FR-03, DQ-01, FR-07 |
| **S02** | P0 | **Source Failure Isolation** — protect unaffected sources. | Independent source processing continues after one source fails; only dependent work is blocked. Previously valid indexed knowledge remains available with a freshness warning. Administrator decides when the source resumes or reruns. | FR-04, FR-07, LC-01 |
| **S03** | P0 | **Processing Layer Failure** — recover without unnecessary work. | Resume from failed Bronze/Silver/Gold/Retrieval stage using reusable successful outputs; unaffected items continue. Valid older knowledge stays searchable with an affected-content freshness warning. Metadata control framework determines/manages eligible reruns. | FR-04, FR-07 |
| **S04** | P0 | **Partial Object Failure** — isolate bad objects. | Continue independent objects; block only affected dependents. Rerun failed and affected dependent objects, not entire unaffected sets. Retain previously valid knowledge; withhold incomplete new dependent knowledge. Noncritical failures produce **Completed with Warnings** and details. | FR-04, DQ-01, FR-07 |
| **S05** | P0 | **Incremental Source Changes** — keep knowledge up to date. | Changed assets and affected dependents are updated without unnecessary full processing. Previous valid content stays available during updates with a freshness indicator. Unsynchronized SQL/GitHub states remain distinct and discrepancies are flagged. Aim for source-change-to-search within **60 minutes**, recording exceptions. | FR-04, FR-05, LC-01 |
| **S06** | P0 | **Source Inventory Reconciliation** — detect missing coverage. | Compare expected inventory with captured and processed items. Record missing objects without stopping independent work; evaluate their criticality using source-owner rules. Control framework identifies eligible recovery; authorized administrator initiates or approves it. | FR-01, FR-04, FR-07 |
| **S07** | P0 | **Content Extraction** — preserve usable knowledge. | Preserve original files, all supported extractable text, tables and metadata. Unsupported embedded files/images may remain unextracted; record limitations. Authorized, noncritical partial content may publish with quality indicators. Preserve/register files with no extractable text and indicate unavailability of searchable content. | FR-01, FR-02, DQ-01 |

## B. Knowledge integrity and lifecycle

| ID | Priority | Scenario / goal | Expected behavior and acceptance criteria | Requirements |
|---|---|---|---|---|
| **S08** | P0 | **Knowledge Identity and Relationships** — ensure traceability. | Same-named assets in different sources stay distinct. Record supported dependencies with evidence; mark evidence-backed uncertain links as inferred/unverified. Preserve meaningful prior versions and change evidence subject to retention. | FR-02, FR-05, LC-02 |
| **S09** | P0 | **Conflicting Knowledge** — avoid false authority. | Preserve SQL deployed and GitHub repository definitions separately. Flag detected discrepancies with both references; do not silently reconcile. Source owners resolve authoritative content issues; platform teams resolve processing issues. Authorized conflicting content stays searchable with uncertainty indication. | FR-02, FR-05, FR-06, GOV-01 |
| **S10** | P0 | **Knowledge Quality Validation** — prevent misleading publication. | Critical validation failures block affected knowledge and dependents. Noncritical incomplete content may publish with quality indicators. Unverified claims/links are not presented as confirmed. Reassess previously published knowledge: restrict critically invalid content and flag noncritical problems. | FR-05, DQ-01, DQ-02 |
| **S11** | P0 | **Source Renames and Deletions** — maintain correct current state. | Confirmed renames retain identity/history. Deleted assets disappear from normal current retrieval; preserve permitted history. Same-name recreations receive new identities unless continuity is shown. Mandatory sensitive-content deletion removes affected copies and derivatives under approved policy, overriding retention. | FR-04, LC-02, LC-03, SEC-01 |
| **S12** | P1 | **Knowledge History** — enable authorized investigation. | Retain meaningful history under agreed rules. Current knowledge is the default; historical access requires explicit authorization and search/investigation. Include source, version, timestamps and available evidence. Source owners/Governance own rules; authorized administrators maintain configuration. | LC-02, SEC-01, GOV-01 |
| **S13** | P1 | **Knowledge Issue Management** — ensure accountable resolution. | Record extraction failures, missing/stale knowledge, inconsistencies and validation problems. Assign source-content issues to source owners, processing/indexing issues to platform teams. Close only after verification in platform and relevant results. Track status, ownership and available notifications centrally. | FR-06, FR-07, GOV-01 |

## C. Security and authorization

| ID | Priority | Scenario / goal | Expected behavior and acceptance criteria | Requirements |
|---|---|---|---|---|
| **S14** | P0 | **Role-Based Retrieval** — limit knowledge to authorized users. | Apply effective role, department, sensitivity and approved source constraints. Eligible technical/business knowledge remains discoverable if authorized. Never disclose denied content, snippets, metadata or source references. Retrieval requires no end-user access to original systems. | SEC-01, GOV-02, FR-03 |
| **S15** | P0 | **Section-Level Authorization** — share approved excerpts safely. | Developer can retrieve source-owner-approved formula/section from restricted document without seeing protected neighboring content. Mixed-permission chunks cannot disclose prohibited content. Approved section policies are governed, administrator-managed, approved and audited. | SEC-01, GOV-01 |
| **S16** | P0 | **Dynamic Permission Changes** — enforce current access immediately. | Grants and revocations affect the **next retrieval request**, independent of content refresh and stale index permissions. Policy updates are validated, versioned and audited; broader restricted access needs owner approval. | SEC-01 |
| **S17** | P0 | **Security Failure and Denial** — fail closed. | Deny content when authorization is unknown, contradictory or unavailable. Immediately restrict accidentally exposed content and record/correct incident. Audit affected assets, context, team and actions without leaking protected details. | SEC-01, FR-07 |
| **S18** | P0 | **Environment and Privileged Access** — secure operations. | Development uses masked/synthetic sensitive data. Production IT Support access is previously authorized, scoped and audited; support privileges do not bypass content permissions. Protect intermediate artifacts, notebooks and logs. | SEC-01 |

## D. Search and retrieval

| ID | Priority | Scenario / goal | Expected behavior and acceptance criteria | Requirements |
|---|---|---|---|---|
| **S19** | P0 | **Knowledge Retrieval** — find documented evidence. | Exact technical identifiers return authorized definitions and references. Paraphrased business queries return relevant authorized documents/excerpts. Multiple matching sources may be returned, without synthesizing an answer. If evidence is missing, clearly report no relevant result. | FR-02, FR-03 |
| **S20** | P1 | **Role-Aware Relevance** — prioritize without excluding. | Query relevance comes first; authorized technical knowledge can rank higher for developers and business content for Sales Analysts. Other authorized content stays discoverable. Same query may rank differently by audience. | FR-03, SEC-01 |
| **S21** | P0 | **Search Index Synchronization** — reflect approved knowledge changes. | Search updates aim for ≤60 minutes with exceptions recorded. Current search replaces superseded versions while retaining authorized history. Publish successful items despite unrelated publication failures; preserve valid existing results where permitted. Enforce deletion/revocation restrictions without routine-refresh delay. | FR-03, FR-04, LC-01, LC-02, LC-03, SEC-01 |
| **S22** | P0 | **Search Index Recovery** — restore trustworthy retrieval. | Fabric knowledge processing continues during Search outage, preserving publication backlog. Operational controls identify pending/failed items for authorized recovery. Rebuild a lost/corrupted index from retained knowledge without unnecessary source re-ingestion. Accept restoration only after validating completeness, current state, permissions and retrieval. | FR-03, FR-07, SEC-01 |

## E. Operations and monitoring

| ID | Priority | Scenario / goal | Expected behavior and acceptance criteria | Requirements |
|---|---|---|---|---|
| **S23** | P0 | **Execution Monitoring and Recovery** — operate recoverably. | Authorized operators can inspect run/stage/item states, errors, warnings and timestamps. Record failures and send configurable notifications. Metadata control determines rerun eligibility, scope and dependencies; authorized operators initiate/approve recovery. | FR-07, FR-04 |
| **S24** | P0 | **Freshness and Configuration** — manage service expectations. | Monitor configurable 60-minute change-to-search target and report exceptions operationally. **For routine freshness delays, the stakeholder elected no user-facing freshness warning**; keep showing last available knowledge. Authorized administrators adjust refresh/freshness parameters without redeployment; validate/audit changes and apply them to subsequent work. | LC-01, FR-07 |

## Cross-scenario rules and handoff to Solution Architect

1. **Freshness presentation:** S02/S03/S05 explicitly call for freshness indicators in failures/updates; S24 calls for no user-facing warning on routine delays. Apply this distinction as specified; Solution Architect to align UI/test-client or metadata representation with the business baseline's synchronization-warning expectation.
2. **Initial load severity:** S01 distinguishes *critical file failure* (blocks initial publication) from *entire source unavailable* (other sources may publish; overall status **Incomplete**). The Solution Architect should reconcile publication boundaries with the requirement for all four sources at initial MVP acceptance.
3. **History:** S12 expects explicit authorized history access; the Data Architect report allows limiting historical search indexing if materially complex. The Solution Architect should determine the MVP coverage path without dropping the history-retention obligation.
4. **Control framework:** S03/S06/S22/S23 require metadata-driven recovery decisions; engineering reports confirm existing `DataOps_Control` coverage for dataflow/item tracking but do **not** prove non-dataflow Search publication control. The Solution Architect owns integration boundary decisions.
5. **Security:** S15–S17 require independently governed section permissions and *request-time* authorization, not merely index-time classification. Enforcement mechanism is a technical design matter; expected outcomes remain mandatory.
6. **Deletion timing:** S11/S21 require prompt restrictions for sensitive deletions/revocations, while routine change freshness is a 60-minute target. Solution Architect/Security define the operational trigger and policy service-level expectation.

## Sign-off and usage

**Stakeholder decisions:** S01–S24 reviewed and reflected above.  
**Architecture status:** Not assessed or certified by QA. Submit this report to the Solution Architect to evaluate scope/coverage and route unresolved design choices to technical specialists.  
**Next QA phase:** After architecture alignment, develop representative test data, execution steps, objective pass/fail evidence, and approved numerical retrieval-quality benchmarks. No detailed test scripts are included in this report.
