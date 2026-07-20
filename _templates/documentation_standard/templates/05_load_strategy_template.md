# Load Strategy

<!-- Conditional: create this document for stateful ingestion or materialized targets. It owns load/write patterns, keys, state, watermarks, checkpoints, change/delete handling, idempotency, reruns, and recovery. When it does not apply, do not create the project file; list it as Not Applicable in the project README with a brief reason. -->

## Document Goal

This document defines how {{PROJECT_NAME}} reads changes and writes recoverable target state.

## Load Pattern Catalog

| Pattern ID | Read Behavior | Write Behavior | State Mechanism | Typical Use | Rationale |
|---|---|---|---|---|---|
| {{LOAD_PATTERN_ID}} | {{FULL_INCREMENTAL_CDC_EVENT_REQUEST_OR_OTHER}} | {{APPEND_UPSERT_REPLACE_DELETE_RELOAD_OR_OTHER}} | {{WATERMARK_CHECKPOINT_OFFSET_VERSION_OR_NOT_APPLICABLE}} | {{APPLICABILITY}} | {{BRIEF_RATIONALE}} |

## Object Load Assignment

<!-- Reference object IDs defined in the source profile and target architecture. Do not repeat their inventories or flow paths. -->

| Target Object ID | Flow ID | Pattern ID | Match or Partition Key | State Field or Store | Delete Handling |
|---|---|---|---|---|---|
| {{TARGET_OBJECT_ID}} | {{FLOW_ID}} | {{LOAD_PATTERN_ID}} | {{KEY_OR_NOT_APPLICABLE}} | {{WATERMARK_CHECKPOINT_OR_NOT_APPLICABLE}} | {{BEHAVIOR}} |

## State and Progress Tracking

| Flow or Object ID | State Captured | Storage | Advance Condition | Reset or Replay Rule |
|---|---|---|---|---|
| {{ID}} | {{WATERMARK_OFFSET_CHECKPOINT_VERSION_OR_BATCH}} | {{STATE_STORE}} | {{SUCCESS_CONDITION}} | {{RESET_OR_REPLAY_RULE}} |

## Change, Ordering, and Late-Data Rules

| Concern | Rule | Rationale |
|---|---|---|
| Inserts and updates | {{RULE}} | {{BRIEF_RATIONALE}} |
| Deletes or tombstones | {{RULE}} | {{BRIEF_RATIONALE}} |
| Duplicates | {{RULE}} | {{BRIEF_RATIONALE}} |
| Ordering | {{RULE_OR_NOT_APPLICABLE_WITH_REASON}} | {{BRIEF_RATIONALE}} |
| Late or out-of-window data | {{RULE_OR_NOT_APPLICABLE_WITH_REASON}} | {{BRIEF_RATIONALE}} |
| Schema or contract change | {{RULE}} | {{BRIEF_RATIONALE}} |

## Idempotency

| Flow or Object ID | Idempotency Boundary | Duplicate Prevention | Verification |
|---|---|---|---|
| {{ID}} | {{REQUEST_BATCH_WINDOW_EVENT_OR_OBJECT}} | {{MECHANISM}} | {{HOW_VERIFIED}} |

## Rerun and Recovery

| Failure Scenario | Recovery Point | Rerun Scope | Expected Result | Approval Needed |
|---|---|---|---|---|
| {{SCENARIO}} | {{LAST_CHECKPOINT_BATCH_VERSION_OR_OTHER}} | {{FLOW_OBJECT_PARTITION_WINDOW_OR_REQUEST}} | {{EXPECTED_RESULT}} | {{YES_NO_AND_OWNER}} |

## Load Assumptions and Constraints

| Type | Statement | Impact |
|---|---|---|
| {{ASSUMPTION_OR_CONSTRAINT}} | {{STATEMENT}} | {{IMPACT}} |
