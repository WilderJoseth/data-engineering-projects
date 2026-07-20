# Validation and Reconciliation Strategy

<!-- Required, scaled to the project. This file owns validation, reconciliation, thresholds, traceability, and acceptance. Reconciliation may be Not Applicable with justification. -->

## Document Goal

This document defines how {{PROJECT_NAME}} verifies data and determines whether outputs are accepted.

## Validation Principles

| Principle | Project Rule | Rationale |
|---|---|---|
| Severity | {{HOW_INFO_WARNING_AND_ERROR_ARE_USED}} | {{BRIEF_RATIONALE}} |
| Timing | {{BEFORE_DURING_AFTER_WRITE_OR_CONTINUOUS}} | {{BRIEF_RATIONALE}} |
| Traceability | {{HOW_RESULTS_LINK_TO_FLOW_RUN_REQUEST_OR_OBJECT}} | {{BRIEF_RATIONALE}} |
| Blocking behavior | {{WHAT_STOPS_PUBLICATION_OR_PROCESSING}} | {{BRIEF_RATIONALE}} |

## Validation Rules

| Rule ID | Applies To ID | Check | Severity | Threshold | Timing | Failure Action | Owner |
|---|---|---|---|---|---|---|---|
| {{VALIDATION_RULE_ID}} | {{FLOW_OR_OBJECT_ID}} | {{CHECK_DESCRIPTION}} | {{INFO_WARNING_OR_ERROR}} | {{THRESHOLD_OR_EXPECTATION}} | {{TIMING}} | {{ACTION}} | {{OWNER}} |

<!-- Repeat rows as needed. Reference object IDs instead of copying inventories. -->

## Reconciliation Strategy

| Applicability | Justification |
|---|---|
| {{APPLICABILITY}} | {{BRIEF_REASON}} |

<!-- Complete the remaining reconciliation sections only when applicable. -->

### Reconciliation Rules (Optional)

| Reconciliation ID | Source ID | Target ID | Metric | Grain or Window | Tolerance | Timing |
|---|---|---|---|---|---|---|
| {{RECONCILIATION_ID}} | {{SOURCE_OR_OBJECT_ID}} | {{TARGET_OBJECT_ID}} | {{COUNT_SUM_HASH_BALANCE_OR_OTHER}} | {{GRAIN_WINDOW_OR_REQUEST}} | {{TOLERANCE}} | {{TIMING}} |

## Result Traceability

| Result Field | Purpose |
|---|---|
| {{RUN_REQUEST_OR_EXECUTION_ID_FIELD}} | Links the result to the producing execution or request |
| {{RULE_ID_FIELD}} | Identifies the applied validation or reconciliation rule |
| {{SCOPE_FIELD}} | Identifies the object, partition, window, record, or request checked |
| {{OBSERVED_AND_EXPECTED_FIELDS}} | Records the comparison and threshold |
| {{STATUS_AND_TIMESTAMP_FIELDS}} | Records the outcome and evaluation time |

## Acceptance and Exception Handling

| Outcome | Acceptance State | Required Action | Decision Owner |
|---|---|---|---|
| {{PASS_WARNING_FAILURE_OR_EXCEPTION}} | {{ACCEPTED_HELD_REJECTED_OR_CONDITIONAL}} | {{ACTION}} | {{OWNER}} |

## Assumptions and Constraints

| Type | Statement | Impact |
|---|---|---|
| {{ASSUMPTION_OR_CONSTRAINT}} | {{STATEMENT}} | {{IMPACT}} |
