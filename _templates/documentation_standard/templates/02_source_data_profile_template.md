# Source Data Profile

<!-- Conditional: create this document when the project ingests or transforms external data. It owns source-system details, source-object inventory, volume, growth, cadence, and profiling assumptions. When it does not apply, do not create the project file; list it as Not Applicable in the project README with a brief reason. -->

## Document Goal

This document defines the source data used by {{PROJECT_NAME}} and the evidence or assumptions that describe its scale and behavior.

## Source Overview

| Source ID | System or Interface | Role | Platform and Hosting | Owner | Access Method |
|---|---|---|---|---|---|
| {{SOURCE_ID}} | {{SOURCE_NAME}} | {{SOURCE_ROLE}} | {{PLATFORM_AND_HOSTING}} | {{OWNER}} | {{DATABASE_API_FILE_STREAM_OR_OTHER}} |

<!-- Repeat rows as needed. Use Source ID consistently in other documents. -->

## Source Characteristics

| Source ID | Data Shape | Delivery Mode | Cadence or Latency | Estimated Scale | Growth | Retention |
|---|---|---|---|---|---|---|
| {{SOURCE_ID}} | {{RELATIONAL_EVENT_FILE_DOCUMENT_OR_OTHER}} | {{BATCH_MICRO_BATCH_STREAMING_REQUEST_OR_OTHER}} | {{CADENCE_OR_LATENCY}} | {{ROWS_EVENTS_OR_BYTES}} | {{GROWTH_ESTIMATE}} | {{RETENTION}} |

## Source Object Inventory

<!-- Repeat this section for each source. Keep target mappings in the target architecture and flow documents. -->

### {{SOURCE_ID}} Objects (Repeatable)

| Object ID | Object or Endpoint | Category | Grain or Key | Change Indicator | Sensitivity | Included |
|---|---|---|---|---|---|---|
| {{SOURCE_OBJECT_ID}} | {{OBJECT_ENDPOINT_TOPIC_OR_PATH}} | {{CATEGORY}} | {{GRAIN_OR_KEY}} | {{TIMESTAMP_SEQUENCE_CDC_OR_NOT_APPLICABLE}} | {{CLASSIFICATION}} | {{YES_NO_WITH_REASON}} |

## Profiling Summary

| Object ID | Metric | Result | Observed At | Confidence or Limitation |
|---|---|---|---|---|
| {{SOURCE_OBJECT_ID}} | {{ROW_COUNT_SIZE_RATE_NULLS_DUPLICATES_OR_OTHER}} | {{RESULT}} | {{DATE_OR_RUN_ID}} | {{CONFIDENCE_OR_LIMITATION}} |

## Schema and Contract Behavior

| Source ID or Object ID | Expected Change | Notification or Detection | Compatibility Expectation |
|---|---|---|---|
| {{ID}} | {{SCHEMA_OR_CONTRACT_CHANGE}} | {{MECHANISM}} | {{EXPECTATION}} |

## Profiling Assumptions and Gaps

| Type | Statement | Validation Plan |
|---|---|---|
| {{ASSUMPTION_OR_GAP}} | {{STATEMENT}} | {{HOW_AND_WHEN_TO_VALIDATE}} |
