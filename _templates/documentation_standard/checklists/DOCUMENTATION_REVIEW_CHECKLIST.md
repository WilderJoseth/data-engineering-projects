# Documentation Review Checklist

<!-- Complete before publishing. Use Yes, No, or Not Applicable. Every No and Not Applicable response requires a note. -->

## Template Selection and Completeness

| Check | Yes / No / Not Applicable | Notes |
|---|---|---|
| The project README exists and states purpose, scope, exclusions, dependencies, documentation links, and status | {{RESPONSE}} | {{NOTES}} |
| Applicable templates were selected using the documentation guide | {{RESPONSE}} | {{NOTES}} |
| Every omitted document is listed as `Not Applicable` in the project README with a brief reason; no empty document file is required | {{RESPONSE}} | {{NOTES}} |
| Required sections contain project-specific content | {{RESPONSE}} | {{NOTES}} |
| Assumptions, constraints, and open limitations are explicit | {{RESPONSE}} | {{NOTES}} |

## Template Cleanup and Markdown

| Check | Yes / No / Not Applicable | Notes |
|---|---|---|
| No unresolved `{{PLACEHOLDER}}` values remain | {{RESPONSE}} | {{NOTES}} |
| Author-only HTML comments were removed from final project documentation; reusable files under `documentation_standard/templates/` retain their comments | {{RESPONSE}} | {{NOTES}} |
| Optional and repeatable blocks were resolved correctly | {{RESPONSE}} | {{NOTES}} |
| Tables render correctly and remain readable | {{RESPONSE}} | {{NOTES}} |
| Links point to existing or clearly identified planned artifacts | {{RESPONSE}} | {{NOTES}} |
| Diagrams render and match the documented architecture | {{RESPONSE}} | {{NOTES}} |

## Ownership and Consistency

| Check | Yes / No / Not Applicable | Notes |
|---|---|---|
| Source details are authoritative in the Source Data Profile | {{RESPONSE}} | {{NOTES}} |
| Target definitions are authoritative in the Target Data Architecture | {{RESPONSE}} | {{NOTES}} |
| Routes are owned by Data Flow and state changes are owned by Load Strategy | {{RESPONSE}} | {{NOTES}} |
| Validation and acceptance rules are owned by the Validation Strategy | {{RESPONSE}} | {{NOTES}} |
| Deployment mechanics and security controls are not duplicated | {{RESPONSE}} | {{NOTES}} |
| Repeated information is limited to stable IDs or short context | {{RESPONSE}} | {{NOTES}} |
| Names, IDs, terminology, maturity, and status agree across documents | {{RESPONSE}} | {{NOTES}} |

## Design Quality and Neutrality

| Check | Yes / No / Not Applicable | Notes |
|---|---|---|
| Material architecture, flow, load, validation, deployment, and security choices include brief rationale | {{RESPONSE}} | {{NOTES}} |
| Alternatives or tradeoffs are recorded where they affect the design | {{RESPONSE}} | {{NOTES}} |
| Platform or product terminology reflects an explicit project choice | {{RESPONSE}} | {{NOTES}} |
| The documentation does not imply a migration, reporting, or layered architecture unless selected by the project | {{RESPONSE}} | {{NOTES}} |
| Workload-specific concerns are covered for batch, micro-batch, streaming, API, file, or hybrid processing as applicable | {{RESPONSE}} | {{NOTES}} |
| Hosting-specific concerns are covered for cloud, on-premises, or hybrid deployment as applicable | {{RESPONSE}} | {{NOTES}} |

## Maturity, Validation, and Security

| Check | Yes / No / Not Applicable | Notes |
|---|---|---|
| Every maturity status uses `Planned`, `In Progress`, `Implemented`, `Validated`, or `Production-Ready` | {{RESPONSE}} | {{NOTES}} |
| Design documentation is not presented as implemented work | {{RESPONSE}} | {{NOTES}} |
| `Implemented`, `Validated`, and `Production-Ready` claims have appropriate evidence | {{RESPONSE}} | {{NOTES}} |
| Validation rules define severity, threshold, timing, traceability, and failure action | {{RESPONSE}} | {{NOTES}} |
| Reconciliation is defined or marked `Not Applicable` with justification | {{RESPONSE}} | {{NOTES}} |
| Acceptance and exception ownership are clear | {{RESPONSE}} | {{NOTES}} |
| Authentication, authorization, secrets, sensitive data, and access boundaries are addressed | {{RESPONSE}} | {{NOTES}} |
| No credentials, tokens, secret values, or unnecessary sensitive data appear in documentation | {{RESPONSE}} | {{NOTES}} |

## Final Decision

| Decision | Yes / No | Notes |
|---|---|---|
| Documentation is ready to publish | {{RESPONSE}} | {{REMAINING_ACTIONS_OR_EVIDENCE}} |
