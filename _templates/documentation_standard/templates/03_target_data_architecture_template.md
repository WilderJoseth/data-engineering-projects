# Target Data Architecture

<!-- Required. This file owns target components, layers or zones, target objects, naming, responsibilities, and architectural rationale. Do not assume a layered architecture; use Not Applicable where justified. -->

## Document Goal

This document defines the target data architecture for {{PROJECT_NAME}}.

## Architecture Overview

{{TARGET_ARCHITECTURE_SUMMARY}}

| Component ID | Component or Service | Type | Hosting | Responsibility | Status |
|---|---|---|---|---|---|
| {{COMPONENT_ID}} | {{COMPONENT_NAME}} | {{STORAGE_COMPUTE_STREAM_API_DATABASE_OR_OTHER}} | {{CLOUD_ON_PREMISES_HYBRID}} | {{PRIMARY_RESPONSIBILITY}} | {{STATUS}} |

<!-- Repeat rows as needed. Status must use the standard maturity vocabulary. -->

## Key Architecture Decisions

| Decision | Selected Approach | Alternatives Considered | Rationale | Consequence |
|---|---|---|---|---|
| {{DECISION}} | {{SELECTED_APPROACH}} | {{ALTERNATIVES_OR_NOT_APPLICABLE}} | {{BRIEF_RATIONALE}} | {{TRADEOFF_OR_CONSEQUENCE}} |

## Layers or Zones (Optional, Repeatable)

<!-- Use only when the architecture has meaningful layers, zones, domains, or serving boundaries. -->

### {{LAYER_OR_ZONE_ID}}

| Attribute | Value |
|---|---|
| Component | {{COMPONENT_ID}} |
| Purpose | {{PURPOSE}} |
| Inputs | {{SOURCE_OBJECT_FLOW_OR_LAYER_IDS}} |
| Consumers | {{CONSUMER_OR_DOWNSTREAM_IDS}} |
| Access boundary | {{ACCESS_BOUNDARY}} |
| Rationale | {{BRIEF_RATIONALE}} |

## Target Object Inventory

<!-- This is the authoritative target inventory. Reference Source IDs and Object IDs from the source profile; do not repeat source details. -->

| Target Object ID | Component or Zone | Object | Type and Grain | Primary Inputs | Responsibility | Status |
|---|---|---|---|---|---|---|
| {{TARGET_OBJECT_ID}} | {{COMPONENT_OR_ZONE_ID}} | {{OBJECT_NAME_TOPIC_ENDPOINT_OR_PATH}} | {{TYPE_AND_GRAIN}} | {{SOURCE_OR_TARGET_OBJECT_IDS}} | {{RESPONSIBILITY}} | {{STATUS}} |

## Naming Conventions

| Object Type | Convention | Example |
|---|---|---|
| {{OBJECT_TYPE}} | {{NAMING_CONVENTION}} | `{{EXAMPLE_NAME}}` |

## Technical Metadata

| Metadata Field | Applies To | Purpose |
|---|---|---|
| `{{FIELD_NAME}}` | {{TARGET_OBJECT_TYPES_OR_IDS}} | {{PURPOSE}} |

## Architecture Assumptions and Constraints

| Type | Statement | Impact |
|---|---|---|
| {{ASSUMPTION_OR_CONSTRAINT}} | {{STATEMENT}} | {{IMPACT}} |

