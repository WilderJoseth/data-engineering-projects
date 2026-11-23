# ACT-04 — Azure AI Search and Embedding Architecture

**Project:** Fabric Enterprise Knowledge Platform  
**References:** HLD v1.1 (approved); ACT-02 (accepted); ACT-03 (accepted)  
**Status:** Accepted — specialist review complete; implementation validations outstanding  
**Scope:** MVP architecture and resource selection; no provisioning

## 1. Purpose and boundaries

Define a low-cost search and embedding design for the Fabric knowledge platform. **Fabric Gold and Retrieval remain authoritative for governed knowledge and persisted embeddings**; Azure AI Search contains a derived, rebuildable index.

The MVP retrieves **existing documents, excerpts, metadata, and source evidence** through controlled tests. It does **not** include generated answers, a chatbot, or an employee-facing search application.

The logical design assumes separate DEV/PROD resources. The portfolio initially uses **one Azure subscription, Fabric trial capacity, and DEV-oriented search resources**. This is not evidence of production isolation.

## 2. Proposed resources and decisions

| ID | Component / decision | Proposed baseline | Validation required |
|---|---|---|---|
| SEARCH-01 | Azure AI Search tier | **Free for DEV evaluation**, only if current limits and required features permit meaningful MVP tests; otherwise select the lowest suitable paid tier | Validate current limits, indexing/vector features, security approach, index size, request volume, and costs |
| SEARCH-02 | Embedding provider | **Azure OpenAI `text-embedding-3-small`** preferred, subject to availability and budget; open-source notebook-hosted model is a fallback | Verify regional deployment/access, dimensions, quotas, model versioning, throughput, and costs |
| SEARCH-03 | Index organization | **One logical chunk index** spanning approved sources | Confirm field/filter design, size, and permission-safe retrieval |
| SEARCH-04 | Retrieval modes | **Keyword and vector search (hybrid)**; no dependency on paid semantic reranking | Validate exact identifier and natural-language retrieval on representative queries |
| SEARCH-05 | Publication | **Fabric-controlled push indexing** using prepared Retrieval assets | Verify upsert/delete, retries, partial failures, reconciliation, rebuild, and 60-minute freshness measurement |
| SEARCH-06 | Authorization | **Trusted retrieval/authorization boundary** using current Entra ID–linked effective permissions, independent of index refresh | Demonstrate section-level restrictions, next-request revocation, no leakage, and fail-closed behavior |

The Free tier and embedding provider are **provisional selections**, not confirmed deployments or guarantees of feature support.

## 3. Data flow and contracts

`Fabric Gold → Retrieval Lakehouse (chunks + persisted embeddings) → publication pipeline/notebook → Azure AI Search → trusted authorization boundary → controlled retrieval tests`

**Retrieval → index payload** includes:
- Stable chunk ID; parent asset/version and section IDs; text and vector.
- Embedding model ID/version and dimensions; source provenance and evidence references.
- Lifecycle/current status, quality/freshness indicators, and security-policy references.
- Index filter fields appropriate to approved source and audience restrictions.

**Chunk boundary rule:** Never combine text from sections with incompatible effective permissions. Retain source evidence and enough identifiers to revalidate permissions.

**Index lifecycle:** Publish idempotent upserts and removals; capture per-item outcomes; retry failures; reconcile index state against retained Fabric Retrieval assets; rebuild without re-ingesting original sources when retained assets are sufficient. Current versions appear by default; governed historical search behavior requires separate validation.

## 4. Retrieval security boundary

Azure AI Search is **not** the final authorization authority merely because the index contains security fields.

A trusted retrieval component must:
1. Authenticate the requester and resolve **current** role, department, sensitivity, and approved section-level permissions from a trusted authority on each request.
2. Constrain retrieval to permitted sections and ensure responses, snippets, metadata, counts, and source links do not disclose restricted knowledge.
3. Deny access when identity, permissions, policy freshness, or enforcement cannot be established (**fail closed**).
4. Enforce revocations on the **next request**, independent of the normal indexing freshness window.
5. Audit relevant access decisions and failures without exposing sensitive content.

**Implementation approach is intentionally open:** The AI/Search and Security/Governance specialists must validate a concrete, feasible combination of trusted query filtering and result authorization that prevents leaks. This ACT does not assume a particular Azure AI Search native permission feature solves dynamic authorization.

## 5. Cost, environment, and dependencies

- **Cost-first DEV:** Evaluate Free tier first; estimate storage for text, vector dimensions, document count, and index overhead. Upgrade only when justified by a required MVP test.
- **Embeddings:** Account for Azure OpenAI usage charges and deployment availability; assess Fabric compute use if adopting a local model. Cache/persist vectors, and regenerate only when text or model policy changes.
- **Environments:** Logical DEV and PROD use independent index/service configurations, identities, and secrets. One portfolio subscription/service may be shared **for DEV testing only**; do not claim independently isolated production.
- **Other dependencies:** Entra ID, secret management, Fabric trial continuity, Search provision/access, embedding service deployment, and source permissions. SharePoint remains unavailable, limiting full four-source MVP validation.
- **Operational control:** `DataOps_Control` may track supported execution states, but support for Search publication, backlog and reconciliation must be confirmed rather than assumed.
- **Freshness:** Measure detected source change to **successful searchability** (target ≤60 minutes, monitored exceptions), not simply pipeline completion.

## 6. MVP validation gates

| Validation | Expected architectural evidence |
|---|---|
| Tier/model feasibility | Chosen tier and model are available and fit measured DEV scale and required capabilities |
| Exact and natural-language search | Relevant existing chunks and source evidence are returned; no generated answers |
| Security | Allowed/restricted sections, immediate revocation, fail-closed behavior, and no metadata/snippet leakage tested |
| Index lifecycle | Update, deletion, partial failure, idempotent retry, reconciliation, and rebuild demonstrated |
| Freshness | Searchability measured against the 60-minute target with exceptions recorded |
| Source coverage | SQL/GitHub vertical slice first; SharePoint source demonstrated before claiming full MVP coverage |

**No PROD deployment approval or claim of validated security follows from approval of this design.**

## 7. Specialist review and decision status

| Specialist | Required review | Verdict |
|---|---|---|
| AI/Search Engineer | Tier feasibility, embedding choice, unified hybrid index, push lifecycle and recovery | Accept (reported) |
| Security/Governance Specialist | Trusted retrieval boundary, dynamic section authorization, fail-closed behavior, DEV/PROD limitations | Accept (reported) |

**Solution Architect final verdict: ACCEPT.** Both specialists accepted the proposed ACT-04 design, as reported by the project owner. No architectural revisions were requested or made. The decisions in this report are the approved design baseline, while the tier, model availability, cost, authorization enforcement, and indexing behavior remain subject to the explicitly listed feasibility and implementation validations. Approval does **not** authorize PROD deployment or establish that security controls have been tested.

**GitHub closure readiness:** Once this accepted document is committed and the associated Pull Request is merged, ACT-04 may be moved to Done and the issue closed. Track outstanding implementation dependencies in subsequent work rather than keeping this design issue open.
