# Current State Assessment

## Document Goal

Evaluate the current Sales data platform, identify modernization drivers, and explain why building the Warehouse Gold model exposed through the Power BI semantic model as the target reporting source of truth is justified.

## Current Environment Summary

The current Sales platform contains two active databases hosted on the same on-premise SQL Server 2022 instance.

| Characteristic            | `Sales_Operational`                                           | `Sales_Analytics`                                                  |
| ------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------------ |
| Platform                  | SQL Server 2022                                               | SQL Server 2022                                                    |
| Hosting model             | On-premise                                                    | On-premise                                                         |
| Current role              | Operational system of record                                  | Current reporting source of truth                                  |
| Primary usage             | Transactional Sales operations                                | Business reporting and analysis                                    |
| Workload type             | OLTP-style operational workload                               | Analytical/reporting workload                                      |
| Data model                | Normalized model                                              | Star schema                                                        |
| Current status            | Active                                                        | Active                                                             |
| Data volume               | Millions of operational records                               | Tens of millions of historical analytical records                  |
| Historical range          | Current and recent operational history                        | Multi-year historical reporting data                               |
| Update frequency          | Continuously updated during business operations               | Refreshed through scheduled analytical loads                       |
| Main growth driver        | New Sales transactions                                        | Accumulated historical facts                                       |
| Largest data areas        | Sales orders and order details                                | Sales fact history                                                 |
| Maintenance pattern       | Operational tables maintained in current normalized structure | Historical fact data maintained through year-based physical copies |
| Business criticality      | Required for active Sales operations                          | Required for reporting, analysis, and decision-making              |

## What Works Well Today

| Aspect                 | Current Strength                                                                   |
| ---------------------- | ---------------------------------------------------------------------------------- |
| Operational processing | `Sales_Operational` supports on-premise transactional operations                   |
| Reporting model        | `Sales_Analytics` provides a curated star schema for business reporting            |
| Source of truth        | `Sales_Analytics` is a reliable current reporting source of truth for historical reporting |
| Execution control      | The analytical platform includes metadata-driven execution control                 |
| Validation             | Existing processes support validation and reconciliation                           |
| Data history           | Historical analytical data is already available in `Sales_Analytics`               |
| SQL Server platform    | SQL Server 2022 provides a stable relational database environment                  |

## Current Limitations

Although the current environment is reliable, its analytical capabilities are limited by the fact that the trusted reporting platform remains on-premise.

| Aspect                        | Current Limitation                                                                                             | Impact                                                                                                            |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Cloud analytical availability | Trusted Sales reporting data exists only in the on-premise `Sales_Analytics` database                          | Cloud-native analytics, AI, and data science workloads cannot consume the trusted model directly                  |
| Reporting platform dependency | Reporting depends on the on-premise SQL Server analytical database                                             | Reporting remains tied to SQL Server connectivity, availability, and operational constraints                      |
| Enterprise data sharing       | Curated Sales data is available in the on-premise reporting database, but not as a governed cloud data product | New cloud consumers require additional integration work                                                           |
| Analytical storage format     | Historical Sales data is stored in SQL Server relational structures                                            | The data is not directly available in Delta/Parquet format for Lakehouse, Spark, and Direct Lake scenarios        |
| Historical maintenance        | Large historical reporting tables are maintained through year-based physical copies                            | Maintenance is more complex as historical volume and usage increase                                               |
| Workload location             | Operational and analytical databases run on the same on-premise SQL Server instance                            | Analytical growth remains physically tied to the same server environment as operational processing                |
| Future platform alignment     | The current platform is optimized for traditional SQL Server reporting                                         | It does not provide a Fabric-native foundation for future reporting, AI, data science, and cross-domain analytics |

## Risk of Doing Nothing

If the current platform remains unchanged, the organization can continue operating successfully in the short term. However, future cloud analytics demand may be handled through isolated solutions instead of a governed Fabric-based analytical platform.

| Risk                                | Description                                                                                                                     |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| Duplicated data pipelines           | New cloud consumers may create separate extracts, replicated datasets, or custom pipelines from the on-premise Sales databases  |
| Fragmented Sales definitions        | Different teams may calculate Sales metrics differently if they build independent datasets outside the governed reporting model |
| Slower AI and data science adoption | Data science teams may not have direct governed access to curated Sales history in cloud-native analytical formats              |
| Increased maintenance effort        | Historical table-copy patterns may become harder to manage as data volume, retention, and usage increase                        |
| Delayed Fabric adoption             | Direct Lake, OneLake, Spark, and Fabric-native consumption may remain limited while trusted Sales data stays only on-premise    |
| Higher integration backlog          | Data engineering teams may spend more time creating one-off integrations instead of publishing reusable Sales data products     |

## Modernization Drivers

The main driver is to evolve the trusted Sales analytical model into a governed cloud analytical data product.

| Driver | Reason |
|---|---|
| Fabric reporting modernization | Move reporting ownership from on-premise `Sales_Analytics` to the Warehouse Gold model exposed through the Power BI semantic model |
| Direct Lake readiness | Support Fabric-native Power BI consumption patterns over trusted analytical data |
| AI and data science enablement | Provide governed access to historical and new Sales data in a cloud analytical platform |
| Reusable data products | Publish curated Sales data for multiple consumers instead of creating one-off extracts |
| Open analytical storage | Store analytical data using Delta/Parquet-based patterns for broader analytical use |
| Analytical workload separation | Keep operational processing on-premise while moving analytical ownership to the target analytics platform |
| Long-term maintainability | Reduce dependency on year-based physical table copies for historical reporting data |
| Enterprise analytical consumption | Prepare Sales data for reporting, AI, data science, and cross-domain analytics |

## Modernization Boundary

The project is not a full replacement of the Sales platform.

| Scope Item                                | Decision                                                                  |
| ----------------------------------------- | ------------------------------------------------------------------------- |
| `Sales_Operational`                       | Remains on-premise and continues supporting transactional operations      |
| `Sales_Analytics`                         | Provides historical reporting data for the historical reporting baseline  |
| `Sales_Operational`                       | Provides new transactional data for reporting transformation in the target analytics platform |
| Warehouse Gold model and Power BI semantic model | Target reporting source of truth                                  |

## Conclusion

The current Sales platform is reliable and well structured for its original purpose. `Sales_Operational` supports on-premise transactional operations, while `Sales_Analytics` provides a controlled and trusted reporting model with historical analytical data.

The modernization is not driven by a failed platform. It is driven by the need to expand Sales analytical data beyond traditional reporting and make it available as a reusable cloud data product for Power BI, AI, data science, and broader enterprise consumption.

The recommended approach is to keep `Sales_Operational` on-premise, use `Sales_Analytics` as the historical reporting baseline, and build the Warehouse Gold model exposed through the Power BI semantic model as the target reporting source of truth for both historical and new Sales reporting data.

This approach preserves the value of the current platform while addressing the main modernization need: moving trusted Sales analytics from an on-premise reporting dependency to a governed cloud analytical platform.
