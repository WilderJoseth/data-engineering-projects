# Observability Design

## Purpose

This document describes how the `observability` schema captures execution evidence for `DataOps_Control`, including technical errors, validation results, reconciliation results, and monitoring results.

SQL scripts remain the source of truth for exact table and procedure definitions.

## Observability Tables

| Design Role / Concept | Table | Responsibility |
|---|---|---|
| Technical error logging | `observability.error_logs` | Stores technical error details linked to an execution step. |
| Validation result capture | `observability.validation_results` | Stores validation findings linked to an execution step and validation code. |
| Reconciliation result capture | `observability.reconciliation_results` | Stores metric values by reconciliation side and scope for an execution step. |
| Monitoring result capture | `observability.monitoring_results` | Stores captured monitoring metric values and threshold evaluation results for an execution step. |

## Important Design Distinctions

The observability model stores evidence from execution. It does not own project-specific business rules or notification delivery.

| Distinction | Meaning | Why It Matters |
|---|---|---|
| Execution step vs observability evidence | Execution steps are stored in `runtime.execution_steps`. Errors, validations, reconciliations, and monitoring records are evidence linked to a step. | Runtime records show what ran; observability records show what was observed. |
| Error logging vs step failure | `observability.error_logs` stores technical error details. Step failure is recorded separately in `runtime.execution_steps`. | Logging an error does not automatically close or fail the execution step. |
| Validation code vs validation result | `reference.validation_codes` defines reusable validation classifications. `observability.validation_results` stores captured findings. | The framework separates controlled validation types from runtime evidence. |
| Validation rule vs validation evidence | Project-specific logic defines validation rules. The control database stores the validation result summary. | `DataOps_Control` captures evidence but does not own all business validation logic. |
| Reconciliation metric definition vs reconciliation result | A metric name identifies what was measured. A reconciliation result stores the measured value for a side and key. | The model supports comparable metrics without forcing one reconciliation method. |
| Reconciliation key vs process scope | Reconciliation key identifies the comparison grain or grouping. Process scope is defined in metadata. | A result can represent total-level, batch-level, or other grouped comparisons for the same execution step. |
| Metric value bigint vs metric value decimal | Reconciliation and monitoring results store one numeric value family per record. | The model avoids mixing integer and decimal values in the same result record. |
| Monitoring definition vs monitoring result | Monitoring thresholds are configured in metadata. Monitoring results store actual captured values and range evaluation. | Expected values belong to metadata; observed values belong to observability. |
| Monitoring calculation vs status decision | Monitoring capture can evaluate whether values are within range. Step status is still closed by runtime logic or the caller. | Observability evidence can inform status, but it does not replace execution control. |
| Observability evidence vs rejected records | Observability tables store summary evidence. Row-level rejected business records are not centrally stored. | The framework tracks execution evidence without becoming a rejected-record repository. |

## Observability Procedures and Views

| Object Type | Name | Purpose |
|---|---|---|
| Procedure | `observability.usp_log_error` | Inserts a technical error record for an execution step. |
| Procedure | `observability.usp_capture_execution_step_bigint_monitoring_results` | Recalculates and stores BIGINT-based monitoring results for one execution step. |
| View | `observability.vw_execution_observability_summary` | Returns one row per execution step with counts of error, validation, reconciliation, and monitoring records. |
| View | `observability.vw_monitoring_result_summary` | Returns monitoring results with project/process context, metric metadata, thresholds, and evaluation outcome. |
| View | `observability.vw_reconciliation_result_summary` | Returns reconciliation results with project/process context and metric values. |

## Source SQL Scripts

| Script | Relevant Content |
|---|---|
| `database/ddl/03_create_reference_tables.sql` | Validation code and monitoring metric reference tables. |
| `database/ddl/04_create_metadata_tables.sql` | Process monitoring and notification metadata. |
| `database/ddl/06_create_observability_tables.sql` | Observability result tables. |
| `database/ddl/07_create_stored_procedures.sql` | Error logging and monitoring capture procedures. |
| `database/ddl/10_create_views.sql` | Observability review views. |
