# Documentation Guide

## Purpose

This guide explains how to use the reusable documentation templates for data engineering portfolio projects.

The templates are based on the <Project Name> documentation style: concise explanations, compact Markdown tables, design-first structure, and clear separation between design baseline, implementation planned, implementation in progress, and production-ready scope.

## Recommended Document Order

| Order | Document | Purpose |
|---|---|---|
| 1 | README_project_template.md | Presents the project story, scope, architecture, technologies, dependencies, documentation map, and status |
| 2 | 01_current_state_assessment_template.md | Explains the current environment, limitations, risks, drivers, and modernization boundary |
| 3 | 02_source_data_profile_template.md | Defines source systems, source categories, object inventory, volumes, and growth assumptions |
| 4 | 03_target_data_architecture_template.md | Defines target components, layers, objects, naming, and metadata columns |
| 5 | 04_data_flow_strategy_template.md | Defines source-to-target flows, responsibilities, coexistence, and control requirements |
| 6 | 05_load_strategy_template.md | Defines refresh patterns, source-specific load strategies, reruns, and recovery behavior |
| 7 | 06_validation_and_reconciliation_strategy_template.md | Defines validation principles, validation codes, reconciliation types, grain, and measures |
| 8 | 07_ci_cd_and_deployment_strategy_template.md | Defines environments, deployment approach, configuration, repository structure, and deployment artifacts |
| 9 | 08_security_and_access_strategy_template.md | Defines authentication, access, secret handling, sensitive data handling, and security rules |

## How to Use the Templates

| Step | Action |
|---|---|
| 1 | Copy the templates into the new project documentation folder |
| 2 | Replace placeholders such as <Project Name>, <Source Platform>, <Target Platform>, and <Source System> |
| 3 | Keep the document order unless the project has a clear reason to omit or merge a document |
| 4 | Start with a design baseline before documenting implementation details |
| 5 | Mark implementation status clearly as planned, in progress, or production-ready |
| 6 | Review terminology against this guide before publishing |

## Placeholder Rules

| Placeholder Type | Example | Replacement Guidance |
|---|---|---|
| Project name | <Project Name> | Use the exact portfolio project name |
| Platform | <Source Platform>, <Target Platform> | Use product or platform names consistently |
| System | <Source System> | Use the source system or database name consistently |
| Component | <Target Component> | Use the target storage, processing, or reporting component name |
| Object | <Database Name>, <Schema Name>, <Table Name> | Use real object names only after they are defined |
| Flow | <Data Flow Name> | Use a stable name that describes the business role of the flow |
| Rule | <Validation Rule>, <Load Pattern> | Use the same wording across strategy, implementation, and review documents |
| Repository | <Repository Link> | Use a valid relative or external repository link |

## Writing Style

| Rule | Guidance |
|---|---|
| Use direct technical wording | Prefer "This document defines" or "This project describes" over marketing language |
| Keep the tone portfolio-oriented | Explain design choices clearly without overstating production readiness |
| Avoid unnecessary detail | Include enough detail to show engineering thinking without turning strategy docs into implementation logs |
| Use consistent sentence structure | Similar sections should read as if they belong to the same project |
| Use American English | Use American spelling such as "modeling" and "remodeling" |
| Keep terminology stable | Do not introduce alternate names for the same platform, flow, layer, or object |

## Table Formatting

Use compact Markdown tables. Do not align columns with extra spaces.

| Column A | Column B |
|---|---|
| Value | Value |

## Naming Conventions

| Area | Convention |
|---|---|
| Documents | Prefix numbered strategy documents with two digits, such as `01_` |
| Diagrams | Store diagrams under `docs/diagrams` and rendered images under `docs/images` or `docs/img` |
| Data flows | Use names that describe the role of the flow, such as <Data Flow Name> |
| Environments | Use clear environment names such as Development and Production |
| Variables | Use a consistent prefix when the platform supports named variables |
| Technical metadata | Use a consistent naming style such as snake_case or the project standard |

## Terminology Guidance

| Term Type | Guidance |
|---|---|
| Design baseline | Use when the document defines the intended architecture or strategy before implementation |
| Implementation planned | Use when the work is expected but not started |
| Implementation in progress | Use when artifacts are being created or validated |
| Production-ready | Use only when the documented solution has been implemented, validated, and can be operated |
| Target reporting platform | Use for the target environment that owns reporting after cutover |
| Source system | Use for upstream systems that provide raw, operational, historical, or analytical data |
| Control layer | Use for execution tracking, validation, reconciliation, logging, and rerun control |

## Documentation Boundaries

| Document | Keep In | Keep Out |
|---|---|---|
| README | Project story, scope, architecture image, technologies, dependencies, documentation map, status | Detailed object-by-object design |
| Current state assessment | Current platform, limitations, risks, drivers, boundary | Target implementation steps |
| Source data profile | Source inventory, volumes, categories, growth assumptions | Target transformation logic |
| Target data architecture | Target components, layers, objects, naming | Deployment mechanics |
| Data flow strategy | Flow paths, ownership, coexistence, control requirements | Detailed code or orchestration implementation |
| Load strategy | Refresh patterns, rerun behavior, recovery rules | Validation rule definitions unless needed for context |
| Validation and reconciliation | Checks, reconciliation types, grain, measures | Full data quality implementation code |
| CI/CD and deployment | Environments, deployment approach, configuration, repository structure | Security policy details |
| Security and access | Authentication, permissions, secrets, sensitive data handling | Architecture redesign |
