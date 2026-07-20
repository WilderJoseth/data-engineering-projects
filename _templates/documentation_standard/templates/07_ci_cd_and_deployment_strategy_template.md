# CI/CD and Deployment Strategy

<!-- Conditional: create this document when deployable artifacts or multiple environments exist. It owns environments, configuration, promotion, connections, and deployment units. When it does not apply, do not create the project file; list it as Not Applicable in the project README with a brief reason. -->

## Document Goal

This document defines how {{PROJECT_NAME}} artifacts and configuration are built, tested, promoted, and deployed.

## Environment Strategy

| Environment ID | Purpose | Hosting Boundary | Data Policy | Approval Owner |
|---|---|---|---|---|
| {{ENVIRONMENT_ID}} | {{PURPOSE}} | {{ACCOUNT_SERVER_CLUSTER_WORKSPACE_OR_OTHER}} | {{SYNTHETIC_MASKED_PRODUCTION_OR_OTHER}} | {{OWNER}} |

## Promotion Path

```text
{{SOURCE_ENVIRONMENT}} -> {{INTERMEDIATE_ENVIRONMENT_OR_NOT_APPLICABLE}} -> {{TARGET_ENVIRONMENT}}
```

| Gate | Required Evidence | Approval or Automation |
|---|---|---|
| {{BUILD_TEST_SECURITY_OR_RELEASE_GATE}} | {{EVIDENCE}} | {{AUTOMATED_OR_OWNER}} |

## Configuration and Connections

<!-- Define configuration mechanics, not secret values. Security requirements belong in the security strategy. -->

| Configuration ID | Purpose | Scope | Source | Override Method |
|---|---|---|---|---|
| {{CONFIGURATION_ID}} | {{PURPOSE}} | {{GLOBAL_ENVIRONMENT_COMPONENT_OR_FLOW}} | {{CONFIG_STORE_OR_MECHANISM}} | {{METHOD}} |

| Connection ID | Purpose | Environment Scope | Resolution Method |
|---|---|---|---|
| {{CONNECTION_ID}} | {{PURPOSE}} | {{ENVIRONMENT_IDS}} | {{CONFIGURATION_OR_DISCOVERY_METHOD}} |

## Deployment Units

<!-- Reference Component IDs from the target architecture; do not redefine component responsibilities. -->

| Deployment Unit | Component IDs | Artifact | Deployment Method | Created or Promoted | Rollback Method |
|---|---|---|---|---|---|
| {{DEPLOYMENT_UNIT_ID}} | {{COMPONENT_IDS}} | {{ARTIFACT_OR_PACKAGE}} | {{MANUAL_PIPELINE_SCRIPT_IAC_OR_OTHER}} | {{CREATED_OR_PROMOTED}} | {{ROLLBACK_METHOD}} |

## Versioning and Release Evidence

| Item | Convention or Location |
|---|---|
| Source control | {{REPOSITORY_AND_BRANCH_STRATEGY}} |
| Artifact version | {{VERSION_CONVENTION}} |
| Release record | {{LOCATION_OR_SYSTEM}} |
| Deployment evidence | {{LOCATION_OR_SYSTEM}} |

## Repository Layout (Optional)

```text
{{PROJECT_ROOT}}
|-- {{ARTIFACT_DIRECTORY}}
|-- {{DEPLOYMENT_DIRECTORY}}
|-- docs
|-- README.md
```

## Deployment Decisions

| Decision | Selected Approach | Rationale | Consequence |
|---|---|---|---|
| {{DECISION}} | {{SELECTED_APPROACH}} | {{BRIEF_RATIONALE}} | {{CONSEQUENCE}} |

## Deployment Assumptions and Constraints

| Type | Statement | Impact |
|---|---|---|
| {{ASSUMPTION_OR_CONSTRAINT}} | {{STATEMENT}} | {{IMPACT}} |
