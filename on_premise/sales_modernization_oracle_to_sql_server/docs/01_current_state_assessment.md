# Current State Assessment

## Document Goal

This document evaluates the current Sales data source, identifies current-state limitations, and explains why the existing source must be assessed before supporting a new web/service layer and Power BI reporting needs.

## Current Environment Summary

The current Sales data source is a legacy Oracle-based platform that has been operating since 2012. It supports existing Sales processes and contains accumulated operational and historical Sales data.

| Characteristic | Current Oracle Sales Source |
| --- | --- |
| Platform | Oracle |
| Hosting model | On-premise |
| Business domain | Sales |
| Current role | Existing Sales operational source |
| Primary usage | Operational processing, historical Sales data access, and reporting consumption |
| Workload type | OLTP-style operational workload |
| Data model | Normalized model |
| Current status | Active |
| Data volume | Millions of operational records |
| Historical range | Sales history accumulated since 2012 |
| Update frequency | Updated through existing operational and batch processes |
| Main growth driver | New Sales transactions and accumulated historical data |
| Largest data areas | Sales orders, order details, customers, addresses, and related Sales entities |
| Maintenance pattern | Existing database objects, jobs, procedures, triggers, and manual/operational scripts |
| Business criticality | Required for current Sales operations and existing reporting consumption |

## What Works Well Today

The current source should be recognized as a working platform. The purpose of this assessment is to identify whether it is ready for the next business and technology requirements.

| Aspect | Current Strength |
|---|---|
| Operational continuity | The source has supported Sales operations for several years. |
| Historical data availability | Sales history is available in the current platform. |
| Existing business rules | Current processes already implement business behavior required by the existing application. |
| Business familiarity | Users and technical teams understand the current operational behavior. |
| Existing integrations | Current processes and reports are already connected to the source. |

## Current Limitations

Although the current source is operational, several limitations may affect its readiness to support a new service-based architecture and reporting consumption.

| Aspect | Current Limitation | Impact |
|---|---|---|
| Source model alignment | The current model was designed for older operational needs and may not match the structure required by the new web/service layer. | New service development may require extra transformation, workarounds, or redesign before the data can be consumed cleanly. |
| Mixed table responsibilities | Some tables or structures may support both operational processing and reporting needs. | Changes become harder because one object may affect transactional behavior, reporting logic, and external consumers at the same time. |
| Reporting workload pressure | Reporting or analytical queries may run against operational structures. | Operational performance can be affected by reporting consumption, especially as data volume and usage grow. |
| Hidden business logic | Triggers may contain implicit business rules that are not visible from an standard process review. | New service behavior can become unpredictable if hidden rules execute automatically without clear documentation or control. |
| Low adaptability of existing processes | Long stored procedures, complex functions, hardcoded rules, fixed table names, hardcoded filters, or rigid batch logic may exist. | Supporting new requirements becomes slower and riskier because changes are difficult to isolate and test. |
| Incomplete data integrity enforcement | Some relationships, foreign keys, uniqueness rules, mandatory fields, or validation constraints may not have been fully implemented or may have been applied inconsistently. | The source can continue operating, but downstream consumption may require additional validation to avoid inconsistent or unreliable data. |
| Inconsistent naming conventions | Object and column names may reflect different development periods, teams, or standards. | Understanding, maintaining, and exposing the data to new consumers becomes harder. |
| Active and historical data separation | Active operational data and historical records may not be clearly separated by lifecycle rules. | Queries, maintenance, performance tuning, and service consumption become harder to manage. |
| Standardized error logging | Errors may be handled differently by each process or stored only in job logs/manual records. | Troubleshooting and auditability are limited because failures are not captured consistently. |
| Centralized job monitoring | Scheduled jobs may not have a single monitoring layer for status, duration, errors, dependencies, and reruns. | Operations teams may need to review multiple places to understand whether the platform is healthy. |
| Manual scripts dependency | Some corrections, validations, reloads, or reconciliations may depend on manual execution. | Operational risk increases because outcomes depend on individual knowledge and manual steps. |
| Reactive performance tuning | Performance may be tuned after issues appear instead of being managed through design standards, monitoring, indexing, and workload separation. | The source may become harder to scale as service and reporting demand increases. |
| Data retention rules | Retention, archive, and access rules for historical Sales data may not be clearly defined. | Historical growth may increase maintenance, backup, query, and operational complexity over time. |

## Risk of Doing Nothing

If the current source remains unchanged, the business may continue operating in the short term. However, the new web/service layer and Power BI reporting needs may inherit existing limitations.

| Risk | Description |
|---|---|
| New service inherits legacy complexity | The new service may depend on structures, rules, and behaviors that were not designed for service-based consumption. |
| Hidden logic affects service behavior | Triggers and implicit database behavior may produce unexpected results when the new service writes or updates data. |
| Reporting continues to pressure operations | Power BI or analytical queries may continue competing with operational workloads if a separate reporting-ready structure is not defined. |
| Increased change risk | Hardcoded logic, long procedures, and unclear dependencies may make new requirements slower and riskier to implement. |
| Inconsistent data consumption | Different consumers may interpret Sales data differently if there is no cleaner operational model and reporting-ready structure. |
| Continued manual support effort | Manual scripts, manual reconciliation, and non-standard error handling may continue increasing operational support effort. |
| Limited operational visibility | Without centralized monitoring and standardized logging, failures and performance issues may remain harder to diagnose. |
| Historical growth remains unmanaged | Without clear retention and active/historical separation, old data may continue increasing maintenance and performance complexity. |

## Modernization Drivers

The main driver is the implementation of a new web/service layer as part of a broader modernization plan. This requires evaluating whether the current source is suitable for future operational and analytical needs.

| Driver | Reason |
|---|---|
| New service readiness | The new web/service layer requires a cleaner operational model with predictable logic, clear relationships, and reliable access patterns. |
| Operational and reporting separation | Operational processing and Power BI reporting should not depend on the same structures without clear workload boundaries. |
| Service-safe business logic | Hidden logic, especially triggers, should not be the standard for new service-oriented behavior. |
| Standardized process control | Jobs, errors, dependencies, and reruns need centralized visibility and consistent handling. |
| Improved data reliability | Data integrity rules, validation, and reconciliation should be clearer before exposing data to new consumers. |
| Better maintainability | Naming conventions, process design, and data lifecycle rules should support long-term maintenance. |
| Power BI readiness | Reporting data should be structured for analytical consumption instead of relying directly on operational structures. |
| Historical data lifecycle | Active and historical data should be managed with clearer retention, archive, and access rules. |

## Modernization Boundary

This assessment does not imply that the current source is failing or that all existing processes are wrong. The current source remains operational and has supported the business for years.

| Scope Item | Boundary |
|---|---|
| Current Oracle source | Evaluated as the existing Sales source, not described as broken. |
| New web/service layer | Treated as the main modernization trigger requiring service-ready operational data. |
| Power BI reporting | Treated as the target analytical consumption need requiring reporting-ready data. |
| Existing business behavior | Must be reviewed and preserved where still valid. |
| Hidden or hardcoded logic | Must be identified and redesigned only where it creates risk for new requirements. |
| Sales domain | Assessment is focused on Sales-domain readiness, not a full enterprise platform replacement. |
