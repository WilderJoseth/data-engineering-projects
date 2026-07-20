# Documentation Guide

## Purpose

Use this guide to select and adapt the documentation templates without duplicating authoritative information or overstating project maturity.

## Template Selection

| Template | Use | Applicability |
|---|---|---|
| Project README | Project summary, scope, links, and status | Required |
| Current State Assessment | Existing environment, limitations, risks, and change boundary | Required for migration, modernization, replacement, or remediation; optional for greenfield |
| Source Data Profile | Source systems, objects, scale, and profiling assumptions | Required when external data is ingested or transformed |
| Target Data Architecture | Target components, objects, naming, and responsibilities | Required |
| Data Flow Strategy | End-to-end routes and responsibilities | Required for movement, integration, pipeline, or transformation work |
| Load Strategy | State, write patterns, reruns, and recovery | Required for stateful ingestion or materialized targets |
| Validation and Reconciliation | Checks, thresholds, traceability, and acceptance | Required; reconciliation may be `Not Applicable` |
| CI/CD and Deployment | Environments, configuration, promotion, and deployment units | Required for deployable artifacts or multiple environments |
| Security and Access | Authentication, authorization, secrets, and data boundaries | Required; depth should match risk |

When a document does not apply, list it as `Not Applicable` in the project README with a brief reason. The actual document file does not need to be created.

## Placeholder and Instruction Conventions

| Convention | Meaning | Action |
|---|---|---|
| `{{UPPER_SNAKE_CASE}}` | Author-supplied project value | Replace every occurrence |
| `<!-- instruction -->` | Author-only guidance | Keep in reusable templates; after copying a template into a project, follow and remove before the project documentation is final |
| `(Optional)` | Section may be omitted | Remove or mark `Not Applicable` with justification |
| `(Repeatable)` | Copy the complete section or row | Repeat once per relevant item |
| `Not Applicable` | Content does not apply | Add a concise reason; do not use it to hide missing work |

Use stable IDs such as `SRC_ORDERS`, `OBJ_CUSTOMER`, `CMP_STORAGE`, and `FLOW_INGEST` to cross-reference information without copying full inventories.

## Information Ownership

| Information | Authoritative File |
|---|---|
| Summary, scope, exclusions, dependencies, links, status | Project README |
| Current environment, limitations, risks, change boundary | Current State Assessment |
| Source systems, objects, volumes, growth, profiling | Source Data Profile |
| Target components, layers, objects, naming, responsibilities | Target Data Architecture |
| End-to-end routes and flow responsibilities | Data Flow Strategy |
| Load patterns, keys, state, watermarks, checkpoints, reruns, recovery | Load Strategy |
| Validation, reconciliation, thresholds, traceability, acceptance | Validation and Reconciliation Strategy |
| Environments, configuration, promotion, deployment units | CI/CD and Deployment Strategy |
| Authentication, authorization, secrets, sensitive data, access boundaries | Security and Access Strategy |

## Avoiding Duplication

- Define each inventory once in its authoritative file.
- In other files, repeat only a stable ID, name, or one-line context needed to read the local decision.
- Link to the authoritative document instead of copying descriptions, mappings, rules, or volumes.
- Keep the README at summary level.
- Let deployment own configuration mechanics and security own protection of credentials and access.
- Let flow own routes, load own state changes, and validation own acceptance rules.

## Explaining Rationale

For each material decision, record the selected approach, brief reason, relevant alternative, and important consequence. Focus on why the choice fits the project's constraints; avoid generic claims that a technology is "best."

## Maturity Statuses

| Status | Meaning |
|---|---|
| `Planned` | Intended but not started |
| `In Progress` | Work has started but is incomplete |
| `Implemented` | A working artifact exists |
| `Validated` | The implementation passed defined checks with recorded evidence |
| `Production-Ready` | Validated and ready for supported operation, security, monitoring, recovery, and release requirements |

Design approval does not make an implementation `Implemented`. Always include evidence or the next step with status claims.

## Adapting the Standard

- Use platform-selected terms only after defining their generic role.
- Add or remove component, layer, flow, and environment blocks to match the design.
- For batch or micro-batch, emphasize schedules, windows, watermarks, and reruns.
- For streaming, emphasize events, partitions, offsets, checkpoints, ordering, late data, and replay.
- For APIs or operational serving, use request, endpoint, contract, latency, and idempotency concepts.
- For file, lakehouse, warehouse, or database targets, describe their responsibilities without forcing named layers.
- For cloud, on-premises, or hybrid designs, document actual hosting, connection, network, identity, and deployment boundaries.

## Publishing Workflow

1. Select applicable templates and record exclusions.
2. Replace placeholders in project copies and remove author comments from those copies before final publication. Do not remove comments from files under `documentation_standard/templates/`.
3. Confirm ownership and cross-references.
4. Add decision rationale and current maturity evidence.
5. Verify links, diagrams, tables, terminology, security, and validation.
6. Complete the review checklist.
