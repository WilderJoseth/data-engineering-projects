# Current State Assessment

## Document Goal

Evaluate the current Sales data platform, identify modernization drivers, and explain why building Microsoft Fabric as the new reporting source of truth is justified.

## Current Environment Summary

The current Sales platform runs on a SQL Server 2022 on-premise instance.

It contains two main databases:

| Database            | Role                        | Data Model       | Current Status                                |
| ------------------- | --------------------------- | ---------------- | --------------------------------------------- |
| `Sales_Operational` | Operational source of truth | Normalized model | Active and remains on-premise                 |
| `Sales_Analytics`   | Reporting source of truth   | Star schema      | Active and provides historical reporting data |

The current architecture already separates operational and analytical responsibilities.

## What Works Well Today

| Area                   | Current Strength                                                                   |
| ---------------------- | ---------------------------------------------------------------------------------- |
| Operational processing | `Sales_Operational` supports on-premise transactional operations                   |
| Reporting model        | `Sales_Analytics` provides a curated star schema for business reporting            |
| Source of truth        | `Sales_Analytics` is a reliable reporting source of truth for historical reporting |
| Execution control      | The analytical platform includes metadata-driven execution control                 |
| Validation             | Existing processes support validation and reconciliation                           |
| Data history           | Historical analytical data is already available in `Sales_Analytics`               |
| SQL Server platform    | SQL Server 2022 provides a stable relational database environment                  |

## Current Limitations

Although the current environment is reliable, it has limitations for future enterprise analytics.

| Area                       | Current Limitation                                                               | Impact                                                                           |
| -------------------------- | -------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| Reporting dependency       | Reporting depends on the on-premise SQL Server analytical database               | Cloud analytics adoption remains limited                                         |
| Workload location          | Operational and analytical databases run on the same on-premise server instance  | Analytical workloads remain tied to the operational environment                  |
| Enterprise consumption     | Sales analytical data is mainly structured for reporting                         | Other consumers may require custom extracts                                      |
| AI and data science access | Data science teams need governed access to curated historical and new Sales data | Additional pipelines may be created outside the main reporting platform          |
| ETL scalability            | New departments may request new extracts or custom transformations               | Risk of duplicated ETL and inconsistent data definitions                         |
| Historical maintenance     | Large historical tables are maintained through year-based physical copies        | Maintenance can become harder as data volume and usage increase                  |
| Cloud integration          | Current analytical data is not stored in a cloud-native analytical format        | Fabric, OneLake, Spark, Direct Lake, and AI workloads cannot consume it natively |

## Modernization Drivers

The main driver is to turn Sales analytical data into a reusable cloud analytical data product.

| Driver                         | Reason                                                                                                            |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------------- |
| Fabric reporting modernization | Move reporting ownership from SQL Server `Sales_Analytics` to Microsoft Fabric                                    |
| Unified reporting source       | Combine historical reporting data from `Sales_Analytics` with new reporting data derived from `Sales_Operational` |
| Direct Lake readiness          | Support Fabric-native Power BI consumption patterns                                                               |
| AI and data science enablement | Provide governed access to historical and new Sales data                                                          |
| Reusable data products         | Reduce custom data extracts for each new consumer                                                                 |
| Open analytical storage        | Store analytical data using Delta/Parquet-based patterns                                                          |
| Workload separation            | Keep operational processing on-premise while moving analytics to the cloud                                        |
| Long-term maintainability      | Reduce dependency on year-based physical table copies for historical data management                              |
| Enterprise scalability         | Prepare Sales data for broader cross-domain analytical use                                                        |

## Risk of Doing Nothing

If the current platform remains unchanged, the organization may continue to operate successfully in the short term. However, the long-term analytics model becomes harder to scale.

| Risk                      | Description                                                                                   |
| ------------------------- | --------------------------------------------------------------------------------------------- |
| More duplicated ETL       | New departments may build separate extracts from `Sales_Analytics` or `Sales_Operational`     |
| Fragmented definitions    | Different teams may calculate Sales metrics differently                                       |
| Slower AI adoption        | Data science teams may not have direct governed access to curated Sales data                  |
| On-premise dependency     | Reporting remains tied to the on-premise SQL Server environment                               |
| Harder maintenance        | Historical table copies may increase operational complexity                                   |
| Limited cloud integration | Fabric-native capabilities cannot be fully used while analytical data remains only on-premise |

## Modernization Boundary

The project is not a full replacement of the Sales platform.

| Scope Item                                | Decision                                                                  |
| ----------------------------------------- | ------------------------------------------------------------------------- |
| `Sales_Operational`                       | Remains on-premise and continues supporting transactional operations      |
| `Sales_Analytics`                         | Provides historical reporting data for the Fabric baseline                |
| `Sales_Operational`                       | Provides new transactional data to Fabric for reporting transformation    |
| Microsoft Fabric                          | Unified reporting source of truth                                         |

## Design Implications

The current-state assessment leads to several design decisions.

| Assessment Finding                                   | Design Implication                                                                |
| ---------------------------------------------------- | --------------------------------------------------------------------------------- |
| `Sales_Operational` remains active on-premise        | Fabric must support ongoing ingestion from operational data                       |
| `Sales_Analytics` contains historical reporting data | Fabric must be seeded with historical reporting data                              |
| New reporting data comes from `Sales_Operational`    | Fabric must implement reporting transformations for new data                      |
| Fabric becomes the unified reporting source          | Historical and new data must be aligned under a consistent analytical model       |
| Current platform already has execution control       | The Fabric solution must include equivalent or improved control capabilities      |
| AI and data science need access                      | Data should be available in reusable analytical formats                           |
| New consumers should avoid custom extracts           | Curated data products should be published from Fabric                             |
| Historical data is large                             | Load strategy must support full reload, incremental load, and batch period reload |
| Cutover must be controlled                           | A clear reporting boundary date or period must be defined                         |

## Assessment Conclusion

The current Sales platform is reliable and well structured for its original purpose. `Sales_Operational` supports on-premise transactional operations, while `Sales_Analytics` provides a controlled and trusted reporting model with historical analytical data.

The modernization is not driven by a failed platform. It is driven by the need to expand Sales analytical data beyond traditional reporting and make it available as a reusable cloud data product for Power BI, AI, data science, and broader enterprise consumption.

The recommended approach is to keep `Sales_Operational` on-premise, use `Sales_Analytics` as the historical reporting baseline, and build Microsoft Fabric as the new unified reporting source of truth for both historical and new Sales reporting data.

This approach preserves the value of the current platform while moving analytical ownership to a cloud-native architecture based on Fabric, OneLake, Lakehouse/Warehouse patterns, open analytical storage, controlled execution, validation, and reconciliation.
