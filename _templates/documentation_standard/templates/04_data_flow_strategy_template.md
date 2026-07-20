# Data Flow Strategy

<!-- Conditional: create this document for pipeline, integration, movement, or transformation projects. It owns end-to-end routes, flow purpose, responsibilities, and ownership. Use IDs from the source profile and target architecture. When it does not apply, do not create the project file; list it as Not Applicable in the project README with a brief reason. -->

## Document Goal

This document defines how data moves through {{PROJECT_NAME}} and assigns responsibility for each flow.

## Flow Overview

| Flow ID | Purpose | Source IDs | Target IDs | Mode | Owner | Status |
|---|---|---|---|---|---|---|
| {{FLOW_ID}} | {{PURPOSE}} | {{SOURCE_OR_TARGET_IDS}} | {{TARGET_OBJECT_IDS}} | {{BATCH_MICRO_BATCH_STREAMING_REQUEST_OR_HYBRID}} | {{OWNER}} | {{STATUS}} |

<!-- Repeat rows as needed. Do not reproduce full source or target inventories. -->

## Flow Definition (Repeatable)

<!-- Repeat this complete section for every major flow. -->

### {{FLOW_ID}}: {{FLOW_NAME}}

| Attribute | Value |
|---|---|
| Purpose | {{PURPOSE}} |
| Sources | {{SOURCE_OR_TARGET_OBJECT_IDS}} |
| Targets | {{TARGET_OBJECT_IDS}} |
| Trigger | {{SCHEDULE_EVENT_REQUEST_DEPENDENCY_OR_OTHER}} |
| Cadence or latency objective | {{CADENCE_OR_LATENCY}} |
| Duration or lifecycle | {{ONGOING_TEMPORARY_ONE_TIME_OR_OTHER}} |
| Owner | {{OWNER}} |
| Rationale | {{WHY_THIS_ROUTE_AND_MODE_WERE_SELECTED}} |

#### Route

```text
{{SOURCE_ID}} -> {{INTERMEDIATE_COMPONENT_OR_NOT_APPLICABLE}} -> {{TARGET_ID}}
```

#### Responsibilities

| Step | Component or Actor | Responsibility | Output |
|---|---|---|---|
| {{STEP_NAME}} | {{COMPONENT_OR_ACTOR}} | {{RESPONSIBILITY}} | {{OUTPUT_ID_OR_STATE}} |

#### Observability and Control

| Control | Expected Behavior | Owner or System |
|---|---|---|
| Execution or request tracking | {{EXPECTED_BEHAVIOR}} | {{OWNER_OR_SYSTEM}} |
| Lineage or source identification | {{EXPECTED_BEHAVIOR}} | {{OWNER_OR_SYSTEM}} |
| Health, lag, or completion signal | {{EXPECTED_BEHAVIOR}} | {{OWNER_OR_SYSTEM}} |
| Failure routing | {{EXPECTED_BEHAVIOR}} | {{OWNER_OR_SYSTEM}} |

<!-- Reference the load strategy for state, checkpoint, rerun, and recovery detail. Reference the validation strategy for rules and acceptance. -->

## Transition or Coexistence Flows (Optional, Repeatable)

| Flow ID | Need | Entry Condition | Exit Condition | Owner |
|---|---|---|---|---|
| {{FLOW_ID}} | {{MIGRATION_BACKFILL_DUAL_RUN_FALLBACK_OR_OTHER}} | {{ENTRY_CONDITION}} | {{EXIT_CONDITION}} | {{OWNER}} |

## Flow Assumptions and Constraints

| Type | Statement | Impact |
|---|---|---|
| {{ASSUMPTION_OR_CONSTRAINT}} | {{STATEMENT}} | {{IMPACT}} |
