# Fabric Enterprise Knowledge Platform
## AI / Search Engineering — Architecture Review (Revised)

**Basis:** Business Requirements Baseline v0.5; HLD v1.0 Draft  
**Date:** 2026-11-13  
**Assessment:** Recommend conditional acceptance of the AI/Search design.

### 1. MVP decision

**Accepted by the stakeholder: document and knowledge retrieval only.** Users can ask questions in natural language and receive relevant indexed content, excerpts, metadata, and source references. **Limitation accepted:** the service will not generate new explanations, summarize code on demand, or synthesize answers across documents. It will return existing indexed information or clearly indicate when relevant evidence is unavailable.

The current **Gold → Retrieval → Azure AI Search** design remains appropriate. Preserve reusable text chunks, source evidence, and authorization metadata so a future RAG service can consume retrieved content **without creating a new ingestion flow from Bronze or Silver**. Future RAG may require adjustments to Retrieval/indexing, but not a second upstream pipeline unless essential content was never captured in Gold.

### 2. Technical decisions and recommendations

| Topic | Evaluation and recommendation | Status |
|---|---|---|
| Retrieval service | **Azure AI Search** fits the agreed MVP target and supports exact-term and natural-language discovery. | Accept |
| Query strategy | Use **keyword search as the baseline** for SQL identifiers; compare **hybrid (keyword + vector)** for natural-language phrasing. Do not use vector-only search as the default. | Recommend; test |
| Semantic ranking | Optional reranking if measurable relevance gains justify cost and latency. | Test |
| Chunking | **Structure-aware**: SQL objects/code blocks, Markdown sections, Word headings, Excel tables, PowerPoint slides. Preserve object/section context and parent IDs. | Recommend |
| Embeddings | Generate from prepared text; persist with model/version/dimensions and content fingerprint for reuse and regeneration. Exact model selection follows testing. | Recommend |
| Index design | Start with **one logical chunk index** containing text, vectors, identifiers, source references, relationships, version/current state, quality and permission-filter fields. | Recommend |
| Publication | **Push** prepared chunks; use stable IDs, idempotent retries, per-item outcomes, delete handling, reconciliation and rebuild. | Recommend; test |
| Role-based access | Enforce effective user permissions **before returning results** (e.g., Entra ID group-based access filters). Never expose unauthorized chunks, snippets or metadata; urgent revocation must not rely solely on delayed index updates. | Required behavior; test |
| Role-aware relevance | Rank technical objects higher for developers and business documentation higher for business users, **after authorization filtering**. Do not hide otherwise authorized results solely because of audience. Use content type/audience metadata and query-side ranking rules. | Recommend; test |
| Missing knowledge | If no relevant authorized evidence is found, return a clear no-result/insufficient-evidence response. Do not fabricate explanations or treat low-relevance results as facts. | Accept |
| Lifecycle | Update changed chunks, remove superseded/deleted content from current results, and filter historical content explicitly. | Recommend |
| RAG readiness | Retain full retrievable text and evidence in Gold/Retrieval. Do not implement answer generation in this MVP. | Accept |

### 3. Retrieval validation

Use representative questions from **IT Support, Data Engineering, and Sales Analysts**, including exact stored procedure names, paraphrased business questions, document lookup, SQL dependencies, denied-access queries, missing-information cases, and changes/deletions. Test the **same query under different authorized roles** to verify audience-aware ranking without suppressing permitted content. Dependencies must come from indexed, governed relationship evidence; search results alone do not guarantee an exhaustive dependency list.

| Measure | Proposed starting criterion* |
|---|---|
| Exact-identifier relevance | Recall@5 ≥ 95% |
| Natural-language relevance | Recall@5 ≥ 85% |
| Ranking | MRR@10 ≥ 0.80 |
| Source references | 100% valid for returned results |
| Unauthorized or deleted content in current results | Zero |
| Role-aware result ordering | Relevant authorized content appropriately prioritized for each test role |
| Missing-evidence behavior | No fabricated answer; clear no-result indication |
| Source change → searchable | Target ≤ 60 minutes, with monitored exceptions |

*These are initial engineering targets, not approved acceptance thresholds. Finalize after testing a labeled sample.*

### 4. Only validations still necessary

1. **Representative content:** Inspect actual SQL/code and Office document samples to set chunk boundaries and choose an embedding model.
2. **Measured search quality:** Compare keyword, hybrid and optional semantic ranking on the same labeled queries; establish final thresholds.
3. **Index operations and security:** Test partial failures, deletes, permission changes, revocations, rebuilds and end-to-end freshness; verify both access filters and role-aware ranking.
4. **Expected volume and usage:** Confirm approximate chunk counts, change rate and query load to size the index and assess cost.

### 5. Recommendation to the Solution Architect

**Retain the HLD's Gold → Retrieval → push publication → Azure AI Search flow.** Record **natural-language document retrieval, not AI-generated answers**, as the stakeholder-approved MVP outcome, including permission filtering, role-aware ranking, and explicit missing-evidence behavior. Keep persisted, traceable chunks and embeddings so future RAG can be added downstream of Azure AI Search without reprocessing Bronze or Silver. Approve the AI/Search design conditionally, subject to relevance, access-control, and index-lifecycle validation.
