# Current State Assessment

## Document Goal

This document describes the current Sales data source, identifies the main current-state limitations, and evaluates whether the existing source is ready to support new business and technology requirements.

The current source is recognized as a working platform that has supported Sales operations over time. However, the introduction of a new web/service layer and Power BI reporting needs requires assessing whether the current source can continue serving as a reliable foundation for operational processing, service-based consumption, and reporting.

## Current Environment Summary

| Characteristic | Current Oracle Sales Source |
| --- | --- |
| Platform | Oracle XE 21c |
| Hosting model | On-premise |
| Business domain | Sales |
| Current role | Operational processing, historical Sales data access, and reporting consumption |
| Workload type | OLTP-style operational workload |
| Data model | Normalized model |
| Current status | Active |
| Data volume | Millions of operational records |
| Historical range | Sales history accumulated since 2012 |
| Update frequency | Updated through existing operational and batch processes |
| Main growth driver | New Sales transactions and accumulated historical data |
| Largest data areas | Sales orders and order details |
| Maintenance pattern | Existing database objects, jobs, procedures, triggers, and manual/operational scripts |

## What Works Well Today

| Aspect | Current Strength |
|---|---|
| Operational continuity | The source has supported Sales operations for several years |
| Historical data availability | Sales history is available in the current source |
| Existing business rules | Current processes already implement business behavior required by the existing processes |
| Business familiarity | Users and technical teams understand the current operational behavior |
| Existing integrations | Current processes and reports are already connected to the source |

## Current Limitations and Risks

| Current Limitation | Current Impact | Risk if Not Addressed |
|---|---|---|
| Source model no longer matches business needs | The current model reflects older operational processes and may not be easy to use for the new web/service layer | The new service may inherit legacy complexity and require workarounds |
| Tables with mixed operational and reporting responsibilities | Some tables support operational processing and reporting needs at the same time | The platform may become harder to scale, maintain, and govern as service and Power BI consumption grow |
| Reporting queries impact operations | Reporting or analytical queries compete with operational workloads on the same source structures | Performance issues may increase when the new service and Power BI reporting are added |
| Hidden business logic | Triggers execute business rules that are not visible from application flow | New service behavior may become unpredictable or difficult to test |
| Low adaptability of existing processes | Long stored procedures, complex functions, hardcoded logic, and rigid jobs make changes slower and riskier | Future requirements may require manual fixes, duplicated logic, or risky changes |
| Inconsistent naming conventions | Object names reflect different development periods, teams, or standards | Development, support, and onboarding may become slower as the platform expands |
| No clear distinction between active and historical data | Current and historical records coexist without clear lifecycle separation | Queries, maintenance, and service consumption may become harder to optimize |
| Jobs without centralized monitoring | Scheduled jobs do not have a single place to review status, duration, errors, and dependencies | Failures or delays may be harder to detect and explain |
| Excessive dependency on manual scripts | Corrections, reloads, validations, or reconciliations depend on manually executed scripts | Operational support effort and execution risk may increase |
| Manual reconciliation | Data trust depends on manual checks of counts, totals, or process results | Support effort may increase as more consumers depend on the data |

## Modernization Drivers

| Driver | Reason |
|---|---|
| New service readiness | The new web/service layer requires a cleaner operational model with predictable logic, clear relationships, and reliable access patterns |
| Operational and reporting separation | Operational processing and Power BI reporting should not depend on the same structures without clear workload boundaries |
| Service-safe business logic | Hidden logic, especially triggers, should not be the standard for new service-oriented behavior |
| Standardized process control | Jobs, errors, dependencies, and reruns need centralized visibility and consistent handling |
| Improved data reliability | Data integrity rules, validation, and reconciliation should be clearer before exposing data to new consumers |
| Better maintainability | Naming conventions, process design, and data lifecycle rules should support long-term maintenance |
| Power BI readiness | Reporting data should be structured for analytical consumption instead of relying directly on operational structures |
| Historical data lifecycle | Active and historical data should be managed with clearer retention, archive, and access rules |
