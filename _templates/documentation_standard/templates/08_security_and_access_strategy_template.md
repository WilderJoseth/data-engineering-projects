# Security and Access Strategy

<!-- Required, scaled to the project. This file owns authentication, authorization, secrets, sensitive data, and access boundaries. Never place real credentials or secret values in documentation. -->

## Document Goal

This document defines security and access controls for {{PROJECT_NAME}}.

## Security Context

| Area | Classification or Exposure | Main Risk | Control Owner |
|---|---|---|---|
| {{SOURCE_COMPONENT_TARGET_OR_INTERFACE_ID}} | {{PUBLIC_INTERNAL_CONFIDENTIAL_RESTRICTED_OR_PROJECT_STANDARD}} | {{RISK}} | {{OWNER}} |

## Authentication

| Connection or Actor | Resource ID | Authentication Method | Credential Location | Rationale |
|---|---|---|---|---|
| {{CONNECTION_OR_ACTOR_ID}} | {{RESOURCE_ID}} | {{METHOD}} | {{SECRET_MANAGER_IDENTITY_PLATFORM_OR_NOT_APPLICABLE}} | {{BRIEF_RATIONALE}} |

## Authorization

| Principal or Role | Resource or Boundary | Permission | Environment | Approval Owner |
|---|---|---|---|---|
| {{PRINCIPAL_OR_ROLE}} | {{RESOURCE_COMPONENT_LAYER_OR_INTERFACE_ID}} | {{PERMISSION_SCOPE}} | {{ENVIRONMENT_OR_ALL}} | {{OWNER}} |

## Secret and Key Handling

| Secret or Key Type | Approved Storage | Rotation or Expiry | Access Boundary |
|---|---|---|---|
| {{SECRET_OR_KEY_TYPE}} | {{APPROVED_STORE}} | {{ROTATION_OR_EXPIRY}} | {{AUTHORIZED_PRINCIPALS}} |

Secrets and keys must not be stored in source control, scripts, notebooks, pipeline definitions, logs, diagrams, or Markdown documentation.

## Sensitive Data Handling

| Data Class | Source or Object IDs | Allowed Use | Protection | Published Form |
|---|---|---|---|---|
| {{DATA_CLASS}} | {{SOURCE_OR_TARGET_OBJECT_IDS}} | {{ALLOWED_USE}} | {{MASK_ENCRYPT_FILTER_TOKENIZE_RESTRICT_OR_OTHER}} | {{PUBLISHED_FORM_OR_NOT_APPLICABLE}} |

## Access Boundaries

| Boundary | Allowed Actors | Prohibited Access | Enforcement |
|---|---|---|---|
| {{COMPONENT_LAYER_NETWORK_OR_ENVIRONMENT_ID}} | {{ALLOWED_ACTORS}} | {{PROHIBITED_ACCESS}} | {{ROLE_POLICY_NETWORK_OR_PLATFORM_CONTROL}} |

## Security Rules

| Rule | Requirement | Verification |
|---|---|---|
| Least privilege | Grant only required access for the required duration | {{VERIFICATION_METHOD}} |
| Environment separation | Isolate identities, configuration, and data as required | {{VERIFICATION_METHOD}} |
| Auditability | Record security-relevant access and changes | {{VERIFICATION_METHOD}} |
| Sensitive-data minimization | Retain and expose only required attributes | {{VERIFICATION_METHOD}} |
| {{PROJECT_RULE}} | {{REQUIREMENT}} | {{VERIFICATION_METHOD}} |

## Security Decisions

| Decision | Selected Approach | Rationale | Residual Risk |
|---|---|---|---|
| {{DECISION}} | {{SELECTED_APPROACH}} | {{BRIEF_RATIONALE}} | {{RESIDUAL_RISK}} |

## Assumptions and Constraints

| Type | Statement | Impact |
|---|---|---|
| {{ASSUMPTION_OR_CONSTRAINT}} | {{STATEMENT}} | {{IMPACT}} |

