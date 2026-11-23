# Fabric Enterprise Knowledge Platform
## Security & Governance — Architecture Review Report (Updated)

**Basis:** Business Requirements Baseline v0.5; HLD v1.0; updated Data Architect, Senior Data Engineer, and AI/Search reviews; stakeholder decisions  
**Purpose:** Input for Solution Architect HLD consolidation  
**Assessment:** **Accept the architecture direction**, subject to validation of security-policy enforcement across the retrieval boundary.

### 1. Assessment

The centralized **SQL Server / GitHub / SharePoint → Fabric Bronze → Silver → Gold → Retrieval → Azure AI Search** design is suitable for the MVP. Sources remain authoritative; the MVP retrieves existing knowledge and evidence, **not AI-generated answers**. Security must govern originals, extracted content, knowledge assets, chunks, embeddings, search results, and historical copies. Copying content does not copy its source permissions automatically.

**Key refinement:** A restricted source document can contain sections approved for broader access (for example, formulas used by developers). The platform must protect the original while authorizing independently classified sections under approved policies.

### 2. Security and governance decisions

| ID | Decision / required behavior |
|---|---|
| **SG-01** | **Centralized, effective authorization:** Evaluate role, department, content sensitivity, and applicable source restrictions. Broader section access is permitted only under an explicitly approved policy; otherwise deny conflicting or unknown permissions. |
| **SG-02** | **Section-level governance:** Classify and authorize meaningful sections/knowledge items independently of the parent document when approved. Search chunks must not combine content with incompatible effective permissions in a way that leaks restricted material. |
| **SG-03** | **Owner-approved, configuration-driven policy:** Source owners participate in the initial assessment of shareable sections and access categories. Store approved classification/access rules in governed, administrator-editable configuration; avoid case-by-case creation of new source documents. |
| **SG-04** | **Dynamic enforcement:** Evaluate the currently effective authorization policy on each retrieval request. Policy changes and revocations must affect subsequent requests without waiting for the 60-minute content refresh or reprocessing unchanged documents. |
| **SG-05** | **Fail closed:** Uncertain classifications, conflicting/absent effective permissions, or unavailable authorization policy prevent disclosure until resolved. Restrict affected content immediately when a classification error is detected; log and correct the incident. |
| **SG-06** | **Classification and propagation:** Use an approved sensitivity scheme and preserve content classification, source evidence, policy references, and effective authorization attributes from governed knowledge into Retrieval/Search. Intended audience may guide ranking but **does not grant access**. |
| **SG-07** | **Lifecycle and history:** Apply configurable, approved retention by content type and sensitivity. Remove deleted/retired content from current retrieval; preserve history only where permitted and authorized. Mandatory deletion overrides historical retention. |
| **SG-08** | **Privileged access:** Developers use separate environments with masked/synthetic sensitive content. IT Support may troubleshoot production under prior, dynamic authorization; operational privileges do not automatically grant access to restricted content. Protect notebooks, intermediate files, and logs. |
| **SG-09** | **Policy administration:** Only designated administrators change security configuration. Changes broadening access to restricted content require source-owner approval. Validate, audit, and version policy changes, with a controlled rollback capability. |
| **SG-10** | **Audit and protection:** Audit policy changes, access denials, privileged operations, retrieval activity, revocations, and security failures. Apply least privilege, encryption in transit/at rest, approved credential handling, and avoid sensitive details in logs. |

### 3. Ownership and enforcement boundaries

- **Source/data owners:** Approve classification, sharing exceptions, access entitlements, and retention requirements; remain accountable for authoritative content.
- **Security/Governance:** Own effective-access standards, section-classification policy, privileged-access rules, security audit requirements, and policy compliance.
- **Engineering teams:** Implement and demonstrate controls throughout ingestion, storage, transformation, indexing, and retrieval.

**Publication rule:** Publish a knowledge item only when identity, provenance, classification, and applicable authorization are valid. Incomplete but non-sensitive extraction may be published with explicit quality indicators; unresolved security uncertainty blocks disclosure.

### 4. Security acceptance criteria

1. **No unauthorized exposure** of sections, snippets, metadata, source references, historical versions, or indexed chunks in role-based retrieval tests.
2. **Section-level access works:** a developer can retrieve an approved formula from a restricted business document, without retrieving confidential neighboring content.
3. **Policy updates take effect on subsequent retrieval requests**, including revocation, without waiting for re-ingestion; policy unavailability denies retrieval.
4. **Lifecycle is enforced:** deleted/retired content disappears from current search, and retained history follows approved permissions and retention.
5. **Operational controls are demonstrable:** developer masking, authorized production support, privileged-access audit, and administrator policy-change history.

### 5. Cross-workstream items for HLD consolidation

| Owner | Required validation / decision |
|---|---|
| **Data Architect** | Model independent section identities, classification/policy references, inheritance, versioning, and source provenance. |
| **Senior Data Engineer** | Confirm reliable section extraction/classification inputs, propagation, protected source copies, deletion signals, and policy configuration/auditing. |
| **AI/Search Engineer** | Prove request-time effective authorization, safe chunk boundaries, denied-result filtering, revocation, and index update/rebuild behavior. |
| **Platform Engineering** | Validate identity, privileged access, encryption, credential controls, and environment boundaries. |
| **Solution Architect** | Resolve cross-component enforcement boundaries and update the HLD/ADRs. |
| **Authorized business/source owners** | Approve the classification vocabulary, section-sharing policies, concrete retention periods, and administrative approval authority. |

### 6. Recommendation

**Retain the HLD architecture** and incorporate SG-01 through SG-10 as the stakeholder-supported Security/Governance baseline. The principal architectural requirement is **centrally governed, dynamically enforced section-level access**, including approved exceptions to parent-document restrictions. No additional security product or employee-facing application is required for the MVP. Technical specialists should validate the enforcement mechanism and record evidence against the acceptance criteria before production approval.
