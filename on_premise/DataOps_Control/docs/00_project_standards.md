# DataOps_Control Project Standards

## 1. SQL Naming Standards

| Object | Standard |
|---|---|
| Schemas | `metadata`, `runtime`, `observability`, `reference` |
| Tables | Plural or descriptive snake_case |
| Primary key columns | `id`, except bridge/detail cases if justified |
| Foreign keys | `<referenced_entity>_id` |
| Stored procedures | `usp_<verb>_<object>` |
| Views | `vw_<subject>_<purpose>` |
| Functions | `ufn_<verb>_<object>` |
| Primary key constraints | `PK_<schema>_<table>` |
| Foreign key constraints | `FK_<schema>_<table>_<referenced_table>` |
| Unique constraints | `UK_<schema>_<table>_<columns>` |
| Default constraints | `DF_<schema>_<table>_<column>` |
| Check constraints | `CK_<schema>_<table>_<rule>` |

## 2. Table Structure Standards

- Tables should use consistent audit fields.
- Current standard: `created_at`, `created_by`.
- Do not add `updated_at` / `updated_by` unless the table truly supports update tracking.
- Runtime/history/evidence tables should preserve execution history.
- Observability tables are append-only by default, except documented controlled recalculation procedures.
- Reference IDs may be fixed when inserted explicitly by seed scripts.

## 3. Stored Procedure Standards

Each stored procedure should follow this structure:

1. Header comment with purpose.
2. Parameters grouped clearly.
3. Basic validation.
4. Status/code lookup or documented fixed ID assumption.
5. Main transaction if multiple writes must be atomic.
6. Error handling with `TRY...CATCH`.
7. No silent failures.
8. No undocumented hardcoded business logic.
9. Consistent output parameters where identifiers are created.
10. Comments only where logic is not obvious.

## 4. Comment Standards

- Comments should explain why, not repeat what the SQL already says.
- Use short section comments for complex procedures.
- Avoid excessive comments for simple inserts/selects.
- Add comments when relying on fixed framework status IDs.
- Add comments for controlled exceptions, such as monitoring recalculation.

## 5. Runtime Design Standards

- Metadata defines configuration.
- Runtime controls execution state and history.
- Observability records evidence.
- Runtime procedures should not modify metadata.
- Execution plans define what should run.
- Execution runs and steps record what actually ran.
- Watermark control stores committed state.
- Execution watermark stores per-step range/history.

## 6. Security Standards

- Executors read metadata and reference data.
- Executors execute runtime/observability procedures.
- Executors should not directly update runtime tables.
- Error logging is procedure-only.
- Validation, reconciliation, and monitoring evidence can be inserted directly only if required by external tools.
- Admin has broader maintenance rights.

## 7. Review Rules

A file is not accepted if it has:
- Inconsistent object naming.
- Undocumented hardcoded constants.
- Procedure logic that bypasses lifecycle rules.
- Direct metadata changes from runtime procedures.
- Direct executor grants that violate least privilege.
- Documentation that describes non-implemented behavior as current.
