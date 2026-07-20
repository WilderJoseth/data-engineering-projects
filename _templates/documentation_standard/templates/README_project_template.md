# {{PROJECT_NAME}}

<!-- Required. Replace every {{UPPER_SNAKE_CASE}} placeholder after copying this template into a project. Remove author instructions from the project copy before final publication; keep them in the reusable template. -->

## Overview

{{PROJECT_SUMMARY}}

| Item | Value |
|---|---|
| Business or technical goal | {{PROJECT_GOAL}} |
| Project type | {{GREENFIELD_MIGRATION_MODERNIZATION_INTEGRATION_DATA_PRODUCT_OR_OTHER}} |
| Workload mode | {{BATCH_MICRO_BATCH_STREAMING_HYBRID_OR_OTHER}} |
| Hosting model | {{CLOUD_ON_PREMISES_HYBRID_OR_OTHER}} |
| Current maturity | {{PLANNED_IN_PROGRESS_IMPLEMENTED_VALIDATED_OR_PRODUCTION_READY}} |

## Scope

| Area | In Scope |
|---|---|
| {{SCOPE_AREA}} | {{SCOPE_DESCRIPTION}} |

<!-- Repeat the row above as needed. -->

## Out of Scope

| Area | Reason |
|---|---|
| {{EXCLUDED_AREA}} | {{EXCLUSION_REASON}} |

<!-- Repeat as needed. Use Not Applicable with a reason only when the project has no exclusions. -->

## Success Criteria

| Criterion | Measure or Evidence |
|---|---|
| {{SUCCESS_CRITERION}} | {{MEASURE_OR_EVIDENCE}} |

## High-Level Architecture

![{{PROJECT_NAME}} high-level architecture]({{ARCHITECTURE_DIAGRAM_PATH}})

<!-- Add two or three sentences explaining the architecture and its main rationale. Do not repeat detailed component or flow inventories. -->

{{ARCHITECTURE_SUMMARY_AND_RATIONALE}}

## Technologies

| Capability | Selected Technology | Rationale |
|---|---|---|
| {{CAPABILITY}} | {{TECHNOLOGY_OR_PLATFORM}} | {{BRIEF_RATIONALE}} |

<!-- Repeat as needed. Capabilities may include storage, compute, orchestration, streaming, serving, observability, or infrastructure. -->

## Dependencies

| Dependency | Purpose | Status | Link |
|---|---|---|---|
| {{DEPENDENCY_NAME}} | {{PURPOSE}} | {{PLANNED_IN_PROGRESS_IMPLEMENTED_VALIDATED_OR_PRODUCTION_READY}} | {{LINK_OR_NOT_APPLICABLE}} |

## Documentation

<!-- List every standard document. When one does not apply, select Not Applicable, add a brief reason, and use plain document text instead of a link because the actual file does not need to be created. Use links for files that exist. -->

| Document | Purpose | Applicability | Reason |
|---|---|---|---|
| [Current State Assessment](docs/01_current_state_assessment.md) | Existing environment, limitations, risks, and change boundary | {{APPLICABILITY}} | {{BRIEF_REASON}} |
| [Source Data Profile](docs/02_source_data_profile.md) | Source systems, objects, scale, and profiling assumptions | {{APPLICABILITY}} | {{BRIEF_REASON}} |
| [Target Data Architecture](docs/03_target_data_architecture.md) | Target components, objects, naming, and responsibilities | Required | Core project design |
| [Data Flow Strategy](docs/04_data_flow_strategy.md) | End-to-end routes and flow responsibilities | {{APPLICABILITY}} | {{BRIEF_REASON}} |
| [Load Strategy](docs/05_load_strategy.md) | Load patterns, state, reruns, and recovery | {{APPLICABILITY}} | {{BRIEF_REASON}} |
| [Validation and Reconciliation](docs/06_validation_and_reconciliation_strategy.md) | Validation, reconciliation, traceability, and acceptance | Required | Core quality strategy |
| [CI/CD and Deployment](docs/07_ci_cd_and_deployment_strategy.md) | Environments, configuration, promotion, and deployment units | {{APPLICABILITY}} | {{BRIEF_REASON}} |
| [Security and Access](docs/08_security_and_access_strategy.md) | Authentication, authorization, secrets, and access boundaries | Required | Core security strategy |

<!-- For {{APPLICABILITY}}, use Required, Optional, or Not Applicable. -->

## Project Status

<!-- Status describes completed work, not intended design. Implemented requires a working artifact; Validated requires recorded evidence; Production-Ready requires operational readiness. -->

| Area | Status | Evidence or Next Step |
|---|---|---|
| Project framing | {{STATUS}} | {{EVIDENCE_OR_NEXT_STEP}} |
| Design documentation | {{STATUS}} | {{EVIDENCE_OR_NEXT_STEP}} |
| Implementation | {{STATUS}} | {{EVIDENCE_OR_NEXT_STEP}} |
| Validation | {{STATUS}} | {{EVIDENCE_OR_NEXT_STEP}} |
| Deployment and operations | {{STATUS}} | {{EVIDENCE_OR_NEXT_STEP}} |
